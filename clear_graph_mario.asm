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
mov ax,08000h 
mov ds,ax 
pop ax 
mov ah,al 
mov bx,0FFFCh 
mov [bx],ax 
p0: 
add bx,4
mov [bx],ax 
mov [bx+2],ax   
cmp bx,0FFFCh 
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
cmp cx,200
ja draw_sprite_2
mul cx 
mov dx,[x]      
cmp dx,0319
ja draw_sprite_2 
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
cmp bx,0FFF8h 
jz draw_display_2 
mov al,[bx]
stosb        
mov al,[bx+1]
stosb        
mov al,[bx+2]
stosb
mov al,[bx+3]
stosb    
mov al,[bx+4]
stosb        
mov al,[bx+5]
stosb        
mov al,[bx+6]
stosb
mov al,[bx+7]
stosb
add bx,8
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

line_45:
mov [move_45_turn],al
mov [steps],ah
xor di,di
mov si,di
cmp al,01h
jnz line_45_2
line_45_1_rotate:
push dx
push cx 
mov al,1Fh
mov ah,00h 
call put_pix
pop cx
pop dx
mov al,[steps]
cmp al,00
jz e
inc dx
dec cx
dec al
mov [steps],al
jmp line_45_1_rotate
line_45_2: 
cmp al,02h
jnz line_45_3 
line_45_2_rotate:
push dx
push cx 
mov al,1Fh
mov ah,00h 
call put_pix
pop cx
pop dx
mov al,[steps]
cmp al,00
jz e
dec dx
dec cx
dec al
mov [steps],al  
jmp line_45_2_rotate
line_45_3:
cmp al,03h
jnz line_45_4
line_45_3_rotate:
push dx
push cx 
mov al,1Fh
mov ah,00h 
call put_pix
pop cx
pop dx
mov al,[steps]
cmp al,00
jz e
dec dx
inc cx
dec al
mov [steps],al
jmp line_45_3_rotate 
line_45_4:
cmp al,04h
jnz e
line_45_4_rotate:
push dx
push cx 
mov al,1Fh
mov ah,00h 
call put_pix
pop cx
pop dx
mov al,[steps]
cmp al,00
jz e
inc dx
inc cx
dec al
mov [steps],al
jmp line_45_4_rotate 


steps        db 0
move_45_turn db 0 

db '51-1'
 


draw_titles_inc_y: 
mov [scroll_x],0FFh
mov al,[scroll_y]
inc al
mov [scroll_y],al  
cmp al,20
jz e
jmp draw_titles_01

empy_title:    
mov ah,0
mov al,[scroll_x]
add ax,[global_scroll]
mov bh,0
mov bl,[titles_line]
inc bl
add bx,[global_scroll]
cmp al,bl
jz draw_titles_inc_y
jmp draw_titles_01   

output_title01:
mov ax,0000h 
mov al,[scroll_y]
mov dl,[height_sprite]
mul dl
mov [y],ax
mov ax,0000h     
mov al,[scroll_x]
mov dl,[lenght_sprite]
mul dl 
mov dl,[local_scroll]  
mov dh,00h      
sub ax,dx
mov [x],ax     
mov si,0000h
mov di,si
mov bx,title_01
call draw_sprite
jmp empy_title


draw_titles: 
mov [scroll_x],0FFh
mov [scroll_y],00h
mov si,0000h
mov di,si     
draw_titles_01: 
add [scroll_x],01h
mov ax,0000h
mov al,[scroll_y]
mov dl,[map_lenght]
mul dl
mov bx,0000h
mov bx,ax  
mov al,[scroll_x]
mov ah,0
add ax,[global_scroll]  
add bx,ax  
add bx,map
mov al,[bx]
cmp al,00h
jz empy_title
cmp al,01h
jz output_title01  
jmp e
 



scroll_x db 0
scroll_y db 0


left: 
cmp [local_scroll],00h
jnz left_01
cmp [global_scroll],00h
jz p4
sub [global_scroll],01h  
mov al,[lenght_sprite]     
mov [local_scroll],al
jmp p4
left_01:
sub [local_scroll],01h
jmp p4

