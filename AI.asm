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
	#this VX is actually (VX << 7)
	move r2, r1
	shra r1
	shra r1
	shra r1
	shra r1
	shra r1
	shra r1
	add r1, r0
	
	
	#computing XRIGHT-XBALL
	#it is the distance to the right bat from the current position
	ldi r1, 227
	sub r1, r0
	
	wait
	#`wait` is used for lowering the stress on simulation
	#so real frequency is same when ball goes right or left 
	
	ldi r1, MUL1
	st r1, r0
	
	wait
	
	#then we need to divide XRIGHT-XBALL by VX
	#we use external calculator
	#first give A, B, C to it via `st`
	#then get the result of A * B / C
	
	ldi r1, DIV
	st r1, r2
	
	wait
	
	#now let's mult the result by VY
	
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
	
	#Getting the result
	
	ldi r3, COORDS
	ld r3, r0 # Y coordinate of touching XRIGHT
	inc r3
	ld r3, r1 # the number of reflections from the upper and lower wall
	wait

	#Okay, let's add our ball's Y coordinate to the (XRIGHT-XBALL) / VX * VY
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
	#add carry to r1 -- n of reflections
	addc r3, r1
	move r2, r0
	ldi r2, 1
	and r1, r2
	ldi r1, 1
	#if quantity of reflections was odd we negate the result
	if
	cmp r1, r2
	is eq
		neg r0
	fi

	wait
	ldi r1, YBAT
	st r1, r0
	wait
	br main
	
	end