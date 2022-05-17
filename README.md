# Project-OKMA
## У нас есть план и мы будем его придерживаться (этот пункт существует на время написания курсовой):

1. Создать развертывание кубер-кластера на 2 ноды 4/8/64 в `terraform`
2. Написать Докер-файлы для разворачивание приложения в докере
3. Залить докер-образы в докер-хаб
4. Написать деплойменты приложения в кубер-кластер
5. Установить nginx ingress-controller в кластер:

`kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/cloud/deploy.yaml`

6. Написать правило `ingress` для приложения
7. Деплоим приложение и `ingress`
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

* Для работы приложения в `dockerfil'ах` изменили версию python на 3.9
* изменили зависимости приложения (файлы`requirements.txt`): обновили используемую версию `flask` до 2.0.3
* для микросервисов `crawler` и `crawler_ui` были собраны Docker-образы, образы находятся в каталогах `search_crawler`  и `search_crawler_ui` для    `crawler` и `crawler_ui` соответственно.
* Образы добавили в репозиторий Docker-hub. Для работы `crawler_ui` в `requirements.txt` добавили также библиотеку `markupsafe`.

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

  * `kubectl apply -f rabbitmq_rbac.yaml -n dev`
  * `kubectl apply -f rabbitmq_pv.yaml -n dev`
  * `kubectl apply -f rabbitmq_pvc.yaml -n dev`
  * `kubectl apply -f rabbitmq_service.yaml -n dev`
  * `kubectl apply -f rabbitmq_service_ext.yaml -n dev`
  * `kubectl apply -f rabbitmq_configmap.yaml -n dev`
  * `kubectl apply -f rabbitmq_statefulset.yaml -n dev`

### Деплой приложения в kubernetes-кластер

**Пока работает не до конца!**

1. Создайте диск для хранения БД, для этого выполните команду

  `yc compute disk create k8s --size 4 --description "disk for okmadb"`,

2. Командой `yc compute disk list` получаем ID созданного диска

3. Полученный ID нужно указать в разделе `volumeHandle` файле `kubernetes/app/mongo-volume.yml`

4. В терминале перейдите в каталог `kubernetes/app`

5. Последовательно выполните следующие команды:

  `kubectl apply -f mongo-volume.yml -n dev`

  `kubectl apply -f mongo-claim.yml -n dev`

  `kubectl apply -f mongo-deployment.yml -n dev`

  `kubectl apply -f mongodb-service.yml -n dev`

  `kubectl apply -f crawler-ui-deployment.yml -n dev`

  `kubectl apply -f crawler-ui-service.yml -n dev`

  `kubectl apply -f crawler-ui-mongodb-service.yml -n dev`

  `kubectl apply -f crawler1-deployment.yml -n dev`

  `kubectl apply -f crawler1-mongodb-service.yml -n dev`

  `kubectl apply -f crawler1-rabbitmq-service.yml -n dev`


## Мониторинг
#### Используемый стек:

**Prometheus+Alertmanager+Graphana**

#### Docker images
 * Решены проблемы с совместимостью плагина для `fluentd` и версии `elasticsearch`
 * решили проблему с падением `elasticsearch` из-за нехватки памяти
 * для запуска мониторинга собран `docker-compose` в файле `docker-monitoring.yml`
 * Добавлен файл kube-prometheus-stack.yml с настройками для разворота через helm
 * Чтобы развернуть kube-prometheus-stack выполняем:
 `helm repo add prometheus-community https://prometheus-community.github.io/helm-charts`
 
 `helm repo update`
 
`helm install --set name=dev monitoring prometheus-community/kube-prometheus-stack -f monitoring/kube-prometheus-stack.yml`
 
 * На данный момент в файле kube-prometheus-stack.yml настройки ingress для alertmanager и prometheus закомментированы
<!-- Деплоймент для кубер кластера пока не готов -->

#### Alerting

  * Создано правило отправки `alert'ов` при падении сервиса (если `up` одного из `endpoint == 0`)
  * для получения алертов создан канал `monitoring-okma` в Slack. В канал добавлены все участники проекта
  * Оповещение при падении сервиса приходит.


#### Gitlab-CI
Непрерывное развертывание контейнеризованных приложений с помощью GitLab в Яндексе:
https://cloud.yandex.ru/docs/tutorials/infrastructure-management/gitlab-containers

`helm repo add gitlab-ci https://charts.gitlab.io`
Установить раннер в кубер:
`helm install --namespace default gitlab-runner -f gitlab-values.yaml gitlab/gitlab-runner`
Убедитесь, что под GitLab Runner перешел в состояние Running:

    kubectl get pods -n default | grep gitlab-runner
    gitlab-runner-gitlab-runner-6d5f667499-l4jtg   1/1     Running   0          64s


