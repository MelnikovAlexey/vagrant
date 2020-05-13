# OTUS LUKS HW

### 1. Сгенерировать ключ-файл с помощью команды dd
```bash
dd if=/dev/urandom of=/home/vagrant/my.key bs=1 count=1024  
```
![screen1](https://github.com/MelnikovAlexey/vagrant/blob/hw-10/screen/screen1.png)
### 2. Создать на основе созданного ключа криптоконтейнер
```bash
sudo cryptsetup -v -s 512 luksFormat /dev/sdb1 /home/vagrant/my.key  
```

### 3. Открыть контейнер с помощью ключа
```bash
sudo cryptsetup luksOpen -d /home/vagrant/my.key /dev/sdb1 secrets
sudo mkfs.xfs /dev/mapper/secrets
sudo mkdir /secrets
sudo mount /dev/mapper/secrets /secrets  
```


### 4. Заполнить контейнер произвольными данными




### 5. Закрыть контейнер
```bash
sudo umount /secrets
sudo cryptsetup luksClose secrets  
```

### 6. Открыть контейнер (неожиданно :) )
```bash
sudo cryptsetup luksOpen -d /home/vagrant/my.key /dev/sdb1 secrets
sudo mount /dev/mapper/secrets /secrets 
```

### 7. Проверить, что все на месте


### 8. Создать дополнительный ключ (либо ключевой файл)
##### 8.1. для начала посмотрим занятость слотов 
```bash
	sudo cryptsetup luksDump /dev/sdb1 | grep Slot
```
##### 8.2. Создаем доп.ключ файл
```bash
	dd if=/dev/urandom of=/home/vagrant/x-files.key bs=1 count=1024
```
#####8.3. добавляем доп.ключ убеждаемся что ключ добавился
```bash
sudo cryptsetup luksAddKey /dev/sdb1 /home/vagrant/x-files.key --key-file=/home/vagrant/my.key
sudo cryptsetup luksDump /dev/sdb1 | grep Slot
```

з.ы. на скриншоте shell немного глюкнуло поэтому появился артефакт  t/x-files.key --key
 
### 9. Удалить старый ключ
Здесь можно пойти 2мя способами
1 способ: просто удалить ключ из каталога командой 
```bash
rm my.key
```



И тогда нам придется выполнять пункт 10 поскольку если мы выполним команду 
```bash
sudo cryptsetup luksDump /dev/sdb1 | grep Slot
``` 
увидим что слот до сих пор занят.
2 способ в начале удаляем ключ из слота 
```bash
sudo cryptsetup luksRemoveKey -d /home/vagrant/my.key /dev/sdb1
```
а затем безопасно  удаляем сам ключ способом 1. 

### 10. очистить слот от старого ключа
Но в пункте 9 мы пошли по первому сценарию и теперь при попытке очистить слот командой 
```bash
sudo cryptsetup luksRemoveKey -d /home/vagrant/my.key /dev/sdb1
```
мы получаем вот такую неприятную запись
 но мы не унываем и выполняем команду 
 ```bash
 sudo cryptsetup luksKillSlot /dev/sdb1 0 --key-file=/home/vagrant/x-files.key
```
### 11. проделать пункты 6-7 с новым ключом
```bash
sudo cryptsetup luksOpen -d /home/vagrant/x-files.key /dev/sdb1 secrets 
sudo mount /dev/mapper/secrets /secrets
cat /secrets/xfiles.txt
```

### 12. отмонтировать контейнер
```bash
sudo umount /secrets
sudo cryptsetup luksClose secrets  
```

