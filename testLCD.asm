/*
 * TestADC.asm
 *
 *  Created: 11/13/2014 11:35:48 AM
 *   Author: fgonzalez
 */ 


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
//
// XMegaA3BU properties:
// SRAM starts on location 2000h.
//
// There are 256K bytes of flash (program memory) 0 - 1EFFF (words)
// There are 16K bytes of SRAM (data memory) 2000 - 5FFF (bytes)
//
// header pin layout (top view) on XPlained
//
//  
//	2 4 6 8 10
//  <-header->
//  1 3 5 7 9
//
// external baord
// LED on A-4 (J2 pin 5)
// POT on A-5 (J2 pin 6) (ADC5)

// This program tests the LCD display by writting the numbers 0 through F in reverse order.


 				.include	<atxmega256a3budef.inc>
				.CSEG
				.ORG		0x00
				JMP			start

				.ORG		0xF6
start:		
				LDI			R16,low(RAMEND)			; initialize the stack
				STS			CPU_SPL,R16				;			*
				LDI			R16,high(RAMEND)		;			*
				STS			CPU_SPH,R16				;			*

				CALL		InitTheLCD				; Initialize the LCD
				CALL		LCDBackLightOff		
				CALL		LCDClearScreen

// your code can start here

// Draw "Hello" at colum 0, page 0
				LDI			R16,0					; colm. Set the row and colm to 0 each
				MOV			R0,R16
				LDI			R16,0					; row
				MOV			R1,R16
				RCALL		LCDSetCurser

				LDI			R16,'H'
				CALL		LCDWriteASCIIChar
				LDI			R16,'E'
				CALL		LCDWriteASCIIChar
				LDI			R16,'L'
				CALL		LCDWriteASCIIChar
				LDI			R16,'L'
				CALL		LCDWriteASCIIChar
				LDI			R16,'O'
				CALL		LCDWriteASCIIChar


// Draw "Hello" at colum 0, page 0
				LDI			R16,0					; colm. Set the row and colm to 0 each
				MOV			R0,R16
				LDI			R16,1					; row
				MOV			R1,R16
				RCALL		LCDSetCurser

				JMP			cont1
MyData:			.db			"HELLO",0
cont1:			LDI			ZL,low(MyData << 1)
				LDI			ZH,high(MyData << 1)
				CALL		LCDPrintf

// Draw a ball at colum 64, page 2
				LDI			R16,64					; colm. Set the row and colm to 0 each
				MOV			R0,R16
				LDI			R16,2					; row
				MOV			R1,R16
				RCALL		LCDSetCurser

				LDI			ZL,low(Ball << 1)		;			*
				LDI			ZH,high(Ball << 1)		;			*
				CALL		LCDDraw6ColmFig			

// Draw a box at colum 32, page 1
				LDI			R16,32					; colm. Set the row and colm to 0 each
				MOV			R0,R16
				LDI			R16,1					; row
				MOV			R1,R16
				RCALL		LCDSetCurser

				LDI			ZL,low(Box << 1)		;			*
				LDI			ZH,high(Box << 1)		;			*
				CALL		LCDDraw6ColmFig

// Draw the number 3 at colum 100, page 0
				LDI			R16,100					; colm. Set the row and colm to 0 each
				MOV			R0,R16
				LDI			R16,0					; row
				MOV			R1,R16
				RCALL		LCDSetCurser

				LDI			R16,4
				MOV			R0,R16
				RCALL		LCDWriteHexDigit		;    Write the hex digit in R0
								
				LDI			R16,5
				MOV			R0,R16
				RCALL		LCDWriteHexDigit		;    Write the hex digit in R0

done:			JMP			done	

// The data to draw may go here.
Ball:			.db			0x3C,0x7E,0xFF,0xFF,0x7E,0x3C
Box:			.db			0xFF,0xFF,0xFF,0xFF,0xFF,0xFF


// This routine tests the LCD by writting the numbers 0 through F on the top row of the LCD.

LCDTest:
				PUSH		R16						; ddd
				PUSH		R0

				LDI			R16,0					; row. Set the row and colm to 0 each
				MOV			R1,R16
				LDI			R16,0					; colm
				MOV			R0,R16
				RCALL		LCDSetCurser

				LDI			R16,15					; R0 = 15
				MOV			R0,R16
