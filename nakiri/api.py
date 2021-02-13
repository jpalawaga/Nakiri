import os
import smtplib, ssl

from flask import Flask
from flask import request

app = Flask(__name__)

@app.route("/")
def index():
    return "<p>This is the home of Nakiri.</p>"


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

    return 'OK'


def send_email(ip, uri):
    port = 465  # For SSL
    smtp_server = "smtp.gmail.com"
    sender_email = os.getenv('GMAIL_USER')  # Enter your address
    receiver_email = os.getenv('GMAIL_USER')  # Enter receiver address
    password = os.getenv('GMAIL_APP_PASSWORD')
    message = f"""\
    Subject: URL with spam reported

    User at {ip} reported uri {uri}."""

    context = ssl.create_default_context()
    with smtplib.SMTP_SSL(smtp_server, port, context=context) as server:
        server.login(sender_email, password)
        server.sendmail(sender_email, receiver_email, message)

