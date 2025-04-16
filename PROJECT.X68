*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
   ORG $1000

; ------------------------------------------------------
; CONSTANTS 
; ------------------------------------------------------
MIN_RESOURCES       EQU 1         ; Minimum resources gain 
MAX_RESOURCES       EQU 5         ; Maximum resources gain 
MIN_THREATS         EQU 1         ; Minimum threat damage 
MAX_THREATS         EQU 3         ; Maximum threat damage 

; Role-specific starting values and point adjustments
SURVIVOR_INIT_SCORE EQU 60        ; Survivor starts with 60 points
SURVIVOR_WIN_POINT  EQU 15        ; Gain 15 points for resources (Survivor)
SURVIVOR_LOSE_POINT EQU 10        ; Lose 10 points when hit by a threat (Survivor)

EXPLORER_INIT_SCORE EQU 40        ; Explorer starts with 40 points
EXPLORER_WIN_POINT  EQU 5         ; Gain 5 points for resources (Explorer)
EXPLORER_LOSE_POINT EQU 2         ; Lose 2 points when hit by a threat (Explorer)

THREAT_LOC          EQU 50        ; If input >= 50, potential threat event
RESOURCE_LOC        EQU 25        ; If input <= 25, potential resource event
WIN_THRESHOLD       EQU 100       ; Score of 100 or more wins the game

; Health-related constants
INITIAL_HEALTH      EQU 100       ; Player starts with 100 health points
HEALTH_DAMAGE       EQU 10        ; Each threat event subtracts 10 health points

; Level system:
; Level 1 -> 2: Score >= 50, Level 2 -> 3: Score >= 75, Level 3 -> 4: Score >= 90
THREAT_INCREASE     EQU 2         ; Each level-up increases threat damage by 2

; ------------------------------------------------------
; START OF GAME
; ------------------------------------------------------
START:
    BSR     WELCOME         ; Display welcome message and game objective
    BSR     INPUT           ; Read player’s role choice
    BSR     GAME            ; Enter the main game loop

; ------------------------------------------------------
; GAME LOOP AREA 
; ------------------------------------------------------
    ORG $3000               ; Starting address for game loop

GAME:
    BSR     GAMELOOP        ; Begin main game loop
    RTS                     

END:
    SIMHALT                 

; ------------------------------------------------------
; WELCOME: Display the welcome screen and objective
; ------------------------------------------------------
WELCOME:
    BSR     ENDL            ; Print newline 
    LEA     WELCOME_MSG,A1  ; Load address of welcome message
    MOVE.B  #14,D0          ; Set system call code for text output
    TRAP    #15             ; Output the welcome message
    BSR     ENDL            ; Newline

    ; Show game objective including health and level details
    BSR     OBJECTIVE
    BSR     CONTINUE        ; Wait for any key to continue
    RTS

; ------------------------------------------------------
; OBJECTIVE: Display the game storyline and instructions
; ------------------------------------------------------
OBJECTIVE:
    LEA     GAME_OBJECTIVE_MSG,A1  ; Load the objective message address
    MOVE.B  #14,D0                 ; Set output code
    TRAP    #15                    ; Print message
    BSR     ENDL                   ; Newline 
    RTS

; ------------------------------------------------------
; INPUT: Get the player's initial choice (role selection)
; ------------------------------------------------------
INPUT:
    BSR     ENDL                   ; Newline
    LEA     INPUT_MSG,A1           ; Print message
    MOVE.B  #14,D0                 ; Set output code for text
    TRAP    #15                    ; Print the prompt
    MOVE.B  #4,D0                  ; Set system call code for input
    TRAP    #15                    ; Read player's input into D1

    ; Check player's input for valid choices
    CMP.B   #1,D1                  ; If 1, choose Survivor
    BEQ     CHOICE_1
    CMP.B   #2,D1                  ; If 2, choose Explorer
    BEQ     CHOICE_2
    CMP.B   #3,D1                  ; If 3, exit game
    BEQ     CHOICE_3
    BRA     INPUT                  ; If invalid, repeat input

