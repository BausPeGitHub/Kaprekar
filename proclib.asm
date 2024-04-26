INCLUDE maclib.asm

VECTOR_OP SEGMENT PARA PUBLIC 'CODE'
    ASSUME CS: VECTOR_OP
    PUBLIC SORT_VEC_DEC, SORT_VEC_INC, SORT_NUMBER, COPY_VEC, SUBSTRACT, COMPARE_VEC
    SORT_VEC_DEC PROC FAR
        ;sort decreasing vector of length 4 received from stack by address
        MOV BP, SP
        MOV SI, [BP + 4];address of vector
        MOV BL, 4
        MOV CX, 3
        ;INTERCHANGE SORT
        FOR1:
            PUSH CX
            XOR CH, CH
            DEC BL
            MOV CL, BL 
            MOV DI, SI
            INC DI
            MOV AL, BYTE PTR [SI]
            FOR2:
                CMP AL, BYTE PTR[DI]
                JNB SORTED
                    ;SWAP
                    MOV AH, BYTE PTR [DI]
                    MOV BYTE PTR[DI], AL
                    MOV BYTE PTR[SI], AH
                    MOV AL, BYTE PTR [SI]
                SORTED:
                INC DI
            LOOP FOR2
            POP CX
            INC SI
        LOOP FOR1
        RET 2
    SORT_VEC_DEC ENDP
    SORT_VEC_INC PROC FAR
        ;sort increasing vector of length 4 received from stack
        MOV BP, SP
        MOV SI, [BP + 4];address of vector
        MOV BL, 4
        MOV CX, 3
        ;INTERCHANGE SORT
        FOR3:
            PUSH CX
            XOR CH, CH
            DEC BL
            MOV CL, BL 
            MOV DI, SI
            INC DI
            MOV AL, BYTE PTR [SI]
            FOR4:
                CMP AL, BYTE PTR[DI]
                JNA SORTED2
                    ;SWAP
                    MOV AH, BYTE PTR [DI]
                    MOV BYTE PTR[DI], AL
                    MOV BYTE PTR[SI], AH
                    MOV AL, BYTE PTR [SI]
                SORTED2:
                INC DI
            LOOP FOR4
            POP CX
            INC SI
        LOOP FOR3
        RET 2
    SORT_VEC_INC ENDP
    SORT_NUMBER PROC FAR
        ;receives address of vector representing number to be sorted and direction of sorting
        MOV BP, SP
        MOV DI, [BP + 4];address of vector of digits
        MOV DX, [BP + 6];DIR
        MOV BX, DI
        ;sort vector of digits
        PUSH DI
        CMP DX, 0001H
        JZ DESC
            CALL SORT_VEC_INC
            JMP DONE
        DESC:
            CALL SORT_VEC_DEC  
        DONE:
        RET 4
    SORT_NUMBER ENDP
    COPY_VEC PROC FAR
        ;copies source vector into destination vector
        MOV BP, SP
        MOV DI, [BP + 4];DESTINATION
        MOV SI, [BP + 6];SOURCE
        MOV CX, 4
        FOR5:
            MOV AL, BYTE PTR [SI]
            MOV BYTE PTR [DI], AL
            INC DI
            INC SI
        LOOP FOR5
        RET 4
    COPY_VEC ENDP
    SUBSTRACT PROC FAR
        ;[BP + 8] = [BP + 4] - [BP + 6]
        MOV BP, SP
        MOV SI, [BP + 4]
        MOV DI, [BP + 6]
        MOV DX, [BP + 8]
        ADD SI, 3
        ADD DI, 3
        MOV CX, 4
        MOV BL, 0;HERE WE WILL KEEP THE BORROW
        DIGIT:
            MOV AL, [SI]
            CMP AL, BL
            JAE FALSE01;SEE IF AL = 0, BL = 1
                MOV AL, 9
                JMP BORROW2;YES01
            FALSE01:
                SUB AL, BL
                CMP AL, [DI]
                JB BORROW
                    SUB AL, [DI]
                    MOV [SI], AL
                    MOV BL, 0;NO BORROW
                    JMP NEXT
                BORROW:
                    ADD AL, 0Ah
                    SUB AL, [DI]
                    MOV [SI], AL
                    MOV BL, 1;YES BORROW
                    JMP NEXT
                BORROW2:
                    SUB AL, [DI]
                    MOV [SI], AL
                    MOV BL, 1;YES BORROW
                NEXT:
                    DEC SI
                    DEC DI
        LOOP DIGIT

        ;MOVE RESULT IN VEC
        PUSH [BP + 4]
        PUSH [BP + 8]
        CALL COPY_VEC
        RET 6
    SUBSTRACT ENDP
    COMPARE_VEC PROC FAR
        ;BOOL = 1 IF THE 2 VECTORS ARE EQUAL
        ;[BP + 4] - address of vector to be compared
        ;[BP + 6] - adress of K2/K
        ;[BP + 8] - address of BOOL
        MOV BP, SP
        MOV SI, [BP + 4]
        MOV DI, [BP + 6]
        MOV CX, 4
        ANOTHER_FOR:
            MOV AL, BYTE PTR [SI]
            CMP AL, [DI]
            JNZ BOOL0
            INC SI
            INC DI
        LOOP ANOTHER_FOR
        ;put 1 into BOOL
        MOV DI, [BP + 8]
        MOV BYTE PTR [DI], 1
        JMP GOOUT
        BOOL0:
            ;put 0 into BOOL
            MOV DI, [BP + 8]
            MOV BYTE PTR [DI] , 0
        GOOUT:
        RET 6
    COMPARE_VEC ENDP
VECTOR_OP ENDS

END