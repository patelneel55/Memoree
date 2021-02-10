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
const spawn = require('child_process').spawn;

const ffmpegInstallation = require('@ffmpeg-installer/ffmpeg');

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

/**
 * Parses the data geenrated from the GCloud Video Intelligence API
 * and adds it to a search server for indexing 
 * 
 * @param {*} bucketObject The json file generated from the Video Intelligence API
 */
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
		if(functions.config().memoree.typesense.active)
			typesense.save(
				func(json.annotation_results),
				functions.config().memoree.typesense.host,
				functions.config().memoree.typesense.port,
				functions.config().memoree.typesense.api_key,
				functions.config().memoree.typesense.index
			)
		else if(functions.config().memoree.algolia.active)
			algolia.save(
				func(json.annotation_results),
				functions.config().memoree.algolia.app_id,
				functions.config().memoree.algolia.admin_key,
				functions.config().memoree.algolia.index
			)
	})
}

/**
 * Resolve a search request make to the respective search index
 * server (Algolia or Typesense)
 * 
 * @param {*} queryParams Search params to customize request
 */
async function makeSearchRequest(queryParams)
{
	let tailoredResults = []
	if(functions.config().memoree.typesense.active)
	{
		let request_per_page = queryParams.per_page * queryParams.page;
		queryParams.page = 1;
	
		while(tailoredResults.length < request_per_page)
		{
			let searchResult = await typesense.search(
				queryParams,
				functions.config().memoree.typesense.host,
				functions.config().memoree.typesense.port,
				functions.config().memoree.typesense.api_key,
				functions.config().memoree.typesense.index
			);
			if(searchResult.grouped_hits.length == 0)
				break;
	
			let results = searchResult.grouped_hits.map(obj => {
				return {
					"file_name": obj.hits[0].document.file_name,
					"confidence": obj.hits[0].document.confidence,
					"document": obj.hits[0].document
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
		tailoredResults = tailoredResults.slice(0, request_per_page);
	}
	else if(functions.config().memoree.algolia.active)
	{
		let searchResult = await algolia.search(
			queryParams,
			functions.config().memoree.algolia.app_id,
			functions.config().memoree.algolia.api_key,
			functions.config().memoree.algolia.index
		)

		let results = searchResult.map(obj => {
			Object.keys(obj).forEach((key) => {
				if(["_highlightResult", "_snippetResult", "_rankingInfo", "_distinctSeqID"].includes(key))
					delete obj[key]
			})
			return {
				"file_name": obj.file_name,
				"confidence": obj.confidence,
				"document": obj
			}
		});

		for(const item of results)
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

	return tailoredResults;
}

/**
 * Generate a base64 data URL representing an image from a video
 * source using ffmpeg
 *  
 * @param {*} videoURL Video source url used to extract thumbnail
 */
function generateThumbnail(videoURL) {

	// Generate unique random file name
    do {
        var fileName = Math.random().toString(36).substring(7);
        var filePath = path.join(os.tmpdir(), fileName) + ".bmp";
	} while(fs.existsSync(filePath));

	return new Promise((resolve, reject) => {
		let cmd = ffmpegInstallation.path;
		let args = [
			'-y',
			'-i', videoURL,
			'-frames:v', '1',
			filePath
		]
		let proc = spawn(cmd, args);
		proc.on('close', function(code) {
			if(code != 0)
				return reject("FFMPEG error occured.");

			let dataURL = fs.readFileSync(filePath, 'base64');
			fs.unlinkSync(filePath);
			return resolve(dataURL);
		});
	});
}

/**
 * Authorize access to user based on whitelist
 * under Firebase Firestore
 * 
 * @param {*} email Google email of user
 */
async function emailExists(email) {
	const record = await admin
		.firestore()
		.collection('memoree_whitelist')
		.doc('authorized_emails')
		.get();
	
	if(!record.exists)
		return false;
	console.log(record.data().emails.includes(email))
	return record.data().emails.includes(email);
}

// The following functions are triggered externally 
// when a new entity is added in Google Cloud Storage or
// a request is made

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

exports.search = functions.runWith(runtimeOpts).https.onCall(async (data, context) => {
	if(!context.auth || !context.auth.token.email)
		throw new functions.https.HttpsError(
			'failed-precondition',
			'The function must be called while authenticated',
		);
	
	const isWhitelisted = await emailExists(context.auth.token.email);
	if(!isWhitelisted)
		throw new functions.https.HttpsError(
			'failed-precondition',
			'User ${context.auth.token.email} does not have access to this server.\nPlease contact your admin.'
		);

	return new Promise(async (resolve, reject) => {
		let queryParams = {
			"query": data.q,
			"sortType": data.sort || "relevant",
			"page": data.page || 1,
			"per_page": data.per_page || 25,
		}

		try{
			let resData = await makeSearchRequest(queryParams);
			resolve(resData);
		}catch(err){
			console.error(err);
			reject(new functions.https.HttpsError(500, "Unexpected error occured.", err));
		}
	});
});

exports.generateThumbnail = functions.runWith(runtimeOpts).https.onCall(async (data, context) => {
	if(!context.auth || !context.auth.token.email)
		throw new functions.https.HttpsError(
			'failed-precondition',
			'The function must be called while authenticated',
		);
	
	const isWhitelisted = await emailExists(context.auth.token.email);
	if(!isWhitelisted)
		throw new functions.https.HttpsError(
			'failed-precondition',
			'User ${context.auth.token.email} does not have access to this server.\nPlease contact your admin.'
		);

	return new Promise(async (resolve, reject) => {
		try {
			let imageData = await generateThumbnail(data.video_url);
			resolve(imageData);
		}catch(err){
			console.error(err);
			reject(new functions.https.HttpsError(500, "Unexpected error occured.", err));
		}
	});
});

exports.checkWhitelist = functions.runWith(runtimeOpts).https.onCall((data, context) => {
	if(!context.auth || !context.auth.token.email)
		throw new functions.https.HttpsError(
			'failed-precondition',
			'The function must be called while authenticated',
		);

	return new Promise(async (resolve, reject) => {
		let isWhitelisted = await emailExists(context.auth.token.email);
		resolve(isWhitelisted);
	});
});
