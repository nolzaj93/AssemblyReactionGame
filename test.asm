/*
 * TestHardware.asm
 *
 *  Created: 9/15/2014 11:20:28 AM
 *   Author: fgonzalez
 */ 

//	All Data Direcetion registers are set as input by default.

//	LED <-0 => on
//	LED <-1 => off
//	SWITCH pressed => 1
//	SWITCH up => 0

// The XMEGA-A3BU-XPlained board has the following:

//	PORT D(4)	LED (red)
//	PORT R(0)	LED (yellow bottom)
//	PORT R(1)	LED (Yellow top)
//	PORT E(5)	SWITCH (#1 top left)
//	PORT F(1)	SWITCH (#2)
//	PORT F(2)	SWITCH (#3)
//
// XMegaA3BU properties:
// SRAM starts on location 2000h.

// LED on A-4
// This program turns on the 2 yellow LED. While the top left button is pressed it turns off the LEDs.

 			.include	<atxmega256a3budef.inc>
			.CSEG
			.ORG		0x00
			JMP			start

			.ORG		0xF6
start:		
			LDI			R16,0xFF			; Set pins A4 of port A as output
			STS			PORTA_DIR,R16		;				*

			LDI			R17,0b00010000		; turn on the LED
			STS			PORTA_OUT,R17		;				*

			LDI			R16,0x03			; Set pins 0 & 1 of port R as output
			STS			PORTR_DIR,R16		;				*

			LDI			R17,0b00000011		; turn off the two yellow LEDs
			STS			PORTR_OUT,R17		;				*

loop:		LDS			R16,PORTE_IN		; Check to see if the button is pressed
			ANDI		R16,0b00100000		;				*
			BREQ		else				; if it is pressed then 
			LDI			R17,0b00000000		;	turn on the LEDs
			STS			PORTR_OUT,R17		;				*
			LDS			R17,PORTA_IN		;   turn on A4 LED
			ORI			R17,0b00010000		;				*
			STS			PORTA_OUT,R17		;				*
			JMP			endif				; else
else:		LDI			R17,0b00000011		;	turn off the LEDs
			STS			PORTR_OUT,R17		;				*
			LDS			R17,PORTA_IN		;   turn off A4 LED
			ANDI		R17,0b11101111		;				*
			STS			PORTA_OUT,R17		;				*
endif:		JMP			LOOP				; and loop

here:		RJMP		here				; do nothing forever

