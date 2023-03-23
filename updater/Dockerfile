FROM python:slim

WORKDIR /app

COPY updater/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY projects.json /projects.json

COPY updater/. .

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=80"]