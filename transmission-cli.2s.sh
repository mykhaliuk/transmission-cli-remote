#!/usr/bin/env sh
#
# Transmission-cli Remote
#
# <bitbar.title>Transmission-cli Remote</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Mykhaliuk Volodymyr</bitbar.author>
# <bitbar.author.gitHub></bitbar.author.gitHub>
# <bitbar.desc></bitbar.desc>
# <bitbar.dependencies>transmission-remote</bitbar.dependencies>
# <bitbar.image></bitbar.image>
#
# Dependencies:
#   transmission-remote (https://trac.transmissionbt.com/wiki/Building) available via homebrew `brew install transmission`

COLOR="white";
LENGTH=50;
UP="↑|dropdown=false color=green";
DOWN="↓|dropdown=false color=red";
UPDOWN="↑↓|dropdown=false color=$COLOR";
START_DAEMON="/Users/vo/Applications/scripts/transmission/start_daemon.sh";
STOP_DAEMON="/Users/vo/Applications/scripts/transmission/stop_daemon.sh";

function is_remote () {
  [[ -x /usr/local/bin/transmission-remote ]]
}

function print_error () {
  echo "⚠️|dropdown=false color=red";
  echo "---";
  echo "Transmission is not installed|color=red";
  echo "|trim=false";
  echo "Please install it via Homebrew using this command";
  echo "brew install fortune|font=Courier color=green";
  echo "Then refresh your Bitbar (Preferences ▶ Refresh all)";
}

function is_deamon_running () {
  pgrep -x transmission-daemon >/dev/null;
}

function print_run_demon_menu () {
  echo "👻 |dropdown=false color=$COLOR";
  echo "---";
  # echo "|trim=false";
  echo "Daemon is offnline";
  echo "✔️  Start daemon|terminal=false bash=$START_DAEMON color=green";
}

function print_status_bar () {
  /usr/local/bin/transmission-remote -l | grep % |
    sed " # This first sed command is to ensure a desirable order with sort
      s/.*Stopped.*/A/g;
      s/.*Seeding.*/Z/g;
      s/.*Idle.*/B/g;
      s/.*Uploading.*/L/g;
      s/.*Verifying.*/V/g;
      # s/.*100%.*/N/g;
      s/.*%.*/M/g;" |
        sort -h | uniq -c | sed " # Now we replace standing letters with symbols
              s/A//g;
              s/B//g;
              s/Z//g;
              s/N//g;
              s/L//g;
              s/V//g;
              s/M//g;" | awk '{print $2, $1}' | tr '\n' ' ';
  echo "$@|dropdown=false font='RobotoMono Nerd Font'-Bold color=$COLOR";
}

function print_menu_header (){
  /usr/local/bin/transmission-remote -l |
    grep ID |
    sed -E "
      s/(ID) *(Done) *(Have) *(ETA) *(Up) *(Down) *(Ratio) *(Status) *(Name)/Stat   \1      \2      \9/;" |
    tr '\n' ' ';
  echo "$@";
}

function print_menu_footer () {
  /usr/local/bin/transmission-remote -l |
    grep Sum |
    sed -E "
      s/(Sum:) *([0-9]*\.[0-9]* [A-Z]*)\ *([0-9]*\.[0-9]*) *([0-9]*\.[0-9]*).*/\2  ( ⇣ \4  ⇡ \3 )/" |
    tr '\n' ' ';
  echo "$@|color=white";
}

function print_torrents_list () {
  /usr/local/bin/transmission-remote -l |
    grep % |
    sed -E "
      s/([0-9]*) *([0-9]*%) *([0-9]*\.[0-9]* [A-Z]{2,4} *(([0-9]* [A-z]*)|([A-z]*)) *[0-9]*\.[0-9]* *[0-9]*\.[0-9]* *[0-9]*\.[0-9]* *)(([A-z]*)|(Up & Down)) */\7   \1    \2     /g" |
    sed "
      s/Stopped//g;
      s/Seeding//g;
      s/Idle//g;
      s/Downloading//g;
      s/Up & Down//g;
      # s/100%//g;
      s/Uploading//g;
      s/Verifying//g;
      " |
    while read line
    do
      echo "${line} | color=#999999 font='RobotoMono Nerd Font' length=$LENGTH";
      echo "-- Start torrent|terminal=false bash=/usr/local/bin/transmission-remote param1=-t` echo $line | awk '{print $2}'` param2=-s"
      echo "-- Stop torrent|terminal=false bash=/usr/local/bin/transmission-remote param1=-t` echo $line | awk '{print $2}'` param2=-S"
      echo "-- Remove torrent|terminal=false bash=/usr/local/bin/transmission-remote param1=-t` echo $line | awk '{print $2}'` param2=-r"
      echo "-- Remove torrent & delete data|terminal=false bash=/usr/local/bin/transmission-remote param1=-t` echo $line | awk '{print $2}'` param2=-rad"
      echo "-- Verify torrent|terminal=false bash=/usr/local/bin/transmission-remote param1=-t` echo $line | awk '{print $2}'` param2=-v"

    done
}

function print_status () {
  print_status_bar;

  print_menu_header;
  echo "---";
  echo "|trim=false";
  print_torrents_list;
  echo "|trim=false";
  echo "---";
  echo "Summary:|color=green";
  print_menu_footer;
  echo "---";
  echo "Start All| color=green terminal=false bash=/usr/local/bin/transmission-remote param1=-tall param2=-s";
  echo "Stop All| color=red terminal=false bash=/usr/local/bin/transmission-remote param1=-tall param2=-S";
  echo "---";
  echo "❗️ Stop Daemon";
  echo "--Stop|terminal=false bash=$STOP_DAEMON color=red";
}

if ! is_remote; then
  print_error;
else
  if ! is_deamon_running; then
    print_run_demon_menu;
  else
    print_status;
  fi
fi
