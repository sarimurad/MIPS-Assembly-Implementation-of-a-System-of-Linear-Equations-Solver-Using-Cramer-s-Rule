#				ENCS4370
#             Project 1
# 	Dr.Ayman Hroub

#       Students    -    ID   - Section
#	Sari Abdalghani - 1220982 -   3
#	Hashem Ahmad    - 1220948 -   3


.data
    inputFile:   .space 50    
    buffer:     .space 1000				 		# contant of the input file
    outputFile:   .asciiz "output.txt"
    firstMessage:     .asciiz "Enter the File name or his Path: "
    errorFile:  .asciiz "***ERROR: the file can't open****\n"
    errorNumEquation:  .asciiz "\n***ERROR: number of equation is error***"
    Menu : .asciiz "Menu:\n1-write 'F' or 'f' to save the results in output file\n2-write 'S' or 's' to print results on the screen\n3- write 'E' or 'e' to exit\n"
    errorOptions: .asciiz "\n***ERROR:Please write one of menu options***\n"
    errorDetarmin: .asciiz "\n***ERROR: Main detarmin is equal to zero***\n"
    newLine:    .asciiz "\n"
    X_message: .asciiz "\nX = "
    Y_message: .asciiz "\nY = "
    Z_message: .asciiz "\nZ = "
    menuChar:   .space 4  					# option character (s,S , f,F or e,E )
    numEquations: .word 0
    X_coefficient: .space 12
    Y_coefficient: .space 12
    Z_coefficient:  .space 12
    A_answers: .space 12
    detA: .space 4
    X: .space 4
    Y: .space 4
    Z: .space 4
    
    Storge:      .space  32              # to convert floating point to ascii
    temp:        .space  32              # used for fraction
    ten:         .float  10.0            
    zero:      .float  0.0             
    minus:       .asciiz "-"            
    point:       .asciiz "."            
.text
.globl main
main:
#print the menu
	li $v0, 4
    la $a0, Menu
    syscall
# check if past char is f close file  
	lb $t8,menuChar
    beq $t8,'f', closeOutputFile
    beq $t8,'F', closeOutputFile
    j readAndPrint
    
closeOutputFile:
    li   $v0, 16              # syscall 16: close file
    lw $a0,0($sp)             # file descriptor
    syscall
    
#read menu option
readAndPrint:
    li $v0, 8               # 8 : to read
    la $a0, menuChar       
    li $a1, 4             
    syscall
    
#check menu char
	la $t0, menuChar
	lb $t2,($t0)
	beq $t2,'E',exit
	beq $t2,'e',exit
	beq $t2,'F',OpenFile
	beq $t2,'f',OpenFile
	beq $t2,'S',start
	beq $t2,'s',start

	li $v0, 4				#if the option note exisit in menu
    la $a0, errorOptions
    syscall
    j main
#---------------------------------------------------------
#oprn file for write
OpenFile:
	li   $v0, 13               
    la   $a0, outputFile        
    li   $a1, 1                # flag: 1 for write
    li   $a2, 0              
    syscall
    sw $v0,0($sp)
	
#----------------------------------------------------------
# Print file message to read name of the file
start:
    li $v0, 4				
    la $a0, firstMessage
    syscall

    # Read filename:
    li $v0, 8 
    la $a0, inputFile       
    li $a1, 50             
    syscall

    la $t0, inputFile        
#---------------------------------------------------------
# to remove new line from end of name of file
removeNewline:
    lb $t1, ($t0)          
    beqz $t1, openFile    
    beq $t1, 10, replace   
    addi $t0, $t0, 1       
    j removeNewline
#---------------------------------------------------------
replace:
    sb $zero, ($t0)        # remove new line and set null
#---------------------------------------------------------
openFile:
    # Open file
    li $v0, 13             
    la $a0, inputFile      
    li $a1, 0              
    li $a2, 0             
    syscall

    # Check for errors
    bltz $v0, errorOpen     
    move $s0, $v0         

    # Read from file
    li $v0, 14            
    move $a0, $s0      
    la $a1, buffer         
    li $a2, 1000           
    syscall

    # Close file
    li $v0, 16                   
    syscall
