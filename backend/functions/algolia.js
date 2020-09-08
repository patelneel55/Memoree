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

const algoliasearch = require('algoliasearch');
const encode = require('hashCode').hashCode;

exports.save = (records, appId, apiKey, targetIndex) => {
    function _generateObjectID(obj) {
        return Math.abs(
            encode().value(
                obj.file_name +
                obj.subheader +
                obj.confidence +
                (obj.text || obj.entity || obj.transcript)
            )
        )
    }

    const algoliaClient = algoliasearch(appId, apiKey)
    const index = algoliaClient.initIndex(targetIndex)

    // Add object id to records
    records = records.map((obj) => {
        return {
            ...obj,
            objectID: _generateObjectID(obj)
        }
    })

    // Save records to Algolia
    index.saveObjects(records)
}