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

    jmp  process_lines         ; Jump to process lines

  checking_eof:     
    ; Check end of file
    mov  ah, 3Eh               ; DOS function for checking EOF
    mov  bx, 0                 ; File handle (0 = standard input)
    int  21h                   ; DOS interrupt

    ; If EOF pointer is not equal to 128 (0x80), file has ended
    cmp  ax, 80h
    je   process_lines         ; If not EOF, proceed to process lines
                  
    ; Otherwise, exit the program

process_lines:
    mov  si, offset buffer     ; Set SI to the beginning of the buffer
    mov  di, offset keys       ; Set DI to the beginning of the keys array
    mov  bx, offset values     ; Set BX to the beginning of the values array
    mov  cx, 128               ; Initialize CX with the length of the buffer

read_and_store:
    mov  al, [si]              ; Load the character
    mov  [di], al              ; Store the character in the keys array
    inc  di                    ; Move to the next position in the keys array

    inc  si                    ; Move to the next character
    mov  al, [si]              ; Load the character
    mov  [bx], al              ; Store the character in the values array
    inc  bx                    ; Move to the next position in the values array

    inc  si                    ; Move to the next character
    loop read_and_store        ; Repeat until CX != 0

    jmp  convert_values_to_hex ; Proceed to convert values to hexadecimal

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
    ; Initialize variables
    mov  cx, keyCount               ; Initialize CX with the count of keys
    mov  si, offset keys            ; Set SI to the beginning of the keys array
    mov  di, offset values          ; Set DI to the beginning of the values array

    ; Loop through the keys
calculate_average_loop:
    mov  ax, [di]                   ; Load value from values array
    add  [si + 2], ax               ; Add value to corresponding key's sum
    add  di, 2                      ; Move to next value
    add  si, 4                      ; Move to next key and average slot
    loop calculate_average_loop     ; Repeat until all keys are processed

    ; Now calculate the average for each key
    mov  cx, keyCount               ; Reload CX with the count of keys
    mov  si, offset keys            ; Reset SI to the beginning of the keys array

calculate_average_avg:
    mov  ax, [si + 2]               ; Load sum of values for the key
    div  cx                          ; Divide sum by count to get average
    mov  [si + 2], ax                ; Store the average back to the keys array
    add  si, 4                       ; Move to next key and average slot
    loop calculate_average_avg      ; Repeat until all keys are processed

   
  ;bubble sort
  
  mov  si, offset keys      ; Set SI to the beginning of the key buffer
  mov  cx, keyCount         ; Number of keys to process
  dec  cx                   ; Set to count - 1 for loop control

outerLoop:
  push cx                   ; Preserve outer loop counter

  lea  si, keys             ; Set SI to the beginning of the key buffer
  lea  di, keys + 4         ; Set DI to the next key for comparison
  mov  cx, keyCount - 1     ; Number of key pairs to compare

innerLoop:
  mov  ax, [si]             ; Load current key's average
  mov  bx, [di]             ; Load next key's average
  cmp  ax, bx               ; Compare averages
  jge  nextPair             ; If current average is greater or equal, proceed to the next pair

  ; Swap keys
   mov ax, [si]           ; Load current key into AX
  mov bx, [di]           ; Load next key into BX
  mov [si], bx           ; Store next key in current key's place
  mov [di], ax           ; Store current key in next key's place

  mov ax, [si+2]         ; Load corresponding count of current key into AX
  mov bx, [di+2]         ; Load corresponding count of next key into BX
  mov [si+2], bx         ; Store next key's count in current key's place
  mov [di+2], ax         ; Store current key's count in next key's place

nextPair:
  add  si, 4                ; Move to the next pair
  add  di, 4                ; Move to the next pair
  loop innerLoop            ; Repeat until all key pairs are compared

  pop  cx                   ; Restore outer loop counter
  loop outerLoop            ; Repeat until outer loop counter is zero

  ; Store the number of sorted keys
  ;  output the sorted keys
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
