#put some inputs for debugging
	asect 0xf0
XBALL:
	dc 0
YBALL:
	dc 0
VX:
	dc 0
VY:
	dc 0
	asect 0xf4
COORDS:
	dc 70
REFLECT:
	dc 3
	asect 0xf8
YBAT:
	dc 0
	asect 0xf9
MUL1:
	dc 200
MUL2:
	dc 5
DIV:
	dc 3
	asect 0xef
stack:	
	asect 0x00
start:
	#lower the stack
	ldi r0, stack
	stsp r0

main:
	#in cycle get the VX and check if it's positive or not
	#if it is then jump to `compute` and calculate bat position
	#Then jump to main again
	#if not then put the bat in the middle
	ldi r0, VX
	ld r0, r1
	tst r1
	bgt compute
	ldi r2, YBAT
	ldi r3, 127
	st r2, r3
main_loop:
	wait
	ld r0, r1
	tst r1
	bgt compute
	br main_loop


compute:
	#load all values in one moment
	ldi r0, XBALL
	ldi r2, YBALL
	ldi r3, VY
	ld r0, r0
	ld r2, r2
	ld r3, r3
	#put VY and YBALL in stack to use later
	push r2
	push r3
	ldi r2, VX
	ld r2, r2
	
	#XBALL is read 2 ticks after YBALL
	#1 kinematic tick is now 1 cdm-8 tick
	#XBALL := XBALL + VX * 2
	#this VX is actually (VX << 4)
	move r2, r1
	shra r1
	shra r1
	shra r1
	add r1, r0
	
	#computing 224-XBALL
	ldi r1, 227
	#it is 224+3 because for big vy 
	#the ball travels too much
	sub r1, r0
	
	wait
	
	ldi r1, MUL1
	st r1, r0
	
	
	wait
	
	#then I need to divide 224-XBALL by VX
	
	
	
	ldi r1, DIV
	st r1, r2
	
	wait
	
#	ldi r1, 2
#	if
#	cmp r1, r2
#	is eq
#		#if VX == 2 I simply "shra" the thing
#		shra r0
#		#then I need to make it positive ofc
#		ldi r3, 127
#		and r3, r0
#	else
#		ldi r1, 4
#		if
#		cmp r1, r2
#		is eq
#			#VX == 4; the same as in the previous case I simply "shra"
#			shra r0
#			shra r0
#			#and make it positive
#			ldi r3, 63
#			and r3, r0
#		else
#			ldi r1, 3
#			if
#			cmp r1, r2
#			is eq
#				#if VX == 3; now it's more complicated
#				#imagine we have two numbers: AB & CD
#				#where A, B, C, D stand for 4 bits of data each
#				#then the result of the AB*CD will be a number EF
#				#where E, F stand for 8 bits of data each
#				#and F = B * D + (B * C) << 2 + (A * D) << 2
#				#E = carry_bit + A * C + (A * D) >> 2 + (B * C) >> 2
#				#Why are we talking about multiplication?
#				#Well, number / 3 == number * (2^8 / 3) >> 8 ==
#				#== number * 86 == E in the terms below
#				#And here I try to implement this
#				
#				#I start with simply computing A & B
#				#I already know C == 5 and D == 6
#				
#				#the code was removed
#				shra r0
#				#then I need to make it positive ofc
#				ldi r3, 127
#				and r3, r0
#				
#			fi
#		fi
#	fi
	#OK, at this point we have calcualted (224 - XBALL) / VX
	#now let's mult it by VY
	clr r1
	pop r2 # VY
	push r2
	if
	tst r2
	is mi
		#if VY is negative we simply negate it
		neg r2
	fi
	#we will eventually come back to it's sign but a bit later
	#so we are pushing it to the stack
	
	wait
	
	ldi r3, MUL2
	st r3, r2
	
	wait
	
#	ldi r3, 2
#	if
#	cmp r2, r3
#	is eq
#		#shla if VY == 2
#		shla r0
#		if
#		is cs
#			#counting carry in r1
#			inc r1
#		fi
#	else
#		ldi r3, 4
#		if
#		cmp r2, r3
#		is eq
#			shla r0
#			#same for 4
#			if
#			is cs
#				#counting carry
#				inc r1
#			fi
#			shla r0
#			if
#			is cs
#				#counting carry
#				inc r1
#			fi
#		else
#			ldi r3, 3
#			if
#			cmp r2, r3
#			is eq
#				move r0, r2
#				shla r0
#				if
#				is cs
#					#counting carry
#					inc r1
#				fi
#				add r0, r2
#				if
#				is cs
#					#counting carry
#					inc r1
#				fi
#				move r2, r0
#			fi
#		fi
#	fi

	
	
	ldi r3, COORDS
	ld r3, r0
	inc r3
	ld r3, r1
	
	wait
	


	#Okay, let's add our ball's Y coordinate to the (224 - XBALL) / VX * VY
	pop r3 # VY
	pop r2 # YBALL
	#negate YBALL if VY < 0
	if
	tst r3
	is mi
		neg r2
		inc r1
	fi
	clr r3
	add r0, r2
	#add carry to r1 -- carry counter
	addc r3, r1
	move r2, r0
	ldi r2, 1
	and r1, r2
	ldi r1, 1
	#if quantity of carry bits was odd we negate the result
	if
	cmp r1, r2
	is eq
		neg r0
	fi
	#load the result (!!PART TO IMPROVE!!)	

	wait
	ldi r1, YBAT
	st r1, r0
	wait
	br main
	
	end