; ------------------------------------------------------
; CHOICE_1: Set up Survivor settings
; ------------------------------------------------------
CHOICE_1:
    LEA     CHOICE1_MSG,A1         ; Survivor choice message
    MOVE.B  #14,D0                 ; Set output code
    TRAP    #15                    ; Display message

    ; Initialize score and point adjustments for Survivor
    MOVE.B  #SURVIVOR_INIT_SCORE,(A3) ; initial score to 60
    MOVE.B  #SURVIVOR_WIN_POINT,D2     ; Resource gain: +15 points
    MOVE.B  #SURVIVOR_LOSE_POINT,D5    ; Threat damage: -10 points
    MOVE.W  #INITIAL_HEALTH, HEALTH   ; health to 100
    MOVE.B  #1, LEVEL              ; Start at level 1

    ; Display starting score and health
    LEA     INIT_SCORE_MSG,A1      ; Initial Score message
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A3),D1                ; Display score from memory (A3)
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL
    LEA     INIT_HEALTH_MSG,A1     ; Initial Health message
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.W  HEALTH,D1              ; Display health
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL
    RTS

; ------------------------------------------------------
; CHOICE_2: Set up Explorer settings
; ------------------------------------------------------
CHOICE_2:
    LEA     CHOICE2_MSG,A1         ; Explorer choice message
    MOVE.B  #14,D0
    TRAP    #15                    ; Display message

    ; Initialize score and point adjustments for Explorer
    MOVE.B  #EXPLORER_INIT_SCORE,(A3) ; initial score to 40
    MOVE.B  #EXPLORER_WIN_POINT,D2     ; Resource gain: +5 points
    MOVE.B  #EXPLORER_LOSE_POINT,D5    ; Threat damage: -2 points
    MOVE.W  #INITIAL_HEALTH, HEALTH   ; health to 100
    MOVE.B  #1, LEVEL              ; Start at level 1

    ; Display starting score and health
    LEA     INIT_SCORE_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A3),D1
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL
    LEA     INIT_HEALTH_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.W  HEALTH,D1
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL
    RTS

; ------------------------------------------------------
; CHOICE_3: Exit the game
; ------------------------------------------------------
CHOICE_3:
    LEA     EXIT_MSG,A1            ; Exit message
    MOVE.B  #14,D0
    TRAP    #15                    ; Display exit message
    BRA     END

; ------------------------------------------------------
; GAMEPLAY: Main loop for processing events (resource, threat, healing, bonus)
; ------------------------------------------------------
GAMEPLAY:
    BSR     ENDL                   ; Newline
    BSR     DECORATE               ; Draw separator line
    LEA     GAMEPLAY_MSG,A1        ; "Survival begins!" message
    MOVE.B  #14,D0
    TRAP    #15

; INPUT_LOOP: Read input for events
INPUT_LOOP:
    LEA     INPUT_NUMBER_MSG,A1    ; Prompt
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0                  ; Input system call
    TRAP    #15                   ; Read player's number into D1

    CMP.B   #1,D1                  ; Validate input range (>=1)
    BLT     INVALID_INPUT
    CMP.B   #100,D1                ; Validate input range (<=100)
    BGT     INVALID_INPUT

    ; Check for special events based on exact input values
    CMP.B   #100,D1                ; If 100, trigger bonus event
    BEQ     BONUS_EVENT
    CMP.B   #70,D1                 ; If 70, trigger healing event
    BEQ     HEALING_EVENT

    ; Determine if threat or resource event
    CMP.B   #50,D1                 ; If input >= 50, potential threat
    BLT     CHECK_RESOURCE         ; Otherwise, check for resource event
    CMP.B   #75,D1                 ; If input < 75, it's a threat event
    BGT     CHECK_RESOURCE         ; If >75, then not threat event, check resource
    BSR     HIT_THREAT             ; Process threat event
    BRA     GAMEPLAY_END

CHECK_RESOURCE:
    CMP.B   #1,D1                  ; If input < 1, invalid 
    BLT     NO_RESOURCE
    CMP.B   #25,D1                 ; If input > 25, no resource found
    BGT     NO_RESOURCE
    BSR     FOUND_RESOURCE         ; Process resource event
    BRA     GAMEPLAY_END

NO_RESOURCE:
    LEA     NO_RESOURCE_MSG,A1         
    TRAP    #15
    BRA     GAMEPLAY_END

INVALID_INPUT:
    LEA     INVALID_INPUT_MSG,A1  
    MOVE.B  #14,D0
    TRAP    #15
    BRA     INPUT_LOOP             ; Retry input