#---------------------------------------------------------   
 
    la $t0, buffer         # t0 will be pointer to the charecters in buffer

# change $s0 address and reset
changeAddress:
    move $s0,$t0
    la $s2 , A_answers
	la $t5,X_coefficient
	la $t6,Y_coefficient
	la $t7,Z_coefficient
    li $t1,0
    li $s1,0
    sw $t1,0($t5)
    sw $t1,4($t5)
    sw $t1,8($t5)
    sw $t1,0($t6)
    sw $t1,4($t6)
    sw $t1,8($t6)
    sw $t1,0($t7)
    sw $t1,4($t7)
    sw $t1,8($t7)
    sw $t1,0($s2)
    sw $t1,4($s2)
    sw $t1,8($s2)
    
    li $t1, 0  
#---------------------------------------------------------
# calculate number of equation for the current system
numOfEquations:
    lb  $t2, ($t0)        
    beq $t2, '\n' , checkEnd 
    beq $t2, 0 , endOfEquations			
    beq $t2, '=', calculateNum
    addi $t0, $t0, 1
    j numOfEquations
#---------------------------------------------------------
# if there two new lines in sequnce the system will be finish
checkEnd:
	addi $t0, $t0, 1
	lb  $t2, ($t0)  
	beq $t2, 13 , endOfEquations
	beq $t2, 0 , endOfEquations
	j numOfEquations
 #---------------------------------------------------------   
calculateNum:
	addi $t1,$t1,1
	addi $t0, $t0, 1
	j numOfEquations
#---------------------------------------------------------
# if num of equations equal zero its mean we in the end of file
endOfEquations: 
	sw $t1, numEquations
	beq $t1 ,0, main    
	beq $t1 ,2, System2x2
	beq $t1 ,3, System3x3             
	j equationsNumError
#----------------------------------------------------------
# $s0 is the first byte of the system
System2x2:
	move $t4,$s0
	j start2x2
#----------------------------------------------------------
start2x2:
	la $ra,start2x2  			# we use this becuase there is an label for 3x3 and 2x2
	li $s4,0
	li $t1,1					# to set it neg or pos
	li $t8,1 					# if coffetiont equal 1 ot -1
	lb  $t2, ($t4)  
	beq $t2, '=' , insertA       
    beq $t2, 'x' , insertX 
    beq $t2, 'y', insertY
    addi $t4, $t4, 1
    beq $t2, '\n', increment2x2
    beq $t2, 0, increment2x2
    
    beq $t2,' ',start2x2
    beq $t2,'+',start2x2
    beq $t2,'-',start2x2
    beq $t2,13,start2x2
    bltu $t2,'0',equationsNumError
    bgtu $t2,'9',equationsNumError
    j start2x2
increment2x2:
	addi $s1,$s1,1
    bge $s1,2,cacululate2x2
    j start2x2
#----------------------------------------------------------
cacululate2x2:
	lw $t1,0($t5)
	lw $t2,4($t6)
	mul $t1,$t1,$t2   				#mul X1 x Y2
	lw $t3,4($t5)
	lw $t4,0($t6)
	mul $t3,$t3,$t4					#mul X2 x Y1
	sub $t1,$t1,$t3					#sub (X1 x Y2) - (X2 x Y1)
	sw $t1,detA
	beqz $t1,detarminIsZero			# if determin is zero is error
	jal calcX2x2					#calculate X
	jal calcY2x2					#calculate Y
	
	lb $t8,menuChar
	beq $t8,'S' printScreen2X2
	beq $t8,'s' printScreen2X2
	j printFile2x2
	
#------------------------------------------------------------
calcX2x2:
	lw $t1,0($s2)
	lw $t2,4($t6)
	mul $t1,$t1,$t2					#mul A1 x Y2
	
	lw $t3,4($s2)
	lw $t4,0($t6)
	mul $t3,$t3,$t4					#mul A2 x Y1
	
	sub $t1,$t1,$t3					#sub (A1 x Y2) - (A2 x Y1)
	# after calculate |X| we will calculate X	
	# for division we will convert the int to float point to give us the correct value
	lwc1 $f4,detA
	cvt.s.w $f4,$f4
	mtc1 $t1,$f6
	cvt.s.w $f6,$f6
	div.s $f8,$f6,$f4
	
	l.s $f10,zero
	c.eq.s 1,$f10,$f8
