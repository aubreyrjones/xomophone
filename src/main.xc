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

out port led = PORT_LED;

void error(out port leds){
	leds <: 0b1000;
	while (1){};
}

void delay_us(timer t, unsigned us){
	unsigned time;

	t :> time;

	while (us){
		time += 100;
		t when timerafter(time) :> void;
		--us;
	}
}

int main() {
	timer t;

	led <: 0b0001;

	delay_us(t, 500000);

	led <: 0b0011;

	//if (!dsp_control_write(DSP_CONTROL, 0x0c, 0)) //power up
		//error(led);
	/*if (!dsp_control_write(DSP_CONTROL, 0x0e, 0x03 | 0b01000000))//set output mode
		error(led);
	if (!dsp_control_write(DSP_CONTROL, 0x10, 0xa0)) //set sample rate
		error(led);
	if (!dsp_control_write(DSP_CONTROL, 0x12, 0x01))
		error(led);*/

	led <: 0b0111;

	while (1){};
}

