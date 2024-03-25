.model small
.stack 100h

.data
oneChar db 0
presInd dw 0
newInd dw 0
keys db 10000*16 dup(0) ;buffer for keys
keyTemp db 16 dup(0) ;temporarily biffer to store keys from the beginning
keyTempInd dw 0
isWord db 1
values dw 10000 dup(0)
number db 16 dup(0)
numberInd dw 0
quantity dw 3000 dup(0)

.code
main proc
    mov ax, @data
    mov ds, ax

;read stdin and put characters into keyTemp or number
read_next:
    mov ah, 3Fh
    mov bx, 0  ; file handle
    mov cx, 1   ; 1 byte to read
    mov dx, offset oneChar   ; read to ds:dx 
    int 21h   ;  ax = number of bytes read
    ; do something with [oneChar]

    ;save ax
    push ax

    call procChar ;process char
pop ax
    or ax,ax
    jnz read_next
;remove last char in number
    mov si, offset number
    dec numberInd
    add si, numberInd
    mov [si],0
    ;turn it into number
    call convInNum
 ;calculate average value
 call calcAverage   
 call sortArr
 call writeArrays

ending:
mov ax, 4C00h
    int 21h
main endp


procChar proc
    ; Compare the value of oneChar with the ASCII code for carriage return (CR)
    cmp oneChar, 0Dh
    jnz notCR  ; Jump if not equal to CR

    ; Change isWord to 1 if it's currently 0
    cmp isWord, 0
    jne endProc  ; Jump to end if isWord is not 0 (already 1)
    mov isWord, 1  ; Set isWord to 1
    call convInNum  ; Call the trnInNum procedure to process the character as a number
    jmp endProc  ; Jump to end

notCR:
    ; Compare oneChar with the ASCII code for line feed (LF)
    cmp oneChar, 0Ah
    jnz notLF  ; Jump if not equal to LF

    ; Change isWord to 1 if it's currently 0
    cmp isWord, 0
    jnz endProc  ; Jump to end if isWord is already 1
    mov isWord, 1  ; Set isWord to 1
    call convInNum  ; Call the trnInNum procedure to process the character as a number
    jmp endProc  ; Jump to end

notLF:
    ; Compare oneChar with space (ASCII code 20h)
    cmp oneChar, 20h
    jnz notSpace  ; Jump if not equal to space

    ; Set isWord to 0 since it's not a number
    mov isWord, 0
    ; Check if the entered character is part of a key
    call checkKey  ; Call checkKey procedure to handle key checking
    jmp endProc  ; Jump to end

notSpace:
    ; Check if isWord is 0
    cmp isWord, 0
    jnz itsWord  ; Jump if isWord is 1 (meaning the character is part of a word)

    ; Save the character to the number array
    mov si, offset number  ; Load address of number array
    mov bx, numberInd  ; Load current index in number array
    add si, bx  ; Move to the next position in the number array
    mov al, oneChar  ; Move the character to AL register
    mov [si], al  ; Save the character in the number array
    inc numberInd  ; Increment the index for the next character
    jmp endProc  ; Jump to end

itsWord:
    ; Save the character to the keyTemp array
    mov si, offset keyTemp  ; Load address of keyTemp array
    mov bx, keyTempInd  ; Load current index in keyTemp array
    add si, bx  ; Move to the next position in the keyTemp array
    mov al, oneChar  ; Move the character to AL register
    mov [si], al  ; Save the character in the keyTemp array
    inc keyTempInd  ; Increment the index for the next character

endProc:
    ret  
procChar endp  ; End of procChar procedure

convInNum PROC
    ; Initialize registers for number conversion
    xor bx, bx  ; Clear BX register (used for number storage)
    mov cx, 0   ; Clear CX register (used for iteration)

