

    .data 

fileName:  .asciiz "inams.txt" # Escaped file path

open_fail_msg: .asciiz "Failed to open file.\n"

read_fail_msg: .asciiz "Failed to read file.\n"

newline: .asciiz "\n"       # Newline for formatting output

msg_syntax_error: .asciiz "There is a syntax error in the loaded file.\n"

msg_value_t6: .asciiz "This value is not allowed in the file: "

msg_new_file: .asciiz "Please enter a file name:\n"

msg_new_file2: .asciiz "Please enter a new file name:\n"

buffer: .space 100       # Buffer to store the new file name

dot:.asciiz "."  # Newline for output

dont:.word 0 # Newline for output

variables: .space 12              # Array to store the first three alphabetic characters



msg_d_zero: .asciiz "Determinant is zero, no unique solution.\n"

msg_result: .asciiz "Solution: x = "

result_size : .word 0

x_size : .word 0

y_size : .word 0

z_size : .word 0

rhs_size : .word 0

results: .float 0.0, 0.0, 0.0, 0.0 ,0.0, 0.0, 0.0, 0.0 ,0.0, 0.0, 0.0, 0.0 ,0.0, 0.0 ,0.0, 0.0 ,0.0, 0.0  # Initialize an array of 4 floating-point numbers, all set to 0.0



msg_y:      .asciiz ", y =  "

msg_z:      .asciiz ", z =  "

.align 4  

#results:    .space 64        # Space for storing x, y, z results (3 words)





fileWords: .space 1024   # Buffer for file content

 .align 4                     # Aligns z_coeff to a 4-byte boundary

z_array: .space 64               # Allocate 64 bytes for z_coeff (16 words)



    .align 4                     # Aligns y_coeff to a 4-byte boundary

y_array: .space 64               # Allocate 64 bytes for y_coeff (16 words)



    .align 4                     # Aligns x_coeff to a 4-byte boundary

x_array: .space 64               # Allocate 64 bytes for x_coeff (16 words)



    .align 4                     # Aligns rhs to a 4-byte boundary

rhs: .space 64                   # Allocate 64 bytes for rhs (16 words)

                   # Array for right-hand side (constants)

#******************

menu:      .asciiz "\nMenu:\n1. Enter the letter s to display the results \n2. Enter the letter f to move the results to a file \n3. Enter the letter e to exit\n "

error_msg: .asciiz "No unique solution (det(A) = 0)\n"

Error_msg:   .asciiz "\nInvalid Input\n"

filename: .asciiz "C:/Users/Dell/Desktop/outmars2.txt"                    # Output file name

promptX:     .word 0               # Word to hold the value of the first element
promptY:     .word 0               # Word to hold the value of the second element
promptZ:     .word 0               # Word to hold the value of the third element

    border: .asciiz "*********************************************************"

    border2: .asciiz "\n___________________\n"

    Msg: .asciiz "\n-System " 



errorMsg: .asciiz "Invalid System (No solution)\n"

pointer: .word 0

int:   .word 0           # Placeholder for the integer part

ratio: .word 0           # Placeholder for the fractional ratio part

num: .word 0           # Placeholder for the fractional ratio part

fullnumber:  .space 24         # Reserve space for the full number (enough for both integers and dot)

float_num:  .float 5555.22    # Original floating-point number

hundreds: .float 100000.0 



    .text

    .globl main



main:





 li $v0, 4                # Syscall 4 for printing a string

    la $a0, newline          # Load address of newline string

    syscall



# Prompt user to enter a new file name

     li $v0, 4           # Print string syscall

    la $a0, msg_new_file

    syscall

enter_file :

    # Read new file name

    li $v0, 8           # Read string syscall

    la $a0, buffer      # Address of the buffer to store input

    li $a1, 100         # Maximum input size

    syscall

 la $t0, buffer      # Load the address of the buffer into $t0



iterate_buffer:

    lb $t1, 0($t0)      # Load a byte from the buffer

    beqz $t1, end_loop  # If the byte is null (end of string), exit the loop

    li $t2, 10          # ASCII value of newline ('\n')

    beq $t1, $t2, replace_newline  # If the byte is a newline, replace it

    addiu $t0, $t0, 1   # Move to the next byte

    j iterate_buffer    # Repeat the loop



replace_newline:

    li $t1, 0           # Null terminator ('\0')

    sb $t1, 0($t0)      # Replace the newline with null

    addiu $t0, $t0, 1   # Move to the next byte

    j iterate_buffer    # Continue the loop



end_loop:



    # Open file

    li $v0, 13           # open_file syscall code

    la $a0, buffer     # get the file name

    li $a1, 0            # file flag = read (0)

    syscall

    move $s0, $v0        # save the file descriptor. $s0 = file





    # Check if the file was opened successfully

    bltz $s0, open_fail  # if $s0 < 0, file failed to open



    # Read the file

    li $v0, 14           # read_file syscall code

    move $a0, $s0        # file descriptor

    la $a1, fileWords    # buffer to hold the file content

    li $a2, 1024         # buffer length

    syscall



    # Check if the read was successful

    bltz $v0, read_fail  # if $v0 < 0, read failed

    beq $v0, $zero, read_fail # if $v0 == 0, nothing read (empty or EOF)



 


    la $t0, fileWords               # Load address of the buffer

    la $t1, variables             # Load address of the variables array

    li $t2, 0                     # Counter for variables (max 3)



extract_variables:

    lb $t3, 0($t0)                 # Load a byte from the buffer

    beqz $t3, done_extraction      # If null terminator, end loop



    # Check if the character is alphabetic

    li $t4, 'a'                    # ASCII value of 'a'

    li $t5, 'z'                    # ASCII value of 'z'

    blt $t3, $t4, not_alpha        # If character < 'a', not alphabetic

    bgt $t3, $t5, check_upper      # If character > 'z', check uppercase



    # Check for duplicates

check_duplicates:

    la $t6, variables              # Load the base address of the variables array

    li $t7, 0                      # Index for checking

duplicate_loop:

    beq $t7, $t2, store_variable   # If reached the end of stored variables, it's new

    lb $t8, 0($t6)                 # Load a variable from the array

    beq $t3, $t8, skip_store       # If match found, skip storing

    addiu $t6, $t6, 1              # Move to the next variable

    addiu $t7, $t7, 1              # Increment index

    j duplicate_loop



    # Store the variable (lowercase)

store_variable:

    sb $t3, 0($t1)                 # Store the character in the variables array

    addiu $t1, $t1, 1              # Move to the next position in the array

    addiu $t2, $t2, 1              # Increment variable counter

    b check_done                   # Check if 3 variables have been found



    # Check uppercase alphabetic characters

check_upper:

    li $t4, 'A'                    # ASCII value of 'A'

    li $t5, 'Z'                    # ASCII value of 'Z'

    blt $t3, $t4, not_alpha        # If character < 'A', not alphabetic

    bgt $t3, $t5, not_alpha        # If character > 'Z', not alphabetic

    j check_duplicates             # Check if uppercase variable is a duplicate



    # Skip non-alphabetic characters

not_alpha:

    addiu $t0, $t0, 1              # Move to the next byte in the buffer

    j extract_variables            # Continue the loop



    # If the variable exists, skip storing

