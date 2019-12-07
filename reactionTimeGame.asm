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
	.org PORTD_INT0_vect
					; interrupt for button press
	jmp GameButtonPressed_ISR

	.org TCF0_OVF_vect
	jmp timerISR
	
	.org PORTF_INT0_vect
	jmp reactButtonPressed_ISR
	
	
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
	
	//Setup Game interrupt
					; setup port-D pin 0 as output and pin 1 as input
	lds tmp,PORTD_DIR
					; do not change other pins
	andi tmp,0b11111101
					; pin-1 -> 0=input
	ori tmp,0b00000001
					; pin-0 -> 1=output
	sts PORTD_DIR,tmp

					; enable priority levels low, medium, and high
	ldi tmp,0xd8
					; enbable config register changes
	sts CPU_CCP,tmp

	ldi tmp,0b00000111		; high/med/low
	
	sts PMIC_CTRL,tmp
					; enable interrupt-0 from port-D as medium level priority
	ldi tmp,0b00000010
					; medium priority
	sts PORTD_INTCTRL,tmp
					; interrupt 0
					; map port-e pin-1 to use interrupt-0 mask
	ldi tmp,0b00000010
					; set pin 1 in int-0 mask
	sts PORTD_INT0MASK,tmp
	
					; set port-D pin-1 to pull-down and sense rising edge
	ldi tmp,0b00010001
					; 00 - OPC:010=pulldown - ISC:001=rising
	
	sts PORTD_PIN1CTRL,tmp
	
	sei
	
	// Setup timer interrupt
	ldi r16,0xD8
	sts CPU_CCP,r16
	ldi r16,0b00000111
	sts PMIC_CTRL,r16
	
	sei
	
	ldi r16,0b00000000
	sts TCF0_CTRLB,r16
	
	ldi r16,(low(12500))
	sts TCF0_PER,r16
	ldi r16, (high(12500))
	sts TCF0_PER + 1,r16
	
	ldi r16, 0b00000110
	sts TCF0_CTRLA,r16
	
	ldi r16,0b00000001
	sts TCF0_INTCTRLA,r16
	
	// Port F(1)
				    ; setup port-e pin 0 as output and pin 1 as input
	lds tmp,PORTF_DIR
				    ; do not change other pins
	andi tmp,0b11111101
				    ; pin-1 -> 0=input
	ori tmp,0b00000001
				    ; pin-0 -> 1=output
	sts PORTF_DIR,tmp

				    ; enable priority levels low, medium, and high
	ldi tmp,0xd8
				    ; enbable config register changes
	sts CPU_CCP,tmp

	ldi tmp,0b00000111	    ; high/med/low
	
	sts PMIC_CTRL,tmp

	sei
				    ; set port-F pin-1 to pull-down and sense rising edge
	ldi tmp,0b00010001	    ; 00 - OPC:010=pulldown - ISC:001=rising
	
	sts PORTF_PIN1CTRL,tmp      ; enable interrupt-0 from port-F as medium level priority
	ldi tmp,0b00000010          ; medium priority
	sts PORTF_INTCTRL,tmp
				    ; interrupt 0
				    ; map port-e pin-1 to use interrupt-0 mask
	ldi tmp,0b00000010
				    ;    set pin 1 in int-0 mask
	sts PORTF_INT0MASK,tmp
	
	
end:	 rjmp end	

    
; Interrupt Service Routine for button pressed:
; toggles an LED on port-e pin-0, then 
;
; Notice the use of "reti" to return from an interrupt call
;----------------------------------------------------------
GameButtonPressed_ISR:
	 push tmp
			    ; save tmp register
	 lds tmp,PORTD_IN
			    ; read port

			    ; set bit-0 off=0
toggle_on_green:
	 ori tmp,0b00100000
			    ; set bit-0 on=1
set_led_green: 
	 sts PORTD_OUT,tmp
			    ; toggle led
	 nop
	 nop
	 nop
	 nop
	 
toggle_off:
	 andi tmp,0b11111110	
set_led_off: 
	 sts PORTD_OUT,tmp	 
	 	 
         pop tmp
; restore tmp register
	 reti
; return from interrupt

	 
timerISR:
	 push tmp
	 lds tmp,count
	 inc tmp
	 sts count,tmp
	 
	 pop tmp
	 
	 reti
	 
reactButtonPressed_ISR:
         push tmp
	 lds tmp,PORTF_IN
	 sbrs tmp,1
	 reti
	 
	 lds r17,count
	 push r17
	 
	 pop tmp
	 
	 reti
