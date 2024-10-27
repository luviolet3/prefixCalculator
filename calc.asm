# Supported instructions:
# Arithmatic:
#   +: addition
#   -: subtraction
#   *: multiplication
#   /: division
#   %: modulus
# Logic:
#  &&: logical and
#  ||: logical or
#   !: logical not
# Bitwise:
#   &: bitwise and
#   |: bitwise or
#   ~: bitwise not
#   ^: bitwise xor
#  >>: right shift
#  <<: left shift
# Rational:
#  ==: equals
#  !=: not equals
#   <: less than
#  <=: less than equals
#   >: greater than
#  >=: greater than equals
# Assignment:
#   =: assignment
#  +=: addition 
#  -=: subtraction
#  *=: multiplication
#  /=: division
#  %=: modulus
#  &=: bitwise and
#  |=: bitwise or
#  ^=: bitwise xor
#  ++: increment
#  --: decrement
# Other:
#   .: pop stack

.data
instructions: .asciiz "Insert expression to solve in prefix notation (ie + 1 2 instead of 1 + 2) with spaces between tokens.\nSupported operations:\nc arithmetic, comparison, logical, bitwise, and assignment operations\n. : pop value from stack (usefull for assignments. i.e. \". = a 1 + a 1\" will first assign 1 to a, then return a + 1)\n"
unknown_op_msg: .asciiz "\nError: unknown operation: "
out_of_tokens_msg: .asciiz "\nError: out of tokens to parse"
divide_by_zero_msg: .asciiz "\nError: divide by zero"
not_var_msg: .asciiz "\nError: unknown variable: "

.align 2
vars: .space 208

.text
.globl main
main:
  bne $a0 $zero start
  la $a0 instructions
  li $v0 4
  syscall
  li $a0 1
  li $v0 17
  syscall
start:
  # I'm using $s0 and $s1 as global variables, so they are not going on the stack
  move $s0 $a0 # argc
  move $s1 $a1 # argv

  lw $a0 0($s1)
  jal parse_token
  
  move $v1 $v0
  
  move $a0 $v0
  li $v0 1
  syscall
  
  la $a0 0
  li $v0 17
  syscall
  
parse_token:
  subi $sp $sp 4
  sw $ra 0($sp)
  addi $s1 $s1 4
  subi $s0 $s0 1

  bltz $s0 err_out_of_tokens
  lbu $t0 0($a0)
  li $t7 57
  slti $t7 $t0 57
  bne $t7 $zero ascii_number
  sgeu $t8 $t0 'a'
  sleu $t9 $t0 'z'
  and $t1 $t8 $t9
  sgeu $t8 $t0 'A'
  sleu $t9 $t0 'Z'
  and $t2 $t8 $t9
  or $t1 $t1 $t2
  bnez $t1 ascii_letter
  j ascii_operator
ascii_number:
  slti $t7 $t0 48
  beq $t7 $zero parse_token_number
ascii_operator:
  li $t7 45
  bne $t0 $t7 parse_token_operator
ascii_negative:
  lbu $t1 1($a0)
  beq $t1 $zero parse_token_operator
ascii_letter:
  move $a0 $t0
  jal get_variable_index
  lw $v0 0($v0)
  j parse_token_return

parse_token_number:
  jal parse_number
  j parse_token_return
parse_token_operator:
  jal parse_operator
  j parse_token_return
parse_token_return:
  lw $ra 0($sp)
  addi $sp $sp 4
  jr $ra
  
# parse and return the memory address of a variable
parse_variable:
	subi $sp $sp 4
	sw $ra 0($sp)
	addi $s1 $s1 4
  subi $s0 $s0 1
  bltz $s0 err_out_of_tokens
  
  lbu $a0 0($a0)
  move $v1 $a0
  jal get_variable_index
  
  lw $ra 0($sp)
	addi $sp $sp 4
  jr $ra

parse_operator:
  # $a0 operator
  #
  # 0($sp) $ra
  # 4($sp) $s3
  # 8($sp) $s4
  # 12($sp) $s5
  # 16($sp) $s6
  #
  # $s3 operator
  # $s4 lhs
  # $s5 rhs
  # $s6 instruction address
  subi $sp $sp 20
  sw $ra 0($sp)
  sw $s3 4($sp)
  sw $s4 8($sp)
  sw $s5 12($sp)
  sw $s6 16($sp)

  move $s3 $a0