skip_store:

    addiu $t0, $t0, 1              # Move to the next byte in the buffer

    j extract_variables            # Continue the loop



    # Check if we found 3 variables

check_done:

    li $t4, 3                      # Maximum number of variables

    bge $t2, $t4, done_extraction  # If 3 variables are found, stop

    addiu $t0, $t0, 1              # Move to the next byte in the buffer

    j extract_variables            # Continue the loop



done_extraction:

    # Add null terminator to the variables array

    li $t3, 0                      # Null terminator

    sb $t3, 0($t1)                 # Store null terminator



    # Print the variables array for debugging

    la $a0, variables              # Address of variables array

    #li $v0, 4                      # Syscall for print string

    #syscall



    

    

    # Close the file

    li $v0, 16           # close_file syscall code

    move $a0, $s0        # file descriptor to close

    syscall



 j skip



# Error handling

open_fail:

    li $v0, 4            # print_string syscall

    la $a0, open_fail_msg

    syscall

    j main



read_fail:

    li $v0, 4            # print_string syscall

    la $a0, read_fail_msg

    syscall

    j end

    

    

    skip:

    li $t0, 0               # Load the value 0 into register $t0

    sw $t0, result_size    # Store the updated size back into results_size




    la $t0, x_array             

    la $t1, y_array            

    la $t2, z_array             

    la $t3, rhs                 

    

    la $t4, fileWords              

    li $t5, 0                    

    li $v1, 0

    li $s7, 0x20 

    la ,$a2 , results

      

    loop:

    lb $t6,0($t4)

    beqz $t6, endloop

    beq $t6, 0xA, next_line      # If newline (0xA), go to the next line

    sub $t7, $t6, 48  

    li $t8, '-'  

 

     beq $t6, $t8, negative_flag 

    
    move $a0, $t6   

    #li $v0, 11        

    #syscall 

    

    bgez $t7, check

    

    li $s2, 43          # ASCII value of '+'

    beq $t6, $s2, next# If $t6 == '+', branch



    li $s2, 45          # ASCII value of '-'

    beq $t6, $s2, next



    li $s2, 32          # ASCII value of ' ' (space)

    beq $t6, $s2, next #  If $t6 == ' ', branch



    li $s2, 61          # ASCII value of '='

    beq $t6, $s2, next  # If $t6 == '=', branch

    

    li $s2, 13          # ASCII value of CR

    beq $t6, $s2, next # If $t6 == CR, branch

    

    j  syntax_error

    

    next:

    addi $t4,$t4,1

    j loop

    

   negative_flag:

   beqz  $v1 , make_one

   li $v1, 0

   j next

   make_one:

    li $v1, 1             

    addi $t4, $t4, 1       

    j loop

    

    apply_negative:

    sub $t9, $zero, $t9    

    li $v1, 0    

    jr $ra           



    check:

    

    li $t8, '='

    beq $t6, $t8, rhs_part2

    li $s7, 0x20 

    beq $s7, $t8, rhs_part

    #addi $t4,$t4,1

   

    #lb $t6, 0($t4)

    

    la $a2,variables

    lb $t8, 0($a2)

    beq $t6, $t8, x_coeff

    

     lb $t8, 1($a2)

    beq $t6, $t8, y_coeff

    

     lb $t8, 2($a2)

    beq $t6, $t8, z_coeff





    mul $t9, $t9, 10       

    add $t9, $t9, $t7   



    

    j next

    

    

    

    x_coeff:

   bnez  $t9, multi_coeff

   li $t9,1

   multi_coeff:

   beqz  $v1, pos

   jal apply_negative

    pos:

    sw $t9,0($t0)

    addi $t0,$t0,4

    li $t9,0

    lw $s6, x_size   

    addi $s6, $s6, 4

    sw $s6, x_size 

    j next

    

     y_coeff:

    bnez  $t9, multi_coeff2

   li $t9,1

   multi_coeff2:

   beqz  $v1, pos2

   jal apply_negative

    pos2:

    sw $t9,0($t1)

    addi $t1,$t1,4

    li $t9,0

    lw $s6, y_size   

    addi $s6, $s6, 4

    sw $s6, y_size 

    j next

    

     z_coeff:

     bnez  $t9, multi_coeff3

   li $t9,1

   multi_coeff3:

    beqz  $v1, pos3

   jal apply_negative

    pos3:

    sw $t9,0($t2)

    addi $t2,$t2,4

    li $t9,0

   lw $s6, z_size   

    addi $s6, $s6, 4

    sw $s6, z_size 

    j next

   

    rhs_part2:

    li $s5 ,'='

    j next

    

     rhs_part:

     lb $t6,0($t4)

     sub $t7,$t6,48

     mul $t9, $t9, 10       

     add $t9, $t9, $t7     

      j next

   

    next_line:

    beqz  $v1, pos4

   jal apply_negative

  

    pos4:

    



    beq $t6 , '\r' , no_inc

    

       addi $t5, $t5, 1             

       lw $s6, rhs_size 

    addi $s6, $s6, 4

    sw $s6, rhs_size 

     sw $t9,0($t3)

     addi $t3 ,$t3,4

     no_inc:

     li $t9,0

     li $s5,0

    addi $t4, $t4, 1      

   move $s4 ,$t4

   addi $s4,$s4,1

   lb $s3,0($s4)

   li $a1,'\n'

   bne  $a1 ,$s3,skip2

   addi $t4, $t4, 1  

   li $s3,3

   beq $t5,$s3,sys3x3

   li $s3,2

   beq $t5,$s3,sys2x2

  

  

   lw $t9,-4($t3)

   beq $t9,-594,endloop

   

    addi $t4, $t4, 1

   j no_solution 

   sys3x3:

   addi $t4, $t4, 1

   li $a3, 12

   lw $a1, x_size          

   bne $a1, $a3, no_solution 

    

    lw $a1, y_size       

   bne $a1, $a3, no_solution 

   

   lw $a1, z_size          

   bne $a1, $a3, no_solution 

   

   lw $a1, rhs_size           

   bne $a1, $a3, no_solution 



   j solve3x3

    sys2x2:

    addi $t4, $t4, 1

   li $a3, 8

   lw $a1, x_size          

   bne $a1, $a3, no_solution 

    

    lw $a1, y_size       

   bne $a1, $a3, no_solution 

   

   lw $a1, rhs_size           

   bne $a1, $a3, no_solution 

   

    j solve2x2

    

 

    skip2:     

    j loop



endloop:



    jal print_results       # Call the function to print the array





 la $t3, rhs           # Start of 'z' coefficient array

 

 print_z_array:

    #li $v0, 1                # Syscall 1 for printing an integer

    lw $a0, 0($t3)           # Load the byte (coefficient) from z_array into $a0

    beq $a0, $zero, cont

    #syscall                  # Print the coefficient



    # Print a newline after each coefficient

    #li $v0, 4                # Syscall 4 for printing a string

    la $a0, newline          # Load address of newline string

    #syscall                  # Print newline

    addi $t3, $t3, 4     # Move to the next byte in the z_array

    j print_z_array          # Repeat the loop

   

  cont:

 #*****************************************



    

  jal menu_loop

    

    

