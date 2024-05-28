#make_boot#

org 7c00h 
use16 

push ds
push ds
push ds
jmp start 

e: 
ret

e1:
pop ds
ret    
     
put_pix_box: 
push ax
push bx
push cx
push dx

push dx
mov ax, 8000h 
mov es, ax 
mov ax,320 
mul cx 
pop dx 
add ax,dx 
mov di,ax 
mov al,[boxc]
stosb  
pop dx
pop cx
pop bx
pop ax
ret 

put_box_new_line:
inc cx
cmp cx,bx
jz e  
dec cx
inc cx
mov dx,[bxr]
jmp ppb0 

put_box: 
mov [bxr],dx 
ppb0:   
call put_pix_box  
cmp cx,bx
jz e    
cmp ax,dx
jz put_box_new_line
inc dx
jmp ppb0 

;; AX - x2
;; DX - x1

;; CX - y1
;; BX - y2


boxc db 0
bxr  dw 0


put_pix: 
push ax 
push dx 
mov ax, 8000h 
mov es, ax 
mov ax,320 
mul cx 
pop dx 
add ax,dx 
mov di,ax 
pop ax 
stosb 
ret 

fill_disp: 
push ds
push ax 
mov ax,8000h 
mov ds,ax 
pop ax 
mov ah,al 
mov bx,0000h 
mov [bx],ax 
p0: 
add bx,2 
mov [bx],ax 
cmp bx,0FFFEh 
jz e1 
jmp p0 

e_draw: 
pop dx 
pop bx 
mov [x],dx 
mov [y],bx
pop ds 
ret 

draw_sprite_nexline: 
inc si 
mov al,00h 
cmp al,[bx+si] 
jz e_draw 
dec si 
add [y],01h 
mov ax,[x_ret] 
mov [x],ax 
inc si 
jmp draw_sprite_1 

draw_sprite: 
push ds
mov ax,bx 
mov dx,[x] 
mov bx,[y] 
push bx 
push dx 
mov bx,ax 
mov ax,[x] 
mov [x_ret],ax 
mov si,0000h 
draw_sprite_1: 
mov ax, 8000h 
mov es, ax 
mov ax,320 
mov cx,[y] 
mul cx 
mov dx,[x] 
add ax,dx 
mov di,ax 
mov al,[bx+si] 
cmp al,255 
jz draw_sprite_2 
stosb 
draw_sprite_2: 
inc si 
mov al,00h 
cmp al,[bx+si] 
jz draw_sprite_nexline 
add [x],1 
jmp draw_sprite_1 

draw_display:
push ds 
mov di,0000h 
mov bx,0000h 
mov si,0000h 
mov ax,8000h 
mov ds,ax 
mov ax,0A000h 
mov es,ax 
draw_display_1: 
cmp bx,0FFFFh 
jz draw_display_2 
mov al,[bx] 
stosb 
inc bx 
jmp draw_display_1 
draw_display_2: 
jz e1   

get_pix:
push ax
push dx
mov ax,320 
mul cx 
pop dx 
add ax,dx
mov di,ax 
pop ax 
push ds
mov ax,0A000h
mov ds,ax
mov al,[di]
pop ds
ret

get_alive1:
mov [alives],00h
mov al,[es:di+1]
cmp al,30h
jnz get_alive2  
add [alives],01h
get_alive2: 
mov al,[es:di-1]
cmp al,30h
jnz get_alive3  
add [alives],01h
get_alive3:
mov al,[es:di+1+320]
cmp al,30h
jnz get_alive4  
add [alives],01h 
get_alive4:   
mov al,[es:di-1+320]
cmp al,30h
jnz get_alive5  
add [alives],01h 
get_alive5:
mov al,[es:di+1-320]
cmp al,30h
jnz get_alive6
add [alives],01h 
get_alive6: 
mov al,[es:di-1-320]
cmp al,30h
jnz get_alive7  
add [alives],01h 
get_alive7:  
mov al,[es:di+320]
cmp al,30h
jnz get_alive9  
add [alives],01h 
get_alive9:
mov al,[es:di-320]
cmp al,30h
jnz get_alive10  
add [alives],01h 
get_alive10:  
ret

alives db 0

