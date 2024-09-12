#!/data/data/com.termux/files/usr/bin/bash -e

function check_dependencies() {
    printf "${blue}\n[*] Checking package dependencies...${reset}\n"
    ## Workaround for termux-app issue #1283 (https://github.com/termux/termux-app/issues/1283)
    ##apt update -y &> /dev/null
    apt-get update -y &> /dev/null || apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" dist-upgrade -y &> /dev/null
    for i in pulseaudio play-audio axel; do
        if [ -e $PREFIX/bin/$i ]; then
            echo "  $i is OK"
        else
            printf "\033[35;1mInstalling ${i}...${reset}\n"
            apt install -y $i || {
                printf "${red}ERROR: Failed to install packages.\n Exiting.\n${reset}"
	        exit
            }
        fi
    done
    printf "\033[1;35mapt upgrade starting...\n${reset}"
    apt upgrade -y || {
        printf "\n${red}ERROR: Failed to upgrade packages.\n_______Please check the internet connection.\n\n"
        read -p "$1[?] Do you want continue any way ??? [y/N] " ANS
        printf "\n${reset}"
        case "$ANS" in
            *y*|*Y*) echo "Continuing any way.";return 0;;
            *) echo "You have successfully logged out.";exit;;
        esac
    }
}

function ad() {
     REQUEST='_____[ Please subscribe my youtube chennel ]_____'
     CHENNEL='_________________[ Al-Amin Zone ]_________________'
     for i in {1..66}; do
     echo -ne "\r${yellow}${REQUEST:0:$i}${reset}"
     sleep .03
     done
     for j in {1..55}; do
     echo -ne "\r\033[1;31;42m${CHENNEL:0:$j}${reset}"
     sleep .03
     done
}

function setup_storage() {
    printf "\n${green}";read -p " [#] Allow the storage permission. [Enter] ";printf "${reset}\n"
    termux-setup-storage ||:
    read -p " [#] Check the Termux storage permission. [Enter]"
    echo "check storage" >> /sdcard/.Al-Amin_Zone || {
        printf "\n\n${green} Please send 'y' command & then press 'Enter'.\n Or,${reset}"
        setup_storage
        return 0
    }
}

function bootstrap_dir() {
    if [ -d $HOME/storage ]; then
        printf "\u001b[46m${blue}_____[ Please subscribe my youtube chennel ]______\n_________________[ Al-Amin Zone ]_________________${reset}\n\n"
        echo "check storage" >> /sdcard/.Al-Amin_Zone || {
              setup_storage
        }
    else
        printf "\u001b[46m${blue}_____[ Please subscribe my youtube chennel ]______\n_________________[ Al-Amin Zone ]_________________${reset}\n\n"
        setup_storage
    fi
    printf "${light_cyan}\n"
    read -p " Continue with welcome voice.             [Enter]"
    printf "${yellow} Continuing Anyway...........${reset}\n\n"
    check_dependencies
    mkdir /sdcard/Termux-Bootstrap &> /dev/null || :
    if [ -f /sdcard/Termux-Bootstrap/welcome.mp3 ];then
        printf "\n${green}Welcome to Al-Amin Zone${reset}\n\n"
        play-audio /sdcard/Termux-Bootstrap/welcome.mp3 &> /dev/null ||:
    else
        axel --output=/sdcard/Termux-Bootstrap/welcome.mp3 https://github.com/shahinuralamin/Technical_Shahinur_Al-Amin/releases/download/termux-prefix-switcher/welcome.mp3 &> /dev/null || {
             printf "${red}E: Internet connection failed ${reset}\n\n"
             printf "\n${green}Welcome to Al-Amin Zone${reset}\n\n"
             return 0
        }
        printf "\n${green}Welcome to Al-Amin Zone${reset}\n\n"
        play-audio /sdcard/Termux-Bootstrap/welcome.mp3
    fi
}

function timer() {
    seconds=2
    start="$(($(date +%s) + $seconds))"
    while [ "$start" -ge `date +%s` ]; do
        time="$(( $start - `date +%s` ))"
        printf '%s\r' "    Please wait... ($(date -u -d " @$time" +%S))"
    done
}