exit_loop:

    li $v0, 10              # syscall for exit

    syscall



#*********************************************************************************************************

menu_loop:

    la $t0, variables                  # Load the address of the array into $t0
    
    lb $t1, 0($t0)                 # Load the first byte (character 'x') of array into $t1
    la $a0, promptX                # Load the address of promptX into $a0
    sb $t1, 0($a0)                 # Store character 'x' to the beginning of promptX
    li $t2, '='                    # Load the equal sign character into $t2
    sb $t2, 1($a0)                 # Store the equal sign after 'x' in promptX
    sb $zero, 2($a0)               # Null terminator at the end of promptX

    # Move second character with '=' to promptY
    lb $t1, 1($t0)                 # Load the second byte (character 'y') of array into $t1
    la $a0, promptY                # Load the address of promptY into $a0
    sb $t1, 0($a0)                 # Store character 'y' to the beginning of promptY
    li $t2, '='                    # Load the equal sign character into $t2
    sb $t2, 1($a0)                 # Store the equal sign after 'y' in promptY
    sb $zero, 2($a0)               # Null terminator at the end of promptY

    # Move third character with '=' to promptZ
    lb $t1, 2($t0)                 # Load the third byte (character 'z') of array into $t1
    la $a0, promptZ                # Load the address of promptZ into $a0
    sb $t1, 0($a0)                 # Store character 'z' to the beginning of promptZ
    li $t2, '='                    # Load the equal sign character into $t2
    sb $t2, 1($a0)                 # Store the equal sign after 'z' in promptZ
    sb $zero, 2($a0)               # Null terminator at the end of promptZ


loopp:

 li $v0, 4                # Syscall 4 for printing a string

    la $a0, newline          # Load address of newline string

    syscall  

    

 li $v0, 4            # print_string syscall code

    la $a0, border

    syscall

    

    # Print the menu

    li $v0, 4                # syscall for printing a string

    la $a0, menu             # load address of menu string

    syscall

 li $v0, 4            # print_string syscall code

    la $a0, border

    syscall

     li $v0, 4                # Syscall 4 for printing a string

    la $a0, newline          # Load address of newline string

    syscall  

    # Read a single character

    li $v0, 12               # syscall for reading a character

    syscall

    move $t0, $v0            # store the character in $t0



    # Check if the character is 'e' or 'E' (exit)

    li $t1, 'e'

    li $t2, 'E'

    beq $t0, $t1, exit_loop  # if the input character is 'e', exit the loop

    beq $t0, $t2, exit_loop  # if the input character is 'E', exit the loop



    # Check if the character is 'f' or 'F' (print "hi")

    li $t1, 'f'

    li $t2, 'F'

    beq $t0, $t1, print_file # if the input character is 'f', jump to print_file

    beq $t0, $t2, print_file # if the input character is 'F', jump to print_file



    # Check if the character is 's' or 'S' (print "bye")

    li $t1, 's'

    li $t2, 'S'

    beq $t0, $t1, print_screen # if the input character is 's', jump to print_screen

    beq $t0, $t2, print_screen # if the input character is 'S', jump to print_screen



    # Otherwise, loop again

    li $v0, 4                # syscall for printing a string

    la $a0, Error_msg

    syscall

    j loopp

    



# Exit point for menu_loop function



    jr $ra                   # return to caller



 #************************************************************************   

 solve3x3:

   

   addi $sp, $sp, -4     

   sw $a2, 0($sp)

   

   lw $s6 ,x_size

   sub $t0 , $t0, $s6

    lw $s6 ,y_size

   sub $t1 , $t1, $s6

    lw $s6 ,z_size

   sub $t2 , $t2, $s6

    lw $s6 ,rhs_size

   sub $t3 , $t3, $s6

  

  

     # Load the coefficients and RHS values for the first three equations

    lw $a0, 0($t0)            # x-coefficient for equation 1

    lw $a1, 0($t1)            # y-coefficient for equation 1

    lw $a2, 0($t2)            # z-coefficient for equation 1

    lw $a3, 0($t3)            # RHS constant for equation 1



    lw $t6, 4($t0)            # x-coefficient for equation 2

    lw $t7, 4($t1)            # y-coefficient for equation 2

    lw $t8, 4($t2)            # z-coefficient for equation 2

    lw $s6, 4($t3)            # RHS constant for equation 2



    lw $s0, 8($t0)            # x-coefficient for equation 3

    lw $s1, 8($t1)            # y-coefficient for equation 3

    lw $s2, 8($t2)            # z-coefficient for equation 3

    lw $s3, 8($t3)            # RHS constant for equation 3



   # Calculating det

# det = a0 * (t7 * s2 - t8 * s1) - a1 * (t6 * s2 - t8 * s0) + a2 * (t6 * s1 - t7 * s0)



mul $t9, $t7, $s2         # t7 * s2

mul $s4, $t8, $s1         # t8 * s1

sub $t9, $t9, $s4         # t7 * s2 - t8 * s1

mul $t9, $a0, $t9         # a0 * (t7 * s2 - t8 * s1)



mul $s4, $t6, $s2         # t6 * s2

mul $s5, $t8, $s0         # t8 * s0

sub $s4, $s4, $s5         # t6 * s2 - t8 * s0

mul $s4, $a1, $s4         # a1 * (t6 * s2 - t8 * s0)



sub $t9, $t9, $s4         # a0 * (...) - a1 * (...)



mul $s4, $t6, $s1         # t6 * s1

mul $s5, $t7, $s0         # t7 * s0

sub $s4, $s4, $s5         # t6 * s1 - t7 * s0

mul $s4, $a2, $s4         # a2 * (t6 * s1 - t7 * s0)



add $s7, $t9, $s4         # det = final result in $s7





    # Check if D is zero

bne  $s7, $zero, skipit2


lw $s6 ,x_size

   add $t0 , $t0, $s6

    lw $s6 ,y_size

   add $t1 , $t1, $s6

    lw $s6 ,z_size

   add $t2 , $t2, $s6

    lw $s6 ,rhs_size

   add $t3 , $t3, $s6

    li $v1, 0 

    li $t9, 0 

    li $t5,0

j no_solution

skipit2:

   # Calculating det_x

# det_x = a3 * (t7 * s2 - t8 * s1) - a1 * (s6 * s2 - s3 * t8) + a2 * (s6 * s1 - s3 * t7)



mul $s4, $t7, $s2         # t7 * s2

mul $s5, $t8, $s1         # t8 * s1

sub $s4, $s4, $s5         # t7 * s2 - t8 * s1

mul $s0, $a3, $s4         # a3 * (t7 * s2 - t8 * s1)



mul $s4, $s6, $s2         # s6 * s2

mul $s5, $s3, $t8         # s3 * t8

sub $s4, $s4, $s5         # s6 * s2 - s3 * t8

mul $s4, $a1, $s4         # a1 * (s6 * s2 - s3 * t8)



sub $v1, $s0, $s4         # a3 * (...) - a1 * (...)



mul $s4, $s6, $s1         # s6 * s1

mul $s5, $s3, $t7         # s3 * t7

sub $s4, $s4, $s5         # s6 * s1 - s3 * t7

