# ECHO8085
## A "follow me" memory game in the tradition of Simon, written for the EMAC, Inc. "The Primer" Intel 8085 CPU trainer.

### The Hardware & Development Environment.
[EMAC, Inc. Equipment Monitor And Control](http://emacinc.com/) offers ["The Primer" Trainer](http://emacinc.com/primer-trainer) as "a low cost 8085 based training tool developed specifically for learning the operation of today's microprocessor based systems."

The base unit features:
- Intel 8085 Microprocessor
- Intel 8155 Programmable I/O Interface with a 14-bit Timer
- Intel 8279 Compatible Keypad and Display Controller
- 20-key Keypad
- 6 Digit, 7 Segment LED Display
- 8 Position DIP Switch
- 8 Bit Output Port with LEDs
- A/D and D/A Convertors
- Timer Output with Speaker

ECHO8085 requires the *Standard Upgrade Option* which includes:
- Intel 8251 UART Serial Controller
- 32K Battery-backed RAM
- Intel HEX File Upload Support

The development environment that is used to write, debug, and play ECHO8085 consists of:
- an Ubuntu PC
- an FTDI USB to Serial Adapter
- [DOSBox](https://www.dosbox.com/), an x86 Emulator with DOS
- ma85.exe, a DOS-based i8085 cross-assembler provided by EMAC, Inc. with The Primer
- [ProComm](https://en.wikipedia.org/wiki/Datastorm_Technologies), a DOS-based terminal emulator with great ANSI support
- [TheDraw](https://en.wikipedia.org/wiki/TheDraw), a DOS-based editor for ANSI & ASCII graphics
Alternative tools could serve similar purposes in this environment.

### The Game
ECHO8085 is a memory game modeled after [Simon](https://en.wikipedia.org/wiki/Simon_(game)). The computer creates a random sequence of flashing "light" and tone combinations, which increases in length by one each time the player repeats the sequence correctly. If the sequence is not repeated correctly, the game ends.

User interaction is via a serial console keyboard and monitor, and ANSI graphics support is required. ANSI graphics are used to draw the game introductory splash screen, along with the gameboard and its four flashing squares of color. The tones are played through The Primer's onboard speaker, so the serial console must be in hearing range of the Primer running the game. The length of each light/tone combination when the sequence is presented by the computer can be configured via the eight-position DIP switch on the Primer.

A maximum sequence duration of 50 steps is hard-coded into the game, so it is possible to "beat" the computer.

### In Action
A [YouTube video](https://www.youtube.com/watch?v=wtKz_fCiLA4) of the game in action is available.
