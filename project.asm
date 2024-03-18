.model small
.stack 100h

.data
    buffer      db 80h dup(?)             ; Buffer for storing input
    keyBuffer   db 16 dup(?)              ; Buffer for storing the key
    sortedKeys  db 16 dup(?)              ; Buffer for storing sorted keys
    sortedCount dw ?                      ; Number of sorted keys

.code
main proc
    mov  ax, @data                  ; Load data segment address
    mov  ds, ax                     ; Initialize data segment

    mov  ah, 3Fh                    ; DOS function for opening a file
    mov  bx, 0                      ; File handle (0 = standard input)
    lea  dx, buffer                 ; Pointer to buffer
    mov  cx, 80h                    ; Number of bytes to read
    int  21h                        ; DOS interrupt

    cmp  ax, cx                     ; Compare bytes read with buffer size
    jae  checking_eof               ; If end of file reached, proceed to checking EOF
    mov  cx, ax                     ; Update the count of characters read

    jmp  ascii_hex                  ; Jump to convert ASCII to hex

checking_eof:     
    ; Check end of file
    mov  ah, 3Eh                    ; DOS function for checking EOF
    mov  bx, 0                      ; File handle (0 = standard input)
    int  21h                        ; DOS interrupt

    ; If EOF pointer is not equal to 128 (0x80), file has ended
    cmp  ax, 80h
    je   ascii_hex                  ; If not EOF, convert ASCII to hex
    jmp  exit_program               ; Otherwise, exit the program

ascii_hex:        
    mov  si, offset buffer          ; Set SI to the beginning of the buffer
    mov  di, offset keyBuffer       ; Set DI to the beginning of the key buffer
    mov  cx, 16                     ; Initialize CX with the length of the buffer

convert_loop:     
    mov  al, [si]                   ; Load the character
    sub  al, '0'                    ; Convert ASCII to binary
    cmp  al, 9                      ; Check if the character is a digit
    jbe  store_hex                  ; If less than or equal to 9, store directly
    add  al, 7                      ; Otherwise, adjust for A-F

store_hex:        
    mov  [di], al                   ; Store the character in the key buffer
    inc  di                         ; Move to the next position in the key buffer
    inc  si                         ; Move to the next character
    loop convert_loop               ; Repeat until CX != 0

    jmp  calculate_average          ; After converting to hex, calculate average

calculate_average:
    ; Initialize sum and count variables
    mov  ax, 0                      ; Clear AX (sum)
    mov  cx, 0                      ; Clear CX (count)
    mov  si, offset keyBuffer       ; Set SI to the beginning of the key buffer

sum_loop:
    mov  al, [si]                   ; Load value from key buffer
    sub  al, '0'                    ; Convert ASCII to binary
    add  ax, ax                     ; Shift left AX (multiply by 2)
    add  ax, ax                     ; (two times to multiply by 4)
    add  ax, ax                     ; (two times to multiply by 8)
    add  ax, ax                     ; (two times to multiply by 16)
    add  ax, si                     ; Add to sum
    inc  si                         ; Move to next value in buffer
    cmp  si, offset keyBuffer + 16  ; Check end of buffer
    jb   sum_loop                   ; If not end, continue loop

    ; Calculate average
    mov  cx, 16                     ; Total number of elements
    mov  dx, 0                      ; Clear DX for division
    div  cx                         ; Divide sum by count

    ; Now sort the keys based on their average values
    mov  si, offset keyBuffer       ; Set SI to the beginning of the key buffer
    mov  di, offset sortedKeys      ; Set DI to the beginning of the sorted keys buffer
    mov  cx, 16                     ; Number of keys to process
    mov  bx, di                     ; Set BX to the beginning of the sorted keys buffer
    mov  ax, 0                      ; Clear AX (sorted count)

sort_loop:
    ; Check if the current key is already in the sorted keys buffer
    mov  dx, di                     ; Set DX to the beginning of the sorted keys buffer
    mov  al, [si]                   ; Load current key
search_loop:
    mov  bl, [di]                   ; Load byte from memory into BL
    cmp  al, bl                     ; Compare current key with the key in sorted keys buffer
    je   skip_add                   ; If found, skip adding to the sorted keys buffer
    add  di, 1                      ; Move to the next key in sorted keys buffer
    loop search_loop                ; Repeat until all keys are checked
                  
skip_add:
    mov  [di], al                   ; Add the key to the sorted keys buffer
    inc  di                         ; Move to the next position in the sorted keys buffer
    inc  si                         ; Move to the next key in key buffer
    inc  ax                         ; Increment the sorted count
    loop sort_loop                  ; Repeat until all keys are processed

    ; Store the number of sorted keys
    mov  sortedCount, ax            ; Store the sorted count

    ; Now output the sorted keys
    mov  si, offset sortedKeys      ; Set SI to the beginning of the sorted keys buffer
    mov  cx, sortedCount            ; Number of keys to output
output_loop:
    mov  dl, [si]                   ; Load key for output
    mov  ah, 02h                    ; DOS function for displaying character
    int  21h                        ; Display character
    inc  si                         ; Move to next key
    dec  cx                         ; Decrement the count of keys to output
    jnz  output_loop                ; Repeat until CX != 0

    jmp  exit_program               ; After outputting sorted keys, exit the program


;skip_convert:
 ;   add  dl, 7                      ; Convert to A-F

;print_character:
 ;   mov  ah, 02h                    ; DOS function for displaying character
  ;  int  21h                        ; Display character
   ; inc  si                         ; Move to next key
 ;   loop output_loop               ; Repeat until CX != 0
;
  ;  jmp  exit_program               ; After outputting sorted keys, exit the program

exit_program:     
    ; Terminate program
    mov  ax, 4c00h
    int  21h

main endp
end main
