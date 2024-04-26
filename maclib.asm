;MACROS
;prints char to console CHAR - actual value
PRINT_CHAR MACRO CHAR
    PUSH AX
    PUSH DX

    MOV AH, 02H
    MOV DL, CHAR
    INT 21H

    POP DX
    POP AX
ENDM

;prints new line to console
NEW_LINE MACRO 
    PUSH AX
    PUSH DX

    MOV AH, 02H
    MOV DL, 0AH 
    INT 21H

    MOV AH, 02H
    MOV DL, 0DH
    INT 21H

    POP DX
    POP AX
ENDM

;prints char to file - pointer to char
PRINT_CHAR_TO_FILE MACRO CHAR
    PUSH CHAR
    CALL WRITE_TO_FILE
ENDM

;prints new line to file
NEW_LINE_TO_FILE MACRO 
    PUSH OFFSET VAR0A
    CALL WRITE_TO_FILE
ENDM

;prints message to console; MSG - message variable
PRINT_MSG MACRO MSG
    PUSH DX
    PUSH AX

    MOV AH, 09H
    LEA DX, MSG
    INT 21H

    POP AX
    POP DX
ENDM