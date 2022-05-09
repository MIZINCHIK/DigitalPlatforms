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
	
	ldi r0, stack
	stsp r0
	ldi r0, XBALL
	ldi r1, YBALL
	ldi r2, 0
	ldi r3, 0
	st r0, r2
	st r1, r3
	ldi r0, VX
	ldi r1, VY
	ldi r2, 3
	ldi r3, 1
	st r0, r2
	st r1, r3

main:
	ldi r0, VX
	ld r0, r0
	if
	tst r0
	is pl
		jsr compute
		br main
	else
		br main
	fi

compute:
	ldi r0, 224
	ldi r1, XBALL
	ld r1, r1
	sub r0, r1
	move r1, r0
	ldi r1, 2
	ldi r2, VX
	ld r2, r2
	if
	cmp r1, r2
	is eq
		shra r0
		ldi r3, 127
		and r3, r0
	else
		ldi r1, 4
		if
		cmp r1, r2
		is eq
			shra r0
			shra r0
			ldi r3, 63
			and r3, r0
		else
			ldi r1, 3
			if
			cmp r1, r2
			is eq
				move r0, r1
				ldi r2, 15
				shra r0
				shra r0
				shra r0
				shra r0
				and r2, r0
				and r2, r1
				push r0
				push r1
				
				push r0
				push r1
				push r1
				push r1
				pop r0
				shla r0
				shla r0
				pop r2
				shla r2
				add r2, r0
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
				pop r1
				add r1, r0
				pop r1
				push r1
				shla r1
				shla r1
				pop r2
				shla r2
				add r2, r1
				shra r1
				shra r1
				shra r1
				shra r1
				add r1, r0
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
				add r3, r0
			fi
		fi
	fi
	ldi r1, 0
	ldi r2, VY
	ld r2, r2
	if
	tst r2
	is mi
		neg r2
	fi
	push r2
	ldi r3, 2
	if
	cmp r2, r3
	is eq
		shla r0
		if
		is cs
			inc r1
		fi
	else
		ldi r3, 4
		if
		cmp r2, r3
		is eq
			shla r0
			if
			is cs
				inc r1
			fi
			shla r0
			if
			is cs
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
					inc r1
				fi
				add r0, r2
				if
				is cs
					inc r1
				fi
				move r2, r0
			fi
		fi
	fi
	ldi r2, YBALL
	ld r2, r2
	add r0, r2
	move r2, r0
	ldi r2, 1
	and r1, r2
	ldi r1, 1
	if
	cmp r1, r2
	is eq
		neg r0
	fi
	pop r2
	if
	tst r2
	is mi
		neg r0
	fi		
	ldi r1, YBAT
	st r1, r0
	rts
	
	end
