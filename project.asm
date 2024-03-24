.model small
.stack 100h

.data

mesBad      db "File error $"
handle      dw 0

buffInd     db 0                 ; Index to keep track of the current position in buffer
oneChar     db 0

keys        db 5000*16 dup(0)
keyInd      dw 0
isWord      db 1
values      db 5000*16 dup(0)
valInd      dw 0

.code
main proc
    mov ax, @data
    mov ds, ax
    jmp read_next
     jc error                    ; Call routine to handle errors

    mov [handle], ax            ; Save file handle for later
; Read file and put characters into buffer
read_next:
    mov ah, 3Fh                 ; DOS Read File function number

    mov bx, 0                   ; File handle

    mov bx, 0           ; File handle

    mov cx, 1                   ; 1 byte to read
    mov dx, offset oneChar      ; Read to ds:dx 
    int 21h                     ; AX = number of bytes read

    push ax                     ; Preserve ax
    call procChar               ; Process the read character
    pop ax                      ; Restore ax

    or ax, ax                   ; Check if ax is zero (end of file)
    jnz read_next               ; If not zero, continue reading

    ; Clean values last number
    mov si, offset values
    mov bx, valInd
    dec bx
    add si, bx
    mov al, 0
    mov [si], al

    ; Convert values to hexadecimal
    jmp convert_values_to_hex

error:
    mov ah, 09h                 ; DOS Display String function number
    mov dx, offset mesBad
    int 21h                     ; Display error message


procChar proc
    cmp oneChar, 0Dh            ; Check if carriage return
    jnz notCR                   ; If not CR, jump to notCR
    mov isWord, 1               ; Change isWord to 1
    jmp endProc

notCR:
    cmp oneChar, 0Ah            ; Check if line feed
    jnz notLF                   ; If not LF, jump to notLF
    mov isWord, 1               ; Change isWord to 1
    jmp endProc

notLF:
    cmp oneChar, 20h            ; Check if space
    jnz notSpace                ; If not space, jump to notSpace
    mov isWord, 0               ; Change isWord to 0
    jmp endProc

notSpace:
    cmp isWord, 0               ; Check if isWord is 0
    jnz itsWord                 ; If not 0, jump to itsWord
    ; Save char to values
    mov si, offset values
    mov bx, valInd
    add si, bx
    mov al, oneChar
    mov [si], al
    inc valInd
    jmp endProc

itsWord:
    ; Save char to keys
    mov si, offset keys
    mov bx, keyInd 
    add si, bx
    mov al, oneChar
    mov [si], al
    inc keyInd 

endProc:
    ret
procChar endp   

convert_values_to_hex:
    ; Convert values to hexadecimal
    mov  cx, valInd             ; Initialize CX with the count of values
    mov  si, offset values      ; Set SI to the beginning of the values array
    mov  di, offset values      ; Set DI to the beginning of the values array

convert_values_to_hex_loop:
    mov  al, [si]   

    cmp al, 0
    je skip_conversion  
    mov cl, al
    mov ax, 0                   ; Clear AX (get rid of HO bits)

  cmp al, 0
  je skip_conversion  
    mov cl, al
     mov ax, 0                   ; Clear AX (get rid of HO bits)

    mov cl, al             ; Load the value
    call ascii_hex              ; Convert the value to hexadecimal
    mov  [di], al               ; Store the hexadecimal character in the values buffer
  skip_conversion:

    inc si  ; Move to the next element in the buffer even if skipped
    inc di  ; Move the destination pointer for the next conversion
    loop convert_values_to_hex_loop                  ; Move to the next position in the values array

  inc si  ; Move to the next element in the buffer even if skipped
  inc di  ; Move the destination pointer for the next conversion
loop convert_values_to_hex_loop                  ; Move to the next position in the values array


    ; Calculate average
    jmp calculate_average

ascii_hex:
    MOV BX, 16                  ; Set up the divisor (base 16)
    MOV CX, 0                   ; Initialize the counter
    MOV DX, 0                   ; Clear DX

