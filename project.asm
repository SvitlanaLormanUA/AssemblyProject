.model small
.stack 100h

.data
    filename    db  'input.in', 0
    buffer_size equ 64
    buffer      db  buffer_size dup(?)

.code
main proc
                mov  ax, @data
                mov  ds, ax

    ; Відкриття файлу для читання
                mov  ah, 3Dh            ; Функція для відкриття файлу
                lea  dx, filename       ; Адреса рядка з ім'ям файлу
                int  21h                ; Виклик DOS сервісу

    ; Перевірка на помилку при відкритті файлу
                jc   file_error

                mov  bx, ax             ; Збереження дескриптора файлу в bx

    ; Читання даних з файлу в стек
    read_loop:  
                mov  ah, 3Fh            ; Функція для читання з файлу
                mov  cx, buffer_size    ; Розмір буфера
                lea  dx, buffer         ; Адреса буфера
                int  21h                ; Виклик DOS сервісу

    ; Перевірка на кінець файлу
                jz   end_reading

    ; Занесення даних у стек
                push dx
                jmp  read_loop

    end_reading:
    ; Закриття файлу
                mov  ah, 3Eh            ; Функція для закриття файлу
                int  21h                ; Виклик DOS сервісу

    ; Сортування даних у стеку
                mov  si, sp             ; Адреса стеку
                mov  di, sp             ; Копіюємо адресу стеку в di для порівняння
    sort_loop:  
                mov  cx, buffer_size    ; Розмір стеку
                mov  ax, di             ; Починаємо порівнювати з першим елементом
                add  ax, 2              ; Порівнювати з наступним елементом
    inner_loop: 
                mov  bx, ax
                mov  dl, [bx]
                cmp  dl, [bx-2]
                jae  not_swap
                mov  al, [bx]
                xchg al, [bx-2]
                mov  [bx], al
    not_swap:   
                sub  ax, 2
                cmp  ax, si
                jne  inner_loop
                sub  di, 2
                cmp  di, si
                jne  sort_loop

    ; Виведення відсортованого стеку
    print_loop: 
                mov  ah, 02h            ; Функція для виведення на екран
                pop  dx                 ; Поп зі стеку
                int  21h                ; Виклик DOS сервісу
                cmp  sp, si             ; Перевірка на кінець стеку
                jnz  print_loop

    ; Вихід з програми
                mov  ah, 4Ch            ; Функція для завершення програми
                int  21h                ; Виклик DOS сервісу

    file_error: 
    ; Обробка помилки при відкритті файлу
    ; Додайте відповідні дії тут

main endp
end main
