.model small
.stack 100h

.data
    buffer db 80h dup(?)
    sumVal dw ?
    countVal dw ?
    averageMsg db ' Average of the array: $'

.code
main proc
    mov ax, @data
    mov ds, ax

    mov ah, 3Fh       
    mov bx, 0        
    lea dx, buffer   
    mov cx, 80h      
    int 21h         

    cmp ax, cx
    jae checking_eof    
    mov cx, ax       

output:
    mov ah, 02h      
    mov si, 0        

print_loop:
    mov dl, buffer[si] ; Load character for output
    int 21h           ; Display character
    inc si            ; Move to next character
    loop print_loop   ; Repeat until CX != 0

checking_eof:
    ; Check end of file
    mov ah, 3Eh       ; DOS function for checking EOF
    mov bx, 0     
    int 21h           ; DOS interrupt

    ; If EOF pointer is not equal to 128 (0x80), file has ended
    cmp ax, 80h
    jne calculate_average   ; If EOF, calculate average
    jmp exit_program

calculate_average:
    ; Calculate sum and count
    mov ax, 7FFFh
add ax, 0FFFh
   xor dx,dx       ; DX - 32-bit hi-word
mov ax, 7FFFh   ; AX - 32-bit lo-word
add ax, 7FFFh   ; add 16bit signed value
adc dx, 0       ; note that OF=0! 
mov dx, 0FFh
mov ax, 0h
mov bx, 1500
div bx  ; DX:AX / 1500, result in ax
   ; Output average
     mov cx, 17
     lea  dx, averageMsg
    mov ah, 09h       ; DOS function for printing string
    int 21h           ; DOS interrupt

    mov cx, 11
    lea si, buffer
outLoop:
    mov dl, [si]
    mov ah, 02h
    int 21h

    jmp exit_program

exit_program:
    ; Terminate program
    mov ax, 4c00h
    int 21h

main endp
end main