loop2:												; while R0 >= 0

				RCALL		LCDWriteHexDigit		;    Write the hex digit in R0
				DEC			R0						;	 R0 = R0 - 1
				BRNE		loop2					; end while
				RCALL		LCDWriteHexDigit		; Write the last hex digit R0 == 0
	
				POP			R0
				POP			R16
				RET


		
// ***********************************************************************************
// *                  LCD Public functions. Call these functions but do not modefy   *
// ***********************************************************************************

// Performs all LCD initialization.
InitTheLCD:		CALL		SetCpuClockTo32MInt
				CALL		LCDSetupUsartSpiPins
				CALL		LCDSetupSPIOnUARTD0
				CALL		LCDReset
				CALL		LCDInit
				RET

// Possitions the curser in the LCD. 
// input:	R0 = colm			(0 ... 131)
//			R1 = row  (page)	(0 ... 3)
//			
// each page is a block of 8 rows.
// each letter is a 8 X 6 matrix with the image in the top left 7 X 5 corner.
// Leave the bottom row and the rightmost column blank for spacing. 

LCDSetCurser:	MOV			R16,R0					; set the MSB of the colm address
				ANDI		R16,0xF0				; Code is 0001xxxx
				SWAP		R16
				ORI			R16,0x10
				RCALL		LCDWriteCmd

				MOV			R16,R0					; set the LSB of the colm address
				ANDI		R16,0x0F				; code is 0000xxxx
				RCALL		LCDWriteCmd

				MOV			R16,R1					; set the row (page)
				ANDI		R16,0x0F				; code is 1011xxxx
				ORI			R16,0xB0
				RCALL		LCDWriteCmd
				RET

// Writes the byte in R16 to the current colm of the current row of the LCD.
// The next colomn is incremented automatically.
// Algo: make A0 line high then send the byte to the LCD.
// Input: R16 = byte with bit pattern to display.

LCDWriteData:
				PUSH		R17					
				LDI			R17,0b00000001			; LCD_AO high (D0 <- 1)
				STS			PORTD_OUTSET,R17		;			*
				CALL		LCDSendByte				; Send the byte
				POP			R17
				RET

// Draws a figure that has 6 colms a the location of the curser.
//
// Z = address of the first of the 6 bytes to draw.
//

LCDDraw6ColmFig:
				PUSH		R16
				LPM			R16,Z+					; write( LCDData[Z++] )
				RCALL		LCDWriteData			;			*
				LPM			R16,Z+					; write( LCDData[Z++] )
				RCALL		LCDWriteData			;			*
				LPM			R16,Z+					; write( LCDData[Z++] )
				RCALL		LCDWriteData			;			*
				LPM			R16,Z+					; write( LCDData[Z++] )
				RCALL		LCDWriteData			;			*
				LPM			R16,Z+					; write( LCDData[Z++] )
				RCALL		LCDWriteData			;			*
				LPM			R16,Z+					; write( LCDData[Z++] )
				RCALL		LCDWriteData			;			*
				POP			R16
				RET


// clears the whole LCD screen.
// Algo: Traverses each block of the screen writting a 00 bit pattern.
LCDClearScreen:
				PUSH		R16
				PUSH		R17
				PUSH		R18
				PUSH		R0
				PUSH		R1

				CLR			R0						; colm
				LDI			R16,3
				MOV			R1,R16					; row (page)
LCDwhile2:	
				CALL		LCDSetCurser

				CLR			R16
				LDI			R17,132
LCDwhile3:		CALL		LCDWriteData
				DEC			R17
				BRNE		LCDwhile3
		
				DEC			R1
				BRGE		LCDwhile2
				POP			R1
				POP			R0
				POP			R18
				POP			R17
				POP			R16
				RET

LCDBackLightOn:
				PUSH		R16
				LDI			R16,0b00010000			; E4 <- 1 (LCD back light on)
				STS			PORTE_OUTSET,R16		
				POP			R16
				RET

LCDBackLightOff:
				PUSH		R16
				LDI			R16,0b00010000			; E4 <- 0 (LCD back light off)
				STS			PORTE_OUTCLR,R16		
				POP			R16
				RET
LCDReverseOn:
				PUSH		R16
				LDI			R16,0xA7				; cmd = A7 (Reverse on)
				RCALL		LCDWriteCmd
				POP			R16
				RET
