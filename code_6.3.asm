
#make_bin#
#LOAD_SEGMENT=0500h#    ; setting loading address, .bin file will be loaded to this address:
#LOAD_OFFSET=0000h#
sec equ 1010h 		;Stores the seconds value
min equ 1032h		;Stores the minutes value
power equ 1012h 		;Stores the number of power presses
start equ 1013h 		;Stores the number of start button presses
timeset equ 1034h 	;Stores 0 or 1. 1 if time is set. 0 if not
inprogress equ 1035h ;1 if cooking in progress. 0 if not
stop equ 1014h		;Stores the number of stop button presses
disp equ 1015h 		;Next 4 bytes will be stored for 4-digit BCD count
display_table equ 1019h 	;Display table for displaying digits on the 7-segement display
inp equ 1029h			;Stores the input from the port - to check which button is
;time_loop equ 1030h 



#0000=0500h#         ; setting entry point

#DS=1000h#           ; set segment registers
#ES=1000h# 

#SS=1000h#           ; setting stack
#SP=FFFEh#    

#AX=0000h#           ; clearing general registers   
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#


db 1024 dup(0) ;Initially reserving first 1K of memory for IVT


;Storing IP and CS values for different interrupts in the Interrupt Vector Table 

mov ax, 0
mov es, ax  
mov al, 30h          ; set general registers
mov bl, 4h           ; multiply 30h by 4, store result in ax:
mul bl
mov bx, ax
mov si, offset [A10MIN]      ; copy offset into interrupt vector:
mov es:[bx], si
add bx, 2
mov ax, 0000         ; copy segment into interrupt vector:
mov es:[bx], ax


mov ax, 0
mov es, ax
mov al, 31h          ; calculate vector address for interrupt 31h:
mov bl, 4h           ; multiply 31h by 4, store result in ax:
mul bl
mov bx, ax 
mov si, offset [A1MIN]   ; copy offset into interrupt vector:
mov es:[bx], si
add bx, 2
mov ax, 0000           ; copy segment into interrupt vector:
mov es:[bx], ax


mov ax, 0
mov es, ax
mov al, 32h        ; calculate vector address for interrupt 32h:
mov bl, 4h         ; multiply 32h by 4, store result in ax:
mul bl
mov bx, ax
mov si, offset [A10SEC]    ; copy offset into interrupt vector:
mov es:[bx], si
add bx, 2
mov ax, 0000         ; copy segment into interrupt vector:
mov es:[bx], ax


mov ax, 0
mov es, ax
mov al, 33h          ; calculate vector address for interrupt 33h:
mov bl, 4h           ; multiply 33h by 4, store result in ax:
mul bl
mov bx, ax
mov si, offset [POW]    ; copy offset into interrupt vector:
mov es:[bx], si
add bx, 2
mov ax, 0000        ; copy segment into interrupt vector:
mov es:[bx], ax


mov ax, 0
mov es, ax
mov al, 34h       ; calculate vector address for interrupt 34h:
mov bl, 4h        ; multiply 34h by 4, store result in ax:
mul bl 
mov bx, ax
mov si, offset [STRT]    ; copy offset into interrupt vector:
mov es:[bx], si
add bx, 2
mov ax, 0000        ; copy segment into interrupt vector:
mov es:[bx], ax


mov ax, 0
mov es, ax
mov al, 35h      ; calculate vector address for interrupt 35h:
mov bl, 4h       ; multiply 35h by 4, store result in ax:
mul bl
mov bx, ax
mov si, offset [STP]     ; copy offset into interrupt vector:
mov es:[bx], si
add bx, 2
mov ax, 0000      ; copy segment into interrupt vector:
mov es:[bx], ax


mov ax, 0
mov es, ax
mov al, 36h       ; calculate vector address for interrupt 36h:
mov bl, 4h        ; multiply 36h by 4, store result in ax:
mul bl 
mov bx, ax
mov si, offset [TIMER]    ; copy offset into interrupt vector:
mov es:[bx], si
add bx, 2
mov ax, 0000      ; copy segment into interrupt vector:
mov es:[bx], ax


mov ax,10000000b	;All ports are output ports
mov dx,5006h
out dx,al            
mov ax,00001010b	;Buzzer Indicator OFF
out dx,al
mov ax,00001100b	;Power input can be taken
out dx,al
mov ax,00001001b	;Countdown can't be started
out dx,al

;PC0 - PC3 set 1 -- which means all the 4 seven segement displays are disabled
mov ax,00000001b
out dx,al
mov ax,00000011b	 
out dx,al
mov ax,00000101b
out dx,al
mov ax,00000111b
out dx,al


;Initializing 8255(2)
mov ax,10000010b  ;Port B is taken as input 
mov dx,6006h
out dx,al

;Initializing the values at the following addresses:


