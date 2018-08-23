; ECHO8085
; A Simon-like game for the EMAC "The PRIMER" 8085 Trainer.
; Written in 8085 Assembly.
; Christopher Fox
; April 2015

		ORG		0C000h
; Load the delay value from the DIP switches,
; and display on LD0-LD7.
		MVI		L,0h
		IN		DIPS
		MOV	H,A
		SHLD	DLAY
		CMA
		OUT		LEDS
; Set timer and start. Timer used for PRNG.
		MVI		A,0FFh
		OUT		TIMERLO
		IN		TIMERHI
		ORI		03Fh
		OUT		TIMERHI
		IN		TIMERCD
		ORI		0C0h
		OUT		TIMERCD
; Game name "ECHO.85" to the 7-segment LEDs.
		MVI		C,LEDSTR
		LXI		D,0506h
		LXI		H,LEDNAM
		CALL	MOS
; Print the game splash to the console.
		MVI		C,PSTR
		LXI		D,SPLASH
		CALL	MOS
; Wait for "y" key to be pressed to start the game or any other key to return to MOS.
		MVI		C,CONIN
		CALL	MOS
		MOV	A,L
		CPI		079h
		JZ		PRNG
		RST		7			; End and return to MOS.
; Start of the game code. Just testing stuff for now.
; Generate the random number sequence.
PRNG	LXI		H,RNDNMS
		MVI		C,032h
		IN		TIMERLO
PRNGLP	MOV	B,A
		ANI		03h
		MOV	M,A
		MOV	A,B
		RLC
		JNC		NOXOR
		XRI		0A6h
NOXOR	INX		H
		DCR		C
		JNZ		PRNGLP
; Print the game board to the console.
GAME	MVI		C,PSTR
		LXI		D,GAMEBD
		CALL	MOS
; Load the starting sequence length, 1.
		LXI		H,SEQLEN
		MVI		M,01h
; 
STRSEQ	MOV	C,M			; The C register is our counter to decrement to run through the sequence.
		LXI		D,RNDNMS	; Load the DE register with the memory location for the current random number.
; Computer plays through the sequence once.
PLYSEQ	LDAX	D			; Load the current random number into the accumulator.
		PUSH	D			; Preserve DE, holding the memory location in the random number sequence.
		PUSH	B			; Preserve BC, holding where we are in the sequence.
		CPI		0h			; Flash the proper color, play the proper tone.
		CZ		F_YLW
		CPI		1h
		CZ		F_BLU
		CPI		2h
		CZ		F_GRN
		CPI		3h
		CZ		F_RED
		POP		B			; Restore BC.
		POP		D			; Restore DE.
		INX		D			; Increment DE, moving to the next random number in the sequence.
		DCR		C			; Decrement C, the counter for this iteration through the sequence.
		JNZ		PLYSEQ		; If we're not all the way through, jump back and play the next random number.
; Players turn to repeat.
		LXI		H,SEQLEN
		MOV	C,M
		LXI		D,RNDNMS
RPTSEQ	PUSH	B
		PUSH	D
		MVI		C,CONIN		; Wait for the player to press a key,
		CALL	MOS			; and store the ASCII value in L.
		MOV	A,L			; Move the value into the accumulator for comparisons.
		CPI		031h		; Did the player press "1" for Yellow?
		CZ		P_YLW
		CPI		032h		; Did the player press "2" for Blue?
		CZ		P_BLU
		CPI		034h		; Did the player press "4" for Green?
		CZ		P_GRN
		CPI		035h		; Did the player press "5" for Red?
		CZ		P_RED
		POP		D
		POP		B
		LDAX	D			; Load the current random number into the accumulator.
		;PUSH	D			; Preserve DE, holding the memory location in the random number sequence.
		;PUSH	B			; Preserve BC, holding where we are in the sequence.
		CMP	L			; Did the player press the correct key?
		JNZ		ULOSE		; No? Game over.
		INX		D			; Increment DE, moving to the next random number in the sequence.
		DCR		C			; Decrement C, the counter for this iteration through the sequence.
		JNZ		RPTSEQ		; If we're not at the end of the sequence, repeat with the next entry.
		;MVI		C,DELAY		; A delay between the sequences, temporary until player repeat portion is written.
		;LXI		H,03FFFh		; A big delay value.
		;CALL	MOS			;
		;CALL	MOS			; Twice.
