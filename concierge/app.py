from flask import Flask, render_template
from ansi2html import Ansi2HTMLConverter
import json
import subprocess
import os
import sys

app = Flask(__name__)
conv = Ansi2HTMLConverter()

projects_file = open("../projects.json")
projects = json.load(projects_file)


@app.route("/")
def home():
    return render_template("status.html", projects=projects)


@app.route("/logs")
def logs():
    logs = {}

    for app_type in ["services", "daemons"]:
        for app_name in projects[app_type]:
            deploy_log_filename = f"logs/{app_name}.deploy.txt"

            logs[app_name] = {
                "deploy": "",
                "app": conv.convert(subprocess.check_output(
                    ["bash", "scripts/app_log.sh", app_name],
                    encoding="utf8",
                )),
            }

            if os.path.isfile(deploy_log_filename):
                f = open(deploy_log_filename, "r")
                logs[app_name]["deploy"] = conv.convert(f.read())

    return logs


@app.route("/infra_logs")
def infra_logs():
    concierge_app_log_filename = f"logs/concierge.app.txt"

    logs = {
        "concierge": "",
        "reverse-proxy": subprocess.check_output(
            ["bash", "scripts/app_log.sh", "cocos-concierge"], encoding="utf8"
        ),
    }

    concierge_app_log_line_limit = 700

    if os.path.isfile(concierge_app_log_filename):
        f = open(concierge_app_log_filename, "r")

        concierge_log_lines = f.readlines()
        f.seek(0)
        num_lines = len(concierge_log_lines)

        # If number of lines exceeds 700, clear file and copy the last 700 lines
        if num_lines > concierge_app_log_line_limit:
            f.close()
            f2 = open(concierge_app_log_filename, "w")
            f2.writelines(concierge_log_lines[-concierge_app_log_line_limit:])
            f2.close()
            f = open(concierge_app_log_filename, "r")

        logs["concierge"] = f.read()
        f.close()

    return logs


@app.route("/infra")
def infra_status():
    return render_template("infra.html", projects=projects)


@app.route("/hook/<action>/<app_type>/<app_name>")
@app.route("/hook/<action>/<app_type>/<app_name>")
@app.route("/hook/<action>/<app_type>/<app_name>/")
@app.route("/hook/<action>/<app_type>/<app_name>/<branch_name>")
@app.route("/hook/<action>/<app_type>/<app_name>/<branch_name>/")
def hook(action: str, app_type: str, app_name: str, branch_name="main"):
    app_repo = None

    if app_type == "service" and app_name in projects["services"]:
        app_repo = projects["services"][app_name]
    elif app_type == "daemon" and app_name in projects["daemons"]:
        app_repo = projects["daemons"][app_name]

    if not app_repo:
        return f"App <code>{app_name}</code> does not exist in projects.json."

    if action == "update":
        log = open(f"logs/{app_name}.deploy.txt", "w")
        subprocess.Popen(
            ["bash", "scripts/update.sh", app_name, app_repo, branch_name],
            stdout=log,
            stderr=log,
        )
        return render_template("hook.html")
    elif action == "restart":
        log = open(f"logs/{app_name}.deploy.txt", "w")
        subprocess.Popen(
            ["bash", "scripts/restart.sh", app_name, "0"],
            stdout=log,
            stderr=log,
        )
        return "", 200
    elif action == "rebuild":
        log = open(f"logs/{app_name}.deploy.txt", "w")
        subprocess.Popen(
            ["bash", "scripts/restart.sh", app_name, "1"],
            stdout=log,
            stderr=log,
        )
        return "", 200
    elif action == "powerdown":
        log = open(f"logs/{app_name}.deploy.txt", "w")
        subprocess.Popen(
            ["bash", "scripts/restart.sh", app_name, "-1"],
            stdout=log,
            stderr=log,
        )
        return "", 200

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
