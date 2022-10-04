/*
 * enm221_0039_2018__assignment1.asm
 *
 *  Created: 9/29/2022 2:52:32 PM
 *   Author: Admin
 */ 


 .include "tn13def.inc"


 .cseg
 .org 0x00
 

.macro CONTROLLER
		;;SUB ROUTINE TURN ON 
		LDI R16, @0			;; IS IT INPUT OR OUTPUT
		OUT DDRB, R16

		LDI R16, @1			;; TURN SPECIFIC PINS HIGH 
		OUT PORTB, R16		;;TURN PORT ON USING
.endmacro


 MAIN:
	LDI R16,HIGH(RAMEND)
	
	LDI R17,LOW(RAMEND)
	OUT SPL, R17

	CLR R16
	CLR R17 

	RCALL INIT_CONVERSION

	;;RCALL BLINK_LEDS
	;;RCALL DELAY 

	RJMP MAIN					;; MAKING THE MAIN FUNCTION A CONTINUOS LOOP
INIT_CONVERSION:
			LDI R16,(1<<ADEN) | (1<<ADPS2) | (1<<ADPS1)| (1<<ADPS0) ;0B10000011
			OUT ADCSRA, R16			

			LDI R16, 0B00100010			// THE ADC VALUE SHOULD BE RIGHT JUSTIFIED SO THAT LATER I CAN IGNRE THE LAST 2 LEAST SIGNIFICANT VALUES
			OUT ADMUX, R16

			;;RCALL START_CONVERSION 
			;;RCALL WAIT_FOR_CONVERSION 
START_CONVERSION:
			IN R16, ADCSRA
			LDI R17, (1<<ADSC)
			OR R16, R17 

			OUT ADCSRA, R16			;; START CONVERSION 

WAIT_FOR_CONVERSION:
			IN R17, ADCSRA
			SBRS R17 , 6					;; CHECK IF THE CONVERSION HAS COMPLETED
		
			RJMP WAIT_FOR_CONVERSION 
			IN R19, ADCL
			in R18, ADCH			;;get the value of ADC conversion 
			// i will only use the values of ADCL ommiting the values of ADCH which are LSBs

			
			
		
			
BLINK_LEDS:
			;;IF VOLATGE == 1 LIGHT 1 LED IF V==2 LIGHT LED 2 IF V==3 LIGHT LED 3  IF VOLTAGE == 4 BLINK 4TH LED
			;; I ONLY NEED TO CHECK VALUE OF ADCL TO READ VALUE 
			/*
			 This sub routine compares the value of the digital output read from the ADC with known values that correspond to 1v , 2v, 3v and 4v

			 in 10bit ADC 1V is equivalent to 409. Since 409 cannot be represented as an 8 bit value, it is right -shifted 2 times (same as dividing by 4)
			 Therefore 409 / 4 == 0x66 

			 value 0x66 is compared to the right adjusted ADC value.

			 Since the value of ADC has an error of +- 4 due to right shifting the value we don't compare this value exactly rather 
			 we check if the value of ADC is in range of the required voltage
			
			*/
			LDI R17 , 0X66	;; 2v == 409 Digital value. dividing this value by 4  
			CP R18, R17 
			BRLO LED_1			;; LIGHT LED 1 IF VALUE IN ADC IS 409 IS THE VALUE FOR 2V IF ADC VALUE IS LESS THAN THAT LIGHT LED 1
			LDI R17, 0X99		;;FOR 3V THE OUTPUT OF ADC WILL BE 614 / 4 == 0X99
			CP R18, R17 
			BRLO LED_2			//IF ADC VALUE IS BETWEEN 614 AND 409 LIGHT UP LED 2
			LDI R17 , 0XCC	;; FOR 
			CP R18, R17 			;; check if adc value is 3 
			BRLO LED_3 
			LDI R17, 0XFF			;; compare vaue in adc with 4
			CP R18, R17
			BRSH LED_4  
			RET  
			 
LED_1:
		CONTROLLER 0X1 ,0X1
		CLR R16
		RET 
LED_2:
		CONTROLLER 0X2 ,0X2 ;; USING MACRO CONTROLLER LIGHT UP LEDS 
		CLR R16
		RET 
LED_3:
		CONTROLLER 0B00000100 ,0B00000100
		CLR R16
		RET 
LED_4:
		CONTROLLER 0B00001000 ,0B00001000
		rjmp	LED_1
		CLR R16
		RET 

DELAY:
		;;SINCE THE MICROCONTROLLER IS RUNNING AT IMHZ IT IS NECESSARY TO SLOW DOWN THE PROGRAM 
		;;SO THAT THE LEDs CAN BE ON LONG ENOUGH TO BE SEEN 
		    LDI R16, 200 
		LP0: LDI R17, 20
		LP1: LDI R19, 10
		LP2: NOP

		 
		 DEC R19 
		 BRNE LP2
	     DEC R17 
		 BRNE LP1 
		 DEC R16 
		 BRNE LP0

		; [ 4 + (200* 20 * 10)]  == 40,004  1 INSTRUCTION TAKES 1 MICROSECOND SO 400,004 WILL TAKE 0. 04 SECONDS 

		RET     ;; 
		

			   


	