; If the player repeats correctly.
		LXI		H,SEQLEN	; Move the memory address for the current sequence length (aka score) into HL.
		INR		M			; Increment the value in the memory location, adding one to the player's score and length of the sequence.
		MVI		A,08h		; Move the maximum possible score into the accumulator.
		CMP	M			; Compare with the current sequence length.
		JNZ		STRSEQ		; Not yet at maximum? Allow the player to continue.
		RST		7			; End and return to MOS.
ULOSE	MVI		C,PITCH
		LXI		D,LOSS
		CALL	MOS
		MVI		C,DELAY
		LXI		H,0FFFFh
		CALL	MOS
		MVI		C,PITCH
		LXI		D,0h
		CALL	MOS
		RST		7
; Subroutines
P_GRN	CALL	F_GRN
		MVI		L,2h
		RET
P_RED	CALL	F_RED
		MVI		L,3h
		RET
P_YLW	CALL	F_YLW
		MVI		L,0h
		RET
P_BLU	CALL	F_BLU
		MVI		L,1h
		RET
F_GRN	MVI		C,PSTR
		LXI		D,ONGRN
		CALL	MOS
		MVI		C,PITCH
		LXI		DE,GRNTN
		CALL	MOS
		MVI		C,DELAY
		LHLD	DLAY
		CALL	MOS
		MVI		C,PITCH
		LXI		DE,0h
		CALL	MOS
		MVI		C,PSTR
		LXI		D,OFFGRN
		CALL	MOS
		RET
F_RED	MVI		C,PSTR
		LXI		D,ONRED
		CALL	MOS
		MVI		C,PITCH
		LXI		DE,REDTN
		CALL	MOS
		MVI		C,DELAY
		LHLD	DLAY
		CALL	MOS
		MVI		C,PITCH
		LXI		DE,0h
		CALL	MOS
		MVI		C,PSTR
		LXI		D,OFFRED
		CALL	MOS
		RET
F_YLW	MVI		C,PSTR
		LXI		D,ONYLW
		CALL	MOS
		MVI		C,PITCH
		LXI		DE,YLWTN
		CALL	MOS
		MVI		C,DELAY
		LHLD	DLAY
		CALL	MOS
		MVI		C,PITCH
		LXI		DE,0h
		CALL	MOS
		MVI		C,PSTR
		LXI		D,OFFYLW
		CALL	MOS
		RET
F_BLU	MVI		C,PSTR
		LXI		D,ONBLU
		CALL	MOS
		MVI		C,PITCH
		LXI		DE,BLUTN
		CALL	MOS
		MVI		C,DELAY
		LHLD	DLAY
		CALL	MOS
		MVI		C,PITCH
		LXI		DE,0h
		CALL	MOS
		MVI		C,PSTR
		LXI		D,OFFBLU
		CALL	MOS
		RET

; EMAC MOS Service Calls
MOS		EQU		1000h
PSTR	EQU		4h
		; In:		Register DE; starting addr. of string.
		; Out:	Register DE; addr. after "$" string terminator.
CONIN	EQU		1h
		; Out:	Register L; ASCII char. returned from console keyboard.
PITCH	EQU		10h
		; In:		Register DE; 14-bit pitch value.
DELAY	EQU		14h
		; In:		Register HL; amount of delay, larger is longer.
LEDSTR	EQU		1Ah
		; In:		Register E; number of displays to change (1-6).
		; In:		Register D; starting display (5-0).
		; In:		Register HL; starting addr. of bit pattern data.
; Constants
		; Ports
TIMERCD	EQU		10h
TIMERLO	EQU		14h
TIMERHI	EQU		15h
LEDS	EQU		11h
DIPS		EQU		12h

		; PITCH service tone values.
BLUTN	EQU		03A4h
YLWTN	EQU		0454h
REDTN	EQU		0574h
GRNTN	EQU		0746h
LOSS	EQU		0F00h

