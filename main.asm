IF 1
    INCLUDE maclib.asm
ENDIF


DATA SEGMENT PARA PUBLIC 'DATA'
    ;define your data here
    NEW_INPUT_MSG       DB          "CONTINUE? [Y/N]: $"
    NEW_INPUT_MSG_ERROR DB          "INCORRECT INPUT -> CONTINUE? [Y/N]: $"
    FIRST_MSG           DB          "ENTER 0 FOR AUTOMATIC MODE OR 1 FOR INTERACTION MODE: $"
    FIRST_ERR_MSG       DB          "INCORRECT INPUT -> ENTER 0 OR 1: $"
    SECOND_MSG          DB          "ENTER 4 DIGIT NUMBER: $"
    SECOND_ERR_MSG      DB          "INCORRECT INPUT -> ENTER 4 DIGIT NUMBER: $"
    MSG_ITER            DB          "NUMBER OF ITERATIONS: $"
    FILE_ERR            DB          "ERROR: COULD NOT CREATE FILE!"
    FILE_ERR2           DB          "ERROR: COULD NOT OPEN FILE!"
    FILE_ERR3           DB          "ERROR: COULD NOT PRINT TO FILE!"
    FILE_NAME           DB          "data.out"
    FILE_HANDLER        DW          ?
    READ_BUF            DB          101, ?, 101 DUP(?)
    VEC                 DB          4 DUP(0)
    COPY                DB          4 DUP(0)
    VEC_INC             DB          4 DUP(0)
    VEC_DEC             DB          4 DUP(0)
    K                   DB          6, 1, 7, 4
    K2                  DB          0, 0, 0, 0
    BOOL                DB          0
    MODE                DB          ?
    ITERATIONS          DB          0
    TIP                 DB          0
    VAR0A               DB          0AH
    VAR0D               DB          0DH
    CHAR_TO_PRINT       DB          0
    EXIT                DB          0
DATA ENDS

READ_WRITE SEGMENT PARA PUBLIC 'CODE'
    ASSUME CS: READ_WRITE, DS: DATA
     READ_MODE PROC FAR
        MOV BP, SP
        MOV SI, [BP + 4];MODE
        ;reads mode AUTOMATIC = 0, INTERACTIVE = 1;
        MOV AH, 01H
        INT 21H
        MOV BYTE PTR [SI], AL
        RET 2
    READ_MODE ENDP
    READ_NUMBER PROC FAR
        ;reads number for interactive mode
        MOV BP, SP
        RECURSION:
        MOV DI, [BP + 4];ADDRESS OF VEC
        MOV AH, 0AH
        LEA DX, READ_BUF
        INT 21H

        MOV AL, READ_BUF[1]

        ;VERIFY IF INPUT HAS EXACTLY 4 DIGITS
        CMP AL, 4
        JNE TRY_AGAIN_HERE
        JMP GOAHEAD
        TRY_AGAIN_HERE:
            NEW_LINE
            PRINT_MSG SECOND_ERR_MSG
            JMP RECURSION
        GOAHEAD:
            ;VERIFY IF EACH DIGIT IS CORRECT
            MOV CX, 4
            MOV SI, 2
            FOR_LOOP:
                MOV AL, READ_BUF[SI]
                CMP AL, '0'
                JNB CONTINUE
                JMP TRY_AGAIN_HERE
                CONTINUE:
                CMP AL, '9'
                JNA CONTINUE2
                JMP TRY_AGAIN_HERE
                CONTINUE2:
                SUB AL, '0'
                MOV [DI], AL
                INC DI
                INC SI
            LOOP FOR_LOOP
        RET 2
    READ_NUMBER ENDP
    CREATE_FILE PROC FAR
        MOV AH, 3CH
        LEA DX, FILE_NAME
        MOV CL, 1
        INT 21H
        JC IF_ERROR
        MOV FILE_HANDLER, AX
        JMP TO_RET
        IF_ERROR:
            PRINT_MSG FILE_ERR
        TO_RET:
        RET
    CREATE_FILE ENDP
    OPEN_FILE PROC FAR
        MOV AH, 3DH
        MOV AL, 1
        LEA DX, FILE_NAME
        INT 21H
        JC IF_ERROR2
        MOV FILE_HANDLER, AX
        JMP TO_RET2
        IF_ERROR2:
            PRINT_MSG FILE_ERR2
        TO_RET2:
        RET
    OPEN_FILE ENDP
    WRITE_TO_FILE PROC FAR
        MOV BP, SP
        MOV AH, 40H
        MOV BX, FILE_HANDLER
        MOV DX, [BP + 4]
        MOV CX, 1
        INT 21H
        JC IF_ERROR3
        JMP TO_RET3
        IF_ERROR3:
            PRINT_MSG FILE_ERR3
        TO_RET3:
        RET 2
    WRITE_TO_FILE ENDP
    READ_CONTINUE PROC FAR
        BEGIN:
        MOV AH, 01H
        INT 21H
        CMP AL, 'Y'
        JNE EXIT1
        MOV EXIT, 0
        JMP STOP
        EXIT1:
            CMP AL, 'N'
            JNE REPEAT
            JMP EXIT0
            REPEAT:
                NEW_LINE
                PRINT_MSG NEW_INPUT_MSG_ERROR
                JMP BEGIN
            EXIT0:
                MOV EXIT, 1
        STOP:
        RET
    READ_CONTINUE ENDP
    PRINT_VEC PROC FAR
        ;prints vec to console
        MOV BP, SP
        PUSH SI
        MOV SI, [BP + 4];address of VEC
        PUSH CX
        MOV CX, 4
        FOR6:
            MOV AL, [SI]
            ADD AL, '0'
            MOV AH, 02H
            MOV DL, AL
            INT 21H
            INC SI
        LOOP FOR6
        POP CX
        POP SI
        RET 2
    PRINT_VEC ENDP
    PRINT_VEC_TO_FILE PROC FAR
        ;prints vec to file
        MOV BP, SP
        PUSH SI
        MOV SI, [BP + 4];address of VEC
        PUSH CX
        MOV CX, 4
        FFOR:
            MOV AL, [SI]
            ADD AL, '0'
            PUSH SI
            PUSH CX
            MOV CHAR_TO_PRINT, AL
            PUSH OFFSET CHAR_TO_PRINT
            CALL WRITE_TO_FILE
            POP CX
            POP SI
            INC SI
        LOOP FFOR
        POP CX
        POP SI
        RET 2
    PRINT_VEC_TO_FILE ENDP