LCDReverseOff:
				PUSH		R16				
				LDI			R16,0xA6				; cmd = A6 (Reverse off)
				RCALL		LCDWriteCmd
				POP			R16
				RET

LCDOn:
				PUSH		R16				
				LDI			R16,0xAF				; cmd = AF (LCD on)
				RCALL		LCDWriteCmd
				POP			R16
				RET

LCDOff:
				PUSH		R16				
				LDI			R16,0xAE				; cmd = AE (LCD off)
				RCALL		LCDWriteCmd
				POP			R16
				RET

// ***********************************************************************************
// *    LCD Private functions. Do not call these functions directly. Do not modefy   *
// ***********************************************************************************



// Writes the byte in R16 to the LCD as a command.
// Algo: make A0 line low then send the byte to the LCD.
// Input: R16 = the byte command.

LCDWriteCmd:
													
				PUSH		R17
				LDI			R17,0b00000001			; LCD_AO low (D0 <- 0)
				STS			PORTD_OUTCLR,R17		;			*
				CALL		LCDSendByte				; Send the byte
				POP			R17
				RET

// Send the byte in R16 to the LCD. 

LCDSendByte:
				PUSH		R17						
				LDI			R17,0b00001000			; Make CS low (F3 <- 0)
				STS			PORTF_OUTCLR,R17		;			*
wcmd1:
				LDS			R17, USARTD0_STATUS		; loop until the data buffer is clear
				SBRS		R17,5
				RJMP		wcmd1
				STS			USARTD0_DATA,R16		; Send the byte to the LCD
wcmd2:
				LDS			R17, USARTD0_STATUS		; loop until the transmit is complete
				SBRS		R17,6
				RJMP		wcmd2
				CBR			R17,6
				STS			USARTD0_STATUS,R17		; CLEAR TRANSMIT COMPLETE
				POP			R17
				RET

;   wait a little, short delay used in RESET of the ST7565r
;	for lcd5 added an outer loop to increase the delay by a factor of 4.
;
wlittle:
		PUSH r17
		PUSH r18
		ldi r18,4
agab:
		ldi r17,85
agaa:
		nop
		nop
		nop
		dec r17
		brne agaa
		dec r18
		brne agab
		POP r18
		POP r17
		ret



// Initialize the LCD
LCDInit:
				LDI			R16, 0xA0				; cmd = A0 (adc normal)
				CALL		LCDWriteCmd				;			*
				LDI			R16, 0xA6				; cmd = A6 (display in normal mode)
				CALL		LCDWriteCmd
				LDI			R16, 0xC8				; cmd = C8 (reverse scan)
				CALL		LCDWriteCmd
				LDI			R16, 0xA2				; cmd = A2 (lcd bias)
				CALL		LCDWriteCmd
				CALL		wlittle					; wants a small delay here
				LDI			R16, 0x2F				; cmd = 2F (power control)		
				CALL		LCDWriteCmd
				LDI			R16, 0xF8				; cmd = F8 (set  booster ratio)
				CALL		LCDWriteCmd
				LDI			R16, 0x00				; cmd = 00 (booster ratio 2x ... 4x)
				CALL		LCDWriteCmd
				LDI			R16, 0x21				; cmd = 21 (resister ratio)
				CALL		LCDWriteCmd
													; SHOULD CHECK 30 <-< 40 for contrast, called volume
													; in ST7565
				LDI			R16, 0x1F				; cmd = 1F (set contrast ???)
				CALL		LCDWriteCmd
				LDI			R16,0xAF				; cmd = AF (LCD on)
				CALL		LCDWriteCmd
				RET



; Setup the Pins used for the SPI on USART D0

; A3 = Reset/
; F3 = CS/
; D0 = AO of the LCD
; D1 = XCK
; D3 = TX
; E4 = back light (1 = on, 0 = off)

LCDSetupUsartSpiPins:
				PUSH		R16

				LDI			R16,0b00001000			;set usart-spi ports
				STS			PORTA_DIRSET,R16		;A3 out for Reset
				STS			PORTA_OUTSET,R16		;   high
				STS			PORTF_DIRSET,R16		;F3 out for CS
				STS			PORTF_OUTSET,R16		;   high
				LDI			R16,0b00001011
				STS			PORTD_DIRSET,R16		;D0,1,3 out for  D0=A0,D1=xck,D3=TX
				STS			PORTD_OUTSET,R16		;   high
				LDI			R16,0b00010000			;set usart-spi ports
				STS			PORTE_DIRSET,R16		;E4 out  for backlite
				STS			PORTE_OUTSET,R16		;   on

				POP			R16
				RET

