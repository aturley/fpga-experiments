# FPGA Serial Mirror

## Overview

This project will use an ICE40HX1K-STICK-EVN to receive incoming
serial data and send it back out.

Relevant information:
* RS232 pins
  * TX -- 9 (`PIO03_07`) -- `tx`
  * RX -- 10 (`PIO03_08`) -- `rx`
* Clock
  * freq -- 12MHz
  * pin -- 21 -- `clk`
* Reset
  * CRESET_B -- 66

I used [this UART module](https://github.com/cyrozap/osdvu/blob/d18488c41141cfb1c7b29f5a5840510e727ae5a2/uart.v).