; ------------------------------------------------------
; BONUS_EVENT: Add extra 10 points when input is exactly 100
; ------------------------------------------------------
BONUS_EVENT:
    LEA     BONUS_MSG,A1           ; Display bonus event message
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A3),D4                ; Load current score
    ADD.B   #10,D4                 ; Add bonus points
    MOVE.B  D4,(A3)                ; Update score in memory
    LEA     UPDATED_SCORE_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15                    ; Show updated score message
    MOVE.B  (A3),D1                ; Display updated score
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL
    BRA     GAMEPLAY_END

; ------------------------------------------------------
; HEALING_EVENT: Recover 15 health (capped at 100) when input is exactly 70
; ------------------------------------------------------
HEALING_EVENT:
    LEA     HEALING_MSG,A1         ; Display healing event message
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.W  HEALTH,D7              ; Load current health into D7
    ADD.W   #15,D7                 ; Add 15 health points
    CMP.W   #INITIAL_HEALTH,D7     ; Check if health exceeds maximum (100)
    BLS     HEALING_OK             ; If not, continue
    MOVE.W  #INITIAL_HEALTH,D7     ; Otherwise, cap at 100
HEALING_OK:
    MOVE.W  D7, HEALTH             ; Update health value
    LEA     UPDATED_HEALTH_MSG,A1  ; Display updated health message
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.W  HEALTH,D1             ; Show new health value
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL
    BRA     GAMEPLAY_END

; ------------------------------------------------------
; LEVEL_UP: Increases level and threat damage when fixed thresholds are met
; ------------------------------------------------------
LEVEL_UP:
    LEA     LEVEL_UP_MSG,A1        ; Message
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  LEVEL,D7               ; Get current level
    ADD.B   #1,D7                  ; Increment level by 1
    MOVE.B  D7, LEVEL              ; Save new level
    ADD.B   #THREAT_INCREASE,D5    ; Increase threat damage by 2
    LEA     UPDATED_LEVEL_MSG,A1   ; Message
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  LEVEL,D1               ; Display new level number
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL
    RTS

; ------------------------------------------------------
; GAMEPLAY_END: End current iteration; check for level up thresholds
; ------------------------------------------------------
GAMEPLAY_END:
    MOVE.B  (A3),D4                ; Load current score
    MOVE.B  LEVEL,D7               ; Load current level
    ; Check fixed thresholds:
    ; Level 1 -> 2 when score >= 50, Level 2 -> 3 when score >= 75, Level 3 -> 4 when score >= 90
    CMP.B   #1,D7
    BEQ     L1_CHECK
    CMP.B   #2,D7
    BEQ     L2_CHECK
    CMP.B   #3,D7
    BEQ     L3_CHECK
    BRA     AFTER_LEVEL_CHECK

L1_CHECK:
    CMP.B   #50,D4                ; For level 1, need score >= 50 to level up
    BLT     AFTER_LEVEL_CHECK
    BRA     LEVEL_UP

L2_CHECK:
    CMP.B   #75,D4                ; For level 2, need score >= 75
    BLT     AFTER_LEVEL_CHECK
    BRA     LEVEL_UP

L3_CHECK:
    CMP.B   #90,D4                ; For level 3, need score >= 90
    BLT     AFTER_LEVEL_CHECK
    BRA     LEVEL_UP

AFTER_LEVEL_CHECK:
    BSR     DECORATE              ; Print separator 
    RTS

; ------------------------------------------------------
; GAMELOOP: Main loop that updates state, draws screen, processes input,
;           displays HUD (score, health, level), and handles replay
; ------------------------------------------------------
GAMELOOP:
    BSR     UPDATE                ; Show update message
    BSR     DRAW                  ; Show drawing message
    BSR     GAMEPLAY              ; Process gameplay events
    BSR     HUD                   ; Display current score, health, level
    BSR     REPLAY                ; Ask to continue or restart
    RTS

; ------------------------------------------------------
; UPDATE: Display update message
; ------------------------------------------------------
UPDATE:
    BSR     ENDL
    BSR     DECORATE
    LEA     UPDATE_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BSR     DECORATE
    RTS

; ------------------------------------------------------
; DRAW: Display drawing message
; ------------------------------------------------------
DRAW:
    BSR     ENDL
    BSR     DECORATE
    LEA     DRAW_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BSR     DECORATE
    RTS

