.data
array: .space 40       # Space for 10 integers (4 bytes each)
prompt1: .asciiz "Enter the number of elements in the array (1-10): "
prompt2: .asciiz "Enter an integer: "
error_msg1: .asciiz "Error: Please enter a number between 1 and 10.\n"
error_msg2: .asciiz "Error: Integer entered is greater than 10.\n"
result_msg: .asciiz "Average of even values: "

.text
.globl main

main:
    # Initialize registers
    li $t0, 0           # Initialize loop counter to 0
    la $t1, array       # Load address of the array
    li $t5, 0           # Initialize sum of even values to 0
    li $t6, 0           # Initialize count of even values to 0

    input_elements:
    # Ask the user for the number of elements
    li $v0, 4
    la $a0, prompt1
    syscall

    # Read the number of elements
    li $v0, 5
    syscall
    move $t2, $v0       # Store the number of elements in $t2

    # Check if the number of elements is valid (between 1 and 10)
    li $t3, 1
    li $t4, 10
    bge $t2, $t3, valid_elements
    li $v0, 4
    la $a0, error_msg1
    syscall
    j input_elements

    valid_elements:
    ble $t2, $t4, input_loop
    li $v0, 4
    la $a0, error_msg2
    syscall
    j input_elements

input_loop:
    # Print prompt for integer input
    li $v0, 4
    la $a0, prompt2
    syscall

    # Read integer from user
    li $v0, 5
    syscall
    sw $v0, 0($t1)      # Store the integer in the array

    # Update loop counter and array pointer
    addi $t0, $t0, 1    # Increment loop counter
    addi $t1, $t1, 4    # Move to the next element in the array

    # Check if we have read the desired number of elements
    beq $t0, $t2, calculate_average

    j input_loop         # Repeat the loop

calculate_average:
    la $t1, array       # Reset array pointer
    li $t0, 0           # Reset loop counter

    compute_average_loop:
    lw $t3, 0($t1)      # Load the integer from the array

    # Check if the value is even
    andi $t4, $t3, 1
    bnez $t4, not_even  # If it's not even, skip adding to the sum

    add $t5, $t5, $t3   # Add the even value to the sum
    addi $t6, $t6, 1    # Increment the count of even values

    not_even:
    addi $t0, $t0, 1    # Increment loop counter
    addi $t1, $t1, 4    # Move to the next element in the array

    # Check if we have processed all elements
    beq $t0, $t2, print_average

    j compute_average_loop

# Convert the sum of the even integers ($t5) t0 a float, as well as the count of even integers ($t6), then calculate the average, then print the result message, then the average
print_average:
    mtc1 $t5, $f1           # Move sum of even integers to float register to convert it
    mtc1 $t6, $f2           # Move count of even integers
    cvt.s.w $f1, $f1        # Store sum of even integers in $f1
    cvt.s.w $f2, $f2        # Store count of even integers in $f2
    div.s $f0, $f1, $f2     # divide sum by count and store result in $f0

    mov.s $f12, $f0				# move the result to $f12 which is used to temporarily hold the float value we're about to print
    li $v0, 2				    # command to print a float
    syscall

exit:
    # Exit the program
    li $v0, 10
    syscall