mul $s4, $a2, $s4         # a2 * (s6 * s1 - s3 * t7)



add $s4, $v1, $s4         # det_x = final result in $s4



 lw $s0, 8($t0)            # x-coefficient for equation 3



   # Calculating det_y

# det_y = a0 * (s6 * s2 - s3 * t8) - a3 * (t6 * s2 - t8 * s0) + a2 * (t6 * s3 - s6 * s0)



mul $s5, $s6, $s2         # s6 * s2

mul $v1, $s3, $t8         # s3 * t8

sub $s5, $s5, $v1        # s6 * s2 - s3 * t8

mul $s1, $a0, $s5         # a0 * (s6 * s2 - s3 * t8)



mul $s5, $t6, $s2         # t6 * s2

mul $t5, $t8, $s0         # t8 * s0

sub $s5, $s5, $t5         # t6 * s2 - t8 * s0

mul $s5, $a3, $s5         # a3 * (t6 * s2 - t8 * s0)



sub $s1, $s1, $s5         # a0 * (...) - a3 * (...)



mul $s5, $t6, $s3         # t6 * s3

mul $s6, $s6, $s0         # s6 * s0

sub $s5, $s5, $s6         # t6 * s3 - s6 * s0

mul $s5, $a2, $s5         # a2 * (t6 * s3 - s6 * s0)



add $s5, $s1, $s5         # det_y = final result in $s5



 lw $s1, 8($t1)

 lw $s6, 4($t3) 



    # Calculating det_z

# det_z = a0 * (t7 * s3 - s6 * s1) - a1 * (t6 * s3 - s6 * s0) + a3 * (t6 * s1 - t7 * s0)



mul $v1, $t7, $s3         # t7 * s3

mul $a2, $s6, $s1         # s6 * s1

sub $v1, $v1, $a2        # t7 * s3 - s6 * s1

mul $s2, $a0, $v1        # a0 * (t7 * s3 - s6 * s1)



mul $v1, $t6, $s3         # t6 * s3

mul $s3, $s6, $s0         # s6 * s0

sub $s6, $v1, $s3         # t6 * s3 - s6 * s0

mul $s6, $a1, $s6         # a1 * (t6 * s3 - s6 * s0)



sub $s2, $s2, $s6         # a0 * (...) - a1 * (...)



mul $s6, $t6, $s1         # t6 * s1

mul $s3, $t7, $s0         # t7 * s0

sub $s6, $s6, $s3         # t6 * s1 - t7 * s0

mul $s6, $a3, $s6         # a3 * (t6 * s1 - t7 * s0)



add $s6, $s2, $s6         # det_z = final result in $s6





  mtc1 $s4, $f4              # Move Dx to $f4

cvt.s.w $f4, $f4           # Convert Dx to single-precision float



mtc1 $s5, $f5              # Move Dy to $f5

cvt.s.w $f5, $f5           # Convert Dy to single-precision float



mtc1 $s6, $f6              # Move Dz to $f6

cvt.s.w $f6, $f6           # Convert Dz to single-precision float



mtc1 $s7, $f7              # Move D to $f7

cvt.s.w $f7, $f7           # Convert D to single-precision float



# Perform floating-point divisions

div.s $f4, $f4, $f7        # x = Dx / D

div.s $f5, $f5, $f7        # y = Dy / D

div.s $f6, $f6, $f7        # z = Dz / D





#lw $a2, 0($sp)   

la $a3 ,results

lw $a0 , result_size

mul $a0,$a0,4

add $a3,$a3,$a0



addi $sp, $sp, 4



swc1 $f4, 0($a3)       



swc1 $f5, 4($a3) 



swc1 $f6, 8($a3)      





 li $t7, 'v'          

 mtc1 $t7, $f8        

 cvt.s.w $f8, $f8      

 swc1 $f8, 12($a3)       



lw $s6, result_size    

addi $s6, $s6, 4

 sw $s6, result_size

 

 

# Output the results

la $a0, msg_result         # Print message for result

li $v0, 4

syscall







# Load and print x

l.s $f12, 0($a3)    # Load x (floating-point) into $f12 for printing

li $v0, 2                 

syscall



la $a0, msg_y             

li $v0, 4

syscall



addi $a3 , $a3,4

# Load and print y

l.s $f12, 0($a3)  

li $v0, 2                  

syscall



la $a0, msg_z             

li $v0, 4

syscall



addi $a3 , $a3,4

# Load and print z

l.s $f12, 0($a3)     

li $v0, 2                  

syscall



li $t9,'v'

lw $t9 ,results

    

  lw $s6 ,x_size

   add $t0 , $t0, $s6

    lw $s6 ,y_size

   add $t1 , $t1, $s6

    lw $s6 ,z_size

   add $t2 , $t2, $s6

    lw $s6 ,rhs_size

   add $t3 , $t3, $s6

   

   sw $zero, x_size

   sw $zero, y_size

   sw $zero, z_size

   sw $zero, rhs_size



    li $v1, 0 

    li $t9, 0 

    li $t5,0

   

    j loop



no_solution:

la $a3 ,results

lw $a0 , result_size

mul $a0,$a0,4

add $a3,$a3,$a0



 li $t9, 'i'             # Load ASCII value of 'i' 

 mtc1 $t9, $f2           # Move the integer value from $t7 to floating-point register $f2

 cvt.s.w $f2, $f2        # Convert the integer in $f2 to a single-precision float

 swc1 $f2, 0($a3)     # Store the converted float value at the next position



    la $a0, msg_d_zero

    li $v0, 4

    syscall

li $t9,0

lw $s6, result_size    # Load the address of results_size into $t0

addi $s6, $s6, 1

 sw $s6, result_size



sw $zero, x_size

   sw $zero, y_size

   sw $zero, z_size

   sw $zero, rhs_size

li $t5,0

    

j loop

  



 

end:



    li $v0, 10

    syscall

 

    

 syntax_error:

    # Print newline

    li $v0, 11          # Print character syscall

    li $a0, 10          # ASCII code for newline

    syscall

    

 # Print syntax error message

    li $v0, 4           # Print string syscall

    la $a0, msg_syntax_error

    syscall



    # Print the value of $t6 along with the detailed message

    li $v0, 4        # Print string syscall

    la $a0, msg_value_t6

    syscall



    li $v0, 11          # Print integer syscall

    move $a0, $t6       # Load value of $t6 into $a0

    syscall



    # Print newline

    li $v0, 11          # Print character syscall

    li $a0, 10          # ASCII code for newline

    syscall   

    

    # Print newline

    li $v0, 11          # Print character syscall

    li $a0, 10          # ASCII code for newline

    syscall

    

    li $v0, 4           # Print string syscall

    la $a0, msg_new_file2

    syscall

    

    j enter_file      

          

             

  print_results:

    # Set up the base address and counter

    la $t0, results         # Load the base address of the array into $t0

    lw $t1, result_size     # Load the size of the array (counter) into $t1

    li $t2, 0               # Initialize index (counter) in $t2

   

    

