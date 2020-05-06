#### SELinux: проблема с удаленным обновлением зоны DNS

Инженер настроил следующую схему:

- ns01 - основной DNS-сервер (192.168.50.10);
- ns02 - вторичный DNS-сервер (192.168.50.11);
- client - клиентская рабочая станция.

При попытке удаленно (с рабочей станции) внести изменения в зону ddns.lab происходит следующее:
```bash
cat /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1586064270.161:1993): avc:  denied  { search } for  pid=7418 comm="isc-worker0000" name="net" dev="proc" ino=33739 scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:sysctl_net_t:s0 tclass=dir permissive=0

        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.

type=AVC msg=audit(1586064270.161:1994): avc:  denied  { search } for  pid=7418 comm="isc-worker0000" name="net" dev="proc" ino=33739 scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:sysctl_net_t:s0 tclass=dir permissive=0

        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.

type=AVC msg=audit(1586064855.444:2044): avc:  denied  { create } for  pid=7418 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.

[root@ns01 vagrant]# cat /var/log/audit/audit.log | audit2allow 

>
```
SElinux блокирует работу сервиса named

Для исправление ошибки можно воспользоваться рекомендацией использовать audit2allo для создания разрешающих правил (необходимо повторить несколько раз).
```bash
cat /var/log/audit/audit.log | audit2allow
audit2allow -a -M named
semodule -i named.pp
```
Итоговые правила:
```bash
module named 1.0;

require {
        type etc_t;
        type sysctl_net_t;
        type named_t;
        class dir search;
        class file { create getattr open read write };
}

#============= named_t ==============

#!!!! This avc is allowed in the current policy
allow named_t etc_t:file { create write };

#!!!! This avc is allowed in the current policy
allow named_t sysctl_net_t:dir search;

#!!!! This avc is allowed in the current policy
allow named_t sysctl_net_t:file { getattr open read };
```

Но в этом случае, если злоумышленник поломает named (а ведь этого исключать нельзя, т.к. named видет снаружи), то он сможет писать в /etc и стало быть сможет получить контроль над хостом ns01. Такого ответственный инженер допустить не позволит, поэтому необходим другой вариант решения проблемы.

Почитав документацию по Bind инженер нигде не находит упоминания о named в /etc. Немного подумав инженер решает проанализировать файловые контексты named на ns01:

```bash
[vagrant@ns01 etc]$ sudo semanage fcontext -l | grep named
/etc/rndc.*                                        regular file       system_u:object_r:named_conf_t:s0 
/etc/unbound(/.*)?                                 all files          system_u:object_r:named_conf_t:s0 
/var/named/chroot(/.*)?                            all files          system_u:object_r:named_conf_t:s0 
/etc/named\.rfc1912.zones                          regular file       system_u:object_r:named_conf_t:s0 
/var/named/chroot/etc/named\.rfc1912.zones         regular file       system_u:object_r:named_conf_t:s0 
/etc/named\.conf                                   regular file       system_u:object_r:named_conf_t:s0 
/var/named/named\.ca                               regular file       system_u:object_r:named_conf_t:s0 
/etc/named\.root\.hints                            regular file       system_u:object_r:named_conf_t:s0 
/var/named/chroot/etc/named\.conf                  regular file       system_u:object_r:named_conf_t:s0 
/etc/named\.caching-nameserver\.conf               regular file       system_u:object_r:named_conf_t:s0 
/var/named/chroot/var/named/named\.ca              regular file       system_u:object_r:named_conf_t:s0 
/var/named/chroot/etc/named\.root\.hints           regular file       system_u:object_r:named_conf_t:s0 
/var/named/chroot/etc/named\.caching-nameserver\.conf regular file       system_u:object_r:named_conf_t:s0 
/var/named(/.*)?                                   all files          system_u:object_r:named_zone_t:s0 
/var/named/chroot/var/named(/.*)?                  all files          system_u:object_r:named_zone_t:s0 
```

и инженеру приходит светлая мысль, может конфигурация named для ddns содержит опечатку, и достаточно просто ее исправить: в named.conf в разделах для ddns поменять директорию, где размещается файл зоны с /etc/named/dynamic на /var/named/dynamic

далее достаточно только пересобрать образ.


#### Стенд

В provision внесены изменения, устраняющие проблему.

