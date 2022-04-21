; Hellway! 
; Thanks to AtariAge and all available online docs 
	processor 6502
	include vcs.h
	include macro.h
	org $F000
	
;contants
SCREEN_SIZE = 72;(VSy)
SCORE_SIZE = 5
GAMEPLAY_AREA = SCREEN_SIZE - SCORE_SIZE - 1;
FONT_OFFSET = #SCORE_SIZE -1
COLLISION_FRAMES = $FF; 4,5 seconds
SCORE_FONT_HOLD_CHANGE = $FF; 4,5 seconds
COLLISION_SPEED_L = $10;

WARN_TIME_ENDING = 10 ; Exclusive

TRAFFIC_LINE_COUNT = 4
;16 bit precision
;640 max speed!
CAR_MAX_SPEED_H = $02; L is in a table

CAR_MIN_SPEED_H = 0
CAR_MIN_SPEED_L = 0
CAR_START_LINE = 15 ; Exclusive

CAR_ID_DEFAULT = 0
CAR_ID_HATCHBACK = 1
CAR_ID_SEDAN = 2
CAR_ID_DRAGSTER = 3

DRAGSTER_TURN_MASK = %00000001;

BREAK_SPEED = 10
;For now, will use in all rows until figure out if make it dynamic or not.
TRAFFIC_1_MASK = %11111000 ;Min car size... Maybe make different per track

TRAFFIC_CHANCE_LIGHT = 14
CHECKPOINT_TIME_LIGHT = 29
TRAFFIC_COLOR_LIGHT = $D4

TRAFFIC_CHANCE_REGULAR = 23
CHECKPOINT_TIME_REGULAR = 34
TRAFFIC_COLOR_REGULAR = $34

TRAFFIC_CHANCE_INTENSE = 32
CHECKPOINT_TIME_INTENSE = 39
TRAFFIC_COLOR_INTENSE = $79

TRAFFIC_CHANCE_RUSH_HOUR = 40
CHECKPOINT_TIME_RUSH_HOUR = 44
TRAFFIC_COLOR_RUSH_HOUR = $09

BACKGROUND_COLOR = $00

GREY_BACKGROUND_COLOR = $03

SCORE_FONT_COLOR_GOOD = $37
OP_SCORE_FONT_COLOR_GOOD = $D8

SCORE_FONT_COLOR_BAD = $44
OP_SCORE_FONT_COLOR_BAD = $56

SCORE_FONT_COLOR_START = $38 ;Cannot be the same as good, font colors = game state
OP_SCORE_FONT_COLOR_START = $C8 ;Cannot be the same as good, font colors = game state

SCORE_FONT_COLOR_OVER = $0C
OP_SCORE_FONT_COLOR_OVER = $AB

PLAYER0_COLOR = $F9
PLAYER1_COLOR = $98

PLAYER_0_X_START = 32;
PLAYER_1_X_START = 41;
PLAYER_MAX_X = 44 ; Going left will underflow to FF, so it only have to be less (unsigned) than this

INITIAL_COUNTDOWN_TIME = 90; Seconds +-
CHECKPOINT_INTERVAL = $10 ; Acts uppon TrafficOffset0 + 3
TIMEOVER_BREAK_SPEED = 1

SWITCHES_DEBOUNCE_TIME = 30 ; Frames

BLACK = $00;

MAX_GAME_MODE = 16

PARALLAX_SIZE = 8

HALF_TEXT_SIZE = 5

ONE_SECOND_FRAMES = 60

QR_CODE_LINE_HEIGHT = 7
QR_CODE_BACKGROUNG = $0F
QR_CODE_COLOR = $00
QR_CODE_SIZE = 25

CURRENT_CAR_MASK = %00000011; 4 cars

;43 default, one less line 2 We start the drawing cycle after 36 lines, because drawing is delayed by one line. 
VBLANK_TIMER = 41
;Almost no game processing with QR code. This gives bleading space by reducing vblank (Still acceptable limits)
VBLANK_TIMER_QR_CODE = 26 ; 22 lines 

ENGINE_VOLUME = 8

CAR_SIZE = 8
	
GRP0Cache = $80
PF0Cache = $81
PF1Cache = $82
PF2Cache = $83
GRP1Cache = $84
ENABLCache = $85
ENAM0Cache = $86
ENAM1Cache = $87

FrameCount0 = $8C;
FrameCount1 = $8D;

CollisionCounter=$8E
OpCollisionCounter=$8F

; The cache could shared, and just written in the correct frame (used for drawing), saving 4 bytes.
TrafficOffset0 = $90; Border $91 $92 (24 bit) $93 is cache
TrafficOffset1 = $94; Traffic 1 $95 $96 (24 bit) $97 is cache
TrafficOffset2 = $98; Traffic 2 $99 $9A (24 bit) $9B is cache
TrafficOffset3 = $9C; Traffic 3 $9D $9E (24 bit) $9F is cache
OpTrafficOffset0 = $A0; Border $A1 $A2 (24 bit) $A3 is cache
OpTrafficOffset1 = $A4; Border $A5 $A6 (24 bit) $A7 is cache
OpTrafficOffset2 = $A8; Border $A9 $AA (24 bit) $AB is cache
OpTrafficOffset3 = $AC; Border $AD $AE (24 bit) $AF is cache

;Temporary variables, multiple uses
Tmp0 = $B0
Tmp1 = $B1
Tmp2 = $B2
Tmp3 = $B3
Tmp4 = $B4
Tmp5 = $B5

Player0X = $B6
Player1X = $B7
CountdownTimer = $B8
OpCountdownTimer = $B9
Traffic0Msb = $BA
OpTraffic0Msb = $BB
SwitchDebounceCounter = $BC
GameStatus = $BD ; Not zero is running! No need to make it a bit flag for now.
TrafficChance = $BE
OpTrafficChance = $BF

CheckpointTime = $C0
OpCheckpointTime = $C1
TrafficColor = $C2
OpTrafficColor = $C3
CurrentDifficulty = $C4
OpCurrentDifficulty = $C5
GameMode = $C6 ; Bit 0 controls fixed levels, bit 1 random positions, Bit 2 speed delta, Bit 3 random traffic 

CurrentCarId = $C7
OpCurrentCarId = $C8

ScoreFontColor=$C9
OpScoreFontColor=$CA
ScoreFontColorHoldChange=$CB
OpScoreFontColorHoldChange=$CC
NextCheckpoint=$CD
OpNextCheckpoint=$CE
OpponentLine = $CF 

ScoreD0 = $D0
ScoreD1 = $D1
ScoreD2 = $D2
ScoreD3 = $D3
ScoreD4 = $D4

Gear = $D5
OpGear = $D6

CarSpritePointerL = $D7
CarSpritePointerH = $D8

EnemyCarSpritePointerL = $D9
EnemyCarSpritePointerH = $DA

EnableRubberBadding = $DB 

AccelerateBuffer = $DC ; Change speed on buffer overflow.
OpAccelerateBuffer = $DD ; Change speed on buffer overflow.

Player0SpeedL = $DE
Player1SpeedL = $DF
Player0SpeedH = $F0
Player1SpeedH = $F1

IsOpponentInFront = $F2 ; Bit 7 tells if negative or positive.

BackgroundColor = $F3


;generic start up stuff, put zero in almost all...
BeforeStart ;All variables that are kept on game reset or select
	LDY #0
	STY SwitchDebounceCounter
	STY CurrentDifficulty
    STY OpCurrentDifficulty
	STY GameStatus
    STY CurrentCarId
    STY OpCurrentCarId
    STY EnableRubberBadding ; Triggered to 1 on first run
	LDY #16
	STY GameMode

Start
	LDA #2
	STA VSYNC
	STA WSYNC
	STA WSYNC
	STA WSYNC
	LDA #0 ;2
	STA VSYNC ;3

	SEI	
	CLD 	
	LDX #$FF	
	TXS	

	LDX #68 ; Skips (VSYNC, RSYNC, WSYNC, VBLANK), TIA is mirrored on 64 - 127
CleanMem 
	CPX #SwitchDebounceCounter
	BEQ SkipClean
	CPX #GameMode
	BEQ SkipClean
	CPX #CurrentCarId
	BEQ SkipClean
    CPX #OpCurrentCarId
	BEQ SkipClean
	CPX #CurrentDifficulty
	BEQ SkipClean
    CPX #OpCurrentDifficulty
	BEQ SkipClean
	CPX #GameStatus
	BEQ SkipClean
    CPX #EnableRubberBadding
    BEQ SkipClean
	STA 0,X		
SkipClean	
	INX
	BNE CleanMem

	LDA #190 ; needs change if memory clean routine changes
	STA TIM64T ;3	

;Setting some variables...

SaveOldDifficulty
    LDA CurrentDifficulty
    STA Tmp5 ; Used to define if toggles rubberband

SettingTrafficOffsets; Time sensitive with player H position
	STA WSYNC ;We will set player position
	JSR DefaultOffsets

	LDA TrafficSpeeds + 4 * 2 ; Same as the line he is in.
	STA Player0SpeedL
    STA Player1SpeedL
	
	;SLEEP 11;18
	LDX #0
	LDA SWCHB ; Reading the switches and mapping to difficulty id
	AND #%11000000
	BEQ StoreCurrentDifficulty
	INX
	CMP #%10000000
	BEQ StoreCurrentDifficulty
	INX
	CMP #%01000000
	BEQ StoreCurrentDifficulty
	INX

StoreCurrentDifficulty
	STX CurrentDifficulty
    STX OpCurrentDifficulty
    LDX #0
	JSR ConfigureDifficulty
    INX
	JSR ConfigureDifficulty

ToggleRubberBanding
    LDA GameStatus
    BNE SetGameNotRunning ; Do not toggle if game running
    LDA Tmp5 ; old difficulty
    CMP CurrentDifficulty
    BNE SetGameNotRunning ; Do not toggle if change difficulty
    LDA EnableRubberBadding
    EOR #%00000001
    STA EnableRubberBadding

SetGameNotRunning
	LDA #0
	STA GameStatus

ConfigureTimer
    LDA #INITIAL_COUNTDOWN_TIME ;2
	STA CountdownTimer ;3
    STA OpCountdownTimer ;3

ConfigurePlayer1XPosition
    LDA #PLAYER_1_X_START ;2
	STA Player1X ;3

ConfigureOpNextCheckpoint
    LDA #CHECKPOINT_INTERVAL
	STA OpNextCheckpoint

HPositioning ; Avoid sleep doing needed stuff
	STA WSYNC

ConfigurePlayer0XPosition
    LDA #PLAYER_0_X_START ;2
	STA Player0X ;3

ConfigureMissileSize
    LDA #%00110000;2 Missile Size
	STA NUSIZ0 ;3
	STA NUSIZ1 ;3

ConfigureNextCheckpoint
    LDA #CHECKPOINT_INTERVAL
	STA NextCheckpoint

	LDA #0 ; Avoid missile reseting position 
	;SLEEP 41
    SLEEP 5;
	STA RESM0
	SLEEP 2;
	STA RESBL
	SLEEP 2
	STA RESM1
    SLEEP 3

	LDA #$D0
	STA HMBL
	STA HMM0
	STA HMM1
	STA WSYNC
	STA HMOVE
	STA WSYNC ; Time is irrelevant before sync to TV, ROM space is not!
	STA HMCLR
    SLEEP 31
    STA RESP0
    STA RESP1

WaitResetToEnd
	LDA INTIM	
	BNE WaitResetToEnd

MainLoop
	LDA #2
	STA VSYNC	
	STA WSYNC
    STA HMOVE  ;2 Apply Movement, must be done after a WSYNC
    ;Some free cycles here!
PrepareMaxHMove
    LDA SWCHB
    AND #%00001000
    BEQ GreyBackground
    LDA #BACKGROUND_COLOR
    JMP StoreBackground
GreyBackground
    LDA #GREY_BACKGROUND_COLOR;
StoreBackground
	STA COLUBK
    STA BackgroundColor
    SLEEP 24 - 15 ; Ensures "Should not be modified during the 24 computer cycles immediately following an HMOVE" 11 is the minimun cycles used until here
    LDA #$80
    STA HMBL
	STA HMM0
	STA HMM1
    STA HMP0
    STA HMP1
	STA WSYNC
    STA HMOVE ; 1/10			

