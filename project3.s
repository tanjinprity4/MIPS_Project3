.data
	stringfromUser: .space 10000
	Stringisemptiness: .asciiz "Input is emptiness."
	StringisInvalid: .asciiz "Invalid base-36 number."
	long_entry: .asciiz "Input is too long."
.text                           # Assembly language instructions
main:
	li $v0, 8  #  Taking in input
	la $a0, stringfromUser  #  load byte space into address
	li $a1, 10000  #  allot the byte space for string
	syscall
	move $t0, $a0  #  move user input to $t0
	move $t7, $a0  #  move user input in another register, $t7 for later
	
check_emptiness:
	lb $a0, 0($t0)
	beq $a0, 10, emptiness
	j firstLoop
	
emptiness:
	li $v0, 4  		# for printing string
	la $a0, Stringisemptiness
	syscall
	j exit
	
	li $t2, 0		#$t2 will be used for length of characters
	li $t4, -10		
	li $t3, 0		#$t3 will count space
	li $s0, -1 		# check if valid
	li $s1, 0  		# total valid characters
	
firstLoop:
	lb $a0, 0($t0)
	beq $a0, 10, calculate_value_in_loop 	#if linefeed found, calculate_value_in_loop starts
	addi $t0, $t0, 1		
	slti $t1, $a0, 123        #if value in $a0 less than 123, char valid or $t1 = 1
	beq $t1, $zero, invalid_or_not
	beq $a0, 32, space
	slti $t1, $a0, 48
	bne $t1, $zero, invalid_or_not
	slti $t1, $a0, 58
	bne $t1, $zero, digit_value
	slti $t1, $a0, 65
	bne $t1, $zero, invalid_or_not
	slti $t1, $a0, 91 
	bne $t1, $zero, char_upper
	slti $t1, $a0, 97 
	bne $t1, $zero, invalid_or_not
	slti $t1, $a0, 123
	bne $t1, $zero, char_lower
	j firstLoop
space:
	beq $t2, 0, firstLoop
	beq $t4, 1, valid_char_or_not
	beq $t4, 0, check_spaces
	j firstLoop
	
check_spaces:
	addi $t3, $t3, 1  
	j firstLoop

valid_char_or_not:
	li $t4, 0
	addi $t3, $t3, 1  
	j firstLoop
	
invalid_or_not:
	li $s0, -1
	addi $t2, $t2, 1  
	bne $t2, 1, check_prev 
	li $t4, 1 
	j firstLoop
	
digit_value:
	addi $s1, $s1, 1  
	addi $t2, $t2, 1  
	bne $t2, 1, check_prev 
	li $t4, 1 
	j firstLoop
	
char_upper:
	addi $s1, $s1, 1  
	addi $t2, $t2, 1  
	bne $t2, 1, check_prev
	li $t4, 1
	j firstLoop

char_lower:
	addi $s1, $s1, 1  
	addi $t2, $t2, 1  
	bne $t2, 1, check_prev
	li $t4, 1
	j firstLoop

check_prev:
	beq $t4, 0, space_between_valid_chars 
	j firstLoop

space_between_valid_chars:
	li $s0, -1
	add $t2, $t2, $t3 
	li $t3, 0  
	li $t4, 1  
	j firstLoop

invalid:

	li $v0, 4  
	la $a0, StringisInvalid
	syscall
	j exit

calculate_value_in_loop:

	li $a1, 36 
	li $a2, 46656  
	li $a3, 4  
	li $t8, 0 

    move $t0, $t7  
    beq $t2, 0, emptiness

    slti $t1, $t2, 5  
    beq $t1, $zero, print_error_long

    beq $s0, -1, invalid 
    slti $t1, $s1, 4 
    bne $t1, $zero, conver_small_values

calculation_and_conversion:
    lb $a0, 0($t0)
    beq $a0, 10, print_value 
    addi $t0, $t0, 1  

    slti $t1, $a0, 123 
    beq $t1, $zero, invalid

    beq $a0, 32, calculation_and_conversion

    slti $t1, $a0, 48  
    bne $t1, $zero, invalid

    slti $t1, $a0, 58  
    bne $t1, $zero, digit_conversion

    slti $t1, $a0, 65 
    bne $t1, $zero, invalid

    slti $t1, $a0, 91  
    bne $t1, $zero, upper_conversion

    slti $t1, $a0, 97  
    bne $t1, $zero, invalid

    slti $t1, $a0, 123 
    bne $t1, $zero, lower_conversion

    j calculation_and_conversion

upper_conversion:
    addi $a0, $a0, -55
    mult $a0, $a2
    mflo $t9
    add $t8, $t8, $t9
    div $a2, $a1
    mflo $a2
    j calculation_and_conversion


lower_conversion:
    addi $a0, $a0, -87
    mult $a0, $a2
    mflo $t9
    add $t8, $t8, $t9
    div $a2, $a1
    mflo $a2
    j calculation_and_conversion

digit_conversion:
    addi $a0, $a0, -48 
    mult $a0, $a2  
    mflo $t9
    add $t8, $t8, $t9  
    div $a2, $a1
    mflo $a2 
    j calculation_and_conversion

conver_small_values:
    sub $t5, $a3, $s1

small_value_loop:
    beq $t5, 0, calculation_and_conversion
    addi $t5, $t5, -1
    div $a2, $a1
    mflo $a2
    j small_value_loop

print_value:
    li $v0, 1
    addi $a0, $t8, 0
    syscall
    j exit

print_error_long:
    li $v0, 4  
    la $a0, long_entry
    syscall



	
exit:
	li $v0, 10                  
	syscall
