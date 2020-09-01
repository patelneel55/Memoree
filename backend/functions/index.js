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

admin.initializeApp();


/**
 * Uses the GCloud Video Intelligence API to analyze
 * video added to the GCloud Storage Bucket
 *
 * @param {*} bucketObject The video file added to GCloud storage
 */
async function runVideoAnalyzer(bucketObject) {

	let filePath = bucketObject.name;
	let jsonPath = bucketObject.name.split('.')[0] + '.json'

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


// The following functions are triggered when a new entity is added or
// modified in Google Cloud Storage

exports.helloWorld = functions.https.onRequest((request, response) => {
	response.send("Hello from Firebase!");
});

exports.analyzeVideo = functions
	.storage
	.bucket(functions.config().memoree.video_bucket)
	.object()
	.onFinalize(async (object) => {
		await Promise.all([runVideoAnalyzer(object)]);

	})