ConfigVBlankTimer
	LDA GameMode
	CMP #MAX_GAME_MODE
	BEQ SetVblankTimerQrCode
	LDA #VBLANK_TIMER
	JMP SetVblankTimer
SetVblankTimerQrCode
	LDA #VBLANK_TIMER_QR_CODE

SetVblankTimer
	STA WSYNC ;3
	STA TIM64T ;3	
	LDA #0 ;2
	STA VSYNC ;3	

RandomizeGame
	LDA GameStatus ;Could be merge with code block bellow
	BNE EndRandomizeGame
	LDA GameMode ; Games 3 and for and not running
	AND #%00000010
	BEQ DeterministicGame
	LDX TrafficOffset1 + 2
	LDA AesTable,X
	EOR FrameCount0
	STA TrafficOffset1 + 2
    STA OpTrafficOffset1 + 2
	LDX TrafficOffset2 + 2
	LDA AesTable,X
	EOR FrameCount0
	STA TrafficOffset2 + 2
    STA OpTrafficOffset2 + 2
	LDX TrafficOffset3 + 2
	LDA AesTable,X
	EOR FrameCount0
	STA TrafficOffset3 + 2
    STA OpTrafficOffset3 + 2
	JMP EndRandomizeGame

DeterministicGame
	JSR DefaultOffsets

EndRandomizeGame

CountFrame	
	INC FrameCount0 ; 5
	BNE SkipIncFC1 ; 2 When it is zero again should increase the MSB
	INC FrameCount1 ; 5 
SkipIncFC1

CallDrawQrCode
	LDA GameMode
	CMP #MAX_GAME_MODE
	BNE TestIsGameRunning
	JMP DrawQrCode

;Does not update the game if not running
TestIsGameRunning
	LDA GameStatus ;3
	BNE ContinueWithGameLogic ;3 Cannot branch more than 128 bytes, so we have to use JMP
SelectCarWithDpadCall ; Only do it when game is stoped
    LDX #0 ; Player 0
    LDA #%10000000 ;SWCHA Mask, it ends the call in the correct value for Player 1 call
    STA Tmp0
    JSR SelectCarWithDpad
    INX ; Player 1
    JSR SelectCarWithDpad

    ; Needs to draw the opponent in the correct line even when game stoped  
    ; Draeing is a destructive operation
    JSR ProcessOpponentLineAndPlayerSprite

SkipUpdateLogicJump
	JMP SkipUpdateLogic
ContinueWithGameLogic

CallEverySecond ; Timer for now
    LDX #0
    JSR EverySecond
    INX 
    JSR EverySecond

CallProcessSpeed
    LDX #0
    JSR ProcessSpeed

    INX ; Player 1
    JSR ProcessSpeed

CallUpdateOffsets
    LDX #0 ; Player 0
    LDA #TRAFFIC_LINE_COUNT * 4 ; Max X
    STA Tmp3 ;Tmp 0,1,2 used by SBR
    LDA Player0SpeedL
    STA Tmp4
    LDA Player0SpeedH
    STA Tmp5
    JSR UpdateOffsets

    ;LDX Exits the call with correct value.
    LDA #TRAFFIC_LINE_COUNT * 4 * 2 ; Max X
    STA Tmp3 
    LDA Player1SpeedL
    STA Tmp4
    LDA Player1SpeedH
    STA Tmp5
    JSR UpdateOffsets

CallProcessOpponentLine
    JSR ProcessOpponentLineAndPlayerSprite

SkipUpdateLogic ; Continue here if not paused

CallCalculateGear
    LDX #0
    JSR CalculateGear
    INX
    JSR CalculateGear

CallProcessFontColor
    LDA FrameCount0
    AND #%00000001
    BNE ContinueProcessFontColorPlayer0 ; Not my frame, always process!
    LDA EnableRubberBadding ; Rubber Band Switch
    BEQ ContinueProcessFontColorPlayer0
    LDA IsOpponentInFront
    BEQ ContinueProcessFontColorPlayer0 ; Oponent not in front
    LDA ScoreFontColor
    CMP #SCORE_FONT_COLOR_GOOD
    BEQ ContinueProcessFontColorPlayer1 ; Opponent is in front! Skip counting checkpoint for the frame (double time)
ContinueProcessFontColorPlayer0
    LDX #0
    JSR ProcessScoreFontColor
ContinueProcessIsToUpdateColorPlayer1
    LDA FrameCount0
    AND #%00000001
    BEQ ContinueProcessFontColorPlayer1 ; Not my frame, always process!
    LDA EnableRubberBadding ; Rubber Band Switch
    BEQ ContinueProcessFontColorPlayer1
    LDA IsOpponentInFront
    BEQ ContinueProcessFontColorPlayer1 ; Oponent not in front
    LDA OpScoreFontColor
    CMP #OP_SCORE_FONT_COLOR_GOOD
    BEQ SkipProcessFontColor ; Opponent is in front and is checkpoint Skip counting checkpoint for the frame (double time)
ContinueProcessFontColorPlayer1
    LDX #1
    JSR ProcessScoreFontColor
SkipProcessFontColor

CallProcessPlayerStatus ; Only when visible, status depends on opponent line, 1 frame max delay is ok.
    LDA FrameCount0
    AND #%00000001
    BNE CallProcessPlayer1Status
CallProcessPlayer0Status
    LDA TrafficOffset0 + 2 ; Not sequential to OpTrafficOffset0
    STA Tmp0
    LDX #0
    JSR ProcessPlayerStatus
    JMP EndCallProcessPlayerStatus
CallProcessPlayer1Status
    LDA OpTrafficOffset0 + 2
    STA Tmp0
    LDX #1
    JSR ProcessPlayerStatus
EndCallProcessPlayerStatus

CallProcessSound ; We might save cycles by updating one channel per frame.
    LDX #0
    LDA TrafficOffset0 + 2
    STA Tmp1
    JSR ProcessSound
    INX ; Player 1
    LDA OpTrafficOffset0 + 2
    STA Tmp1
    JSR ProcessSound

ChooseTextSide ; 
	LDA FrameCount0 ;3
    AND #%00000001
	BEQ LeftScoreWrite ; Half of the screen with the correct colors.
	JMP RightScoreWrite 

LeftScoreWrite
	LDA GameStatus
	BEQ PrintHellwayLeft
	LDA ScoreFontColor
	CMP #SCORE_FONT_COLOR_GOOD
	BEQ PrintPlayer0Checkpoint
	CMP #SCORE_FONT_COLOR_START
	BEQ PrintPlayer0StartGame
    CMP #SCORE_FONT_COLOR_OVER
	BEQ ProcessPlayer0OverText
ContinueP0Score
    JMP Digit0Timer

PrintHellwayLeft
    LDA INPT4 ; Joystick is pressed, show ready!
    BMI ContinueWithDefaultLeftText
Player0IsReady
    LDX #<ReadyText
    JSR PrintStaticText
    JMP RightScoreWriteEnd;3
ContinueWithDefaultLeftText
	LDA FrameCount1
	AND #1
	BNE PrintCreditsLeft
	LDX #<HellwayLeftText - 1 ; Padding
	JMP PrintGameMode
PrintCreditsLeft
	LDX #<OpbText - 1 ; Padding

PrintGameMode
	JSR PrintStaticText
	LDX GameMode
	LDA FontLookup,X ;4 
	STA ScoreD0 ;3
	JMP RightScoreWriteEnd;3

ProcessPlayer0OverText
    LDA IsOpponentInFront
    BMI PrintPlayer0Lose
PrintPlayer0Win
    LDX #<WinText
    JMP PrintPlayer0Status
PrintPlayer0Lose
    LDX #<LoseText
PrintPlayer0Status
    JSR PrintStaticText
    JMP DistanceCheckpointCount;3

PrintPlayer0Checkpoint
	LDX #<CheckpointText
	JSR PrintStaticText
	JMP PrintPlayer0ScoreHoldChange;3
    
PrintPlayer0StartGame
	LDX #<GoText
	JSR PrintStaticText

PrintPlayer0ScoreHoldChange
    LDX #0
    JSR PrintScoreHoldChange
    STA ScoreD4
	JMP RightScoreWriteEnd;3

Digit0Timer
	LDA CountdownTimer ;3
    STA Tmp0
    JSR BINBCD8
    ; LDA Tmp1 Also returned in A
	AND #%00001111 ;2
	TAX ; 2
	LDA FontLookup,X ;4 
	STA ScoreD1 ;3

Digit1Timer
	LDA Tmp1 ;3 ; Converted to BCD in digit 0
	LSR ; 2
	LSR ; 2
	LSR ; 2
	LSR ; 2
	TAX ; 2
	LDA FontLookup,X ;4
	STA ScoreD0 ;3

SpeedBar
	LDX #0
    JSR PrintSpeedBar

DistanceCheckpointCount ; Will run all letters in the future
    LDA Traffic0Msb
    AND #%00000001
    ASL
    ASL
    ASL
    ASL
    STA Tmp0
    LDA TrafficOffset0 + 2 ;3
	AND #%11110000 ;2
    LSR
    LSR
    LSR
    LSR
    ORA Tmp0
	TAX ; 2
	LDA FontLookup,X ;4 
	STA ScoreD3 ;3

DistanceBar ; 16 subdivisions per checkpoint
	LDA TrafficOffset0 + 2 ;3
	AND #%00001111 ;2
	TAX ; 2
	LDA BarLookup,X ;4 
	STA ScoreD4 ;3

EndDrawDistance
	JMP RightScoreWriteEnd;3

RightScoreWrite
	LDA GameStatus
	BEQ PrintHellwayRight
	LDA OpScoreFontColor
    CMP #OP_SCORE_FONT_COLOR_GOOD
	BEQ PrintPlayer1Checkpoint
    CMP #OP_SCORE_FONT_COLOR_START
	BEQ PrintPlayer1StartGame
    CMP #OP_SCORE_FONT_COLOR_OVER
	BEQ ProcessPlayer1OverText
ContinueP1Score
    JMP OpDigit0Timer
    
PrintHellwayRight
    LDA INPT5 ; Joystick is pressed, show ready!
    BMI ContinueWithDefaultRightText
Player1IsReady
    LDX #<ReadyText
    JSR PrintStaticText
    JMP RightScoreWriteEnd;3
ContinueWithDefaultRightText
	LDA FrameCount1
	AND #1
	BNE PrintCreditsRight
	LDX #<HellwayRightText
	JMP PrintRightIntro
PrintCreditsRight
    LDA FrameCount1
	AND #%00000010
    BEQ PrintYearText
PrintBuildNumberText
    LDX #<BuildNumberText
    BNE PrintRightIntro ; Save one byte, it will neve be equal in not first text constant...
PrintYearText
	LDX #<YearText
PrintRightIntro
	JSR PrintStaticText
PipeOnRuberBandOff
    LDA EnableRubberBadding
    BNE EndPrintHellwayRight
    LDA #<Pipe + FONT_OFFSET
    STA ScoreD0
EndPrintHellwayRight
	JMP RightScoreWriteEnd

ProcessPlayer1OverText
    LDA IsOpponentInFront
    BMI PrintPlayer1Lose
PrintPlayer1Win
    LDX #<WinText - 2
    JMP PrintPlayer1Status
PrintPlayer1Lose
    LDX #<LoseText - 2
PrintPlayer1Status
    JSR PrintStaticText
    JMP OpDistanceCheckpointCount

PrintPlayer1Checkpoint
	LDX #<CheckpointText - 1
	JSR PrintStaticText
	JMP PrintPlayer1ScoreHoldChange;3
    
PrintPlayer1StartGame
	LDX #<GoText - 1
	JSR PrintStaticText

PrintPlayer1ScoreHoldChange
    LDX #1
    JSR PrintScoreHoldChange
    STA ScoreD0
	JMP RightScoreWriteEnd;3

OpDigit0Timer
    LDA OpCountdownTimer ;3
    STA Tmp0
    JSR BINBCD8
    ; LDA Tmp1 Also returned in A
	AND #%00001111 ;2
	TAX ; 2
	LDA FontLookup,X ;4 
	STA ScoreD4 ;3

OpDigit1Timer
	LDA Tmp1 ;3
	LSR ; 2
	LSR ; 2
	LSR ; 2
	LSR ; 2
	TAX ; 2
	LDA FontLookup,X ;4
	STA ScoreD3 ;3

