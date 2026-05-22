from flask import (
    Flask,
    render_template,
    request,
    redirect,
    url_for,
    flash
)

from flask_sqlalchemy import SQLAlchemy
from werkzeug.utils import secure_filename
from dotenv import load_dotenv

import boto3
import os

from datetime import datetime

# Env

load_dotenv()

# App

app = Flask(
    __name__,
    template_folder="template",
    static_folder="static"
)

app.secret_key = os.getenv(
    "SECRET_KEY",
    "cloudvault-secret"
)

# DB

app.config["SQLALCHEMY_DATABASE_URI"] = (
    "sqlite:///cloudvault.db"
)

app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

# S3

AWS_REGION = os.getenv("AWS_REGION")
S3_BUCKET = os.getenv("S3_BUCKET")

s3 = boto3.client(
    "s3",
    aws_access_key_id=os.getenv(
        "AWS_ACCESS_KEY_ID"
    ),
    aws_secret_access_key=os.getenv(
        "AWS_SECRET_ACCESS_KEY"
    ),
    region_name=AWS_REGION
)

# Model

class File(db.Model):

    __tablename__ = "files"

    id = db.Column(
        db.Integer,
        primary_key=True
    )

    filename = db.Column(
        db.String(255),
        nullable=False
    )

    file_url = db.Column(
        db.String(500),
        nullable=False
    )

    uploaded_at = db.Column(
        db.DateTime,
        default=datetime.utcnow
    )

# Home

@app.route("/")
def home():

    return render_template(
        "index.html"
    )

# Dashboard

@app.route("/dashboard")
def dashboard():

    files = File.query.order_by(
        File.uploaded_at.desc()
    ).all()

    return render_template(
        "main.html",
        files=files
    )

# Upload

@app.route(
    "/upload",
    methods=["POST"]
)
def upload():

    file = request.files.get(
        "file"
    )

    if not file:

        flash(
            "Please select a file"
        )

        return redirect(
            url_for("dashboard")
        )

    try:

        filename = secure_filename(
            file.filename
        )

        s3.upload_fileobj(
            file,
            S3_BUCKET,
            filename
        )

        file_url = (
            f"https://{S3_BUCKET}"
            f".s3.{AWS_REGION}"
            f".amazonaws.com/{filename}"
        )

        new_file = File(
            filename=filename,
            file_url=file_url
        )

        db.session.add(
            new_file
        )

        db.session.commit()

        flash(
            "File uploaded successfully"
        )

    except Exception as e:

        flash(
            f"Upload failed: {e}"
        )

    return redirect(
        url_for("dashboard")
    )

# Delete

@app.route(
    "/delete/<int:file_id>",
    methods=["POST"]
)
def delete_file(file_id):

    file = File.query.get_or_404(
        file_id
    )

    try:

        s3.delete_object(
            Bucket=S3_BUCKET,
            Key=file.filename
        )

    except Exception:
        pass

    db.session.delete(
        file
    )

    db.session.commit()

    flash(
        "File deleted successfully"
    )

    return redirect(
        url_for("dashboard")
    )

# Health

@app.route("/health")
def health():

    return {
        "status": "healthy"
    }

# Start

if __name__ == "__main__":

    with app.app_context():
        db.create_all()

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )