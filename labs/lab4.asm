                                .MODEL small

.STACK 4096

.DATA           
   Newline db 13,'$'

   Set_X   DB       'X = $'            
   Set_A   DB       'A = $'
   Set_B   DB       'B = $'

   Result   DB       13,10,'Y = $'

   error_ db "incorrect number$"

   buff    db 6,7 Dup(?)   

.CODE    

main PROC
    mov    ax,@Data
    mov    ds,ax
    
    mov bp, sp      
    mov dx, offset Set_X
    mov ah,09h
    int 21h  
    call read_number
    push ax   
    mov dx, offset Set_A
    mov ah,09h
    int 21h  
    call read_number
    push ax 
    mov dx, offset Set_B
    mov ah,09h
    int 21h  
    call read_number
    push ax
    
    cmp ax, 40
    jge .second_function
     call function_first
     jmp .calculated  
   .second_function:
     call function_second
   .calculated:
     
    push ax
    mov dx, offset Result
    mov ah,09h
    int 21h
    pop ax  
    call write_number
    mov     ah,04ch        
    int       21h                  
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


function_first PROC  
    push bp
    mov bp, sp    
    mov ax, [bp+4]
    mov ax, [bp+6]
    mov ax, [bp+8]
    pop bp                                                                                                                                                                    
    ret
function_first ENDP            

function_second PROC
    push bp
    mov bp, sp
    mov ax, [bp+4]
    mov ax, [bp+6]
    mov ax, [bp+8]
    pop bp                                                                                                                                                                    
    ret
function_second ENDP     

END main