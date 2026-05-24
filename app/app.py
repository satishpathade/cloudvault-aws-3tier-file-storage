from flask import Flask, render_template, request, jsonify, redirect, url_for
from dotenv import load_dotenv
import boto3
import os
from botocore.exceptions import ClientError

USE_MOCK_DATA = True

load_dotenv()
app = Flask(__name__)

AWS_REGION = os.getenv("AWS_REGION")
BUCKET_NAME = os.getenv("S3_BUCKET_NAME")

print("Region:", AWS_REGION)
print("Bucket Name:", BUCKET_NAME)

s3 = boto3.client(
    "s3",
    region_name=AWS_REGION,
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
)
# Helper Functions

def get_all_files():
    """
    Fetch all files from S3 bucket
    """
    files = []

    try:
        response = s3.list_objects_v2(Bucket=BUCKET_NAME)

        if "Contents" in response:
            for obj in response["Contents"]:
                files.append({
                    "key": obj["Key"],
                    "size": round(obj["Size"] / 1024, 2),
                    "last_modified": obj["LastModified"]
                })

    except ClientError as e:
        print(e)

    return files


def get_storage_used():
    """
    Calculate total storage used
    """
    total_bytes = 0

    try:
        response = s3.list_objects_v2(Bucket=BUCKET_NAME)

        if "Contents" in response:
            total_bytes = sum(
                obj["Size"] for obj in response["Contents"]
            )

    except ClientError:
        pass

    return round(total_bytes / (1024 * 1024), 2)

# Pages
@app.route("/")
def home():
    return render_template("index.html")


@app.route("/dashboard")
def dashboard():

    if USE_MOCK_DATA:
        return render_template(
            "dashboard.html",
            total_files=5,
            storage_used=1.2,
            recent_files=[]
        )

    files = get_all_files()

    return render_template(
        "dashboard.html",
        total_files=len(files),
        storage_used=get_storage_used(),
        recent_files=files[:5]
    )


@app.route("/upload")
def upload_page():
    return render_template("upload.html")


from datetime import datetime

@app.route("/gallery")
def gallery():

    if USE_MOCK_DATA:
        files = [
            {
                "key": "resume.pdf",
                "size": 245,
                "last_modified": datetime.now()
            },
            {
                "key": "cloudvault.png",
                "size": 512,
                "last_modified": datetime.now()
            }
        ]

        return render_template(
            "gallery.html",
            files=files
        )

    files = get_all_files()

    return render_template(
        "gallery.html",
        files=files
    )

# Upload File

@app.route("/upload-file", methods=["POST"])
def upload_file():

    if "file" not in request.files:
        return jsonify({
            "success": False,
            "message": "No file selected"
        }), 400

    file = request.files["file"]

    if file.filename == "":
        return jsonify({
            "success": False,
            "message": "Empty filename"
        }), 400

    try:

        s3.upload_fileobj(
            file,
            BUCKET_NAME,
            file.filename
        )

        return jsonify({
            "success": True,
            "message": "File uploaded successfully"
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500


# Delete File

@app.route("/delete/<path:file_key>", methods=["DELETE"])
def delete_file(file_key):

    try:

        s3.delete_object(
            Bucket=BUCKET_NAME,
            Key=file_key
        )

        return jsonify({
            "success": True,
            "message": "File deleted successfully"
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500

# Download File

@app.route("/download/<path:file_key>")
def download_file(file_key):

    try:

        download_url = s3.generate_presigned_url(
            "get_object",
            Params={
                "Bucket": BUCKET_NAME,
                "Key": file_key
            },
            ExpiresIn=3600
        )

        return redirect(download_url)

    except Exception as e:

        return str(e), 500

# API - Get All Files

@app.route("/api/files")
def api_files():

    return jsonify(
        get_all_files()
    )

# Run Application
if __name__ == "__main__":
    app.run(
        debug=True,
        host="0.0.0.0",
        port=5000
    )