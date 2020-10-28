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

const TypeSense = require('typesense');
const encode = require('hashcode').hashCode;

function get_search_server_schema(targetIndex)
{
    return {
        name: targetIndex,
        num_documents: 0,
        fields: [
            {
                name: "file_name",
                type: "string",
                facet: false,
            },
            {
                name: "keywords",
                type: "string[]",
                facet: false,
                optional: true
            },
            {
                name: "entity",
                type: "string",
                facet: false,
                optional: true
            },
            {
                name: "confidence",
                type: "float",
                facet: false,
            },
            {
                name: "text",
                type: "string",
                facet: false,
                optional: true
            },
            {
                name: "subheader",
                type: "string",
                facet: false,
            },
            {
                name: "transcript",
                type: "string",
                facet: false,
                optional: true
            },
            {
                name: "words",
                type: "string[]",
                facet: false,
                optional: true
            },
        ],
        default_sorting_field: "confidence"
    }
}

exports.save = (records, host, port, apiKey, targetIndex) => {
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

    // Add object id to records
    records = records.map((obj) => {
        return {
            ...obj,
            id: _generateObjectID(obj).toString()
        }
    })

    // Create search server client
    const typesenseClient = new TypeSense.Client({
        nodes: [{
            host: host,
            port: port,
            protocol: "http"
        }],
        apiKey: apiKey,
        'connectionTimeoutSeconds': 2
    });

    // Import records to typesense server, create a new collection if applicable
    typesenseClient.collections(targetIndex).documents().import(records, {action: 'upsert'})
    .catch(err => {
        // Create new index if 404 error was returned
        if(err.httpStatus == 404)
        {
            typesenseClient.collections().create(get_search_server_schema(targetIndex))
            .then(res => {
                typesenseClient.collections(targetIndex).documents().import(records, {action: 'upsert'});
            });
        }
        else
            console.error(err);
    })
    .then(res => {
        errors = []
        for(let i = 0;i < res.length;i++)
        {
            if(!res[i].success)
                errors.push(i);
        }
        if(errors.length != 0)
            console.log("Errors: ", errors);
    });
}