OpSpeedBar
	LDX #1
    JSR PrintSpeedBar

OpDistanceCheckpointCount
    LDA OpTraffic0Msb
    AND #%00000001
    ASL
    ASL
    ASL
    ASL
    STA Tmp0
    LDA OpTrafficOffset0 + 2 ;3
	AND #%11110000 ;2
    LSR
    LSR
    LSR
    LSR
    ORA Tmp0
	TAX ; 2
	LDA FontLookup,X ;4 
	STA ScoreD1 ;3

OpDistanceBar ; 16 subdivisions per checkpoint
	LDA OpTrafficOffset0 + 2 ;3
	AND #%00001111 ;2
	TAX ; 2
	LDA BarLookup,X ;4 
	STA ScoreD0 ;3

ScoreWriteEnd
RightScoreWriteEnd

ConfigurePFForScore
	JSR ClearAll
	LDA #%00000010 ; Score mode
	STA CTRLPF
	LDA FrameCount0 ;3
    AND #%00000001
	BEQ LeftScoreOn ; Half of the screen with the correct colors.
RightScoreOn
	LDA OpScoreFontColor
	STA COLUP1
	LDA BackgroundColor
	STA COLUP0
	JMP CallWaitForVblankEnd
LeftScoreOn
	LDA ScoreFontColor
	STA COLUP0
	LDA BackgroundColor
	STA COLUP1

; After here we are going to update the screen, No more heavy code
CallWaitForVblankEnd
    ;SLEEP 222 ;Force the game to its limits and check if no line count issue.
	JSR WaitForVblankEnd

DrawScoreHud
	JSR PrintScore

	STA WSYNC
	STA WSYNC
    STA HMOVE

PrepareForTraffic
	JSR ClearPF ; 32

	STA WSYNC
    STA HMOVE
	STA WSYNC
    STA HMOVE

	LDA #%00110000 ; 2 Score mode
	STA CTRLPF ;3
	
    LDA FrameCount0;3
    AND #%00000001;2
    TAX ;2
	LDA TrafficColor,X ;4
	STA COLUPF ;3
	
	LDA #PLAYER1_COLOR ;2
	STA COLUP1 ;3

	LDA ScoreFontColor ;3
	STA COLUP0 ;3

    LDA OpScoreFontColor ;3
	STA COLUP1 ;3

	LDY #GAMEPLAY_AREA ;2; (Score)

    LDA FrameCount0 ;Brach flag
    AND #%00000001 

    BNE OpScanLoop ;2
	JMP ScanLoop ;3 Skips the first WSYNC, so the last background line can be draw to the end.
	;The first loop never drans a car, so it is fine this jump uses 3 cycles of the next line.

;main scanline loop...
OpScanLoop
	STA WSYNC ;from the end of the scan loop, sync the final line

	LDA GRP0Cache ;3
	STA GRP0      ;3

	LDA GRP1Cache ;3
	STA GRP1      ;3

	LDA ENABLCache ;3
	STA ENABL      ;3

	LDA ENAM0Cache ;3
	STA ENAM0    ;3

	LDA ENAM1Cache  ;3
	STA ENAM1 ;3

	LDA PF0Cache ;3
	STA PF0	     ;3

	LDA #0		 ;2
    ;STA PF0	     ;3
	STA GRP0Cache ;3
    STA ENAM0Cache ;3
	STA ENABLCache ;3
	STA ENAM1Cache; 3
    ;STA GRP1Cache ;3
    STA PF0        ;3
    ;STA PF2	     ;3

	LDA PF2Cache ;3
	STA PF2	     ;3

OpDrawCar0
	CPY #CAR_START_LINE ;2 ;Saves memory and still fast
	BCS OpSkipDrawCar;2
	LDA (CarSpritePointerL),Y ;5 ;Very fast, in the expense of rom space
	STA GRP1Cache      ;3   ;put it as graphics now
OpSkipDrawCar

	;BEQ DrawTraffic3
OpDrawTraffic1; 33
	TYA; 2
	CLC; 2 
	ADC OpTrafficOffset1 + 1;3
	AND #TRAFFIC_1_MASK ;2 ;#%11111000
	BCS OpEorOffsetWithCarry; 2(worse not to jump), 4 if branch
	EOR OpTrafficOffset1 + 2 ; 3
	JMP OpAfterEorOffsetWithCarry ; 3
OpEorOffsetWithCarry
	EOR OpTrafficOffset1 + 3 ; 3
OpAfterEorOffsetWithCarry ;17
	TAX ;2
	LDA AesTable,X ; 4
	CMP OpTrafficChance;3
	BCS OpFinishDrawTraffic1 ; 2
	LDA #$FF ;2
	STA ENAM0Cache;3
OpFinishDrawTraffic1

OpErasePF2
    LDA #0
    STA PF2

OpDrawTraffic2; 33
	TYA; 2
	CLC; 2 
	ADC OpTrafficOffset2 + 1;3
	AND #TRAFFIC_1_MASK ;2
	BCS OpEorOffsetWithCarry2; 4 max if branch max, 2 otherwise
	EOR OpTrafficOffset2 + 2 ; 3
	JMP OpAfterEorOffsetWithCarry2 ; 3
OpEorOffsetWithCarry2
	EOR OpTrafficOffset2 + 3 ; 3
OpAfterEorOffsetWithCarry2 ;17
	TAX ;2
	LDA AesTable,X ; 4
	CMP OpTrafficChance;3
	BCS OpFinishDrawTraffic2 ; 2
	LDA #%00000010 ;2
	STA ENABLCache;3
OpFinishDrawTraffic2	

	;STA WSYNC ;65 / 137

	; LDA Tmp0 ; Flicker this line if drawing car
	; BEQ FinishDrawTraffic4
OpDrawTraffic3; 33
	TYA; 2
	CLC; 2 
	ADC OpTrafficOffset3 + 1;3
	AND #TRAFFIC_1_MASK ;2
	BCS OpEorOffsetWithCarry3; 4 max if branch max, 2 otherwise
	EOR OpTrafficOffset3 + 2 ; 3
	JMP OpAfterEorOffsetWithCarry3 ; 3
OpEorOffsetWithCarry3
	EOR OpTrafficOffset3 + 3 ; 3
OpAfterEorOffsetWithCarry3 ;17
	TAX ;2
	LDA AesTable,X ; 4
	CMP OpTrafficChance;3
	BCS OpFinishDrawTraffic3 ; 2 
	LDA #%00000010 ;2
	STA ENAM1Cache
OpFinishDrawTraffic3	

OpDrawOpponent ;26
    STY Tmp0 ;3
    LDY OpponentLine ;3
    CPY #(CAR_START_LINE - 8);2
    BCS OpSkipDrawOpponent ;2
OpDrawOpponentVisible
    LDA (EnemyCarSpritePointerL),Y ;5
    STA GRP0Cache ;3
    DEC OpponentLine ;5 ; Waste some bytes (repeated code), but faster
    LDY Tmp0 ;3
    JMP OpHasNoBorderP0 ; Do not draw border to save cycles
OpSkipDrawOpponent
    DEC OpponentLine ;5
    LDY Tmp0 ;3


OpDrawTraffic0; 21 2pe
    TYA; 2
	CLC; 2 
	ADC OpTrafficOffset0 + 1 ;3
    AND #%00001000 ;2
    BEQ OpHasNoBorderP0 ;3
OpHasBorderP0
    LDA #%11100000 ; 2
    JMP OpStoreBorderP0 ; 3
OpHasNoBorderP0
    LDA #0 ; 2
OpStoreBorderP0
    STA PF0Cache ; 3
    STA PF2Cache ; 3

OpSkipDrawTraffic0

OpWhileScanLoop 
	DEY	;2
	BMI OpFinishScanLoop ;2 two big Breach, needs JMP
	JMP OpScanLoop ;3
OpFinishScanLoop ; 7 209 of 222
    JMP FinishScanLoop

;main scanline loop...
ScanLoop 
	STA WSYNC ;from the end of the scan loop, sync the final line

	LDA PF0Cache ;3
	STA PF0	     ;3
	
	LDA GRP0Cache ;3
	STA GRP0      ;3

	LDA GRP1Cache ;3
	STA GRP1      ;3

	LDA ENAM0Cache ;3
	STA ENAM0    ;3

	LDA ENABLCache ;3
	STA ENABL      ;3

	LDA ENAM1Cache  ;3
	STA ENAM1 ;3

	LDA PF2Cache ;3
	STA PF2	     ;3

	LDA #0		 ;2
    STA PF0	     ;3
	STA GRP1Cache ;3
	STA ENABLCache ;3
	STA ENAM0Cache ;3
	STA ENAM1Cache; 3
    ;STA GRP0Cache
    STA PF2	     ;3

DrawCar0
	CPY #CAR_START_LINE ;2 ;Saves memory and still fast
	BCS SkipDrawCar;2
	LDA (CarSpritePointerL),Y ;5 ;Very fast, in the expense of rom space
	STA GRP0Cache      ;3   ;put it as graphics now
SkipDrawCar

	;BEQ DrawTraffic3
DrawTraffic1; 33
	TYA; 2
	CLC; 2 
	ADC TrafficOffset1 + 1;3
	AND #TRAFFIC_1_MASK ;2 ;#%11111000
	BCS EorOffsetWithCarry; 2(worse not to jump), 4 if branch
	EOR TrafficOffset1 + 2 ; 3
	JMP AfterEorOffsetWithCarry ; 3
EorOffsetWithCarry
	EOR TrafficOffset1 + 3 ; 3
AfterEorOffsetWithCarry ;17
	TAX ;2
	LDA AesTable,X ; 4
	CMP TrafficChance;3
	BCS FinishDrawTraffic1 ; 2
	LDA #$FF ;2
	STA ENAM0Cache ;3
FinishDrawTraffic1

DrawTraffic2; 33
	TYA; 2
	CLC; 2 
	ADC TrafficOffset2 + 1;3
	AND #TRAFFIC_1_MASK ;2
	BCS EorOffsetWithCarry2; 4 max if branch max, 2 otherwise
	EOR TrafficOffset2 + 2 ; 3
	JMP AfterEorOffsetWithCarry2 ; 3
EorOffsetWithCarry2
	EOR TrafficOffset2 + 3 ; 3
AfterEorOffsetWithCarry2 ;17
	TAX ;2
	LDA AesTable,X ; 4
	CMP TrafficChance;3
	BCS FinishDrawTraffic2 ; 2
	LDA #%00000010 ;2
	STA ENABLCache;3
FinishDrawTraffic2	

	;STA WSYNC ;65 / 137

	; LDA Tmp0 ; Flicker this line if drawing car
	; BEQ FinishDrawTraffic4
DrawTraffic3; 33
	TYA; 2
	CLC; 2 
	ADC TrafficOffset3 + 1;3
	AND #TRAFFIC_1_MASK ;2
	BCS EorOffsetWithCarry3; 4 max if branch max, 2 otherwise
	EOR TrafficOffset3 + 2 ; 3
	JMP AfterEorOffsetWithCarry3 ; 3
EorOffsetWithCarry3
	EOR TrafficOffset3 + 3 ; 3
AfterEorOffsetWithCarry3 ;17
	TAX ;2
	LDA AesTable,X ; 4
	CMP TrafficChance;3
	BCS FinishDrawTraffic3 ; 2 
	LDA #%00000010 ;2
	STA ENAM1Cache
FinishDrawTraffic3	
	

DrawOpponent ;26
    STY Tmp0 ;3
    LDY OpponentLine ;3
    CPY #(CAR_START_LINE - 8);2
    BCS SkipDrawOpponent ;2
DrawOpponentVisible
    LDA (EnemyCarSpritePointerL),Y ;5
    STA GRP1Cache ;3
    DEC OpponentLine ;5 ; Waste some bytes (repeated code), but faster
    LDY Tmp0 ;3
    JMP HasNoBorderP0 ; Do not draw border to save cycles
SkipDrawOpponent
    DEC OpponentLine ;5
    LDY Tmp0 ;3

DrawTraffic0; 21 2pe
    TYA; 2
	CLC; 2 
	ADC TrafficOffset0 + 1 ;3
    AND #%00001000 ;2
    BEQ HasNoBorderP0 ;3
