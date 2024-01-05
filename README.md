## MOTD
Customized dynamic message of the day (motd) for Raspberry Pi
<div align="center">

![motd](https://img.shields.io/badge/-motd-D8BFD8?logo=themodelsresource&logoColor=3a3a3d)
&nbsp;&nbsp;[![release](https://img.shields.io/github/v/release/ar51an/raspberrypi-motd?display_name=release&logo=rstudio&color=90EE90&logoColor=8FBC8F)](https://github.com/ar51an/raspberrypi-motd/releases/latest/)
&nbsp;&nbsp;![downloads](https://img.shields.io/github/downloads/ar51an/raspberrypi-motd/total?color=orange&label=downloads&logo=github)
&nbsp;&nbsp;![visitors](https://img.shields.io/endpoint?color=4883c2&label=visitors&logo=github&url=https%3A%2F%2Fhits.dwyl.com%2Far51an%2Fraspberrypi-motd.json)
&nbsp;&nbsp;![lang](https://img.shields.io/badge/lang-Bash-5F9EA0?logo=gnubash&logoColor=4EAA25)
&nbsp;&nbsp;![license](https://img.shields.io/badge/license-MIT-CED8E1)
</div>

### Preview
<div align="center">

![WithCount](https://github.com/ar51an/raspberrypi-motd/assets/11185794/fbf346a2-6978-427b-b042-8fd5a5af3e8e)

![WithoutCount](https://github.com/ar51an/raspberrypi-motd/assets/11185794/f5f6c3ca-915e-439e-9dbb-8c376c156633)
</div>

---
<div align="justify">

### Intro
Many folks use Raspberry Pi as headless. If you use SSH more often to connect Raspberry Pi and interested in changing the MOTD (message of the day), keep on reading. **The goal is to create simple, swift and useful motd**.
<br/>

Lack of available update count in RaspiOS motd is the triggering point to develop this motd. Traditionally `apt-check` utility in `update-notifier-common` package was used to fetch the available update count. This package is no longer available from `buster` onwards, its functionality is merged into `unattended-upgrades` add-on package. I used `apt-get` to parse the required information.
<br/>

The process used for the motd is the same as RaspiOS or Ubuntu uses to show the motd dynamically. There is no additional package or third party tool used. It is written in bash and executes using the same mechanism as the default motd. There are multiple commands for retrieving the same information. I tested various commands for each info and used that took the least amount of time. This dynamic motd takes approximately 1 sec after authentication. This is the fastest you can get with all the information it is displaying.
<br/>

#### Specs:
> |HW                      |OS                           |
> |:-----------------------|:----------------------------|
> |`Raspberry Pi 4 Model B`|`raspios-bookworm-arm64-lite`|
#
### Steps
#### ❯ Remove Default MOTD

* Delete `/etc/motd`. This file contains the static text about Debian GNU/Linux liability. Alternatively you can keep a backup of this file at some place.
  > `sudo rm /etc/motd`  

* Delete `/etc/update-motd.d/10-uname`. This file prints the OS version dynamically to the default message. New motd will print a trimmed down version of OS.  
  > `sudo rm /etc/update-motd.d/10-uname`  

* Modify `/etc/ssh/sshd_config`. This file prints last login timestamp and location. New motd will print last login timestamp and location.  
  > `sudo nano /etc/ssh/sshd_config`  
  > Add: `PrintLastLog no`  
  > Save & Exit  
  > Restart sshd: `sudo systemctl restart sshd`  

#
> **_NOTE:_**  
> Default motd is completely removed. Reconnect ssh session and if you followed the steps correctly you will not see any motd.  
#

#### ❯ Implement New MOTD
* Copy `10-welcome`, `15-system` and `20-update` scripts from the latest release under `update-motd.d` dir to `/etc/update-motd.d` dir. 
Make sure scripts are under the ownership of root and are executable.
  > **Change ownership [If needed]:**  
  > `sudo chown root:root /etc/update-motd.d/<script-name>`  

  > **Make scripts executable [If needed]:**  
  > `sudo chmod +x /etc/update-motd.d/<script-name>`  

  > ![update-motd_files](https://user-images.githubusercontent.com/11185794/202982786-76711b90-6cc9-4680-afb5-de07fa1da446.png)

#
> **_NOTE:_**  
> If you noticed all the scripts have names starting with a number. Dynamic contents of the motd are created by PAM (Pluggable Authentication Module) running bash scripts from /etc/update-motd.d dir. Scripts are read in numeric order and do not need a file extension. In the default motd it was executing 10-uname script to show the OS version which we deleted earlier.
#

* Create static contents of new motd. This is not entirely static, PAM will execute static script. Static script is created from dynamic script once a day with systemd timer. It minimizes startup delay. Keeping it completely dynamic increases startup delay to 3-4 seconds after authentication.
  * Create dir /etc/update-motd-static.d  
    > `sudo mkdir /etc/update-motd-static.d/`  

  * Copy `20-update` script from the latest release under `update-motd-static.d` dir to this newly created dir `/etc/update-motd-static.d`. Make sure script is under the ownership of root and it is executable.
    > **Change ownership [If needed]:**  
    > `sudo chown root:root /etc/update-motd-static.d/20-update`  

    > **Make script executable [If needed]:**  
    > `sudo chmod +x /etc/update-motd-static.d/20-update`  

    > ![update-motd-static_files](https://user-images.githubusercontent.com/11185794/202983089-6b303358-9b27-4005-bf27-170c16141cc8.png)

  * Run dynamic script to update the static script `/etc/update-motd.d/20-update` with pending update count (if any). We will automate this process through systemd timer.
    > **Run script:**  
    > `sudo run-parts /etc/update-motd-static.d`  

#
> **_NOTE:_**  
> New motd is implemented, pending few automations. Let's test new motd to verify that everything is working properly. **Either** reconnect ssh session **or** run the new motd from the same shell. If steps were followed correctly you will see new motd, something similar to the preview.  
> > **Run motd from the same shell:**  
> > `sudo run-parts /etc/update-motd.d`
#

#### ❯ Automation

* We need to automate the process of finding pending OS update count. It is scheduled to run once a day at 8:00pm. You can change the time and frequency based on your preference.

  * **Systemd Timer**  
	  Copy `motd-update.timer` and `motd-update.service` from the latest release under `systemd-timer` dir to `/etc/systemd/system`. Make sure files are under the ownership of root. Enable and start timer.  
    > **Change ownership [If needed]:**  
    > `sudo chown root:root /etc/systemd/system/motd-update.timer`  
    > `sudo chown root:root /etc/systemd/system/motd-update.service`  
    > **Enable timer:**  
    > `sudo systemctl enable motd-update.timer`  
    > **Start timer:**  
    > `sudo systemctl start motd-update.timer`  
    > **List all timers [If needed]:**  
    > `systemctl list-timers`  

* Last step. We need to reset the pending update count in motd as soon as we update the OS, otherwise count will be updated at the next run of systemd timer. Suppose you update system with commands `sudo apt update` & `sudo apt full-upgrade`. **You need to run command `sudo run-parts /etc/update-motd-static.d` at the end.** It will reset the update count in motd after OS update. Whatever your preferred way to update the OS, run this command at the very end.
  * I update OS with a bash script `update.sh` after seeing pending updates in motd. It takes care of everything that includes **update OS, cleanup and update motd count**. `update.sh` is available in the latest release under `update-os` dir. Execution screenshot is shown in the repo under `update-os` dir. Script is well documented. **Open and check the commands once before execution.**  
You can add switch -y to `sudo apt full-upgrade` command to bypass the yes/no prompt. I prefer not to have it as a last chance to review. Script does cleanup as well using `sudo apt --purge autoremove` & `sudo apt clean`, you can remove them if you prefer not to run these after OS update.  

#
> **_NOTE:_**  
> If you are not seeing the exact colors in your motd as in the preview, check the Putty section below for color scheme.
#

### Scripts Info
#### ❯ /etc/update-motd.d/10-welcome
> Displays the raspberry model, welcome user message, current timestamp and kernel version.

#### ❯ /etc/update-motd.d/15-system
> Shows various details of the system. It includes temperature, memory, running processes and others. Few labels are trimmed down, like `Procs` for `Processes`, `Temp` for `Temperature`, `Last` for `Last Login`. You can use full labels according to your preference and arrange them accordingly.

#### ❯ /etc/update-motd.d/20-update
> This static script displays available update count. It is generated by `/etc/update-motd-static.d/20-update`.

#### ❯ /etc/update-motd-static.d/20-update
> Calculates available update count and generates the static script for motd display. It can be expanded to show the security update count separately like Ubuntu.

#
### PuTTY
I use slight modification of `Liquid Carbon` PuTTY theme from [AlexAkulov](https://github.com/AlexAkulov/putty-color-themes/blob/master/23.%20Liquid%20Carbon.reg). Modified theme `Liquid Carbon Mod.reg` is available under this repo folder `putty` along with screenshots of PuTTY settings.
</div>
