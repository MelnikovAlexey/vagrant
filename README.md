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
[Скриншот]()
### Добавление нестандартного порта в имеющийся тип
```bash
semanage port --add --type http_port_t --proto tcp 8088
```
автоматически поднимается ваграндом.
для проверки достаточно ввести в браузере : 
```
127.0.0.1:8082
```
[Скриншот]()
### Формирование и установка модуля SELinux
```bash
ausearch -c 'nginx' --raw | audit2allow -M nginx-custom-port
semodule -i nginx-custom-port.pp
```
в данном случае придется зайти на виртуальную машину и выполнить данные строчки вручную. Предварительно попытавшись запустить nginx
автоматизировать не получилось поскольку на моменте попытки запуска nginx на нестандартном порту vagrant завершал работу провижина.
```bash
systemctl start nginx
ausearch -c 'nginx' --raw | audit2allow -M nginx-custom-port
semodule -i nginx-custom-port.pp
```
[Скриншот]()

