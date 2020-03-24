#DISK=/dev/sdb
#DIR=/var/lib/docker
#if [[ ! $(df | grep ${DISK}) ]]; then
#  parted -s $DISK mklabel msdos
#  parted -s -a opt $DISK mkpart primary ext4 0% 100%
#  mkfs.ext4 "${DISK}1" >$NULL
#  mkdir -p $DIR
#  mount "${DISK}1" $DIR
#fi


gen_pass() {
    echo $(cat /dev/urandom | tr -d -c 'a-zA-Z0-9' | fold -w 16 | head -1)
}
NULL=/dev/null
DISK=/dev/sdc
DIR=/var/lib/docker
if [[ ! $(df | grep ${DISK}) ]]; then
  parted -s $DISK mklabel msdos
  parted -s -a opt $DISK mkpart primary ext4 0% 100%
  mkfs.ext4 "${DISK}1" >$NULL
  mkdir -p $DIR
  mount "${DISK}1" $DIR
fi

echo "==> Update the apt package index:"
sudo apt-get update >$NULL
echo "==> Install packages to allow apt to use a repository over HTTPS"
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common >$NULL
echo "==> Add Docker’s official GPG key:"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
echo "==> Добавляем docker stable репозиторий."
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
echo "==> INSTALL DOCKER ENGINE - COMMUNITY"
echo "==> Update the apt package index"
sudo apt-get update >$NULL
echo "==> Install the latest version of Docker Engine - Community and containerd."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io >$NULL
echo "==> Запускаем rsyslog"
sudo systemctl start rsyslog
echo "==> Запускаем docker"
sudo systemctl start docker

echo "==> Устанавливаем auditd"
sudo apt-get install -y auditd audispd-plugins >$NULL
echo "==> Конфигурируем auditd"
RULESD_DIR=/etc/audit/rules.d
AUDIT_DIR=/etc/audit/
AUDIT_CURR=$AUDIT_DIR/audit.rules
AUDIT_RULES=$RULESD_DIR/audit.rules
AUDIT_BKP=$RULESD_DIR/audit.bkp
if [[ ! -e $AUDIT_BKP ]]; then
 echo "====> Создаем бэкап для audit.rules и добавляем правила для докера"
 cp $AUDIT_RULES $AUDIT_BKP
 cp $AUDIT_RULES $AUDIT_CURR
  {
	sudo echo "-w /usr/bin/docker -p wa"
	sudo echo "-w /var/lib/docker -p wa"
	sudo echo "-w /etc/docker -p wa"
	sudo echo "-w /lib/systemd/system/docker.service -p wa"
	sudo echo "-w /lib/systemd/system/docker.socket -p wa"
	sudo echo "-w /etc/default/docker -p wa"
	sudo echo "-w /etc/docker/daemon.json -p wa"
	sudo echo "-w /usr/bin/docker-containerd -p wa"
	sudo echo "-w /usr/bin/docker-runc -p wa"
  } >> $AUDIT_CURR
  sudo systemctl daemon-reload
  sudo systemctl restart auditd
  sudo auditctl -l
fi

if [[ ! -e /etc/docker/policies ]]; then
   echo "==> Создаем docker policies"
   sudo mkdir -p /etc/docker/policies
   {
     echo "package docker.authz"
     echo ""
     echo "allow = true"
   } > /etc/docker/policies/authz.rego 
   echo "==> Устанавливаем плагин opa-docker-authz"
	sudo docker plugin install --grant-all-permissions --alias opa-docker-authz openpolicyagent/opa-docker-authz-v2:0.5 opa-args="-policy-file /etc/docker/policies/authz.rego" >$NULL
	sudo docker plugin ls
fi
 
 echo "==> Конфигурируем docker"
