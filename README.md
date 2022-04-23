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
8. Если приложение заработало (о чудо!!!) описать его деплой ансиблом
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