calcNum:
    ; Calculate the position of the next character in the number array
    mov si, offset number  ; Load address of number array
    add si, numberInd     ; Add the current index to get the last character of this number
    dec si                ; Move to the previous character
    sub si, cx            ; Adjust for the next character position

    ; Read the character
    xor ax, ax      ; Clear AX register
    mov al, [si]    ; Load the character into AL register

    ; Test if the character is '-'
    cmp ax, 45
    jnz notMinus  ; Jump if not a minus sign
        neg bx     ; Negate BX to turn it into a negative number
        jmp afterCalc  ; Jump to afterCalc

    notMinus:
    sub al, '0'  ; Convert the character into its numerical value

    ; Get the real number by multiplying it by 10
    push cx
    cmp cx, 0
    jnz notZer
    jmp endOFMul
    notZer:
    mulByTen:
    mov dx, 10
    mul dx
    dec cx
    cmp cx, 0
    jnz mulByTen

    endOFMul:
    pop cx
    add bx, ax  ; Add the current number to the result

    inc cx  ; Increment the counter
    cmp cx, numberInd  ; Compare with the number of digits
    jnz calcNum  ; Jump to calcNum if not all digits processed

afterCalc:
    ; Save the number into the values array
    mov si, offset values  ; Load address of values array
    mov ax, presInd  ; Load the index of the current number
    shl ax, 1  ; Calculate the real index in values array
    add si, ax  ; Add the real index to get the address in values array
    add bx, [si]  ; Add the previously saved number
    mov [si], bx  ; Save the new number into the values array

    ; Reset variables for the next number
    mov numberInd, 0  ; Reset the number index
    mov cx, 0         ; Reset the counter

    ; Fill the number array with zeros for the next number
    fillZeros:
    mov si, offset number  ; Load address of number array
    add si, cx  ; Move to the next position
    mov [si], 0  ; Fill with zero
    inc cx  ; Increment the counter
    cmp cx, 9  ; Check if all positions filled (up to 9 digits)
    jnz fillZeros  ; Jump to fillZeros if not all positions filled

ret  ; Return from the procedure
convInNum endp  ; End of trnInNum procedure


checkKey proc
    mov ax,0
    mov bx, 0; presence of key
    mov cx, 0
    mov dx,0
    ;check if keyInd is 0
    cmp newInd,0
    jnz findKey
jmp addNewKey  
    findKey:
    mov dx,0
        checkPresKey:
        mov si, offset keys
        shl cx, 4
        add si, cx
        shr cx,4
        add si, dx; next char offset
        mov al,[si]; next char
        mov di, offset keyTemp
        add di,dx
        mov ah, [di]; next char in keyTemp
        cmp al,ah
        jne notEqualChar
            mov bx,1; this char present in current key
            jmp contComp
            notEqualChar:
            mov bx,0; this char dont present in current key
            mov dx, 15; go to next key
        contComp:
            inc dx
            cmp dx,16
            jnz checkPresKey
        ;check if key is present   
    cmp bx,0
    jnz keyPresent 
    inc cx
    cmp cx, newInd
    jne findKey
 ;   new key
    ;add new key to key array
    mov cx, 0  ; counter
    addNewKey:
    
    mov si, offset keyTemp   ; addr of source
    add si, cx
    mov di, offset keys  ; addr of dest
    mov ax,  newInd
    shl ax,4 
    add di,cx
    add di, ax ; addr of dest
    mov al, [si]
    mov [di], al 
    inc cx
    cmp cx, 16
    jnz addNewKey
    mov cx, newInd
    mov presInd,cx
    inc newInd
     ; set new 1 to array of quantities
 ;add to quantity one
    mov si, offset quantity
    mov cx, presInd
    shl cx,1
    add si, cx
    mov ax,1
    mov [si],ax
    jmp endOfCheck;goto end

keyPresent:
    ;key index in cx
    ;add 1 to this index
    mov presInd,cx
    ;add to quantity one
    mov si, offset quantity
    mov cx, presInd
    shl cx,1
    add si, cx
    mov ax, [si]
    inc ax
    mov [si],ax
endOfCheck:
   ;fill temp key by 0
    mov keyTempInd,0
    mov cx,0
  fillZeroskey:
    mov si, offset keyTemp
    add si, cx
    mov [si],0
    inc cx
    cmp cx,15
    jnz fillZeroskey  
    ret
checkKey endp


calcAverage proc

mov cx,0;counter
calcAv:
mov si, offset values
shl cx,1
add si,cx; next number