assignment_op:
  lbu $t0 0($s3)
  lbu $t1 1($s3)
  seq $t8 $t0 '='
  seq $t9 $t1 $zero
  and $t8 $t8 $t9
  bnez $t8 assign # $s3 contains /=/
  bne $t1 '=' one_token # filter out /.[^=]/
  beq $t0 '!' one_token # filter out /!.*/
  beq $t0 '<' one_token # filter out /<.*/
  beq $t0 '>' one_token # filter />.*/

	assign:
  # $s3 contains /[^!=<>]?=/

  lw $a0 0($s1)
  jal parse_variable
  move $s4 $v0
  move $s6 $v1
  
  lw $a0 0($s1)
  jal parse_token
  move $s5 $v0
  
  move $a0 $s6
  li $v0 11
  syscall
  
  lbu $t0 0($s3)
check_assignment:
	bne $t0 '=' check_assign_add
	sw $s5 0($s4)
	move $v0 $s5
	j parse_operator_return
check_assign_add:
  bne $t0 '+' check_assign_sub
  lw $t0 0($s4)
  add $t0 $t0 $s5
  sw $t0 0($s4)
  move $v0 $t0
  j parse_operator_return
check_assign_sub:
  bne $t0 '-' check_assign_mult
  lw $t0 0($s4)
  sub $t0 $t0 $s5
  sw $t0 0($s4)
  move $v0 $t0
  j parse_operator_return
check_assign_mult:
  bne $t0 '*' check_assign_div
  lw $t0 0($s4)
  mult $t0 $s5
  mflo $t0
  sw $t0 0($s4)
  move $v0 $t0
  j parse_operator_return
check_assign_div:
  bne $t0 '/' check_assign_mod
  lw $t0 0($s4)
  div $t0 $t5
  mflo $t0
  sw $t0 0($s4)
  move $v0 $t0
  j parse_operator_return
check_assign_mod:
  bne $t0 '%' check_assign_and
  lw $t0 0($s4)
  div $t0 $t5
  mfhi $t0
  sw $t0 0($s4)
  move $v0 $t0
  j parse_operator_return
check_assign_and:
  bne $t0 '&' check_assign_or
  lw $t0 0($s4)
  and $t0 $t0 $s5
  sw $t0 0($s4)
  move $v0 $t0
  j parse_operator_return
check_assign_or:
  bne $t0 '|' check_assign_xor
  lw $t0 0($s4)
  or $t0 $t0 $s5
  sw $t0 0($s4)
  move $v0 $t0
  j parse_operator_return
check_assign_xor:
  bne $t0 '^' err_unknown_op
  lw $t0 0($s4)
  xor $t0 $t0 $s5
  sw $t0 0($s4)
  move $v0 $t0
  j parse_operator_return


	
	j err_unknown_op
one_token:

  #lw $a0 0($s1)
  #jal parse_token
  #move $s4 $v0
  
  lbu $t0 0($s3)
  
  li $t7 '~'
  bne $t0 $t7 check_not
  la $s6 bit_not
  j get_single_token
check_not:
  li $t7 '!'
  bne $t0 $t7 two_tokens
  lbu $t1 1($s3)
  bnez $t1 check_ne
  la $s6 not
  j get_single_token
check_ne:
  li $t7 '='
  bne $t1 $t7 err_unknown_op
  la $s6 ne
  j get_two_tokens
  

get_single_token:
  lw $a0 0($s1)
  jal parse_token
  move $s4 $v0

print_single_token:

  move $a0 $s3
  li $v0 4
  syscall
  move $a0 $s4
  li $v0 1
  syscall
  
  jr $s6
  
two_tokens:
  
  lbu $t0 0($s3)
  
  li $t7 '+'
  bne $t0 $t7 check_sub
  la $s6 add
  j get_two_tokens
check_sub:
  li $t7 '-'
  bne $t0 $t7 check_mul
  la $s6 sub
  j get_two_tokens
check_mul:
  li $t7 '*'
  bne $t0 $t7 check_div
  la $s6 mul
  j get_two_tokens
check_div:
  li $t7 '/'
  bne $t0 $t7 check_mod
  la $s6 div
  j get_two_tokens
check_mod:
  li $t7 '%'
  bne $t0 $t7 check_bit_and
  la $s6 mod
  j get_two_tokens
