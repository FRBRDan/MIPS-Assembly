# Description: The program receives a number between -9999 and 9999. It prints the number in the form of 16 bits, and then in reverse.
# Finally, it prints the number represented by the reverse bits, in base 10.

################# Data Segment #####################
.data
initial_msg: .asciiz "Please enter a 4 digit number between -9999 and 9999:\n"
error_msg: .asciiz "The input you entered is incorrect. Please try again.\n"

################# Code Segment #####################
.text
.globl main

###############
# SECTION 1
###############
main:
	li $v0, 4
	la $a0, initial_msg
	syscall
	
	li $v0, 5 # Get number
	syscall

	bgt $v0, 9999, incorrect
	blt $v0, -9999, incorrect
	move $s0, $v0 # Store number in $s0
	j continue # If correct
	
# If the number received is incorrect, executes the above again.
incorrect:
	li $v0, 4
	la $a0, error_msg
	syscall
	j main

###############
# SECTION 2
###############	
continue:
	li $v0, 1 # Service to print an int
	li $t0, 0x8000 # Equivalent to 1 followed by 15 zeros in binary (MASK)
print_func:	
	and $a0, $s0, $t0 
	beq $a0, $zero, print_digit # The MSB at this iteration is 0
	li $a0, 1 # Otherwise it's 1.
	
print_digit:
	syscall
	srl $t0, $t0, 1
	bne $t0, $zero, print_func # 16 iterations until all bits are 0 in $t0
	
	li $v0, 11
	li $a0, '\n' 
	syscall
	
###############
# SECTION 3
###############
	li $v0, 1 # Prints integer
	li $t0, 0x1
	li $t1, 0x8000 # Used for 4th section
	li $t2, 0 # Used for 4th section to store bits in reverse
		
print_reverse:
	and $a0, $t0, $s0 
	beq $a0, $zero, print_digit_rev
	li $a0, 1 # If $a0 is not 0 then the digit is 1
	or $t2, $t2, $t1
	
print_digit_rev:
	syscall
	sll $t0, $t0, 1
	srl $t1, $t1, 1
	ble $t0, 0x8000, print_reverse # Iterates until $t0 is bigger than 0x8000 (16 times)

	li $v0, 11
	li $a0, '\n' 
	syscall
	
#############
# SECTION 4
#############
	andi $a0, $t2, 0x8000 # Check the MSB (1 means it's negative)
	beq $a0, $zero, positive
	lui $a0, 0xffff # If negative, fill the 16 left bits with 1s 
	
positive:
	or $a0, $a0, $t2 # Fill rest of the bits accordingly
	li $v0, 1
	syscall

# EXIT
	li $v0, 10 
	syscall
	
	

