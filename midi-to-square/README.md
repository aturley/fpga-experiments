# MIDI to Square

## Objective

The FPGA receives [MIDI note on
messages](http://www.gweep.net/~prefect/eng/reference/protocol/midispec.html),
and plays a square wave of the corresponding frequency.

## Current status

The system reads from the pin that is connected to the FTDI
USB-to-serial device at 9600 baud and puts out the signal on one of
the LED pins on the board. This facilitates testing to make sure that
the logic is right before moving on to hardware.

It listens for MIDI note on commands and turns the LED on or off
depending on whether or not the velocity of the note is greater than
zero.