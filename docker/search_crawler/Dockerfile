FROM python:alpine3.6
RUN mkdir -p /run/crawlerapp
COPY crawlerapp /run/crawlerapp
RUN pip install --no-cache-dir -r /run/crawlerapp/requirements.txt
WORKDIR /run/crawlerapp
ENV CRAWLERAPP=crawler.py
ENV MONGO mongo
ENV MONGO_PORT 27017
ENV RMQ_HOST rabbit
ENV RMQ_QUEUE urls
ENV RMQ_USERNAME rabbitmq
ENV RMQ_PASSWORD rabbitmq
ENV EXCLUDE_URLS '.*github.com'

#Это добавлено с просторов энторнетов чтобы приложение ожидало RabbitMQ и не падало сразу при старте
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.9.0/wait /wait
RUN chmod +x /wait

## Тут мы ожидаем (чего ожидаем указано в докеркомпоузе) и потом стартует приложение
CMD /wait && python -u crawler.py "https://vitkhab.github.io/search_engine_test_site/"



