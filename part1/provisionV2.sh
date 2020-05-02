set -euo pipefail

echo "==> Обновляем пакеты"
yum update -y >/dev/null

echo "==> Подключаем yum репозиторий nginx"
cp /vagrant/nginx.repo /etc/yum.repos.d/nginx.repo
yum-config-manager --enable nginx-mainline >/dev/null

echo "==> Устанавливаем setools policycoreutils policycoreutils-python setroubleshoot nginx"
yum install -y nano setools policycoreutils policycoreutils-python setroubleshoot nginx >/dev/null

echo "==> Перезапускаем auditd"
service auditd restart >/dev/null

echo "==> Смотрим статус SELinux"
sestatus | grep "SELinux status"

NGINX_CONF=/etc/nginx/conf.d/default.conf
PORT=8088
echo "==> Меняем порт nginx на ${PORT}"
sed -i -e"s/listen       80;/listen       ${PORT};/" ${NGINX_CONF}

echo "==> Добавление нестандартного порта в имеющийся тип"
semanage port --add --type http_port_t --proto tcp ${PORT}
echo "==> Перезапускаем NGINX"
systemctl restart nginx >/dev/null