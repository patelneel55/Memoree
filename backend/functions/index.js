/*
 * Copyright (c) 2020 Neel Patel
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

const functions = require('firebase-functions');
require("firebase-functions/lib/logger/compat"); // This is to properly structure console output with Node v10 in Firebase
const admin = require('firebase-admin');
const videoIntel = require('@google-cloud/video-intelligence');
const fs = require('fs');
const path = require('path');
const os = require('os');

const utils = require('./utils.js');
const algolia = require('./algolia.js');
const typesense = require('./typesense.js');

admin.initializeApp();


/**
 * Uses the GCloud Video Intelligence API to analyze
 * video added to the GCloud Storage Bucket
 *
 * @param {*} bucketObject The video file added to GCloud storage
 */
async function runVideoAnalyzer(bucketObject) {

	let filePath = bucketObject.name;
	let jsonPath = bucketObject.name.split(/(?:\.([^.]+))?$/)[0] + '_' + bucketObject.name.split(/(?:\.([^.]+))?$/)[1] + '.json'

	console.log(
		"Input URI: ", `gs://${bucketObject.bucket}/${bucketObject.name}\n`,
		"Output URI: ", `gs://${functions.config().memoree.json_bucket}/${jsonPath}`
	)

	let request = {
		inputUri: `gs://${bucketObject.bucket}/${bucketObject.name}`,
		outputUri: `gs://${functions.config().memoree.json_bucket}/${jsonPath}`,
		features: [
			"LABEL_DETECTION",
			"SHOT_CHANGE_DETECTION",
			"EXPLICIT_CONTENT_DETECTION",
			"FACE_DETECTION",
			"SPEECH_TRANSCRIPTION",
			"TEXT_DETECTION",
			"OBJECT_TRACKING",
			"LOGO_RECOGNITION",
			"PERSON_DETECTION"
		],
		videoContext: {
			speechTranscriptionConfig: {
				languageCode: "en-US",
				enableAutomaticPunctuation: true
			},
			faceDetectionConfig: {
				includeBoundingBoxes: true,
				includeAttributes: true,
			},
			personDetectionConfig: {
				includeBoundingBoxes: true,
				includePoseLandmarks: true,
				includeAttributes: true
			}
		}
	}

	const videoClient = new videoIntel.v1p3beta1.VideoIntelligenceServiceClient()

	const [operation] = await videoClient.annotateVideo(request);
	console.log("Video annotation initatied: ", operation)

}

async function addSearchRecords(bucketObject) {
	const tempFilePath = path.join(os.tmpdir(), bucketObject.name.split(/(?:\.([^.]+))?$/)[0] + '_' + bucketObject.name.split(/(?:\.([^.]+))?$/)[1] + '.json');

	console.log("Adding video records to TypeSense: ", bucketObject.name)
	fs.mkdirSync(path.dirname(tempFilePath), {recursive: true})
	await admin
		.storage()
		.bucket(bucketObject.bucket)
		.file(bucketObject.name)
		.download({destination: tempFilePath})

	const json = JSON.parse(fs.readFileSync(tempFilePath));

	const parseFunc = [
		utils.segment_label_annotations,
		utils.shot_label_annotations,
		utils.object_annotations,
		utils.logo_annotations,
		utils.text_annotations,
		utils.face_annotations,
		utils.speech_annotations
	]

	// Upload parsed data to search database using helper functions
	parseFunc.forEach((func) => {
		typesense.save(
			func(json.annotation_results),
			functions.config().memoree.search_host,
			functions.config().memoree.search_port,
			functions.config().memoree.search_apikey,
			functions.config().memoree.search_index
		)
	})
}

async function makeSearchRequest(queryParams)
{
	let tailoredResults = [];
	let request_per_page = queryParams.per_page * queryParams.page;
	queryParams.page = 1;

	while(tailoredResults.length < request_per_page)
	{
		let searchResult = await typesense.search(
			queryParams,
			functions.config().memoree.search_host,
			functions.config().memoree.search_port,
			functions.config().memoree.search_apikey,
			functions.config().memoree.search_index
		);
		if(searchResult.hits.length == 0)
			break;

		let results = searchResult.hits.map(obj => {
			return {
				"file_name": obj.document.file_name,
				"confidence": obj.document.confidence,
				"data": obj.document
			}
		});

		for (const item of results)
		{
			if(tailoredResults.findIndex((item1) => item1.file_name == item.file_name) == -1)
			{
				const file_blob = admin.storage().bucket(functions.config().memoree.video_bucket).file(item.file_name.replace(/^.+?[\/]/, ""));
				const [url] = await file_blob.getSignedUrl({
					version: 'v4',
					action: 'read',
					expires: Date.now() + (24 * 60 ** 2 * 1000)
				});

				item['videoURL'] = url;
				tailoredResults.push(item);
			}
		}

		queryParams.page++;
	}

	return tailoredResults;
}


// The following functions are triggered when a new entity is added or
// modified in Google Cloud Storage

const runtimeOpts = {
	timeoutSeconds: 90,
	memory: '2GB'
}

exports.helloWorld = functions.https.onRequest((request, response) => {
	response.send("Hello from Firebase!");
});

exports.analyzeVideo = functions
	.runWith(runtimeOpts)
	.storage
	.bucket(functions.config().memoree.video_bucket)
	.object()
	.onFinalize(async (object) => {
		await runVideoAnalyzer(object);
	})

exports.processJson = functions
	.runWith(runtimeOpts)
	.storage
	.bucket(functions.config().memoree.json_bucket)
	.object()
	.onFinalize(async (object) => {
		await addSearchRecords(object)
	})

exports.search = functions.runWith(runtimeOpts).https.onRequest(async (req, res) => {
	let queryParams = {
		"query": req.query.q,
		"sortType": req.query.sort || "relevant",
		"page": req.query.page || 1,
		"per_page": req.query.per_page || 25,
	}
	let resData = await makeSearchRequest(queryParams);

	res.send(resData);
});