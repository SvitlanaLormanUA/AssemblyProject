.model small
.stack 100h

.data
    buffer      db 80h dup(?)             ; Buffer for storing input
    sumVal      dw ?
    countVal    dw ?
    keyBuffer   db 16 dup(?)              ; Buffer for storing the key
    valueBuffer db 8 dup(?)               ; Buffer for storing the value

.code
main proc
    mov  ax, @data
    mov  ds, ax

    mov  ah, 3Fh                 ; DOS function for opening a file
    mov  bx, 0                   ; File handle (0 = standard input)
    lea  dx, buffer              ; Pointer to buffer
    mov  cx, 80h                 ; Number of bytes to read
    int  21h                     ; DOS interrupt

    cmp  ax, cx
    jae  checking_eof            ; If end of file reached, proceed to checking EOF
    mov  cx, ax                  ; Update the count of characters read

    ; Output received characters
    mov  ah, 02h                 ; DOS function for displaying character
    mov  si, 0                   ; Initialize source index to 0

print_loop:       
    mov  dl, [si]                ; Load character for output
    int  21h                     ; Display character
    inc  si                      ; Move to next character
    loop print_loop              ; Repeat until CX != 0

    jmp  ascii_hex               ; Jump to convert ASCII to hex

checking_eof:     
    ; Check end of file
    mov  ah, 3Eh                 ; DOS function for checking EOF
    mov  bx, 0                   ; File handle (0 = standard input)
    int  21h                     ; DOS interrupt

    ; If EOF pointer is not equal to 128 (0x80), file has ended
    cmp  ax, 80h
    je   ascii_hex               ; If not EOF, convert ASCII to hex
    jmp  exit_program            ; Otherwise, exit the program

ascii_hex:        
    mov  si, offset buffer       ; Set SI to the beginning of the buffer
    mov  di, offset keyBuffer    ; Set DI to the beginning of the key buffer
    mov  cx, 80h                 ; Initialize CX with the length of the buffer

convert_loop:     
    mov  al, [si]                ; Load the character
    sub  al, '0'                 ; Convert ASCII to binary
    cmp  al, 9                   ; Check if the character is a digit
    jbe  store_hex               ; If less than or equal to 9, store directly
    add  al, 7                   ; Otherwise, adjust for A-F

store_hex:        
    mov  [di], al                ; Store the character in the key buffer
    inc  di                      ; Move to the next position in the key buffer
    inc  si                      ; Move to the next character
    loop convert_loop            ; Repeat until CX != 0

    jmp  calculate_average       ; After converting to hex, calculate average

calculate_average:
    ; Initialize sum and count variables
    mov  ax, 0                   ; Clear AX (sum)
    mov  cx, 0                   ; Clear CX (count)
    mov  si, offset keyBuffer    ; Set SI to the beginning of the key buffer

sum_loop:
    mov  al, [si]                ; Load value from key buffer
    sub  al, '0'                 ; Convert ASCII to binary
    add  ax, ax                  ; Shift left AX (multiply by 2)
    add  ax, ax                  ; (two times to multiply by 4)
    add  ax, ax                  ; (two times to multiply by 8)
    add  ax, ax                  ; (two times to multiply by 16)
    add  ax, si                  ; Add to sum
    inc  si                      ; Move to next value in buffer
    cmp  si, offset keyBuffer + 16  ; Check end of buffer
    jb   sum_loop                ; If not end, continue loop

    ; Calculate average
    mov  cx, 16                  ; Total number of elements
    mov  dx, 0                   ; Clear DX for division
    div  cx                      ; Divide sum by count


    jmp  exit_program            ; After calculating average, exit the program

exit_program:     
    ; Terminate program
    mov  ax, 4c00h
    int  21h

main endp
end main