; ------------------------------------------------------
; HUD: Show current score, health, and level on the screen
; ------------------------------------------------------
HUD:
    BSR     ENDL
    BSR     DECORATE
    LEA     HUD_MSG,A1             ; Score label
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A3),D1              ; Display score from memory
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL
    LEA     HEALTH_MSG,A1          ; Health label
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.W  HEALTH,D1            ; Display current health
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL
    LEA     LEVEL_MSG,A1           ; Level label
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  LEVEL,D1             ; Display current level
    MOVE.B  #3,D0
    TRAP    #15
    BSR     DECORATE
    RTS

; ------------------------------------------------------
; FOUND_RESOURCE: Process resource event (increase score)
; ------------------------------------------------------
FOUND_RESOURCE:
    LEA     FOUND_RESOURCE_MSG,A1  ; Message
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A3),D4              ; Load current score
    ADD.B   D2,D4                ; Add resource points
    MOVE.B  D4,(A3)              ; Update score
    LEA     UPDATED_SCORE_MSG,A1 ; Message
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A3),D1              ; Display updated score
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL
    ; Check win condition
    MOVE.B  (A3),D4
    CMP.B   #WIN_THRESHOLD,D4
    BGE     GAME_WON             ; Win if score >= 100
    BRA     GAMEPLAY_END

; ------------------------------------------------------
; HIT_THREAT: Process threat event (decrease score and health)
; ------------------------------------------------------
HIT_THREAT:
    LEA     HIT_THREAT_MSG,A1      ; Threat message
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A3),D4              ; Load current score
    SUB.B   D5,D4                ; Subtract threat points
    MOVE.B  D4,(A3)              ; Update score
    ; Subtract health damage
    MOVE.W  HEALTH,D6
    SUB.W   #HEALTH_DAMAGE,D6
    MOVE.W  D6, HEALTH
    CMP.W   #1,D6                ; If health < 1, player loses
    BLT     GAME_LOST
    LEA     UPDATED_SCORE_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A3),D1
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL
    RTS

; ------------------------------------------------------
; DECORATE: Print a line of 60 equals signs as a separator
; ------------------------------------------------------
DECORATE:
    MOVE.B  #60,D3
    BSR     ENDL
OUT:
    LEA     LOOP_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    SUB     #1,D3
    BNE     OUT
    BSR     ENDL
    RTS


; ------------------------------------------------------
; REPLAY: Ask the player to continue, restart, or quit
; ------------------------------------------------------
REPLAY:
    BSR     ENDL
    LEA     REPLAY_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0
    TRAP    #15
    CMP.B   #1,D1                ; If input == 1, continue
    BEQ     CONTINUE_GAME
    CMP.B   #5,D1                ; If input == 5, restart
    BEQ     RESTART_GAME
    BRA     END

CONTINUE_GAME:
    BSR     GAMELOOP
    RTS

RESTART_GAME:
    BSR     START

; ------------------------------------------------------
; CONTINUE: Wait for player input before proceeding
; ------------------------------------------------------
CONTINUE:
    BSR     ENDL
    LEA     CONTINUE_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0
    TRAP    #15
    RTS

; ------------------------------------------------------
; ENDL: Output newline (CR and LF)
; ------------------------------------------------------
ENDL:
    MOVEM.L D0/A1,-(A7)
    MOVE    #14,D0
    LEA     CRLF,A1
    TRAP    #15
    MOVEM.L (A7)+,D0/A1
    RTS

; ------------------------------------------------------
; GAME_LOST: Display "You lost" and restart game
; ------------------------------------------------------
GAME_LOST:
    BSR     ENDL
    LEA     GAME_LOST_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BSR     ENDL
    BSR     RESTART_GAME
    RTS

; ------------------------------------------------------
; GAME_WON: Display "You won" and restart game
; ------------------------------------------------------
GAME_WON:
    BSR     ENDL
    LEA     GAME_WON_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BSR     ENDL
    BSR     RESTART_GAME
    RTS

; ------------------------------------------------------
; DATA DECLARATIONS: Message strings and variable storage
; ------------------------------------------------------
CRLF:               DC.B  $0D,$0A,0

