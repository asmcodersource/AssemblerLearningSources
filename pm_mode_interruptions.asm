#fasm#         
#make_boot#

org 7c00h     
use16   


;;---------------Clear display--------------------
mov ax,3                                        ;-
int 10h                                         ;-
;;----------------------------------------------;-

;;---------------Turn on A20.--------------------
in al,92h                                      ;-
or al,2                                        ;-
out 92h,al                                     ;-
;----------------------------------------------;-


;;---------------Get address of protected_mode_entry_point ------------;-
xor eax,eax                                                            ;-
mov ax,cs                                                              ;-
shl eax,4                                                              ;-
add eax,protected_mode_entry_point                                     ;-
mov [entry_off],eax                                                    ;-
;----------------------------------------------------------------------;-

;;---------------Get address of GDT ------------;-
xor eax,eax                                     ;-
mov ax,cs                                       ;-
shl eax,4                                       ;-
add ax,GDT                                      ;-
;;----------------------------------------------;-

;;---------------Load GDT to GDTR --------------;-
mov dword [GDTR+2],eax                          ;-
lgdt fword [GDTR]                               ;-
;;----------------------------------------------;-

;;---------------Turn off interruptions.--------;-
cli                                             ;-
in al,70h                                       ;-
or al,80h                                       ;-
out 70h,al                                      ;-
;;----------------------------------------------;-
           
;; ------- Set on protected mode. (x32)----;-
mov eax,cr0                                ;-
or eax,1                                   ;-
mov cr0,eax                                ;-
;------------------------------------------;-

;; binary far jump for set CS selector.----;-
db 66h         ;; Code of command far jump ;-
db 0EAh        ;;                          ;-
entry_off dd 0 ;; Offset                   ;-
dw 00001000b   ;; Selector                 ;-
;;-----------------------------------------;- 

align 8   
;;------------------ Descriptor table. ----------------------;-
GDT:                                                         ;-
NULL_descr  db 8 dup(0)                                      ;-
CODE_descr  db 0FFh,0FFh,00h,00h,00h,10011010b,11001111b,00h ;-
DATA_descr  db 0FFh,0FFh,00h,00h,00h,10010010b,11001111b,00h ;-
VIDEO_descr db 0FFh,0FFh,00h,80h,0Bh,10010010b,01000000b,00h ;-
;;-----------------------------------------------------------;-     
GDT_size equ $-GDT                                           

GDTR:
dw GDT_size-1
dd ?  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
use32  

;;------------------- Empy IRQ Handler.---------------------------------;-
nopint:                                                                 ;-
push ax                                                                 ;-
mov al,20h                                                              ;-
out 20h,al                                                              ;-
out 0A0h,al                                                             ;-
pop ax                                                                  ;-
iretd                                                                   ;-
;;----------------------------------------------------------------------;-

;;------------------- IRQ 0 Handler.--------------------------------------
irq0:                                                                   ;-
push eax                                                                ;-
push ebx                                                                ;-
push ecx                                                                ;-
push edx                                                                ;-
;inc [timer]                                                            ;-
;cmp [timer],18                                                         ;-
;jnz exit_irq0                                                          ;-
timer0:                                                                 ;-
;mov [timer],0                                                          ;-
mov al,[es:180+44+8]                                                    ;-
inc al                                                                  ;-
mov byte [es:180+44+8],al                                               ;-
cmp  al,':'                                                             ;-
jnz exit_irq0                                                           ;-
mov byte [es:180+44+8],'0'                                              ;-
mov al,[es:180+44+6]                                                    ;-
inc al                                                                  ;-
mov byte [es:180+44+6],al                                               ;-
cmp  al,':'                                                             ;-
jnz exit_irq0                                                           ;-
mov byte [es:180+44+6],'0'                                              ;-
mov al,[es:180+44+4]                                                    ;-
inc al                                                                  ;-
mov byte [es:180+44+4],al                                               ;-
cmp  al,':'                                                             ;-
jnz exit_irq0                                                           ;-
mov byte [es:180+44+4],'0'                                              ;-
mov al,[es:180+44+2]                                                    ;-
inc al                                                                  ;-
mov byte [es:180+44+2],al                                               ;-
cmp  al,':'                                                             ;-
jnz exit_irq0                                                           ;-
mov byte [es:180+44+2],'0'                                              ;-
mov al,[es:180+44+0]                                                    ;-
inc al                                                                  ;-
mov byte [es:180+44+0],al                                               ;-
cmp  al,':'                                                             ;-
jnz exit_irq0                                                           ;-
mov byte [es:180+44+0],'0'                                              ;-
jmp timer0                                                              ;-
                                                                        ;-
                                                                        ;-
jmp timer0                                                              ;-
exit_irq0:                                                              ;-
mov al,20h                                                              ;-
out 20h,al                                                              ;-
out 0A0h,al                                                             ;-
pop edx                                                                 ;-
pop ecx                                                                 ;-
pop ebx                                                                 ;-
pop eax                                                                 ;-
iretd                                                                   ;-
;;----------------------------------------------------------------------;-

timer db 0 

