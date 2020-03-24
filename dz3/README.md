# OTUS: LINUX Security. Homework Objective
Упаковать приложение в docker провести харденинг собранного образа, чтобы на выходе образ проходил проверки - cis audit

## Подготовка
После клонирования репозитория необходимо инициализировать сабмодули:
```shell script
git submodule init
git submodule update
```

В файле bench.log содержится проверка на основе которого описаны следующие замечания.
## Некоторые замечания по проверке образов докера DOCKER-BENCH-SECURITY
В ходе выполнения проверки DOCKER-BENCH-SECURITY осмелюсь предположить что  некоторые тесты работают не совсем корректно.
#### [WARN] 1.1  - Ensure a separate partition for containers has been created
Если выполнить команду *df -h* будет видно что папка /var/lib/docker замонтирована отдельным разделом.
#### [WARN] 2.11  - Ensure that authorization for Docker client commands is enabled
По данному ворнингу толком не нашел нормальной инструкции по исправлению. Бенч ссылается на статью в докере.
#### [WARN] 4.5  - Ensure Content trust for Docker is Enabled
После включения DOCKER_CONTENT_TRUST=1 перестают пулиться образы с hub.docker.com
#### [WARN] 4.6  - Ensure HEALTHCHECK instructions have been added to the container image
В образах websocket-sample:1.0, python:3.8.2-alpine3.11 не предусмотрена инструкция HEALTHCHECK
