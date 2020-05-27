# OTUS Volatility

### 1. Task 1

подробности работы с дампом памяти отражено в [отчете task_1_report.pdf](https://github.com/MelnikovAlexey/vagrant/blob/hw-7/Task_1_report.pdf)

### 2. Task 2

подробности работы с дампом памяти отражено в [отчете task_2_report.pdf ](https://github.com/MelnikovAlexey/vagrant/blob/hw-7/Task_2_report.pdf) 


### Общие команды

### task1

```shell
cp /vagrant/task1/Ubuntu_4.15.0-72-generic_profile.zip /usr/lib/python2.7/dist-packages/volatility/plugins/overlays/linux
wget https://raw.githubusercontent.com/cuckoosandbox/community/master/data/yara/shellcode/metasploit.yar
volatility --profile=LinuxUbuntu_4_15_0-72-generic_profilex64 --filename=/vagrant/task1/memory.vmem <command>
```

### task2
```shell
sudo cp /vagrant/Ubuntu16.04_4.4.0_116_generic-39158-dea5d1.zip /usr/lib/python2.7/dist-packages/volatility/plugins/overlays/linux
volatility --profile=LinuxUbuntu16_04_4_4_0_116_generic-39158-dea5d1x64 --filename=/vagrant/task2/image <command>
```
