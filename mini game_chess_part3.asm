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

checkcollun:
add [collun],01h
cmp [collun],02h
jnz e
mov [collun],0
add ax,25
add dx,25
jmp e


regtangles:
mov ax,[x_pole1]
add ax,25
mov dx,[x_pole1]
mov cx,0000
mov bx,0025  
p5:           
mov di,0000
mov si,di
mov [boxc],06h   
push ax
push dx
push cx
push bx
call put_box 
pop bx
pop cx
pop dx
pop ax     
add dx,50
add ax,50
cmp ax,[x_pole]
jna p6   
mov ax,[x_pole1]
add ax,25
mov dx,[x_pole1]
add cx,25
add bx,25  
call checkcollun
p6:      
cmp bx,200
jna p7     
jmp e
p7:
jmp p5              

draw_eror_checker:  
mov al,25
mul di              
sub al,25
mov [pos_y_check],al  
mov dx,235
mov ax,260          
mov cl,[pos_y_check]
mov ch,0
mov bx,0
mov bx,cx
add bx,25
mov di,0000
mov si,0000
jmp draw_cheker_1_1   

draw_eror_checker_manual:
add bx,100
mov di,0000
mov si,0000
mov cx,75  
mov dx,235
jmp draw_cheker_1_1   




draw_white_checker:
mov [boxc],1Fh  
jmp draw_checker
draw_black_checker: 
mov [boxc],11h   
draw_checker: 
push si
push di
push ax
push bx
push cx
push dx       
cmp si,16
jz draw_eror_checker  
cmp si,64
jz draw_eror_checker
cmp si,48
jz draw_eror_checker   
cmp si,32
jz draw_eror_checker_manual
sub cx,08h
sub si,cx        
mov al,25
mul si  
sub al,25
mov [pos_x_check],al 
mov al,25
mul di              
mov [pos_y_check],al  
mov di,0000h
mov si,0000h    
mov dh,0
mov dl,[pos_x_check]
mov ch,0
mov cl,[pos_y_check]   
add dx,60
add ax,60 
draw_cheker_1_1: 
add dx,1 
mov [x],dx
mov [y],cx  
mov bx,checker_sprite_white    
mov cl,[boxc]
cmp cl,1Fh
jz draw_checker_white
mov bx,checker_sprite_black
draw_checker_white:
call draw_sprite
pop dx
pop cx
pop bx
pop ax
pop di
pop si
jmp draw_checkers_1 





pos_x_check db 0
pos_y_check db 0 




draw_checkers:
xor si,si
xor di,di
mov cx,08h
inc si 
draw_checkers_0:    
mov al,[pole-1+si]    
cmp al,01
jz draw_white_checker      
cmp al,02
jz draw_black_checker  
draw_checkers_1:
inc si   
cmp si,65
jz e     
cmp si,cx
jnz draw_checkers_0
add cx,08h
inc di
jmp draw_checkers_0  


draw_selector:
mov al,[x_sel]
mov dl,25
mul dl
mov dx,ax 
push dx
mov al,[y_sel]
mov dl, 25
mul dl 
mov cx,ax
pop dx
add dx,60
mov ax,dx
add ax,25 

mov bx,cx
add bx,25

mov [boxc],79h
call put_box
ret   

swoop:
cmp [player],01h
jnz player_swop 
mov [player],02h
jmp e
player_swop:
mov [player],01h
jmp e 



x_sel db 0
y_sel db 0

collun db 1   

up_sel:   
cmp [y_sel], 00
jz p4
sub [y_sel],01 
jmp p4

down_sel:
cmp [y_sel], 07
jz p4
add [y_sel],01 
jmp p4 

left_sel:
cmp [x_sel], 00
jz p4
sub [x_sel],01
jmp p4 

right_sel:    
cmp [x_sel], 07
jz p4
add [x_sel],01 
jmp p4  

enemy_spotted:   
mov [enemy_spoted],01h
ret


enemy_spoted db 0

