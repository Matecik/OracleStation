
/obj/structure/transit_tube
	name = "transit tube"
	icon = 'icons/obj/atmospherics/pipes/transit_tube.dmi'
	icon_state = "straight"
	density = 1
	layer = LOW_ITEM_LAYER
	anchored = 1
	climbable = 1
	var/tube_construction = /obj/structure/c_transit_tube
	var/list/tube_dirs //list of directions this tube section can connect to.
	var/exit_delay = 1
	var/enter_delay = 0

/obj/structure/transit_tube/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	return !density

/obj/structure/transit_tube/New(loc, newdirection)
	..(loc)
	if(newdirection)
		setDir(newdirection)
	init_tube_dirs()
	generate_decorative_tubes()

/obj/structure/transit_tube/Destroy()
	for(var/obj/structure/transit_tube_pod/P in loc)
		P.deconstruct(FALSE)
	return ..()

/obj/structure/transit_tube/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)

/obj/structure/transit_tube/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		if(tube_construction) //decorative diagonals cannot be unwrenched directly
			for(var/obj/structure/transit_tube_pod/pod in src.loc)
				user << "<span class='warning'>Remove the pod first!</span>"
				return
			user.visible_message("[user] starts to deattach \the [src].", "<span class='notice'>You start to deattach the [name]...</span>")
			playsound(src.loc, W.usesound, 50, 1)
			if(do_after(user, 35/W.toolspeed, target = src))
				user << "<span class='notice'>You deattach the [name].</span>"
				var/obj/structure/c_transit_tube/R = new tube_construction(loc)
				R.setDir(dir)
				transfer_fingerprints_to(R)
				R.add_fingerprint(user)
				qdel(src)
	else if(istype(W, /obj/item/weapon/crowbar))
		for(var/obj/structure/transit_tube_pod/pod in src.loc)
			pod.attackby(W, user)
	else
		return ..()

// Called to check if a pod should stop upon entering this tube.
/obj/structure/transit_tube/proc/should_stop_pod(pod, from_dir)
	return 0

// Called when a pod stops in this tube section.
/obj/structure/transit_tube/proc/pod_stopped(pod, from_dir)
	return


/obj/structure/transit_tube/proc/has_entrance(from_dir)
	from_dir = turn(from_dir, 180)

	for(var/direction in tube_dirs)
		if(direction == from_dir)
			return 1

	return 0



/obj/structure/transit_tube/proc/has_exit(in_dir)
	for(var/direction in tube_dirs)
		if(direction == in_dir)
			return 1

	return 0



// Searches for an exit direction within 45 degrees of the
//  specified dir. Returns that direction, or 0 if none match.
/obj/structure/transit_tube/proc/get_exit(in_dir)
	var/near_dir = 0
	var/in_dir_cw = turn(in_dir, -45)
	var/in_dir_ccw = turn(in_dir, 45)

	for(var/direction in tube_dirs)
		if(direction == in_dir)
			return direction

		else if(direction == in_dir_cw)
			near_dir = direction

		else if(direction == in_dir_ccw)
			near_dir = direction

	return near_dir


// Return how many BYOND ticks to wait before entering/exiting
//  the tube section. Default action is to return the value of
//  a var, which wouldn't need a proc, but it makes it possible
//  for later tube types to interact in more interesting ways
//  such as being very fast in one direction, but slow in others
/obj/structure/transit_tube/proc/exit_delay(pod, to_dir)
	return exit_delay

/obj/structure/transit_tube/proc/enter_delay(pod, to_dir)
	return enter_delay


// Parse the icon_state into a list of directions.
// This means that mappers can use Dream Maker's built in
//  "Generate Instances from Icon-states" option to get all
//  variations. Additionally, as a separate proc, sub-types
//  can handle it more intelligently.
/obj/structure/transit_tube/proc/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(NORTH, SOUTH)
		if(SOUTH)
			tube_dirs = list(NORTH, SOUTH)
		if(EAST)
			tube_dirs = list(EAST, WEST)
		if(WEST)
			tube_dirs = list(EAST, WEST)


