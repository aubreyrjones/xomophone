/*
 * dsp_control.h
 *
 *  Created on: Feb 2, 2013
 *      Author: netzapper
 */

#ifndef DSP_CONTROL_H_
#define DSP_CONTROL_H_
#include <xs1.h>

typedef struct {
	clock clk;
	clock dataClk;
    out buffered port:8 sclk;
    out buffered port:8 mosi;
    out port csb;
} CODEC_IF;

/**
 * Initialize the CODEC control interface.
 * */
void codec_init_interface(CODEC_IF& codec_if);

/**
 * Set a CODEC register.
 * */
void codec_set_register(CODEC_IF& codec_if, unsigned char reg, unsigned short value);

void codec_reset(CODEC_IF& codec_if);

/**
 * Power up the CODEC.
 * */
void codec_power_up(CODEC_IF& codec_if);

/**
 * Set up the codec to do its job.
 * */
void codec_setup(CODEC_IF& codec_if);

/**
 * Start the codec.
 * */
void codec_start(CODEC_IF& codec_if);

#endif /* DSP_CONTROL_H_ */