if [[ ! -e /root/docker-ca ]]; then
  mkdir -p /root/docker-ca
  cd /root/docker-ca
  echo "==> Генерируем passphrase"
  PASS=$(gen_pass)
  CN=$IP
  echo "==> Генерируем ключ центра сертификации"
  openssl genrsa -aes256 -passout "pass:$PASS" -out "ca-key.pem" 4096 >$NULL
  echo "==> Генерируем сертификат центра сертификации"
  openssl req -new -x509 -days 365 -key "ca-key.pem" -sha256 -passin "pass:$PASS" -subj "/CN=$CN" -out "ca-cert.pem"

  if [[ ! -e /var/docker ]]; then
    mkdir -p /var/docker
  fi
  cd /var/docker
  echo "==> Генерируем серверный ключ"
  openssl genrsa -out "server-key.pem" 4096 >$NULL
  echo "==> Генерируем серверный сертификат"
  openssl req -new -sha256 -key "server-key.pem" -subj "/CN=$CN" -out server.csr
  echo "subjectAltName = IP:$IP,IP:127.0.0.1" > extfile.cnf
  echo "extendedKeyUsage = serverAuth" >> extfile.cnf
  echo "Генерируем подписанный сертификат" 
  openssl x509 -req -days 365 -sha256 -in server.csr -passin "pass:$PASS" -CA "/root/docker-ca/ca-cert.pem" -CAkey "/root/docker-ca/ca-key.pem" -CAcreateserial -out "server-cert.pem" -extfile extfile.cnf

  mkdir -p ~/.docker
  cd ~/.docker
  echo "==> Генерируем клиентский ключ"
  openssl genrsa -out "key.pem" 4096 >$NULL
  echo "==> Генерируем клиентский сертификат"
  openssl req -subj "/CN=$CN" -new -key "key.pem" -out client.csr
  echo "extendedKeyUsage = clientAuth" > extfile.cnf
  echo "Генерируем подписанный сертификат" 
  openssl x509 -req -days 365 -sha256 -in client.csr -passin "pass:$PASS" -CA "/root/docker-ca/ca-cert.pem" -CAkey "/root/docker-ca/ca-key.pem" -CAcreateserial -out "cert.pem" -extfile extfile.cnf
  chmod 0400 /var/docker/server-key.pem
  chmod 0400 /root/docker-ca/ca-key.pem
  chmod 0400 /root/.docker/key.pem

  chmod 0444 /root/docker-ca/ca-cert.pem
  chmod 0444 /var/docker/server-cert.pem
  chmod 0444 /root/.docker/cert.pem
fi

echo "==> Создаем subuid и subgid"
echo "vagrant:231072:65536" >/etc/subuid
echo "vagrant:231072:65536" >/etc/subgid
echo "==> Копируем daemon.json"
cp /vagrant/daemon.json /etc/docker
chmod 0644 /etc/docker/daemon.json
echo "==> Перезапускаем docker"
sudo systemctl restart docker

echo "==> Добавляем пользователя vagrant в группу docker"
sudo usermod -aG docker vagrant >$NULL

echo "==> Сборка образа"
IMAGE_NAME=websocket-sample:1.0
cd /vagrant
sudo docker build -t ${IMAGE_NAME} . >$NULL

echo "==> DOCKER-BENCH-SECURITY"
echo "==> DOCKER-BENCH-SECURITY: скачиваем образ docker/docker-bench-security"
sudo docker pull docker/docker-bench-security >$NULL
echo "==> DOCKER-BENCH-SECURITY: запускаем проверку"
sudo docker run --net host --pid host --userns host --cap-add audit_control \
   -e DOCKER_CONTENT_TRUST=0 \
   -v /etc:/etc:ro \
   -v /usr/bin/docker-containerd:/usr/bin/docker-containerd:ro \
   -v /usr/bin/docker-runc:/usr/bin/docker-runc:ro \
   -v /usr/lib/systemd:/usr/lib/systemd:ro \
   -v /var/lib:/var/lib:ro \
   -v /var/run/docker.sock:/var/run/docker.sock:ro \
   --label docker_bench_security \
   docker/docker-bench-security ./docker-bench-security.sh