print_loop:

    bge $t2, $t1, end_print1 # If index >= result_size, exit the loop



    mul $t3, $t2, 4         # Calculate the offset: index * 4 bytes (size of a float)

    add $t4, $t0, $t3       # Calculate the address of the current element

    l.s $f12, 0($t4)        # Load the floating-point value into $f12



    # Print the floating-point value

    #li $v0, 2               # Print floating-point syscall

    #syscall



    # Add a new line (optional)

    #li $v0, 11              # Print character syscall

    #li $a0, 10              # ASCII code for newline

    #syscall



    addi $t2, $t2, 1        # Increment index

    j print_loop            # Repeat the loop



end_print1:

    jr $ra                  # Return to caller







# Function to solve the linear system

solve2x2:



   lw $s6 ,x_size

   sub $t0 , $t0, $s6

   lw $s6 ,y_size

   sub $t1 , $t1, $s6

   

    # Load coefficients for matrix A into integer registers

    lw $v0, 0($t0)        # $v0 = a = 2

    lw $v1, 4($t0)       # $v1 = c = 4

    lw $a1, 0($t1)          # $a1 = b = 3

    lw $a2, 4($t1)       # $a2 = d = -5



    # Calculate det(A) = a * d - b * c

    mul $a3, $v0, $a2       # $a3 = a * d

    mul $t5, $a1, $v1       # $t5 = b * c

    sub $t6, $a3, $t5       # $t6 = det(A)



    # Check if det(A) is zero (no unique solution)

    bne  $t6, $zero, skipit # If det(A) = 0, jump to error



lw $s6 ,x_size

   add $t0 , $t0, $s6

    lw $s6 ,y_size

   add $t1 , $t1, $s6

   

   lw $s6 ,rhs_size

   add $t3 , $t3, $s6
   li $v1, 0 

    li $t9, 0 

    li $t5,0
   j no_solution  


   skipit:
   lw $s6 ,rhs_size

   sub $t3 , $t3, $s6

    # Load constants for matrix B

    lw $t7, 0($t3)   # $t7 = e = 8

    lw $t8, 4($t3)     # $t8 = f = -2



    # Calculate det(A_x) = e * d - b * f

    mul $a3, $t7, $a2       # $a3 = e * d

    mul $t5, $a1, $t8       # $t5 = b * f

    sub $t9, $a3, $t5       # $t9 = det(A_x)



    # Calculate det(A_y) = a * f - e * c

    mul $a3, $v0, $t8       # $a3 = a * f

    mul $t5, $t7, $v1       # $t5 = e * c

    sub $a2, $a3, $t5       # $a2 = det(A_y)



    # Store integer results for x and y

    div $t9, $t6            # Perform integer division for x = det(A_x) / det(A)

    mflo $a3                # Move integer result of x to $a3

    div $a2, $t6            # Perform integer division for y = det(A_y) / det(A)

    mflo $t5                # Move integer result of y to $t5



    # Save integer results to memory

    #sw $a3, result_x_int    # Store integer x in result_x_int

    #sw $t5, result_y_int    # Store integer y in result_y_int



    # Convert det(A), det(A_x), and det(A_y) to floats for division

    mtc1 $t6, $f6           # Move det(A) to floating-point register $f6

    mtc1 $t9, $f7           # Move det(A_x) to floating-point register $f7

    mtc1 $a2, $f8           # Move det(A_y) to floating-point register $f8

    cvt.s.w $f6, $f6        # Convert det(A) to float

    cvt.s.w $f7, $f7        # Convert det(A_x) to float

    cvt.s.w $f8, $f8        # Convert det(A_y) to float



    # Calculate floating-point x = det(A_x) / det(A)

    div.s $f0, $f7, $f6     # $f0 = x (floating-point result)



    # Calculate floating-point y = det(A_y) / det(A)

    div.s $f1, $f8, $f6     # $f1 = y (floating-point result)



    # Save floating-point results to memory

    la $a3, results         # Load the base address of "results" into $a3

 lw $t7, result_size    # Load the current size of the array into $t7

 sll $t7, $t7, 2         # Multiply the size by 4 to get the offset in bytes (word size)

 add $a3, $a3, $t7       # Move the pointer to the end of the array



 swc1 $f0, 0($a3)        # Store the value of $f0 at the end of the array

 swc1 $f1, 4($a3)        # Store the value of $f1 at the next position

 li $t7, 'v'             # Load ASCII value of 'v' (118) into $t7

 mtc1 $t7, $f2           # Move the integer value from $t7 to floating-point register $f2

 cvt.s.w $f2, $f2        # Convert the integer in $f2 to a single-precision float

 swc1 $f2, 8($a3)        # Store the converted float value at the next position



 lw $t7, result_size    # Reload the current size of the array

 addi $t7, $t7, 3        # Increment the size by 3 (since 3 elements were added)

 sw $t7, result_size    # Store the updated size back into results_size

    # Return from function

    

      lw $s6 ,x_size

   add $t0 , $t0, $s6

    lw $s6 ,y_size

   add $t1 , $t1, $s6

   

   lw $s6 ,rhs_size

   add $t3 , $t3, $s6

   

   li $v1 ,0 

 sw $zero, x_size

   sw $zero, y_size

   sw $zero, rhs_size

   

   li $t5, 0 
   li $t9, 0 

   

    j loop                  # Jump back to caller







#***************************************************************************



print_screen:

  

     li $t9,0 

      la $t0, results         # load address of results into $t0

    lw $t7, result_size   # Load the current size of the array into $t0

    move $t6, $t7    # Set length of the array (number of elements)

    li $t4, 0               # Initialize counter for storing x, y, z



lp:

    beq $t6, 0, loopp # If all elements are processed, exit loop



    # Load the next element into $f1 as a floating-point value

    lw $t1, 0($t0)   
                  # Load the word into $t1
    mtc1 $t1, $f1  

    addi $t0, $t0, 4         # Move to the next element

    subi $t6, $t6, 1         # Decrement the length counter

    

    # Check if the loaded value is an ASCII character

    cvt.w.s $f2, $f1 

    mfc1 $t1, $f2           # Move float to integer register for character check

    li $t2, 65               # ASCII value of 'A'

    li $t3, 122              # ASCII range from 'A' to 'z'



    # Check if the integer form of $f1 is in the ASCII range

    blt $t1, $t2, store_values  # If $t1 < 'A', treat as number

    bgt $t1, $t3, store_values  # If $t1 > 'z', treat as number

    addi $t9, $t9, 1

    # Handle character 'i' for skipping

    li $t5, 'i'

    beq $t1, $t5, handle_i    # If character is 'i', handle skip



    # If it's another character, print x, y, z

    j print_xyz



store_values:

    # Check if we have stored 3 numbers (x, y, z)

    bne $t4, 3, store_number  # If not yet 3, store the next value



    # If we have 3 numbers, print x, y, z

