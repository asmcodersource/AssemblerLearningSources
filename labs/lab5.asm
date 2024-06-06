.MODEL small
.STACK 4096
.DATA           
   Newline db 13,'$'       
   RequestNumber db 10,13,'Input integer number in decimal format: $'   
   RequestOperation db 'Chose operation to perform:'
                    db 10,13,'1) Cyclic shift all bytes to the left by 2 bits',
                    db 10,13,'2) Set all bits of the least significant byte to 1',
                    db 10,13,'3) Invert 3,4,7,15 bits$'     
   YourNumber       db 10,13,'      Your number: $'
   CalculatedNumber db 10,13,'Calculated number: $'
   BinaryPresentation db ',',09,' binary presentation of number:$'    
   error_ db "incorrect number$"
   TryAgain db 10,13,'Try again [Y/N]?$'

   buff    db 6,7 Dup(?)    
   X dw ?                 
   Y dw ?
.CODE    

main PROC
    mov    ax,@Data
    mov    ds,ax

    .start:
    mov dx, offset RequestNumber 
    call write_string        
    call read_number
    mov [X], ax

    mov dx, offset RequestOperation
    call write_string  
    .repeat_input:
        mov ah,00h
        int 16h
        cmp al,'1'
        jz .operation_1
        cmp al,'2'  
        jz .operation_2
        cmp al,'3'  
        jz .operation_3 
        jmp .repeat_input   
   .operation_1:  
   mov ax, [X]  
   rol ax, 2
   jmp .operation_executed
   .operation_2:  
   mov ax, [X]
   or al, 0FFh 
   jmp .operation_executed
   .operation_3:
   mov ax, [X]         
   xor ax, 001100100000001b 
   .operation_executed:  
   mov [Y], ax
   mov dx, offset YourNumber
   call write_string
   mov ax, [X]
   call write_number
   mov dx, offset BinaryPresentation
   call write_string  
   push [X]  
   call write_binary
   add sp, 2
     
   mov dx, offset YourNumber
   call write_string
   mov ax, [Y]
   call write_number
   mov dx, offset BinaryPresentation
   call write_string   
   push [Y]      
   call write_binary 
   add sp, 2
   
   .input_cycle:
       mov dx, offset TryAgain
       mov ah,09h
       int 21h
       mov ah, 0
       int 16h
       cmp al, 'Y'
       jz .start
       cmp al, 'y'
       jz .start
       cmp al, 'N'
       jz exit
       cmp al, 'n'
       jz exit
       jmp .input_cycle
   exit:
   mov ah,04ch
   int 21h                 
main ENDP


write_number PROC
   test       ax, ax
   jns        oi1
   mov      cx, ax
   mov     ah, 02h
   mov     dl, '-'
   int        21h
   mov      ax, cx
   neg       ax
oi1: 
    xor     cx, cx
    mov     bx, 10 
oi2:
    xor     dx,dx
    div       bx
    push    dx
    inc       cx
    test      ax, ax
    jnz       oi2
    mov     ah, 02h
oi3:
    pop     dx
    add     dl, '0'
    int        21h
    loop    oi3
    ret
write_number ENDP

read_number PROC                  
    mov     cx,0
    mov     ah,0ah
    xor      di,di
    mov     dx,offset buff                           
    int       21h                                        
    mov     dl,0ah
    mov     ah,02
    int       21h                                       
    mov     si,offset buff+2                        
    cmp     byte ptr [si],"-"                        
    jnz       ii1
    mov     di,1                                         
    inc      si                                             
ii1:
    xor      ax,ax
    mov     bx,10                                       
ii2:
    mov     cl,[si]                                   
    cmp     cl,0dh
    jz         endin
    cmp     cl,'0'                                       
    jl         er
    cmp     cl,'9'                                        
    ja        er
    sub      cl,'0'                                        
    mul     bx                                            
    add     ax,cx                                      
    inc      si                                            
    jmp     ii2                                           
er:
    mov     dx, offset error_
    mov     ah,09
    int       21h
    int       20h
endin:
    cmp     di,1                                        
    jnz     ii3
    neg     ax                                            
ii3:      
    push ax
    mov dx, offset Newline 
    mov ah,09
    int 21h
    pop ax
    ret
read_number ENDP     

write_string PROC 
    mov bp, sp
    mov ah,09h
    int 21h
    ret
write_string ENDP

write_binary PROC  
    mov bp, sp
    push bx  
    push cx 
    mov cx, 16
    mov bx, [bp+2]
    .cycle:
        mov dl,'1'  
        shl bx, 1
        jc .one
            mov dl,'0'
        .one:
        mov ah,2
        int 21h
        loop .cycle 
    pop cx
    pop dx 
    ret
write_binary ENDP 

END main