WELCOME_MSG:        
    DC.B '***************************************************************', $0D,$0A
    DC.B '*                     WELCOME TO SURVIVE!                     *', $0D,$0A
    DC.B '*  Embark on a post-apocalyptic journey of danger and strategy. *', $0D,$0A
    DC.B '***************************************************************', $0D,$0A
    DC.B '1. SURVIVOR (HIGH SCORE, HIGH RISK)', $0D,$0A
    DC.B '2. EXPLORER (LOW SCORE, LOW RISK)', $0D,$0A
    DC.B '3. EXIT GAME', $0D,$0A,0

INPUT_MSG:          
    DC.B 'ENTER YOUR CHOICE (1, 2, OR 3): ',0

EXIT_MSG:           
    DC.B 'Exiting the game... Goodbye!',0

GAMEPLAY_MSG:       
    DC.B '>> SURVIVAL BEGINS! <<',0

UPDATE_MSG:         
    DC.B '-- Updating Survival Status --',0

DRAW_MSG:           
    DC.B '-- Redrawing the Wilderness --',0

INPUT_NUMBER_MSG:   
    DC.B 'ENTER A NUMBER BETWEEN 1 AND 100: ',0

FOUND_RESOURCE_MSG: 
    DC.B '*** RESOURCES FOUND! (+',0

NO_RESOURCE_MSG:    
    DC.B '--- No resources in sight...',0

HIT_THREAT_MSG:     
    DC.B '!!! ALERT: Threat Encountered! (-',0

UPDATED_SCORE_MSG:  
    DC.B '>>> UPDATED SCORE: ',0

LOOP_MSG:           
    DC.B '=',0

REPLAY_MSG:         
    DC.B 'Press [1] to CONTINUE, [5] to RESTART, or any other key to QUIT: ',0

CONTINUE_MSG:       
    DC.B 'Press any key to continue...',0

HUD_MSG:            
    DC.B 'SCORE: ',0

HEALTH_MSG:         
    DC.B 'HEALTH: ',0

LEVEL_MSG:          
    DC.B 'LEVEL: ',0

INIT_SCORE_MSG:     
    DC.B 'Starting Score: ',0

INIT_HEALTH_MSG:    
    DC.B 'Starting Health: ',0

INVALID_INPUT_MSG:  
    DC.B '*** Invalid input. Please try again. ***',0

CHOICE1_MSG:        
    DC.B '*** You chose SURVIVOR! High risk, high reward awaits you. ***', $0D,$0A
    DC.B 'Gain 15 points for resources, lose 10 for threats.', $0D,$0A,0

CHOICE2_MSG:        
    DC.B '*** You chose EXPLORER! A cautious path with steadier gains. ***', $0D,$0A
    DC.B 'Gain 5 points for resources, lose 2 for threats.', $0D,$0A,0

HEALING_MSG:        
    DC.B '+++ Healing Event: You recover 15 health points!', $0D,$0A,0

UPDATED_HEALTH_MSG: 
    DC.B '>>> UPDATED HEALTH: ',0

LEVEL_UP_MSG:       
    DC.B '### LEVEL UP! ###', $0D,$0A,0

UPDATED_LEVEL_MSG:  
    DC.B '>>> NEW LEVEL: ',0

GAME_OBJECTIVE_MSG:
    DC.B '---------------------------------------------------------------', $0D,$0A
    DC.B 'In a desolate wasteland, your only hope is to gather vital resources', $0D,$0A
    DC.B 'and avoid perilous threats that lurk in every shadow. Every choice', $0D,$0A
    DC.B 'could mean the difference between life and death. Reach 100 points to win,', $0D,$0A
    DC.B 'but beware: if your score falls to 0, you meet your end.', $0D,$0A
    DC.B '---------------------------------------------------------------', $0D,$0A
    DC.B 'Good luck, survivor!', $0D,$0A,0

BONUS_MSG:          
    DC.B '+++ BONUS EVENT! Extra 10 points awarded!', $0D,$0A,0

GAME_LOST_MSG:      
    DC.B 'XXX YOU LOST! The wasteland claims another victim...',0

GAME_WON_MSG:       
    DC.B '*** CONGRATULATIONS! YOU WON THE SURVIVAL CHALLENGE! ***',0

; Variables
LEVEL:              DS.B 1            ; Player's current level
HEALTH:             DS.W 1            ; Player's health
SCORE               DS.W 1            ; Player's score
        
    END START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
