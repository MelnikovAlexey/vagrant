## Запустить nginx на нестандартном порту 3-мя разными способами
### Логические параметры SELinux
```bash
setsebool -P nis_enabled on
```
автоматически поднимается ваграндом.
для проверки достаточно ввести в браузере : 
```
127.0.0.1:8081
```
[Скриншот](https://github.com/MelnikovAlexey/vagrant/blob/hw-3/part1/nginxV1.png)
### Добавление нестандартного порта в имеющийся тип
```bash
semanage port --add --type http_port_t --proto tcp 8088
```
автоматически поднимается ваграндом.
для проверки достаточно ввести в браузере : 
```
127.0.0.1:8082
```
[Скриншот](https://github.com/MelnikovAlexey/vagrant/blob/hw-3/part1/nginxV2.png)
### Формирование и установка модуля SELinux
```bash
ausearch -c 'nginx' --raw | audit2allow -M nginx-custom-port
semodule -i nginx-custom-port.pp
```
В данном случае придется зайти на виртуальную машину и выполнить данные строчки вручную. Предварительно попытавшись запустить nginx.

Автоматизировать не получилось поскольку на моменте попытки запуска nginx на нестандартном порту из shell файла в vagrant завершал работу провижина.
[Vagrant](https://github.com/MelnikovAlexey/vagrant/blob/hw-3/part1/nginxV3_autocrash.png)
После того как vagrant развернет все три виртуалки заходим на третью виртуалку 
```
vagrant ssh centos3
``` 
Далее из под рута выполняем следующие команды
```bash 
systemctl start nginx
ausearch -c 'nginx' --raw | audit2allow -M nginx-custom-port
semodule -i nginx-custom-port.pp
```
[Результат](https://github.com/MelnikovAlexey/vagrant/blob/hw-3/part1/nginxV3_result.png)

Проверяем работоспособность nginx

[Скриншот](https://github.com/MelnikovAlexey/vagrant/blob/hw-3/part1/nginxV3.png)

