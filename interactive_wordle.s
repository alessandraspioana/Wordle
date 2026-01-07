# in this file you will find the wordle game in interactive mode 
# the user types in a secret name and then pursues to guess it
# updates are to be expected in order to generate a random word to be guessed entirely by the user+
# this game allows the user to use non existent words
# example "aaaaa" is still a valid word
# the game is case sensitive si it will NOT work for upper case or lower case depending on the input


.equ words, 11454 # actual number of words in the text file
.equ len, 6 # each word has 5 characters and \0 at the end
.equ saved_space, words*len # saving up space for an array containing all words in the file

.data
    secret: .space 6
    guess: .space 6 
    feedback: .space 6 
    guessed: .asciz "GGGGG"
    message: .asciz "Type here the secret word :"
    congrats: .asciz "Congratulations! You have guessed the wordle of the day!"
    try: .asciz "Your attempt :"

    input: .string "%5s" 
    attempt: .string "%s\n"
    fb: .string "Feedback : %s\n"
    buffer: .space 6     

    path: .asciz "cuvinte_wordle.txt" # this is the full path to the text file with words (it is in the same directory) 
    mode: .asciz "r" # need to open this file in reading mode (using string "r" to define just that)
    size_line: .long 7 # each line contains a 5 character word plus "\0" plus "\n"
    counter: .long 0 # how many words i have read yet

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
equality:

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


main:

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

    guess_loop:

    movl $4, %eax
    movl $1, %ebx
    movl $try, %ecx
    movl $15, %edx
    int $0x80

    pushl $guess
    pushl $input
    call scanf
    addl $8, %esp

    call verify

    pushl $feedback
    pushl $fb
    call printf
    addl $8, %esp

    pushl $feedback
    pushl $guessed 
    call equality
    addl $8, %esp

    cmpl $0, %eax
    je et_exit
    jne guess_loop

et_exit:

    movl $4, %eax
    movl $1, %ebx
    movl $congrats, %ecx
    movl $57, %edx
    int $0x80

    movl $0, %eax
    ret

    