; Reset the LCD.  
; Algo: Make CS/ low then Reset/ low then wait 1 ms then Reset/ high.
LCDReset:
				PUSH		R16
				LDI			R16,0b00001000
				STS			PORTF_OUTCLR,R16		; F3 = 0 (cs_bar low = active)
				STS			PORTA_OUTCLR,R16		; A3 = 0 (reset_bar low = start reset)
				CALL		wlittle					; delay 1 ms
				STS			PORTA_OUTSET,R16		; A3 = 1 (reset_bar high).
				POP			R16
				RET

; Set up master spi on UARTD0
; USART initialization should use the following sequence: 
; 1.    Set the TxD pin value high, and optionally set the XCK pin low.
; 2.    Set the TxD and optionally the XCK pin as output. DONE ABOVE
; 3.    Set the baud rate and frame format. 
; 4.    Set the mode of operation (enables XCK pin output in synchronous mode). 
; 5.    Enable the transmitter or the receiver, depending on the usage. 

LCDSetupSPIOnUARTD0:
				PUSH		R16
				
				LDI			R16, 0b01000000			; Step 1&2. invert xck
				STS			PORTD_PIN1CTRL,R16		; This is part of "SPI MODE 3"
				
				LDI			R16,0b00000010			; xck
				STS			PORTD_OUTCLR,R16	

				LDI			R16, 0b00001111			; Step 3. set BSEL USART xck to 0x0F
				STS			USARTD0_BAUDCTRLA,R16

				LDI			R16, 0b11000011			; Step 4.
				STS			USARTD0_CTRLC,R16		; MASTER,MSB FIRST, hafl of MODE 3, BIT0 ???, 

				LDI			R16, 0b00011000			; Step 5.
				STS			USARTD0_CTRLB,R16		; TX & RX ENABLE

				POP			R16
				RET



// Displays the number in the least significant 4 bits of R0.
// The bit patterns for each digit is stored in the table LCDData in program memory.
// Each digit has 6 columns for the table has 6 bytes per digit. 
// Algo:	The digit value is multiplied by 6 to produce a byte offset from the start 
// of the table. Then the offset is added to the start of the table and that address points 
// to the first of the 6 bytes for that digit. Each of the 6 byte is sent to the LCD to display. 
// Input:	R0 = digit to display (00 ... 0F)

LCDWriteHexDigit:
				PUSH		R16
				PUSH		R17
				PUSH		R1
				PUSH		ZL	
				PUSH		ZH	
				PUSH		R0

				LDI			ZL,low(LCDData << 1)	; Z = LCDData			
				LDI			ZH,high(LCDData << 1)	;			*

				MOV			R16,R0					; Clear the MSB of R0 just in case 
				ANDI		R16,0x0F				;			*
				LDI			R17,6					; Z = LCDData + (digit * 6)
				MUL			R16,R17					;			* 
				MOV			R16,R0					;			*
				ADD			ZL,R16					;			*
				CLR			R16						;			*
				ADC			ZH,R16					;			*
				
				CALL		LCDDraw6ColmFig

				POP			R0
				POP			ZH
				POP			ZL
				POP			R1
				POP			R17
				POP			R16		

				RET


// Displays the character whose ASCII code is stored in R16.

// The bit patterns for each ASCII character is stored in the table LCDData in program memory.
// Each character has 6 columns from the table for 6 bytes per display box. 
// Algo:	The code is multiplied by 6 to produce a byte offset from the start 
// of the table. Then the offset is added to the start of the table and that address points 
// to the first of the 6 bytes for that code. Each of the 6 byte is sent to the LCD to display. 
// Input:	R0 = ASCII code (00 ... 7F)

LCDWriteASCIIChar:
				PUSH		R17
				PUSH		R0
				PUSH		R1
				PUSH		ZL	
				PUSH		ZH

				LDI			ZL,low(LCDData << 1)	; Z = LCDData			
				LDI			ZH,high(LCDData << 1)	;			*

				LDI			R17,6					; Z = LCDData + (ASCII * 6)
				MUL			R16,R17					;			* 
				ADD			ZL,R0					;			*
				ADC			ZH,R1					;			*
				
				CALL		LCDDraw6ColmFig

				POP			ZH
				POP			ZL
				POP			R1
				POP			R0
				POP			R17
				RET

