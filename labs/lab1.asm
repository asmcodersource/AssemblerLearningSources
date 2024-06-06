.MODEL small
.STACK 4096    

.DATA
    first_name DB 'Bi',226,'a',171,'i',169, 13, 10, '$'             
    last_name DB 'Ho',162,'a',170, 13, 10, '$'       
    middle_name DB 143,'e',226,'po',162,168,231, 13, 10, '$'       

.CODE

main PROC
    mov ax,@data       
    mov ds,ax      
    mov dx,offset last_name
    mov ah,9h
    int 21h     
    mov dx,offset first_name
    int 21h      
    mov dx,offset middle_name
    int 21h
    mov ah, 04Ch       
    int 21h
main ENDP
END main