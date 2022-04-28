# RC Discharge Pot

## Overview

Measure the position of a potentiomenter using an RC circuit.

The circuit looks like this:

```
                 220 Ohm
CHARGE_PIN ==>----/\/\/\------o-----o-----<== READ_PIN
                              |     |
                              |     /
                              -     \<-- 10k Ohm
                       4.7 uF -     /
                              |     \
                              |     |
                              o-----o----> GND
```

The Verilog implements the following steps:
* set the `CHARGE_PIN` high long enough that the RC circuit is fully charged
* set the `CHARGE_PIN` to high-impedence
* measure how long it takes for `READ_PIN` to read 0

The ammount of time it takes for `READ_PIN` to go from 1 to 0 is
directly proportional to the value of the potentiomenter.