#### Подключаемся к яндексу OKMA
yc config profile create okma
yc init

kubectl -n kube-system get secrets -o json | \
jq -r '.items[] | select(.metadata.name | startswith("gitlab-admin")) | .data.token' | \
base64 --decode

eyJhbGciOiJSUzI1NiIsImtpZCI6IjZ1X3FjNUZ0a0lsc3c0UW44NFV2QjNZRjcxTzZmYk1hVEhxM2JMUl81QzAifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJnaXRsYWItYWRtaW4tdG9rZW4tazk0ODciLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZ2l0bGFiLWFkbWluIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiOTYwNzE0ZjYtNjMxOC00YjYxLWIyYjktMTI4Nzg0MmMzMDFjIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOmdpdGxhYi1hZG1pbiJ9.nNoEmMJPKn5-mTMs3xw1MFM9aq0DnjIMNMuRZrxVLcI8MzbmtDWbqN7Q_AG12Rtuc4g3mXzxYR8SmWiud9I-521pHWKjHnhcJ2Y1_zuI3oMlvh1DGWI4q0uCBCkwxitnMlxb4xU2-BnA6De64QNXLJQCsZjUjQ3dA91lAg9Y3yWOxgu3_7fectQkXJlmFwerwJhReyJPS7oJYktsUzx20PnTb0PEXgIjgQESlfLMmmtXzdT2fR5qC56xKfVfwZT_q3tblcDo4EFWLXoeEjUHZg24goWPq-H0TDZBUuVvbGyl1UBpx-PKaNsoh_iZHPzdJ4fVzpFC-EvUf4n3YuoKpQ

yc managed-kubernetes cluster get kubernetes --format=json \
| jq -r .master.endpoints.external_v4_endpoint

https://51.250.80.81

yc managed-kubernetes cluster get kubernetes --format=json \
| jq -r .master.master_auth.cluster_ca_certificate

-----BEGIN CERTIFICATE-----
MIIC5zCCAc+gAwIBAgIBADANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwprdWJl
cm5ldGVzMB4XDTIyMDUxNDEwNTEyM1oXDTMyMDUxMTEwNTEyM1owFTETMBEGA1UE
AxMKa3ViZXJuZXRlczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMfc
K8LJyIXGWsweBgvFC6cAT40hBCRZlxH1j3Hb2W+LzGhPv2m4/tsqLLAir7E/y5oT
mdgR+OuYDty6eltsXnGvSgQ8LEybfy22idXVdm1BUoxbh8yFkynBFOBZFw19KrUJ
rNn1/A9MMKI68ORHSmXVvekS1igF0pPuAHnptCYLWQEiocyN/LMKiF+Wex+d4bc/
M9hEk1AIcZFbrfiRmOhDL5Zn43gpEiX7cVWEhso8dMsHp4oz1ExiaYkqmi2yYUY3
dZMDW1KHr5gNbr5gMYWi2P5Ti2w5RI+faOboxHvAl7I0eTa2quOIfLiCnW76FFBX
KCSM634znIvuZ0O65TsCAwEAAaNCMEAwDgYDVR0PAQH/BAQDAgKkMA8GA1UdEwEB
/wQFMAMBAf8wHQYDVR0OBBYEFGni2i7HukW6IJsnaEG714iWU0yzMA0GCSqGSIb3
DQEBCwUAA4IBAQAhilCOa59ZVVbfzg5uuOEOCEZ+cImQfZUlIb4g7X/gBErxQv36
r4SAvRCHF/XM9eOgapK7vk2psmiu4PTawoDiuokAFeatI1ZrtcYpuDksVWqLz7hG
D3vCKyKWsJiQPfahECoGbGjclje4ZQo2bEObsNkCxu5xTjOXVcZm76UToJocMFyO
2hhob3AEirsbwO3ZVdm6jARocTXlvbUvjpWZ3lu4kbZ94RUS93RI4SfOzBPtpVU6
UnHeM9hnf1qQtHklB8yx4GZYexY+RG/w1f3fWPuBydvNyr+is6xmqA5PMEODgQkd
KHi6zSOJyiwrD3k5TrfYAptQy8laYeIk0qeS
-----END CERTIFICATE-----


#### Ingress
У нас теперь всё что надо доступно по доменным именам:
1. http://crawler.maxx.su
2. http://rabbit.maxx.su
3. http://alertmanager.maxx.su
4. http://prometheus.maxx.su
5. http://elastic.maxx.su - в процессе


