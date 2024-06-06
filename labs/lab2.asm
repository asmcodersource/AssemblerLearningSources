.MODEL small
 
.STACK 4096
 
.DATA
 question db "You are man or female?[W\M]",10,13,'$'
 error db 10,13,'Try again, something went wrong', 10,13,'$'
 woman: db 10,13,"WOMAN",10,13,'$'
 man: db 10,13,"MAN", 10,13,'$'
 
.CODE
 
main PROC
start:    
mov ax,@Data
mov ds,ax
mov ah, 09h
mov dx, offset question
int 21h
 
mov ah,01h   
int 21h  
cmp al, 'W'
jz print_woman
cmp al, 'M'
jz print_man   
 
mov dx, offset error
mov ah, 09h
int 21h
jmp start
 
 
print_woman:
mov ah, 09h
mov dx, offset woman
int 21h
jmp start
 
print_man: 
mov ah, 09h         
mov dx, offset man
int 21h
jmp start
 
main ENDP
END main