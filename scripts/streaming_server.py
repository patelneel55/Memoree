from flask import jsonify, request, Response, abort, Flask
import subprocess
import os
import re

app = Flask(__name__)

@app.after_request
def add_header(response):
    """Add header to response."""
    response.cache_control.max_age = 300
    response.cache_control.no_cache = True
    response.cache_control.must_revalidate = True
    response.cache_control.proxy_revalidate = True
    return response


@app.route('/media/<path:path>')
def media_transcode(path):
    start = float(request.args.get("start") or 0)
    def generate_stream():
        cmdline = "ffmpeg -ss " + str(start) + " -i " + path + " -f mp4 -strict experimental -preset ultrafast -movflags frag_keyframe+empty_moov+faststart pipe:1"
        proc = subprocess.Popen(cmdline.split(), stdout=subprocess.PIPE, stderr=open(os.devnull, 'w'))
        try:
            f = proc.stdout
            byte= f.read(65535)
            while byte:
                yield byte
                byte = f.read(65536)
        finally:
            proc.kill()
    
    return Response(response=generate_stream(), status=200, mimetype="video/mp4", 
                    headers={'Access-Control-Allow-Origin': '*', "Content-Type": "video/mp4",
                            "Content-Disposition": "inline", "Content-Transfer-Enconding": "binary"})

@app.route('/duration/<path:path>')
def media_duration(path):
    cmdline = "ffmpeg -i  " + path;
    duration = -1
    proc = subprocess.Popen(cmdline.split(), stderr=subprocess.PIPE, stdout=open(os.devnull, 'w'))
    try:
        for line in proc.stderr:
            line = str(line)
            line = line.rstrip()
            m = re.search('Duration: (..):(..):(..)\.(..)', line)
            if m is not None:
                duration = int(m.group(1)) * 3600 * 1000 + int(m.group(2)) * 60 * 1000 + int(m.group(3)) * 1000 + (int(m.group(4)) * 10 if int(m.group(4)) < 100 else int(m.group(4)))
    finally:
        proc.kill()

    try:
        return jsonify({
            "duration": duration
        }), 200, {'Access-Control-Allow-Origin': '*'}
    except IOError:
        abort(404)

if(__name__ == "__main__"):
    app.run(host="0.0.0.0", port=8024, threaded=True, debug=False)