// input:	Z = address of 0 terminated string.
// Algo:
//
// while (mem(Z) != 0)
//     LCDWriteASCIIChar ( mem(Z++) )
//
LCDPrintf:
				PUSH		R16
if:				LPM			R16,Z+
				CPI			R16,0
				BREQ		endif
				CALL		LCDWriteASCIIChar
				JMP			if
endif:			
				POP			R16
				RET
// The LCD Data

LCDData:
LCDData00:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; NULL
LCDData01:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; SOH
LCDData02:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; STX
LCDData03:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; ETX
LCDData04:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; EOT
LCDData05:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; ENQ
LCDData06:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; ACK
LCDData07:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; BEL
LCDData08:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; BS
LCDData09:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; HT
LCDData0A:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; LF
LCDData0B:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; VT
LCDData0C:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; FF
LCDData0D:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; CR
LCDData0E:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; SO
LCDData0F:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; SI

LCDData10:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; DLE
LCDData11:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; DC1
LCDData12:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; DC2
LCDData13:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; DC3
LCDData14:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; DC4
LCDData15:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; NAK
LCDData16:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; SYN
LCDData17:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; ETB
LCDData18:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; CAN
LCDData19:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; EM
LCDData1A:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; SUB
LCDData1B:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; ESC
LCDData1C:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; FS
LCDData1D:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; GS
LCDData1E:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; RS
LCDData1F:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; US

LCDData20:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; BLANK
LCDData21:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; !
LCDData22:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; " 
LCDData23:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; #
LCDData24:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; $
LCDData25:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; %
LCDData26:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; &
LCDData27:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; '
LCDData28:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; (
LCDData29:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; )
LCDData2A:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; *
LCDData2B:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; +
LCDData2C:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; ,
LCDData2D:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; -
LCDData2E:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; .
LCDData2F:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; /

LCDData30:		.DB			0x3E,0x45,0x49,0x51,0x3E,0x00 ; 0
LCDData31:		.DB			0x00,0x00,0x7F,0x00,0x00,0x00 ; 1
LCDData32:		.DB			0x32,0x49,0x49,0x49,0x06,0x00 ; 2
LCDData33:		.DB			0x41,0x49,0x49,0x49,0x36,0x00 ; 3
LCDData34:		.DB			0x0F,0x08,0x7E,0x08,0x08,0x00 ; 4
LCDData35:		.DB			0x2F,0x49,0x49,0x49,0x31,0x00 ; 5
LCDData36:		.DB			0x3E,0x49,0x49,0x49,0x32,0x00 ; 6
LCDData37:		.DB			0x41,0x21,0x11,0x09,0x07,0x00 ; 7
LCDData38:		.DB			0x36,0x49,0x49,0x49,0x36,0x00 ; 8
LCDData39:		.DB			0x06,0x09,0x09,0x09,0x7E,0x00 ; 9
LCDData3A:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; :
LCDData3B:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; ;
LCDData3C:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; <
LCDData3D:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; =
LCDData3E:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; >
LCDData3F:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; ?

LCDData40:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; @
LCDData41:		.DB			0x7C,0x12,0x11,0x12,0x7C,0x00 ; A
LCDData42:		.DB			0x7F,0x49,0x49,0x49,0x36,0x00 ; B
LCDData43:		.DB			0x3E,0x41,0x41,0x41,0x41,0x00 ; C
LCDData44:		.DB			0x7F,0x41,0x41,0x41,0x3E,0x00 ; D
LCDData45:		.DB			0x7F,0x49,0x49,0x41,0x41,0x00 ; E
LCDData46:		.DB			0x7F,0x09,0x09,0x01,0x00,0x00 ; F
LCDData47:		.DB			0x3E,0x41,0x41,0x49,0x3A,0x00 ; G
LCDData48:		.DB			0x7F,0x08,0x08,0x08,0x7F,0x00 ; H
LCDData49:		.DB			0x41,0x41,0x7F,0x41,0x41,0x00 ; I
LCDData4A:		.DB			0x21,0x41,0x3F,0x01,0x01,0x00 ; J
LCDData4B:		.DB			0x7F,0x08,0x14,0x22,0x41,0x00 ; K
LCDData4C:		.DB			0x7F,0x40,0x40,0x40,0x40,0x00 ; L
LCDData4D:		.DB			0x7F,0x02,0x04,0x02,0x7F,0x00 ; M
LCDData4E:		.DB			0x7F,0x04,0x08,0x10,0x7F,0x00 ; N
LCDData4F:		.DB			0x3E,0x41,0x41,0x41,0x3E,0x00 ; O