READ_WRITE ENDS

;code segment
CODE SEGMENT PARA PUBLIC 'CODE'
    ASSUME CS:CODE, DS:DATA
    EXTRN SORT_VEC_DEC:FAR, SORT_VEC_INC:FAR, SORT_NUMBER:FAR, COPY_VEC:FAR, SUBSTRACT:FAR, COMPARE_VEC:FAR
    KAPREKAR PROC NEAR
        MOV AL, 0
        MOV ITERATIONS, AL
        KAPREKAR_ROUTINE:
            ;PRINT THE CURRENT NUMBER
            MOV DL, TIP
            CMP DL, 1
            JNZ NO_PRINT
                PUSH OFFSET VEC
                CALL PRINT_VEC
                NEW_LINE
            NO_PRINT:
            PUSH OFFSET BOOL
            PUSH OFFSET K
            PUSH OFFSET VEC
            CALL COMPARE_VEC
            CMP BOOL, 1 
            JNZ NOT_FINISH_1;IF WE REACH KAPREKAR'S CONSTANT 6174 WE STOP
            RET 
            NOT_FINISH_1:
            PUSH OFFSET BOOL
            PUSH OFFSET K2
            PUSH OFFSET VEC
            CALL COMPARE_VEC
            CMP BOOL, 1 
            JNZ NOT_FINISH;IF WE REACH KAPREKAR'S CONSTANT 0000 WE STOP
            RET 
            NOT_FINISH:
            MOV AX, 0
            PUSH AX ;DIR: DIR = 0 => SORT INC, DIR = 1 => SORT DESC
            PUSH OFFSET VEC
            CALL SORT_NUMBER
            PUSH OFFSET VEC
            PUSH OFFSET VEC_INC
            CALL COPY_VEC

            MOV AX, 1
            PUSH AX ;DIR: DIR = 0 => SORT INC, DIR = 1 => SORT DESC
            PUSH OFFSET VEC
            CALL SORT_NUMBER
            PUSH OFFSET VEC
            PUSH OFFSET VEC_DEC
            CALL COPY_VEC

            ;NOW WE HAVE SORTED NUMBERS IN VEC_DEC AND VEC_INC
            ;WE WILL SUBSTRACT THEM AND STORE THE RESULT IN VEC
            PUSH OFFSET VEC
            PUSH OFFSET VEC_INC
            PUSH OFFSET VEC_DEC
            CALL SUBSTRACT
            INC ITERATIONS
        JMP KAPREKAR_ROUTINE
        RET 
    KAPREKAR ENDP
    
    MAIN PROC FAR
        ;instructions to allow return to OS
        PUSH DS
        XOR AX, AX
        PUSH AX

        ;initialize DS with start of data segment
        MOV AX, DATA
        MOV DS, AX

        ;main code goes here

        NEW_INPUT:
        ;READ
        NEW_LINE
        PRINT_MSG FIRST_MSG
        PUSH OFFSET MODE;SET MODE
        CALL READ_MODE;ENTER MODE
        JMP FIRST
        ;IF INPUT NOT 0 OR 1 TRY AGAIN

        TRY_AGAIN:
            NEW_LINE
            PRINT_MSG FIRST_ERR_MSG
            PUSH OFFSET MODE
            CALL READ_MODE

        FIRST:
        CMP MODE, '0'
        JB TRY_AGAIN
        JNE NOT0
        JMP AUTOMATIC
        NOT0:
        CMP MODE, '1'
        JA TRY_AGAIN
        NEW_LINE

        ;ENTER NUMBER FOR INTERACTIVE MODE
        PRINT_MSG SECOND_MSG
        PUSH OFFSET VEC
        CALL READ_NUMBER
        NEW_LINE

        ;CALL KAPREKAR WITH TYPE = 1(interactive)
        MOV DL, 1
        MOV TIP, DL
        CALL KAPREKAR
        JMP FINISH


        AUTOMATIC:
            NEW_LINE

            CALL CREATE_FILE
            ;CALL OPEN_FILE
            
            ;CREATE ALL POSSIBLE VEC
            MOV CX, 10
            MOV DL, 0
            MOV TIP, DL
            FIRST_DIGIT:
                MOV AX, 10
                SUB AX, CX
                MOV VEC[0], AL
                PUSH CX
                MOV CX, 10
                SECOND_DIGIT:
                    MOV AX, 10
                    SUB AX, CX
                    MOV VEC[1], AL
                    PUSH CX
                    MOV CX, 10
                    THIRD_DIGIT:
                        MOV AX, 10
                        SUB AX, CX
                        MOV VEC[2], AL
                        PUSH CX
                        MOV CX, 10
                        FOURTH_DIGIT:
                            MOV AX, 10
                            SUB AX, CX
                            PUSH CX
                            MOV VEC[3], AL

                            ;COPY VEC
                            PUSH OFFSET VEC;SOURCE
                            PUSH OFFSET COPY;DESTINATION
                            CALL COPY_VEC

                            ;CALL ROUTINE FOR CURRENT VEC
                            CALL KAPREKAR

                            ;RESTORE VEC
                            PUSH OFFSET COPY;SOURCE
                            PUSH OFFSET VEC;DESTINATION
                            CALL COPY_VEC
                            

                            ;PRINT TO CONSOLE

                            ;PUSH OFFSET VEC
                            ;CALL PRINT_VEC
                            ;PRINT_CHAR ':'
                            ;PRINT_CHAR ' '
                            ;MOV DL, ITERATIONS
                            ;ADD DL, '0'
                            ;PRINT_CHAR DL
                            ;NEW_LINE
                            
                            ;PRINT TO FILE
                            PUSH OFFSET VEC
                            CALL PRINT_VEC_TO_FILE
                            MOV AL, ':'
                            MOV CHAR_TO_PRINT, AL
                            LEA DX, CHAR_TO_PRINT
                            PRINT_CHAR_TO_FILE DX
                            MOV AL, ' '
                            MOV CHAR_TO_PRINT, AL
                            LEA DX, CHAR_TO_PRINT
                            PRINT_CHAR_TO_FILE DX
                            MOV DL, ITERATIONS
                            ADD DL, '0'
                            MOV CHAR_TO_PRINT, DL
                            LEA DX, CHAR_TO_PRINT
                            PRINT_CHAR_TO_FILE DX
                            NEW_LINE_TO_FILE

                            POP CX
                        DEC CX
                        CMP CX, 0
                        JE CONTINUE_FOURTH_DIGIT
                        JMP FOURTH_DIGIT
                        CONTINUE_FOURTH_DIGIT:
                        POP CX
                    DEC CX
                    CMP CX, 0
                    JE CONTINUE_THIRD_DIGIT
                    JMP THIRD_DIGIT
                    CONTINUE_THIRD_DIGIT:
                    POP CX
                DEC CX
                CMP CX, 0
                JE CONTINUE_SECOND_DIGIT
                JMP SECOND_DIGIT
                CONTINUE_SECOND_DIGIT:
                POP CX
            DEC CX
            CMP CX, 0
            JE CONTINUE_FIRST_DIGIT
            JMP FIRST_DIGIT
            CONTINUE_FIRST_DIGIT:
            JMP REALLY_FINISH
        FINISH:
            ;PRINT ITERATIONS
            PRINT_MSG MSG_ITER
            MOV DL, ITERATIONS
            ADD DL, '0'
            PRINT_CHAR DL
        REALLY_FINISH:
            NEW_LINE
            PRINT_MSG NEW_INPUT_MSG
            CALL READ_CONTINUE
            CMP EXIT, 0
            JNE END_MAIN
            JMP NEW_INPUT
            END_MAIN:
        RET;return control to OS
    MAIN ENDP
CODE ENDS

END MAIN

