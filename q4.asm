# Solution to question 4
# Author: Dan Farber
# Description: The program has an array of numbers stored in the form of bytes. It prints all the numbers divisible by 4 and 8 in reverse
# according to the requirements provided. It also prints the sum of all the numbers, treated as signed and unsigned, and the differences between
# every two adjacent numbers. It does all this in base 4, 8 and 10. Finally, it prints whether or not the array is an arithmetic sequence,
# it prints a message accordingly and if it is, it allows the user to select an index between 50 and 100 and prints the number at that index.


# Macros include printing a string, character and an integer.
.include "q4_macros.asm" 


################# Data Segment #####################
.data
number: .byte -8, -4, 0, 4, 8, 12, 16, 20, 24, 28
length: .word 10
base10_print: .asciiz "Printing in base 10:\n"
base4_print: .asciiz "\nPrinting in base 4:\n"
base8_print: .asciiz "\nPrinting in base 8:\n"

################# Code Segment #####################
.text
.globl main
# Throughout the entire program, a0 holds the address of the array, a1 holds the length of array and a2 has the base with which to print.
main:
	# Sections 1 to 5 in base 10
	print_str(base10_print)
	la $a0, number
	la $t0, length
	lw $a1, 0($t0)
	li $a2, 10
	jal sections_1_to_5
	
	# Sections 1 to 5 in base 4
	print_str(base4_print)
	la $a0, number
	la $t0, length
	lw $a1, 0($t0)
	li $a2, 4
	jal sections_1_to_5

	# Sections 1 to 5 in base 8
	print_str(base8_print)
	la $a0, number
	la $t0, length
	lw $a1, 0($t0)
	li $a2, 8
	jal sections_1_to_5
		
	# Section 8
	la $a0, number
	la $t0, length
	lw $a1, 0($t0)
	jal is_sequence
	
	# Section 9
	beqz $v0, exit
	la $a0, number
	jal get_number
	
exit:
	li $v0, 10
	syscall
	
################# Data Segment #####################
.data
space: .asciiz " " # Space to insert between numbers
question1_msg: .asciiz "The signed numbers divisible by 8 printed in reverse are: "
question2_msg: .asciiz "The unsigned numbers divisible by 4 printed in reverse are: "
question3_msg: .asciiz "The sum of the numbers in the array, treated as signed numbers is: "
question4_msg: .asciiz "The sum of the numbers in the array, treated as unsigned numbers is: "
question5_msg: .asciiz "The differences between the adjacent numbers are: "
sequence_msg: .asciiz "\nThe numbers in the array are an arithmetic sequence.\n"
not_sequence_msg: .asciiz "\nThe numbers in the array are NOT an arithmetic sequence.\n"
get_number_msg: .asciiz "\nEnter the index of the desired number in the sequence (50-100): "
invalid_number_msg: .asciiz "\nThe number you entered is incorrect!\n"
final_number_msg: .asciiz "\nThe number at the requested index is "

################# Code Segment #####################
.text
# $a0 - pointer to array, $a1 - length of array, $a2 - base to print in, $a3 - 0 for unsigned, 1 for signed.
# The last argument on the stack is the number to divide by.

get_number:
	addi $sp, $sp, 4
	sw $s0, 0($sp) # Stored in the stack since it is to be manipulated
	
	lb $t0, 0($a0)
	lb $t1, 1($a0)
	sub $s0, $t1, $t0 # The difference is stored into $s0
	
	print_str(get_number_msg)
	li $v0, 5 # Get number from user
	syscall
	
	move $t2, $v0
	blt $t2, 50, invalid_number # If number isn't within range, it's not correct
	bgt $t2, 100, invalid_number
	# The difference needs to be multiplied by (n-1) and added to the first value, where 'n' is the index number.
	addi $t2, $t2, -1
	mul $t2, $t2, $s0
	add $t0, $t0, $t2 # $t0 holds the final result
	print_str(final_number_msg)
	print_int($t0)
	print_char('\n')
	
	# Recover $s0 and restore stack
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra	
	
	# If invalid, prints a message and returns back to main.
