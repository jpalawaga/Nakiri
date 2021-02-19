import base64
import os
import smtplib, ssl

from flask import Flask
from flask import request

app = Flask(__name__)

@app.route("/")
def index():
    return "<p>This is the home of Nakiri.</p>"

@app.route("/report-uri", methods=["POST"])
def report_uri_post():
    # This is really an error state, but we'll just be transparent
    # to the user. Besides, this way, there's fewer error states to worry about
    # for the app, and less surface area to worry about for security purposes.
    if request.content_length > 1000:
        return 'OK'

    try:
        data = request.get_data(as_text=True)
        if (data.startswith('http')):
            send_email(request.remote_addr, data)
    except:
        pass

    # This will mask all errors--not great for error reporting story.
    # There's also nothing the client can do, so this is fine for now.
    return 'OK'

@app.route("/report-uri", methods=["GET"])
def report_uri_get():
    uri = request.args.get('uri')

    # Should never be this long anyhow, given http rfc.
    if len(uri) > 2048:
        return 'OK'

    try:
        data = base64.b64decode(uri).decode("utf-8")
        if (data.startswith('http')):
            send_email(request.remote_addr, data)
    except:
        pass

    # This will mask all errors--not great for error reporting story.
    # There's also nothing the client can do, so this is fine for now.
    return 'OK'


def send_email(ip, uri):
    port = 465  # For SSL
    smtp_server = "smtp.gmail.com"
    sender_email = os.getenv('GMAIL_USER')
    receiver_email = os.getenv('GMAIL_USER')
    password = os.getenv('GMAIL_APP_PASSWORD')
    message = f"""\
From: Nakiri Feedback ({sender_email})
Subject: URL with spam reported

User at {ip} reported uri {uri}."""

    context = ssl.create_default_context()
    with smtplib.SMTP_SSL(smtp_server, port, context=context) as server:
        server.login(sender_email, password)
        server.sendmail(sender_email, receiver_email, message)

