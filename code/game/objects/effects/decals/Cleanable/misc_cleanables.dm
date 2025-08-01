#define ALWAYS_IN_GRAVITY 3

/obj/effect/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	gender = PLURAL
	layer = TURF_LAYER
	icon = 'icons/obj/objects.dmi'
	icon_state = "shards"

/obj/effect/decal/cleanable/ash
	name = "ashes"
	desc = "Ashes to ashes, dust to dust, and into space."
	gender = PLURAL
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	scoop_reagents = list("ash" = 10)
	mergeable_decal = FALSE
	plane = GAME_PLANE

/obj/effect/decal/cleanable/glass
	name = "tiny shards"
	desc = "Back to sand."
	icon = 'icons/obj/shards.dmi'
	icon_state = "tiny"
	plane = GAME_PLANE

/obj/effect/decal/cleanable/glass/Initialize(mapload)
	. = ..()
	setDir(pick(GLOB.cardinal))

/obj/effect/decal/cleanable/glass/ex_act()
	qdel(src)

/obj/effect/decal/cleanable/glass/plasma
	icon_state = "plasmatiny"

/obj/effect/decal/cleanable/glass/plastitanium
	icon_state = "plastitaniumtiny"

/obj/effect/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	gender = PLURAL
	layer = TURF_LAYER
	icon = 'icons/effects/dirt.dmi'
	icon_state = "dirt"
	base_icon_state = "dirt"
	smoothing_groups = list(SMOOTH_GROUP_CLEANABLE_DIRT)
	canSmoothWith = list(SMOOTH_GROUP_CLEANABLE_DIRT, SMOOTH_GROUP_WALLS)
	mouse_opacity = FALSE

/obj/effect/decal/cleanable/dirt/Initialize(mapload)
	. = ..()
	QUEUE_SMOOTH_NEIGHBORS(src)
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/effect/decal/cleanable/dirt/Destroy()
	QUEUE_SMOOTH_NEIGHBORS(src)
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/obj/effect/decal/cleanable/dirt/blackpowder
	name = "black powder"
	mouse_opacity = TRUE
	no_scoop = TRUE
	scoop_reagents = list("blackpowder" = 40) // size 2 explosion when activated

/obj/effect/decal/cleanable/flour
	name = "flour"
	desc = "It's still good. Four second rule!"
	gender = PLURAL
	layer = TURF_LAYER
	icon_state = "flour"

/obj/effect/decal/cleanable/flour/nanofrost
	name = "nanofrost residue"
	desc = "Residue left behind from a nanofrost detonation. Perhaps there was a fire here?"
	color = "#B2FFFF"

/obj/effect/decal/cleanable/flour/foam
	name = "Fire fighting foam"
	desc = "It's foam."
	color = "#EBEBEB"

/obj/effect/decal/cleanable/flour/foam/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 15 SECONDS)

/obj/effect/decal/cleanable/greenglow
	name = "glowing goo"
	desc = "Jeez. I hope that's not for lunch."
	gender = PLURAL
	layer = TURF_LAYER
	light_range = 1
	icon_state = "greenglow"

/obj/effect/decal/cleanable/greenglow/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 2 MINUTES)

/obj/effect/decal/cleanable/greenglow/ex_act()
	return

/obj/effect/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Somebody should remove that."
	plane = GAME_PLANE
	icon_state = "cobweb1"
	resistance_flags = FLAMMABLE

/obj/effect/decal/cleanable/molten_object
	name = "gooey grey mass"
	desc = "It looks like a melted... something."
	plane = GAME_PLANE
	icon_state = "molten"
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/molten_object/large
	name = "big gooey grey mass"
	icon_state = "big_molten"

/obj/effect/decal/cleanable/cobweb2
	name = "cobweb"
	desc = "Somebody should remove that."
	plane = GAME_PLANE
	icon_state = "cobweb2"

/obj/effect/decal/cleanable/vomit
	name = "vomit"
	desc = "Gosh, how unpleasant."
	gender = PLURAL
	layer = TURF_LAYER
	icon = 'icons/effects/blood.dmi'
	icon_state = "vomit_1"
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")
	no_clear = TRUE
	scoop_reagents = list("vomit" = 5)


/obj/effect/decal/cleanable/vomit/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	check_gravity(T)

	if(!gravity_check)
		layer = MOB_LAYER
		plane = GAME_PLANE
		if(prob(50))
			animate_float(src, -1, rand(30, 120))
		else
			animate_levitate(src, -1, rand(30, 120))
		icon = 'icons/effects/blood_weightless.dmi'

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/decal/cleanable/vomit/Bump(atom/A)
	if(gravity_check)
		return ..()

	if(iswallturf(A) || istype(A, /obj/structure/window))
		splat(A)
		return
	else if(A.density)
		splat(get_turf(A))
		return

	return ..()

