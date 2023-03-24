from flask import Flask, render_template
import datetime
import json
import subprocess
import os
import sys


app = Flask(__name__)

projects_file = open("../projects.json")
projects = json.load(projects_file)


@app.route("/")
def home():
    logs = {}

    for app_name in projects["services"]:
        log_filename = f"logs/{app_name}.txt"

        if os.path.isfile(log_filename):
            f = open(log_filename, "r")
            logs[app_name] = f.read()

    return render_template("status.html", logs=logs)


@app.route("/hook/<action>/<app_type>/<app_name>")
@app.route("/hook/<action>/<app_type>/<app_name>/")
@app.route("/hook/<action>/<app_type>/<app_name>/<branch_name>")
@app.route("/hook/<action>/<app_type>/<app_name>/<branch_name>/")
def hook(action: str, app_type: str, app_name: str, branch_name="main"):
    app_repo = None

    if app_type == "service" and app_name in projects["services"]:
        app_repo = projects["services"][app_name]
    elif app_type == "daemon" and app_name in projects["daemon"]:
        app_repo = projects["daemon"][app_name]

    if not app_repo:
        return f"App <code>{app_name}</code> does not exist in projects.json."

    if action == "update":
        log = open(f"logs/{app_name}.txt", "w")
        subprocess.Popen(
            ["bash", "scripts/update.sh", app_name, app_repo, branch_name],
            stdout=log,
            stderr=log,
        )
        return render_template("hook.html")

    return "Invalid action."


@app.route("/poweroff")
def poweroff():
    sys.exit()


if __name__ == "__main__":
    app.run(
        debug=True,
        port=3030,
        host="0.0.0.0",
        ssl_context=(
            "/root/ssl/certbot/conf/live/cocoshouse.xyz/cert.pem",
            "/root/ssl/certbot/conf/live/cocoshouse.xyz/privkey.pem",
        ),
    )
