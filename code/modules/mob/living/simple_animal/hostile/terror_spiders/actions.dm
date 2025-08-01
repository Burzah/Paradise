// ---------- ACTIONS FOR ALL SPIDERS

/datum/action/innate/terrorspider/web
	name = "Web"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "stickyweb1"

/datum/action/innate/terrorspider/web/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/user = owner
	user.Web()

/datum/action/innate/terrorspider/wrap
	name = "Wrap"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "cocoon_large1"

/datum/action/innate/terrorspider/wrap/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/user = owner
	user.FindWrapTarget()
	user.DoWrap()

// ---------- GREEN ACTIONS

/datum/action/innate/terrorspider/greeneggs
	name = "Lay Green Eggs"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "eggs"

/datum/action/innate/terrorspider/greeneggs/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/green/user = owner
	user.DoLayGreenEggs()


// ---------- BOSS ACTIONS

/datum/action/innate/terrorspider/ventsmash
	name = "Smash Welded Vent"
	button_icon = 'icons/atmos/vent_pump.dmi'
	button_icon_state = "map_vent"

/datum/action/innate/terrorspider/ventsmash/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/user = owner
	user.DoVentSmash()

/datum/action/innate/terrorspider/remoteview
	name = "Remote View"
	button_icon = 'icons/obj/eyes.dmi'
	button_icon_state = "heye"

/datum/action/innate/terrorspider/remoteview/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/user = owner
	user.DoRemoteView()


// ---------- MOTHER ACTIONS

/datum/action/innate/terrorspider/mother/royaljelly
	name = "Lay Royal Jelly"
	button_icon_state = "spiderjelly"

/datum/action/innate/terrorspider/mother/royaljelly/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/mother/user = owner
	user.DoCreateJelly()

/datum/action/innate/terrorspider/mother/gatherspiderlings
	name = "Gather Spiderlings"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "spiderling"

/datum/action/innate/terrorspider/mother/gatherspiderlings/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/mother/user = owner
	user.PickupSpiderlings()

/datum/action/innate/terrorspider/mother/incubateeggs
	name = "Incubate Eggs"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "eggs"

/datum/action/innate/terrorspider/mother/incubateeggs/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/mother/user = owner
	user.IncubateEggs()

// ---------- QUEEN ACTIONS

/datum/action/innate/terrorspider/queen/queennest
	name = "Nest"
	button_icon = 'icons/mob/terrorspider.dmi'
	button_icon_state = "terror_queen"

/datum/action/innate/terrorspider/queen/queennest/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/user = owner
	user.NestPrompt()

/datum/action/innate/terrorspider/queen/queensense
	name = "Hive Sense"
	button_icon_state = "mindswap"

/datum/action/innate/terrorspider/queen/queensense/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/user = owner
	user.DoHiveSense()

/datum/action/innate/terrorspider/queen/queeneggs
	name = "Lay Queen Eggs"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "eggs"

/datum/action/innate/terrorspider/queen/queeneggs/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/user = owner
	user.LayQueenEggs()


// ---------- EMPRESS

/datum/action/innate/terrorspider/queen/empress/empresserase
	name = "Empress Erase Brood"
	button_icon = 'icons/effects/blood.dmi'
	button_icon_state = "mgibbl1"

/datum/action/innate/terrorspider/queen/empress/empresserase/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/user = owner
	user.EraseBrood()

/datum/action/innate/terrorspider/queen/empress/empresslings
	name = "Empresss Spiderlings"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "spiderling"

/datum/action/innate/terrorspider/queen/empress/empresslings/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/user = owner
	user.EmpressLings()


// ---------- WEB

/mob/living/simple_animal/hostile/poison/terror_spider/proc/Web()
	if(!web_type)
		return
	if(!isturf(loc))
		to_chat(src, "<span class='danger'>Webs can only be spun while standing on a floor.</span>")
		return
	var/turf/mylocation = loc
	visible_message("<span class='notice'>[src] begins to secrete a sticky substance.</span>")
	if(do_after(src, delay_web, target = loc))
		if(loc != mylocation)
			return
		else if(isspaceturf(loc))
			to_chat(src, "<span class='danger'>Webs cannot be spun in space.</span>")
		else
			var/obj/structure/spider/terrorweb/T = locate() in get_turf(src)
			if(T)
				to_chat(src, "<span class='danger'>There is already a web here.</span>")
			else
				var/obj/structure/spider/terrorweb/W = new web_type(loc)
				W.creator_ckey = ckey

/obj/structure/spider/terrorweb
	name = "terror web"
	desc = "It's stringy and sticky!"
	max_integrity = 20 // two welders, or one laser shot (15 for the normal spider webs)
	creates_cover = TRUE
	var/creator_ckey = null

/obj/structure/spider/terrorweb/Initialize(mapload)
	. = ..()
	if(prob(50))
		icon_state = "stickyweb2"
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/spider/terrorweb/CanPass(atom/movable/mover, border_dir)
	if(isterrorspider(mover))
		return TRUE
	if(istype(mover, /obj/item/projectile/terrorqueenspit))
		return TRUE
	if(isliving(mover))
		var/mob/living/M = mover
		if(!(M.mobility_flags & MOBILITY_MOVE))
			return TRUE
		return prob(80)
	if(isprojectile(mover))
		return prob(20)
	return ..()

