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
//	PORT E(5)	SWITCH (#1 top left)
//	PORT F(1)	SWITCH (#2)
//	PORT F(2)	SWITCH (#3)

//	PORT A(3)	LCD Reset bar
//	PORT F(3)	LCD CS bar
//	PORT D(0)	LCD AO line
//	PORT D(1)	LCD XCK
//	PORT D(3)	LCD TX 
//	PORT E(4)	LCD back light (1 = on, 0 = off)
	
        .cseg
	.org	0x00		; reset
	jmp	start
	
        ;set interrupt vector table 
	; entry for button pushed
	.org PORTE_INT0_vect
	; interrupt for button press
	jmp ButtonPressed_ISR
        ; on PortE - pin 1
	
	.org	0x1000
start:   
    
        .def tmp = r16
	; intialize stack pointer
	ldi tmp,low(RAMEND)
	; init SP
	out CPU_SPL,tmp   
	ldi tmp,high(RAMEND)

	out CPU_SPH,tmp  
	
	; setup port-e pin 0 as output and pin 1 as input
	lds tmp,PORTE_DIR
; do not change other pins
	andi tmp,0b11111101
; pin-1 -> 0=input
	ori tmp,0b00000001
; pin-0 -> 1=output
	sts PORTE_DIR,tmp

; enable priority levels low, medium, and high
	ldi tmp,0xd8
; enbable config register changes
	sts CPU_CCP,tmp

	ldi tmp,0b00000111
; high/med/low
	sts PMIC_CTRL,tmp

; set port-e pin-1 to pull-down and sense rising edge
	ldi tmp,0b00010001
; 00 - OPC:010=pulldown - ISC:001=rising
	
	sts PORTE_PIN1CTRL,tmp
; "
; enable interrupt-0 from port-e as medium level priority
	ldi tmp,0b00000010
; medium priority
	sts PORTE_INTCTRL,tmp
; interrupt 0
; map port-e pin-1 to use interrupt-0 mask
	ldi tmp,0b00000010
; set pin 1 in int-0 mask
	sts PORTE_INT0MASK,tmp
; "
	sei
; enable global interrupts
	
	//Listen for sw0 pressed 
	// if sw0 pressed, call startGame
	
startGame:
	// Flash Red LED 3x, output countdown to LCD if we can
	
	// Turn LED to Green and solid, call calcReact
	
calcReact:
	//Listen for pressed sw1
	
	//Count time
	
	// if sw1 pressed, stop counter, call outputReact
	
outputReact:	
	// Output calculated reactionTime to LCD

	
end:	 rjmp end	

    
----------------------------------------------------------
; Interrupt Service Routine for button pressed:
; toggles an LED on port-e pin-0
;
; Notice the use of "reti" to return from an interrupt call
;----------------------------------------------------------
ButtonPressed_ISR:
	 push tmp
; save tmp register
	 lds tmp,PORTE_IN
; read port
	 sbrs tmp,0
; if bit 0 is set (1)
	 rjmp toggle_on
; then do not jump (go to toggle off)
; else go to toggle on 
toggle_off:
	 andi tmp,0b11111110
; set bit-0 off=0
	 rjmp set_led
toggle_on:
	 ori tmp,0b00000001
; set bit-0 on=1
set_led: 
	 sts PORTE_OUT,tmp
; toggle led
         pop tmp
; restore tmp regsiter
	 reti
; return from interrupt
