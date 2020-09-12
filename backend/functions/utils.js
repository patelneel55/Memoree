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

exports.segment_label_annotations = (annotation_results) => {
    return annotation_results.filter((annotation) => {
        return annotation.segment_label_annotations
    })
        .flatMap((annotation) => {
            return annotation.segment_label_annotations.flatMap((segment_label) => {
                let categories = []

                if (segment_label.hasOwnProperty("category_entities"))
                    categories = segment_label.category_entities.flatMap((category) => {
                        return category.description
                    })

                return segment_label.segments.flatMap((segment) => {
                    return {
                        file_name: annotation.input_uri,
                        subheader: "segment_label_annotations",
                        keywords: categories,
                        entity: segment_label.entity.description,
                        start_time: segment.segment.start_time_offset.nanos || segment.segment.end_time_offset.seconds * 1000 + (segment.segment.end_time_offset.nanos / 1000000) - 5000,
                        end_time: segment.segment.end_time_offset.seconds * 1000 + (segment.segment.end_time_offset.nanos / 1000000),
                        confidence: segment.confidence
                    }
                })
            })
        })
}

exports.shot_label_annotations = (annotation_results) => {
    return annotation_results.filter((annotation) => {
        return annotation.shot_label_annotations
    })
        .flatMap((annotation) => {
            return annotation.shot_label_annotations.flatMap((shot_label) => {
                let categories = []

                if (shot_label.hasOwnProperty("category_entities"))
                    categories = shot_label.category_entities.flatMap((category) => {
                        return category.description
                    })

                return shot_label.segments.flatMap((segment) => {
                    return {
                        file_name: annotation.input_uri,
                        subheader: "shot_label_annotations",
                        keywords: categories,
                        entity: shot_label.entity.description,
                        start_time: segment.segment.start_time_offset.nanos || segment.segment.end_time_offset.seconds * 1000 + (segment.segment.end_time_offset.nanos / 1000000) - 5000,
                        end_time: segment.segment.end_time_offset.seconds * 1000 + (segment.segment.end_time_offset.nanos / 1000000),
                        confidence: segment.confidence
                    }
                })
            })
        })
}

exports.object_annotations = (annotation_results) => {
    return annotation_results.filter((annotation) => {
        return annotation.object_annotations
    })
        .flatMap((annotation) => {
            return annotation.object_annotations.flatMap((object) => {

                return {
                    file_name: annotation.input_uri,
                    subheader: "object_annotations",
                    keywords: [],
                    entity: object.entity.description,
                    start_time: object.segment.end_time_offset.seconds * 1000 + (object.segment.end_time_offset.nanos / 1000000) - 5000,
                    end_time: object.segment.end_time_offset.seconds * 1000 + (object.segment.end_time_offset.nanos / 1000000),
                    confidence: object.confidence
                }
            })
        })
}

exports.logo_annotations = (annotation_results) => {
    return annotation_results.filter((annotation) => {
        return annotation.logo_recognition_annotations
    })
        .flatMap((annotation) => {
            return annotation.logo_recognition_annotations.flatMap((logo) => {

                return logo.segments.flatMap((segment) => {
                    return {
                        file_name: annotation.input_uri,
                        subheader: "logo_annotations",
                        keywords: [],
                        entity: logo.entity.description,
                        start_time: segment.end_time_offset.seconds * 1000 + (segment.end_time_offset.nanos / 1000000) - 5000,
                        end_time: segment.end_time_offset.seconds * 1000 + (segment.end_time_offset.nanos / 1000000),
                        confidence: 0.8
                    }
                })
            })
        })
}

exports.text_annotations = (annotation_results) => {
    return annotation_results.filter((annotation) => {
        // Ignore annotations without text annotations
        return annotation.text_annotations;
    })
        .flatMap((annotation) => {
            return annotation.text_annotations.flatMap((tt) => {
                return tt.segments.flatMap((segment) => {
                    return {
                        file_name: annotation.input_uri,
                        subheader: "text_annotations",
                        text: tt.text,
                        confidence: segment.confidence,
                        start_time: segment.segment.end_time_offset.seconds * 1000 + (segment.segment.end_time_offset.nanos / 1000000) - 5000,
                        end_time: segment.segment.end_time_offset.seconds * 1000 + (segment.segment.end_time_offset.nanos / 1000000),
                    };
                });
            });
        });
}

exports.face_annotations = (annotation_results) => {
    return annotation_results.filter((annotation) => {
        return annotation.face_detection_annotations
    })
        .flatMap((annotation) => {
            return annotation.face_detection_annotations.flatMap((face) => {

                return face.tracks.flatMap((track) => {
                    return track.attributes.flatMap((attr) => {
                        return {
                            file_name: annotation.input_uri,
                            subheader: "face_annotations",
                            keywords: [],
                            entity: attr.name,
                            confidence: attr.confidence,
                            start_time: track.segment.end_time_offset.seconds * 1000 + (track.segment.end_time_offset.nanos / 1000000) - 5000,
                            end_time: track.segment.end_time_offset.seconds * 1000 + (track.segment.end_time_offset.nanos / 1000000),
                        }
                    })
                })
            })
        })
}

exports.speech_annotations = (annotation_results) => {
    return annotation_results.filter((annotation) => {
        // Ignore annotations without speech transcriptions
        return annotation.speech_transcriptions;
    }).flatMap((annotation) => {
        // Sometimes transcription options are empty, so remove those
        return annotation.speech_transcriptions.filter((transcription) => {
            return Object.keys(transcription.alternatives[0]).length;
        })
            .map((transcription) => {
                // We always want the first transcription alternative
                const alternative = transcription.alternatives[0];
                // Streamline the json so we have less to store
                return {
                    file_name: annotation.input_uri,
                    transcript: alternative.transcript,
                    confidence: alternative.confidence,
                    start_time: alternative.words[0].start_time,
                    words: alternative.words.map((word) => {
                        return {
                            start_time: word.start_time.seconds || 0,
                            end_time: word.end_time.seconds,
                            word: word.word,
                        };
                    }),
                };
            });
    });
}