/obj/structure/spider/terrorweb/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(isliving(entered) && !isterrorspider(entered))
		var/mob/living/M = entered
		to_chat(M, "<span class='userdanger'>You get stuck in [src] for a moment.</span>")
		M.Weaken(8 SECONDS)
		if(iscarbon(M))
			web_special_ability(M)
			addtimer(CALLBACK(src, PROC_REF(after_carbon_crossed), M), 7 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/**
  * Called some time after a carbon mob crossed the terror web.
  *
  * Arguments:
  * * C - The carbon mob.
  */
/obj/structure/spider/terrorweb/proc/after_carbon_crossed(mob/living/carbon/C)
	if(!QDELETED(C) && C.loc == loc)
		qdel(src)

/obj/structure/spider/terrorweb/bullet_act(obj/item/projectile/Proj)
	if(Proj.damage_type != BRUTE && Proj.damage_type != BURN)
		visible_message("<span class='danger'>[src] is undamaged by [Proj]!</span>")
		// Webs don't care about disablers, tasers, etc. Or toxin damage. They're organic, but not alive.
		return
	..()

/obj/structure/spider/terrorweb/proc/web_special_ability(mob/living/carbon/C)
	return

// ---------- WRAP

/mob/living/simple_animal/hostile/poison/terror_spider/proc/mobIsWrappable(mob/living/M)
	if(!istype(M))
		return FALSE
	if(M.stat != DEAD)
		return FALSE
	if(M.anchored)
		return FALSE
	if(!Adjacent(M))
		return FALSE
	if(isterrorspider(M))
		return FALSE
	return TRUE

/mob/living/simple_animal/hostile/poison/terror_spider/proc/FindWrapTarget()
	if(!cocoon_target)
		var/list/choices = list()
		for(var/mob/living/L in oview(1,src))
			if(!mobIsWrappable(L))
				continue
			choices += L
		for(var/obj/O in oview(1,src))
			if(Adjacent(O) && !O.anchored)
				if(!istype(O, /obj/structure/spider))
					choices += O
		if(length(choices))
			cocoon_target = tgui_input_list(src, "What do you wish to cocoon?", "Cocoon Selection", choices)
		else
			to_chat(src, "<span class='danger'>There is nothing nearby you can wrap.</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoWrap()
	if(cocoon_target && busy != SPINNING_COCOON)
		if(cocoon_target.anchored)
			cocoon_target = null
			return
		busy = SPINNING_COCOON
		visible_message("<span class='notice'>[src] begins to secrete a sticky substance around [cocoon_target].</span>")
		stop_automated_movement = TRUE
		GLOB.move_manager.stop_looping(src)
		if(do_after(src, 40, target = cocoon_target.loc))
			if(busy == SPINNING_COCOON)
				if(cocoon_target && isturf(cocoon_target.loc) && get_dist(src,cocoon_target) <= 1)
					var/obj/structure/spider/cocoon/C = new(cocoon_target.loc)
					var/large_cocoon = 0
					C.pixel_x = cocoon_target.pixel_x
					C.pixel_y = cocoon_target.pixel_y
					cocoon_target.extinguish_light()
					for(var/obj/O in C.loc)
						if(!O.anchored)
							if(isitem(O))
								O.loc = C
							else if(ismachinery(O))
								O.loc = C
								large_cocoon = 1
							else if(isstructure(O) && !istype(O, /obj/structure/spider)) // can't wrap spiderlings/etc
								O.loc = C
								large_cocoon = 1
					for(var/mob/living/L in C.loc)
						if(!mobIsWrappable(L))
							continue
						if(iscarbon(L))
							regen_points += regen_points_per_kill
							fed++
							visible_message("<span class='danger'>[src] sticks a proboscis into [L] and sucks a viscous substance out.</span>")
							to_chat(src, "<span class='notice'>You feel invigorated!</span>")
						else
							visible_message("<span class='danger'>[src] wraps [L] in a web.</span>")
						large_cocoon = 1
						last_cocoon_object = 0
						L.loc = C
						C.pixel_x = L.pixel_x
						C.pixel_y = L.pixel_y
						break
					if(large_cocoon)
						C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
		cocoon_target = null
		busy = 0
		stop_automated_movement = FALSE

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoVentSmash()
	var/valid_target = FALSE
	for(var/obj/machinery/atmospherics/unary/vent_pump/P in range(1, get_turf(src)))
		if(P.welded)
			valid_target = TRUE
	for(var/obj/machinery/atmospherics/unary/vent_scrubber/C in range(1, get_turf(src)))
		if(C.welded)
			valid_target = TRUE
	if(!valid_target)
		to_chat(src, "<span class='warning'>No welded vent or scrubber nearby!</span>")
		return
	playsound(get_turf(src), 'sound/machines/airlock_alien_prying.ogg', 50, 0)
	if(do_after(src, 40, target = loc))
		for(var/obj/machinery/atmospherics/unary/vent_pump/P in range(1, get_turf(src)))
			if(P.welded)
				P.welded = FALSE
				P.update_icon()
				P.update_pipe_image()
				forceMove(P.loc)
				P.visible_message("<span class='danger'>[src] smashes the welded cover off [P]!</span>")
				return
		for(var/obj/machinery/atmospherics/unary/vent_scrubber/C in range(1, get_turf(src)))
			if(C.welded)
				C.welded = FALSE
				C.update_icon()
				C.update_pipe_image()
				forceMove(C.loc)
				C.visible_message("<span class='danger'>[src] smashes the welded cover off [C]!</span>")
				return
		to_chat(src, "<span class='danger'>There is no welded vent or scrubber close enough to do this.</span>")