LEDNAM	DB		97h,85h,47h,0CDh,0F7h,0D6h
SPLASH	DB		01Bh,05Bh,03Fh,037h,068h,01Bh,05Bh,034h,030h,06Dh,01Bh,05Bh,032h,04Ah,01Bh
		DB		05Bh,034h,030h,06Dh,00Dh,00Ah,01Bh,05Bh,030h,03Bh,031h,06Dh,01Bh,05Bh,039h
		DB		043h,01Bh,05Bh,033h,035h,06Dh,0DCh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,020h,01Bh
		DB		05Bh,033h,033h,06Dh,0DCh,0DBh,0DBh,0DBh,0DBh,0DBh,0DCh,020h,01Bh,05Bh,033h
		DB		034h,06Dh,0DBh,0DBh,020h,020h,020h,0DBh,0DBh,020h,01Bh,05Bh,033h,032h,06Dh
		DB		0DCh,0DBh,0DBh,0DBh,0DBh,0DBh,0DCh,020h,01Bh,05Bh,033h,035h,06Dh,0DCh,0DBh
		DB		0DBh,0DBh,0DBh,0DBh,0DCh,020h,01Bh,05Bh,033h,033h,06Dh,0DCh,0DBh,0DBh,0DBh
		DB		0DBh,0DBh,0DCh,020h,01Bh,05Bh,033h,034h,06Dh,0DCh,0DBh,0DBh,0DBh,0DBh,0DBh
		DB		0DCh,020h,01Bh,05Bh,033h,032h,06Dh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh
		DB		00Ah,01Bh,05Bh,039h,043h,01Bh,05Bh,033h,035h,06Dh,0DBh,0DBh,0DCh,0DCh,0DCh
		DB		0DCh,020h,020h,01Bh,05Bh,033h,033h,06Dh,0DBh,0DBh,01Bh,05Bh,036h,043h,01Bh
		DB		05Bh,033h,034h,06Dh,0DBh,0DBh,0DCh,0DCh,0DCh,0DBh,0DBh,020h,01Bh,05Bh,033h
		DB		032h,06Dh,0DBh,0DBh,020h,020h,020h,0DBh,0DBh,020h,01Bh,05Bh,033h,035h,06Dh
		DB		0DFh,0DBh,0DCh,0DCh,0DCh,0DBh,0DFh,020h,01Bh,05Bh,033h,033h,06Dh,0DBh,0DBh
		DB		020h,020h,0DCh,0DBh,0DBh,020h,01Bh,05Bh,033h,034h,06Dh,0DFh,0DBh,0DCh,0DCh
		DB		0DCh,0DBh,0DFh,020h,01Bh,05Bh,033h,032h,06Dh,0DBh,0DBh,0DCh,0DCh,0DCh,0DCh
		DB		00Dh,00Ah,01Bh,05Bh,039h,043h,01Bh,05Bh,033h,035h,06Dh,0DBh,0DBh,0DFh,0DFh
		DB		0DFh,0DFh,020h,020h,01Bh,05Bh,033h,033h,06Dh,0DBh,0DBh,01Bh,05Bh,036h,043h
		DB		01Bh,05Bh,033h,034h,06Dh,0DBh,0DBh,0DFh,0DFh,0DFh,0DBh,0DBh,020h,01Bh,05Bh
		DB		033h,032h,06Dh,0DBh,0DBh,020h,020h,020h,0DBh,0DBh,020h,01Bh,05Bh,033h,035h
		DB		06Dh,0DBh,0DBh,0DFh,0DFh,0DFh,0DBh,0DBh,020h,01Bh,05Bh,033h,033h,06Dh,0DBh
		DB		0DBh,0DCh,0DFh,020h,0DBh,0DBh,020h,01Bh,05Bh,033h,034h,06Dh,0DBh,0DBh,0DFh
		DB		0DFh,0DFh,0DBh,0DBh,020h,020h,01Bh,05Bh,033h,032h,06Dh,0DFh,0DFh,0DFh,0DFh
		DB		0DBh,0DBh,00Dh,00Ah,01Bh,05Bh,039h,043h,01Bh,05Bh,033h,035h,06Dh,0DFh,0DBh
		DB		0DBh,0DBh,0DBh,0DBh,0DBh,020h,01Bh,05Bh,033h,033h,06Dh,0DFh,0DBh,0DBh,0DBh
		DB		0DBh,0DBh,0DFh,020h,01Bh,05Bh,033h,034h,06Dh,0DBh,0DBh,020h,020h,020h,0DBh
		DB		0DBh,020h,01Bh,05Bh,033h,032h,06Dh,0DFh,0DBh,0DBh,0DBh,0DBh,0DBh,0DFh,020h
		DB		01Bh,05Bh,033h,035h,06Dh,0DFh,0DBh,0DBh,0DBh,0DBh,0DBh,0DFh,020h,01Bh,05Bh
		DB		033h,033h,06Dh,0DFh,0DBh,0DBh,0DBh,0DBh,0DBh,0DFh,020h,01Bh,05Bh,033h,034h
		DB		06Dh,0DFh,0DBh,0DBh,0DBh,0DBh,0DBh,0DFh,020h,01Bh,05Bh,033h,032h,06Dh,0DBh
		DB		0DBh,0DBh,0DBh,0DBh,0DBh,0DFh,00Dh,00Ah,00Dh,00Ah,00Dh,00Ah,01Bh,05Bh,032h
		DB		035h,043h,01Bh,05Bh,033h,037h,06Dh,045h,043h,048h,04Fh,038h,030h,038h,035h
		DB		01Bh,05Bh,030h,06Dh,03Ah,020h,061h,020h,022h,066h,06Fh,06Ch,06Ch,06Fh,077h
		DB		020h,06Dh,065h,022h,020h,067h,061h,06Dh,065h,02Eh,00Dh,00Ah,01Bh,05Bh,035h
		DB		043h,057h,072h,069h,074h,074h,065h,06Eh,020h,066h,06Fh,072h,020h,045h,04Dh
		DB		041h,043h,027h,073h,020h,022h,054h,068h,065h,020h,050h,052h,049h,04Dh,045h
		DB		052h,022h,020h,038h,030h,038h,035h,020h,043h,050h,055h,020h,054h,072h,061h
		DB		069h,06Eh,065h,072h,020h,069h,06Eh,020h,061h,073h,073h,065h,06Dh,062h,06Ch
		DB		079h,020h,06Ch,061h,06Eh,067h,075h,061h,067h,065h,02Eh,00Dh,00Ah,01Bh,05Bh
		DB		032h,036h,043h,01Bh,05Bh,033h,035h,06Dh,043h,068h,072h,069h,073h,074h,06Fh
		DB		070h,068h,065h,072h,020h,046h,06Fh,078h,01Bh,05Bh,033h,037h,06Dh,02Ch,020h
		DB		041h,070h,072h,069h,06Ch,020h,032h,030h,031h,035h,00Dh,00Ah,00Dh,00Ah,00Dh
		DB		00Ah,01Bh,05Bh,031h,031h,043h,01Bh,05Bh,034h,036h,06Dh,020h,01Bh,05Bh,033h
		DB		030h,06Dh,048h,06Fh,077h,020h,06Ch,06Fh,06Eh,067h,020h,061h,020h,073h,065h
		DB		071h,075h,065h,06Eh,063h,065h,020h,06Fh,066h,020h,063h,06Fh,06Ch,06Fh,072h
		DB		020h,061h,06Eh,064h,020h,073h,06Fh,075h,06Eh,064h,020h,063h,061h,06Eh,020h
		DB		079h,06Fh,075h,020h,072h,065h,06Dh,065h,06Dh,062h,065h,072h,03Fh,020h,01Bh
		DB		05Bh,034h,030h,06Dh,00Dh,00Ah,00Dh,00Ah,00Dh,00Ah,01Bh,05Bh,032h,034h,043h
		DB		01Bh,05Bh,033h,037h,06Dh,050h,072h,065h,073h,073h,020h,01Bh,05Bh,031h,03Bh
		DB		033h,033h,06Dh,022h,01Bh,05Bh,035h,06Dh,079h,01Bh,05Bh,030h,03Bh,031h,03Bh
		DB		033h,033h,06Dh,022h,020h,01Bh,05Bh,030h,06Dh,074h,06Fh,020h,062h,065h,067h
		DB		069h,06Eh,020h,061h,06Eh,064h,020h,066h,069h,06Eh,064h,020h,06Fh,075h,074h
		DB		021h,00Dh,00Ah,01Bh,05Bh,031h,035h,043h,04Fh,072h,02Ch,020h,070h,072h,065h
		DB		073h,073h,020h,061h,06Eh,079h,020h,06Fh,074h,068h,065h,072h,020h,06Bh,065h
		DB		079h,020h,074h,06Fh,020h,071h,075h,069h,074h,020h,061h,06Eh,064h,020h,072h
		DB		065h,074h,075h,072h,06Eh,020h,074h,06Fh,020h,04Dh,04Fh,053h,02Eh,00Dh,00Ah
		DB		00Dh,00Ah,00Dh,00Ah,00Dh,00Ah,00Dh,00Ah,00Dh,00Ah,00Dh,00Ah,00Dh,00Ah,01Bh
		DB		05Bh,030h,06Dh,01Bh,05Bh,032h,035h,035h,044h,024h
