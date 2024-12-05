#!/usr/bin/env bash

# Notes:
# https://www.truenas.com/community/threads/script-to-control-fan-speed-in-response-to-hard-drive-temperatures.41294/
# https://forums.servethehome.com/index.php?resources/supermicro-x9-x10-x11-fan-speed-control.20/
# https://blog.pcfe.net/hugo/posts/2018-08-14-epyc-ipmi-fans/

if [ "$EUID" -ne 0 ]; then
  echo "ERROR: this tool uses ipmitool which must be run as root"
  exit
fi

__help="
Usage: $(basename "${0}") [COMMAND]

$(basename "${0}") bmc-reset [warm|cold]
$(basename "${0}") speed [0|1] [SPEED]

Commands:
  list             List the current status of all sensors.
  status           Returns the current fan state.
  standard         Standard mode. BMC controls both fan zones. CPU zone based on CPU temp with target speed 50%, peripheral zone based on PCH temp (target speed 50%).
  full (1):        Full mode. All fans running at 100%.
  optimal (2):     Optimal mode. BMC controls the CPU zone (target speed 30%), peripheral zone fixed at 30%.
  heavyio (4):     BMC control of the CPU zone (target speed 50%), peripheral zone fixed at 75%.
  bmc-reset        Resets the BMC if fan zones stop being controllable. Can be either a warm or cold reset.
  speed            Sets a zone to a specific fan speed percentage. Zones are either 0 or 1.
"

# bmc_reset has two options: warm and cold. If anything other than cold is
#  specified, do a warm reset.
bmc_reset() {
  if [ "${1}" == "cold" ]; then
    local reset_level="cold"
  else
    local reset_level="warm"
  fi
  echo "Doing a ${reset_level} reset of the BMC..."
  ipmitool bmc reset $reset_level
}

set_speed() {
  # zone
  echo "${1}"

  # speed
  echo "${2}"

  # Choose fan zone to be set
  if [ "${1}" == "0" ]; then
    local fan_zone=0x00
  elif [ "${1}" == "1" ]; then
    local fan_zone=0x01
  fi

  # Choose fan speed to be set
  if [ "${2}" == "25" ] ; then
    local fan_speed=0x16
  elif [ "${2}" == "50" ] ; then
    local fan_speed=0x32
  else
    local fan_speed=0x64
  fi

  if [ -z ${fan_zone+x} ]; then
    echo "ERROR: missing fan zone"
    echo "${__help}"
    return
  fi

  echo "Setting fan zone ${fan_zone} to ${fan_speed}"
  ipmitool raw 0x30 0x70 0x66 0x01 "${fan_zone}" 0x16 # 25%
  #ipmitool raw 0x30 0x70 0x66 0x01 "${fan_zone}" 0x32 # 50%
}

if [ -z ${1+x} ]; then
  echo "${__help}"
fi

if [ "${1}" == "help" ]; then
  echo "${__help}"
elif [ "${1}" == "list" ]; then
  ipmitool sensor list all
elif [ "${1}" == "status" ]; then
  ipmitool raw 0x30 0x45 0x00
elif [ "${1}" == "standard" ]; then
  echo "Setting to Standard mode..."
  ipmitool raw 0x30 0x45 0x01 0x00
elif [ "${1}" == "full" ]; then
  echo "Setting to Full mode..."
  ipmitool raw 0x30 0x45 0x01 0x01
elif [ "${1}" == "optimal" ]; then
  echo "Setting to Optimal mode..."
  ipmitool raw 0x30 0x45 0x01 0x02
elif [ "${1}" == "heavyio" ]; then
  echo "Setting to Heavy IO mode..."
  ipmitool raw 0x30 0x45 0x01 0x04
elif [ "${1}" == "minimal" ]; then
  echo "Setting to full mode and minimal fan speeds..."
  ipmitool raw 0x30 0x45 0x01 0x01
  ipmitool raw 0x30 0x70 0x66 0x01 0x00 0x10
  ipmitool raw 0x30 0x70 0x66 0x01 0x01 0x10
elif [ "${1}" == "bmc-reset" ]; then
  bmc_reset "${2}"
elif [ "${1}" == "speed" ]; then
  set_speed "${2}"
fi
