#!/bin/bash
#Author: github.com/harsh2527
#Twitter:@harsh2527
#Instagram: @0x414841524d

trap 'echo exiting cleanly...; exit 1;'

checkroot() {

if [[ "$(id -u)" -ne 0 ]]; then
   printf "\e[1;77m Run me as root!\n\e[0m"
   exit 1
fi

}

checkroot

(trap '' SIGINT SIGTSTP && command -v tor > /dev/null 2>&1 || { printf >&2  "\e[1;92mInstalling TOR, please wait...........\n\e[0m"; apt-get update > /dev/null && apt-get -y install tor > /dev/null || printf "\e[1;91mTor Not installed.\n\e[0m"; }) & wait $!

(trap '' SIGINT SIGTSTP && command -v curl > /dev/null 2>&1 || { printf >&2  "\e[1;92mInstalling cURL, please wait.............\n\e[0m"; apt-get update > /dev/null && apt-get -y install curl > /dev/null || printf "\e[1;91mCurl Not installed.\n\e[0m"; }) & wait $!

printf "\e[1;92m Now all requirements are installed!\n\e[0m"

