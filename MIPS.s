# Laura Tang
# countzeroes, ispalindrome, and countlocalmin

.text

countzeroes:
    li $t0, 0       # counter = 0
    li $t1, 0       # int i = 0

main_loop:                  # counts 1s
    bge $t1, 32, main_exit  # exit loop if i>= 32
    andi $t2, $s0, 1        # bit = input & 1
    beq $t2, $0, main_skip  # skip if bit is 0
    addi $t0, $t0, 1        # count++

main_skip:
    srl $s0, $s0, 1         # input = input >> 1
    add $t1, $t1, 1         # i++
    j main_loop

main_exit:
    sub $t0, $t0, 32        # subtract from 32 (negative)
    mul $t0, $t0, -1        # multiply by -1
    move $s0, $a0           # store input number
    move $v0, $t0           # store number of 0s

    jr $ra

###

ispalindrome:
    li $t0, 0          	    # load $t0 with constant 0

pointer_loop:               # loop to set pointer
    add $t1, $s0, $t0
    lb $t1, 0($t1)          
    beq $t1, $0, pointer_exit # exit when end pointer set
    addi $t0, $t0, 1
    j pointer_loop

pointer_exit:
    addi $t0, $t0, -1	    # decrement further pointer $t0
    move $v1, $t0
    add $v0, $t0, $s0
    move $t0, $v0
    li $v0, 0 	            # default ispalindrome to 0
    move $t2, $s0
    beq $v1, $0, pal_exit   # empty string

pal_loop:		    # loop until $t3 equals 0
    lb $t1, 0($t0)	    # $t1 contains what is at further pointer $t0
    lb $t3, 0($t2)	    # $t3 contains what is at closer pointer $t2
    beq $t3, $0, returnTrue # reached end, returns true or 1
    b pal_looptwo

pal_looptwo:
    bne $t1, $t3, pal_exit # $t1 and $t3 found not equal, exit
    addi $t0, $t0, -1	   # move further pointer $t0 back
    addi $t2, $t2, 1	   # move closer pointer $t2 forward
    j pal_loop

returnTrue:
    li $v0, 1		   # ispalindrome switched to 1
    j pal_exit

pal_exit:
    jr $ra

###

countlocalminima:
    li $t0, 0           # counter = 0
    move $s2, $a0       # s2: pointer to curr element for loop
    sll $s3, $a1, 2
    add $s3, $a0, $s3   # s3: pointer to end of array for loop

    # first iteration
    beq $s2, $s3, done  # check pointer overlap
    lw  $t1, 0($s2)     # first value into $t1
    addi $s2, $s2, 4    # move pointer
    beq $s2, $s3, done  # check pointer overlap
    lw $t2, 0($s2)      # second value into $t2
    j clm_looptwo       # jump to clm_looptwo for checks

clm_looptop:            # all other loops back to to here
    beq $s2, $s3, done  # check pointer overlap
    lw $t2, 0($s2)      # load value into $t2
    j clm_looptwo       # jump to clm_looptwo for checks

clm_looptwo:
    subu $t3, $t1, $t2      # subtract to see if there's a downslope
    bgtz $t3, down_slope    # branch if downslope (possible local min)
    move $t1, $t2           # if not, move $t2 value to $t1
    addi $s2, $s2, 4        # move pointer forward
    j clm_looptop           # loop back

down_slope:                 # testing for local min
    addi $s2, $s2, 4        # move pointer forward
    beq $s2, $s3, done      # check pointer overlap
    lw $t4, 0($s2)          # load value into $t4
    subu $t3, $t4, $t2      # subtract to see if there's an upslope
    bgtz $t3, up_slope      # local min found! branch to upslope
    bltz $t3, down_slope    # not local min, but next element possible
    beqz $t3, clm_looptop   # not local min, next element isn't either

up_slope:                   # local min found!
    addi, $t0, $t0, 1       # counter++
    move $t1, $0            # clear registers
    move $t2, $0
    move $t3, $0
    move $t4, $0
    j clm_looptop           # loop back

done:	                  # pointers overlapped, we're done
  	move $a0, $s0     # load up args
  	move $v0, $t0
	jr $ra
	
############ PLACE ALL OF YOUR FUNCTIONS ABOVE THIS LINE ############
	