;;------- Function of display lines.-----------;- 
put_line:                                      ;-
xor ecx,ecx                                    ;-
xor eax,eax                                    ;-
mov cl,dh                                      ;-
mov al,160                                     ;-
mul cl                                         ;-
mov cx,ax                                      ;-
mov al,dl                                      ;-
add al,al                                      ;-
add cx,ax                                      ;-
put_line0:                                     ;-
mov al,[esi]                                   ;-
test al,al                                     ;-
jz e                                           ;-
mov [es:ecx],al                                ;-
mov [es:ecx+1],bl                              ;-
add ecx,02h                                    ;-
inc esi                                        ;-
jmp put_line0                                  ;-
;;---------------------------------------------;- 
e:
ret

protected_mode_entry_point:  
;;--------- Set on selectors.----------;-
mov ax,00010000b                       ;-
mov bx,ds                              ;-
mov dx,ax                              ;-
mov ax,00011000b                       ;-
mov es,ax                              ;-
;--------------------------------------;-

;;--------- Create PDE.----------;-
mov eax,3000h                    ;-
or  eax,3                        ;-
mov [2000h],eax                  ;-
;;-------------------------------;-
                                              
;;------------ Create PTE.---------------------;-
mov eax,7000h   ;;                             ;-
or  eax,3       ;;                             ;-
mov [301Ch],eax ;; For page with code          ;-
mov eax,8000                                   ;-
or  eax,3                                      ;-
mov [3020h],eax                                ;-
mov eax,0B8000h ;-                             ;-
or  eax,3       ;-                             ;-
mov [32E0h],eax ;- For page of buffer display  ;-  
;;---------------------------------------------;- 

;;-----------------Set on CR3------------------;-
mov eax,2000h                                  ;-
mov cr3,eax                                    ;-
;----------------------------------------------;-

;----------------- Turn on paging.-------------;-
mov eax,cr0                                    ;-
or eax,80000000h                               ;-
mov cr0,eax                                    ;-
;;---------------------------------------------;- 


;;----------------- Display Message.-----------;- 
mov dl,00  ; col                               ;-
mov dh,00  ; row                               ;-
mov esi,messag0  ; offset of message           ;-
mov bl,00001111b ; attrib                      ;-
call put_line    ; Function of display lines   ;-
;;---------------------------------------------;-

;;------------- Initialize timer.--------------;-
mov byte [es:180+44+0],'0'                     ;-
mov byte [es:180+44+2],'0'                     ;-
mov byte [es:180+44+4],'0'                     ;-
mov byte [es:180+44+6],'0'                     ;-
mov byte [es:180+44+8],'0'                     ;-
mov byte [es:180+44+1],00001111b               ;-
mov byte [es:180+44+3],00001111b               ;-
mov byte [es:180+44+5],00001111b               ;-
mov byte [es:180+44+7],00001111b               ;-
mov byte [es:180+44+9],00001111b               ;-
;;---------------------------------------------;-


;;------------- Initialize PIC.----------------;-
mov al,00010001b                               ;-
out 20h,al                                     ;-
mov al,20h                                     ;-
out 21h,al                                     ;-
mov al,00000100b                               ;-
out 21h,al                                     ;-
mov al,00000001b                               ;-
out 21h,al                                     ;-
                                               ;-
mov al,00010001b                               ;-
out 0A0h,al                                    ;-
mov al,28h                                     ;-
out 0A1h,al                                    ;-
mov al,00000100b                               ;-
out 0A1h,al                                    ;-
mov al,00000001b                               ;-
out 0A1h,al                                    ;-
;;---------------------------------------------;-

;;---- Load interrupt description table.-------;-
mov eax,IDT                                    ;-
mov [IDTR+2],eax                               ;-
lidt fword [IDTR]                              ;-
sti                                            ;-
;;---------------------------------------------;-

;;----------------- Display Message.-----------;- 
mov dl,00  ; col                               ;-
mov dh,01  ; row                               ;-
mov esi,messag1  ; offset of message           ;-
mov bl,00001111b ; attrib                      ;-
call put_line    ; Function of display lines   ;-
;;---------------------------------------------;-
jmp $
                    

messag0 db 'CPU in protected mode.',0 
messag1 db 'Interrupt timer IQR0 :',0  


;;---- Interrupt description table.---------;-
align 8                                     ;-
IDT:                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0 ; 10                                   ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0 ;20                                    ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dq 0                                        ;-
dw 7C81h,00001000b,8E00h,0000h              ;-
dw 7C76h,00001000b,8E00h,0000h              ;-
dw 7C76h,00001000b,8E00h,0000h              ;-
dw 7C76h,00001000b,8E00h,0000h              ;-
dw 7C76h,00001000b,8E00h,0000h              ;-
dw 7C76h,00001000b,8E00h,0000h              ;-
dw 7C76h,00001000b,8E00h,0000h              ;-
dw 7C76h,00001000b,8E00h,0000h              ;-
dw 7C76h,00001000b,8E00h,0000h              ;-
dw 7C76h,00001000b,8E00h,0000h              ;-
dw 7C76h,00001000b,8E00h,0000h              ;-
dw 7C76h,00001000b,8E00h,0000h              ;-
dw 7C76h,00001000b,8E00h,0000h              ;-
dw 7C76h,00001000b,8E00h,0000h              ;-
dw 7C76h,00001000b,8E00h,0000h              ;-
dw 7C76h,00001000b,8E00h,0000h              ;-
IDT_size equ $-IDT                          ;-
;;------------------------------------------;-


IDTR:
dw IDT_size-1
dd ?






   