HasBorderP0
    LDA #%11100000 ; 2
    JMP StoreBorderP0 ; 3
HasNoBorderP0
    LDA #0 ; 2
StoreBorderP0
    STA PF0Cache ; 3
    STA PF2Cache ; 3

SkipDrawTraffic0

WhileScanLoop 
	DEY	;2
	BMI FinishScanLoop ;2 two big Breach, needs JMP
	JMP ScanLoop ;3
FinishScanLoop ; 7 209 of 222

	STA WSYNC ;3 Draw the last line, without wrapping
    LDA #0 ; Remove border on last line
    STA PF0
    STA PF2
    LDA GRP0Cache ;3
	STA GRP0      ;3
	LDA GRP1Cache ;3
	STA GRP1      ;3
	JSR LoadBallAndMissile
	STA WSYNC
    ; do stuff!
	;STA WSYNC

PrepareOverscan
	LDA #2		
	STA WSYNC  
	STA VBLANK 	
	
	LDA #8
	STA TIM64T	

    STA HMCLR ; Before we process car movement
;Read Fire Button before, will make it start the game for now.
StartGame
	LDA INPT4 ;3 Any player has to press start
    AND INPT5 ;3 player 1
	BMI SkipGameStart ;2 ;not pressed the fire button in negative in bit 7
    LDA FrameCount0
    AND #%00000001
    BNE SkipGameStart ; Starts only on even frames, so we avoid players to have the screen swaped (hack).
	LDA GameStatus ;3
	ORA SwitchDebounceCounter ; Do not start during debounce
	BNE SkipGameStart
	LDA GameMode
	CMP #MAX_GAME_MODE
	BNE SetGameRunningIfBothPressing
	LDA #0
	STA GameMode
	LDA #SWITCHES_DEBOUNCE_TIME
	STA SwitchDebounceCounter
	JMP SkipGameStart
SetGameRunningIfBothPressing
    LDA INPT4 ;3 Both player have to press start
    ORA INPT5 ;3 player 1
    BMI SkipGameStart
SetGameRunning 
	INC GameStatus
	LDA #0;
	STA FrameCount0
	STA FrameCount1
	LDA #SCORE_FONT_COLOR_START
	STA ScoreFontColor
    LDA #OP_SCORE_FONT_COLOR_START
    STA OpScoreFontColor
	LDA #SCORE_FONT_HOLD_CHANGE
	STA ScoreFontColorHoldChange
    STA OpScoreFontColorHoldChange
    JMP OverScanWait ; Do not process player movement and also start
SkipGameStart

ReadSwitches
	LDX SwitchDebounceCounter
	BNE DecrementSwitchDebounceCounter
	LDA #%00000001
	BIT SWCHB
	BNE SkipReset 
	LDA #SWITCHES_DEBOUNCE_TIME
	STA SwitchDebounceCounter
	JMP OverScanWaitBeforeReset
SkipReset

GameModeSelect
	LDA GameStatus ;We don't read game select while running and save precious cycles
	BNE SkipGameSelect
    LDX #0
	JSR ConfigureDifficulty ; Keeps randomizing dificulty for modes 8 to F, also resets it for other modes
    INX
    JSR ConfigureDifficulty
ContinueGameSelect
	LDA #%00000010
	BIT SWCHB
	BNE SkipGameSelect
	LDX GameMode
	CPX #MAX_GAME_MODE
	BEQ ResetGameMode
	INX
	JMP StoreGameMode
ResetGameMode
	LDX #0
StoreGameMode
	STX GameMode
	LDA #SWITCHES_DEBOUNCE_TIME
	STA SwitchDebounceCounter
SkipGameSelect
	JMP EndReadSwitches
DecrementSwitchDebounceCounter
	DEC SwitchDebounceCounter
EndReadSwitches

DoNotTurnBeforeStart
    ;STA HMCLR
    LDA GameStatus
    BEQ OverScanWait

; Last thing, will overrride hmove
CallTestColisionAndMove
    LDX #0 ; Player 0
    ; Colision with traffic, each player check different flags,
    LDA FrameCount0
    AND #%00000001
    BNE SkipColisionPlayer0 ; Test colision after draw frame
    JSR IsOpponentColliding
    ORA CXM1P
    LSR 
	ORA CXM0P
	ORA CXP0FB
	; ORA CXPPMM ; Collision between players will have its own rules
SkipColisionPlayer0 ; Should not colide on opponent side.
	AND #%01000000 ; Accounting for random noise in the bus	
    STA Tmp2	
    JSR TestCollisionAndMove
    
    INX ; player 1
    LDA FrameCount0
    AND #%00000001
    BEQ SkipColisionPlayer1 ; Test colision after draw frame
    JSR IsOpponentColliding
    ORA CXM0P
    LSR 
	ORA CXM1P
	ORA CXP1FB
SkipColisionPlayer1
    AND #%01000000 ; Accounting for random noise in the bus	
    STA Tmp2	
    JSR TestCollisionAndMove

ClearCollision
    STA CXCLR	;reset the collision detection for next frame.

OverScanWait
	LDA INTIM	
	BNE OverScanWait ;Is there a better way?	
	JMP MainLoop      

OverScanWaitBeforeReset
	LDA INTIM	
	BNE OverScanWaitBeforeReset ;Is there a better way?	
	JMP Start   

Subroutines

;X Player
;Tmp1 TrafficOffset 2
ProcessSound
SoundEffects ; 71 More speed = smaller frequency divider. Just getting speed used MSB. (0 to 23)
	LDA ScoreFontColor,X ;3
	CMP PlayerToScoreOverColor,X ;2
	BEQ EngineSound ;2 A little bit of silence, since you will be run over all the time
	CMP PlayerToScoreGoodColor,X ;2
	BEQ PlayCheckpoint ;2
	LDA CollisionCounter,X ;3
	CMP #$E0 ;2
	BCS PlayColision ;2
	LDA NextCheckpoint,X ;3
	SEC ;2
	SBC Tmp1;TrafficOffset0 + 2 ;3
	CMP #$02 ;2
	BCC PlayBeforeCheckpoint ;4
	LDA CountdownTimer,X ; 3
	BEQ EngineSound ;2
	CMP #WARN_TIME_ENDING ;2
	BCC PlayWarnTimeEnding ;4
    LDA GameStatus ; Mute while game not running
    BNE EngineSound
	JMP MuteSound ;3
PlayColision
	LDA #31
	STA AUDF0,X
	LDA #8
	STA AUDC0,X
	LDA #8
	STA AUDV0,X
	JMP EndSound

PlayCheckpoint
	LDA ScoreFontColorHoldChange,X ;3
	LSR ;2
	LSR ;2
	LSR ;2
	STA AUDF0,X ;3
	LDA #12 ;2
	STA AUDC0,X ;3
	LDA #6 ;2
	STA AUDV0,X ;3
	JMP EndSound ;3

PlayBeforeCheckpoint
	LDA FrameCount0 ;3
	AND #%00011100 ;2
	ORA #%00000011;2
	STA AUDF0,X ;3
	LDA #12 ;2
	STA AUDC0,X ;3
	LDA #3 ;2
	STA AUDV0,X ;3
	JMP EndSound ;3

PlayWarnTimeEnding
	LDA FrameCount0 ;3
	AND #%00000100 ;2
	BEQ MuteSound ;2 Bip at regular intervals
	CLC ;2
	LDA #10 ;2
	ADC CountdownTimer,X ;2
	STA AUDF0,X ;3
	LDA #12 ;2
	STA AUDC0,X ;3
	LDA #3 ;2
	STA AUDV0,X ;3
	JMP EndSound ;3

EngineSound ;41
    LDA #ENGINE_VOLUME ;It needs to restore volume now, since it is a shared audio channel
	STA AUDV0,X
	LDA CountdownTimer,X ;3
	BEQ EngineOff      ;2
	LDY Gear,X
	LDA Player0SpeedL,X ;3
	LSR ;2
	LSR ;2
	LSR ;2
	AND #%00001111 ;2
	STA Tmp0 ;3
	LDA EngineBaseFrequence,Y ; 4 Max of 5 bits
	SEC ;2
	SBC Tmp0 ;3
	STA AUDF0,X ;3
	LDA EngineSoundType,Y ;4
	STA AUDC0,X ;3
	JMP EndEngineSound ;3
EngineOff
MuteSound
	LDA #0
	STA AUDC0,X
EndEngineSound
EndSound
    RTS

ClearAll ; 58
	LDA #0  	  ;2
    STA GRP0      ;3
	STA GRP1      ;3
	STA ENABL     ;3
	STA ENAM0     ;3
	STA ENAM1     ;3
    STA GRP0Cache ;3
	STA GRP1Cache ;3
	STA ENABLCache ;3
	STA ENAM0Cache ;3
	STA ENAM1Cache ;3

ClearPF ; 26
	LDA #0  	  ;2
ClearPFSkipLDA0
	STA PF0		  ;3
	STA PF1	      ;3
	STA PF2       ;3 	
	STA PF0Cache   ;3
	STA PF1Cache   ;3
	STA PF2Cache   ;3 
	RTS ;6
EndClearAll

LoadPlayfield ; 54
	LDA PF0Cache  ;3
	STA PF0		  ;3
	
	LDA PF1Cache ;3
	STA PF1	     ;3
	
	LDA PF2Cache ;3
	STA PF2      ;3

    RTS ; 6
EndLoadPlayfield

LoadBallAndMissile
	LDA ENABLCache ;3
	STA ENABL      ;3

	LDA ENAM0Cache ;3
	STA ENAM0      ;3

	LDA ENAM1Cache ;3
	STA ENAM1      ;3

	RTS ;6
EndLoadBallAndMissile

NextDifficulty ;Is a SBR
	LDA GameMode ; For now, even games change the difficult
	AND #%00000001
	BNE CheckRandomDifficulty

	LDA CurrentDifficulty,X
	CLC
	ADC #1
	AND #%00000011 ; 0 to 3
	STA CurrentDifficulty,X

ConfigureDifficulty ;Is a SBR for performance optimization it is called directly
	LDY CurrentDifficulty,X ;Needed, not always NextDifficulty is entrypoint
	LDA TrafficChanceTable,Y
	STA TrafficChance,X
	LDA TrafficColorTable,Y
	STA TrafficColor,X

	LDA GameMode;
	AND #%00000001
	BEQ UseNextDifficultyTime
	JMP StoreDifficultyTime
UseNextDifficultyTime
	INY
StoreDifficultyTime
	LDA TrafficTimeTable,Y
	STA CheckpointTime,X

CheckRandomDifficulty
	LDA GameMode
	AND #%00001000 ; Random difficulties
	BEQ ReturnFromNextDifficulty
RandomDifficulty ; Might bug if both players cross at the same time, it is a feature! Very unlikelly. Solve if there is rom space left...
    LDA IsOpponentInFront
    BMI UseOpponentChance
    LDA OpponentLine ; Same line
    CMP #(GAMEPLAY_AREA - CAR_SIZE)
    BEQ ReturnFromNextDifficulty ; Special case, just use the default level difficulty.
	LDY FrameCount0
	LDA AesTable,Y
	;31 x 1.5 + 6 [4 to 50]
	AND #%00011111 ;[0 to 31]
	STA Tmp4 ; Cache winning player chance and use
    LSR ; divade by 2
    CLC
    ADC Tmp4 
    ADC #4
    STA TrafficChance,X ; Cache winning player chance and use
    JMP ReturnFromNextDifficulty
UseOpponentChance
    TXA
    EOR #%00000001 ; Reverts the player
    TAX
    LDA TrafficChance,X ; Loads opponent chance
    STA Tmp3
    TXA 
    EOR #%00000001 ; Restors the player
    TAX
    LDA Tmp3
    STA TrafficChance,X
	
ReturnFromNextDifficulty
	RTS

DefaultOffsets
	LDA #$20
	STA TrafficOffset1 + 2
    STA OpTrafficOffset1 + 2
	LDA #$40
	STA TrafficOffset2 + 2	;Initial Y Position
    STA OpTrafficOffset2 + 2
	LDA #$60
	STA TrafficOffset3 + 2	;Initial Y Position
    STA OpTrafficOffset3 + 2
	LDA #$80
	RTS

