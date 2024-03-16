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
    mov cx, 80h
    lea si, buffer
    mov sumVal, 0
    mov countVal, 0

sumLoop:
    mov al, [si]
    add sumVal, ax
    inc countVal
    inc si
    loop sumLoop

    ; Calculate average
    mov ax, sumVal
    cwd 
    idiv countVal

mov ah, 09h        ; DOS function for displaying string
    lea dx, averageMsg ; Load message for display
    int 21h            ; Display message
    ; Output average
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