#	bc1t setXtoZero
	
	s.s $f8,X
	jr $ra
#----------------------------------------------------------
# if X equal Zero
setXtoZero:
	s.s $f10,X
	jr $ra
#----------------------------------------------------------
#same as calculate X but some change in Registers
calcY2x2:
	lw $t1,0($t5)
	lw $t2,4($s2)
	mul $t1,$t1,$t2
	lw $t3,4($t5)
	lw $t4,0($s2)
	mul $t3,$t3,$t4
	sub $t1,$t1,$t3
		
	lwc1 $f4,detA
	cvt.s.w $f4,$f4
	mtc1 $t1,$f6
	cvt.s.w $f6,$f6
	div.s $f8,$f6,$f4
	l.s $f10,zero
	c.eq.s  $f10,$f8
#	bc1t setYtoZero
	s.s $f8,Y
	

	jr $ra
#----------------------------------------------------------
setYtoZero:
	s.s $f10,Y
	jr $ra
#----------------------------------------------------------
# to print the values in screen
printScreen2X2:
	li $v0, 4			
    la $a0, X_message
    syscall
    
    l.s $f12,X
	li $v0,2
	syscall
	
	li $v0, 4				
    la $a0, Y_message
    syscall
    
    l.s $f12,Y
	li $v0,2
	syscall
	
	li $v0, 4				
    la $a0,newLine
    syscall
	la $t0,2($t0)
	
	j changeAddress			# return ro start new system
#----------------------------------------------------------	
#to print the values in output file
printFile2x2:
    
    # first we need to convert X from float pont to ascii
	l.s  $f12, X
    la   $a0, Storge          
    jal  ConvertToAscii
    
    
    
    li $v0, 15	
    lw $a0,0($sp)			 # file descriptor
    la $a1, X_message
    li   $a2, 4
    syscall
    
    li   $v0, 15              
    lw $a0,0($sp)             
    la   $a1, Storge         # after convert X to ascii we save its value in Storge 
    syscall
    
    # now we will convert Y
    l.s  $f12, Y    
    la   $a0, Storge         
    jal  ConvertToAscii
    
    li $v0, 15	
    lw $a0,0($sp)		
    la $a1, Y_message
    li   $a2, 4
    syscall
    
    li   $v0, 15              
    lw $a0,0($sp)           
    la   $a1, Storge         
    syscall
    
    li   $v0, 15
    lw $a0,0($sp)
    la   $a1, newLine
    li   $a2, 1
    syscall

	la $t0,2($t0)
	j changeAddress 				# return ro start new system
	
#-------------------------------------------------------------------
ConvertToAscii:
	move $s0, $a0    
    move $s1, $s0 
    # Check if number is negative
    l.s  $f0, zero
    c.lt.s $f12, $f0
    bc1f positive
    
    abs.s $f12, $f12          # take absolute value
    la   $a0, minus           # load minus sign to Storge
    lb   $t9, ($a0)
    sb   $t9, ($s1)   
            
    addi $s1, $s1, 1 

positive:
	# Convert integer section
    cvt.w.s $f0, $f12         # convert to integer
    mfc1    $s2, $f0          # move integerto $s2
    mtc1    $s2, $f0
    cvt.s.w $f0, $f0          # convert it to float
    sub.s   $f12, $f12, $f0   # get decimal part
    
    move $t8,$ra				#save return address
    move $a0, $s2  
    move $a1, $s1            
    move $t8,$ra
    jal  intToAscii		
    move $s1, $v0 
    
    la   $a0, point
    lb   $t9, ($a0)
    sb   $t9, ($s1)
    addi $s1, $s1, 1
    
    # Convert 3 decimal places
    li   $s3, 6               
    l.s  $f3, ten          
    