right: 
mov al,[lenght_sprite]                  
cmp [local_scroll],al
jz p4
add [local_scroll],01h 
cmp [local_scroll],al
jnz p4
add [global_scroll],01h
mov [local_scroll],00h 
jmp p4     



start:  
mov ah,0
mov al,13h
int 10h    
p4:
mov al,64h
call fill_disp  
call draw_titles  
mov [x],0
mov [y],0
mov bx,mario_sprite  
mov di,0000
mov si,di
call draw_sprite 
call draw_display 
mov ah,0
int 16h
cmp al,'a'
jz left
cmp al,'d'
jz right
jmp p4      

x1 dw 0
y1 dw 0
color_cursor db 1Fh  






;; Calls:
;; draw_sprite, Output sprite.
            ;; BX - offset of sprite
            ;; SI - 0000h 
            ;; [x] - X offset
            ;; [y] - Y offset  
            
;; put_pix, Output pixel
        ;; CX - Y offset
        ;; DX - X offset
         
;; get_pix, Get color of pixel
        ;; CX - Y offset
        ;; DX - X offset   
         ;; return AL 
                 
;; fill_disp, Fill display
            ;; AL - color
            
;; put_box, Output box
            ;; DX - X1
            ;; CX - Y1
            ;; AX - X2
            ;; BX - Y2  
            
            
  
            
              


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

;------------------------------------------------------------------------------------------------

;; ----------------------------------------;-
global_scroll dw 0                         ;-
local_scroll  db 0                         ;-
lenght_sprite db 15                        ;-
height_sprite db 15                        ;-
map_lenght db 46                           ;-
titles_line db 23                          ;-
;; Global offsets for scrolling            ;-
;------------------------------------------;-   


mario_sprite:
         db 255,255,255,004,004,004,004,004,004,255,255,255,255,0
         db 255,255,004,004,004,004,004,004,004,004,004,004,255,0
         db 255,255,006,006,006,014,014,006,014,255,255,255,255,0
         db 255,006,014,006,014,014,014,006,014,014,014,014,255,0
         db 255,006,014,006,006,014,014,014,006,014,014,014,014,0
         db 255,006,006,014,014,014,014,006,006,006,006,006,255,0
         db 255,255,255,014,014,014,014,014,014,014,014,255,255,0
         db 255,255,006,006,004,006,006,006,255,255,255,255,255,0
         db 255,006,006,006,004,006,006,004,006,006,006,006,255,0
         db 006,006,006,006,004,004,004,004,006,006,006,006,006,0
         db 014,014,006,004,014,004,004,014,004,006,006,014,014,0
         db 014,014,014,004,004,004,004,004,004,006,014,014,014,0
         db 014,014,004,004,004,004,004,004,004,004,004,014,014,0 
         db 255,255,006,006,006,255,255,255,006,006,006,255,255,0
         db 255,006,006,006,006,255,255,255,006,006,006,006,255,0,0
         
         
         

title_01 db 0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0
         db 2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,0F8h,2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,0F8h,0 
         db 2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,0F8h,2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,0F8h,0  
         db 2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,0F8h,2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,0F8h,0 
         db 0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0      
         db 2Ah,2Ah,0F8h,2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,0F8h,2Ah,2Ah,2Ah,2Ah,2Ah,0    
         db 2Ah,2Ah,0F8h,2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,0F8h,2Ah,2Ah,2Ah,2Ah,2Ah,0  
         db 0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0
         db 2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,0F8h,2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,0F8h,0 
         db 2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,0F8h,2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,0F8h,0 
         db 0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0
         db 2Ah,2Ah,0F8h,2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,0F8h,2Ah,2Ah,2Ah,2Ah,2Ah,0
         db 2Ah,2Ah,0F8h,2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,0F8h,2Ah,2Ah,2Ah,2Ah,2Ah,0
         db 2Ah,2Ah,0F8h,2Ah,2Ah,2Ah,2Ah,2Ah,2Ah,0F8h,2Ah,2Ah,2Ah,2Ah,2Ah,0
         db 0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0,0
         
          
           
         
   
         
         
           


         
          
         
map db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0 
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0 
    db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0 
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 

    