//phil235 must deconstruct on Move()
//phil235 remember to update the maps!
// Look for diagonal directions, generate the decorative corners in each.
/obj/structure/transit_tube/proc/generate_decorative_tubes()
	for(var/direction in tube_dirs)
		if(direction in diagonals)
			if(direction & NORTH)
				create_decorative_tube(direction ^ 3, NORTH)

//			else
//				create_decorative_tube(direction ^ 3, SOUTH)

				if(direction & EAST)
					create_decorative_tube(direction ^ 12, EAST)

				else
					create_decorative_tube(direction ^ 12, WEST)
		else
			create_decorative_tube(direction)


// Generate a corner, if one doesn't exist for the direction on the turf.
/obj/structure/transit_tube/proc/create_decorative_tube(direction, shift_dir)
	var/image/I
	if(shift_dir)
		I = image(loc = src, icon_state = "decorative_diag", dir = direction)
		switch(shift_dir)
			if(NORTH)
				I.pixel_y = 32
			if(SOUTH)
				I.pixel_y = -32
			if(EAST)
				I.pixel_x = 32
			if(WEST)
				I.pixel_x = -32
	else
		I = image(loc = src, icon_state = "decorative", dir = direction)
	add_overlay(I)




//Some of these are mostly for mapping use
/obj/structure/transit_tube/horizontal
	dir = 8


/obj/structure/transit_tube/diagonal
	icon_state = "diagonal"
	tube_construction = /obj/structure/c_transit_tube/diagonal

/obj/structure/transit_tube/diagonal/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(NORTHEAST, SOUTHWEST)
		if(SOUTH)
			tube_dirs = list(NORTHEAST, SOUTHWEST)
		if(EAST)
			tube_dirs = list(NORTHWEST, SOUTHEAST)
		if(WEST)
			tube_dirs = list(NORTHWEST, SOUTHEAST)


/obj/structure/transit_tube/diagonal/topleft
	dir = 8


/obj/structure/transit_tube/curved
	icon_state = "curved0"
	tube_construction = /obj/structure/c_transit_tube/curved

/obj/structure/transit_tube/curved/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(NORTH, SOUTHWEST)
		if(SOUTH)
			tube_dirs = list(SOUTH, NORTHEAST)
		if(EAST)
			tube_dirs = list(EAST, NORTHWEST)
		if(WEST)
			tube_dirs = list(SOUTHEAST, WEST)

/obj/structure/transit_tube/curved/flipped
	icon_state = "curved1"
	tube_construction = /obj/structure/c_transit_tube/curved/flipped

/obj/structure/transit_tube/curved/flipped/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(NORTH, SOUTHEAST)
		if(SOUTH)
			tube_dirs = list(SOUTH, NORTHWEST)
		if(EAST)
			tube_dirs = list(EAST, SOUTHWEST)
		if(WEST)
			tube_dirs = list(NORTHEAST, WEST)


/obj/structure/transit_tube/junction
	icon_state = "junction0"
	tube_construction = /obj/structure/c_transit_tube/junction

/obj/structure/transit_tube/junction/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(NORTH, SOUTHEAST, SOUTHWEST)//ending with the prefered direction
		if(SOUTH)
			tube_dirs = list(SOUTH, NORTHWEST, NORTHEAST)
		if(EAST)
			tube_dirs = list(EAST, SOUTHWEST, NORTHWEST)
		if(WEST)
			tube_dirs = list(WEST, NORTHEAST, SOUTHEAST)

/obj/structure/transit_tube/junction/flipped
	icon_state = "junction1"
	tube_construction = /obj/structure/c_transit_tube/junction/flipped

/obj/structure/transit_tube/junction/flipped/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(NORTH, SOUTHWEST, SOUTHEAST)//ending with the prefered direction
		if(SOUTH)
			tube_dirs = list(SOUTH, NORTHEAST, NORTHWEST)
		if(EAST)
			tube_dirs = list(EAST, NORTHWEST, SOUTHWEST)
		if(WEST)
			tube_dirs = list(WEST, SOUTHEAST, NORTHEAST)


/obj/structure/transit_tube/crossing
	icon_state = "crossing"
	tube_construction = /obj/structure/c_transit_tube/crossing
	density = 0

/obj/structure/transit_tube/crossing/horizontal
	dir = 8