decimalLoop:
    beqz $s3, done            # if no more decimal places
    mul.s  $f12, $f12, $f3    
    cvt.w.s $f0, $f12         # convert to integer
    mfc1    $s2, $f0          
    mtc1    $s2, $f0
    cvt.s.w $f0, $f0
    sub.s   $f12, $f12, $f0   # get remaining decimal part   
    
     # Convert digit to ASCII and store
    addi $t9, $s2, 48         
    sb   $t9, ($s1)
    addi $s1, $s1, 1
    
    addi $s3, $s3, -1         # decrement counter
    j    decimalLoop
    
done:     
	move $ra,$t8
    jr   $ra
intToAscii:
    move $t9, $a0             
    move $t1, $a1             # copy Storge address
    la   $t2, temp            
    move $t3, $t2             
    
    bnez $t9, convertLoop
    li   $t4, 48              # '0' in Ascii
    sb   $t4, ($t1)
    addi $t1, $t1, 1
    move $v0, $t1
    jr   $ra

convertLoop:
    beqz $t9, reverse        
    
    rem  $t4, $t9, 10         # remainder when divided by 10
    addi $t4, $t4, 48         # convert to ASCII
    sb   $t4, ($t3)         
    addi $t3, $t3, 1         
    
    div  $t9, $t9, 10         # divide number by 10
    j    convertLoop

reverse:
    sub  $t3, $t3, 1    		# last char in temp     
    
reverseLoop:
    blt  $t3, $t2, doneInt  	# if reached start of temp 
    
    lb   $t4, ($t3)           
    sb   $t4, ($t1)          
    addi $t1, $t1, 1        
    sub  $t3, $t3, 1        
    j    reverseLoop

doneInt:
    move $v0, $t1             # save new Storge position
    jr   $ra
#----------------------------------------------------------
# start calculate system 3x3
System3x3: 
	move $t4,$s0
	j start3x3
#----------------------------------------------------------
#same as 2x2 we add Z to this
start3x3:
	la $ra,start3x3
	li $s4,0
	li $t1,1
	li $t8,1
	lb  $t2, ($t4)  
	beq $t2, '=' , insertA       
    beq $t2, 'x' , insertX 
    beq $t2, 'y', insertY
    beq $t2, 'z', insertZ
    addi $t4, $t4, 1
    beq $t2, '\n', increment3x3
    beq $t2, 0, increment3x3
    
    beq $t2,' ',start3x3
    beq $t2,'+',start3x3
    beq $t2,'-',start3x3
    beq $t2,13,start3x3
    bltu $t2,'0',equationsNumError
    bgtu $t2,'9',equationsNumError
    j start3x3
increment3x3:
	addi $s1,$s1,1
    bge $s1,3,cacululate3x3
    j start3x3
 
#---------------------------------------------------------	
insertA:
	move $s3,$t4
	mul $t9, $s1, 4 
	add $t9, $s2, $t9
LA:	lb  $t2, ($s3)
	beq $t2, '-' , setNegA			# if there is an - set - for number
	beq $t2, ' ' , addtoA			
	addi $s3, $s3, 1
	j LA
setNegA:
	li $t1,-1
addtoA:
	lb  $t2, ($s3)
	addi $s3, $s3, 1
	beq $t2, ' ', addtoA
	beq $t2, 13, storeA
	beq $t2, 0, storeA
	move $t8,$t2
	addiu $t8, $t8, -48			# convert ascii to int 
	mul $s4, $s4, 10			#each loop will mul $s4 by 10 
	add $s4, $s4, $t8			#add $s4 to new int
	move $t8,$s4
	j addtoA
storeA:
	mul $t8,$t8,$t1
	sw $t8, ($t9)
	addi $t4, $t4, 1
	jr $ra
#---------------------------------------------------------	
#same as we insert A in some changes
insertX:
	move $s3,$t4
L1:	lb  $t2, -1($s3)
	mul $t9, $s1, 4 
	add $t9, $t5, $t9
	beq $t2, '-' , setNegX	
	beq $t2, '+' , addtoX
	beq $t2, 10 , addtoX
	beq $s3 ,$s0,addtoX
	addi $s3, $s3, -1
	j L1
setNegX:
	li $t1,-1
addtoX:
	lb  $t2, ($s3)
	addi $s3, $s3, 1
	beq $t2, ' ', addtoX
	beq $t2, 'x', storeX 
	move $t8,$t2
	addiu $t8, $t8, -48
	mul $s4, $s4, 10
	add $s4, $s4, $t8
	move $t8,$s4
	j addtoX
