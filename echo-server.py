import os
import logging
from flask import Flask, request, send_from_directory
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = os.path.expanduser('~/Desktop/echo-server/')


@app.route('/')
def hello_world():
    return 'Hello World!'

@app.route('/test/', methods=['GET', ])
def test_message():
    return 'Test message!'

@app.route('/echo/', methods=['POST', ])
def echo_file():
    if request.method == 'POST':
        
        # Make sure the request contains files.
        if not request.files:
            return 'No files in request'

        # Store the file to the filesystem and send it in the HTTP response.
        file_data = next(request.files.values())
        if file_data:
            file_name = secure_filename(file_data.filename)
            file_data.save(os.path.join(app.config['UPLOAD_FOLDER'], file_name))
            return send_from_directory(directory=app.config['UPLOAD_FOLDER'], filename=file_name)

if __name__ == '__main__':
    # Create the uploads folder if it doesn't exist already.
    if not os.path.exists(app.config['UPLOAD_FOLDER']):
        os.makedirs(app.config['UPLOAD_FOLDER'])

    app.run()
