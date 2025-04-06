' ===================================================
' ENDLESS RUNNER GAME
' ===================================================
' A simple pseudo-graphic game where the player ('O')
' moves across the screen avoiding obstacles.
' ===================================================

' Set screen mode and hide cursor
SCREEN 0
WIDTH 80, 25
COLOR 15, 0
CLS
LOCATE , , 0

' Game variables
DIM playerX%: playerX% = 5        ' Player's X position (can move left/right)
DIM playerY%: playerY% = 12       ' Player's Y position (vertical)
DIM gameSpeed!: gameSpeed! = 50   ' Starting game speed (lower = faster)
DIM score&: score& = 0            ' Player's score

' Game area boundaries
CEILING% = 2                      ' Top boundary (excluding border)
FLOOR% = 24                       ' Bottom boundary (excluding border)
LEFT_WALL% = 2                    ' Left boundary
RIGHT_WALL% = 75                  ' Right boundary
HORIZ_CENTER% = 13                ' Horizontal center line

' Obstacle types
TYPE_MOUNTAIN% = 1                ' Mountain obstacle type
TYPE_CLOUD% = 2                   ' Cloud obstacle type
MAX_OBSTACLES% = 20               ' Maximum number of active obstacles

' Obstacle arrays
DIM obsActive%(MAX_OBSTACLES%)    ' Is obstacle active (0/1)
DIM obsType%(MAX_OBSTACLES%)      ' Type (1=mountain, 2=cloud)
DIM obsX%(MAX_OBSTACLES%)         ' X position
DIM obsY%(MAX_OBSTACLES%)         ' Y position
DIM obsWidth%(MAX_OBSTACLES%)     ' Width of obstacle
DIM obsHeight%(MAX_OBSTACLES%)    ' Height of obstacle

' Initialize obstacles
FOR i% = 1 TO MAX_OBSTACLES%
    obsActive%(i%) = 0            ' No active obstacles at start
NEXT i%

' Draw game border
LOCATE 1, 1: PRINT STRING$(80, "=");
LOCATE 25, 1: PRINT STRING$(80, "=");