storeX:
	mul $t8,$t8,$t1
	sw $t8, ($t9)
	addi $t4, $t4, 1
	jr $ra
#---------------------------------------------------------	
insertY:
	move $s3,$t4
L2:	lb  $t2, -1($s3)
	mul $t9, $s1, 4 
	add $t9, $t6, $t9
	beq $t2, '-' , setNegY
	beq $t2, '+' , addtoY
	beq $t2, 10 , addtoY
	beq $s3 ,$s0,addtoY
	addi $s3, $s3, -1
	j L2
setNegY:
	li $t1,-1
addtoY:
	lb  $t2, ($s3)
	addi $s3, $s3, 1
	beq $t2, ' ', addtoY
	beq $t2, 'y', storeY 
	move $t8,$t2
	addiu $t8, $t8, -48
	mul $s4, $s4, 10
	add $s4, $s4, $t8
	move $t8,$s4
	j addtoY
storeY:
	mul $t8,$t8,$t1
	sw $t8, ($t9)
	addi $t4, $t4, 1
	jr $ra
#---------------------------------------------------------	
insertZ:
	move $s3,$t4
L3:	lb  $t2, -1($s3)
	mul $t9, $s1, 4 
	add $t9, $t7, $t9
	beq $t2, '-' , setNegZ
	beq $t2, '+' , addtoZ
	beq $t2, 10 , addtoZ
	beq $s3 ,$s0,addtoZ
	addi $s3, $s3, -1
	j L3
setNegZ:
	li $t1,-1
addtoZ:
	lb  $t2, ($s3)
	addi $s3, $s3, 1
	beq $t2, ' ', addtoZ
	beq $t2, 'z', storeZ 
	move $t8,$t2
	addiu $t8, $t8, -48
	mul $s4, $s4, 10
	add $s4, $s4, $t8
	move $t8,$s4
	j addtoZ
storeZ:
	mul $t8,$t8,$t1
	sw $t8, ($t9)
	addi $t4, $t4, 1
	jr $ra
#---------------------------------------------------------
cacululate3x3:
	#in this section we will calculate determin for A 
	# calculate  X1*(Y2*Z3 - Z2*Y3)
	lw $t1,4($t6)
	lw $t2,8($t7)
	mul $t1,$t1,$t2
	lw $t3,4($t7)
	lw $t4,8($t6)
	mul $t3,$t3,$t4
	sub $t1,$t1,$t3
	lw $t3,0($t5)
	mul $t1,$t1,$t3			
	move $s1, $t1
	
	# calculate  Y1*(X2*Z3 - Z2*X3)
	lw $t1,4($t5)
	lw $t2,8($t7)
	mul $t1,$t1,$t2
	lw $t3,4($t7)
	lw $t4,8($t5)
	mul $t3,$t3,$t4
	sub $t1,$t1,$t3
	lw $t3,0($t6)
	mul $t1,$t1,$t3
	move $s3, $t1
	
	# calculate  Z1*(Y3*X2 - X3*Y2)
	lw $t1,4($t5)
	lw $t2,8($t6)
	mul $t1,$t1,$t2
	lw $t3,4($t6)
	lw $t4,8($t5)
	mul $t3,$t3,$t4
	sub $t1,$t1,$t3
	lw $t3,0($t7)
	mul $t1,$t1,$t3
	move $s4, $t1
	
	# now calculate det(A)  |A|
	move $t1,$s1
	move $t2,$s3
	move $t3,$s4
	
	sub $t1,$t1,$t2
	add $t1,$t1,$t3
	sw $t1,detA
	beqz $t1,detarminIsZero				# if |A| == zero its cant solve
	jal calcX3x3
	jal calcY3x3
	jal calcZ3x3
	
	lb $t8,menuChar
	beq $t8,'S' printScreen3x3
	beq $t8,'s' printScreen3x3
	
	j printFile3x3
