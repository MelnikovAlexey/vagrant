# OTUS LUKS HW

###1. Сгенерировать ключ-файл с помощью команды dd

dd if=/dev/urandom of=/home/vagrant/my.key bs=1 count=1024  


###2. Создать на основе созданного ключа криптоконтейнер
sudo cryptsetup -v -s 512 luksFormat /dev/sdb1 /home/vagrant/my.key  


###3. Открыть контейнер с помощью ключа
sudo cryptsetup luksOpen -d /home/vagrant/my.key /dev/sdb1 secrets
sudo mkfs.xfs /dev/mapper/secrets
sudo mkdir /secrets
sudo mount /dev/mapper/secrets /secrets  



###4. Заполнить контейнер произвольными данными




###5. Закрыть контейнер
sudo umount /secrets
sudo cryptsetup luksClose secrets  


###6. Открыть контейнер (неожиданно :) )
sudo cryptsetup luksOpen -d /home/vagrant/my.key /dev/sdb1 secrets
sudo mount /dev/mapper/secrets /secrets 


###7. Проверить, что все на месте


###8. Создать дополнительный ключ (либо ключевой файл)
	#####8.1. для начала посмотрим занятость слотов 
	sudo cryptsetup luksDump /dev/sdb1 | grep Slot

	#####8.2. Создаем доп.ключ файл
	dd if=/dev/urandom of=/home/vagrant/x-files.key bs=1 count=1024

	#####8.3. добавляем доп.ключ убеждаемся что ключ добавился
	sudo cryptsetup luksAddKey /dev/sdb1 /home/vagrant/x-files.key --key-file=/home/vagrant/my.key
sudo cryptsetup luksDump /dev/sdb1 | grep Slot


з.ы. на скриншоте shell немного глюкнуло поэтому появился артефакт  t/x-files.key --key
 
###9. Удалить старый ключ
Здесь можно пойти 2мя способами
1 способ: просто удалить ключ из каталога командой rm my.key




И тогда нам придется выполнять пункт 10 поскольку если мы выполним команду 
sudo cryptsetup luksDump /dev/sdb1 | grep Slot
 
увидим что слот до сих пор занят.
2 способ в начале удаляем ключ из слота 
sudo cryptsetup luksRemoveKey -d /home/vagrant/my.key /dev/sdb1
а затем безопасно  удаляем сам ключ способом 1. 

###10. очистить слот от старого ключа
Но в пункте 9 мы пошли по первому сценарию и теперь при попытке очистить слот командой 
sudo cryptsetup luksRemoveKey -d /home/vagrant/my.key /dev/sdb1
мы получаем вот такую неприятную запись
 но мы не унываем и выполняем команду 
 sudo cryptsetup luksKillSlot /dev/sdb1 0 --key-file=/home/vagrant/x-files.key

###11. проделать пункты 6-7 с новым ключом
sudo cryptsetup luksOpen -d /home/vagrant/x-files.key /dev/sdb1 secrets 
sudo mount /dev/mapper/secrets /secrets
cat /secrets/xfiles.txt


###12. отмонтировать контейнер
sudo umount /secrets
sudo cryptsetup luksClose secrets  


