#!/usr/bin/env sh
#
# Transmission-cli Remote
#
# <bitbar.title>Transmission-cli Remote</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Mykhaliuk Volodymyr</bitbar.author>
# <bitbar.author.gitHub>https://github.com/mykhaliuk/transmission-cli-remote</bitbar.author.gitHub>
# <bitbar.desc></bitbar.desc>
# <bitbar.dependencies>transmission-remote,nerd-fonts,ssed</bitbar.dependencies>
# <bitbar.image></bitbar.image>
#
# Dependencies:
#   transmission-remote (https://trac.transmissionbt.com/wiki/Building) available via homebrew `brew install transmission`

LENGTH=50;  # String legnth in torrent list
START_DAEMON="/Users/vo/Applications/scripts/transmission/start_daemon.sh";
STOP_DAEMON="/Users/vo/Applications/scripts/transmission/stop_daemon.sh";
# Font
CUSTOM_FONT='RobotoMono Nerd Font';
# Icons set. You can replace them if you don't want to add an adittional (NERD Fonts) fonts.
ICON_STOP=;
ICON_IDLE=;
ICON_SEEDDING=;
ICON_DONE=;
ICON_UPLOADING=;
ICON_DOWNLOADING=;
ICON_VERIFYING=;

function is_remote () {
  [[ -x /usr/local/bin/transmission-remote ]];
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
  echo "👻 |dropdown=false ";
  echo "---";
  # echo "|trim=false";
  echo "Daemon is offnline";
  echo "Start Transmission daemon|terminal=false bash=$START_DAEMON color=green";
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
              s/A/$ICON_STOP/g;
              s/B/$ICON_IDLE/g;
              s/Z/$ICON_SEEDDING/g;
              s/N/$ICON_DONE/g;
              s/L/$ICON_UPLOADING/g;
              s/V/$ICON_VERIFYING/g;
              s/M/$ICON_DOWNLOADING/g;" | awk '{print $2, $1}' | tr '\n' ' ';
  echo "$@|dropdown=false font='$CUSTOM_FONT'";
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
      s/(Sum:) *([0-9]*\.[0-9]* [A-Z]*)\ *([0-9]*\.[0-9]*) *([0-9]*\.[0-9]*).*/\2  ( ⇣ \4  ⇡ \3 )/;" |
    tr '\n' ' ';
  echo "$@";
}

function print_torrents_list () {
  /usr/local/bin/transmission-remote -l |
    grep % |
    /usr/local/bin/ssed -R "s/(\d+\s+)(\d+%).+(?=((Stopped|Idle|Verifying|Uploading|(Up\s.\sDown)|Downloading|Seeding)))(?:(Up & Down)|\w+)?\s*/\3   \1\2    /" |
    sed "
      s/Stopped/$ICON_STOP/g;
      s/Seeding/$ICON_SEEDDING/g;
      s/Idle/$ICON_IDLE/g;
      s/Downloading/$ICON_DOWNLOADING/g;
      s/Up & Down/$ICON_DOWNLOADING/g;
      # s/100%/$ICON_DONE/g;
      s/Uploading/$ICON_UPLOADING/g;
      s/Verifying/$ICON_VERIFYING/g;
      " |
    while read line
    do
      echo "${line} | font='$CUSTOM_FONT' length=$LENGTH";
      echo "-- Start torrent|terminal=false reload=true bash=/usr/local/bin/transmission-remote param1=-t` echo $line | awk '{print $2}'` param2=-s"
      echo "-- Stop torrent|terminal=false reload=true bash=/usr/local/bin/transmission-remote param1=-t` echo $line | awk '{print $2}'` param2=-S"
      echo "-- Remove torrent|terminal=false reload=true bash=/usr/local/bin/transmission-remote param1=-t` echo $line | awk '{print $2}'` param2=-r"
      echo "-- Remove torrent & delete data|terminal=false reload=true bash=/usr/local/bin/transmission-remote param1=-t` echo $line | awk '{print $2}'` param2=-rad"
      echo "-- Verify torrent|terminal=false reload=true bash=/usr/local/bin/transmission-remote param1=-t` echo $line | awk '{print $2}'` param2=-v"
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
  echo "Start all torrents| color=green terminal=false bash=/usr/local/bin/transmission-remote param1=-tall param2=-s";
  echo "Stop all torrents| color=red terminal=false bash=/usr/local/bin/transmission-remote param1=-tall param2=-S";
  echo "---";
  echo "Stop daemon";
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