#------------------------------------------------------------------	
#same as calculate |A| but at the end we will find X
calcX3x3:
	lw $t1,4($t6)
	lw $t2,8($t7)
	mul $t1,$t1,$t2
	lw $t3,4($t7)
	lw $t4,8($t6)
	mul $t3,$t3,$t4
	sub $t1,$t1,$t3
	lw $t3,0($s2)
	mul $t1,$t1,$t3			
	move $s1, $t1
	
	lw $t1,4($s2)
	lw $t2,8($t7)
	mul $t1,$t1,$t2
	lw $t3,4($t7)
	lw $t4,8($s2)
	mul $t3,$t3,$t4
	sub $t1,$t1,$t3
	lw $t3,0($t6)
	mul $t1,$t1,$t3
	move $s3, $t1
	
	lw $t1,4($s2)
	lw $t2,8($t6)
	mul $t1,$t1,$t2
	lw $t3,4($t6)
	lw $t4,8($s2)
	mul $t3,$t3,$t4
	sub $t1,$t1,$t3
	lw $t3,0($t7)
	mul $t1,$t1,$t3
	move $s4, $t1
	
	move $t1,$s1
	move $t2,$s3
	move $t3,$s4
	
	sub $t1,$t1,$t2
	add $t1,$t1,$t3
	
	# after calculate |X| we will calculate X
	lwc1 $f4,detA
	cvt.s.w $f4,$f4
	mtc1 $t1,$f6
	cvt.s.w $f6,$f6
	div.s $f8,$f6,$f4
	l.s $f10,zero
	c.eq.s 1,$f10,$f8
#	bc1t setXtoZero
	s.s $f8,X

	jr $ra
#---------------------------------------------------------
#same as X
calcY3x3:
	lw $t1,4($s2)
	lw $t2,8($t7)
	mul $t1,$t1,$t2
	lw $t3,4($t7)
	lw $t4,8($s2)
	mul $t3,$t3,$t4
	sub $t1,$t1,$t3
	lw $t3,0($t5)
	mul $t1,$t1,$t3			
	move $s1, $t1
	
	lw $t1,4($t5)
	lw $t2,8($t7)
	mul $t1,$t1,$t2
	lw $t3,4($t7)
	lw $t4,8($t5)
	mul $t3,$t3,$t4
	sub $t1,$t1,$t3
	lw $t3,0($s2)
	mul $t1,$t1,$t3
	move $s3, $t1
	
	lw $t1,4($t5)
	lw $t2,8($s2)
	mul $t1,$t1,$t2
	lw $t3,4($s2)
	lw $t4,8($t5)
	mul $t3,$t3,$t4
	sub $t1,$t1,$t3
	lw $t3,0($t7)
	mul $t1,$t1,$t3
	move $s4, $t1
	
	move $t1,$s1
	move $t2,$s3
	move $t3,$s4
	
	sub $t1,$t1,$t2
	add $t1,$t1,$t3
	lwc1 $f4,detA
	cvt.s.w $f4,$f4
	mtc1 $t1,$f6
	cvt.s.w $f6,$f6
	div.s $f8,$f6,$f4
	l.s $f10,zero
	c.eq.s 1,$f10,$f8
#	bc1t setYtoZero
	s.s $f8,Y
	
	jr $ra
#------------------------------------------------------------------	
#same as X
calcZ3x3:
	lw $t1,4($t6)
	lw $t2,8($s2)
	mul $t1,$t1,$t2
	lw $t3,4($s2)
	lw $t4,8($t6)
	mul $t3,$t3,$t4
	sub $t1,$t1,$t3
	lw $t3,0($t5)
	mul $t1,$t1,$t3			
	move $s1, $t1
	
	lw $t1,4($t5)
	lw $t2,8($s2)
	mul $t1,$t1,$t2
	lw $t3,4($s2)
	lw $t4,8($t5)
	mul $t3,$t3,$t4
	sub $t1,$t1,$t3
	lw $t3,0($t6)
	mul $t1,$t1,$t3
	move $s3, $t1
	
	lw $t1,4($t5)
	lw $t2,8($t6)
	mul $t1,$t1,$t2
	lw $t3,4($t6)
	lw $t4,8($t5)
	mul $t3,$t3,$t4
	sub $t1,$t1,$t3
	lw $t3,0($s2)
	mul $t1,$t1,$t3
	move $s4, $t1
	
	move $t1,$s1
	move $t2,$s3
	move $t3,$s4
	
	sub $t1,$t1,$t2
	add $t1,$t1,$t3
	lwc1 $f4,detA
	cvt.s.w $f4,$f4
	mtc1 $t1,$f6
	cvt.s.w $f6,$f6
	div.s $f8,$f6,$f4
	l.s $f10,zero
	c.eq.s 1,$f10,$f8
