FROM python:3.9-alpine
RUN mkdir -p /run/crawlerapp
COPY crawlerapp /run/crawlerapp
RUN pip install --no-cache-dir -r /run/crawlerapp/requirements.txt
WORKDIR /run/crawlerapp
ENV CRAWLERAPP=crawler.py
ENV MONGO mongo
ENV MONGO_PORT 27017
ENV RMQ_HOST rabbit
CMD  ["python", "-u", "crawler.py","https://vitkhab.github.io/search_engine_test_site/"]