mov word ptr [sec],0 ;Total no. of seconds loaded initially
mov word ptr [min],0 ;Total no. of minutes loaded iniially
mov byte ptr [power],-1 ;No. of times Power is pressed
mov byte ptr [start],0 ;No. of times start is pressed
mov byte ptr [stop],00 ;No. of times stop is pressed
mov byte ptr [timeset],0
mov byte ptr [inprogress],0

mov ax,00110110b 	 ;TIMER2 COUNTER 0 Control Word
mov dx,3006h
out dx,al            

mov ax,20h			 ;Loading count into TIMER2 COUNTER 0 
mov dx,3000h
out dx,al            
mov ax,4eh
mov dx,3000h
out dx,al

mov ax,01010110b    		 ;TIMER2 COUNTER 1 Control Word
mov dx,3006h
out dx,al

mov ax,100			 ;Loading count into TIMER2 COUNTER 1
mov dx,3002h
out dx,al   


mov ax,00110110b		 ;TIMER1 COUNTER 0 Control Word
mov dx,2006h
out dx,al            

mov ax,20h			 ;Loading count into TIMER1 COUNTER 0 
mov dx,2000h
out dx,al            
mov ax,4Eh
mov dx,2000h
out dx,al


mov ax,01110110b		;TIMER1 COUNTER 1 Control Word
mov dx,2006h
out dx,al

mov ax,	0E8h		;Loading count into TIMER1 COUNTER 1
mov dx,2002h
out dx,al
mov ax,03h
mov dx,2002h
out dx,al  


        
mov ax,10010010b		;TIMER1 COUNTER 2 Control Word
mov dx,2006h
out dx,al

;Count will be loaded to TIMER1 COUNTER 2 Later


lp: call poll
jmp lp


A10MIN: 

mov byte ptr [timeset],1
mov ax,10 			;Increment the time by 10 minutes
mov si,min
add [si],ax

mov al,[si]
cmp al,60
jl k1
mov [si],59
mov [sec],59

k1:
call display
iret


A1MIN:

mov byte ptr [timeset],1
mov ax,1 			;Increment the time by 1 minute
mov si,min
add [si],ax

mov al,[si]
cmp al,60
jl d1
mov [si],59
mov [sec],59

d1: 
call display
iret


A10SEC: 

mov byte ptr [timeset],1
mov ax,10 			;Increment the time by 10 seconds 
mov si,sec
add [si],ax

mov al,[si]
cmp al,60
jl g1

mov [si],00
add [min],1
mov al,[min]
cmp al,60
jl g1

mov [min],59
mov [sec],59

g1:
call display
iret



POW:

cmp byte ptr [timeset],1
je h1				; If time has been set, power cannot be modified
cmp byte ptr [inprogress],1
je h1				; If cooking is in process, then also power cannot be modified
mov si,power		;Setting up the power
mov al,[si]
add al,1
cmp al,05 			;If 5 presses are there, then the power is again set back to 100%
jne x2
mov al,00
x2: mov [si],al

call display_power
h1: nop
iret



STRT:

mov si,power
mov al,[si]
mov byte ptr [inprogress],1
xor ah,ah

cmp byte ptr [timeset],0
je f1		; If start is pressed without setting the time, then it should work at default power(100)
mov bl, 2
mul bl		;multiplying start with power
mov cl,10
sub cl,al

f1:
cmp byte ptr [timeset],1
je f2
add [sec], 30 			;Incrementing counter by 30 seconds if Start is pressed and time is not set.
mov al,[sec]
cmp al,60
jl f2
sub al,60
mov [sec],al
add [min],1

f2:
mov si,stop 			;Number of stops pressed is made equal to zero
mov al,0
mov byte ptr [si],al


mov ax,00001000b 	;Input fron Timer enabled
mov dx,5006h
out dx,al
mov dx,2004h		;Count loaded into Timer1 Counter 2
mov ax,cx
out dx,al

mov ax,00001101b 	;Power input can't be taken once start is pressed
mov dx,5006h
out dx,al
mov ax,00001111b 	;Set up Lock
out dx,al
call display
iret


STP:

mov byte ptr [inprogress],0
mov ax,00001001b 		;Input from Timer blocked
mov dx,5006h
out dx,al
mov ax,00001100b 		;Power input can be taken
out dx,al
mov ax,00001010b 		;Buzzer LED Offss
out dx,al
mov si,stop
inc byte ptr [si]
mov al,[si]
cmp al,2 			;If Stop is Pressed twice, then only execute all these steps
jl x1
mov word ptr [sec],0
mov word ptr [min],0
mov byte ptr [stop],0
mov byte ptr [start],0		; start variable is made equal to 0
mov byte ptr [timeset],0
x1: mov dx,5006h
mov ax,00001110b		;Opening the lock
out dx,al
call display
iret



TIMER:

mov ax,[sec]
cmp ax,0
jg r1
mov ax,[min]
cmp ax,0
jg r1
mov ax,00001011b 	;If countdown is over, buzzer is on
mov dx,5006h
out dx,al
mov ax,00001001b 	;No further countdown
out dx,al
mov ax,00001100b 	;Power input enabled
out dx,al
mov ax,00001110b 	;Lock opened
out dx,al
jmp r2
r1: 

