; Testing EMAC "The Primer" M81C55 timer data,
; and pseudo-random number generation algorithm.

		ORG		0C000h
; Set timer and begin.
		MVI		A,0FFh
		OUT		TIMERLO
		IN		TIMERHI
		ORI		03Fh
		OUT		TIMERHI
		IN		TIMERCD
		ORI		0C0h
		OUT		TIMERCD
; Wait for a keypad key to be pressed.
		MVI		C,KEYIN
		CALL	MOS
; Load the current timer LSB.
		IN		TIMERLO
; Prepare the counter for the loop to fill the reserved bytes for the random sequence.
		LXI		H,RNDNMS
		MVI		C,32h
; Loop, each time loading a value of 0-3 into a reserved memory location.
; The PRNG value is left-shifted and XOR'd with a constant each iteration.
LOOP	MOV	B,A
		ANI		03h
		MOV	M,A
		MOV	A,B
		RLC
		JNC		NOXOR
		XRI		0A6h
NOXOR	INX		H
		DCR		C
		JNZ		LOOP
; Display the 50 chosen random values to the serial console, separated by NL and CR.
		LXI		H,RNDNMS
		MVI		B,32h
DSPLAY	MVI		D,0h
		MOV	E,M
		MVI		C,UPRINT
		CALL	MOS
		MVI		C,CONOUT
		MVI		E,0Ah
		CALL	MOS
		MVI		E,0Dh
		CALL	MOS
		INX		H
		DCR		B
		JNZ		DSPLAY
		RST		7

; MOS Services
MOS		EQU		1000h
DELAY	EQU		14h
		; IN:		Register C, 14h
		; IN:		Register HL, Amount of delay.
KEYIN	EQU		0Bh
		; IN:		Register C, 0Bh
		; OUT:	Register L, Key value.
LEDHEX	EQU		12h
		; IN:		Register C, 12h
		; IN:		Register DE, 16-bit number to be displayed on ADDR/REG.
DDATA	EQU		1Bh
		; IN:		Register C, 1Bh
		; IN:		Register E, 8-bit number to be displayed on DATA/OP.
UPRINT	EQU		05h
		; IN:		Register C, 05h
		; IN:		Register DE, 16-bit number to be displayed on console.
CONOUT	EQU		03h
		; IN:		Register C, 03h
		; IN:		Register E, ASCII character to be displayed on console.

; Ports
TIMERCD	EQU		10h
TIMERLO	EQU		14h
TIMERHI	EQU		15h
LEDS	EQU		11h

; Storage
RNDNMS	DS		32h

		END