print_xyz:



     li $v0, 4            # print_string syscall code

    la $a0, border2

    syscall

    

    li $v0, 4          # syscall to print string

    la $a0, Msg

    syscall



    li $v0, 1         # syscall to print string

    move $a0, $t9

    syscall

    li $v0, 4

    la $a0, newline

    syscall

    

    li $v0, 4          # syscall to print string

    la $a0, promptX

    syscall

    li $v0, 2          # syscall to print float

    mov.s $f12, $f0    # Move x value to $f12 for printing

    syscall

    li $v0, 4          # print newline

    la $a0, newline

    syscall



    li $v0, 4

    la $a0, promptY

    syscall

    li $v0, 2

    mov.s $f12, $f3    # Move y value to $f12 for printing

    syscall

    li $v0, 4

    la $a0, newline

    syscall

    

    beq $k0, 42,here

    li $v0, 4

    la $a0, promptZ

    syscall

    li $v0, 2

    mov.s $f12, $f4    # Move z value to $f12 for printing

    syscall

    
   


    li $v0, 4

    la $a0, newline

    syscall


 here:

    # Reset counter for next set of values

    li $t4, 0

    j lp



store_number:

    # Store numbers in $f0, $f1, $f2 for x, y, z

    beq $t4, 0, store_x

    beq $t4, 1, store_y

    beq $t4, 2, store_z



store_x:

    mov.s $f0, $f1     # Store in $f0 (x)

    addi $t4, $t4, 1   # Increment counter

    j lp



store_y:

    mov.s $f3, $f1     # Store in $f1 (y)

    addi $t4, $t4, 1

    li $k0, 42

    j lp



store_z:

    mov.s $f4, $f1     # Store in $f2 (z)

    addi $t4, $t4, 1

    li $k0, 0

    j lp



handle_i:


     li $v0, 4            # print_string syscall code

    la $a0, border2

    syscall


    li $v0, 4          # syscall to print string

    la $a0, Msg

    syscall

    li $v0, 1         # syscall to print string

    move $a0, $t9

    syscall

    li $v0, 4

    la $a0, newline

    syscall

    li $v0, 4                 # Print error message for 'i'

    la $a0, errorMsg

    syscall

    li $t4, 0                 # Reset counter to skip previous values

    j lp                    # Go back to the loop







 j loopp                   # jump back to the start of the loop

 

 

print_file:



 

   # Open the file

    li $v0, 13           # Syscall for opening a file

    la $a0, filename   # File name

    li $a1, 1            # Write mode

    li $a2, 0            # Default permissions

    syscall

    move $s0, $v0        # Store file descriptor in $s0



    li $t9, 0            # Initialize character count

    la $t0, results      # Load address of results

    lw $t7, result_size # Load size of array

    move $t6, $t7        # Copy size to counter

    li $t4, 0            # Initialize counter for x, y, z



lpp:

    beq $t6, 0, end_loop2 # Exit loop if all elements are processed



    # Load next element as float

    l.s $f1, 0($t0)

    addi $t0, $t0, 4     # Move to the next element

    subi $t6, $t6, 1     # Decrement counter



    # Convert float to integer for ASCII check

    cvt.w.s $f2, $f1

    mfc1 $t1, $f2

    li $t2, 65           # ASCII value of 'A'

    li $t3, 122          # ASCII value of 'z'



    # Check if it's an ASCII character

    blt $t1, $t2, store_values2

    bgt $t1, $t3, store_values2

    addi $t9, $t9, 1



    # Handle character 'i'

    li $t5, 'i'

    beq $t1, $t5, handle_i2



    # Print x, y, z

    j print_xyz2



store_values2:

    bne $t4, 3, store_number2 # Store number if not all values set

    j print_xyz              # Print x, y, z if all values are set



