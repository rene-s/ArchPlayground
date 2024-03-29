#!/bin/bash
#-------------------------------------------------------------------------------
#Created by helmuthdu mailto: helmuthdu[at]gmail[dot]com
#Contribution: flexiondotorg
#-------------------------------------------------------------------------------
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------------------
# Run this script after your first boot with archlinux (as root)

#GLOBAL VARIABLES {{{
  checklist=( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 )
  # COLORS {{{
    Bold=$(tput bold)
    Underline=$(tput sgr 0 1)
    Reset=$(tput sgr0)
    # Regular Colors
    Red=$(tput setaf 1)
    Green=$(tput setaf 2)
    Yellow=$(tput setaf 3)
    Blue=$(tput setaf 4)
    Purple=$(tput setaf 5)
    Cyan=$(tput setaf 6)
    White=$(tput setaf 7)
    # Bold
    BRed=${Bold}$(tput setaf 1)
    BGreen=${Bold}$(tput setaf 2)
    BYellow=${Bold}$(tput setaf 3)
    BBlue=${Bold}$(tput setaf 4)
    BPurple=${Bold}$(tput setaf 5)
    BCyan=${Bold}$(tput setaf 6)
    BWhite=${Bold}$(tput setaf 7)
  #}}}
  # PROMPT {{{
    prompt1="Enter your option: "
    prompt2="Enter n° of options (ex: 1 2 3 or 1-3): "
    prompt3="You have to manually enter the following commands, then press ${BYellow}ctrl+d${Reset} or type ${BYellow}exit${Reset}:"
  #}}}
  # EDITOR {{{
    AUTOMATIC_MODE=0
    if [[ -f /usr/bin/vim ]]; then
      EDITOR="vim"
    elif [[ -z $EDITOR ]]; then
      EDITOR="nano"
    fi
  #}}}
  # DESKTOP ENVIRONMENT{{{
    CINNAMON=0
    GNOME=0
    KDE=0
  #}}}
  # MOUNTPOINTS {{{
    EFI_MOUNTPOINT="/boot/efi"
    ROOT_MOUNTPOINT="/dev/sda1"
    BOOT_MOUNTPOINT="/dev/sda"
    MOUNTPOINT="/mnt"
  #}}}
  ARCHI=`uname -m` # ARCHITECTURE
  UEFI=0
  LVM=0
  LUKS=0
  LUKS_DISK="sda2"
  AUR=`echo -e "(${BPurple}aur${Reset})"`
  EXTERNAL=`echo -e "(${BYellow}external${Reset})"`
  AUI_DIR=`pwd` #CURRENT DIRECTORY
  [[ $1 == -v || $1 == --verbose ]] && VERBOSE_MODE=1 || VERBOSE_MODE=0 # VERBOSE MODE
  LOG="${AUI_DIR}/`basename ${0}`.log" # LOG FILE
  [[ -f $LOG ]] && rm -f $LOG
  PKG=""
  PKG_FAIL="${AUI_DIR}/`basename ${0}`_fail_install.log"
  [[ -f $PKG_FAIL ]] && rm -f $PKG_FAIL
  XPINGS=0 # CONNECTION CHECK
  SPIN="/-\|" #SPINNER POSITION
  AUTOMATIC_MODE=0
  TRIM=0
