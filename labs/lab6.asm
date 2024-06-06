.MODEL small
.STACK 4096
.DATA           
   newline db 13,'$'   
   new_line db 10,13,'$'
   error   db "incorrect number$"     
   inputX1 db 10,13,10,13,'Input X1: $'      
   inputB db  'Input  B: $'
   inputC db  'Input  C: $'
   inputN db  'Input  N: $'   
   TryAgain db 10,13,'Try again [Y/N]?$'
   dots   db  ':$'           
   comma  db  ', $'
   X      dw  ' X$'  
   Y      dw  ' Y$'   
   F      dw  ' F:$'
   buff    db 6,7 Dup(?)   
   X1      dw ?
   B       dw ?
   C       dw ?
   N       dw ?  
   array_X dw 255 Dup(?)
   array_Y dw 255 Dup(?)  
   Fvalue       dw ?
.CODE            


main PROC
    mov    ax,@Data
    mov    ds,ax
    .start:
    mov dx, offset inputX1
    call write_string        
    call read_number 
    mov [array_X], ax 
    mov dx, offset inputB
    call write_string        
    call read_number   
    mov [B], ax    
    mov dx, offset inputC
    call write_string        
    call read_number   
    mov [C], ax 
    mov dx, offset inputN
    call write_string        
    call read_number 
    mov [N], ax 
    
    
    call calculate_x_array   
    call calculate_y_array
    call calculate_f 
    
    mov cx, [N]
    mov bx, 0000h
    .draw_array_X:    
        push cx    
        mov dx, offset X
        call write_string  
        mov ax, [N]
        sub ax, cx
        inc ax
        call write_number
        mov dx, offset dots
        call write_string
        mov ax, [array_X+bx]  
        call write_number  
        mov dx, offset comma
        call write_string
        add bx, 0002h
        pop cx
        loop .draw_array_X
           
    mov dx, offset new_line
    call write_string
        
    mov cx, [N]
    mov bx, 0000h
    .draw_array_Y:    
        push cx    
        mov dx, offset Y
        call write_string  
        mov ax, [N]
        sub ax, cx
        inc ax
        call write_number
        mov dx, offset dots
        call write_string
        mov ax, [array_Y+bx]  
        call write_number  
        mov dx, offset comma
        call write_string
        add bx, 0002h
        pop cx
        loop .draw_array_Y   
        
    mov dx, offset new_line
    call write_string
    mov dx, offset F
    call write_string
    mov ax, [Fvalue]
    call write_number   
    
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


calculate_x_array PROC   
    mov bx, 0000h     
    mov cx, [N]
    dec cx
    mov ax, [array_X+0000h]
    .inner_cycle_0:
        add ax, 0004h
        add bx, 0002h
        mov [array_X+BX], ax
        loop .inner_cycle_0
    ret
calculate_x_array ENDP  


calculate_y_array PROC
    mov ax, [B]   ;;   
    cwd           ;;
    mov bx, 06h   ;;
    imul bx       ;;
    mov dx, ax    ;; DX = 6*B 
    mov bx, 0000h  
    mov cx, [N]
    .inner_cycle_1:
        mov ax, [array_X+BX]  
        sub ax, dx
        push dx
        mov dx, [C]
        imul dx
        pop dx  
        mov [array_Y+BX], ax    
        add bx, 0002h
        loop .inner_cycle_1
    ret
calculate_y_array ENDP 


calculate_f PROC
    mov cx, [N]
    mov ax, 0000h          
    mov bx, 0000h
    .inner_cycle_2:        
        add ax, [array_Y+BX]
        add bx, 0002h
        loop .inner_cycle_2   
    mov [Fvalue], ax
    ret
calculate_f ENDP


write_number PROC 
   push bx
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
    pop bx
    ret
write_number ENDP

read_number PROC    
    push bx              
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
    mov     dx, offset error
    mov     ah,09
    int       21h
    int       20h
endin:
    cmp     di,1                                        
    jnz     ii3
    neg     ax                                            
ii3:    
    push ax
    mov dx, offset newline 
    mov ah,09
    int 21h
    pop ax 
    pop bx
    ret
read_number ENDP     

write_string PROC   
    push bx
    mov bp, sp
    mov ah,09h
    int 21h
    pop bx
    ret
write_string ENDP
END main