invalid_number: 
	print_str(invalid_number_msg)
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra


# Returns 0 in $v0 if not sequence, otherwise returns a non-zero value. It also prints a message accordingly.
is_sequence:
	addi $sp, $sp, 4
	sw $s0, 0($sp)
	
	lb $t0, 0($a0)
	lb $t1, 1($a0)
	sub $s0, $t0, $t1 # The difference from left to right is stored into $s0
	addi $t1, $a0, 1 # $t1 points to second byte in the array
	add $t2, $a0, $a1 # Pointer to last byte
	add $t2, $t2, -1
	
is_sequence_loop:
	bge $t1, $t2, sequence_true # If reached the last byte - all differences were the same.
	lb $t3, 0($t1)
	lb $t4, 1($t1)
	sub $t3, $t3, $t4
	bne $t3, $s0, sequence_false # If the current difference doesn't equal the one stored before, then it's not a sequence
	addi $t1, $t1, 1
	j is_sequence_loop
	
	
sequence_false:
	print_str(not_sequence_msg) 
	li $v0, 0 # Returns false
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
sequence_true:
	print_str(sequence_msg) # $v0 holds the value 4 (!= 0)
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# This procedure iterates through an array and prints the differences between every two adjacent numbers in it. It always treats the numbers as signed.
difference_print:
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	sw $s0, 4($sp)
	sw $s1, 0($sp)
	
	move $s0, $a0 # Pointer to array
	add $s1, $a0, $a1 # Pointer to last byte
	add $s1, $s1, -1
		
difference_print_loop:
	bge $s0, $s1, difference_print_end # Iterate through array (until reaches the last byte)
	lb $a0, 0($s0)
	lb $t0, 1($s0)
	sub $a0, $a0, $t0 # Current difference stored in $a0
	jal gen_base # Prints the difference according to the base in $a2
	print_str(space)
	addi $s0, $s0, 1
	j difference_print_loop

	# When iteration is over, restores the stack and the values back to the registers
difference_print_end:
	print_char('\n')
	lw $ra, 12($sp)
	lw $a2, 8($sp)
	lw $s0, 4($sp)
	lw $s1, 0($sp)
	addi $sp, $sp, 16
	jr $ra

# This procedure calculates and prints the sum of the array. 
sum_print:
	# Values stores in the stack
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $s0, 4($sp)
	sw $s1, 0($sp)
	
	move $s0, $a0 # Pointer to array
	add $s1, $s0, $a1 # End of array
	li $t1, 0 # Holds sum
	
sum_print_loop:
	bge $s0, $s1, sum_print_end
	beqz $a3, sum_print_unsigned # If $a3 == 0 then prints as unsigned
	lb $t2, 0($s0) # Otherwise prints as signed
	j sum_print_continue
	
sum_print_unsigned:
	lbu $t2, 0($s0)
	
sum_print_continue:
	add $t1, $t1, $t2 # Calculating the sum in $t1
	add $s0, $s0, 1
	j sum_print_loop
	
sum_print_end:
	move $a0, $t1 # Sum is moved to $a0
	jal gen_base # Prints the sum
	print_char('\n')
	
	# Stack is restored
	lw $s1, 0($sp)
	lw $s0, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
	


# The procedure receives a number to print in $a0, and a base in $a2 to print in and prints the number accordingly.
gen_base:
	move $t0, $a0 # The value to print is moved to $t0
	beqz $t0, base10 # 0 in any base is 0 (edge case, otherwise prints -0)
	beq $a2, 10, base10 # If base is 10, print as is
	bgtz $t0, gen_base_continue # Check if positive
	print_char('-') # Negative
	abs $t0, $t0 # Turns to the absolute value
gen_base_continue:
	li $t1, 1 # Counter
	beq $a2, 8, base8
	li $t2, 3 # Mask for 2 LSBs (00..0011)
	li $t3, 2 # Number of bits to shift each iteration
	j base4or8
base8:
	li $t2, 7 # Mask for 3 LSBs (00..0111)
	li $t3, 3 # Number of bits to shift	
base4or8:
	li $t6, 0 # This will contain the final result