/obj/effect/decal/cleanable/vomit/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(!gravity_check)
		splat(entered)

/obj/effect/decal/cleanable/vomit/proc/splat(atom/A)
	if(gravity_check)
		return
	var/turf/T = get_turf(A)
	if(should_merge_decal(T))
		qdel(src)
		return
	if(loc != T)
		forceMove(T)
	icon = initial(icon)
	gravity_check = ALWAYS_IN_GRAVITY
	if(T.density || locate(/obj/structure/window) in T)
		layer = ABOVE_WINDOW_LAYER
		plane = GAME_PLANE
	else
		layer = initial(layer)
		plane = initial(plane)
	animate(src)

/obj/effect/decal/cleanable/vomit/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	if(gravity_check)
		return TRUE

	return ..()

/obj/effect/decal/cleanable/vomit/green
	name = "green vomit"
	desc = "It's all gummy. Ew."
	icon_state = "gvomit_1"
	random_icon_states = list("gvomit_1", "gvomit_2", "gvomit_3", "gvomit_4")
	scoop_reagents = list("green_vomit" = 5)

/obj/effect/decal/cleanable/shreds
	name = "shreds"
	desc = "The shredded remains of what appears to be clothing."
	icon_state = "shreds"
	gender = PLURAL
	plane = GAME_PLANE
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/shreds/ex_act(severity, target)
	if(severity == EXPLODE_DEVASTATE) //so shreds created during an explosion aren't deleted by the explosion.
		qdel(src)

/obj/effect/decal/cleanable/shreds/Initialize(mapload)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	. = ..()

/obj/effect/decal/cleanable/tomato_smudge
	name = "tomato smudge"
	desc = "It's red."
	layer = TURF_LAYER
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

/obj/effect/decal/cleanable/plant_smudge
	name = "plant smudge"
	layer = TURF_LAYER
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_plant")

/obj/effect/decal/cleanable/egg_smudge
	name = "smashed egg"
	desc = "Seems like this one won't hatch."
	layer = TURF_LAYER
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3")

/// honk
/obj/effect/decal/cleanable/pie_smudge
	name = "smashed pie"
	desc = "It's pie cream from a cream pie."
	layer = TURF_LAYER
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_pie")

/obj/effect/decal/cleanable/fungus
	name = "space fungus"
	desc = "A fungal growth. Looks pretty nasty."
	layer = TURF_LAYER
	plane = GAME_PLANE
	icon_state = "flour"
	color = "#D5820B"
	scoop_reagents = list("fungus" = 10)
	no_clear = TRUE
	var/timer_id

/obj/effect/decal/cleanable/fungus/examine(mob/user)
	. = ..()
	if(no_scoop)
		. += "<span class='notice'>There's not a lot here, you probably wouldn't be able to harvest anything useful.</span>"
	else
		. += "<span class='notice'>There's enough here to scrape into a beaker.</span>"

/obj/effect/decal/cleanable/fungus/on_scoop()
	alpha = 128
	no_scoop = TRUE

	timer_id = addtimer(CALLBACK(src, PROC_REF(recreate)), rand(5 MINUTES, 10 MINUTES), TIMER_STOPPABLE)

/obj/effect/decal/cleanable/fungus/Destroy()
	. = ..()
	deltimer(timer_id)

/obj/effect/decal/cleanable/fungus/proc/recreate()
	alpha = 255
	reagents.add_reagent_list(scoop_reagents)
	no_scoop = FALSE

/// PARTY TIME!
/obj/effect/decal/cleanable/confetti
	name = "confetti"
	desc = "Party time!"
	gender = PLURAL
	plane = GAME_PLANE
	icon = 'icons/obj/objects.dmi'
	icon_state = "confetti1"
	random_icon_states = list("confetti1", "confetti2", "confetti3")

/obj/effect/decal/cleanable/insectguts
	name = "bug guts"
	desc = "One bug squashed. Four more will rise in its place."
	icon = 'icons/effects/blood.dmi'
	icon_state = "xfloor1"
	random_icon_states = list("xfloor1", "xfloor2", "xfloor3", "xfloor4", "xfloor5", "xfloor6", "xfloor7")

#undef ALWAYS_IN_GRAVITY
