from flask import Flask, make_response
import subprocess
import json

app = Flask(__name__)

projects_file = open("../projects.json")
projects = json.load(projects_file)


@app.route("/")
def home():
    return "Welcome to the <code>updater</code> microservice."


@app.route("/update/<app_type>/<service_name>")
def update_service(app_type: str, service_name: str):
    response = make_response()

    if app_type not in ["service", "daemon"]:
        response.status_code = 500
    else:
        print(projects)

        if (app_type == "service" and service_name in projects["services"]) or (
            app_type == "daemon" and service_name in projects["daemon"]
        ):
            subprocess.run(
                [
                    "bash",
                    "update.sh",
                    app_type,
                    service_name,
                    projects["services"][service_name],
                ]
            )

    return response


if __name__ == "__main__":
    app.run(debug=True, port=1234, host="0.0.0.0")
