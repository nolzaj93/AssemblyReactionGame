; Project: Reaction Time Game
;
; Created : 12/07/2019
; Authors : Ramzy El-Taher, Austin Nolz
; Purpose : Apply what we learned about in the course.
.include <ATxmega256A3BUdef.inc>

//	All Data Direcetion registers are set as input by default.

//	LED <-0 => on
//	LED <-1 => off
//	SWITCH pressed => 0
//	SWITCH up => 1

// The XMEGA-A3BU-XPlained board has the following:

//	PORT D(4)	LED (red)
//      PORT D(5)	LED (green)
//	PORT R(0)	LED (yellow bottom)
//	PORT R(1)	LED (Yellow top)
//	PORT E(5)	SWITCH (#0 top left)
//	PORT F(1)	SWITCH (#1)
//	PORT F(2)	SWITCH (#2)

//	PORT A(3)	LCD Reset bar
//	PORT F(3)	LCD CS bar
//	PORT D(0)	LCD AO line
//	PORT D(1)	LCD XCK
//	PORT D(3)	LCD TX 
//	PORT E(4)	LCD back light (1 = on, 0 = off)
	
	.dseg				; start a data segment
	.org	    0x2000
count:  .byte       1	
	
        .cseg
	.org	0x00			; reset
	jmp	start
	
					;set interrupt vector table 
					; entry for button pushed
	
	
	.org	0x1000
start:   
    
        .def tmp = r16
	clr  tmp
	sts  count,tmp

					; intialize stack pointer
	ldi tmp,low(RAMEND)
					; init SP
	out CPU_SPL,tmp   
	ldi tmp,high(RAMEND)

	out CPU_SPH,tmp  
	
checkForGameStart:
    
	lds tmp,PORTE_IN

	andi tmp,0b00100000		    ; check if sw0 is pressed
	breq checkForGameStart
	
startGame:	
    
	//we can sub with LCD code
	
toggle_on_red:	
	lds tmp,PORTD_IN

	andi tmp,0b11101111	    ; set bit-4 off = 0

set_led_red: 	
	sts PORTD_OUT,tmp

	nop
	nop
	nop
	nop
	
toggle_on_green:
	 ori tmp,0b00100000
			    ; set bit-5 on=1
set_led_green: 
	 sts PORTD_OUT,tmp
			    ; toggle led

	
	
end:	 rjmp start	
