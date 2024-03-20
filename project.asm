.model small
.stack 100h

.data
  buffer db 128 dup(?)     ; Buffer for storing input (128 bytes)
  keys   dw 10000 dup(?)   ; Array to store keys (10000 words)
  values dw 10000 dup(?)  ; Array to store values (10000 words, assuming they are words)
  keyCount dw 0            ; Number of keys read (initialized to 0)
  valueCount dw 0          ; Number of values read (initialized to 0)
  keyBuffer db 16 dup(?)   ; Buffer for storing the currently processed key (16 bytes)
  hexBuffer db 5 dup(?)    ; Buffer for storing the hexadecimal representation of values

.code
main proc
    mov  ax, @data             ; Load data segment address
    mov  ds, ax                ; Initialize data segment

    mov  ah, 3Fh               ; DOS function for opening a file
    mov  bx, 0                 ; File handle (0 = standard input)
    lea  dx, buffer            ; Pointer to buffer
    mov  cx, 128               ; Number of bytes to read
    int  21h                   ; DOS interrupt

    cmp  ax, cx                ; Compare bytes read with buffer size
    jae  checking_eof          ; If end of file reached, proceed to checking EOF
    mov  cx, ax                ; Update the count of characters read

    jmp  ascii_hex             ; Jump to convert ASCII to hex

  checking_eof:     
    ; Check end of file
    mov  ah, 3Eh               ; DOS function for checking EOF
    mov  bx, 0                 ; File handle (0 = standard input)
    int  21h                   ; DOS interrupt

    ; If EOF pointer is not equal to 128 (0x80), file has ended
    cmp  ax, 80h
    je   process_lines         ; If not EOF, convert ASCII to hex
                  
    ; Otherwise, exit the program
   

process_lines:
    mov  si, offset buffer     ; Set SI to the beginning of the buffer
    mov  di, offset keys       ; Set DI to the beginning of the keys array
    mov  bx, offset values     ; Set BX to the beginning of the values array
    mov  cx, 128               ; Initialize CX with the length of the buffer

parse_line:
    mov  al, [si]              ; Load the character
    cmp  al, ' '               ; Check if the character is a space
    je   store_value           ; If space, store the value
    mov  [di], al              ; Store the character in the keys array
    inc  di                    ; Move to the next position in the keys array
    jmp  next_char             ; Jump to process next character

store_value:
    mov  [bx], al              ; Store the character in the values array
    inc  bx                    ; Move to the next position in the values array
    inc  valueCount            ; Increment value count
    jmp  next_char             ; Jump to process next character

next_char:
    inc  si                    ; Move to the next character
    loop parse_line            ; Repeat until CX != 0

    ; Now convert values to hexadecimal
    mov  si, offset values     ; Set SI to the beginning of the values array
    mov  di, offset hexBuffer  ; Set DI to the beginning of the hexBuffer

convert_values_to_hex:
    mov  al, [si]              ; Load the value
    call ascii_hex             ; Convert the value to hexadecimal
    mov  [di], al               ; Store the hexadecimal character in the hexBuffer
    inc  di                    ; Move to the next position in the hexBuffer
    inc  si                    ; Move to the next position in the values array
    loop convert_values_to_hex ; Repeat until CX != 0

    jmp   calculate_average       ; Terminate program

ascii_hex:        
    push cx
    mov  ah, 01h
    int  21h
    sub  al, 30h
    cmp  al, 09h
    jle  down
down:             
    mov  cl, 04h
    rol  al, cl
    mov  ch, al
                    
    mov  ah, 01h
    int  21h
    sub  al, 30h
    cmp  al, 09h
    jle  d2
    sub  al, 07h
d2:               
    add  al, ch
    pop  cx
    ret
  calculate_average:
  ; Initialize sum and count variables
                    mov  ax, 0                      ; Clear AX (sum)
                    mov  cx, 0                      ; Clear CX (count)
                    mov  si, offset keys       ; Set SI to the beginning of the key buffer

  sum_loop:         
                    xor  al, al                     ; Clear AL
                    mov  al, [si]                   ; Load value from key buffer
                   ; sub  al, '0'                    ; Convert ASCII to binary
                    mov  al, byte ptr al            ; Load the byte value from memory address a into the AL register
                    add  ax, ax                     ; Add the byte value in AL to the AX register
 
                    add  cx, 1                      ; Increment count
                    inc  si                         ; Move to next value in buffer
                    cmp  si, offset keys + 16  ; Check end of buffer
                    jb   sum_loop                   ; If not end, continue loop

  ; Calculate average
                    div  cx                         ; Divide sum by count

  ; Now sort the keys based on their average values
                    mov  si, offset keys      ; Set SI to the beginning of the key buffer
                    mov  cx, 8                      ; Number of keys to process (16 bytes / 2 bytes per key)
                    dec  cx                         ; Set to count - 1 for loop control
  outerLoop:        
                    push cx                         ; Preserve outer loop counter

                    lea  si, keys             ; Set SI to the beginning of the key buffer
  innerLoop:        
                    mov  ax, [si]                   ; Load current key
                    cmp  ax, [si+2]                 ; Compare current key with the next key
                    jl   nextStep                   ; If less, proceed to the next step

                    xchg [si+2], ax                 ; Swap keys
                    mov  [si], ax
  nextStep:         
                    add  si, 2                      ; Move to the next key
                    loop innerLoop                  ; Repeat until inner loop counter is zero

                    pop  cx                         ; Restore outer loop counter
                    loop outerLoop                  ; Repeat until outer loop counter is zero

  ; Store the number of sorted keys
  ; Now output the sorted keys
                    mov  si, offset keys      ; Set SI to the beginning of sorted keys (in keyBuffer)
                    mov  cx, 8                      ; Number of keys to output (assuming 8 keys)

  output_loop:      
                    mov  ax, [keys]            ; Load key for output from keyBuffer
                    add  dl, '0'                    ; Convert back to ASCII
                    mov  ah, 02h                    ; DOS function for displaying character
                    int  21h                        ; Display character

  ; Debugging output to verify the content of the sortedKeys buffer (optional)
                    mov  dl, ','                    ; Delimiter for debugging output
                    int  21h                        ; Display delimiter

                    inc  si                         ; Move to next key in keyBuffer
                    dec  cx                         ; Decrement the count of keys to output
                    jnz  output_loop                ; Repeat until all keys are printed

  exit_program:     
  ; Terminate program
                    mov  ax, 4c00h
                    int  21h

main endp
end main


main endp
end main