print_xyz2:

    # Write message to file

    li $v0, 15

    move $a0, $s0         # File descriptor

    la $a1, Msg           # Message to write

    li $a2, 8            # Message length

    syscall

    

    

    sub $sp, $sp, 52   # Allocate space on the stack (3 registers x 4 bytes)

    sw $t0, 44($sp)     # Save $t0 to the stack

    sw $t1, 48($sp)     # Save $t1 to the stack

    sw $t2, 52($sp)     # Save $t2 to the stack

    sw $t3, 16($sp)     # Save $t2 to the stack

    sw $t4, 20($sp)     # Save $t2 to the stack

    sw $t5, 24($sp)     # Save $t2 to the stack

    sw $t6, 28($sp)     # Save $t2 to the stack

    sw $t7, 32($sp)     # Save $t2 to the stack

    sw $t9, 36($sp)     # Save $t2 to the sta

    

    sw $s0, 40($sp)     # Save $t2 to the stack

    

    la $t2, pointer           

    sw $s0, 0($t2)        



    la $t1, num           # Load the address of 'num' into $t1

    sw $t9, 0($t1)        # Store the value in $t0 into 'num' (address in $t1)



    jal PrintInt    # Call the function



    lw $t0, 44($sp)     # Restore $t0 from the stack

    lw $t1, 48($sp)     # Restore $t1 from the stack

    lw $t2, 52($sp)     # Restore $t2 from the stack

    lw $t3, 16($sp)     # Restore $t2 from the stack

    lw $t4, 20($sp)     # Restore $t2 from the stack

    lw $t5, 24($sp)     # Restore $t2 from the stack

    lw $t6, 28($sp)     # Restore $t2 from the stack

    lw $t7, 32($sp)     # Restore $t2 from the stack

    lw $t9, 36($sp)     # Restore $t2 from the stack

    lw $s0, 40($sp)     # Restore $t2 from the stack

    add $sp, $sp, 52   # Deallocate the stack space





    # Write newline

    li $v0, 15

    move $a0, $s0             # File descriptor

    la $a1, newline

    li $a2, 1

    syscall



    # Write x, y, z values

    li $v0, 15                # Syscall for writing to a file

    move $a0, $s0             # File descriptor

     la $a1, promptX           # Address of the string "X: "

     li $a2, 2                # Length of the string

     syscall

     

     

    sub $sp, $sp, 60   # Allocate space on the stack (3 registers x 4 bytes)

    sw $t0, 44($sp)     # Save $t0 to the stack

    sw $t1, 48($sp)     # Save $t1 to the stack

    sw $t2, 52($sp)     # Save $t2 to the stack

    sw $t3, 16($sp)     # Save $t2 to the stack

    sw $t4, 20($sp)     # Save $t2 to the stack

    sw $t5, 24($sp)     # Save $t2 to the stack

    sw $t6, 28($sp)     # Save $t2 to the stack

    sw $t7, 32($sp)     # Save $t2 to the stack

    sw $t9, 36($sp)     # Save $t2 to the sta

    s.s $f3, 56($sp)

    s.s $f4, 60($sp)

    sw $s0, 40($sp)     # Save $t2 to the stack

    

    la $t2, pointer           

    sw $s0, 0($t2)

            

    la $t0,   float_num         # Load the address of 'num' into register $t0

    swc1 $f0, 0($t0) 



    jal FloatFile    # Call the function



    lw $t0, 44($sp)     # Restore $t0 from the stack

    lw $t1, 48($sp)     # Restore $t1 from the stack

    lw $t2, 52($sp)     # Restore $t2 from the stack

    lw $t3, 16($sp)     # Restore $t3 from the stack

    lw $t4, 20($sp)     # Restore $t4 from the stack

    lw $t5, 24($sp)     # Restore $t5 from the stack

    lw $t6, 28($sp)     # Restore $t6 from the stack

    lw $t7, 32($sp)     # Restore $t7 from the stack

    lw $t9, 36($sp)     # Restore $t9 from the stack

    lw $s0, 40($sp)     

    l.s $f3, 56($sp)

    l.s $f4, 60($sp)

    add $sp, $sp, 60   # Deallocate the stack space



    

    

    li $v0, 15

    move $a0, $s0             # File descriptor

    la $a1, promptY

    li $a2, 2

    syscall

    

    

    sub $sp, $sp, 60  # Allocate space on the stack (3 registers x 4 bytes)

    sw $t0, 44($sp)     # Save $t0 to the stack

    sw $t1, 48($sp)     # Save $t1 to the stack

    sw $t2, 52($sp)     # Save $t2 to the stack

    sw $t3, 16($sp)     # Save $t2 to the stack

    sw $t4, 20($sp)     # Save $t2 to the stack

    sw $t5, 24($sp)     

    sw $t6, 28($sp)     

    sw $t7, 32($sp)     

    sw $t9, 36($sp)     

    s.s $f3, 56($sp)

    s.s $f4, 60($sp)

    sw $s0, 40($sp)     # Save $t2 to the stack

 

    

    

    la $t2, pointer           

    sw $s0, 0($t2)

            

    la $t0,   float_num         # Load the address of 'num' into register $t0

    swc1 $f3, 0($t0) 



    jal FloatFile    # Call the function

    

     lw $t0, 44($sp)     # Restore $t0 from the stack

    lw $t1, 48($sp)     # Restore $t1 from the stack

    lw $t2, 52($sp)     # Restore $t2 from the stack

    lw $t3, 16($sp)     # Restore $t2 from the stack

    lw $t4, 20($sp)     # Restore $t2 from the stack

    lw $t5, 24($sp)     # Restore $t2 from the stack

    lw $t6, 28($sp)     # Restore $t2 from the stack

    lw $t7, 32($sp)     # Restore $t2 from the stack

    lw $t9, 36($sp)     # Restore $t2 from the stack

    lw $s0, 40($sp)     # Restore $t2 from the stack

    l.s $f3, 56($sp)

    l.s $f4, 60($sp)

    add $sp, $sp, 60   # Deallocate the stack space



    



  





    beq $k0, 42,heree

    li $v0, 15

    move $a0, $s0             # File descriptor

    la $a1, promptZ

    li $a2, 2

    syscall

    

    sub $sp, $sp, 60   # Allocate space on the stack (3 registers x 4 bytes)

    sw $t0, 44($sp)     # Save $t0 to the stack

    sw $t1, 48($sp)     # Save $t1 to the stack

    sw $t2, 52($sp)     # Save $t2 to the stack

    sw $t3, 16($sp)     # Save $t2 to the stack

    sw $t4, 20($sp)     # Save $t2 to the stack

    sw $t5, 24($sp)     # Save $t2 to the stack

    sw $t6, 28($sp)     # Save $t2 to the stack

    sw $t7, 32($sp)     # Save $t2 to the stack

    sw $t9, 36($sp)     # Save $t2 to the sta

    s.s $f3, 56($sp)

    s.s $f4, 60($sp)

    sw $s0, 40($sp)     # Save $t2 to the stack

    

    la $t2, pointer           

    sw $s0, 0($t2)

            

    la $t0,   float_num         # Load the address of 'num' into register $t0

    swc1 $f4, 0($t0) 



    jal FloatFile    # Call the function



    lw $t0, 44($sp)     # Restore $t0 from the stack

    lw $t1, 48($sp)     # Restore $t1 from the stack

    lw $t2, 52($sp)     # Restore $t2 from the stack

    lw $t3, 16($sp)     # Restore $t2 from the stack

    lw $t4, 20($sp)     # Restore $t2 from the stack

    lw $t5, 24($sp)     # Restore $t2 from the stack

    lw $t6, 28($sp)     # Restore $t2 from the stack

    lw $t7, 32($sp)     # Restore $t2 from the stack

    lw $t9, 36($sp)     # Restore $t2 from the stack

    lw $s0, 40($sp)     # Restore $t2 from the stack

    l.s $f3, 56($sp)

    l.s $f4, 60($sp)

    add $sp, $sp, 60   # Deallocate the stack space



    





heree:

    li $v0, 15

    move $a0, $s0             # File descriptor

    la $a1, newline

    li $a2, 1

    syscall



    li $t4, 0            # Reset counter

    j lpp



store_number2:

    # Store numbers in x, y, z

    beq $t4, 0, store_x2

    beq $t4, 1, store_y2

    beq $t4, 2, store_z2



store_x2:

    mov.s $f0, $f1

    addi $t4, $t4, 1

    j lpp



store_y2:

    mov.s $f3, $f1

    addi $t4, $t4, 1

     li $k0, 42

    j lpp



store_z2:

    mov.s $f4, $f1

    addi $t4, $t4, 1

     li $k0, 0

    j lpp



handle_i2:

    # Write error message

    

    

     li $v0, 15

    move $a0, $s0         # File descriptor

    la $a1, Msg           # Message to write

    li $a2, 8            # Message length

    syscall





  

    

    sub $sp, $sp, 52   # Allocate space on the stack (3 registers x 4 bytes)

    sw $t0, 44($sp)     # Save $t0 to the stack

    sw $t1, 48($sp)     # Save $t1 to the stack

    sw $t2, 52($sp)     # Save $t2 to the stack

    sw $t3, 16($sp)     # Save $t2 to the stack

    sw $t4, 20($sp)     # Save $t2 to the stack

    sw $t5, 24($sp)     # Save $t2 to the stack

    sw $t6, 28($sp)     # Save $t2 to the stack

    sw $t7, 32($sp)     # Save $t2 to the stack

    sw $t9, 36($sp)     # Save $t2 to the sta

    

    sw $s0, 40($sp)     # Save $t2 to the stack

    

    la $t2, pointer           

    sw $s0, 0($t2)        



    la $t1, num           # Load the address of 'num' into $t1

    sw $t9, 0($t1)        # Store the value in $t0 into 'num' (address in $t1)



    jal PrintInt    # Call the function



    lw $t0, 44($sp)     # Restore $t0 from the stack

    lw $t1, 48($sp)     # Restore $t1 from the stack

    lw $t2, 52($sp)     # Restore $t2 from the stack

    lw $t3, 16($sp)     # Restore $t2 from the stack

    lw $t4, 20($sp)     # Restore $t2 from the stack

    lw $t5, 24($sp)     # Restore $t2 from the stack

    lw $t6, 28($sp)     # Restore $t2 from the stack

    lw $t7, 32($sp)     # Restore $t2 from the stack

    lw $t9, 36($sp)     # Restore $t2 from the stack

    lw $s0, 40($sp)     # Restore $t2 from the stack

    add $sp, $sp, 52   # Deallocate the stack space





   li $v0, 15

    move $a0, $s0             # File descriptor

    la $a1, newline

    li $a2, 1

    syscall

   



    li $v0, 15

    move $a0, $s0

    la $a1, errorMsg

    li $a2, 29

    syscall



    li $t4, 0

    j lpp



end_loop2:

    # Close the file

    li $v0, 16

    move $a0, $s0

    syscall







 j loopp                   # jump back to the start of the loop



 



#*********************************************************************************************************

 #Coverts Floats Into String and prints them to the file 



