# MIDI to Square

## Objective

The FPGA receives [MIDI note on
messages](http://www.gweep.net/~prefect/eng/reference/protocol/midispec.html),
and plays a square wave of the corresponding frequency.

## Current status

The system reads MIDI note on messages from pin 119; if the note is
between 24 and 120 (inclusive) and the velocity is greater than 0 then
the note is played using by generating a 50% duty cycle square wave on
pin 44.

The built-in serial port on pin 9 can also be used at 9600 baud by
changing the Verilog source file and using the `m2s-serial.pcf` file.