FROM python:3.6.0-alpine 
RUN mkdir -p /run/app
COPY crawleruiapp /run/crawleruiapp
COPY gunicornconf.py /run/gunicornconf.py
RUN pip install --no-cache-dir -r /run/crawleruiapp/requirements.txt  

WORKDIR /run/crawleruiapp
ENV FLASKAPP=ui.py
ENV MONGO mongo
ENV MONGO_PORT 27017
EXPOSE 8000
CMD ["gunicorn", "--config", "/run/gunicornconf.py", "ui:app"]