function config_pulseaudio() {
    ad; printf "${blue}[*] Configuring Pulseaudio...${reset}\n"
    timer; printf "\n${light_cyan}[*] Processing Pulseaudio...${reset}\n"
    BAR='(~) Loading...[##################################'   # this is full bar, e.g. 20 chars
    GRA='               …………………………………………………………………………………………]'
    echo -ne "\r$GRA"
    for i in {15..80}; do
    echo -ne "\r${BAR:0:$i}" # print $i chars of $BAR from 0 position
    sleep .08                # wait 640ms between "frames"
    done
    DEFAULT_PA=$PREFIX/etc/pulse/default.pa
    cat > $DEFAULT_PA <<- EOF
#!/data/data/com.termux/files/usr/bin/pulseaudio -nF
#
# This file is part of PulseAudio.
#
# PulseAudio is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# PulseAudio is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with PulseAudio; if not, see <http://www.gnu.org/licenses/>.

# This startup script is used only if PulseAudio is started per-user
# (i.e. not in system mode)

.fail

### Automatically restore the volume of streams and devices
load-module module-device-restore
load-module module-stream-restore
load-module module-card-restore

### Automatically augment property information from .desktop files
### stored in /usr/share/application
load-module module-augment-properties

### Should be after module-*-restore but before module-*-detect
load-module module-switch-on-port-available

### Load audio drivers statically
### (it's probably better to not load these drivers manually, but instead
### use module-udev-detect -- see below -- for doing this automatically)
#load-module module-null-sink
#load-module module-pipe-sink

### Automatically load driver modules depending on the hardware available
.ifexists module-detect.so
### Use the static hardware detection module (for systems that lack udev support)
#load-module module-detect
.endif

### Automatically connect sink and source if JACK server is present
.ifexists module-jackdbus-detect.so
.nofail
load-module module-jackdbus-detect channels=2
.fail
.endif


### Load several protocols
.ifexists module-esound-protocol-unix.so
load-module module-esound-protocol-unix
.endif
load-module module-native-protocol-unix

### Network access (may be configured with paprefs, so leave this commented
### here if you plan to use paprefs)
#load-module module-esound-protocol-tcp
load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1

### Load the RTP receiver module (also configured via paprefs, see above)
#load-module module-rtp-recv

### Load the RTP sender module (also configured via paprefs, see above)
#load-module module-null-sink sink_name=rtp format=s16be channels=2 rate=44100 sink_properties="device.description='RTP Multicast Sink'"
#load-module module-rtp-send source=rtp.monitor


### Automatically restore the default sink/source when changed by the user
### during runtime
### NOTE: This should be loaded as early as possible so that subsequent modules
### that look up the default sink/source get the right value
load-module module-default-device-restore

### Make sure we always have a sink around, even if it is a null sink.
load-module module-always-sink

### Honour intended role device property
load-module module-intended-roles

### Automatically suspend sinks/sources that become idle for too long
load-module module-suspend-on-idle

### If autoexit on idle is enabled we want to make sure we only quit
### when no local session needs us anymore.
.ifexists module-console-kit.so
load-module module-console-kit
.endif
.ifexists module-systemd-login.so
load-module module-systemd-login
.endif

### Enable positioned event sounds
load-module module-position-event-sounds

### Cork music/video streams when a phone stream is active
load-module module-role-cork

### Modules to allow autoloading of filters (such as echo cancellation)
### on demand. module-filter-heuristics tries to determine what filters
### make sense, and module-filter-apply does the heavy-lifting of
### loading modules and rerouting streams.
load-module module-filter-heuristics
load-module module-filter-apply

### Make some devices default
#set-default-sink output
#set-default-source input

### Allow including a default.pa.d directory, which if present, can be used
### for additional configuration snippets.
### Note that those snippet files must have a .pa file extension, not .conf
.nofail
.include /data/data/com.termux/files/usr/etc/pulse/default.pa.d
load-module module-sles-sink
#load-module module-aaudio-sink
EOF
    DAEMON_CONF=$PREFIX/etc/pulse/daemon.conf
    cat > $DAEMON_CONF <<- EOF
# This file is part of PulseAudio.
#
# PulseAudio is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# PulseAudio is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with PulseAudio; if not, see <http://www.gnu.org/licenses/>.

## Configuration file for the PulseAudio daemon. See pulse-daemon.conf(5) for
## more information. Default values are commented out.  Use either ; or # for
## commenting.

; daemonize = no
; fail = yes
; allow-module-loading = yes
; allow-exit = yes
; use-pid-file = yes
; system-instance = no
; enable-shm = yes
; enable-memfd = yes
; shm-size-bytes = 0 # setting this 0 will use the system-default, usually 64 MiB
; lock-memory = no
; cpu-limit = no

; high-priority = yes
; nice-level = -11

; realtime-scheduling = yes
; realtime-priority = 5

; exit-idle-time = -1
; scache-idle-time = 20

; dl-search-path = (depends on architecture)

; load-default-script-file = yes
; default-script-file = /data/data/com.termux/files/usr/etc/pulse/default.pa

; log-target = auto
; log-level = notice
; log-meta = no
; log-time = no
; log-backtrace = 0

; resample-method = speex-float-1
; avoid-resampling = false
; enable-remixing = yes
; remixing-use-all-sink-channels = yes
; remixing-produce-lfe = no
; remixing-consume-lfe = no
; lfe-crossover-freq = 0

; flat-volumes = no

; rescue-streams = yes

; rlimit-fsize = -1
; rlimit-data = -1
; rlimit-stack = -1
; rlimit-core = -1
; rlimit-as = -1
; rlimit-rss = -1
; rlimit-nproc = -1
; rlimit-nofile = 256
; rlimit-memlock = -1
; rlimit-locks = -1
; rlimit-sigpending = -1
; rlimit-msgqueue = -1
; rlimit-nice = 31
; rlimit-rtprio = 9
; rlimit-rttime = 200000

; default-sample-format = s16le
; default-sample-rate = 44100
; alternate-sample-rate = 48000
; default-sample-channels = 2
; default-channel-map = front-left,front-right

; default-fragments = 4
; default-fragment-size-msec = 25

; enable-deferred-volume = yes
; deferred-volume-safety-margin-usec = 8000
; deferred-volume-extra-delay-usec = 0
EOF
}

