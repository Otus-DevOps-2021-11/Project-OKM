# Project-OKMA
## У нас есть план и мы будем его придерживаться:

1. Создать развертывание кубер-кластера на 2 ноды 4/8/64 в terraform
2. Написать Докер-файлы для разворачивание приложения в докере
3. Залить докер-образы в докер-хаб
4. Написать деплойменты приложения в кубер-кластер
5. Установить nginx ingress-controller в кластер:

`kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/cloud/deploy.yaml`

6. Написать правило ingress для приложения
7. Деплоим приложение и ingress
8. Если приложение заработало (о чудо!!!) - описать его деплой ансиблом
9. Запилить логгирование
10. Запилить мониторинг и алерты
11. Смешная 11 опция...

### Приложения:
[CRAWLER](https://github.com/express42/search_engine_crawler)

[UI](https://github.com/express42/search_engine_ui)

### Разворот managed k8s кластера

Приложение развёрнуто в kubernetes кластере. Кластер состоит из двух нод, кластер создаётся через Terraform. Для
создания kubernetes-кластера нужно:

1. Перейти в каталог `terraform`
2. В файлах `variables.tf` и `terraform.tfvars` заменить значения всех переменных (кроме переменной `instance count`).
3. Выполнить команду `terraform init`
4. Выполнить команду `terraform apply`
5. После создания кластера чтобы к нему подключиться в консоли Host'a выполнить команду 
   `yc managed-kubernetes cluster get-credentials okmacluster --external --force`
6. Для создания неймспейса перейти в каталог `kubernetes/app` и выполнить команду `kubectl apply -f namespace.yml`

### Docker образы

Для работы приложения в dockerfil'ах изменили версию python на 3.9, также изменили зависимости приложения (файлы
requirements.txt): обновили используемую версию flask до 2.0.3

Запилил 2 образа crawler и crawler_ui соотвественно

Запушил их в свою репу opopovich85/crawler и opopovich85/сrawler_ui

crawler_ui не хватило requirements.txt добавил туда markupsafe

Хотел запустить на более-менее свежем python-3.8-alpine,словил exception,откатился на версию 3.6

На данный момент оба приложения хотят видеть монгу и кролика

Починили crawler у которого была ошибка с множественными очередями

Сейчас приложение полностью работает, можно начать развлекаться дальше

Добавил fluentd,собрал образ opopovich85/fluentd:latest.Сделал зачатки compose для логирования.

Допилил compose для логирования до конца. Решены проблемы с совместимостью плагина для fluentd и версии elasticsearch.

Решил проблему с падением elasticsearch из-за нехватки памяти.

## Kubernetes

### Установка nginx ingress-controller

1. Добавьте в Helm репозиторий для NGINX:

    `helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx`

2. Обновите набор данных для создания экземпляра приложения в кластере Kubernetes:

    `helm repo update`

3. Установите контроллер в стандартной конфигурации:

    `helm install ingress-nginx ingress-nginx/ingress-nginx`

### Deploy Rabbitmq

**Важно!** В случае, если в файле `docker/search_crawler/Dockerfile` в качестве значения переменных `ENV RMQ_USERNAME`,
`ENV RMQ_PASSWORD` не используется`rabbitmq`, то в файле `kubernetes/rmq/rabbitmq_statefulset.yaml` в разделе `env`
(ориентировочно строки 83 - 86) нужно заменить значения переменных `RABBITMQ_DEFAULT_USER` и `RABBITMQ_DEFAULT_PASS` на
значения этих переменных из файла `docker/search_crawler/Dockerfile`.

1. Перейдите в каталог `kubernetes`

2. Выполните команду `kubectl apply -f namespace.yml`

3. Перейдите в каталог `kubernetes\rmq`

4. Последовательно выполните команды

  * `kubectl apply -f namespace.yml`
  * `kubectl apply -f rabbitmq_rbac.yaml -n dev`
  * `kubectl apply -f rabbitmq_pv.yaml -n dev`
  * `kubectl apply -f rabbitmq_pvc.yaml -n dev`
  * `kubectl apply -f rabbitmq_service.yaml -n dev`
  * `kubectl apply -f rabbitmq_service_ext.yaml -n dev`
  * `kubectl apply -f rabbitmq_configmap.yaml -n dev`
  * `kubectl apply -f rabbitmq_statefulset.yaml -n dev`

## Мониторинг

Добавлен стек мониторинга - Prometheus+Alertmanager+Graphana

Запилил compose docker-monitoring.yml

Порешал проблему с сетями докера т.к докер создает сеть согласно папке+название сети. Покурил мануал, принудил docker к сотрудничеству.

Сделал правило отправки alert при падении сервиса ( если up одного из endpoint == 0)

Запилил канал в Slack ( monitoring-okma) и пригласил всех участников.

Проверил что алерт при падении сервиса приходит.

Todo - Возможно нам нужно оповещение еще и по почте.