GAMEBD	DB		01Bh,05Bh,03Fh,037h,068h,01Bh,05Bh,034h,030h,06Dh,01Bh,05Bh,032h,04Ah,01Bh
		DB		05Bh,033h,036h,043h,01Bh,05Bh,030h,03Bh,031h,06Dh,045h,043h,048h,04Fh,038h
		DB		030h,038h,035h,00Dh,00Ah,00Dh,00Ah,01Bh,05Bh,032h,039h,043h,01Bh,05Bh,030h
		DB		06Dh,046h,06Fh,06Ch,06Ch,06Fh,077h,020h,074h,068h,065h,020h,073h,065h,071h
		DB		075h,065h,06Eh,063h,065h,020h,06Fh,066h,00Dh,00Ah,01Bh,05Bh,033h,032h,043h
		DB		063h,06Fh,06Ch,06Fh,072h,020h,061h,06Eh,064h,020h,074h,06Fh,06Eh,065h,02Eh
		DB		00Dh,00Ah,00Dh,00Ah,01Bh,05Bh,032h,039h,043h,01Bh,05Bh,033h,032h,06Dh,0B1h
		DB		0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,020h,020h,01Bh,05Bh,033h,031h
		DB		06Dh,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah,01Bh,05Bh
		DB		032h,039h,043h,01Bh,05Bh,033h,032h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h
		DB		0B1h,0B1h,0B1h,020h,020h,01Bh,05Bh,033h,031h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h
		DB		0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah,01Bh,05Bh,032h,039h,043h,01Bh,05Bh,033h
		DB		032h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,020h,020h,01Bh
		DB		05Bh,033h,031h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh
		DB		00Ah,01Bh,05Bh,031h,038h,043h,01Bh,05Bh,033h,032h,06Dh,047h,072h,065h,065h
		DB		06Eh,03Dh,022h,034h,022h,020h,020h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h
		DB		0B1h,0B1h,020h,020h,01Bh,05Bh,033h,031h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h
		DB		0B1h,0B1h,0B1h,0B1h,020h,020h,022h,035h,022h,03Dh,052h,065h,064h,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,01Bh,05Bh,033h,032h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h
		DB		0B1h,0B1h,0B1h,0B1h,0B1h,020h,020h,01Bh,05Bh,033h,031h,06Dh,0B1h,0B1h,0B1h
		DB		0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah,01Bh,05Bh,032h,039h,043h,01Bh
		DB		05Bh,033h,032h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,020h
		DB		020h,01Bh,05Bh,033h,031h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h
		DB		0B1h,00Dh,00Ah,00Dh,00Ah,01Bh,05Bh,032h,039h,043h,01Bh,05Bh,031h,03Bh,033h
		DB		033h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,020h,020h,01Bh
		DB		05Bh,030h,03Bh,033h,034h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h
		DB		0B1h,00Dh,00Ah,01Bh,05Bh,032h,039h,043h,01Bh,05Bh,031h,03Bh,033h,033h,06Dh
		DB		0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,020h,020h,01Bh,05Bh,030h
		DB		03Bh,033h,034h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh
		DB		00Ah,01Bh,05Bh,031h,037h,043h,01Bh,05Bh,031h,03Bh,033h,033h,06Dh,059h,065h
		DB		06Ch,06Ch,06Fh,077h,03Dh,022h,031h,022h,020h,020h,0B1h,0B1h,0B1h,0B1h,0B1h
		DB		0B1h,0B1h,0B1h,0B1h,0B1h,020h,020h,01Bh,05Bh,030h,03Bh,033h,034h,06Dh,0B1h
		DB		0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,020h,020h,022h,032h,022h,03Dh
		DB		042h,06Ch,075h,065h,00Dh,00Ah,01Bh,05Bh,032h,039h,043h,01Bh,05Bh,031h,03Bh
		DB		033h,033h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,020h,020h
		DB		01Bh,05Bh,030h,03Bh,033h,034h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h
		DB		0B1h,0B1h,00Dh,00Ah,01Bh,05Bh,032h,039h,043h,01Bh,05Bh,031h,03Bh,033h,033h
		DB		06Dh,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,020h,020h,01Bh,05Bh
		DB		030h,03Bh,033h,034h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h
		DB		020h,020h,01Bh,05Bh,031h,03Bh,033h,030h,06Dh,022h,051h,022h,020h,074h,06Fh
		DB		020h,071h,075h,069h,074h,020h,061h,06Eh,064h,00Dh,00Ah,01Bh,05Bh,032h,039h
		DB		043h,01Bh,05Bh,033h,033h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h
		DB		0B1h,020h,020h,01Bh,05Bh,030h,03Bh,033h,034h,06Dh,0B1h,0B1h,0B1h,0B1h,0B1h
		DB		0B1h,0B1h,0B1h,0B1h,0B1h,020h,020h,020h,01Bh,05Bh,031h,03Bh,033h,030h,06Dh
		DB		072h,065h,074h,075h,072h,06Eh,020h,074h,06Fh,020h,04Dh,04Fh,053h,02Eh,00Dh
		DB		00Ah,00Dh,00Ah,00Dh,00Ah,01Bh,05Bh,032h,039h,043h,01Bh,05Bh,035h,03Bh,033h
		DB		033h,03Bh,034h,034h,06Dh,050h,072h,065h,073h,073h,020h,061h,020h,06Bh,065h
		DB		079h,020h,074h,06Fh,020h,062h,065h,067h,069h,06Eh,021h,021h,01Bh,05Bh,034h
		DB		030h,06Dh,00Dh,00Ah,00Dh,00Ah,00Dh,00Ah,00Dh,00Ah,01Bh,05Bh,030h,06Dh,01Bh
		DB		05Bh,032h,035h,035h,044h,024h