PrintStaticText ; Preload X with the offset referent to StaticText
	LDA StaticText,X
	STA ScoreD0
	INX
	LDA StaticText,X
	STA ScoreD1
	INX
	LDA StaticText,X
	STA ScoreD2
	INX
	LDA StaticText,X
	STA ScoreD3
	INX
	LDA StaticText,X
	STA ScoreD4
	RTS

PrintScore ; Runs in 2 lines, this is the best I can do!
	LDX #0
	LDY #FONT_OFFSET

ScoreLoop ; 20 
	STA WSYNC ;2
    STA HMOVE

	LDA PF0Cache  ;3 Move to a macro?
	STA PF0		  ;3
	
	LDA PF1Cache ;3
	STA PF1	     ;3
	
	LDA PF2Cache ;3
	STA PF2 ;3

DrawScoreD0 ; 15
	LDX ScoreD0 ; 3
	LDA Font,X	;4
	STA PF0Cache ;3
	DEC ScoreD0 ;5

DrawScoreD1 ; 23	
	LDX ScoreD1 ; 3
	LDA Font,X	;4
	ASL ;2
	ASL ;2
	ASL ;2
	ASL ;2
	STA PF1Cache ;3
	DEC ScoreD1 ;5

DrawScoreD2 ; 20
	LDX ScoreD2 ; 3
	LDA Font,X	;4
	AND #%00001111 ;2
	ORA PF1Cache ;3
	STA PF1Cache ;3
	DEC ScoreD2 ;5

DrawScoreD3 ; 23
	LDX ScoreD3 ; 3
	LDA Font,X	;4
	LSR ;2
	LSR ;2
	LSR ;2
	LSR ;2
	STA PF2Cache ;3
	DEC ScoreD3 ;5

DrawScoreD4 ; 20
	LDX ScoreD4 ; 3
	LDA Font,X	;4
	AND #%11110000 ;2
	ORA PF2Cache ;3
	STA PF2Cache ;3
	DEC ScoreD4 ;5


	DEY ;2
	BPL ScoreLoop ;4

	STA WSYNC
    STA HMOVE
	JSR LoadPlayfield
	RTS ; 6

WaitForVblankEnd
	LDA INTIM	
	BNE WaitForVblankEnd	
	STA WSYNC
	STA VBLANK
	RTS	

Sleep4Lines
	STA WSYNC
	STA WSYNC
	STA WSYNC
	STA WSYNC
	RTS

Sleep8Lines
	JSR Sleep4Lines
	JSR Sleep4Lines
	RTS

;X = number of WSYNC HMOVE to run
HMoveXTimes
    STA WSYNC ;3
    STA HMOVE; 3/10 
    DEX
    BNE HMoveXTimes
    RTS

; From http://www.6502.org/source/integers/hex2dec-more.htm
; Can be transformed into a 100 bytes lookup table if cycles are scarse...
; Tmp0 Binary Number
; Result Returned in Tmp 1 and A
BINBCD8:	
    SED		; Switch to decimal mode
	LDA #0		; Ensure the result is clear
	STA Tmp1+0
	;STA Tmp1+1
	LDX #8		; The number of source bits

CNVBIT:		
    ASL Tmp0 ;BIN		; Shift out one bit
	LDA Tmp1+0	; And add into result
	ADC Tmp1+0
	STA Tmp1+0
    ;Not needed now, 0 to 99 is enought for timer!
	; LDA Tmp1+1	; propagating any carry
	; ADC Tmp1+1
	; STA Tmp1+1
	DEX		; And repeat for next bit
	BNE CNVBIT
	CLD		; Back to binary
	RTS		; All Done.

;Tmp0 Current SWCHA mask, will be right shifted 4 times
;X player 0 or 1
SelectCarWithDpad 
    LDY #3
SelectCarWithDpadLoop
    LDA SWCHA
    AND Tmp0
    BNE ContinueSelectCarWithDpadLoop
    TYA
    STA CurrentCarId,X
ContinueSelectCarWithDpadLoop
    LSR Tmp0
    DEY
    BPL SelectCarWithDpadLoop
    RTS

ProcessOpponentLineAndPlayerSprite ; The sprite might depend on the line, the SBRs are connected
    LDA FrameCount0
    AND #%00000001
    SEC
    BNE Player0IsOpponent
Player1IsOpponent ; Code could be reused?
    LDA TrafficOffset0 + 1
    SBC OpTrafficOffset0 + 1
    STA Tmp0
    LDA TrafficOffset0 + 2
    SBC OpTrafficOffset0 + 2
    STA Tmp1
    LDA Traffic0Msb
    SBC OpTraffic0Msb
    STA IsOpponentInFront
    JMP CalculateOpponentVisibility
Player0IsOpponent
    LDA OpTrafficOffset0 + 1
    SBC TrafficOffset0 + 1
    STA Tmp0
    LDA OpTrafficOffset0 + 2
    SBC TrafficOffset0 + 2
    STA Tmp1
    LDA OpTraffic0Msb
    SBC Traffic0Msb
    STA IsOpponentInFront

CalculateOpponentVisibility
    LDA Tmp1
    ORA IsOpponentInFront
    BEQ OpponentVisibleBehind ; 2 MSB are all zero

    LDA Tmp1
    AND IsOpponentInFront
    CMP #%11111111
    BEQ OpponentVisibleInFront ; 2 MSB are all one

OpponentNotVisible
    LDA #0
    STA Tmp4
    LDA #$FF
    STA OpponentLine
    BNE ConfigureCarSprites

OpponentVisibleBehind
    LDA Tmp0
    BMI OpponentVisibleBehindNegativeNumber
    CMP #14
    BCC OpponentFullyVisible ; A is Greater or equal
OpponentVisibleBehindNegativeNumber
    LDA #51
    STA OpponentLine
    STA Tmp4 ; Use sprite override
    LDA #<ArrowDownSprite
    STA EnemyCarSpritePointerL
    LDA #>ArrowDownSprite
    STA EnemyCarSpritePointerH
    BNE ConfigureCarSprites ; Always jump

OpponentVisibleInFront
    LDA Tmp0
    BPL OpponentVisibleInFrontPositiveNumber
    CMP #-58
    BPL OpponentFullyVisible ; A more than
OpponentVisibleInFrontPositiveNumber
    LDA #4
    STA OpponentLine
    STA Tmp4 ; Use sprite override
    LDA #<ArrowUpSprite
    STA EnemyCarSpritePointerL
    LDA #>ArrowUpSprite
    STA EnemyCarSpritePointerH
    BNE ConfigureCarSprites ; Alwys jump

OpponentFullyVisible
    LDA #0
    STA Tmp4
    CLC
    LDA Tmp0
    ADC #(GAMEPLAY_AREA - CAR_SIZE)
    STA OpponentLine

ConfigureCarSprites
    LDA FrameCount0
    AND #%00000001
    BNE LoadForRightScreenSprites
LoadForLeftScreenSprites
    LDA CurrentCarId
    STA Tmp0
    LDA OpCurrentCarId
    STA Tmp1
    JMP LoadCarSpritesFromIds
LoadForRightScreenSprites
    LDA CurrentCarId
    STA Tmp1
    LDA OpCurrentCarId
    STA Tmp0
    
LoadCarSpritesFromIds ; The pointers are reversed every frame, opponent car has no padding
	LDY Tmp0
	LDA CarIdToSpriteAddressL,Y
	STA CarSpritePointerL
	LDA CarIdToSpriteAddressH,Y
	STA CarSpritePointerH
ConfigureOpponentCarSprite
    LDA Tmp4
    BNE ReturnFromConfigureCarSprite ; Using override!
OpponentCarSprite
	LDY Tmp1
	LDA EnemyCarIdToSpriteAddressL,Y
	STA EnemyCarSpritePointerL
	LDA EnemyCarIdToSpriteAddressH,Y
	STA EnemyCarSpritePointerH
ReturnFromConfigureCarSprite
    RTS

; Value stored in A
IsOpponentColliding
    ;Any non default state, opponent do not colide
    LDA CollisionCounter
    ORA OpCollisionCounter
    ORA ScoreFontColorHoldChange
    ORA OpScoreFontColorHoldChange
    BNE OpponentNotColliding
    LDA IsOpponentInFront
    AND CXPPMM
    JMP ReturnIsOpponentColliding
OpponentNotColliding
    LDA #0
ReturnIsOpponentColliding
    RTS


; Movement and colision are binded because the car must be moved after duplicate size.
; Use X for the player
; Tmp2 Traffic colision result
TestCollisionAndMove
; Until store the movemnt, Y contains the value to be stored.
; see if player0 colides with the rest
	LDA Tmp2
	BEQ NoCollision	;skip if not hitting...
	LDA CollisionCounter,X ; If colision is alredy happening, ignore!
	BNE NoCollision	
	LDA ScoreFontColor,X ; Ignore colisions during checkpoint (Green Score)
	CMP PlayerToScoreGoodColor,X
	BEQ NoCollision
	CMP PlayerToScoreStartColor,X
	BEQ NoCollision
	LDA #COLLISION_FRAMES
	STA CollisionCounter,X
	LDA Player0SpeedH,X
	BNE SetColisionSpeedL ; Never skips setting colision speed if high byte > 0
	LDA #COLLISION_SPEED_L
	CMP Player0SpeedL,X
	BCS SkipSetColisionSpeedL
SetColisionSpeedL
	LDA #COLLISION_SPEED_L ; Needs optimization!
	STA Player0SpeedL,X
SkipSetColisionSpeedL	
	LDA #0
	STA Player0SpeedH,X
	LDY #$40	;Move car left 4 color clocks, to center the stretch (+4)	
	JMP StoreHMove ; We keep position consistent
NoCollision

DecrementCollision
	LDA CollisionCounter,X
	BEQ FinishDecrementCollision
	LDA #%00110101; Make player bigger to show colision
	STA NUSIZ0,X ; NUSIZ1 is on the next position
	DEC CollisionCounter,X
FinishDecrementCollision

ResetPlayerSize
	BNE FinishResetPlayerSize
	LDA #%00110000
	STA NUSIZ0,X;
FinishResetPlayerSize

ResetPlayerPosition ;For 1 frame, he will not colide, but will have the origina size
	LDA CollisionCounter,X
    CMP #1 ; Last frame before reset
	BNE SkipResetPlayerPosition
	LDY #$C0	;Move car left 4 color clocks, to center the stretch (-4)
	JMP StoreHMove
SkipResetPlayerPosition

MakeDragsterTurnSlow ; Only car diff that does not use a table.
	LDA CurrentCarId,X
	CMP #CAR_ID_DRAGSTER
	BNE PrepareReadXAxis
	LDY #0
	LDA FrameCount0
	AND #DRAGSTER_TURN_MASK
	BEQ StoreHMove ; Ignore movement on some frames

PrepareReadXAxis
	LDY #0
	LDA Player0X,X
BeginReadLeft
	BEQ SkipMoveLeft ; We do not move after maximum
	LDA PlayerToLeftMask,X	;Left mask 
	BIT SWCHA
	BNE SkipMoveLeft
	LDY #$10	;a 1 in the left nibble means go left
	DEC Player0X,X
	JMP StoreHMove ; Cannot move left and right...
SkipMoveLeft
BeginReadRight
    LDA Player0X,X
	CMP #PLAYER_MAX_X
	BEQ SkipMoveRight ; At max already
	LDA PlayerToRightMask,X	;Right mask set before call (player 0 or 1)
	BIT SWCHA 
	BNE SkipMoveRight
	LDY #$F0	;a -1 in the left nibble means go right...
	INC Player0X,X
SkipMoveRight
StoreHMove
	STY HMP0,X	;set the move for player 0

    RTS

; X Traffic offset 4 bits each lane, 4 lanes per player
; Tmp3 Max X offset
; Tmp4 Max Player Speed L
; Tmp5 Max Player Speed H
UpdateOffsets
	LDY #0 ; Line Speeds 16 bits
	LDA GameMode
	AND #%00000100 ; GameModes with high delta
	BEQ UpdateOffsetsLoop
	LDY #(TrafficSpeedsHighDelta - TrafficSpeeds)
	