mov di, offset quantity
add di, cx;present quantity of this number
shr cx,1
mov ax, [si]; mov number to ax
mov bx, [di]; mov quantity to dx
mov dx,0
div bx; get average of these numbers
mov [si], ax; put average to values
inc cx
cmp cx, newInd
jnz calcAv

ret
calcAverage endp

writeArrays proc
mov cx,0
makeString:
mov ax,0
mov presInd,ax
mov dx,0
push cx
    mov di, offset quantity
    shl cx,1
    add di,cx;get index of numbers
    mov cx, [di]
    writeKey:
    mov si, offset keys
    mov ax,0
    mov ax, cx; index of cell
    shl ax, 4; real index of cell
    add si, ax
    add si, presInd
    ;write char
    mov ah, 02h
    mov bx,dx; save counter to bx
    mov dl, [si]
    cmp dl, 0 

    jne notEndOfKey
        jmp gotoNewLine
    notEndOfKey:
    int 21h
    mov dx,bx
    inc presInd
    inc dx
    cmp dx, 16
    jnz writeKey
gotoNewLine:
;go to new line
    mov ah, 02h
mov dl, 0dh
int 21h
 mov ah, 02h
mov dl, 0ah
int 21h
;check if its not the last key-average
pop cx
inc cx
cmp cx, newInd
jnz makeString

ret
writeArrays endp

turnInChar proc
pop dx
pop bx; get index
shl bx,1
mov ax, [values+bx]; get in ax number
cmp ax, 10000 
jc positive ;Jump to positive if ax is less than 10000
    neg ax
positive:
shr bx, 1
push bx
push dx
mov cx,15;number ind
makeChar:
    mov dx,0
    mov bx,10
    div bx; remainder in dx, quontient in ax
    mov si, offset keyTemp
    add si, cx; location to write
    add dx, '0' ;Convert remainder to ASCII character
    mov [si], dl ; Store ASCII character in keyTemp
    cmp ax, 0
    jnz contSetNumb
        mov bx, 16
        mov numberInd, bx
        sub numberInd, cx
        jmp reverse_number
    contSetNumb:
    dec cx
    cmp cx, -1
    jne makeChar  
;we wrote number into chars
reverse_number:
mov cx, 16
sub cx, numberInd
mov dx,0
reverse:
    mov si, offset keyTemp
    add si, cx ;Move to the location in keyTemp
    mov di, offset number
    add di, dx
    mov al,[si] ;Load character from keyTemp into al
    mov [di], al ;Store character in number
    inc dx
    inc cx
    cmp cx,16
    jnz reverse
ret
turnInChar endp

addMinus proc
mov bx,cx
shl bx,1
mov ax, [values+bx]; get in ax number
cmp ax, 10000
jc positiveVal
    mov ah,02h
    mov dl, '-' ;Print '-' using DOS interrupt 21h
    int 21h
positiveVal:
ret
addMinus endp

sortArr proc
pop dx; save address
;set array of pointers
mov cx,0
fillArrayFinal:

    
    mov di, offset quantity
    shl cx,1 ; Multiply cx by 2 (index calculation)
    add di,cx
    shr cx,1    
    mov [di],cx;mov to quantity address of next value
    inc cx
    cmp cx, newInd
    jnz fillArrayFinal

;sort array of pointers
mov cx, word ptr newInd
    dec cx  ; count-1
outerLoop:
    push cx
    lea si, quantity
innerLoop:
    mov ax, [si];get index
    push ax; remember index of numb
    shl ax,1; get index in values
    add ax,offset values;get address of values
    mov di, ax
    mov ax, [di]
    mov bx, [si+2];get next index
    push bx; remember index of next numb
    shl bx,1; get next index in values
    add bx,offset values
   mov di, bx
    mov bx, [di]
    cmp ax, bx;compare value with next value
    pop bx
    pop ax
    jg nextStep
    xchg bx, ax
    mov [si], ax
    MOV [si+2],bx
nextStep:
    add si, 2
    loop innerLoop
    pop cx
    loop outerLoop
push dx
ret
sortArr endp
end main
