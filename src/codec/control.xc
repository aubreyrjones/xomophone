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

	configure_clock_src(codec_if.dataClk, codec_if.sclk);
	configure_out_port(codec_if.mosi, codec_if.dataClk, 0);

	clearbuf(codec_if.sclk);
	clearbuf(codec_if.mosi);
	codec_if.csb <: 1;

	start_clock(codec_if.clk);
}

void codec_set_register(CODEC_IF& codec_if, unsigned char reg, unsigned short value){
	unsigned outbuf;
	outbuf = reg;
	outbuf <<= 9; //shift left by size of dataword
	outbuf |= value & 0x1ff;


	outbuf = bitrev(outbuf) >> 16; //swap to MSbit first order, shift into proper port alignment

	asm("setc res[%0], 8" :: "r"(codec_if.mosi)); // reset port

	codec_if.mosi <: outbuf;

	asm("setc res[%0], 8" :: "r"(codec_if.mosi)); // reset port
	asm("setc res[%0], 0x200f" :: "r"(codec_if.mosi)); // set to buffering
	asm("settw res[%0], %1" :: "r"(codec_if.mosi), "r"(8)); // set transfer width to 8

	configure_clock_src(codec_if.dataClk, codec_if.sclk);
	configure_out_port(codec_if.mosi, codec_if.dataClk, outbuf);
	start_clock(codec_if.dataClk);

	outbuf >>= 1;

	codec_if.csb <: 0;
	codec_if.mosi <: >> outbuf;
	codec_if.sclk <: CLOCK_VAL; //clock 4 bits
	codec_if.sclk <: CLOCK_VAL; //clock 4 bits

	codec_if.mosi <: >> outbuf;
	codec_if.sclk <: CLOCK_VAL; //clock 4 bits
	codec_if.sclk <: CLOCK_VAL; //clock 4 bits

	sync(codec_if.sclk);
	codec_if.csb <: 1; //latch in data
	//codec_if.sclk <: 0b10;

	//sync(codec_if.sclk);

	clearbuf(codec_if.mosi);
	stop_clock(codec_if.dataClk);
}

void codec_reset(CODEC_IF& codec_if){
	codec_set_register(codec_if, 0b1111, 0);
}

void codec_power_up(CODEC_IF& codec_if){
	//power up everything except the crystal oscillator and CLKOUT.
	//this is because we use a self-contained digital clock.
	codec_set_register(codec_if, 0b110, 0b011000000);
}

void codec_power_down(CODEC_IF& codec_if){
	codec_set_register(codec_if, 0b110, 0b010011111);
}

void codec_setup(CODEC_IF& codec_if){
	//enable master mode, 24-bit samples, and dsp transfer style
	codec_set_register(codec_if, 0b111, 0b01001011);

	//set unity clock dividers, 48kHz sample both directions, BOSR setting for ~18MHz MCLK.
	codec_set_register(codec_if, 0b1000, 0b00000010);

	//set headphones
	//codec_set_register(codec_if, 0b10, 0b101111001);

	//set up analog path, basically just turn on DAC, disable bypass and sideband.
	//codec_set_register(codec_if, 0b100, 0b00010010);

	//set deemphasis filter, disable dac mute
	//codec_set_register(codec_if, 0b101, 0b00110);
}

void codec_start(CODEC_IF& codec_if){
	//activate sampling
	codec_set_register(codec_if, 0b1001, 1);
}
