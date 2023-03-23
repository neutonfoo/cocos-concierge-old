from flask import Flask, make_response
import os
import json

app = Flask(__name__)

projects_file = open('../projects.json')
projects = json.load(projects_file)

@app.route("/update/<service_name>")
def update(service_name: str):
    os.system(f"bash update.sh {service_name}")

    response = make_response()
    response.status_code = 200
    return response


if __name__ == "__main__":
    app.run(debug=True, port=80)