OFFGRN	DB		01Bh,05Bh,036h,03Bh,033h,030h,048h,01Bh,05Bh,030h,03Bh,033h,032h,06Dh
		DB		0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,024h
ONGRN	DB		01Bh,05Bh,036h,03Bh,033h,030h,048h,01Bh,05Bh,030h,03Bh,033h,032h,06Dh
		DB		0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,024h
OFFYLW	DB		01Bh,05Bh,031h,033h,03Bh,033h,030h,048h,01Bh,05Bh,031h,03Bh,033h,033h,06Dh
		DB		0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,024h
ONYLW	DB		01Bh,05Bh,031h,033h,03Bh,033h,030h,048h,01Bh,05Bh,031h,03Bh,033h,033h,06Dh
		DB		0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,032h,039h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,024h
OFFRED	DB		01Bh,05Bh,036h,03Bh,034h,032h,048h,01Bh,05Bh,030h,03Bh,033h,031h,06Dh
		DB		0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,024h
ONRED	DB		01Bh,05Bh,036h,03Bh,034h,032h,048h,01Bh,05Bh,030h,03Bh,033h,031h,06Dh
		DB		0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,024h
OFFBLU	DB		01Bh,05Bh,031h,033h,03Bh,034h,032h,048h,01Bh,05Bh,030h,03Bh,033h,034h,06Dh
		DB		0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,0B1h,024h
ONBLU	DB		01Bh,05Bh,031h,033h,03Bh,034h,032h,048h,01Bh,05Bh,030h,03Bh,033h,034h,06Dh
		DB		0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,00Dh,00Ah
		DB		01Bh,05Bh,034h,031h,043h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh,024h
SEQLEN	DB		000h
DLAY	DS		002h
RNDNMS	DS		032h
; Listing ends.
		END
		
