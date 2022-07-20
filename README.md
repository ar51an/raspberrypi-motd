## MOTD
Customized dynamic Message of the Day (MOTD) for Raspberry Pi

### Preview
<div align="center">

![WithCount](https://user-images.githubusercontent.com/11185794/157579568-50dddaa2-c56d-4eb7-bc7c-a8a0a9cd0b3d.png)

![WithoutCount](https://user-images.githubusercontent.com/11185794/157579619-535aecd7-be3f-477a-9a7e-dccd70f0fb56.png)
<br>

![motd](https://img.shields.io/badge/-motd-D8BFD8?logo=themodelsresource&logoColor=3a3a3d)
&nbsp;&nbsp;![visitors](https://shields-io-visitor-counter.herokuapp.com/badge?page=ar51an.raspberrypi-motd&label=visitors&logo=github&color=4883c2)
&nbsp;&nbsp;![lang](https://img.shields.io/badge/lang-Bash-5F9EA0?logo=gnubash&logoColor=#4EAA25)
&nbsp;&nbsp;![license](https://img.shields.io/badge/license-MIT-CED8E1)
</div>

### Intro
Many folks use Raspberry Pi as headless (without display) system. If you use SSH to connect to your Raspberry Pi more often and interested in changing the MOTD (message of the day), this might be the one you were looking for. There are many options available for customized motd on the web with and without ascii art. **The goal was to create simple, attractive, swift and useful motd**.
<br/>

I prefer updating my OS manually. After the transition from Ubuntu to Raspberry Pi OS, lack of number of available updates on motd was the triggering point to develop this motd. Few custom motd on the web for Raspberry Pi OS shows the number of available updates. They used `apt-check` utility which was part of update-notifier-common package. It is no longer available from RaspiOS buster onward. They merged the features of update-notifier-common package into unattended-upgrades add-on package. Ubuntu uses the same utility to show package count on motd. I used `apt-get` to parse the required information.
<br/>

The process I used for the motd is the same as Raspberry Pi OS OR Ubuntu uses to show the motd dynamically. There is no third party package or tool used. It is written in bash and executes using the same mechanism as the default motd. There are multiple commands for retrieving the same information. I tested various commands for each info and used the ones that took least amount of time. This dynamic motd takes approximately 1 sec or less after entering password. This is the fastest you can get with all the information it is displaying.
<br/>

#### Specs:
> Raspberry Pi 4 Model B &nbsp;•&nbsp; raspios-bullseye-arm64-lite  
> System & Distro used for motd. It should work on other specs as well.  
#
### Steps
#### ⮞ Remove Default MOTD

* Delete `/etc/motd` file. This file contains the static text about Debian GNU/Linux liability. You can check the contents of the file with command `sudo nano /etc/motd`. Alternatively you can keep a backup of this file at some place.
  > **Delete motd file:**  
  > `sudo rm /etc/motd`  

* Delete `/etc/update-motd.d/10-uname` file. This file prints the OS version dynamically to the default message. We will print a trimmed down version of OS through our new customized motd.  
  > **Delete 10-uname file:**  
  > `sudo rm /etc/update-motd.d/10-uname`  

* Modify `/etc/ssh/sshd_config` file. This file prints last login timestamp and location. We will print last login timestamp and location through our new customized motd.  
  > **Edit sshd_config file:**  
  > `sudo nano /etc/ssh/sshd_config`  
  > Find the line `#PrintLastLog yes` Replace it with `PrintLastLog no`  
  > Save sshd_config file [Ctrl+O] & Exit nano [Ctrl+X]  
  > Restart sshd process `sudo systemctl restart sshd`  

#
> **_NOTE:_**  
> At this point we completely removed the default motd. You can reconnect using ssh and if you followed the steps correctly  you will not see any motd.  
#

#### ⮞ Implement New MOTD

* Copy `10-welcome` & `15-system` files from this repo folder `update-motd.d` to Raspberry Pi OS folder `/etc/update-motd.d` Make sure these files are under the user:group of root and they are executable. You can **either** use WinSCP or wget to copy/download these files to tmp folder and then move them to `/etc/update-motd.d` **or** create empty files in `/etc/update-motd.d` using touch and copy/paste the contents of corresponding file in it.

  > **Change ownership of files [If needed]:**  
  > `sudo chown root:root /etc/update-motd.d/10-welcome`  
  > `sudo chown root:root /etc/update-motd.d/15-system`  

  > **Create empty files to copy/paste contents [If needed]:**  
  > `sudo touch /etc/update-motd.d/10-welcome`  
  > `sudo touch /etc/update-motd.d/15-system`  

  > **Make files executable:**  
  > `chmod +x /etc/update-motd.d/10-welcome`  
  > `chmod +x /etc/update-motd.d/15-system`  

  > If everything is done properly it will look something like this. Ignore `20-update` file for now we will create it in next step:  
  > ![update-motd_files](https://user-images.githubusercontent.com/11185794/132084515-5b41d9fb-5e84-4c1d-8a2f-7d7cd9c5e671.png)

* Create third file `/etc/update-motd.d/20-update` as empty file using touch  
  > **Create file and make it executable:**  
  > `sudo touch /etc/update-motd.d/20-update`  
  > `chmod +x /etc/update-motd.d/20-update`  

#
> **_NOTE:_**  
> If you noticed all the files we have created/copied so far have filenames starting with a number. Dynamic contents of the motd are created by PAM (Pluggable Authentication Module) running bash files from /etc/update-motd.d folder. The files are read in number order and do not need a file extension. In the default motd it was executing 10-uname file to show the OS version which we deleted earlier.
#

* In this step we will create static contents of our new motd. This is not entirely static, PAM will execute this information from bash file that has static contents. Static file is created from dynamic file using cronjob once a day. It is done this way to minimize startup delay. If I keep it completely dynamic (how I initially did and it was easier), the startup delay between entering the password and seeing the prompt is approximately 3-4 seconds.
  * Create a folder `/etc/update-motd-static.d` Even though this folder contains the dynamic file that will generate the static file `/etc/update-motd.d/20-update` I am calling it `update-motd-static.d` for easier distinction (You can name it whatever you prefer and use the same name in automation tasks)  
    > **Create folder:**  
    > `sudo mkdir /etc/update-motd-static.d/`  

  * Copy `20-update` file from this repo folder `update-motd-static.d` to this newly created folder `/etc/update-motd-static.d` Make sure file is under the user:group of root and it is executable. You can **either** use WinSCP or wget to copy/download this file to tmp folder and then move it to `/etc/update-motd-static.d` **or** create empty file in `/etc/update-motd-static.d` using touch and copy/paste the contents of corresponding file in it.
  
    > **Change ownership of file [If needed]:**  
    > `sudo chown root:root /etc/update-motd-static.d/20-update`  

    > **Create empty file to copy/paste contents [If needed]:**  
    > `sudo touch /etc/update-motd-static.d/20-update`  

    > **Make file executable:**  
    > `chmod +x /etc/update-motd-static.d/20-update`  
    
    > If everything is done properly it will look something like this:  
    > ![update-motd-static_files](https://user-images.githubusercontent.com/11185794/132091200-e960ac30-4985-447a-9c26-5878f2514c6e.png)

    
  * Execute this file. This process will update the static file `/etc/update-motd.d/20-update` with the number of pending updates (if any). We will automate this process through cronjob later.
    > **Execute file:**  
    > `sudo run-parts /etc/update-motd-static.d`  

#
> **_NOTE:_**  
> At this point we implemented our new motd, pending few automations. Let's test our new motd. It will verify that everything we did so far is working properly. There are multiple ways to test **either** you can reconnect using ssh **or** run the new motd from the same shell. If you followed the steps correctly you will see new motd something similar to the initial preview of this guide.  
> > **Execute motd from the same shell:**  
> > `sudo run-parts /etc/update-motd.d`
#

#### ⮞ Automation

* We are almost done. We need to automate the process of finding pending OS updates count. I did it through a cronjob which runs once a day. You can change the time and frequency based on your requirements, once a day serves my purpose very well. Below cronjob will find the count of pending OS updates once a day at 8:00pm and update it in the motd.
  > **Create cronjob:**  
  > Open crontab for root `sudo crontab -e`  
  > Add below 2 lines at the end of the crontab file, **save** & close the editor  
  > ```
  > # MOTD - Update '20-update' file - Once A Day At 8:00PM
  > 0 20 * * * run-parts /etc/update-motd-static.d
  > ```
  
#
> **_NOTE:_**  
> If this is the first time you are creating a cronjob. It will ask for your preferred editor, I use nano, you can choose your preferred one.  
#

* Last step. We need to update the pending updates count in motd as soon as we update the OS. With this new motd mechanism it will be updated at the next execution of cronjob. Let's assume you update your system manually by running commands `sudo apt update` & `sudo apt full-upgrade`. **We need to run another command after this** `sudo run-parts /etc/update-motd-static.d` It will reset the update count in motd as soon as we are done with OS update. Whatever your preferred way to update the OS, run this command at the very end.
  * I update OS manually using a bash script `update.sh` after seeing pending updates in motd. This script takes care of everything that includes **update OS, cleanup and update motd count**. `update.sh` is available in the repo under folder `update-os` along with a screenshot of what it will do upon execution. It is well documented. **Open and check the commands first before execution, if you need all of them**. Feel free to modify it according to your requirement.  
You can add switch -y to `sudo apt full-upgrade` command if you want to bypass the yes/no prompt. I prefer not to have it as a last chance to review if I want to update or not. I do cleanup as well in this script using `sudo apt --purge autoremove` & `sudo apt clean`, you can remove them if you prefer not to run these after OS update.  

#
> **_NOTE:_**  
> We are done. If you are not seeing the exact colors in your motd as shown in the preview, check the Putty section below for color scheme.
#

### Scripts Info
#### ⮞ /etc/update-motd.d/10-welcome
> Bash script displays the welcome user message along with current timestamp and OS version.

#### ⮞ /etc/update-motd.d/15-system
> Script shows various details of the system. It includes system temperature, memory, running processes and few more. I trimmed down on some of the labels, like I used `Procs` for `Processes`, `Temp` for `Temperature`, `Last` for `Last Login`. You can use full labels according to your liking and arrange them accordingly.

#### ⮞ /etc/update-motd.d/20-update
> This is the static script. It is generated by `/etc/update-motd-static.d/20-update` to show the number of available updates.

#### ⮞ /etc/update-motd-static.d/20-update
> Script calculates the number of available updates and generates the static file for motd display. It can be expanded to show the number of security updates separately like Ubuntu. My requirement was to see the total number only.

#
### PuTTY
I use slight modification of `Liquid Carbon` PuTTY theme from [AlexAkulov](https://github.com/AlexAkulov/putty-color-themes/blob/master/23.%20Liquid%20Carbon.reg). Modified theme `Liquid Carbon Mod.reg` is available under this repo folder `putty` along with screenshots of PuTTY settings.
