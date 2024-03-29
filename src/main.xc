// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 ============================================================================
 Name        : $(sourceFile)
 Description : Illuminate an LED on the XK-1 card 
 ============================================================================
 */

#include <platform.h>
#include <xs1.h>
#include <math.h>
#include <print.h>
#include <xscope.h>
#include "codec/control.h"

out port led = PORT_LED;

void xscope_user_init(void){
	xscope_config_io(XSCOPE_IO_BASIC);
	xscope_register(3,
			XSCOPE_CONTINUOUS, "SPI - SCLK", XSCOPE_UINT, "D",
			XSCOPE_CONTINUOUS, "SPI - MOSI", XSCOPE_UINT, "D",
			XSCOPE_CONTINUOUS, "SPI - CSB", XSCOPE_UINT, "D");

}

CODEC_IF codec = {
		XS1_CLKBLK_1,
		XS1_CLKBLK_2,
		PORT_CODEC_SCLK,
		PORT_CODEC_MOSI,
		PORT_CODEC_CSB
};

void error(out port leds){
	leds <: 0b1000;
	while (1){};
}

void delay_us(timer t, unsigned us){
	unsigned time;

	t :> time;

	for (; us; --us){
		time += 100;
		t when timerafter(time) :> time;
		--us;
	}
}



int main() {
	timer t;

	codec_init_interface(codec);
	led <: 1;
	delay_us(t, 500000);

	codec_reset(codec);
	led <: 2;
	delay_us(t, 500000);

//#define LOOPIT
#ifdef LOOPIT
	while (1){
#endif

	codec_power_up(codec);
	led <: 3;
	delay_us(t, 250000);

#ifdef LOOPIT
		delay_us(t, 250000);
		delay_us(t, 250000);
		delay_us(t, 250000);
	}
#endif

	codec_setup(codec);
	led <: 4;
	delay_us(t, 250000);

	codec_start(codec);
	led <: 5;
	delay_us(t, 250000);

	while (1){};
}

