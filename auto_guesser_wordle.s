.equ words_count, 11454 # actual number of words in the text file
# .equ len, 8 # each word has 5 characters and \0 at the end
.equ len, 12
.equ saved_space, 200000 # saving up space for an array containing all words in the file

.data
    secret: .space 6
    guess: .space 6 
    feedback: .space 6 
    guessed: .asciz "GGGGG"
    message: .asciz "Type here the secret word :"
    congrats: .asciz "Congratulations! You have guessed the wordle of the day!"
    try: .asciz "Your attempt :"

    G: .long 71 # ascii code for G
    Y: .long 89 # ascii code for Y
    dot: .long 46 # ascii code for .

    input: .string "%5s" 
    attempt: .string "%s\n"
    fb: .string "Feedback : %s\n"

    path: .asciz "cuvinte_wordle.txt" # this is the full path to the text file with words (it is in the same directory) 
    mode: .asciz "r" # need to open this file in reading mode (using string "r" to define just that)
    line_buffer: .space 100 # each line contains a 5 character word plus "\0" plus "\n"
    counter: .long 0 # how many words i have read yet
    words: .space saved_space
    status: .space words_count

.text

.global main
.extern scanf
.extern printf

.extern fopen
.extern fclose
.extern fgets

verify:
        movl $0, %ecx 
    rep_loop:
        cmpl $5, %ecx
        je et_fin

        movzbl secret(%ecx), %eax
        movzbl guess(%ecx), %ebx
        cmpb %al,%bl
        je addG
            yellow:
                movl $0, %edx 
            yellow_loop:
                cmpl $5, %edx
                je addDot
                movzbl secret(%edx), %eax
                cmpb %al, %bl
                jne inclD
            addY:
                movb $'Y', feedback(%ecx)
                jmp inclC
    inclD:
        incl %edx
        jmp yellow_loop
    addG:
        movb $'G', feedback(%ecx) 
        jmp inclC
    addDot:
        movb $'.', feedback(%ecx) 
    inclC:
        incl %ecx
        jmp rep_loop
    et_fin:
        movb $0, feedback+5 
        ret

equality: # method checks whether the guess is the same as the secret number

    pushl %ebp
    movl %esp, %ebp
    movl 8(%ebp), %edi
    movl 12(%ebp), %esi

    repeat:
    movb (%edi), %al
    movb (%esi), %bl

    cmpb %al, %bl
    jne not_equal

    cmpb $0, %al
    je done

    incl %edi
    incl %esi

    jmp repeat
not_equal:
    movl $1, %eax
    popl %ebp
    ret
done:
    movl $0, %eax
    popl %ebp
    ret

apply_feedback_on_word:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi

    movl 8(%ebp), %ecx   
    
    movl %ecx, %ebx
    imull $12, %ebx
    leal words(%ebx), %esi  

    movl $0, %edx  

check_positions:
    cmpl $5, %edx
    je keep_word   

    movzbl feedback(%edx), %eax    
    movzbl guess(%edx), %ebx        
    
    cmpb $'G', %al
    je must_match_green

    cmpb %bl, (%esi, %edx, 1)   
    je kill_word               
    jmp next_pos

must_match_green:
    
    cmpb %bl, (%esi, %edx, 1)  
    jne kill_word              
    jmp next_pos

kill_word:
    movb $0, status(%ecx)
    jmp done_filtering

next_pos:
    incl %edx
    jmp check_positions

keep_word:
    # nothing happens, the status will just remain 1
done_filtering:
    popl %edi
    popl %esi
    popl %ebx
    popl %ebp
    ret

main:

    pushl $mode
    pushl $path
    call fopen
    addl $8, %esp

    cmpl $0, %eax
    je et_exit           

    movl %eax, %esi     
    movl $0, %ecx        
read_loop:
    pushl %ecx        
    
    pushl %esi           
    pushl $8             
    pushl $line_buffer
    call fgets
    addl $12, %esp

    popl %ecx          

    cmpl $0, %eax       
    je done_reading

    movl %ecx, %ebx
    imull $12, %ebx     
    movl $0, %edx        

copy_loop:
    cmpl $5, %edx
    je finish

    movzbl line_buffer(%edx), %eax
    movb %al, words(%ebx, %edx, 1)

    incl %edx
    jmp copy_loop

finish:
    movb $0, words(%ebx,%edx,1) 
    movb $1, status(%ecx)       
    incl %ecx
    jmp read_loop
    
done_reading:
    pushl %esi
    call fclose
    addl $4, %esp

    movl $4, %eax
    movl $1, %ebx
    movl $message, %ecx
    movl $28, %edx
    int $0x80

    movl $3, %eax
    movl $0, %ebx
    movl $secret, %ecx
    movl $6, %edx
    int $0x80

    movb $0, secret+5

guess_loop:
    movl $0, %ecx
find_word:
    cmpl $words_count, %ecx
    je et_exit                  
    
    movzbl status(%ecx), %eax
    cmpb $1, %al
    je found_candidate          
    incl %ecx
    jmp find_word

found_candidate:
    movl %ecx, %ebx
    imull $12, %ebx            
    
    movl $0, %edi
copy_to_guess:
    cmpl $6, %edi
    je do_verification
    movb words(%ebx, %edi, 1), %al
    movb %al, guess(%edi)
    incl %edi
    jmp copy_to_guess

do_verification:

    pushl $guess
    pushl $attempt
    call printf
    addl $8, %esp

    movl $guess, %edi
    movl $secret, %esi
    pushl %esi
    pushl %edi
    call equality        
    addl $8, %esp
    
    cmpl $0, %eax
    je et_exit           

    call verify
    
    pushl $feedback
    pushl $fb
    call printf
    addl $8, %esp

    movl $0, %ecx        
filter_all_words:
    cmpl $words_count, %ecx
    je guess_loop        

    movzbl status(%ecx), %eax
    cmpb $1, %al
    jne skip_this_word

    pushl %ecx
    call apply_feedback_on_word
    popl %ecx

skip_this_word:
    incl %ecx
    jmp filter_all_words

et_exit:
    movl $4, %eax
    movl $1, %ebx
    movl $congrats, %ecx
    movl $57, %edx
    int $0x80

    movl $0, %eax
    ret

    