' Main game loop
DO
    ' Check for keyboard input
    k$ = INKEY$
    IF k$ = CHR$(27) THEN EXIT DO          ' ESC to quit
    IF k$ = CHR$(0) + "H" THEN             ' Up arrow
        IF playerY% > CEILING% THEN playerY% = playerY% - 1
    END IF
    IF k$ = CHR$(0) + "P" THEN             ' Down arrow
        IF playerY% < FLOOR% THEN playerY% = playerY% + 1
    END IF
    IF k$ = CHR$(0) + "K" THEN             ' Left arrow
        IF playerX% > LEFT_WALL% THEN playerX% = playerX% - 1
    END IF
    IF k$ = CHR$(0) + "M" THEN             ' Right arrow
        IF playerX% < RIGHT_WALL% THEN playerX% = playerX% + 1
    END IF
    
    ' Display game info
    LOCATE 2, 1: PRINT "Score:"; score&;
    LOCATE 3, 1: PRINT "Controls: Arrows = Move, ESC = Quit";
    
    ' Generate new obstacles
    IF RND < 0.03 THEN
        ' 3% chance for mountain
        ' Find empty slot for new obstacle
        FOR i% = 1 TO MAX_OBSTACLES%
            IF obsActive%(i%) = 0 THEN
                obsActive%(i%) = 1
                obsType%(i%) = TYPE_MOUNTAIN%
                obsX%(i%) = 78              ' Start at right edge
                obsWidth%(i%) = INT(RND * 10) + 3     ' Width 3-7
                obsHeight%(i%) = INT(RND * 5) + 2    ' Height 2-5
                obsY%(i%) = FLOOR% - obsHeight%(i%) + 1  ' Position at bottom
                EXIT FOR
            END IF
        NEXT i%
    END IF
    
    IF RND < 0.05 THEN
        ' 5% chance for cloud
        ' Find empty slot for new obstacle
        FOR i% = 1 TO MAX_OBSTACLES%
            IF obsActive%(i%) = 0 THEN
                obsActive%(i%) = 1
                obsType%(i%) = TYPE_CLOUD%
                obsX%(i%) = 78              ' Start at right edge
                obsWidth%(i%) = INT(RND * 6) + 5     ' Width 5-10
                obsHeight%(i%) = 2                   ' Height 1
                obsY%(i%) = INT(RND * 4) + (HORIZ_CENTER% - 4)  ' Position above center
                EXIT FOR
            END IF
        NEXT i%
    END IF
    
    ' Clear the game area (except borders)
    FOR y% = CEILING% TO FLOOR%
        LOCATE y%, 1: PRINT SPACE$(80);
    NEXT y%
    
    ' Process all active obstacles
    collision% = 0
    
    FOR i% = 1 TO MAX_OBSTACLES%
        IF obsActive%(i%) = 1 THEN
            ' Move obstacle left
            obsX%(i%) = obsX%(i%) - 1
            
            ' Remove if off screen
            IF obsX%(i%) + obsWidth%(i%) < LEFT_WALL% THEN
                obsActive%(i%) = 0
            ELSE
                ' Draw obstacle based on type
                IF obsType%(i%) = TYPE_MOUNTAIN% THEN
                    ' Draw a mountain
                    COLOR 6, 0 ' Brown mountains
                    
                    ' Draw the mountain
                    FOR j% = 0 TO obsHeight%(i%) - 1
                        mountainWidth% = obsWidth%(i%) - j% * 2
                        IF mountainWidth% < 1 THEN EXIT FOR
                        
                        FOR k% = 0 TO mountainWidth% - 1
                            IF obsX%(i%) + k% + j% <= RIGHT_WALL% AND obsX%(i%) + k% + j% >= LEFT_WALL% THEN
                                LOCATE obsY%(i%) - j%, obsX%(i%) + k% + j%
                                IF j% = 0 THEN
                                    PRINT "M"; ' Base of mountain
                                ELSEIF j% = obsHeight%(i%) - 1 THEN
                                    PRINT "^"; ' Peak of mountain
                                ELSE
                                    PRINT "#"; ' Body of mountain
                                END IF
                            END IF
                        NEXT k%
                    NEXT j%
                    COLOR 15, 0 ' Back to white
                ELSE ' TYPE_CLOUD
                    ' Draw a cloud
                    COLOR 15, 0 ' White clouds
                    FOR j% = 0 TO obsWidth%(i%) - 1
                        IF obsX%(i%) + j% <= RIGHT_WALL% AND obsX%(i%) + j% >= LEFT_WALL% THEN
                            LOCATE obsY%(i%), obsX%(i%) + j%
                            PRINT "~";
                        END IF
                    NEXT j%
                    COLOR 15, 0 ' Back to white
                END IF
                
                ' Check for collision with mountain
                IF obsType%(i%) = TYPE_MOUNTAIN% THEN
                    ' Check if player is inside mountain area
                    IF playerY% >= obsY%(i%) - obsHeight%(i%) + 1 AND playerY% <= obsY%(i%) THEN
                        ' Calculate effective width at this height
                        heightFromBase% = obsY%(i%) - playerY%
                        effectiveWidth% = obsWidth%(i%) - heightFromBase% * 2
                        IF effectiveWidth% < 1 THEN effectiveWidth% = 1
                        
                        ' Check if player X is within effective width
                        IF playerX% >= obsX%(i%) AND playerX% < obsX%(i%) + effectiveWidth% + heightFromBase% THEN
                            collision% = 1
                        END IF
                    END IF
                ' Check for collision with cloud
                ELSEIF obsType%(i%) = TYPE_CLOUD% THEN
                    ' Check if player is inside cloud area
                    IF playerY% = obsY%(i%) AND playerX% >= obsX%(i%) AND playerX% < obsX%(i%) + obsWidth%(i%) THEN
                        collision% = 1
                    END IF
                END IF
            END IF
        END IF
    NEXT i%
    
    ' Show player
    LOCATE playerY%, playerX%
    COLOR 14, 0                   ' Yellow for player
    PRINT "O";
    COLOR 15, 0                   ' Back to white
    
    ' Handle collision
    IF collision% THEN
        ' Collision detected
        FOR blink% = 1 TO 5
            LOCATE playerY%, playerX%
            COLOR 4, 0: PRINT "X";         ' Red X at collision
            _DELAY 0.1                     ' Short delay
            LOCATE playerY%, playerX%
            COLOR 14, 0: PRINT "O";        ' Player
            _DELAY 0.1                     ' Short delay
        NEXT blink%
        
        ' Game over screen
        COLOR 15, 0
        LOCATE 12, 35: PRINT "GAME OVER!"
        LOCATE 14, 30: PRINT "Final Score:"; score&
        LOCATE 16, 27: PRINT "Press ESC to quit"
        LOCATE 17, 25: PRINT "Press any key to restart"
        
        ' Wait for key press
        DO
            k$ = INKEY$
            IF k$ = CHR$(27) THEN END      ' ESC to quit
        LOOP UNTIL k$ <> ""
        
        ' Reset game
        playerX% = 5                       ' Reset X position
        playerY% = 12                      ' Reset Y position
        score& = 0
        gameSpeed! = 50
        
        ' Clear all obstacles
        FOR i% = 1 TO MAX_OBSTACLES%
            obsActive%(i%) = 0
        NEXT i%
        
        CLS
        LOCATE 1, 1: PRINT STRING$(80, "=");
        LOCATE 25, 1: PRINT STRING$(80, "=");
    END IF
    
    ' Update score and increase difficulty
    score& = score& + 1
    IF score& MOD 100 = 0 AND gameSpeed! > 10 THEN
        gameSpeed! = gameSpeed! - 1        ' Speed up game slightly
    END IF
    
    ' Pause to control game speed
    _DELAY 1 / gameSpeed!
    
LOOP

' Clean up and exit
COLOR 7, 0
CLS
LOCATE 12, 30: PRINT "Thanks for playing!"
END