check_top_left: 
cmp [top],01h
jz che1
cmp [left],01h
jz che1 
mov al,[bx+si-9-9]
cmp al,00
jz enemy_spotted  
jmp che1
check_top_right:
cmp [top],01h
jz che2
cmp [right],01h
jz che2 
mov al,[bx+si-7-7]
cmp al,00
jz enemy_spotted 
jmp che2
check_bottom_left:
cmp [bottom],01h
jz che4
cmp [left],01h
jz che4  
mov al,[bx+si+7+7]
cmp al,00
jz enemy_spotted
jmp che4
check_bottom_right:
cmp [bottom],01h
jz che3
cmp [right],01h
jz che3
mov al,[bx+si+9+9]
cmp al,00
jz enemy_spotted 
jmp che3

   
get_flags:
push ax   
mov [top],00h
mov [bottom],00h
mov [left],00h
mov [right],00h
mov al,[x_check]
mov ah,[y_check]
cmp al,01h
jnbe get_flags_1
mov [left],01h
get_flags_1:
cmp al,06h
jnae get_flags_2
mov [right],01h
get_flags_2:
cmp ah,01h
jnbe get_flags_3
mov [top],01h
get_flags_3:
cmp ah,06h 
jnae get_flags_4
mov [bottom],01h
get_flags_4: 
pop ax
ret 

top db 0
bottom db 0
left db 0
right db 0


check_enemy:      
call get_flags
mov cl,[player]
call swoop
mov ch,[player]
mov [player],cl  
mov [enemy_player],ch  
mov al,[y_check]
mov dl,8
mul dl
add al,[x_check]
mov ah,00
mov si,ax            
mov al,[bx+si-9]
cmp al,[enemy_player]
jz check_top_left 
che1: 
mov al,[bx+si-7]
cmp al,[enemy_player]
jz check_top_right
che2: 
mov al,[bx+si+9]
cmp al,[enemy_player]
jz check_bottom_right
che3:
mov al,[bx+si+7]
cmp al,[enemy_player]
jz check_bottom_left
che4:  
jmp check_enemy_exit    
 


enemy_player db 0

     

check_beat: 
mov [x_check],0   
mov [y_check],0 
xor si,si
mov di,si
mov bx,pole
check_beat_01:
mov al,[y_check]
mov dl,8
mul dl
add al,[x_check]
mov ah,00
mov si,ax    
cmp si,64
jz e
mov al,[bx+si] 
cmp al,[player]
jz check_enemy  
check_enemy_exit:
mov al,[x_check]
inc al   
mov [x_check],al
cmp al,08
jnz check_beat_01
mov [x_check],0
mov al,[y_check]
inc al
mov [y_check],al
jmp check_beat_01




x_check db 0
y_check db 0

set_sel_checker:
mov al,[y_sel]
mov [y_buff],al      
mov al,[x_sel]
mov [x_buff],al    
jmp p4


x_buff db 0
y_buff db 0
x1_buff db 0
y1_buff db 0

run_now:        
mov al,[y1_buff]
mov dl,8
mul dl
add al,[x1_buff]
mov ah,0
mov si ,ax
mov bx,pole 
mov al,[player]
mov [bx+si],al
mov al,[y_buff]
mov dl,8
mul dl
add al,[x_buff]
mov ah,0
mov si ,ax
mov bx,pole
mov al, 0 
mov [bx+si],al
call swoop   
jmp p4



try_move:
mov al,[y_sel]
mov [y1_buff],al      
mov al,[x_sel]
mov [x1_buff],al 
cmp [enemy_spoted],01
jnz run    

mov al,[y_buff]
mov cl,[y1_buff]
cmp al,cl
jna attack_02
sub al,cl
cmp al,02h
jnz p4
jmp attack_03
attack_02:
sub cl,al
cmp cl,02h
jnz p4   
attack_03: 

mov al,[x_buff]
mov cl,[x1_buff]
cmp al,cl
jna attack_04
sub al,cl
cmp al,02h
jnz p4
jmp attack_05
attack_04:
sub cl,al
cmp cl,02h
jnz p4   
attack_05:
mov al,[x_buff]
add al,[x1_buff]
mov cl,02h
div cl
mov [middle_point_x],al   
mov al,[y_buff]
add al,[y1_buff]
mov cl,02h
div cl
mov [middle_point_y],al 

mov al,[middle_point_y]
mov dl,8
mul dl
add al,[middle_point_x]
mov ah,00
mov si,ax
mov bx,pole
mov al,[bx+si]        
cmp al,[enemy_player]
jnz p4
mov al,0
mov [bx+si],al

mov al,[y_buff]
mov dl,8
mul dl
add al,[x_buff]
mov ah,00
mov si,ax
mov bx,pole   
mov al,0
mov [bx+si],al    

mov al,[y1_buff]
mov dl,8
mul dl
add al,[x1_buff]
mov ah,00
mov si,ax
mov bx,pole   
mov al,[player]
mov [bx+si],al 
mov [enemy_spoted],00h
call check_beat
cmp [enemy_spoted],01h
jz p4
call swoop  
mov [enemy_spoted],00h
jmp p4