#}}}
#COMMON FUNCTIONS {{{
  error_msg() { #{{{
    local _msg="${1}"
    echo -e "${_msg}"
    exit 1
  } #}}}
  cecho() { #{{{
    echo -e "$1"
    echo -e "$1" >>"$LOG"
    tput sgr0;
  } #}}}
  ncecho() { #{{{
    echo -ne "$1"
    echo -ne "$1" >>"$LOG"
    tput sgr0
  } #}}}
  spinny() { #{{{
    echo -ne "\b${SPIN:i++%${#SPIN}:1}"
  } #}}}
  progress() { #{{{
    ncecho "  ";
    while true; do
      kill -0 $pid &> /dev/null;
      if [[ $? == 0 ]]; then
        spinny
        sleep 0.25
      else
        ncecho "\b\b";
        wait $pid
        retcode=$?
        echo -ne "$pid's retcode: $retcode" >> $LOG
        if [[ $retcode == 0 ]] || [[ $retcode == 255 ]]; then
          cecho success
        else
          cecho failed
          echo -e "$PKG" >> $PKG_FAIL
          tail -n 15 $LOG
        fi
        break
      fi
    done
  } #}}}
  check_boot_system() { #{{{
    if [[ "$(cat /sys/class/dmi/id/sys_vendor)" == 'Apple Inc.' ]] || [[ "$(cat /sys/class/dmi/id/sys_vendor)" == 'Apple Computer, Inc.' ]]; then
      modprobe -r -q efivars || true  # if MAC
    else
      modprobe -q efivarfs            # all others
    fi
    if [[ -d "/sys/firmware/efi/" ]]; then
      ## Mount efivarfs if it is not already mounted
      if [[ -z $(mount | grep /sys/firmware/efi/efivars) ]]; then
        mount -t efivarfs efivarfs /sys/firmware/efi/efivars
      fi
      UEFI=1
      echo "UEFI Mode detected"
    else
      UEFI=0
      echo "BIOS Mode detected"
    fi
  }
  #}}}
  check_trim() { #{{{
    [[ -n $(hdparm -I /dev/sda | grep TRIM &> /dev/null) ]] && TRIM=1
  }
  #}}}
  check_root() { #{{{
    if [[ "$(id -u)" != "0" ]]; then
      error_msg "ERROR! You must execute the script as the 'root' user."
    fi
  } #}}}
  check_user() { #{{{
    if [[ "$(id -u)" == "0" ]]; then
      error_msg "ERROR! You must execute the script as a normal user."
    fi
  } #}}}
  check_archlinux() { #{{{
    if [[ ! -e /etc/arch-release ]]; then
      error_msg "ERROR! You must execute the script on Arch Linux."
    fi
  } #}}}
  check_hostname() { #{{{
    if [[ `echo ${HOSTNAME} | sed 's/ //g'` == "" ]]; then
      error_msg "ERROR! Hostname is not configured."
    fi
  } #}}}
  check_pacman_blocked() { #{{{
    if [[ -f /var/lib/pacman/db.lck ]]; then
      error_msg "ERROR! Pacman is blocked. \nIf not running remove /var/lib/pacman/db.lck."
    fi
  } #}}}
  check_domainname() { #{{{
    local _domainname=`echo ${HOSTNAME} | cut -d'.' -f2- | sed 's/ //g'`

    # no domain name. Keep looking...
    if [[ "${_domainname}" == "" ]]; then
      _domainname=`grep domain /etc/resolv.conf | sed 's/domain //g' | sed 's/ //g'`
    fi

    # not founded...
    if [[ "${_domainname}" == "" ]]; then
      error_msg "ERROR! Domain name is not configured."
    fi
  } #}}}
  check_connection(){ #{{{
    XPINGS=$(( $XPINGS + 1 ))
    connection_test() {
      ping -q -w 1 -c 1 `ip r | grep default | awk 'NR==1 {print $3}'` &> /dev/null && return 1 || return 0
    }
    WIRED_DEV=`ip link | grep "ens\|eno\|enp" | awk '{print $2}'| sed 's/://' | sed '1!d'`
    WIRELESS_DEV=`ip link | grep wlp | awk '{print $2}'| sed 's/://' | sed '1!d'`
    if connection_test; then
      print_warning "ERROR! Connection not Found."
      print_info "Network Setup"
      local _connection_opts=("Wired Automatic" "Wired Manual" "Wireless" "Configure Proxy" "Skip")
      PS3="$prompt1"
      select CONNECTION_TYPE in "${_connection_opts[@]}"; do
        case "$REPLY" in
          1)
            systemctl start dhcpcd@${WIRED_DEV}.service
            break
            ;;
          2)
            systemctl stop dhcpcd@${WIRED_DEV}.service
            read -p "IP Address: " IP_ADDR
            read -p "Submask: " SUBMASK
            read -p "Gateway: " GATEWAY
            ip link set ${WIRED_DEV} up
            ip addr add ${IP_ADDR}/${SUBMASK} dev ${WIRED_DEV}
            ip route add default via ${GATEWAY}
            $EDITOR /etc/resolv.conf
            break
            ;;
          3)
            ip link set ${WIRELESS_DEV} up
            wifi-menu ${WIRELESS_DEV}
            break
            ;;
          4)
            read -p "Enter your proxy e.g. protocol://adress:port: " OPTION
            export http_proxy=$OPTION
            export https_proxy=$OPTION
            export ftp_proxy=$OPTION
            echo "proxy = $OPTION" > ~/.curlrc
            break
            ;;
          5)
            break
            ;;
          *)
            invalid_option
            ;;
        esac
      done
      if [[ $XPINGS -gt 2 ]]; then
        print_warning "Can't establish connection. exiting..."
        exit 1
      fi
      [[ $REPLY -ne 5 ]] && check_connection
    fi
  } #}}}
  check_vga() { #{{{
    # Determine video chipset - only Intel, ATI and nvidia are supported by this script
    ncecho " ${BBlue}[${Reset}${Bold}X${BBlue}]${Reset} Detecting video chipset "
    local _vga=`lspci | grep VGA | tr "[:upper:]" "[:lower:]"`
    local _vga_length=`lspci | grep VGA | wc -l`

    if [[ -n $(dmidecode --type 1 | grep VirtualBox) ]]; then
      cecho Virtualbox
      VIDEO_DRIVER="virtualbox"
    elif [[ $_vga_length -eq 2 ]] && [[ -n $(echo ${_vga} | grep "nvidia") || -f /sys/kernel/debug/dri/0/vbios.rom ]]; then
      cecho Bumblebee
      VIDEO_DRIVER="bumblebee"
    elif [[ -n $(echo ${_vga} | grep "nvidia") || -f /sys/kernel/debug/dri/0/vbios.rom ]]; then
      cecho Nvidia
      read_input_text "Install NVIDIA proprietary driver" $PROPRIETARY_DRIVER
      if [[ $OPTION == y ]]; then
        VIDEO_DRIVER="nvidia"
      else
        VIDEO_DRIVER="nouveau"
      fi
    elif [[ -n $(echo ${_vga} | grep "advanced micro devices") || -f /sys/kernel/debug/dri/0/radeon_pm_info || -f /sys/kernel/debug/dri/0/radeon_sa_info ]]; then
      cecho AMD/ATI
      VIDEO_DRIVER="ati"
    elif [[ -n $(echo ${_vga} | grep "intel corporation") || -f /sys/kernel/debug/dri/0/i915_capabilities ]]; then
      cecho Intel
      VIDEO_DRIVER="intel"
    else
      cecho VESA
      VIDEO_DRIVER="vesa"
    fi
    OPTION="y"
    [[ $VIDEO_DRIVER == intel || $VIDEO_DRIVER == vesa ]] && read -p "Confirm video driver: $VIDEO_DRIVER [Y/n]" OPTION
    if [[ $OPTION == n ]]; then
      read -p "Type your video driver [ex: sis, fbdev, modesetting]: " VIDEO_DRIVER
    fi
  } #}}}
  read_input() { #{{{
    if [[ $AUTOMATIC_MODE -eq 1 ]]; then
      OPTION=$1
    else
      read -p "$prompt1" OPTION
    fi
  } #}}}
  read_input_text() { #{{{
    if [[ $AUTOMATIC_MODE -eq 1 ]]; then
      OPTION=$2
    else
      read -p "$1 [y/N]: " OPTION
      echo ""
    fi
    OPTION=`echo "$OPTION" | tr '[:upper:]' '[:lower:]'`
  } #}}}
  read_input_options() { #{{{
    local line
    local packages
    if [[ $AUTOMATIC_MODE -eq 1 ]]; then
      array=("$1")
    else
      read -p "$prompt2" OPTION
      array=("$OPTION")
    fi
    for line in ${array[@]/,/ }; do
      if [[ ${line/-/} != $line ]]; then
        for ((i=${line%-*}; i<=${line#*-}; i++)); do
          packages+=($i);
        done
      else
        packages+=($line)
      fi
    done
    OPTIONS=("${packages[@]}")
  } #}}}
  print_line() { #{{{
    printf "%$(tput cols)s\n"|tr ' ' '-'
  } #}}}
  print_title() { #{{{
    clear
    print_line
    echo -e "# ${Bold}$1${Reset}"
    print_line
    echo ""
  } #}}}
  print_info() { #{{{
    #Console width number
    T_COLS=`tput cols`
    echo -e "${Bold}$1${Reset}\n" | fold -sw $(( $T_COLS - 18 )) | sed 's/^/\t/'
  } #}}}
  print_warning() { #{{{
    T_COLS=`tput cols`
    echo -e "${BYellow}$1${Reset}\n" | fold -sw $(( $T_COLS - 1 ))
  } #}}}
  print_danger() { #{{{
    T_COLS=`tput cols`
    echo -e "${BRed}$1${Reset}\n" | fold -sw $(( $T_COLS - 1 ))
  } #}}}
  start_module() { #{{{
    modprobe $1
  } #}}}
  add_module() { #{{{
    for module in $1; do
      #check if the name of the module can be the same of the module or the given name
      [[ $# -lt 2 ]] && local _module_name="$module" || local _module_name="$2"
      local _has_module=`cat /etc/modules-load.d/${_module_name}.conf 2>&1 | grep $module`
      [[ -z $_has_module ]] && echo "$module" >> /etc/modules-load.d/${_module_name}.conf
      start_module "$module"
    done
  } #}}}
  add_repository() { #{{{
    local _repo=${1}
    local _url=${2}
    [[ -n ${3} ]] && local _siglevel="\nSigLevel = ${3}" || local _siglevel=""

    local _check_repo=`grep -F "${_repo}" /etc/pacman.conf`
    if [[ -z $_check_repo ]]; then
      echo -e "\n[${_repo}]${_siglevel}\nServer = ${_url}" >> /etc/pacman.conf
      system_update
    fi
  } #}}}
  check_multilib(){ #{{{
    # this option will avoid any problem with packages install
    if [[ $ARCHI == x86_64 ]]; then
      local _has_multilib=`grep -n "\[multilib\]" /etc/pacman.conf | cut -f1 -d:`
      if [[ -z $_has_multilib ]]; then
        echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
        echo -e '\nMultilib repository added into pacman.conf file'
      else
        sed -i "${_has_multilib}s/^#//" /etc/pacman.conf
        local _has_multilib=$(( ${_has_multilib} + 1 ))
        sed -i "${_has_multilib}s/^#//" /etc/pacman.conf
      fi
    fi
  } #}}}
  add_key() { #{{{
    pacman-key -r $1
    pacman-key --lsign-key $1
  } #}}}
  pacman_key(){ #{{{
    if [[ ! -d /etc/pacman.d/gnupg ]]; then
      print_title "PACMAN KEY - https://wiki.archlinux.org/index.php/pacman-key"
      print_info "Pacman uses GnuPG keys in a web of trust model to determine if packages are authentic."
      package_install "haveged"
      haveged -w 1024
      pacman-key --init
      pacman-key --populate archlinux
      pkill haveged
      package_remove "haveged"
    fi
  } #}}}
  add_line() { #{{{
    local _add_line=${1}
    local _filepath=${2}

    local _has_line=`grep -ci "${_add_line}" ${_filepath} 2>&1`
    [[ $_has_line -eq 0 ]] && echo "${_add_line}" >> ${_filepath}
  } #}}}
  replace_line() { #{{{
    local _search=${1}
    local _replace=${2}
    local _filepath=${3}
    local _filebase=`basename ${3}`

    sed -e "s/${_search}/${_replace}/" ${_filepath} > /tmp/${_filebase} 2>"$LOG"
    if [[ ${?} -eq 0 ]]; then
      mv /tmp/${_filebase} ${_filepath}
    else
      cecho "failed: ${_search} - ${_filepath}"
    fi
  } #}}}
  update_early_modules() { #{{{
    local _new_module=${1}
    local _current_modules=`egrep ^MODULES= /etc/mkinitcpio.conf`

    if [[ -n ${_new_module} ]]; then
      # Determine if the new module is already listed.
      local _exists=`echo ${_current_modules} | grep ${_new_module}`
      if [ $? -eq 1 ]; then

        source /etc/mkinitcpio.conf
        if [[ -z ${MODULES} ]]; then
          _new_moduleS="${_new_module}"
        else
          _new_moduleS="${MODULES} ${_new_module}"
        fi
        replace_line "MODULES=\"${MODULES}\"" "MODULES=\"${_new_moduleS}\"" /etc/mkinitcpio.conf
        ncecho " ${BBlue}[${Reset}${Bold}X${BBlue}]${Reset} Rebuilding init "
        mkinitcpio -p linux >>"$LOG" 2>&1 &
        pid=$!;progress $pid
      fi
    fi
  } #}}}
  is_package_installed() { #{{{
    #check if a package is already installed
    for PKG in $1; do
      pacman -Q $PKG &> /dev/null && return 0;
    done
    return 1
  } #}}}
  checkbox() { #{{{
    #display [X] or [ ]
    [[ "$1" -eq 1 ]] && echo -e "${BBlue}[${Reset}${Bold}X${BBlue}]${Reset}" || echo -e "${BBlue}[ ${BBlue}]${Reset}";
  } #}}}
  checkbox_package() { #{{{
    #check if [X] or [ ]
    is_package_installed "$1" && checkbox 1 || checkbox 0
  } #}}}
  aui_download_packages() { #{{{
    for PKG in $1; do
      #exec command as user instead of root
      su - ${username} -c "
        [[ ! -d aui_packages ]] && mkdir aui_packages
        cd aui_packages
        curl -o ${PKG}.tar.gz https://aur.archlinux.org/cgit/aur.git/snapshot/${PKG}.tar.gz
        tar zxvf ${PKG}.tar.gz
        rm ${PKG}.tar.gz
        cd ${PKG}
        makepkg -csi --noconfirm
      "
    done
  } #}}}
  aur_package_install() { #{{{
    su - ${username} -c "sudo -v"
    #install package from aur
    for PKG in $1; do
      if ! is_package_installed "${PKG}" ; then
        if [[ $AUTOMATIC_MODE -eq 1 ]]; then
          ncecho " ${BBlue}[${Reset}${Bold}X${BBlue}]${Reset} Installing ${AUR} ${Bold}${PKG}${Reset} "
          su - ${username} -c "${AUR_PKG_MANAGER} --noconfirm -S ${PKG}" >>"$LOG" 2>&1 &
          pid=$!;progress $pid
        else
          su - ${username} -c "${AUR_PKG_MANAGER} -S ${PKG}"
        fi
      else
        if [[ $VERBOSE_MODE -eq 0 ]]; then
          cecho " ${BBlue}[${Reset}${Bold}X${BBlue}]${Reset} Installing ${AUR} ${Bold}${PKG}${Reset} success"
        else
          echo -e "Warning: ${PKG} is up to date --skipping"
        fi
      fi
    done
  } #}}}
  package_install() { #{{{
    #install packages using pacman
    if [[ $AUTOMATIC_MODE -eq 1 || $VERBOSE_MODE -eq 0 ]]; then
      for PKG in ${1}; do
        local _pkg_repo=`pacman -Sp --print-format %r ${PKG} | uniq | sed '1!d'`
        case $_pkg_repo in
          "core")
            _pkg_repo="${BRed}${_pkg_repo}${Reset}"
            ;;
          "extra")
            _pkg_repo="${BYellow}${_pkg_repo}${Reset}"
            ;;
          "community")
            _pkg_repo="${BGreen}${_pkg_repo}${Reset}"
            ;;
          "multilib")
            _pkg_repo="${BCyan}${_pkg_repo}${Reset}"
            ;;
        esac
        if ! is_package_installed "${PKG}" ; then
          ncecho " ${BBlue}[${Reset}${Bold}X${BBlue}]${Reset} Installing (${_pkg_repo}) ${Bold}${PKG}${Reset} "
          pacman -S --noconfirm --needed ${PKG} >>"$LOG" 2>&1 &
          pid=$!;progress $pid
        else
          cecho " ${BBlue}[${Reset}${Bold}X${BBlue}]${Reset} Installing (${_pkg_repo}) ${Bold}${PKG}${Reset} exists "
        fi
      done
    else
      pacman -S --needed ${1}
    fi
  } #}}}
  package_remove() { #{{{
    #remove package
    for PKG in ${1}; do
      if is_package_installed "${PKG}" ; then
        if [[ $AUTOMATIC_MODE -eq 1 || $VERBOSE_MODE -eq 0 ]]; then
          ncecho " ${BBlue}[${Reset}${Bold}X${BBlue}]${Reset} Removing ${Bold}${PKG}${Reset} "
          pacman -Rcsn --noconfirm ${PKG} >>"$LOG" 2>&1 &
          pid=$!;progress $pid
        else
         pacman -Rcsn ${PKG}
        fi
      fi
    done
  } #}}}
  system_update() { #{{{
    pacman -Sy
  } #}}}
  npm_install() { #{{{
    #install packages using pacman
    npm install -g $1
  } #}}}
  gem_install() { #{{{
    #install packages using pacman
    for PKG in ${1}; do
      sudo -u ${username} gem install -V $PKG
    done
  } #}}}
  contains_element() { #{{{
    #check if an element exist in a string
    for e in "${@:2}"; do [[ $e == $1 ]] && break; done;
  } #}}}
  config_xinitrc() { #{{{
    #create a xinitrc file in home user directory
    cp -fv /etc/X11/xinit/xinitrc /home/${username}/.xinitrc
    echo -e "exec $1" >> /home/${username}/.xinitrc
    chown -R ${username}:users /home/${username}/.xinitrc
  } #}}}
  invalid_option() { #{{{
    print_line
    echo "Invalid option. Try another one."
    pause_function
  } #}}}
  pause_function() { #{{{
    print_line
    if [[ $AUTOMATIC_MODE -eq 0 ]]; then
      read -e -sn 1 -p "Press enter to continue..."
    fi
  } #}}}
  menu_item() { #{{{
    #check if the number of arguments is less then 2
    [[ $# -lt 2 ]] && _package_name="$1" || _package_name="$2";
    #list of chars to remove from the package name
    local _chars=("Ttf-" "-bzr" "-hg" "-svn" "-git" "-stable" "-icon-theme" "Gnome-shell-theme-" "Gnome-shell-extension-");
    #remove chars from package name
    for char in ${_chars[@]}; do _package_name=`echo ${_package_name^} | sed 's/'$char'//'`; done
    #display checkbox and package name
    echo -e "$(checkbox_package "$1") ${Bold}${_package_name}${Reset}"
  } #}}}
  mainmenu_item() { #{{{
    #if the task is done make sure we get the state
    if [ $1 == 1 -a "$3" != "" ]; then
      state="${BGreen}[${Reset}$3${BGreen}]${Reset}"
    fi
    echo -e "$(checkbox "$1") ${Bold}$2${Reset} ${state}"
  } #}}}
  system_ctl() { #{{{
    local _action=${1}
    local _object=${2}
    ncecho " ${BBlue}[${Reset}${Bold}X${BBlue}]${Reset} systemctl ${_action} ${_object} "
    systemctl ${_action} ${_object} >> "$LOG" 2>&1
    pid=$!;progress $pid
  }
  #}}}
  arch_chroot() { #{{{
    arch-chroot $MOUNTPOINT /bin/bash -c "${1}"
  }
  #}}}
  run_as_user() { #{{{
    sudo -H -u ${username} ${1}
  }
  #}}}
  add_user_to_group() { #{{{
    local _user=${1}
    local _group=${2}

    if [[ -z ${_group} ]]; then
      error_msg "ERROR! 'add_user_to_group' was not given enough parameters."
    fi

    ncecho " ${BBlue}[${Reset}${Bold}X${BBlue}]${Reset} Adding ${Bold}${_user}${Reset} to ${Bold}${_group}${Reset} "
    groupadd ${_group} >>"$LOG" 2>&1 &
    gpasswd -a ${_user} ${_group} >>"$LOG" 2>&1 &
    pid=$!;progress $pid
  } #}}}
  setlocale() { #{{{
    local _locale_list=(`cat /etc/locale.gen | grep UTF-8 | sed 's/\..*$//' | sed '/@/d' | awk '{print $1}' | uniq | sed 's/#//g'`);
    PS3="$prompt1"
    echo "Select locale:"
    select LOCALE in "${_locale_list[@]}"; do
      if contains_element "$LOCALE" "${_locale_list[@]}"; then
        LOCALE_UTF8="${LOCALE}.UTF-8"
        break
      else
        invalid_option
      fi
    done
  }
  #}}}
  settimezone() { #{{{
    local _zones=(`timedatectl list-timezones | sed 's/\/.*$//' | uniq`)
    PS3="$prompt1"
    echo "Select zone:"
    select ZONE in "${_zones[@]}"; do
      if contains_element "$ZONE" "${_zones[@]}"; then
        local _subzones=(`timedatectl list-timezones | grep ${ZONE} | sed 's/^.*\///'`)
        PS3="$prompt1"
        echo "Select subzone:"
        select SUBZONE in "${_subzones[@]}"; do
          if contains_element "$SUBZONE" "${_subzones[@]}"; then
            break
          else
            invalid_option
          fi
        done
        break
      else
        invalid_option
      fi
    done
  } #}}}
#}}}

setup_bluetooth() {
    sudo pacman -S --noconfirm bluez bluez-utils pulseaudio-bluetooth bluez-libs
    sudo systemctl enable bluetooth.service

    # In case of problems, list audio devices with ```pactl list cards | less``` and make sure a2dp sink is enabled.
    # Select the "High Fidelity" profile using pavucontrol

    # Fix: When using GDM, another instance of PulseAudio is started, which "captures" your bluetooth device
    # connection. This can be prevented by masking the pulseaudio socket for the GDM user by doing the following:
    sudo mkdir -p ~gdm/.config/systemd/user
    sudo ln -s /dev/null ~gdm/.config/systemd/user/pulseaudio.socket
}

configure_network() {
    WIRELESS_DEV=$(ip link | grep wlp | awk '{print $2}'| sed 's/://' | sed '1!d')
    if [[ -n $WIRELESS_DEV ]]; then
        pacstrap ${MOUNTPOINT} iw wireless_tools wpa_supplicant dialog
    fi

    WIRED_DEV=$(ip link | grep "ens\|eno\|enp" | awk '{print $2}'| sed 's/://' | sed '1!d')
    if [[ -n $WIRED_DEV ]]; then
        arch_chroot "systemctl enable dhcpcd@${WIRED_DEV}.service"
    fi

    # Setup short timeout for dhcpcd so it won't search so long for interfaces not connected during boot
    mkdir -p /mnt/etc/systemd/system/dhcpcd@.service.d
    echo "[Service]" > /mnt/etc/systemd/system/dhcpcd@.service.d/timeout.conf
    echo "ExecStart=" >> /mnt/etc/systemd/system/dhcpcd@.service.d/timeout.conf
    echo "ExecStart=/usr/bin/dhcpcd -w -q -t 3 %I" >> /mnt/etc/systemd/system/dhcpcd@.service.d/timeout.conf
}

# do not break the script when passwords do not match
failsafe_arch_chroot_passwd() {
    set +e
    RET=1
    while [ $RET != 0 ]
    do
        arch_chroot "passwd $1"
        RET=$?
        if [ $RET != 0 ]; then
            sleep 3
        fi
    done
    set -e
}

configure_existing_user() {
    print_info "Enter password for user $1:"
    failsafe_arch_chroot_passwd "$1"

    URL_ZSHRC="https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/cfg/_zshrc"

    if [ "$1" == "root" ]; then
        curl -L $URL_ZSHRC --output /mnt/root/.zshrc
        arch_chroot "chown $1:$1 /$1/.zshrc"
    else
        curl -L $URL_ZSHRC --output "/mnt/home/$1/.zshrc"
        arch_chroot "chown $1:users /home/$1/.zshrc"
        arch_chroot "usermod -aG network $1"
        arch_chroot "usermod -aG wheel $1"
    fi

    arch_chroot "chsh -s /usr/bin/zsh $1"
}

bail_on_missing_yay() {
    which yay > /dev/null

    if [ "$?" == "1" ]; then
        print_danger "Requires yay."
        exit 1
    fi
}

bail_on_root() {
    if [ "${USER}" == "root" ]; then
        print_danger "This script is supposed to be run as a user, not as root."
        exit 1
    fi
}

bail_on_user() {
    if [ "${USER}" != "root" ]; then
        print_danger "This script is supposed to be run as a root, not as user."
        exit 1
    fi
}

answer=""

# Ask user a question and read the input
function ask() {
	TITLE=$1
	BACK_TITLE=$2
	INPUT_BOX=$3
	DEFAULT=$4
	OUTPUT=$(mktemp)

	trap 'rm $OUTPUT; exit' SIGHUP SIGINT SIGTERM

	dialog --title "${TITLE}" \
	--backtitle "${BACK_TITLE}" \
	--inputbox "${INPUT_BOX} " 8 60 "${DEFAULT}" 2>"$OUTPUT"

	ask_result=$?
	# shellcheck disable=SC2034
    answer=$(<"$OUTPUT")

	return $ask_result
}

#ask  "System Setup"  "System Setup" "Enter a user name" "sdouser"
#
#case $ask_result in
#  0)
#  	echo "${answer} "
#  	;;
#  1)
#  	echo "Cancel pressed."
#  	;;
#  255)
#   echo "[ESC] key pressed."
#esac
#
#[[ -f "${OUTPUT}" ]] && rm "${OUTPUT}"