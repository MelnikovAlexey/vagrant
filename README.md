# OTUS Wazuh

### Отчет по работе с Wazuh

[Подробный отчет](https://github.com/MelnikovAlexey/vagrant/blob/hw-8/WAZUH_Report.pdf) 

[Конфигурационный файл wazuh-manager](https://github.com/MelnikovAlexey/vagrant/blob/hw-8/ossec.conf)

### Настройка active response на брутфорс ssh в wazuh

В wazuh уже имеются готовые скрипты для active response, находятся в каталоге /var/ossec/active-response/bin/. Для автоматической блокировки атакующего ip в файл /var/ossec/etc/ossec.conf необходимо добавить правило:
```shell
<active-response>
    <command>firewall-drop</command>
    <location>local</location>
    <rules_id>5712|5720</rules_id>
    <timeout>1800</timeout>
</active-response>
```
firewall-drop - название скрипта, rules id - идентификатор события безопасности "sshd: brute force trying to get access to the system.|sshd: Multiple authentication failures.". Первое правило срабатывает если злоумышленник не знает логин для ssh.  Второе правило затруднит возможность подобрать пароль если по какой то причине злоумышленник смог узнать имя пользователя для ssh. При данной настройке блокировка будет производиться только на хосте, который подвержен атаке.