base4or8_loop:
	and $t4, $t0, $t2 # t4 holds the current digit
	mul $t5, $t4, $t1 
	add $t6, $t6, $t5 # Add to the final result
	srlv $t0, $t0, $t3
	beqz $t0, base4or8_loop_end
	mul $t1, $t1, 10
	j base4or8_loop
	
	# Once the loop ends, print the number
base4or8_loop_end:
	print_int($t6)
	j gen_base_end
base10:
	print_int($t0)
gen_base_end:
	jr $ra


# This procedure receives a pointer to a number to print in $a0, and an indicator in $a3 specifying whether it's signed or not.
base_print:
	addi $sp, $sp, -4
	sw $ra, 0($sp) # Save return address
	
	beqz $a3, base_print_unsigned
	lb $a0, ($a0) # Treats the number as signed
	j base_print_continue
base_print_unsigned:
	lbu $a0, ($a0) # Treats the number as unsigned
base_print_continue:
	jal gen_base
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
		
# This procedure receives an array ($a0), length of it ($a1), base to print in ($a2), indicator for signed or not ($a3).
# It assumes the number to divide by is pushed to the top of the stack. It prints all the numbers divisible by that number in reverse.
div_print:
	# Save for after the call to X function
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	sw $a0, 12($sp) 
	sw $a1, 8($sp) 
	sw $a2, 4($sp) 
	sw $s0, 0($sp) # Store the caller's s0
	add $s0, $a0, $a1 # Points to size of array + 1

div_print_loop:
	add $s0, $s0, -1
	blt $s0, $a0, div_print_end # Loops in reverse
	lbu $t0, 0($s0) # Both signed and unsigned divide by 4/8 or none of them do. Because if 2/3 LSBs are 0, they don't change by number's 2 complement. 
	lw $t1, 20($sp) # Retreive the number to divide by from the stack
	div $t0, $t1
	mfhi $t2
	bnez $t2, div_print_loop # If the number is not divisible, continue looping
	move $a0, $s0
	jal base_print # If it is divisible, prints it
	print_str(space)
	lw $a0, 12($sp)
	j div_print_loop
	
div_print_end:
	print_char('\n')
	lw $s0, 0($sp)
	lw $a2, 4($sp)
	lw $a1, 8($sp)
	lw $a0, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra
	
	
sections_1_to_5: 
	# Saving words in the stack
	addi $sp, $sp, -16
	sw $ra, 12($sp) # Save return address of main
	sw $a0, 8($sp) # Save address of array
	sw $a1, 4($sp) # Save length of array
	sw $a2, 0($sp) # Save base
	
	# Question 1
	# In a0 is the address of array, a1 has length, a2 has base.
	print_str(question1_msg)
	lw $a0, 8($sp)
	li $a3, 1 # Print as signed
	li $t0, 8 # Divide by 8
	addi $sp, $sp, -4
	sw $t0, 0($sp) # Push 8 to the stack
	jal div_print
	add $sp, $sp, 4 # Pop 8 off the stack
	
	# Question 2
	print_str(question2_msg)
	lw $a0, 8($sp)
	lw $a1, 4($sp) 
	lw $a2, 0($sp)
	li $a3, 0 # Print as unsigned
	li $t0, 4
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	jal div_print
	add $sp, $sp, 4
	
	# Question 3
	print_str(question3_msg)
	lw $a0, 8($sp)
	lw $a1, 4($sp) 
	lw $a2, 0($sp)
	li $a3, 1 # Print as signed
	jal sum_print
	
	# Question 4
	print_str(question4_msg)
	lw $a0, 8($sp)
	lw $a1, 4($sp) 
	lw $a2, 0($sp)
	li $a3, 0 # Print as unsigned
	jal sum_print
	
	# Question 5
	print_str(question5_msg)
	lw $a0, 8($sp)
	lw $a1, 4($sp) 
	lw $a2, 0($sp)
	jal difference_print
	
	
	# End of S1-5 function
	sw $a2, 0($sp)
	sw $a1, 4($sp)
	sw $a0, 8($sp)	
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	