#	bc1t setZtoZero
	s.s $f8,Z

	jr $ra
#---------------------------------------------------------
setZtoZero:
	s.s $f10,Z
	jr $ra
#---------------------------------------------------------
printScreen3x3:

	li $v0, 4			
    la $a0, X_message
    syscall
    
    l.s $f12,X
	li $v0,2
	syscall
	
	li $v0, 4				
    la $a0, Y_message
    syscall
    
    l.s $f12,Y
	li $v0,2
	syscall
	
	li $v0, 4				
    la $a0, Z_message
    syscall
    
    l.s $f12,Z
	li $v0,2
	syscall
	
	li $v0, 4				
    la $a0,newLine
    syscall
	la $t0,2($t0)
	
	j changeAddress
#--------------------------------------------------------
printFile3x3:
    
    
	l.s  $f12, X     
    la   $a0, Storge          
    jal  ConvertToAscii

    
    li $v0, 15	
    lw $a0,0($sp)	
    la $a1, X_message
    li   $a2, 4
    syscall
    
    li   $v0, 15              
    lw $a0,0($sp)            
    la   $a1, Storge              
    syscall
    
    
    l.s  $f12, Y      
    la   $a0, Storge          
    jal  ConvertToAscii
    
    li $v0, 15	
    lw $a0,0($sp)		
    la $a1, Y_message
    li   $a2, 4
    syscall
    
    li   $v0, 15               
    lw $a0,0($sp)             
    la   $a1, Storge        
    syscall
    
    l.s  $f12, Z      
    la   $a0, Storge           
    jal  ConvertToAscii
    
    li $v0, 15	
    lw $a0,0($sp)		
    la $a1, Z_message
    li   $a2, 4
    syscall
    
    li   $v0, 15               
    lw $a0,0($sp)              
    la   $a1, Storge           
    syscall
    
    li   $v0, 15
    move $a0, $s0
    la   $a1, newLine
    li   $a2, 1
    syscall
    
    
	la $t0,2($t0)
	j changeAddress
#---------------------------------------------------------
# print error in number of equation 
equationsNumError:
	lb $t8,menuChar
    beq $t8,'f', printErrorinFile		#print in file if user inser 'f'
    beq $t8,'F', printErrorinFile		#print in file if user inser 'F'
    
	li $v0, 4
    la $a0, errorNumEquation
    syscall
    
    li $v0, 4
    la $a0, newLine
    syscall
    
	la $t0,2($t0)
    j changeAddress
 #print error in file
printErrorinFile:
    li   $v0, 15
    lb $a0,0($sp)
    la   $a1, errorNumEquation
    li   $a2, 42
    syscall
    
    li   $v0, 15
    lb $a0,0($sp)
    la   $a1, newLine
    li   $a2, 1
    syscall
    
    la $t0,2($t0)
    j changeAddress
#---------------------------------------------------------
detarminIsZero:
	lb $t8,menuChar
    beq $t8,'f', printInFile
    beq $t8,'F', printInFile
    
	li $v0, 4
    la $a0, errorDetarmin
    syscall
    
    li $v0, 4
    la $a0, newLine
    syscall
    
	la $t0,2($t0)
    j changeAddress
    
printInFile:
    li   $v0, 15
    lb $a0,0($sp)
    la   $a1, errorDetarmin
    li   $a2, 45
    syscall
    
    li   $v0, 15
    lb $a0,0($sp)
    la   $a1, newLine
    li   $a2, 1
    syscall
    
    la $t0,2($t0)
    j changeAddress
#---------------------------------------------------------
errorOpen:

    li $v0, 4
    la $a0, errorFile
    syscall
    
    j main
#---------------------------------------------------------
exit:
    # Exit program
    li $v0, 10             # syscall 10: exit
    syscall