FloatFile:



    addi $sp, $sp, -4   # Make space on the stack

    sw $ra, 0($sp)      # Save $ra (return address to main)





    # Load the floating-point number

    la $t0, float_num

    lwc1 $f0, 0($t0)          # Load float into $f0



    # Step 1: Extract the integer part

    cvt.w.s $f1, $f0          # Convert float $f0 to integer (rounded down)

    mfc1 $t1, $f1             # Move integer part to $t1

    la $t2, int

    sw $t1, 0($t2)            # Store integer part in int_part



    # Step 2: Extract the fractional part

    mtc1 $t1, $f2             # Move integer part back to $f2

    cvt.s.w $f2, $f2          # Convert it back to float

    sub.s $f3, $f0, $f2       # Subtract integer part from original float (fractional part)



    # Step 3: Scale the fractional part to get the ratio

    la $t0, hundreds       # Load the address of the float_value

    lwc1 $f4, 0($t0)

    mul.s $f5, $f3, $f4       # Multiply fractional part by 100

    cvt.w.s $f6, $f5          # Convert result to integer

    mfc1 $t3, $f6             # Move ratio to $t3

    la $t4, ratio

    li $t0 , 0x00000001
    
    sw $t0, 0($t4)            # Store ratio in ratio_part
    
    sw $t3, 0($t4)            # Store ratio in ratio_part




 

    move $a0, $t2             # Load ratio part into $a0

    

    # First number : 

   





    # First number: Load integer and call int_to_string

    lw $t0, int               # Load integer value

    la $a0, buffer            # Address of the buffer

    move $a1, $t0             # Copy integer to $a1

 

  

    

    jal int_to_string         # Convert integer to string



    # Write the integer to the file

    la $t1, buffer            # Load address of buffer

    li $t2, 0                 # Initialize string length counter ($t2 = 0)

count_length_1:

    lb $t3, 0($t1)            # Load byte from buffer

    beqz $t3, write_first     # If byte is null terminator, stop counting

    addi $t2, $t2, 1          # Increment string length

    addi $t1, $t1, 1          # Move to the next byte

    j count_length_1          # Repeat until null terminator



write_first:

    # Write the first number to the file

    li $v0, 15                # Syscall: write

    move $a0, $s0             # File descriptors

    la $a1, buffer            # Address of buffer

    move $a2, $t2             # Length of the string

    syscall

     

    # Write the dot to the file

    li $v0, 15                # Syscall: write

    move $a0, $s0             # File descriptor

    la $a1, dot               # Address of dot

    li $a2, 1                 # Length of dot (1 byte)

    syscall



    # Second number: Load ratio and call int_to_string

    lw $t0, ratio             # Load ratio value

    la $a0, buffer            # Address of the buffer

    move $a1, $t0             # Copy ratio to $a1

      li $v1 , 1

    sw $v1 , dont#lllllllllllllllllll;;;;;;;;;;;

    jal int_to_string         # Convert ratio to string



    # Write the ratio to the file

    li $v0, 15                # Syscall: write

    move $a0, $s0             # File descriptor

    la $a1, buffer            # Address of buffer

    li $t0, 4   

    move $a2, $t0             # ************************************** IMP

    syscall

    

    li $v0, 15

    la $a1, newline

    li $a2, 1

    syscall

    







 



    # Exit the program

    lw $ra, 0($sp)      # Restore $ra (return address to main)

    addi $sp, $sp, 4    # Clean up stack

    jr $ra              # Return to main



# Function: int_to_string

# Converts an integer in $a1 to a null-terminated string at the address in $a0

# (No changes made to the function itself)

int_to_string:

    addiu $sp, $sp, -16    # Allocate stack space

    sw $ra, 12($sp)        # Save return address

    sw $a1, 8($sp)         # Save original integer

    sw $a0, 4($sp)         # Save buffer address



    li $t2, 0              # Flag for negative number



    # Handle negative numbers

    bltz $a1, make_positive

    j convert_digits



make_positive:

    li $t2, 1              # Set negative flag

    negu $a1, $a1          # Make the number positive



convert_digits:

    li $t3, 10             # Divisor (10)

    li $t1, 0              # Index for reverse buffer

reverse_digits:

    div $a1, $t3           # Divide $a1 by 10

    mfhi $t4               # Remainder (current digit)

    mflo $a1               # Quotient (remaining number)



    addiu $t4, $t4, 48     # Convert digit to ASCII ('0' = 48)

    sb $t4, 0($a0)         # Store digit in buffer



    addiu $a0, $a0, 1      # Move buffer pointer forward

    addiu $t1, $t1, 1      # Increment index



    bnez $a1, reverse_digits # Repeat until quotient is 0



    bgtz $t0, skipp

    lw $v1 , dont

    beq $v1 ,1 , skipp

    li $a3, '-'

    sb $a3, 0($a0)  

    addi $t1, $t1, 1

    addi $a0, $a0, 1

skipp:

    

    li $v1,0

    sw $v1,dont

    # Add null terminator

    li $t4, 0              # Null terminator

    sb $t4, 0($a0)         # Store null terminator



    la $a0, buffer

    move $s3, $t1          

    subi $t1, $t1, 1

    add $t2, $a0, $t1    

    div $t1, $t1, 2

    add $t1, $t1, 1



reverse:

    beqz $t1, done 

    lb $t4, 0($a0)         

    lb $t5, 0($t2)        

    sb $t4, 0($t2)        

    sb $t5, 0($a0)        

    subu $t2, $t2, 1      

    addu $a0, $a0, 1

    addiu $t1, $t1, -1     

    j reverse



done:

    la $a0, buffer

    add $a0, $a0, $s3

    lw $ra, 12($sp)        # Restore return address

    addiu $sp, $sp, 16     # Deallocate stack space

    jr $ra                 # Return to caller



#***********************************************************

 #Coverts Integers Into String and prints it to the file

 

 

 PrintInt:

 

    addi $sp, $sp, -4   # Make space on the stack

    sw $ra, 0($sp)      # Save $ra (return address to main)

    



    # First number: Load integer and call int_to_string

    lw $t0, num               # Load integer value

    la $a0, buffer            # Address of the buffer

    move $a1, $t0             # Copy integer to $a1

    jal int_to_string         # Convert integer to string



    # Write the integer to the file

    la $t1, buffer            # Load address of buffer

    li $t2, 0                 # Initialize string length counter ($t2 = 0)

count_length:

    lb $t3, 0($t1)            # Load byte from buffer

    beqz $t3, write    # If byte is null terminator, stop counting

    addi $t2, $t2, 1          # Increment string length

    addi $t1, $t1, 1          # Move to the next byte

    j count_length          # Repeat until null terminator



write:

    # Write the first number to the file

    

    lw $s0, pointer               # Load integer value

    li $v0, 15                # Syscall: write

    move $a0, $s0             # File descriptor

    la $a1, buffer            # Address of buffer

    li $a2, 0x1             # Length of the string

    syscall 



   

    li $v0, 4           # Syscall for print string

    la $a0, buffer      # Address of the string

    syscall

    

    

    lw $ra, 0($sp)      # Restore $ra (return address to main)

    addi $sp, $sp, 4    # Clean up stack

    jr $ra              # Return to main


