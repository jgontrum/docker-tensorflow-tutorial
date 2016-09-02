FROM tensorflow/tensorflow

RUN mkdir -p /usr/shared/

ENTRYPOINT cd /usr/shared && pip install -r requirements.txt && python run.py
