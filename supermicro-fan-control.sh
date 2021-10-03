#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
  echo "ERROR: this tool uses ipmitool which must be run as root"
  exit
fi

__help="
Usage: $(basename $0) [COMMAND]

Commands:
  standard         Standard mode. BMC controls both fan zones. CPU zone based on CPU temp with target speed 50%, peripheral zone based on PCH temp (target speed 50%).
  full (1):        Full mode. All fans running at 100%.
  optimal (2):     Optimal mode. BMC controls the CPU zone (target speed 30%), peripheral zone fixed at 30%.
  heavyio (4):     BMC control of the CPU zone (target speed 50%), peripheral zone fixed at 75%.
"

if [ -z ${1+x} ]; then
  echo "${__help}"
fi

if [ "${1}" == "help" ]; then
  echo "${__help}"
elif [ "${1}" == "check" ]; then
  ipmitool raw 0x30 0x45 0x00
elif [ "${1}" == "standard" ]; then
  echo "Setting to Standard mode..."
  ipmitool raw 0x30 0x45 0x01 0x00
elif [ "${1}" == "full" ]; then
  echo "Setting to Full mode..."
  ipmitool raw 0x30 0x45 0x01 0x00
elif [ "${1}" == "optimal" ]; then
  echo "Setting to Optimal mode..."
  ipmitool raw 0x30 0x45 0x01 0x00
elif [ "${1}" == "heavyio" ]; then
  echo "Setting to Heavy IO mode..."
  ipmitool raw 0x30 0x45 0x01 0x00
fi