Div2:                                               ; Dividend (what's being divided) in DX/AX pair, Quotient in AX, Remainder in DX.
    DIV BX                      ; Divide (will be word sized).
    PUSH DX                     ; Save DX (the remainder) to stack.

    ADD CX, 1                   ; Add one to counter
    MOV DX, 0                   ; Clear Remainder (DX)
    CMP AX, 0                   ; Compare Quotient (AX) to zero
    JNE Div2                    ; If AX not 0, go to "Div2:"
getHex2:
    MOV DX, 0                   ; Clear DX.
    POP DX                      ; Put top of stack into DX.
    ADD DL, 30h                 ; Conv to character.

    CMP DL, 39h
    JG MoreHex2

HexRet2:        
    LOOP getHex2                ; If more to do, getHex2 again
                                ; LOOP subtracts 1 from CX. If non-zero, loop.
    JMP Skip2
MoreHex2:
    ADD DL, 7h
    JMP HexRet2                 ; Return to where it left off before adding 7h.
Skip2:
    RET

calculate_average:
    ; Initialize variables
    mov  cx, keyInd             ; Initialize CX with the count of keys
    mov  si, offset keys        ; Set SI to the beginning of the keys array

calculate_average_loop:
    mov  ax, [si]               ; Load value from keys array
    add  [si + 2], ax           ; Add value to corresponding key's sum
    add  si, 4                  ; Move to next key and average slot
    loop calculate_average_loop ; Repeat until all keys are processed

    ; Now calculate the average for each key
    mov  cx, keyInd             ; Reload CX with the count of keys
    mov  si, offset keys        ; Reset SI to the beginning of the keys array

calculate_average_avg:
    mov  ax, [si + 2]           ; Load sum of values for the key
    div  cx                      ; Divide sum by count to get average
    mov  [si + 2], ax            ; Store the average back to the keys array
    add  si, 4                   ; Move to next key and average slot
    loop calculate_average_avg   ; Repeat until all keys are processed

    ; ---------------- IN CASE MERGE SORT DOES NOT WORK, BUBBLE SORT IS COMMENTED HERE ----------------------
; Bubble sort
 
   ; mov  si, offset keys        ; Set SI to the beginning of the keys array
  ;  mov  cx, keyInd             ; Number of keys to process
 ;   dec  cx                     ; Set to count - 1 for loop control

;outerLoop:
;    push cx                     ; Preserve outer loop counter

   ; lea  si, keys               ; Set SI to the beginning of the keys array
  ;  lea  di, keys + 4           ; Set DI to the next key for comparison
 ;   mov  cx, keyInd - 1         ; Number of key pairs to compare

;innerLoop:
    ;mov  ax, [si + 2]           ; Load current key's average
    ;mov  bx, [di + 2]           ; Load next key's average
    ;cmp  ax, bx                 ; Compare averages
    ;jge  nextPair               ; If current average is greater or equal, proceed to the next pair

    ; Swap keys
    ;mov  ax, [si]               ; Load current key into AX
    ;mov  bx, [di]               ; Load next key into BX
    ;mov  [si], bx               ; Store next key in current key's place
    ;mov  [di], ax               ; Store current key in next key's place

    ;mov  ax, [si + 2]           ; Load corresponding count of current key into AX
    ;mov  bx, [di + 2]           ; Load corresponding count of next key into BX
    ;mov  [si + 2], bx           ; Store next key's count in current key's place
   ; mov  [di + 2], ax           ; Store current key's count in next key's place

;nextPair:
    ;add  si, 4                  ; Move to the next pair
    ;add  di, 4                  ; Move to the next pair
    ;loop innerLoop              ; Repeat until all key pairs are compared

    ;pop  cx                     ; Restore outer loop counter
   ; loop outerLoop              ; Repeat until outer loop counter is zero

    ; Output the sorted keys
  ;  mov  si, offset keys        ; Set SI to the beginning of sorted keys
 ;   mov  cx, keyInd             ; Number of keys to output

;output_loop:      
    ;mov  ax, [si]               ; Load key for output
    ;add  dl, '0'                ; Convert back to ASCII
    ;mov  ah, 02h                ; DOS function for displaying character
    ;int  21h                    ; Display character

    ; Debugging output to verify the content of the sorted keys buffer (optional)
    ;mov  dl, ','                ; Delimiter for debugging output
    ;int  21h                    ; Display delimiter

    ;add  si, 4                  ; Move to next key
    ;loop output_loop            ; Repeat until all keys are printed

    ;jmp  exit_program           ; Terminate program


;-------------------TRYING OUT MERGE SORT--------------------
jmp merge
merge:
    
    push ax             ; Preserve registers
    push bx
    push cx
    push dx
    push si
    push di

    mov si, sp          ; SI points to the start of the stack frame
    add si, 4           ; SI now points to the size of the right half
    mov di, [si]        ; DI = Size of the right half
    add si, 2           ; SI now points to the middle index
    add si, 2           ; SI now points to the address of the right half
    mov bp, [si]        ; BP = Address of the right half
    add si, 2           ; SI now points to the size of the left half
    mov cx, [si]        ; CX = Size of the left half
    add si, 2           ; SI now points to the address of the left half
    mov ax, [si]        ; AX = Address of the left half

    ; Create temporary storage for merged array
    mov dx, cx          ; Copy size of left half
    add dx, di          ; Add size of right half
    push dx             ; Preserve the size of the merged array
    mov ah, 0           ; Clear AH for later use
    mov dl, 0           ; DL will be the index for the merged array
mergeLoop:
    cmp cx, 0           ; Check if left half is empty
    je  mergeRightDone ; If so, jump to mergeRightDone

    cmp di, 0           ; Check if right half is empty
    je  mergeLeftDone  ; If so, jump to mergeLeftDone

    mov al, [si]        ; Load value from left half into AL
    xor ax, ax          ; Clear AX (set it to zero)
    mov al, [si]        ; Load value from left half into AL again (to keep only lower 8 bits)
    mov bx, [bp]        ; Load value from right half into BX
    cmp ax, bx          ; Compare both values
    jle mergeLeft       ; If left value is less than or equal, jump to mergeLeft

mergeRight:
    mov [si], bx        ; Move value from right half to merged array
    add bp, 1           ; Move to next element in right half
    add si, 1           ; Move to next position in merged array
    sub di, 1           ; Decrease size of right half
    inc dl              ; Move index for merged array
    loop mergeLoop      ; Repeat loop
    jmp mergeLoop

mergeLeft:
    mov [si], al        ; Move value from left half to merged array
    add ax, 1           ; Move to next element in left half
    add si, 1           ; Move to next position in merged array
    sub cx, 1           ; Decrease size of left half
    inc dl              ; Move index for merged array
    loop mergeLoop      ; Repeat loop

mergeRightDone:
    pop dx              ; Restore size of merged array

mergeLeftDone:
    mov si, dx          ; SI points to size of merged array
    mov cx, si          ; CX = Size of merged array
    pop si              ; Restore base address of merged array

    pop di              ; Restore registers
    pop si
    pop cx
    pop bx
    pop ax

    ret



    jmp  exit_program           ; Terminate program


exit_program:
    mov ah, 4Ch               ; DOS Terminate Program function number
    int 21h                     ; Terminate program

main endp
end main