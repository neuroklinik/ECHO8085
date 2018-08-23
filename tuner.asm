; Tuner
; Produces MOS-generated PITCH tones,
; for the purpose of tuning to a musical scale.
; Serial console is used to read keystrokes for
; coarse and fine tuning.
; 14-bit pitch value is displayed on 7-segment LEDs.

		ORG		0C000h
; Print intro and instructions to Console.
		MVI		C,PSTR
		LXI		D,SPLASH
		CALL	MOS
; Load starting pitch.
		LXI		D,BGTONE
; Play tone.
PLAY		MVI		C,PITCH
		CALL	MOS
; Write current value to 7-segment LEDs.
		MVI		C,LEDHEX
		CALL	MOS
; Loop waiting for console keystrokes, changing
; tone until "5" is pressed to return to MOS.
		; Get ASCII character from console keypress.
KEYIN	MVI		C,CONIN
		CALL	MOS
		MOV	A,L
		; Comparisons and jumps to handle the possible keys.
		CPI		CRSUPK
		JZ		CRSUPR
		CPI		CRSDNK
		JZ		CRSDNR
		CPI		FINUPK
		JZ		FINUPR
		CPI		FINDNK
		JZ		FINDNR
		CPI		RTMOSK
		JZ		RTMOSR
		JMP		KEYIN
FINUPR	INX		D
		JMP		PLAY
FINDNR	DCX		D
		JMP		PLAY
CRSUPR	XCHG
		LXI		D,0010h
		DAD		D
		XCHG
		JMP		PLAY
CRSDNR	XCHG
		LXI		D,0010h
		MOV	A,D
		CMA
		MOV	D,A
		MOV	A,E
		CMA
		MOV	E,A
		INX		D
		DAD		D
		XCHG
		JMP		PLAY
; Turn off the sound, and return to MOS.
RTMOSR	LXI		D,0h
		MVI		C,PITCH
		CALL	MOS
		RST		7

; EMAC MOS Service Calls
MOS		EQU		01000h
PSTR	EQU		04h
		; In:		Register DE; starting addr. of string.
		; Out:	Register DE; addr. after "$" string terminator.
CONIN	EQU		01h
		; Out:	Register L; ASCII char. returned from console keyboard.
PITCH	EQU		010h
		; In:		Register DE; 14-bit pitch value.
DELAY	EQU		014h
		; In:		Register HL; amount of delay, larger is longer.
LEDSTR	EQU		01Ah
		; In:		Register E; number of displays to change (1-6).
		; In:		Register D; starting display (5-0).
		; In:		Register HL; starting addr. of bit pattern data.
LEDHEX	EQU		012h
		; In:		Register DE; 16-bit number to be displayed in hex.
		
; Constants.
SPLASH	DB		045h,04Dh,041h,043h,020h,022h,054h,068h,065h,020h,050h,072h,069h,06Dh,065h
		DB		072h,022h,020h,050h,069h,074h,063h,068h,020h,054h,075h,06Eh,065h,072h,00Dh
		DB		00Ah,057h,072h,069h,074h,074h,065h,06Eh,020h,069h,06Eh,020h,038h,030h,038h
		DB		035h,020h,061h,073h,073h,065h,06Dh,062h,06Ch,079h,020h,06Ch,061h,06Eh,067h
		DB		075h,061h,067h,065h,020h,062h,079h,020h,043h,068h,072h,069h,073h,074h,06Fh
		DB		070h,068h,065h,072h,020h,046h,06Fh,078h,02Eh,00Dh,00Ah,041h,070h,072h,069h
		DB		06Ch,020h,032h,030h,031h,035h,00Dh,00Ah,00Dh,00Ah,04Bh,065h,079h,073h,03Ah
		DB		00Dh,00Ah,00Dh,00Ah,038h,020h,03Dh,020h,043h,06Fh,061h,072h,073h,065h,020h
		DB		074h,075h,06Eh,069h,06Eh,067h,020h,075h,070h,02Ch,020h,062h,079h,020h,031h
		DB		030h,068h,02Eh,00Dh,00Ah,032h,020h,03Dh,020h,043h,06Fh,061h,072h,073h,065h
		DB		020h,074h,075h,06Eh,069h,06Eh,067h,020h,064h,06Fh,077h,06Eh,02Ch,020h,062h
		DB		079h,020h,031h,030h,068h,02Eh,00Dh,00Ah,034h,020h,03Dh,020h,046h,069h,06Eh
		DB		065h,020h,074h,075h,06Eh,069h,06Eh,067h,020h,064h,06Fh,077h,06Eh,02Ch,020h
		DB		062h,079h,020h,030h,031h,068h,02Eh,00Dh,00Ah,036h,020h,03Dh,020h,046h,069h
		DB		06Eh,065h,020h,074h,075h,06Eh,069h,06Eh,067h,020h,075h,070h,02Ch,020h,062h
		DB		079h,020h,030h,031h,068h,02Eh,00Dh,00Ah,00Dh,00Ah,035h,020h,03Dh,020h,052h
		DB		065h,074h,075h,072h,06Eh,020h,074h,06Fh,020h,04Dh,04Fh,053h,02Eh,00Dh,00Ah
		DB		024h
CRSUPK	EQU		038h ; "8"
CRSDNK	EQU		032h ; "2"
FINUPK	EQU		036h ; "6"
FINDNK	EQU		034h ; "4"
RTMOSK	EQU		035h ; "5"
BGTONE	EQU		02000h
MXTONE	EQU		03FFFh

		END
		