function create_launcher() {
    PA_LAUNCHER=$PREFIX/bin/pa
    cat > $PA_LAUNCHER <<- EOF
#!/data/data/com.termux/files/usr/bin/bash -e
cd \${HOME}
function pa_start() {
              LD_PRELOAD=/system/lib64/libsfplugin_ccodec.so pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 || {
               printf "\n\033[1;31mProblem of Pulseaudio\033[0m\n\n"
               apt update &> /dev/null
               apt-get update &> /dev/null
               apt upgrade -y
               echo "Again installing packages"
               apt reinstall pulseaudio -y &> /dev/null ||:
               apt install axel -y &> /dev/null
               axel --output=\$HOME/pulseaudioinstaller https://raw.githubusercontent.com/shahinuralamin/Technical_Shahinur_Al-Amin/main/install-pulseaudio-termux || {
                    printf "\n\033[1;31mInternet connection error\033[0m\n"
                    pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 || {
                        PULSE=1
                        exit
                    }
               }
               if [ -f pulseaudioinstaller ]; then
       	       mv pulseaudioinstaller install-pulseaudio-termux;chmod +x install-pulseaudio-termux;./install-pulseaudio-termux;pa_start;exit
               fi
               if [ -z \$PULSE ]; then
               echo "pulseaudio is ok"
               fi
    }
    printf "\n\033[1;31;42m[ Pulseaudio is running... ]\033[0m\n\n"
    printf "\033[1;4;35m…♪…♪…♪…♪[\033[0m  \033[1;3;35mexport PULSE_SERVER=127.0.0.1\033[0m  \033[1;4;35m]…♪…♪…♪…\033[0m\n\n"
    auto-1
}

function pa_stop() {
    pulseaudio --kill || {
               printf "\n\033[1;31m[!] Pulseaudio is not running.\n    Please try again...\033[0m\n\n"
               auto-0
               exit
    }
    auto-0
    printf "\n\033[1;31;42m[ Pulseaudio is stoped. ]\033[0m\n\n"
    exit
}

function auto-0() {
    if [ -f \$PREFIX/bin/pa-auto ]; then
        rm -f \$PREFIX/bin/pa-auto
    fi
    cat > \$PREFIX/bin/pa-auto <<- EOM
    pa-0
EOM
}

function auto-1() {
    if [ -f \$PREFIX/bin/pa-auto ]; then
        rm -f \$PREFIX/bin/pa-auto
    fi
    cat > \$PREFIX/bin/pa-auto <<- EOM
    pa-1
EOM
}

function auto() {
    if [ ! -f \$PREFIX/bin/pa-auto ]; then
             pa_start
             exit
    fi
    while read line; do
    case \$line in
        pa-0) pa_start;;
        pa-1) pa_stop;;
    esac
    done < \$PREFIX/bin/pa-auto
}

case "\$1" in
    *start*) pa_start;;
    *stop*) pa_stop;;
    *) auto;;
esac
EOF
    chmod 700 $PA_LAUNCHER
}

function print_banner() {
    clear
    printf "${light_cyan}★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★\n"
    printf "${light_cyan}★                                                ★\n"
    printf "${light_cyan}★  #####. #    # #       .#####.  ######  Audio  ★\n"
    printf "${light_cyan}★  #    # #    # #       #.     * #       Audio  ★\n"
    printf "${light_cyan}★  #####' #    # #         '#.    #####   Audio  ★\n"
    printf "${light_cyan}★  #      #    # #      *     '#  #       Audio  ★\n"
    printf "${light_cyan}★  #      '####' ######  '#####'  ######  Audio  ★\n"
    printf "${light_cyan}★________________________________________________★\n"
    printf "${light_cyan}★________________[ ${green}Al-Amin Zone ${light_cyan}]________________★\n"
    printf "${light_cyan}**************************************************${reset}\n\n"
}

##################################
##              Main            ##

# Add some colours
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
blue='\033[1;34m'
light_cyan='\033[1;96m'
reset='\033[0m'

print_banner
bootstrap_dir
config_pulseaudio
create_launcher

print_banner
printf "${green}[=] Pulseaudio for Termux installed successfully${reset}\n\n"
printf "${green}[+] To start Pulseaudio, type:${reset}\n"
printf "${green}[+] pa start       # To start Pulseaudio${reset}\n"
printf "${green}[+] pa stop        # To stop Pulseaudio${reset}\n"
printf "${green}[+] pa             # To start and stop Pulseaudio${reset}\n"
