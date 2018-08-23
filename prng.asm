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
LOOP	IN		TIMERCD
		OUT		LEDS
		IN		TIMERLO
		MOV	E,A
		IN		TIMERHI
		ANI		3fh
		MOV	D,A
		MVI		C,LEDHEX
		CALL	MOS
		MVI		C,UPRINT
		CALL	MOS
		MVI		C,CONOUT
		MVI		E,0Ah
		CALL	MOS
		MVI		E,0Dh
		CALL	MOS
		IN		TIMERHI
		ANI		0C0h
		RLC
		RLC
		MOV	E,A
		MVI		C,DDATA
		CALL	MOS
		MVI		C,DELAY
		LXI		H,0FFFFh
		CALL	MOS
		JMP		LOOP
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

		END