UpdateOffsetsLoop; Car sped - traffic speed = how much to change offet (signed)
	SEC
	LDA Tmp4 ;Player_SpeedL
	SBC TrafficSpeeds,Y
	STA Tmp0
	INY
	LDA Tmp5 ;Player_SpeedH
	SBC TrafficSpeeds,Y 
	STA Tmp1
	LDA #0; Hard to figure out, makes the 2 complement result work correctly, since we use this 16 bit signed result in a 24 bit operation
	SBC #0
	STA Tmp2

AddsTheResult
	CLC
	LDA Tmp0
	ADC TrafficOffset0,X
	STA TrafficOffset0,X
	INX
	LDA Tmp1
	ADC TrafficOffset0,X
	STA TrafficOffset0,X
	INX
	LDA Tmp2 ; Carry
	ADC TrafficOffset0,X
	STA TrafficOffset0,X
	BCC CalculateOffsetCache
CalculatePlayer0Msb
	CPX #2 ;Only the border (also score) has MSB, player 0
	BNE CalculatePlayer1Msb
	INC Traffic0Msb
    JMP CalculateOffsetCache
CalculatePlayer1Msb
    CPX #(TRAFFIC_LINE_COUNT * 4) + 2 ;MSB for player 1
	BNE CalculateOffsetCache
    INC OpTraffic0Msb

CalculateOffsetCache ; This memory space can be shared and just used on the player drawing frame, saving 4 bytes.
	INX
	SEC
	ADC #0 ;Increment by one
	STA TrafficOffset0,X ; cache of the other possible value for the MSB in the frame, make drawing faster.

PrepareNextUpdateLoop
	INY
	INX
	CPX Tmp3 ; Max X offset
	BNE UpdateOffsetsLoop
    RTS

; X Player 0 or 1
ProcessSpeed
BreakOnTimeOver ; Uses LDX as the breaking speed
	LDA #0
    STA Tmp0 ; Break speed
	LDA CountdownTimer,X
	BNE Break
	LDY CurrentCarId,X
	LDA FrameCount0
	AND CarIdToTimeoverBreakInterval,Y
	BNE Break 
	LDA #TIMEOVER_BREAK_SPEED
    STA Tmp0
	
Break
	LDA PlayerToDownMask,X	;Down in controller
	BIT SWCHA 
	BNE BreakNonZero
	LDA INPT4,X ;3
	BPL BreakWhileAccelerating
	LDY Gear,X
	LDA GearToBreakSpeedTable,Y ; Different break speeds depending on speed.
    STA Tmp0
	JMP BreakNonZero
