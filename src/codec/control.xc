/*
 * dsp_control.xc
 *
 *  Created on: Feb 2, 2013
 *      Author: netzapper
 */

#include "control.h"
#include <xclib.h>
#include <xscope.h>
#define CLOCK_VAL 0b01010101

void codec_init_interface(CODEC_IF& codec_if){
	configure_clock_rate(codec_if.clk, 100, 400);
	configure_out_port(codec_if.sclk, codec_if.clk, 0);
	configure_out_port(codec_if.csb, codec_if.clk, 1);


	configure_clock_src(codec_if.dataClk, codec_if.sclk);
	configure_out_port(codec_if.mosi, codec_if.dataClk, 0);


	clearbuf(codec_if.sclk);
	clearbuf(codec_if.mosi);
	codec_if.csb <: 1;
	xscope_probe_data(2, 100);
	start_clock(codec_if.clk);
	start_clock(codec_if.dataClk);
}

void codec_set_register(CODEC_IF& codec_if, unsigned char reg, unsigned short value){
	unsigned outbuf;
	outbuf = reg;
	outbuf <<= 9; //shift left by size of dataword
	outbuf |= value & 0x1ff;

	outbuf = bitrev(outbuf) >> 16; //swap to MSbit first order, shift into proper port alignment

	clearbuf(codec_if.mosi);
	clearbuf(codec_if.sclk);

	codec_if.sclk <: CLOCK_VAL;
	sync(codec_if.sclk);
	codec_if.csb <: 0;
	codec_if.mosi <: >> outbuf;
	codec_if.sclk <: CLOCK_VAL; //clock 4 bits
	codec_if.sclk <: CLOCK_VAL; //clock 4 bits

	codec_if.mosi <: >> outbuf;
	codec_if.sclk <: CLOCK_VAL; //clock 4 bits
	codec_if.sclk <: CLOCK_VAL; //clock 4 bits

	sync(codec_if.sclk);
	codec_if.csb <: 1; //latch in data
	codec_if.sclk <: CLOCK_VAL; //let the csb sit there for another 4 bits
	codec_if.sclk <: 0;

	clearbuf(codec_if.mosi);
}

void codec_reset(CODEC_IF& codec_if){
	codec_set_register(codec_if, 0b1111, 0);
}

void codec_power_up(CODEC_IF& codec_if){
	//power up everything except the crystal oscillator and CLKOUT.
	//this is because we use the self-contained digital clock.
	codec_set_register(codec_if, 0b110, 0b011000000);
}

void codec_setup(CODEC_IF& codec_if){

	//set headphones
	codec_set_register(codec_if, 0b10, 0b101111001);

	//set up analog path, basically just turn on DAC, disable bypass and sideband.
	codec_set_register(codec_if, 0b100, 0b00010010);

	//set deemphasis filter, disable dac mute
	codec_set_register(codec_if, 0b101, 0b00110);

	//enable master mode, 16-bit samples, and dsp transfer style
	codec_set_register(codec_if, 0b111, 0b01000011);

	//set unity clock dividers, 48kHz sample both directions, BOSR setting for ~18MHz MCLK.
	codec_set_register(codec_if, 0b1000, 0b00000010);

}

void codec_start(CODEC_IF& codec_if){
	//activate sampling
	codec_set_register(codec_if, 0b1001, 1);
}
