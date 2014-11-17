;Karine Josien
;CS 4380 project 3

;data
SIZE	.INT	7
data	.INT	0
opdv	.INT	0
cnt		.INT	0
flag	.INT	0
tenth	.INT	0
c		.BYT	0
		.BYT	0
		.BYT	0
		.BYT	0
		.BYT	0
		.BYT	0
		.BYT	0
size1	.INT	15
str1	.BYT	'N'
		.BYT	'u'
		.BYT	'm'
		.BYT	'b'
		.BYT	'e'
		.BYT	'r'
		.BYT	32
		.BYT	't'
		.BYT	'o'
		.BYT	'o'
		.BYT	32
		.BYT	'b'
		.BYT	'i'
		.BYT	'g'
LINE	.BYT	10
AT		.BYT	'@'
PLUS	.BYT	'+'
MINUS	.BYT	'-'
size2	.INT	11	
str2	.BYT	'O'
		.BYT	'p'
		.BYT	'e'
		.BYT	'r'
		.BYT	'a'
		.BYT	'n'
		.BYT	'd'
		.BYT	32
		.BYT	'i'
		.BYT	's'
		.BYT	32
ZERO	.BYT	'0'
ONE		.BYT	'1'
TWO		.BYT	'2'
THREE	.BYT	'3'
FOUR	.BYT	'4'
FIVE	.BYT	'5'
SIX		.BYT	'6'
SEVEN	.BYT	'7'
EIGHT	.BYT	'8'
NINE	.BYT	'9'
size3	.INT	17
str3	.BYT	32
		.BYT	'i'
		.BYT	's'
		.BYT	32
		.BYT	'n'
		.BYT	'o'
		.BYT	't'
		.BYT	32
		.BYT	'a'
		.BYT	32
		.BYT	'n'
		.BYT	'u'
		.BYT	'm'
		.BYT	'b'
		.BYT	'e'
		.BYT	'r'
		.BYT	10
		
		;code  
		; note SB and SL are loaded in the VM
		MOV SP, SB  	;set stack pointer at the bottom  should this be in VM
		SUB FP, FP		;set frame pointer FP to null in VM?
		
	;reset (1,0,0,0) 
		;use R6 to calculate needed space
			SUB R6, R6
			ADI R6, 8	;space for return address and PFP
			ADI R6, 16  ;reset (1,0,0,0)  4 parameters => space 16 bytes
			;test for overflow
			MOV R5, SP 
			SUB R5, R6	;will be position of SP if no overflow
			CMP R5, SL	;compare SP with stack limit R1 >0 if SP>SL <0 if SP<SL
			BLT R5, OVERFLOW ; branch if overflow occurs
			;create activation record
			MOV R5, FP	;save FP will be PFP
			MOV FP, SP	; set frame pointer to current stack top, bottom of current activation record
			ADI SP, -4	;set stack pointer on top of return address
			STR R5, SP	;store value of R5 (PFP) to address pointed to by SP
			ADI SP, -4	; move SP to top
			;passed parameters
			SUB R5, R5
			ADI R5, 1
			STR	R5, SP
			ADI SP, -4	;adjust top 
			SUB R5, R5
			STR R5, SP ;place 0 on stack
			ADI SP, -4
			STR R5, SP ; place 0 on stack
			ADI SP, -4	
			STR R5, SP	; place 0 on stack
			ADI SP, -4	
			;return address
			MOV R4, PC	;PC points to next instruction
			ADI R4, 36 	;compute return address
			STR R4, FP	;store return address at the beginning of frame pointed to be FP
		JMP RESET	;call function reset
	;getdata() 
		;use R6 to calculate needed space
			SUB R6, R6
			ADI R6, 8	;space for return address and PFP
			;test for overflow
			MOV R5, SP 
			SUB R5, R6	;will be position of SP if no overflow
			CMP R5, SL	;compare SP with stack limit R1 >0 if SP>SL <0 if SP<SL
			BLT R5, OVERFLOW ; branch if overflow occurs
			;create activation record
			MOV R5, FP	;save FP will be PFP
			MOV FP, SP	;set frame pointer to current stack top, bottom of current activation record
			ADI SP, -4	;set stack pointer on top of return address
			STR R5, SP	;store value of R5 (PFP) to address pointed to by SP
			ADI SP, -4	; move SP to top
			; no passed parameters
			;return address
			MOV R4, PC	;PC points to next instruction
			ADI R4, 36 	;compute return address
			STR R4, FP	;store return address at the beginning of frame pointed to be FP
		JMP GETDATA	;call function getdata()
		;while (c[0] != '@') 
		WHILE3	LDA R0, c 	;load address of c
				LDB R1,R0 	;load c[0] in R1
				LDB R2, AT
				CMP R2,R1
				BRZ R2, ENDWHILE3  ;exit loop when c[0]='@'
				LDB R2, PLUS ; if(c[0]==+ || =='-'
				CMP R2,R1   ;compare c[0] and '+'
				BNZ R2 COMPARE1
					ADI R2,1  ; set R2 to 1 if R2=R1
					JMP ENDCOMPARE1
				COMPARE1  SUB R2, R2   ; set R2 to 0 if R2 !=R1
				ENDCOMPARE1 LDB R3, MINUS
				CMP R3,R1	;compare c[0] and '-'
				BNZ R3 COMPARE2
					ADI R3,1  ; set R2 to 1 if R2=R1
					JMP ENDCOMPARE2
				COMPARE2  SUB R3, R3 
				ENDCOMPARE2 OR R2, R3  
				SUB R3,R3  ;set R3=0
				CMP R3,R2  ; 0 if false
				BRZ R3, ELSE2
					;call getdata()
						SUB R6, R6
						ADI R6, 8	;space for return address and PFP
						;test for overflow
						MOV R5, SP 
						SUB R5, R6	;will be position of SP if no overflow
						CMP R5, SL	;compare SP with stack limit R1 >0 if SP>SL <0 if SP<SL
						BLT R5, OVERFLOW ; branch if overflow occurs
						;create activation record
						MOV R5, FP	;save FP will be PFP
						MOV FP, SP	;set frame pointer to current stack top, bottom of current activation record
						ADI SP, -4	;set stack pointer on top of return address
						STR R5, SP	;store value of R5 (PFP) to address pointed to by SP
						ADI SP, -4	; move SP to top
						; no passed parameters
						;return address
						MOV R4, PC	;PC points to next instruction
						ADI R4, 36 	;compute return address
						STR R4, FP	;store return address at the beginning of frame pointed to be FP
					JMP GETDATA	;call function getdata()
					JMP WHILE4
				ELSE2	LDA R0, c  
						ADI R0, 1	;increment position in array of c to 1
						STB R1, R0	; store R1 which contain c[0] in c[1]
						ADI R0, -1  ; set R0 back to c[0]
						LDB R1, PLUS
						STB R1, R0
						LDR R2, cnt
						ADI R2, 1
						STR R2, cnt
						

				WHILE4	SUB R0,R0       ;start loop while(data)  endif2
						LDR R1,data
						CMP R1,R0
						BRZ R1, ENDWHILE4  ; exit loop if flag is 0
						LDA R2, c
						LDR R3, cnt
						ADI R3, -1  ;contains cnt-1
						ADD R2, R3
						LDB R4,R2  ; containts c[cnt-1]
						LDB R5, LINE
						CMP R5, R4
						BNZ R5 ELSE3
							SUB R0, R0
							STR R0, data	;data=0
							ADI R0, 1
							STR R0, tenth
							LDR R3, cnt
							ADI R3, -2
							STR R3, cnt
							; start while (!flag && cnt != 0) 
							WHILE5 	SUB R0,R0
									LDR R1, flag
									CMP R1,R0
									BNZ R1,SWITCH ;(!flag if flag=0 R1=1 else R1=0)
										ADI R1,1
										JMP ENDSWITCH
										SWITCH  SUB R1,R1
									ENDSWITCH LDR R2, cnt
									CMP R2,R0
									AND R1,R2
									CMP R1,R0
									BRZ R1, ENDWHILE5
									;call opd with 3 parameters
									;setup activation record
											SUB R6, R6
											ADI R6, 8	;space for return address and PFP
											ADI R6, 16  ;opd (c[0],tenth, c[cnt])  3 parameters => space 16 bytes
											;test for overflow
											MOV R5, SP 
											SUB R5, R6	;will be position of SP if no overflow
											CMP R5, SL	;compare SP with stack limit R1 >0 if SP>SL <0 if SP<SL
											BLT R5, OVERFLOW ; branch if overflow occurs
											;create activation record
											MOV R5, FP	;save FP will be PFP
											MOV FP, SP	;set frame pointer to current stack top, bottom of current activation record
											ADI SP, -4	;set stack pointer on top of return address
											STR R5, SP	;store value of R5 (PFP) to address pointed to by SP
											ADI SP, -4	; move SP to top
											;passed parameters
											LDA R5,c
											LDR R5,R5 ;load c[0] in R5
											STR	R5, SP
											ADI SP, -4	;adjust top 
											LDR R5, tenth ;load tenth in R5
											STR R5, SP ;place 0 on stack
											ADI SP, -4
											LDA R5,c
											LDR R6,cnt
											ADD R5,R6
											LDR R5,R5 ;load c[cnt] in R5
											STR R5, SP ; place 0 on stack
											ADI SP, -4	
											;return address
											MOV R4, PC	;PC points to next instruction
											ADI R4, 36 	;compute return address
											STR R4, FP	;store return address at the beginning of frame pointed to be FP
										JMP OPD
										LDR R0,cnt
										ADI R0, -1
										STR R0, cnt
										LDR R0, tenth
										SUB R1,R1
										ADI R1, 10
										MUL R0, R1
										STR R0, tenth
									JMP WHILE5
									ENDWHILE5 SUB R0,R0   ; if(!flag)
									
									LDR R1, flag
									CMP R1, R0
									
									BNZ R1, ENDIF3
										LDA R2,str2
										LOOP2	LDR R1, size2  ;print "Operand is "
												CMP R1, R0
												BRZ R1, ENDLOOP2  
												LDB R7, R2
												TRP 3
												ADI R0,1
												ADI R2,1
										JMP LOOP2
										ENDLOOP2 LDR R7, opdv
										TRP 1
										LDB R7, LINE
										TRP 3
									JMP ENDIF3
							ELSE3	SUB R6, R6
											ADI R6, 8	;space for return address and PFP
											;test for overflow
											MOV R5, SP 
											SUB R5, R6	;will be position of SP if no overflow
											CMP R5, SL	;compare SP with stack limit R1 >0 if SP>SL <0 if SP<SL
											BLT R5, OVERFLOW ; branch if overflow occurs
											;create activation record
											MOV R5, FP	;save FP will be PFP
											MOV FP, SP	;set frame pointer to current stack top, bottom of current activation record
											ADI SP, -4	;set stack pointer on top of return address
											STR R5, SP	;store value of R5 (PFP) to address pointed to by SP
											ADI SP, -4	; move SP to top
											; no passed parameters
											;return address
											MOV R4, PC	;PC points to next instruction
											ADI R4, 36 	;compute return address
											STR R4, FP	;store return address at the beginning of frame pointed to be FP
										JMP GETDATA	;call function getdata()
				ENDIF3	JMP WHILE4 
				ENDWHILE4   SUB R6, R6  ;call reset(1,0,0,0)
						ADI R6, 8	;space for return address and PFP
						ADI R6, 16  ;reset (1,0,0,0)  4 parameters => space 16 bytes
						;test for overflow
						MOV R5, SP 
						SUB R5, R6	;will be position of SP if no overflow
						CMP R5, SL	;compare SP with stack limit R1 >0 if SP>SL <0 if SP<SL
						BLT R5, OVERFLOW ; branch if overflow occurs
						;create activation record
						MOV R5, FP	;save FP will be PFP
						MOV FP, SP	;set frame pointer to current stack top, bottom of current activation record
						ADI SP, -4	;set stack pointer on top of return address
						STR R5, SP	;store value of R5 (PFP) to address pointed to by SP
						ADI SP, -4	; move SP to top
						;passed parameters
						SUB R5, R5
						ADI R5, 1
						STR	R5, SP
						ADI SP, -4	;adjust top 
						SUB R5, R5
						STR R5, SP ;place 0 on stack
						ADI SP, -4
						STR R5, SP ; place 0 on stack
						ADI SP, -4	
						STR R5, SP	; place 0 on stack
						ADI SP, -4	
						;return address
						MOV R4, PC	;PC points to next instruction
						ADI R4, 36 	;compute return address
						STR R4, FP	;store return address at the beginning of frame pointed to be FP
					JMP RESET	;call function reset
						SUB R6, R6
						ADI R6, 8	;space for return address and PFP
						;test for overflow
						MOV R5, SP 
						SUB R5, R6	;will be position of SP if no overflow
						CMP R5, SL	;compare SP with stack limit R1 >0 if SP>SL <0 if SP<SL
						BLT R5, OVERFLOW ; branch if overflow occurs
						;create activation record
						MOV R5, FP	;save FP will be PFP
						MOV FP, SP	;set frame pointer to current stack top, bottom of current activation record
						ADI SP, -4	;set stack pointer on top of return address
						STR R5, SP	;store value of R5 (PFP) to address pointed to by SP
						ADI SP, -4	; move SP to top
						; no passed parameters
						;return address
						MOV R4, PC	;PC points to next instruction
						ADI R4, 36 	;compute return address
						STR R4, FP	;store return address at the beginning of frame pointed to be FP
					JMP GETDATA	;call function getdata()
			JMP WHILE3
	ENDWHILE3	TRP 0
TRP 0

;reset() function		
RESET 	MOV R5, SP ;allocate space for local variables -> 1 int
		ADI R5, -4 
		CMP R5, SL	;compare SP with stack limit R1 >0 if SP>SL <0 if SP<SL
		BLT R5, OVERFLOW ; branch if overflow occurs
		ADI SP, -4 ;adjust stack pointer
		
		;execute function reset
		SUB R1,R1	; set at 0 to use for k
		MOV R2,FP
		ADI R2, -24
		STR	R1, R2	; store 0 for k on the stack at position FP-24
		LDA R3, c 	;load adress of array c in R3
		SUB R4, R4 ; set R4 to 0 to use to set array to 0
WHILE1		LDR R0, SIZE 
			CMP R0, R1	;compare R1 and R0
			BRZ R1, ENDWHILE1  ; if k==SIZE exit while loop
			;start content of loop
			STR R3, R4 ; store 0 in the array
			ADI R1, 1	; increment the array
			ADI R3, 4	; increment position in the array
		JMP WHILE1 
ENDWHILE1 MOV R2, FP
		ADI R2, -8 ; access to stack content for data
		LDR R1, R2
		STR R1, data
		ADI R2, -4 ; access to stack content for opdv
		LDR R1, R2
		STR R1, opdv
		ADI R2, -4 ; access to stack content for cnt
		LDR R1, R2
		STR R1, cnt
		ADI R2, -4 ; access to stack content for flag
		LDR R1, R2
		STR R1, flag
;return 
	;test for underflow
		MOV SP, FP ; deallocate current activation record
		MOV R1, SP
		CMP R1, SB
		BGT R1, UNDERFLOW
	;set previous frame to current frame
		LDR R5, FP  ;get return address in R5
		MOV R1, FP
		ADI R1, -4 ; point to PFP
		LDR FP, R1 ; load PFP into FP
	;return
		JMR R5
		
;getdata()  no local variable to load 		
GETDATA 	LDR R0, cnt
			LDR R1, SIZE
			CMP R0, R1 ;>0 if R1>R0 or cnt<SIZE
			BRZ R0, ELSE1
			TRP 4
				LDA R2, c ;load addres of c into R2
				LDR R3, cnt
				ADD R2, R3
				STB R7,R2  ;store in address from R2 the content of R7 (used to read TRP 4)
				ADI R3,1	;increment cnt	
				STR R3, cnt
			JMP ENDIF1
			ELSE1 SUB R0,R0
				LDA R2, str1
				LOOP1	LDR R1, size1  ;print "number too big"
					CMP R1,R0
					BRZ R1, ENDLOOP1  
					LDB R7,R2
					TRP 3
					ADI R0,1
					ADI R2,1
				JMP LOOP1
				
					;start activation stack for flush()
					;use R6 to calculate needed space
				ENDLOOP1 SUB R6, R6
					;set activation record for flush
					ADI R6, 8	;space for return address and PFP
					ADI R6, 0  ;  0 parameters 
					;test for overflow
					MOV R5, SP 
					SUB R5, R6	;will be position of SP if no overflow
					CMP R5, SL	;compare SP with stack limit R1 >0 if SP>SL <0 if SP<SL
					BLT R5, OVERFLOW ; branch if overflow occurs
					;create activation record
					MOV R5, FP	;save FP will be PFP
					MOV FP, SP	;set frame pointer to current stack top, bottom of current activation record
					ADI SP, -4	;set stack pointer on top of return address
					STR R5, SP	;store value of R5 (PFP) to address pointed to by SP
					ADI SP, -4	; move SP to top
					;passed parameters NONE
					;return address
					MOV R4, PC	;PC points to next instruction
					ADI R4, 36 	;compute return address
					STR R4, FP	;store return address at the beginning of frame pointed to be FP
				JMP FLUSH	;call function reset

;return 
	;test for underflow
ENDIF1	MOV SP, FP ; deallocate current activation record
		MOV R1, SP
		CMP R1, SB
		BGT R1, UNDERFLOW
	;set previous frame to current frame
		LDR R5, FP  ;get return address in R5
		MOV R1, FP
		ADI R1, -4 ; point to PFP
		LDR FP, R1 ; load PFP into FP
	;return
		JMR R5
		
;flush() function	
FLUSH 	SUB R0,R0  ;no parameters to load
		STR R0, data  ;data=0
		TRP 4
		STB R7,c
		WHILE2	LDB R1, c
				LDB R0, LINE
				CMP R0,R1
				BRZ R0, ENDWHILE2
				TRP 4
				STR R7, c
		JMP WHILE2
		ENDWHILE2 MOV SP, FP ; return, deallocate current activation record
			MOV R1, SP
			CMP R1, SB
			BGT R1, UNDERFLOW
		;set previous frame to current frame
			LDR R5, FP  ;get return address in R5
			MOV R1, FP
			ADI R1, -4 ; point to PFP
			LDR FP, R1 ; load PFP into FP
		;return
		JMR R5
		
	;OPD(char s, int k, char j) c[0], tenth, c[cnt]
	; s -> FP-8, k-> FP - 12, j -> FP-16
OPD 	MOV R5, SP ;allocate space for local variables -> 1 int
		ADI R5, -4 
		CMP R5, SL	;compare SP with stack limit R1 >0 if SP>SL <0 if SP<SL
		BLT R5, OVERFLOW ; branch if overflow occurs
		ADI SP, -4 ;adjust stack pointer
		SUB R1,R1	; set at 0 to use for t
		MOV R3,FP
		ADI R3, -20
		STR	R1, R2	; store 0 for t on the stack at position FP-20

		MOV R0,FP  
		ADI R0,-16
		LDB R1,R0  ;R1=j
		SUB R4,R4 
		LDB R2,ZERO ;if (j=='0')
			CMP R2,R1
			BNZ R2, ELSE11
				STR R4,R3  ;R3 contains address of t
				JMP ENDIFOPD
			ELSE11 LDB R2,ONE
				CMP R2,R1
				BNZ R2, ELSE12
					ADI R4,1
					STR R4,R3 ;t=1 @R3
					JMP ENDIFOPD
				ELSE12 LDB R2,TWO
					CMP R2,R1
					BNZ R2,  ELSE13
						ADI R4,2
						STR R4,R3 ;t=2 @R3
						JMP ENDIFOPD
					ELSE13 LDB R2,THREE
						CMP R2,R1
						BNZ R2, ELSE14
							ADI R4,3
							STR R4,R3 ;t=3 @R3
							JMP ENDIFOPD
						ELSE14 LDB R2,FOUR
							CMP R2,R1
							BNZ R2, ELSE15
								ADI R4,4
								STR R4,R3 ;t=4 @R3
								JMP ENDIFOPD
							ELSE15 LDB R2,FIVE
								CMP R2,R1
								BNZ R2, ELSE16
									ADI R4,5
									STR R4,R3 ;t=5 @R3
									JMP ENDIFOPD
								ELSE16 LDB R2,SIX
									CMP R2,R1
									BNZ R2, ELSE17
										ADI R4,6
										STR R4,R3 ;t=6 @R3
										JMP ENDIFOPD
									ELSE17 LDB R2,SEVEN
										CMP R2,R1
										BNZ R2, ELSE18
											ADI R4,7
											STR R4,R3 ;t=7 @R3
											JMP ENDIFOPD	
										ELSE18 LDB R2,EIGHT
											CMP R2,R1
											BNZ R2, ELSE19
												ADI R4,8
												STR R4,R3 ;t=8 @R3
												JMP ENDIFOPD
											ELSE19 LDB R2,NINE
												CMP R2,R1
												BNZ R2, ENDELSE
													ADI R4,9
													STR R4,R3 ;t=9 @R3
													JMP ENDIFOPD
												ENDELSE MOV R7,R1
													TRP 3
													SUB R0,R0
													LDA R2, str3
												PRINTLOOP	LDR R1, size3  ;print "is not a number"
														CMP R1,R0
														BRZ R1, ENDPRINT  ;
														LDB R7,R2
														TRP 3
														ADI R0,1
														ADI R2,1
												JMP PRINTLOOP
												ENDPRINT SUB R0,R0
												ADI R0,1
												STR R0, flag				
		ENDIFOPD LDR R0, flag   ; if (!flag)
			SUB R1,R1
			CMP R1,R0
			BNZ R1, ENDOPD
				MOV R0, FP
				ADI R0, -8
				LDB R1, RO  ;R1=s = c[0]
				LDB	R2, PLUS
				CMP R1,R2
				BNZ R1 ELSEFLAG
					MOV R0,FP  ; t*=k
					ADI R0, -20		
					LDR R1, R0		;load R1=t
					MOV R2, FP 
					ADI R2, -12
					LDR R3, R2	; load R3=k
					MUL R1, R3
					STR R1, R0  ; store t at FP-20
					JMP ENDOPD
				ELSEFLAG MOV R0,FP  ; t*=k
					ADI R0, -20		
					LDR R1, R0		;load R1=t
					MOV R2, FP 
					ADI R2, -12
					LDR R3, R2	; load R3=k
					SUB R4, R4
					ADI R4, -1
					MUL R3, R4  ; R3=-k  
					MUL R1, R3
					STR R1, R0  ; store t at FP-20
ENDOPD			LDR R0, opdv     ;opdv += t   R0=opdv
				MOV R1, FP
				ADI R1, -20		
				LDR R2, R1    ;R2=t
				ADD R0, R2
				STR R0, opdv
;setup return
;return 
	;test for underflow
		MOV SP, FP ; deallocate current activation record
		MOV R1, SP
		CMP R1, SB
		BGT R1, UNDERFLOW
	;set previous frame to current frame
		LDR R5, FP  ;get return address in R5
		MOV R1, FP
		ADI R1, -4 ; point to PFP
		LDR FP, R1 ; load PFP into FP
	;return
		JMR R5
		
OVERFLOW TRP 0
UNDERFLOW	TRP 0










