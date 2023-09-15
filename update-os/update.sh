#!/bin/bash -x

# Update all packages of operating system to latest.
# It will also update the Static Motd File [20-update]
# for displaying upgradeable package count at startup

{ echo -e "\e[30;48;5;248mUpdate Packages\e[0m"; } 2> /dev/null
sudo apt update

{ echo -e "\n\e[30;48;5;248mFull Upgrade Packages\e[0m"; } 2> /dev/null
sudo apt full-upgrade

{ echo -e "\n\e[30;48;5;248mRemove Dependency Packages That Are No Longer Needed\e[0m"; } 2> /dev/null
sudo apt --purge autoremove

{ echo -e "\n\e[30;48;5;248mClean apt Cache\e[0m"; } 2> /dev/null
sudo apt clean

{ echo -e "\n\e[30;48;5;248mUpdate Static Motd - Dynamic Folder File /etc/update-motd.d/20-update\e[0m"; } 2> /dev/null
sudo run-parts /etc/update-motd-static.d
