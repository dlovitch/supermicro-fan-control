# supermicro-fan-control
Really simple bash script to manage Supermicro fan speed.

Note: this command must be run with root privileges as it uses `ipmitool`.

```
Usage: supermicro-fan-control.sh [COMMAND]

supermicro-fan-control.sh bmc-reset [warm|cold]
supermicro-fan-control.sh speed [0|1] [SPEED]

Commands:
  list             List the current status of all sensors.
  status           Returns the current fan state.
  standard         Standard mode. BMC controls both fan zones. CPU zone based on CPU temp with target speed 50%, peripheral zone based on PCH temp (target speed 50%).
  full (1):        Full mode. All fans running at 100%.
  optimal (2):     Optimal mode. BMC controls the CPU zone (target speed 30%), peripheral zone fixed at 30%.
  heavyio (4):     BMC control of the CPU zone (target speed 50%), peripheral zone fixed at 75%.
  bmc-reset        Resets the BMC if fan zones stop being controllable. Can be either a warm or cold reset.
  speed            Sets a zone to a specific fan speed percentage. Zones are either 0 or 1.
```
