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
#include <pwm_singlebit_port.h>
#include <xscope.h>

//void xscope_user_init(void) {
//	xscope_register(1,
//				XSCOPE_CONTINUOUS, "GenOut",  XSCOPE_FLOAT, "mV");
//
//}


out port led = XS1_PORT_4F;

on stdcore[0] : out buffered port:32 pwmOut[] = {XS1_PORT_1A};
on stdcore[0] : clock clk = XS1_CLKBLK_1;

const unsigned SAMPLES_PER_SECOND = 44000;
const unsigned TICKS_PER_SAMPLE = 100000000 / 44000; //44kHz
const float SECONDS_PER_SAMPLE = 1.0f / 44000.0f;

void genTri(chanend c, timer genTimer, unsigned frequency, float amp){
	unsigned int values[] = {512};
	unsigned duty = 512;
	unsigned time = 0;
	unsigned halfPeriodCounter = 0;
	unsigned dutiesPerSample;
	char direction = 1;
	unsigned halfPeriodCount = SAMPLES_PER_SECOND / frequency / 2;

	if (halfPeriodCount == 0){
		halfPeriodCount = 1;
	}

	dutiesPerSample = amp / 512;

	genTimer :> time;
	while (1){
		time += TICKS_PER_SAMPLE;
		genTimer when timerafter(time) :> void;
		halfPeriodCounter++;
		if (direction){
			duty += dutiesPerSample;
		}
		else {
			duty -= dutiesPerSample;
		}
	}
}

void genSine(chanend c, timer genTimer, float frequency, float amp){
	float contTime = 0;
	float s = 0;
	unsigned int values[] = {512};
	unsigned duty = 512;

	unsigned time = 0;
	//xscope_probe_data_pred(0, s);
	genTimer :> time;
	while (1){
		time += TICKS_PER_SAMPLE;
		genTimer when timerafter(time) :> void;
		contTime += SECONDS_PER_SAMPLE;
		s = sinf(contTime * frequency) * amp;
		s = s * 512.0f;
		s += 512.0f;
		if (s < 0){
			s = 0.0f;
		}
		duty = (unsigned int) (s);
		values[0] = duty;
		if (values[0] >= 1024){
			values[0] = 1023;
		}
		pwmSingleBitPortSetDutyCycle(c, values, 1);
	}
}

int main() {
	par {
		on stdcore[0] : {
			chan c;
			timer genTimer;
			par {
				genSine(c, genTimer, 17.0f, 1.0f);
				//genTri(c, genTimer, 500, 128);
				pwmSingleBitPort(c, clk, pwmOut, 1, 1024, 5, 1);
			}
		}
	}
}