LCDData50:		.DB			0x7F,0x09,0x09,0x09,0x06,0x00 ; P
LCDData51:		.DB			0x3E,0x41,0x41,0x21,0x5E,0x00 ; Q
LCDData52:		.DB			0x7E,0x09,0x19,0x29,0x46,0x00 ; R
LCDData53:		.DB			0x26,0x49,0x49,0x49,0x32,0x00 ; S
LCDData54:		.DB			0x01,0x01,0x7F,0x01,0x01,0x00 ; T
LCDData55:		.DB			0x3F,0x40,0x40,0x40,0x3F,0x00 ; U
LCDData56:		.DB			0x1F,0x20,0x40,0x20,0x1F,0x00 ; V
LCDData57:		.DB			0x3F,0x40,0x20,0x40,0x3F,0x00 ; W
LCDData58:		.DB			0x63,0x14,0x08,0x14,0x63,0x00 ; X
LCDData59:		.DB			0x03,0x04,0x78,0x04,0x03,0x00 ; Y
LCDData5A:		.DB			0x61,0x51,0x49,0x45,0x43,0x00 ; Z
LCDData5B:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; [
LCDData5C:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; \
LCDData5D:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; ]
LCDData5E:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; ^
LCDData5F:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; _

LCDData60:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; `
LCDData61:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; a
LCDData62:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; b
LCDData63:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; c
LCDData64:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; d
LCDData65:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; e
LCDData66:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; f
LCDData67:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; g
LCDData68:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; h
LCDData69:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; i
LCDData6A:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; j
LCDData6B:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; k
LCDData6C:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; l
LCDData6D:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; m
LCDData6E:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; n
LCDData6F:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; o

LCDData70:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; p
LCDData71:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; q
LCDData72:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; r
LCDData73:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; s
LCDData74:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; t
LCDData75:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; u
LCDData76:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; v
LCDData77:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; w
LCDData78:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; x
LCDData79:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; y
LCDData7A:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; z
LCDData7B:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; {
LCDData7C:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; |
LCDData7D:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; }
LCDData7E:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; ~
LCDData7F:		.DB			0x00,0x00,0x00,0x00,0x00,0x00 ; DEL

/*Ball:			.db			0x3C,0x7E,0xFF,0xFF,0x7E,0x3C 
Box:			.db			0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
RightArrow:		.db			0x08,0x2A,0x1C,0x08,0x08,0x00*/


SetCpuClockTo32MInt:
				LDS			R16,OSC_CTRL			; Enable the 32M Hz oscilator
				ORI			R16,0b00000010			;			*
				STS			OSC_CTRL,R16			;			*
while1:
				LDS			R16,OSC_STATUS			; Wait until its stable
				ANDI		R16,0x02				;			*
				BREQ		while1					;			*

				LDI			R16,0xD8				; Connect the 23 MHz OSC to the system clock
				OUT			CPU_CCP,R16				;			*
				LDI			R16,0x01				;			*
				STS			CLK_CTRL,R16			;			*

				LDI			R16,0xD8				; Reset the prescale stages A,B,C back to 1
				OUT			CPU_CCP,R16				;			*
				LDI			R16,0x00				;			*
				STS			CLK_PSCTRL,R16			;			*

				LDI			R16,0xD8				; Select the internal 32.768 KHz source
				OUT			CPU_CCP,R16				; for the RC32M DFLL
				LDS			R16,OSC_DFLLCTRL		;			*
				ANDI		R16,0b11111101			;			*
				STS			OSC_DFLLCTRL,R16		;			*

				LDS			R16,DFLLRC32M_CTRL		; Enable the DFLL for the RC32MHz
				ORI			R16,0x01				;			*
				STS			DFLLRC32M_CTRL,R16		;			*

				RET