middle_point_x db 0
middle_point_y db 0   



run:      
mov al,[y_buff]
mov cl,[y1_buff]
cmp [player],01h
jz run_02
sub cl,al
cmp cl,01h
jnz p4  
jmp run_03  
run_02:
sub al,cl
cmp al,01h
jnz p4    
run_03:
mov al,[x_buff]
mov cl,[x1_buff]
cmp al,cl
ja run_01
sub cl,al
cmp cl,01h
jz run_now
jmp p4
run_01:
sub al,cl
cmp al,01h
jz run_now
jmp p4




do_some:
mov al,[y_sel]
mov dl,8
mul dl
add al,[x_sel]
mov ah,00
mov si,ax
mov bx,pole
mov al,[bx+si]
cmp al,[player]
jz set_sel_checker 
cmp al,00
jz try_move  
jmp p4



start:  
cld   
mov ah, 0 
mov al, 13h 
int 10h       
p4:
mov al,0BBh
call fill_disp          
mov di,0000h
mov si,di
mov ax,[x_pole]
mov dx,[x_pole1]
mov cx,000
mov bx,200
mov [boxc],0Eh
call put_box     
mov di,0000
mov si,di          
call regtangles  
call draw_selector
call draw_checkers        
call draw_display  
call check_beat
mov ah,0
int 16h
cmp al,'w'
jz up_sel
cmp al,'s'
jz down_sel
cmp al,'a'
jz left_sel
cmp al,'d'
jz right_sel  
cmp ah,1Ch
jz do_some 
jmp p4   

x_pole  dw 260
x_pole1 dw 60    

player db 1

   
pole db 2,0,2,0,2,0,2,0     
     db 0,2,0,2,0,2,0,2
     db 2,0,2,0,2,0,2,0
     db 0,0,0,0,0,0,0,0
     db 0,0,0,0,0,0,0,0
     db 0,1,0,1,0,1,0,1
     db 1,0,1,0,1,0,1,0
     db 0,1,0,1,0,1,0,1


;; AX - x2
;; DX - x1

;; CX - y1
;; BX - y2


;; ------------------------------------------
x_ret dw 0                                 ;-
x dw 0                                     ;-
y dw 0                                     ;-
                                           ;-
tx dw 0                                    ;-
ty dw 0                                    ;-
;; Global offsets for procedure draw_sprite;-
;------------------------------------------;-   

; New line of sprite -  ,0
;; End of sprite      -  ,0,0

;; 16 - black
;; 25 - white_black
;; 30 - white  
;; 43 - yellow
;; 40 - red
;; 32 - blue


checker_sprite_white: 
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0
db 255,255,255,255,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,255,255,255,255,0
db 255,255,255,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,255,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,1eh,1eh,15,15,15,15,15,15,15,1eh,1eh,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,1eh,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,1eh,1eh,15,15,15,15,15,15,15,1eh,1eh,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,255,255,0
db 255,255,255,15,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,1eh,15,255,255,255,0
db 255,255,255,255,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,255,255,255,255,0
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0

checker_sprite_black: 
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0
db 255,255,255,255,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,255,255,255,255,0
db 255,255,255,15,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,15,255,255,255,0
db 255,255,15,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,11h,11h,15,15,15,15,15,15,15,11h,11h,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,11h,15,11h,11h,11h,11h,11h,11h,11h,15,11h,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,15,11h,11h,11h,11h,11h,11h,11h,11h,11h,15,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,15,11h,11h,11h,11h,11h,11h,11h,11h,11h,15,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,15,11h,11h,11h,11h,11h,11h,11h,11h,11h,15,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,15,11h,11h,11h,11h,11h,11h,11h,11h,11h,15,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,15,11h,11h,11h,11h,11h,11h,11h,11h,11h,15,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,15,11h,11h,11h,11h,11h,11h,11h,11h,11h,15,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,15,11h,11h,11h,11h,11h,11h,11h,11h,11h,15,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,11h,15,11h,11h,11h,11h,11h,11h,11h,15,11h,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,11h,11h,15,15,15,15,15,15,15,11h,11h,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,15,255,255,0
db 255,255,15,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,15,255,255,0
db 255,255,255,15,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,11h,15,255,255,255,0
db 255,255,255,255,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,255,255,255,255,0
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0   

   



;; ITS PART 2