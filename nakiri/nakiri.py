import os
import smtplib, ssl

from flask import Flask
from flask import request

app = Flask(__name__)

@app.route("/")
def index():
    return "<p>This is the home of Nakiri.</p>"

@app.route("/.well-known/acme-challenge/d6m8SrfIajJU1THxpJ9Ux6jrXeU3tfRVn-nLzVZ7ngk")
def index2():
    return "d6m8SrfIajJU1THxpJ9Ux6jrXeU3tfRVn-nLzVZ7ngk.Zrg1nlff7LHNovPpwBykcwKy3SeoSQIqfrULVjAs3q0"


@app.route("/report-uri", methods=["POST"])
def report_uri():
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

