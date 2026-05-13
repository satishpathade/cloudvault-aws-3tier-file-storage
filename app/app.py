from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from werkzeug.utils import secure_filename
from dotenv import load_dotenv
import boto3
import os
from datetime import datetime

load_dotenv()

app = Flask(
    __name__,
    template_folder="template",
    static_folder="static",
    static_url_path="/static"
)
app.secret_key = os.getenv("SECRET_KEY", "dev-secret-key")

DB_USERNAME = os.getenv("DB_USERNAME")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")

app.config["SQLALCHEMY_DATABASE_URI"] = (
    f"mysql+pymysql://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"
)

app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

# Database

db = SQLAlchemy(app)

# AWS S3

s3 = boto3.client(
    "s3",
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
    region_name=os.getenv("AWS_REGION")
)

S3_BUCKET = os.getenv("S3_BUCKET")


# Database Model

class File(db.Model):
    __tablename__ = "files"

    id = db.Column(db.Integer, primary_key=True)
    filename = db.Column(db.String(255), nullable=False)
    file_url = db.Column(db.String(500), nullable=False)
    uploaded_at = db.Column(db.DateTime, default=datetime.utcnow)


# Home Page

@app.route('/')
def home():
    return render_template('index.html')


# Dashboard

@app.route('/dashboard')
def dashboard():
    files = File.query.order_by(File.uploaded_at.desc()).all()
    return render_template('dashboard.html', files=files)


# Upload File

@app.route('/upload', methods=['GET', 'POST'])
def upload():
    if request.method == 'POST':

        if 'file' not in request.files:
            flash('No file selected')
            return redirect(request.url)

        file = request.files['file']

        if file.filename == '':
            flash('Please select a file')
            return redirect(request.url)

        try:
            filename = secure_filename(file.filename)

            # Upload to S3
            s3.upload_fileobj(
                file,
                S3_BUCKET,
                filename,
                ExtraArgs={"ACL": "public-read"}
            )

            file_url = (
                f"https://{S3_BUCKET}.s3.amazonaws.com/{filename}"
            )

            # Save metadata to RDS
            new_file = File(
            filename=filename,
            file_url=file_url
            )

            db.session.add(new_file)
            db.session.commit()

            flash('File uploaded successfully')
            return redirect(url_for('dashboard'))

        except Exception as error:
            flash(f'Upload failed: {error}')
            return redirect(request.url)

    return render_template('upload.html')


# Gallery Page

@app.route('/gallery')
def gallery():
    files = File.query.order_by(File.uploaded_at.desc()).all()
    return render_template('gallery.html', files=files)


# Settings Page

@app.route('/settings')
def settings():
    return render_template('setting.html')


if __name__ == '__main__':
    with app.app_context():
        db.create_all()

    app.run(debug=True)