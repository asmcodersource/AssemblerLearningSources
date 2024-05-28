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

use32
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
mov esi,message  ; offset of message           ;-
mov bl,00001111b ; attrib                      ;-
call put_line    ; Function of display lines   ;-
;;---------------------------------------------;- 
jmp $ 

;;------- Function of display lines.-----------;- 
put_line:                                      ;-
xor ecx,ecx                                    ;-
xor eax,eax                                    ;-
mov cl,dh                                      ;-
mov al,160                                     ;-
mul cl                                         ;-
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

message db 'Hello World',0


   
