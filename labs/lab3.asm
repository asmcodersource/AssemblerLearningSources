.MODEL small
.STACK 4096
.DATA
Set_X DB 10,13,'X = $'
Result DB 13,10,'Y = $'
TryAgain DB 13,10, 'You want to try again [Y/N]$'
error_ db "incorrect number$"
buff db 6,7 Dup(?)
.CODE
main PROC
mov ax,@Data
mov ds,ax
repeat2:
mov dx,OFFSET Set_X
mov ah,09h
int 21h
mov cx,0
mov ah,0ah
xor di,di
mov dx,offset buff
int 21h
mov dl,0ah
mov ah,02
int 21h
mov si,offset buff+2
cmp byte ptr [si],"-"
jnz ii1
mov di,1
inc si
ii1:
xor ax,ax
mov bx,10
ii2:
mov cl, [si]
cmp cl, 0dh
jz endin
cmp cl,'0'
jl er
cmp cl,'9'
ja er
sub cl,'0'
mul bx
add ax,cx
inc si
jmp ii2
er:
mov dx, offset error_
mov ah,09
int 21h
int 20h
endin:
cmp di,1
jnz ii3
neg ax
ii3:
add ax, 2
cwd
mov bx, 0Ah
idiv bx
xor dx,dx
imul ax
sub ax, 03
xchg cx,ax
mov dx,OFFSET Result
mov ah,09h
int 21h
xchg cx,ax
test ax, ax
jns oi1
mov cx, ax
mov ah, 02h
mov dl, '-'
int 21h
mov ax, cx
neg ax
oi1:
xor cx, cx
mov bx, 10
oi2:
xor dx,dx
div bx
push dx
inc cx
test ax, ax
jnz oi2
mov ah, 02h
oi3:
pop dx
add dl, '0'
int 21h
loop oi3
repeat1:
mov dx,OFFSET TryAgain
mov ah,09h
int 21h
mov ah, 01h
int 21h
cmp al, 59h
jz repeat2
cmp al, 'N'
jnz repeat1
mov ah,04ch
int 21h
main ENDP
END main