.globl main
main:
	
	## First test case, should print:
	##    32
	##    31
 	li $a0, 32
 	jal test_countzeroes

	## Second test case, should print:
	##    232
	##    28
 	li $a0, 232
 	jal test_countzeroes

	## Third test case, should print:
	##    7
	##    29
 	li $a0, 7
 	jal test_countzeroes

	## First test case, should print:
	##    Hello
	##    0
	la $a0, text1
	jal test_ispalindrome

	## Second test case, should print:
	##    HellolleH
	##    1
	la $a0, text2
	jal test_ispalindrome

	## Third test case, should print:
	##    HelllleH
	##    1
	la $a0, text3
	jal test_ispalindrome

	## Fourth test case, should print:
	##    Helllleh
	##    0
     	la $a0, text4
	jal test_ispalindrome

	## First test case, should print:
	##    3 0 1 2 6 -2 4 7 3 7
	##    3
 	la $a0, array1
 	li $a1, 10
 	jal test_countlocalminima

	## Second test case, should print:
	##    3 0 1 2 6 -2
	##    1
 	la $a0, array2
 	li $a1, 6
 	jal test_countlocalminima

	## Third test case, should print:
	##    32 56 79 7 73 100 41 9 47 24 ...
	##    17
 	la $a0, array3
 	li $a1, 50
 	jal test_countlocalminima
	
	li $v0, 10         # Exit
	syscall

test_countzeroes:	
	addi $sp, $sp, -12
	sw $s0, 0($sp)	
	sw $s1, 4($sp)	
	sw $ra, 8($sp)
 	move $s0, $a0		
	jal countzeroes
	move $s1, $v0
	move $a0, $s0
	jal print_int
	jal print_newline
	move $a0, $s1
	jal print_int
	jal print_newline
	lw $s0, 0($sp)	
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
test_ispalindrome:	
	addi $sp, $sp, -12
	sw $s0, 0($sp)	
	sw $s1, 4($sp)	
	sw $ra, 8($sp)
 	move $s0, $a0		
	jal ispalindrome
	move $s1, $v0
	move $a0, $s0
	jal print_string
	jal print_newline
	move $a0, $s1
	jal print_int
	jal print_newline
	lw $s0, 0($sp)	
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra

test_countlocalminima:	
	addi $sp, $sp, -20
	sw $s0, 0($sp)	
	sw $s1, 4($sp)	
	sw $s2, 8($sp)	
	sw $s3, 12($sp)	
	sw $ra, 16($sp)
	move $s0, $a0		
	move $s1, $a1
	move $s2, $a0	  # s2: pointer to curr element for loop
	sll $s3, $a1, 2	  
	add $s3, $a0, $s3 # s3: pointer to end of array for loop
test_countlocalminima__looptop:	
	beq $s2, $s3, test_countlocalminima__loopdone
	lw  $a0, 0($s2)
	jal print_int
	addi $s2, $s2, 4
	j test_countlocalminima__looptop
test_countlocalminima__loopdone:
	jal print_newline
  	move $a0, $s0     # load up original args
  	move $a1, $s1
  	jal countlocalminima
  	move $a0, $v0
  	jal print_int
	jal print_newline
	lw $s0, 0($sp)	
	lw $s1, 4($sp)	
	lw $s2, 8($sp)	
	lw $s3, 12($sp)	
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra

print_newline:
	      la    $a0, newline
	      li    $v0, 4
	      syscall
	      jr    $ra
	
print_string: 
	      li    $v0, 4
	      syscall
	      jr    $ra

print_int:
	      li    $v0, 1
	      syscall
	      la    $a0, space
	      li    $v0, 4
	      syscall
	      jr    $ra

.data
text1:		.asciiz "Hello"
text2:		.asciiz "HellolleH"
text3:		.asciiz "HelllleH"
text4:		.asciiz "Helllleh"

array1:		.word 3, 0, 1, 2, 6, -2, 4, 7, 3, 7
array2:		.word 3, 0, 1, 2, 6, -2
array3:	        .word 32, 56, 79, 9, 73, 100, 41, 9, 47, 24, 77, 53, 30, 46, 96, 60, 84, 30, 64, 1, 55, 70, 45, 97, 42, 19, 98, 22, 80, 90, 13, 30, 48, 36, 20, 57, 32, 34, 7, 91, 17, 59, 91, 66, 26, 88, 73, 88, 57, 25
	
newline:	.asciiz "\n"
space:   	.asciiz " "
