.MODEL small
.STACK 4096
.DATA           
   newline db 13,'$'   
   new_line db 10,13,'$'
   error   db "incorrect number$"     
   inputN db 10,13,10,13,'Input count of elements: $'  
   calculatedValue db 10,13,'Calculated value is: $'       
   arrayMsg db 10,13,'Array is:',10,13,'$' 
   N dw 0
   TryAgain db 10,13,'Try again [Y/N]?$'        
   sum dw 0
   array dw 512 Dup(?)  
   open db '[$'
   close db '] = $'
   separator   db  ' $'           
   buff    db 6,7 Dup(?)   
.CODE            


main PROC
    mov    ax,@Data
    mov    ds,ax
    .start:
    mov dx, offset inputN
    call write_string        
    call read_number 
    mov [N], ax       
    
    ;; input array         
    mov bx, 0000h
    mov cx, ax
    array_input_cycle:
        push cx
        mov dx, offset open
        call write_string  
        mov ax, bx
        sar ax, 1
        call write_number
        mov dx, offset close
        call write_string   
        call read_number
        mov array [bx], ax
        pop cx   
        add bx, 2
        loop array_input_cycle
    
    ; display array
    mov dx, offset arrayMsg
    call write_string
    mov cx, [N]
    mov bx, 0000h
    .draw_array_X:    
        push cx    
        mov ax, [array+bx]  
        call write_number  
        mov dx, offset separator
        call write_string
        add bx, 0002h
        pop cx
        loop .draw_array_X  
    mov dx, offset new_line
    call write_string   
    
    
    
    ; execute task
    mov cx, [N]             ; iteration
    mov ax, 0000h           ; sum
    mov dx, [array+0000h]   ; minimum
    mov si, 0000h               
    task_cycle:
        mov bx, [array+si]
        test cx, 1b
        jnz skip_sum    
            add ax, bx
        skip_sum:
        cmp dx, bx
        jl skip_minimum_change_1
            mov dx, bx
        skip_minimum_change_1:
        add si, 0002h    
        loop task_cycle 
    mov bx, dx
    cwd  
    imul bx  
  
    ; display result
    push ax
    mov dx, offset calculatedValue
    call write_string
    pop ax      
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