check_bit_and:
  li $t7 '&'
  bne $t0 $t7 check_bit_or
  la $s6 bit_and
  j get_two_tokens
check_bit_or:
  li $t7 '|'
  bne $t0 $t7 check_bit_xor
  la $s6 bit_or
  j get_two_tokens
check_bit_xor:
  li $t7 '^'
  bne $t0 $t7 check_lt
  la $s6 bit_xor
  j get_two_tokens
check_lt:
  li $t7 '<'
  bne $t0 $t7 check_gt
  la $s6 lt
  j get_two_tokens
check_gt:
  li $t7 '>'
  bne $t0 $t7 check_eq
  la $s6 gt
  j get_two_tokens
check_eq:
  li $t7 '='
  bne $t0 $t7 check_pop
  la $s6 eq
  j get_two_tokens
check_pop:
  li $t7 '.'
  bne $t0 $t7 err_unknown_op
  la $s6 pop
  j get_two_tokens

  
get_two_tokens:
  lw $a0 0($s1)
  jal parse_token
  move $s4 $v0

  lw $a0 0($s1)
  jal parse_token
  move $s5 $v0

  la $t0 pop
  bne $t0 $s6 print_two_tokens
  
  move $a0 $s5
  li $v0 1
  syscall
  
  jr $s6
  
  

print_two_tokens:
  move $a0 $s4
  li $v0 1
  syscall
  li $a0 ' '
  li $v0 11
  syscall
  move $a0 $s3
  li $v0 4
  syscall
  li $a0 ' '
  li $v0 11
  syscall
  move $a0 $s5
  li $v0 1
  syscall
  
  jr $s6

add:
  lbu $t0 1($s3)
  bnez $t0 err_unknown_op
  add $v0 $s4 $s5
  j parse_operator_return
sub:
  lbu $t0 1($s3)
  bnez $t0 err_unknown_op
  sub $v0 $s4 $s5
  j parse_operator_return
mul:
  lbu $t0 1($s3)
  bnez $t0 err_unknown_op
  mult $s4 $s5
  mflo $v0
  j parse_operator_return
div:
  lbu $t0 1($s3)
  bnez $t0 err_unknown_op
  beqz $s5 err_div_by_zero
  div $s4 $s5
  mflo $v0
  j parse_operator_return
mod:
  lbu $t0 1($s3)
  bnez $t0 err_unknown_op
  div $s4 $s5
  mfhi $v0
  j parse_operator_return
bit_and:
  lbu $t0 1($s3)
  li $t7 '&'
  beq $t0 $t7 and
  bnez $t0 err_unknown_op
  and $v0 $s4 $s5
  j parse_operator_return
bit_or:
  lbu $t0 1($s3)
  li $t7 '|'
  beq $t0 $t7 or
  bnez $t0 err_unknown_op
  or $v0 $s4 $s5
  j parse_operator_return
bit_xor:
  lbu $t0 1($s3)
  bnez $t0 err_unknown_op
  xor $v0 $s4 $s5 
  j parse_operator_return
bit_not:
  lbu $t0 1($s3)
  bnez $t0 err_unknown_op
  not $v0 $s4
  j parse_operator_return
and:
  lbu $t0 2($s3)
  bnez $t0 err_unknown_op
  move $a0 $s4
  jal itob
  move $s4 $v0
  move $a0 $s5
  jal itob
  move $s5 $v0
  and $v0 $s4 $s5
  j parse_operator_return
or:
  lbu $t0 2($s3)
  bnez $t0 err_unknown_op
  move $a0 $s4
  jal itob
  move $s4 $v0
  move $a0 $s5
  jal itob
  move $s5 $v0
  or $v0 $s4 $s5
  j parse_operator_return
not:
  lbu $t0 1($s3)
  bnez $t0 err_unknown_op
  move $a0 $s4
  jal itob
  xor $v0 1
  j parse_operator_return
rshift:
  lbu $t0 2($s3)
  bnez $t0 err_unknown_op
  li $v0 0
  slti $t0 $s5 32
  beqz $t0 parse_operator_return
  srav $v0 $s4 $s5
  j parse_operator_return
lshift:
  lbu $t0 2($s3)
  bnez $t0 err_unknown_op
  li $v0 0
  slti $t0 $s5 32
  beqz $t0 parse_operator_return
  sllv $v0 $s4 $s5
  j parse_operator_return
