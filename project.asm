.model small
.stack 100h

.data
    buffer db 80h dup(?)
    sumVal dw ?
    countVal dw ?
    averageMsg db ' Average value: $'
    keyBuffer db 16 dup(?)  ; Buffer for storing the key
    valueBuffer db 8 dup(?) ; Buffer for storing the value

.code
main proc
    mov ax, @data
    mov ds, ax

    mov ah, 3Fh       ; DOS function for opening a file
    mov bx, 0         ; File handle (0 = standard input)
    lea dx, buffer    ; Pointer to buffer
    mov cx, 80h       ; Number of bytes to read
    int 21h          ; DOS interrupt

    cmp ax, cx
    jae checking_eof    ; If end of file reached, proceed to checking EOF
    mov cx, ax       ; Update the count of characters read

output:
    mov ah, 02h      ; DOS function for displaying character
    mov si, 0        ; Initialize source index to 0

print_loop:
    mov dl, [si]     ; Load character for output
    int 21h          ; Display character
    inc si           ; Move to next character
    loop print_loop  ; Repeat until CX != 0

checking_eof:
    ; Check end of file
    mov ah, 3Eh      ; DOS function for checking EOF
    mov bx, 0        ; File handle (0 = standard input)
    int 21h          ; DOS interrupt

    ; If EOF pointer is not equal to 128 (0x80), file has ended
    cmp ax, 80h
    jne calculate_average ; If EOF, calculate average
    jmp exit_program

calculate_average:
    mov si, offset buffer  ; Set SI to the beginning of the buffer
    mov di, offset keyBuffer ; Set DI to the beginning of the key buffer
    mov cx, 80h       ; Initialize CX with the length of the buffer

calculate_sum:
    ; Parse the key
    mov al, [si]     ; Load the first character of the key
    cmp al, ' '      ; Check if the character is a space
    je store_value   ; If space, proceed to storing the value

    mov [di], al     ; Store the character in the key buffer
    inc si           ; Move to the next character of the key
    inc di           ; Move to the next position in the key buffer
    loop calculate_sum ; Repeat until CX != 0
    jmp exit_program

store_value:
    inc si           ; Move past the space character
    mov al, [si]     ; Load the first character of the value
    sub al, '0'      ; Convert ASCII to binary
; Zero extend to AX
mov ah, 0     ; Clear AH
mov al, [si]  ; Load the byte from memory into AL

    add sumVal, ax   ; Add to the sum
    inc si           ; Move to the next character
    cmp byte ptr [si], ' '  ; Check if the next character is a space
    jne store_value  ; If not, continue parsing the value

    ; Increment the count of values
    inc countVal

    ; Calculate the average
    mov ax, sumVal
    cwd               ; Sign-extend AX into DX:AX
    idiv countVal     ; Divide DX:AX by countVal, quotient in AX

    ; Output key
    mov dx, offset keyBuffer ; Load address of key buffer
    mov ah, 02h       ; DOS function for printing string
    int 21h           ; DOS interrupt

    ; Output average
    mov ah, 09h 
    mov dx, offset averageMsg ; Load address of average message
        ; DOS function for printing string
    int 21h           ; DOS interrupt

    ; Convert AX to ASCII and print
      mov cx, 17
    add dl, '0'       ; Convert to ASCII
    mov ah, 02h       ; DOS function for displaying character
    int 21h           ; DOS interrupt

    jmp exit_program ; Jump to exit program

exit_program:
    ; Terminate program
    mov ax, 4c00h
    int 21h

main endp
end main