BreakWhileAccelerating ; Allow better control while breaking.
	LDA (#BREAK_SPEED / 2)
    STA Tmp0

BreakNonZero
	LDA Tmp0
	BEQ SkipBreak

DecreaseSpeed
	SEC
	LDA Player0SpeedL,X
	SBC Tmp0
	STA Player0SpeedL,X
	LDA Player0SpeedH,X
	SBC #0
	STA Player0SpeedH,X

CheckMinSpeed
	BMI ResetMinSpeed; Overflow d7 is set
	CMP #CAR_MIN_SPEED_H
	BEQ CompareLBreakSpeed; is the same as minimun, compare other byte.
	BCS SkipAccelerateIfBreaking; Greater than min, we are ok! 

CompareLBreakSpeed	
	LDA Player0SpeedL,X
	CMP #CAR_MIN_SPEED_L	
	BCC ResetMinSpeed ; Less than memory
	JMP SkipAccelerateIfBreaking ; We are greather than min speed in the low byte.

ResetMinSpeed
	LDA #CAR_MIN_SPEED_H
	STA Player0SpeedH,X
	LDA #CAR_MIN_SPEED_L
	STA Player0SpeedL,X

SkipAccelerateIfBreaking
	JMP SkipAccelerate
SkipBreak

Acelerates
	LDA CountdownTimer,X
	BEQ SkipAccelerate; cannot accelerate if timer is zero

ContinueAccelerateTest
	LDA INPT4,X ;3
	BPL IncreaseCarSpeed ; Test button and then up, both accelerate.
	LDA PlayerToUpMask,X	;UP in controller
	BIT SWCHA 
	BNE SkipAccelerate

IncreaseCarSpeed
	LDA #2
    STA Tmp0 ; Loop control
	LDY CurrentCarId,X
IncreaseCarSpeedLoop
;Adds speed
	CLC
	LDA AccelerateBuffer,X
	ADC CarIdToAccelerateSpeed,Y
	STA AccelerateBuffer,X
	BCC ContinueIncreaseSpeedLoop ; Not enought in the buffer to change speed
	INC Player0SpeedL,X
	BNE ContinueIncreaseSpeedLoop ; When turns Zero again, increase MSB
	INC Player0SpeedH,X
ContinueIncreaseSpeedLoop
	DEC Tmp0
	BNE IncreaseCarSpeedLoop
SkipIncreaseCarSpeed

CheckIfAlreadyMaxSpeed
	LDA Player0SpeedH,X
	CMP #CAR_MAX_SPEED_H
	BCC SkipAccelerate ; less than my max speed
	BNE ResetToMaxSpeed ; Not equal, so if I am less, and not equal, I am more!
	;High bit is max, compare the low
	LDY CurrentCarId,X
	LDA Player0SpeedL,X
	CMP CarIdToMaxSpeedL,Y
	BCC SkipAccelerate ; High bit is max, but low bit is not
	;BEQ SkipAccelerate ; Optimize best case, but not worse case

ResetToMaxSpeed ; Speed is more, or is already max
	LDA #CAR_MAX_SPEED_H
	STA Player0SpeedH,X
	LDY CurrentCarId,X
	LDA CarIdToMaxSpeedL,Y
	STA Player0SpeedL,X
SkipAccelerate
    RTS

;Tmp0 Traffic Offset to compare with next checkpoint
ProcessPlayerStatus
IsGameOver
	LDA CountdownTimer,X
	ORA Player0SpeedL,X
	ORA Player0SpeedH,X
	BNE IsCheckpoint
	LDA #2  ; We are not processing the status every frame anymore, need to survice at least 2 frames.
	STA ScoreFontColorHoldChange,X
	LDA PlayerToScoreOverColor,X
	STA ScoreFontColor,X
	JMP SkipIsTimeOver

IsCheckpoint
	LDA NextCheckpoint,X
	CMP Tmp0 ; TrafficOffset0 + 2 not sequential with OpTrafficOffset
	BNE SkipIsCheckpoint
	CLC
	ADC #CHECKPOINT_INTERVAL
	STA NextCheckpoint,X
	LDA PlayerToScoreGoodColor,X
	STA ScoreFontColor,X
	LDA #SCORE_FONT_HOLD_CHANGE
	STA ScoreFontColorHoldChange,X
	LDA CountdownTimer,X
	CLC
	ADC CheckpointTime,X
	STA CountdownTimer,X
	BCC JumpSkipTimeOver
	LDA #$FF
	STA CountdownTimer,X ; Does not overflow!
JumpSkipTimeOver
	JSR NextDifficulty ; Increments to the next dificulty (Will depend on game mode in the future)
	JMP SkipIsTimeOver ; Checkpoints will add time, so no time over routine, should also override time over.
SkipIsCheckpoint

IsTimeOver
	LDA CountdownTimer,X
	BNE SkipIsTimeOver
	LDA #2 ; We are not processing the status every frame anymore, need to survice at least 2 frames.
	STA ScoreFontColorHoldChange,X
	LDA PlayerToScoreBadColor,X
	STA ScoreFontColor,X
SkipIsTimeOver
    RTS


EverySecond ; 64 frames to be more precise
	LDA #%00111111
	AND FrameCount0
	BNE SkipEverySecondAction
	CMP CountdownTimer,X
	BEQ SkipEverySecondAction ; Stop at Zero
	DEC CountdownTimer,X
SkipEverySecondAction
    RTS

CalculateGear
	LDA Player0SpeedL,X  ;3
	AND #%10000000      ;2
	ORA Player0SpeedH,X   ;3
	CLC                 ;2
	ROL                 ;2
	ADC #0 ; 2 Places the possible carry produced by ROL
	STA Gear,X
    RTS

ProcessScoreFontColor
	LDY ScoreFontColorHoldChange,X
	BEQ ResetScoreFontColor
	DEY
	STY ScoreFontColorHoldChange,X
	JMP SkipScoreFontColor
ResetScoreFontColor
	LDA PlayerToDefaultColor,X
	STA ScoreFontColor,X
SkipScoreFontColor
    RTS

; X = Player
; A Returns result to be sotored in the proper digit
PrintScoreHoldChange
    LDA ScoreFontColorHoldChange,X
    LSR
    LSR
    LSR
    LSR
    TAY
    LDA BarLookup,Y
    RTS

PrintSpeedBar
	LDA Player0SpeedL,X
	AND #%11100000 ;2 Discard the last bits
	CLC
	ROL ;First goes into carry
	ROL
	ROL
    ROL
	STA Tmp0
	LDA Player0SpeedH,X
	ASL
	ASL
    ASL
	ORA Tmp0
	TAY ; 2
	LDA SpeedToBarLookup,Y ;4
	STA ScoreD2 ;3
    RTS

; Moved here because of rom space.
; The only SBR in constants space
DrawQrCode
	LDX #QR_CODE_BACKGROUNG ;2
	LDY #QR_CODE_COLOR ;2
	LDA #%00000001 ; Mirror playfield
	STA CTRLPF
	JSR ClearAll ; To be 100 sure!
	LDA SWCHB
	AND #%00001000 ; If Black and white, this will make A = 0
    EOR #%00001000 ; Make black the default, can be optimized.
	BEQ StoreReversedQrCode
	STX COLUBK
	STY COLUPF
	JMP ContinueQrCode
StoreReversedQrCode
	STX COLUPF
	STY COLUBK

ContinueQrCode
    LDX #9
    JSR HMoveXTimes
	LDY #QR_CODE_SIZE - 1
	LDX #QR_CODE_LINE_HEIGHT
	JSR WaitForVblankEnd
	JSR Sleep8Lines
	JSR Sleep8Lines
	JSR Sleep8Lines

QrCodeLoop ;Assync mirroed playfield, https://atariage.com/forums/topic/149228-a-simple-display-timing-diagram/
	STA WSYNC
	LDA QrCode1,Y ; 4
	STA PF1  ;3
	LDA QrCode2,Y ;4
	STA PF2 ;3
	SLEEP 27 ; 
	LDA QrCode3,Y ;4
	STA PF2 ;3 Write ends at cycle 48 exactly!
	LDA QrCode4,Y ; 4
	STA PF1  ;3

	DEX ;2
	BNE QrCodeLoop ;2
	LDX #QR_CODE_LINE_HEIGHT ;2
	DEY ;2
	BPL QrCodeLoop ;4

EndQrCodeLoop
	STA WSYNC ;
	LDA #0
	STA PF1  ;3
	STA PF2  ;3

    ;Sleeps 31 lines
	JSR Sleep8Lines
    JSR Sleep8Lines
    JSR Sleep8Lines
    JSR Sleep4Lines
    STA WSYNC
    STA WSYNC
    ;STA WSYNC
	JMP PrepareOverscan

;ALL CONSTANTS FROM HERE (The QrCode routine is the only exception), ALIGN TO AVOID CARRY
	org $FC00
QrCode1
	.byte #%00011111
	.byte #%00010000
	.byte #%00010111
	.byte #%00010111
	.byte #%00010111
	.byte #%00010000
	.byte #%00011111
	.byte #%00000000
	.byte #%00010111
	.byte #%00010000
	.byte #%00011101
	.byte #%00010110
	.byte #%00000011
	.byte #%00011001
	.byte #%00010011
	.byte #%00011100
	.byte #%00001011
	.byte #%00000000
	.byte #%00011111
	.byte #%00010000
	.byte #%00010111
	.byte #%00010111
	.byte #%00010111
	.byte #%00010000
	.byte #%00011111

QrCode2
	.byte #%11000011
	.byte #%10011010
	.byte #%10000010
	.byte #%11011010
	.byte #%10101010
	.byte #%11001010
	.byte #%11110011
	.byte #%01111000
	.byte #%11011111
	.byte #%11111100
	.byte #%11000111
	.byte #%10011000
	.byte #%00100011
	.byte #%10111001
	.byte #%11010010
	.byte #%00110000
	.byte #%11101011
	.byte #%00101000
	.byte #%10101011
	.byte #%01110010
	.byte #%11111010
	.byte #%01111010
	.byte #%00110010
	.byte #%00111010
	.byte #%01100011	

QrCode3
	.byte #%10011000
	.byte #%11000011
	.byte #%00111001
	.byte #%00110100
	.byte #%11111111
	.byte #%01110001
	.byte #%11010101
	.byte #%11010001
	.byte #%01011111
	.byte #%00100110
	.byte #%00101101
	.byte #%11101001
	.byte #%11010110
	.byte #%00100110
	.byte #%10111010
	.byte #%00000011
	.byte #%11011101
	.byte #%11100000
	.byte #%01010111
	.byte #%00010100
	.byte #%00110101
	.byte #%11100101
	.byte #%10110101
	.byte #%11010100
	.byte #%10010111

QrCode4
	.byte #%00001001
	.byte #%00001110
	.byte #%00001111
	.byte #%00001100
	.byte #%00001100
	.byte #%00001000
	.byte #%00001000
	.byte #%00000110
	.byte #%00000110
	.byte #%00001011
	.byte #%00001111
	.byte #%00000100
	.byte #%00001000
	.byte #%00001111
	.byte #%00001001
	.byte #%00000111
	.byte #%00000101
	.byte #%00000000
	.byte #%00001111
	.byte #%00001000
	.byte #%00001011
	.byte #%00001011
	.byte #%00001011
	.byte #%00001000
	.byte #%00001111
    
PlayerToUpMask
    .byte #%00010000;
    .byte #%00000001;

PlayerToDownMask
    .byte #%00100000;
    .byte #%00000010;

PlayerToLeftMask
    .byte #%01000000;
    .byte #%00000100;

PlayerToRightMask
    .byte #%10000000;
    .byte #%00001000;

FontLookup ; Very fast font lookup for dynamic values!
	.byte #<C0 + #FONT_OFFSET ; 0
	.byte #<C1 + #FONT_OFFSET
	.byte #<C2 + #FONT_OFFSET
	.byte #<C3 + #FONT_OFFSET
	.byte #<C4 + #FONT_OFFSET
	.byte #<C5 + #FONT_OFFSET 
	.byte #<C6 + #FONT_OFFSET
	.byte #<C7 + #FONT_OFFSET ; 8
	.byte #<C8 + #FONT_OFFSET 
	.byte #<C9 + #FONT_OFFSET
	.byte #<CA + #FONT_OFFSET 
	.byte #<CB + #FONT_OFFSET 
	.byte #<CC + #FONT_OFFSET
	.byte #<CD + #FONT_OFFSET
	.byte #<CE + #FONT_OFFSET
	.byte #<CF + #FONT_OFFSET ; 16
	.byte #<CG + #FONT_OFFSET
    .byte #<CH + #FONT_OFFSET
    .byte #<CI + #FONT_OFFSET
    .byte #<CJ + #FONT_OFFSET
    .byte #<CK + #FONT_OFFSET
    .byte #<CL + #FONT_OFFSET
    .byte #<CM + #FONT_OFFSET
    .byte #<CN + #FONT_OFFSET ; 24
    .byte #<CO + #FONT_OFFSET
    .byte #<CP + #FONT_OFFSET
    .byte #<CQ + #FONT_OFFSET 
    .byte #<CR + #FONT_OFFSET
    .byte #<CS + #FONT_OFFSET
    .byte #<CT + #FONT_OFFSET
    .byte #<CU + #FONT_OFFSET 
    .byte #<Exclamation + #FONT_OFFSET ; 32


BarLookup ; Very fast font lookup for dynamic values (vertical bar)!
	.byte #<C0B + #FONT_OFFSET
	.byte #<C1B + #FONT_OFFSET
	.byte #<C2B + #FONT_OFFSET
	.byte #<C3B + #FONT_OFFSET
	.byte #<C4B + #FONT_OFFSET
	.byte #<C5B + #FONT_OFFSET 
	.byte #<C6B + #FONT_OFFSET
	.byte #<C7B + #FONT_OFFSET
	.byte #<C8B + #FONT_OFFSET 
	.byte #<C9B + #FONT_OFFSET
	.byte #<CAB + #FONT_OFFSET 
	.byte #<CBB + #FONT_OFFSET 
	.byte #<CCB + #FONT_OFFSET
	.byte #<CDB + #FONT_OFFSET
	.byte #<CEB + #FONT_OFFSET
	.byte #<CFB + #FONT_OFFSET

SpeedToBarLookup ; Speed will vary from 0 to 20 and mapped to a 0 to 15 space
	.byte #<C0B + #FONT_OFFSET
    .byte #<C0B + #FONT_OFFSET
	.byte #<C1B + #FONT_OFFSET
	.byte #<C2B + #FONT_OFFSET
	.byte #<C3B + #FONT_OFFSET
    .byte #<C3B + #FONT_OFFSET
    .byte #<C4B + #FONT_OFFSET
	.byte #<C5B + #FONT_OFFSET 
	.byte #<C6B + #FONT_OFFSET
	.byte #<C6B + #FONT_OFFSET
    .byte #<C7B + #FONT_OFFSET
	.byte #<C8B + #FONT_OFFSET 
	.byte #<C9B + #FONT_OFFSET
	.byte #<C9B + #FONT_OFFSET 
    .byte #<CAB + #FONT_OFFSET 
	.byte #<CBB + #FONT_OFFSET 
	.byte #<CCB + #FONT_OFFSET
	.byte #<CCB + #FONT_OFFSET
    .byte #<CDB + #FONT_OFFSET
	.byte #<CEB + #FONT_OFFSET
	.byte #<CFB + #FONT_OFFSET

PlayerToDefaultColor
    .byte #PLAYER0_COLOR
    .byte #PLAYER1_COLOR

PlayerToScoreGoodColor
    .byte #SCORE_FONT_COLOR_GOOD
    .byte #OP_SCORE_FONT_COLOR_GOOD

PlayerToScoreStartColor
    .byte #SCORE_FONT_COLOR_START
    .byte #OP_SCORE_FONT_COLOR_START

PlayerToScoreOverColor
    .byte #SCORE_FONT_COLOR_OVER
    .byte #OP_SCORE_FONT_COLOR_OVER

PlayerToScoreBadColor
    .byte #SCORE_FONT_COLOR_BAD
    .byte #OP_SCORE_FONT_COLOR_BAD

	org $FD00
Font	
C0
	.byte #%11100111;
	.byte #%10100101; 
	.byte #%10100101; 
	.byte #%10100101; 
	.byte #%11100111;	
C1	
	.byte #%11100111;
	.byte #%01000010; 
	.byte #%01000010; 
	.byte #%01000010; 
	.byte #%01100110;
C2
	.byte #%11100111;
	.byte #%00100100; 
	.byte #%11100111; 
	.byte #%10000001; 
	.byte #%11100111;
C3
	.byte #%11100111;
	.byte #%10000001; 
	.byte #%11100111; 
	.byte #%10000001; 
	.byte #%11100111;
C4
	.byte #%10000001;
	.byte #%10000001; 
	.byte #%11100111; 
	.byte #%10100101; 
	.byte #%10100101;
C5
	.byte #%11100111;
	.byte #%10000001; 
	.byte #%11100111; 
	.byte #%00100100; 
	.byte #%11100111;
C6
	.byte #%11100111;
	.byte #%10100101; 
	.byte #%11100111; 
	.byte #%00100100; 
	.byte #%11100111;
C7
	.byte #%10000001;
	.byte #%10000001; 
	.byte #%10000001; 
	.byte #%10000001; 
	.byte #%11100111;
C8
	.byte #%11100111;
	.byte #%10100101; 
	.byte #%11100111; 
	.byte #%10100101; 
	.byte #%11100111;
C9
	.byte #%11100111;
	.byte #%10000001; 
	.byte #%11100111; 
	.byte #%10100101; 
	.byte #%11100111;
CA
	.byte #%10100101;
	.byte #%10100101; 
	.byte #%11100111; 
	.byte #%10100101; 
	.byte #%11100111;
CB
	.byte #%01100110;
	.byte #%10100101; 
	.byte #%01100110; 
	.byte #%10100101;
	.byte #%01100110;
CC
	.byte #%11100111;
	.byte #%00100100; 
	.byte #%00100100; 
	.byte #%00100100;
	.byte #%11100111;

CD
	.byte #%01100110;
	.byte #%10100101; 
	.byte #%10100101; 
	.byte #%10100101;
	.byte #%01100110;

CE
	.byte #%11100111;
	.byte #%00100100; 
	.byte #%11100111; 
	.byte #%00100100; 
	.byte #%11100111;

CF
	.byte #%00100100;
	.byte #%00100100; 
	.byte #%11100111; 
	.byte #%00100100; 
	.byte #%11100111;

CG
	.byte #%11000011;
	.byte #%10100101; 
	.byte #%10100101; 
	.byte #%00100100; 
	.byte #%11000011;	

CH
	.byte #%10100101;
	.byte #%10100101; 
	.byte #%11100111; 
	.byte #%10100101; 
	.byte #%10100101;

CI
	.byte #%11100111;
	.byte #%01000010; 
	.byte #%01000010; 
	.byte #%01000010; 
	.byte #%11100111;

CJ
	.byte #%11100111;
	.byte #%10100101; 
	.byte #%10000001; 
	.byte #%10000001; 
	.byte #%10000001;	

CK
	.byte #%10100101;
	.byte #%10100101; 
	.byte #%01100110; 
	.byte #%10100101; 
	.byte #%10100101;

CL
	.byte #%11100111;
	.byte #%00100100; 
	.byte #%00100100; 
	.byte #%00100100; 
	.byte #%00100100;

CM
	.byte #%10100101;
	.byte #%10100101; 
	.byte #%10100101; 
	.byte #%11100111; 
	.byte #%10100101;

CN
	.byte #%10100101;
	.byte #%10100101; 
	.byte #%10100101; 
	.byte #%10100101; 
	.byte #%01100110;	


CO
	.byte #%01000010;
	.byte #%10100101; 
	.byte #%10100101; 
	.byte #%10100101; 
	.byte #%01000010;	

CP
	.byte #%00100100;
	.byte #%00100100; 
	.byte #%11100111; 
	.byte #%10100101; 
	.byte #%11100111;

CQ
    .byte #%10000001;
	.byte #%11100101; 
	.byte #%10100101; 
	.byte #%10100101; 
	.byte #%11100111;	

CR
	.byte #%10100101;
	.byte #%10100101; 
	.byte #%01100110; 
	.byte #%10100101; 
	.byte #%01100110;

CS
	.byte #%01100110;
	.byte #%10000001; 
	.byte #%01000010; 
	.byte #%00100100; 
	.byte #%11000011;

CT 
	.byte #%01000010;
	.byte #%01000010; 
	.byte #%01000010; 
	.byte #%01000010; 
	.byte #%11100111;

CU 
	.byte #%11100111;
	.byte #%10100101; 
	.byte #%10100101; 
	.byte #%10100101; 
	.byte #%10100101;	

CW 
	.byte #%10100101;
	.byte #%11100111; 
	.byte #%10100101; 
	.byte #%10100101; 
	.byte #%10100101;

CY
	.byte #%01000010;
	.byte #%01000010; 
	.byte #%01000010; 
	.byte #%10100101; 
	.byte #%10100101;

Exclamation
	.byte #%01000010;
	.byte #%00000000; 
	.byte #%01000010; 
	.byte #%01000010; 
	.byte #%01000010;

Pipe
Colon
	.byte #%01000010;
	.byte #%01000010; 
	.byte #%00000000; 
	.byte #%01000010; 
	.byte #%01000010;

Space
C0B
	.byte #%00000000;
	.byte #%00000000; 
	.byte #%00000000; 
	.byte #%00000000; 
	.byte #%00000000;	
C1B	
	.byte #%00100100;
	.byte #%00000000; 
	.byte #%00000000; 
	.byte #%00000000; 
	.byte #%00000000;
C2B
	.byte #%01100110;
	.byte #%00000000; 
	.byte #%00000000; 
	.byte #%00000000; 
	.byte #%00000000;
C3B
	.byte #%11100111;
	.byte #%00000000; 
	.byte #%00000000; 
	.byte #%00000000; 
	.byte #%00000000;
C4B
	.byte #%11100111;
	.byte #%00100100; 
	.byte #%00000000; 
	.byte #%00000000; 
	.byte #%00000000;
C5B
	.byte #%11100111;
	.byte #%01100110; 
	.byte #%00000000; 
	.byte #%00000000; 
	.byte #%00000000;
C6B
	.byte #%11100111;
	.byte #%11100111; 
	.byte #%00000000; 
	.byte #%00000000; 
	.byte #%00000000;
C7B
	.byte #%11100111;
	.byte #%11100111; 
	.byte #%00100100; 
	.byte #%00000000; 
	.byte #%00000000;
C8B
	.byte #%11100111;
	.byte #%11100111; 
	.byte #%01100110; 
	.byte #%00000000; 
	.byte #%00000000;
C9B
	.byte #%11100111;
	.byte #%11100111; 
	.byte #%11100111; 
	.byte #%00000000; 
	.byte #%00000000;
CAB
	.byte #%11100111;
	.byte #%11100111; 
	.byte #%11100111; 
	.byte #%00100100; 
	.byte #%00000000;
CBB
	.byte #%11100111;
	.byte #%11100111; 
	.byte #%11100111; 
	.byte #%01100110; 
	.byte #%00000000;
CCB
	.byte #%11100111;
	.byte #%11100111; 
	.byte #%11100111; 
	.byte #%11100111; 
	.byte #%00000000;

CDB
	.byte #%11100111;
	.byte #%11100111; 
	.byte #%11100111; 
	.byte #%11100111; 
	.byte #%00100100;

CEB
	.byte #%11100111;
	.byte #%11100111; 
	.byte #%11100111; 
	.byte #%11100111; 
	.byte #%01100110;

CFB
	.byte #%11100111;
	.byte #%11100111; 
	.byte #%11100111; 
	.byte #%11100111; 
	.byte #%11100111;

	org $FE00
AesTable
	DC.B $63,$7c,$77,$7b,$f2,$6b,$6f,$c5,$30,$01,$67,$2b,$fe,$d7,$ab,$76
	DC.B $ca,$82,$c9,$7d,$fa,$59,$47,$f0,$ad,$d4,$a2,$af,$9c,$a4,$72,$c0
	DC.B $b7,$fd,$93,$26,$36,$3f,$f7,$cc,$34,$a5,$e5,$f1,$71,$d8,$31,$15
	DC.B $04,$c7,$23,$c3,$18,$96,$05,$9a,$07,$12,$80,$e2,$eb,$27,$b2,$75
	DC.B $09,$83,$2c,$1a,$1b,$6e,$5a,$a0,$52,$3b,$d6,$b3,$29,$e3,$2f,$84
	DC.B $53,$d1,$00,$ed,$20,$fc,$b1,$5b,$6a,$cb,$be,$39,$4a,$4c,$58,$cf
	DC.B $d0,$ef,$aa,$fb,$43,$4d,$33,$85,$45,$f9,$02,$7f,$50,$3c,$9f,$a8
	DC.B $51,$a3,$40,$8f,$92,$9d,$38,$f5,$bc,$b6,$da,$21,$10,$ff,$f3,$d2
	DC.B $cd,$0c,$13,$ec,$5f,$97,$44,$17,$c4,$a7,$7e,$3d,$64,$5d,$19,$73
	DC.B $60,$81,$4f,$dc,$22,$2a,$90,$88,$46,$ee,$b8,$14,$de,$5e,$0b,$db
	DC.B $e0,$32,$3a,$0a,$49,$06,$24,$5c,$c2,$d3,$ac,$62,$91,$95,$e4,$79
	DC.B $e7,$c8,$37,$6d,$8d,$d5,$4e,$a9,$6c,$56,$f4,$ea,$65,$7a,$ae,$08
	DC.B $ba,$78,$25,$2e,$1c,$a6,$b4,$c6,$e8,$dd,$74,$1f,$4b,$bd,$8b,$8a
	DC.B $70,$3e,$b5,$66,$48,$03,$f6,$0e,$61,$35,$57,$b9,$86,$c1,$1d,$9e
	DC.B $e1,$f8,$98,$11,$69,$d9,$8e,$94,$9b,$1e,$87,$e9,$ce,$55,$28,$df
	DC.B $8c,$a1,$89,$0d,$bf,$e6,$42,$68,$41,$99,$2d,$0f,$b0,$54,$bb,$16
	
    org $FF00
StaticText ; All static text must be on the same MSB block. 
CheckpointText; Only the LSB, which is the offset.
	.byte #<CC + #FONT_OFFSET
	.byte #<CK + #FONT_OFFSET
	.byte #<CP + #FONT_OFFSET 
	.byte #<CT + #FONT_OFFSET

HellwayLeftText
	.byte #<Pipe + #FONT_OFFSET
	.byte #<CH + #FONT_OFFSET 
	.byte #<CL + #FONT_OFFSET
	.byte #<CY + #FONT_OFFSET

HellwayRightText
	.byte #<Space + #FONT_OFFSET
	.byte #<C2 + #FONT_OFFSET
	.byte #<CP + #FONT_OFFSET
	.byte #<CE + #FONT_OFFSET 
	.byte #<Exclamation + #FONT_OFFSET

OpbText
	.byte #<Pipe + #FONT_OFFSET
	.byte #<CO + #FONT_OFFSET
	.byte #<CP + #FONT_OFFSET 
	.byte #<CB + #FONT_OFFSET 

YearText
	.byte #<Space + #FONT_OFFSET
	.byte #<C2 + #FONT_OFFSET
	.byte #<C0 + #FONT_OFFSET
	.byte #<C2 + #FONT_OFFSET 
	.byte #<C2 + #FONT_OFFSET

GoText
	.byte #<CG + #FONT_OFFSET
	.byte #<CO + #FONT_OFFSET
	.byte #<Exclamation + #FONT_OFFSET
	.byte #<Exclamation + #FONT_OFFSET 

WinText
    .byte #<Pipe + #FONT_OFFSET
	.byte #<C1 + #FONT_OFFSET
	.byte #<Pipe + #FONT_OFFSET

LoseText
    .byte #<Pipe + #FONT_OFFSET
	.byte #<C2 + #FONT_OFFSET
	.byte #<Pipe + #FONT_OFFSET

BuildNumberText
    .byte #<Space + #FONT_OFFSET
    .byte #<C0 + #FONT_OFFSET
	.byte #<CP + #FONT_OFFSET
	.byte #<CH + #FONT_OFFSET
	.byte #<C3 + #FONT_OFFSET 

ReadyText
    .byte #<CR + #FONT_OFFSET
	.byte #<CE + #FONT_OFFSET
	.byte #<CA + #FONT_OFFSET
	.byte #<CD + #FONT_OFFSET 
	.byte #<CY + #FONT_OFFSET

EndStaticText

EngineSoundType
	.byte #2
	.byte #2
	.byte #14
	.byte #6
	.byte #6
	.byte #14

EngineBaseFrequence
	.byte #31
	.byte #21
	.byte #20
	.byte #31
	.byte #22
	.byte #3

CarSprite0 ; Upside down, Original Car
	ds (CAR_START_LINE - 7)
CarSprite0NoPadding
	.byte #%01111110
	.byte #%00100100
	.byte #%10111101
	.byte #%00111100
	.byte #%10111101
	.byte #%00111100

CarSprite1 ; Car variant posted by KevinMos3 (AtariAge), thanks!
	ds (CAR_START_LINE - 7)
CarSprite1NoPadding
	.byte #%10111101
	.byte #%01111110
	.byte #%01011010
	.byte #%01100110
	.byte #%10111101
	.byte #%00111100

CarSprite2 ; Car variant posted by TIX (AtariAge), his normal car, thanks!
	ds (CAR_START_LINE - 7)
CarSprite2NoPadding
	.byte #%01111110
	.byte #%10100101
	.byte #%01000010
	.byte #%01000010
	.byte #%10111101
	.byte #%01111110

CarSprite3 ; Car variant posted by TIX (AtariAge), dragster, thanks!
	ds (CAR_START_LINE - 7)
CarSprite3NoPadding
	.byte #%00111100
	.byte #%11011011
	.byte #%11011011
	.byte #%00111100
	.byte #%01011010
	.byte #%00111100

    ds 1 ; Car start line is wrong, I would have to change all constants, for the others the existing padding solves. Waste 1 byte, save sanity!

ArrowUpSprite
    .byte #%00011000
    .byte #%00011000
	.byte #%01111110
	.byte #%00111100
	.byte #%00011000

ArrowDownSprite
    ds 2
    .byte #%00011000
	.byte #%00111100
	.byte #%01111110
    .byte #%00011000
    .byte #%00011000
	

TrafficSpeeds
	.byte #$00;  Trafic0 L
	.byte #$00;  Trafic0 H
	.byte #$0A;  Trafic1 L
	.byte #$01;  Trafic1 H
	.byte #$E6;  Trafic2 L
	.byte #$00;  Trafic2 H
	.byte #$C2;  Trafic3 L
	.byte #$00;  Trafic3 H
	.byte #$9E;  Trafic4 L
	.byte #$00;  Trafic4 H
TrafficSpeedsHighDelta
	.byte #$00;  Trafic0 L
	.byte #$00;  Trafic0 H
	.byte #$0A;  Trafic1 L
	.byte #$01;  Trafic1 H
	.byte #$C8;  Trafic2 L
	.byte #$00;  Trafic2 H
	.byte #$86;  Trafic3 L
	.byte #$00;  Trafic3 H
	.byte #$44;  Trafic4 L
	.byte #$00;  Trafic4 H

CarIdToSpriteAddressL
	.byte #<CarSprite0
	.byte #<CarSprite1
	.byte #<CarSprite2
	.byte #<CarSprite3

CarIdToSpriteAddressH
	.byte #>CarSprite0
	.byte #>CarSprite1
	.byte #>CarSprite2
	.byte #>CarSprite3

EnemyCarIdToSpriteAddressL
	.byte #<CarSprite0NoPadding
	.byte #<CarSprite1NoPadding
	.byte #<CarSprite2NoPadding
	.byte #<CarSprite3NoPadding

EnemyCarIdToSpriteAddressH
	.byte #>CarSprite0NoPadding
	.byte #>CarSprite1NoPadding
	.byte #>CarSprite2NoPadding
	.byte #>CarSprite3NoPadding

CarIdToAccelerateSpeed
	.byte #128
	.byte #192
	.byte #96
	.byte #192

CarIdToTimeoverBreakInterval ; Glide
	.byte #%00000011 ;Every 4 frames
	.byte #%00000011 ;Every 4 frames
	.byte #%00001111 ;Every 16 frames
	.byte #%00000011 ;Every 4 frames

CarIdToMaxSpeedL
	.byte #$80
	.byte #$00 ; One less gear
	.byte #$80
	.byte #$80 

CarIdToMaxGear
	.byte #5
	.byte #4 ; One less gear
	.byte #5
	.byte #5

GearToBreakSpeedTable
	.byte #(BREAK_SPEED - 1)
	.byte #(BREAK_SPEED - 1)
	.byte #(BREAK_SPEED + 0)
	.byte #(BREAK_SPEED + 1)
	.byte #(BREAK_SPEED + 2)
	.byte #(BREAK_SPEED + 2)

TrafficColorTable
	.byte #TRAFFIC_COLOR_LIGHT
	.byte #TRAFFIC_COLOR_REGULAR
	.byte #TRAFFIC_COLOR_INTENSE
	.byte #TRAFFIC_COLOR_RUSH_HOUR

TrafficChanceTable
	.byte #TRAFFIC_CHANCE_LIGHT
	.byte #TRAFFIC_CHANCE_REGULAR
	.byte #TRAFFIC_CHANCE_INTENSE
	.byte #TRAFFIC_CHANCE_RUSH_HOUR

TrafficTimeTable
	.byte #CHECKPOINT_TIME_LIGHT
	.byte #CHECKPOINT_TIME_REGULAR
	.byte #CHECKPOINT_TIME_INTENSE
	.byte #CHECKPOINT_TIME_RUSH_HOUR
	.byte #CHECKPOINT_TIME_LIGHT ; For cycling, makes code easier


	org $FFFC
		.word BeforeStart
		.word BeforeStart ; Can be used for subrotine (BRK)