dec word ptr [sec]
mov ax,[sec]
cmp ax,-1
jg r2
dec word ptr [min]
mov word ptr [sec],59

r2:
call display
iret


proc poll near
mov dx,6002h
in al,dx


;Checking which of the inputs is 1 which means the corresponding switch is pressed

;The mapping to switches is:
; PB0 - 10 MIN BUTTON
; PB1 - 1 MIN BUTTON
; PB2 - 10 SEC BUTTON
; PB3 - POWER BUTTON
; PB4 - START BUTTON
; PB5 - STOP BUTTON
; PB6 - TIMER INTERRUPT HANDLING


;Checking which input is receiving interrupt

mov [inp],al
cmp al,0ffh 
je pl7


mov al,[inp]
and al,01h
jnz pl1
int 30h
call delayss

pl1: mov al,[inp]
and al,02h
jnz pl2
int 31h
call delayss

pl2:mov al,[inp]
and al,04h
jnz pl3
int 32h
call delayss

pl3:mov al,[inp]
and al,08h
jnz pl4
int 33h
call delayss

pl4:mov al,[inp]
and al,10h
jnz pl5
int 34h
call delayss

pl5:mov al,[inp]
and al,20h
jnz pl6
int 35h
call delayss

pl6:mov al,[inp]
and al,40h
jnz pl7
int 36h
call delay1s

pl7: ret
endp

;POLLING ENDS

proc display near
mov si,disp
mov di,sec
mov ax, [di] 		;Current number of seconds is stored in AX now

mov bx,10

xor dx,dx
div bx
mov [si],dl 		;Remainder is in DL as remainder is not greater than 9, so no need to consider
					;DH - Hence we extract the last digit

xor dx,dx   		;Digit at Tens place
div bx
mov [si+1],dl

mov di,min
mov ax, [di] 		;Current number of minutes is stored in AX now

xor dx,dx
div bx
mov [si+2],dl 		

xor dx,dx   		;Digit at Tens place
div bx
mov [si+3],dl

;Diplay digit at thousands place
mov al, 00001110b
mov dx,6004h
out dx,al

mov al,[si+3]
mov dx,6000h
out dx,al

;Display digit at hundreds place
mov al, 00001101b
mov dx,6004h
out dx,al

mov al,[si+2]
mov dx,6000h
out dx,al

;Display second last digit
mov al, 00001011b
mov dx,6004h
out dx,al

mov al,[si+1]
mov dx,6000h
out dx,al

;Display Last Digit
mov al, 00000111b
mov dx,6004h
out dx,al

mov al,[si]
mov dx,6000h
out dx,al

mov al, 00001111b 	;disabling all the latches
mov dx,6004h
out dx,al
ret
endp


proc display_power near
mov si,disp
mov di,power
mov al,[di]

	;Loading Power value according to the number of power presses
	cmp al,00
	jnz j1
	mov ax,100
	jmp j0
	
j1: cmp al,01
	jnz j2
	mov ax,80
	jmp j0
	

j2: cmp al,02
	jnz j3
	mov ax,60
	jmp j0
	
j3: cmp al,03
	jnz j4
	mov ax,40
	jmp j0
	
j4: cmp al,04
	jnz j0
	mov ax,20
	
j0: nop

mov bx,10

xor dx,dx
div bx
mov [si],dl ;Remainder is in DL as remainder is not greater than 9, so no need to consider DH - Hence we extract the last digit

xor dx,dx  	 ;Digit at Tens place
div bx
mov [si+1],dl

xor dx,dx	 ;Digit at hundredth place
div bx
mov [si+2],dl

xor dx,dx 	;Digit at Thousandth place
div bx
mov [si+3],dl

;Diplay digit at thousands place
mov al, 00001110b
mov dx,6004h
out dx,al

mov al,[si+3]
mov dx,6000h
out dx,al

;Display digit at hundreds place
mov al, 00001101b
mov dx,6004h
out dx,al

mov al,[si+2]
mov dx,6000h
out dx,al

;Display second last digit
mov al, 00001011b
mov dx,6004h
out dx,al

mov al,[si+1]
mov dx,6000h
out dx,al

;Display Last Digit
mov al, 00000111b
mov dx,6004h
out dx,al

mov al,[si]
mov dx,6000h
out dx,al

mov al, 00001111b 	;disabling all the latches
mov dx,6004h
out dx,al

ret
endp


;DELAY PROCEDURES

delay proc near
mov cx, 2000
l5:    dec cx
loop l5
ret
endp

delayss proc near
mov cx, 60000
l6:    dec cx
loop l6
ret
endp

delay1s proc near
mov ax, 4
delay2:
dec ax
call delayss
cmp ax,0
jnz delay2
ret
endp