lt:
  lbu $t0 1($s3)
  li $t7 '<'
  beq $t0 $t7 lshift
  li $t7 '='
  beq $t0 $t7 lte
  slt $v0 $s4 $s5
  j parse_operator_return
lte:
  lbu $t0 2($s3)
  bnez $t0 err_unknown_op
  slt $v0 $s5 $s4
  xor $v0 1
  j parse_operator_return
gt:
  lbu $t0 1($s3)
  li $t7 '>'
  beq $t0 $t7 rshift
  li $t7 '='
  beq $t0 $t7 gte
  slt $v0 $s5 $s4
  j parse_operator_return
gte:
  lbu $t0 2($s3)
  bnez $t0 err_unknown_op
  slt $v0 $s4 $s5
  xor $v0 1
  j parse_operator_return
eq:
  lbu $t0 1($s3)
  li $t7 '='
  bne $t0 $t7 err_unknown_op
  lbu $t0 2($s3)
  bnez $t0 err_unknown_op
  seq $v0 $s4 $s5
  j parse_operator_return
ne:
  lbu $t0 2($s3)
  bnez $t0 err_unknown_op
  sne $v0 $s4 $s5
  j parse_operator_return
pop:
  lbu $t0 2($s3)
  bnez $t0 err_unknown_op
  move $v0 $s5
  j parse_operator_return
  
parse_operator_return:
  move $t0 $v0
  li $a0 ' '
  li $v0 11
  syscall
  li $a0 '='
  syscall
  li $a0 ' '
  syscall
  move $a0 $t0
  li $v0 1
  syscall
  li $a0 10
  li $v0 11
  syscall
  move $v0 $t0
  
  lw $ra 0($sp)
  lw $s3 4($sp)
  lw $s4 8($sp)
  lw $s5 12($sp)
  lw $s6 16($sp)
  addi $sp $sp 20
  jr $ra

# get the memory address of a variable
get_variable_index:
  blt $a0 'A' err_not_var
  ble $a0 'Z' is_upper
  blt $a0 'a' err_not_var
  bgt $a0 'z' err_not_var
is_lower:
  subi $t0 $a0 'a'
  addi $t0 $t0 26
  j get_variable_index_return
is_upper:
  subi $t0 $a0 'A'
get_variable_index_return:
  li $t1 '4'
  mult $t0 $t1
  mflo $t0
  la $t1 vars
  add $v0 $t0 $t1
  jr $ra

# takes a string containing a number and parses it into a 32 bit number
parse_number:
  li $v0 0
  li $t1 1
  li $t7 '-'
  lbu $t0 0($a0)
  bne $t0 $t7 parse_number_loop
  li $t1 -1
  addi $a0 $a0 1
parse_number_loop:
  lbu $t0 0($a0)
  beqz $t0 parse_number_return # return if at end of string
  li $t7 ' '
  beq $t0 $t7 parse_number_return # return if space

  li $t0 10
  mult $v0 $t0
  mflo $v0 # $multiply $v0 by 10
  
  lbu $t0 0($a0)
  subu $t0 $t0 '0'
  add $v0 $v0 $t0 # add number to $v0

  addi $a0 $a0 1
  j parse_number_loop
parse_number_return:
  mult $v0 $t1
  mflo $v0
  jr $ra

# returns 0 if $a0 is 0, 1 otherwise
itob:
  li $v0 0
  beq $a0 $zero itob_return
  li $v0 1
itob_return:
  jr $ra
  
err_unknown_op:
  la $a0 unknown_op_msg
  li $v0 4
  syscall
  move $a0 $s3
  syscall
  li $a0 '\n'
  li $v0 11
  syscall
  li $a0 1
  li $v0 17
  syscall

err_out_of_tokens:
  la $a0 out_of_tokens_msg
  li $v0 4
  syscall
  li $a0 1
  li $v0 17
  syscall

err_div_by_zero:
  la $a0 divide_by_zero_msg
  li $v0 4
  syscall
  li $a0 1
  li $v0 17
  syscall

err_not_var:
	move $t0 $a0
  la $a0 not_var_msg
  li $v0 4
  syscall
  move $a0 $t0
  li $v0 11
  syscall
  li $a0 '\n'
  syscall
  li $a0 1
  li $v0 17
  syscall
 
  