put_alive_if_alive:
mov al,[es:di]
cmp al,30h
jnz put_alive_if_alive_1
mov ax,9000h
mov es,ax   
mov al,30h
mov [es:di],al
mov ax,8000h
mov es,ax
cmp di,0FFFFh
jz e
inc di
jmp life_step1
put_alive_if_alive_1:     
cmp di,0FFFFh
jz e
inc di
jmp life_step1

put_alive_forewer:  ;; lol
mov ax,9000h
mov es,ax     
mov al,30h
mov [es:di],al
mov ax,8000h
mov es,ax 
cmp di,0FFFFh
jz e
inc di
jmp life_step1    

put_dead: 
mov ax,9000h
mov es,ax     
mov al,00h
mov [es:di],al
mov ax,8000h
mov es,ax      
cmp di,0FFFFh
jz e
inc di
jmp life_step1



life_step:  
mov ax,08000h
mov es,ax
mov di,0000h
mov si,di
life_step1:    
call get_alive1 
cmp [alives],02h
jz put_alive_if_alive
cmp [alives],03h
jz put_alive_forewer
jmp put_dead


life_output:
push ds 
mov di,0000h 
mov bx,0000h 
mov si,0000h 
mov ax,9000h 
mov ds,ax 
mov ax,8000h 
mov es,ax 
life_output_1: 
cmp bx,0FFFFh 
jz life_output_2 
mov al,[bx] 
stosb 
inc bx 
jmp life_output_1 
life_output_2: 
jz e1 
 
move_up:
mov cx,[y1]  
mov cx,[y1]
mov dx,[x1]  
mov al,[pre_color]
mov ah,0
call put_pix  
mov cx,[y1] 
dec cx
mov [y1],cx
jmp p5

move_down:
mov cx,[y1] 
mov cx,[y1]
mov dx,[x1]  
mov al,[pre_color]
mov ah,0
call put_pix 
mov cx,[y1] 
inc cx
mov [y1],cx
jmp p5   

move_left:
mov ax,[x1]        
mov cx,[y1]
mov dx,[x1]  
mov al,[pre_color]
mov ah,0
call put_pix 
mov ax,[x1] 
dec ax
mov [x1],ax
jmp p5  

move_right:
mov ax,[x1]        
mov cx,[y1]
mov dx,[x1]  
mov al,[pre_color]
mov ah,0
call put_pix  
mov ax,[x1]
inc ax
mov [x1],ax
jmp p5   

p5:
mov cx,[y1]
mov dx,[x1]  
call get_pix
mov [pre_color],al
jmp p6   

push_color: 
mov al,30h
mov [pre_color],al
jmp p6   

push_dead: 
mov al,00h
mov [pre_color],al
jmp p6 


pre_color db 0


go:
mov cx,[y1]
mov dx,[x1]  
mov al,[pre_color]
mov ah,0
call put_pix      
jmp p4

start:  
mov ah,0
mov al,13h
int 10h
mov al,10h
call fill_disp 
p6_1: 
mov cx,[y1]
mov dx,[x1]  
call get_pix
mov [pre_color],al
;;
p6:  
mov cx,[y1]
mov dx,[x1]  
mov al,[color_cursor]
mov ah,0
call put_pix
call draw_display
p7:  
mov ah,0
int 16h 
cmp ah,48h
jz move_up
cmp ah,4Bh
jz move_left
cmp ah,50h
jz move_down
cmp ah,4Dh
jz move_right
cmp al,20h
jz push_color
cmp ah,1Ch
jz go     
cmp al,'c'
jz push_dead
jmp p7   
;;
p4:      
call life_step 
mov al,10h
call fill_disp  
call life_output
call draw_display  
mov ah,01h
int 16h   
jz p4
mov ah,0
int 16h
cmp ah,1Ch
jz p6_1
jmp p4      

x1 dw 0
y1 dw 0
color_cursor db 1Fh


;; AX - x2
;; DX - x1

;; CX - y1
;; BX - y2


wait_commets dw 0
;; ------------------------------------------
x_ret dw 0                                 ;-
x dw 0                                     ;-
y dw 0                                     ;-
                                           ;-
tx dw 0                                    ;-
ty dw 0                                    ;-
;; Global offsets for procedure draw_sprite;-
;------------------------------------------;-   
