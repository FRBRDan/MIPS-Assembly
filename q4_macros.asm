.macro print_str(%str)
	li $v0, 4
	la $a0, %str
	syscall
.end_macro

# Prints an integer whereas %x can be an immediate value or register name.
.macro print_int(%x)
	li $v0, 1
	add $a0, $zero, %x
	syscall
.end_macro

.macro print_char (%ch)
    li $v0, 11
    addi $a0, $zero, %ch
    syscall
.end_macro
