	asect 0xfb
XBALL:
	asect 0xfc
YBALL: 
	asect 0xfd	
VX: 	
	asect 0xfe
VY: 	
	asect 0xff
YBAT: 	
	asect 0xfa
stack:	
	asect 0x00
start:
	#lower the stack
	ldi r0, stack
	stsp r0
	#put some inputs for debugging
	ldi r0, XBALL
	ldi r1, YBALL
	ldi r2, 0
	ldi r3, 0
	st r0, r2
	st r1, r3
	ldi r0, VX
	ldi r1, VY
	ldi r2, -3
	ldi r3, -1
	st r0, r2
	st r1, r3

main:
	#get the VX and check if it's positive or not
	#if it is then jump to subroutine calculating
	#YBAT. Then jump to main again.
	ldi r0, VX
	ld r0, r0
	if
	tst r0
	is pl
		jsr compute
	fi
	br main

compute:
	#it starts with computing 224-XBALL and
	#pushing it into r0
	ldi r0, 224
	ldi r1, XBALL
	ld r1, r1
	sub r0, r1
	move r1, r0
	#then I need to divide it by VX
	ldi r1, 2
	ldi r2, VX
	ld r2, r2
	if
	cmp r1, r2
	is eq
		#if VX == 2 I simply "shra" the thing
		shra r0
		#then I need to make it positive ofc
		ldi r3, 127
		and r3, r0
	else
		ldi r1, 4
		if
		cmp r1, r2
		is eq
			#VX == 4; the same as in the previous case I simply "shra"
			shra r0
			shra r0
			#and make it positive
			ldi r3, 63
			and r3, r0
		else
			ldi r1, 3
			if
			cmp r1, r2
			is eq
				#if VX == 3; now it's more complicated
				#imagine we have two numbers: AB & CD
				#where A, B, C, D stand for 4 bits of data each
				#then the result of the AB*CD will be a number EF
				#where E, F stand for 8 bits of data each
				#and F = B * D + (B * C) << 2 + (A * D) << 2
				#E = carry_bit + A * C + (A * D) >> 2 + (B * C) >> 2
				#Why are we talking about multiplication?
				#Well, number / 3 == number * (2^8 / 3) >> 8 ==
				#== number * 86 == E in the terms below
				#And here I try to implement this
				
				#I start with simply computing A & B
				#I already know C == 5 and D == 6
				move r0, r1
				ldi r2, 15
				shra r0
				shra r0
				shra r0
				shra r0
				and r2, r0
				and r2, r1
				#and then I push them to the stack
				push r0
				push r1
				
				#here I compute B
				push r0
				push r1
				push r1
				push r1
				#from here I do B * D
				pop r0
				shla r0
				shla r0
				pop r2
				shla r2
				add r2, r0
				#then (B * C) << 2
				pop r1
				push r1
				shla r1
				shla r1
				pop r2
				add r2, r1
				shla r1
				shla r1
				shla r1
				shla r1
				#and finally (A * D) << 2
				pop r2
				push r2
				shla r2
				shla r2
				pop r3
				shla r3
				add r3, r2
				shla r2
				shla r2
				shla r2
				shla r2
				#and the carry_bit is in r3
				ldi r3, 0
				add r2, r1
				addc r3, r3
				ldi r2, 0
				add r1, r0
				addc r2, r3
				
				pop r1
				pop r0
				push r1
				push r0
				push r0
				shla r0
				shla r0
				#it's time to calculate A * C
				pop r1
				add r1, r0
				pop r1
				push r1
				shla r1
				shla r1
				#then (A * D) >> 2
				pop r2
				shla r2
				add r2, r1
				shra r1
				shra r1
				shra r1
				shra r1
				#there surely won't be any carry bits
				#thus I store it in r0
				add r1, r0
				#finally (B * C) >> 2
				pop r1
				push r1
				shla r1
				shla r1
				pop r2
				add r2, r1
				shra r1
				shra r1
				shra r1
				shra r1
				add r1, r0
				#and carry
				add r3, r0
			fi
		fi
	fi
	#OK, at this point we have calcualted (224 - XBALL) / VX
	#now let's mult it by VY
	ldi r1, 0
	ldi r2, VY
	ld r2, r2
	if
	tst r2
	is mi
		#if VY is negative we simply negate it
		neg r2
	fi
	#we will eventually come back to it's sign but a bit later
	#so we are pushing it to the stack
	push r2
	ldi r3, 2
	if
	cmp r2, r3
	is eq
		#shla if VY == 2
		shla r0
		if
		is cs
			#counting carry
			inc r1
		fi
	else
		ldi r3, 4
		if
		cmp r2, r3
		is eq
			shla r0
			#same for 4
			if
			is cs
				#counting carry
				inc r1
			fi
			shla r0
			if
			is cs
				#counting carry
				inc r1
			fi
		else
			ldi r3, 3
			if
			cmp r2, r3
			is eq
				move r0, r2
				shla r0
				if
				is cs
					#counting carry
					inc r1
				fi
				add r0, r2
				if
				is cs
					#counting carry
					inc r1
				fi
				move r2, r0
			fi
		fi
	fi
	#Okay, let's add our ball's Y coordinate to the (224 - XBALL) / VX * VY
	ldi r2, YBALL
	ld r2, r2
	add r0, r2
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
	pop r2
	#and we negate it if we had negative VY
	if
	tst r2
	is mi
		neg r0
	fi	
	#load the result (!!PART TO IMPROVE!!)	
	ldi r1, YBAT
	st r1, r0
	rts
	
	end
