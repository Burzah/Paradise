/**********************Lazarus Injector**********************/
/obj/item/lazarus_injector
	name = "lazarus injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise animals from the dead, making them become friendly to the user. Unfortunately, the process is useless on higher forms of life and incredibly costly, so these were hidden in storage until an executive thought they'd be great motivation for some of their employees."
	icon = 'icons/obj/hypo.dmi'
	icon_state = "lazarus_hypo"
	item_state = "hypo"
	origin_tech = "biotech=4;magnets=6"
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	var/loaded = 1
	var/malfunctioning = 0
	var/revive_type = SENTIENCE_ORGANIC //So you can't revive boss monsters or robots with it
	new_attack_chain = TRUE

/obj/item/lazarus_injector/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!loaded)
		return ITEM_INTERACT_COMPLETE
	if(isliving(target))
		if(isanimal(target))
			var/mob/living/simple_animal/M = target
			if(M.sentience_type != revive_type)
				to_chat(user, "<span class='notice'>[src] does not work on this sort of creature.</span>")
				return ITEM_INTERACT_COMPLETE
			if(M.stat == DEAD)
				M.faction = list("neutral")
				M.revive()
				M.AddElement(/datum/element/wears_collar)
				if(ishostile(target))
					var/mob/living/simple_animal/hostile/H = M
					if(isretaliate(target))
						// Clear the enemies list so we don't break windows
						// to get to people we no longer hate.
						var/mob/living/simple_animal/hostile/retaliate/R = H
						R.enemies.Cut()

					if(malfunctioning)
						H.faction |= list("lazarus", "\ref[user]")
						H.robust_searching = TRUE
						H.friends += user
						H.attack_same = TRUE
						log_game("[user] has revived hostile mob [target] with a malfunctioning lazarus injector")
					else
						H.attack_same = FALSE
				loaded = 0
				user.visible_message("<span class='notice'>[user] injects [M] with [src], reviving it.</span>")
				playsound(src,'sound/effects/refill.ogg',50,1)
				icon_state = "lazarus_empty"
				return ITEM_INTERACT_COMPLETE
			else
				to_chat(user, "<span class='notice'>[src] is only effective on the dead.</span>")
				return ITEM_INTERACT_COMPLETE
		else
			to_chat(user, "<span class='notice'>[src] is only effective on lesser beings.</span>")
			return ITEM_INTERACT_COMPLETE

/obj/item/lazarus_injector/emag_act(mob/user)
	if(!malfunctioning)
		malfunctioning = 1
		to_chat(user, "<span class='notice'>You override [src]'s safety protocols.</span>")
		return TRUE

/obj/item/lazarus_injector/emp_act()
	if(!malfunctioning)
		malfunctioning = 1

/obj/item/lazarus_injector/examine(mob/user)
	. = ..()
	if(!loaded)
		. += "<span class='notice'>[src] is empty.</span>"
	if(malfunctioning)
		. += "<span class='notice'>The display on [src] seems to be flickering.</span>"

/*********************Mob Capsule*************************/

/obj/item/mobcapsule
	name = "lazarus capsule"
	desc = "It allows you to store and deploy lazarus-injected creatures easier."
	icon = 'icons/obj/mobcap.dmi'
	icon_state = "mobcap0"
	w_class = WEIGHT_CLASS_TINY
	var/mob/living/simple_animal/captured = null
	var/colorindex = 0
	var/capture_type = SENTIENCE_ORGANIC //So you can't capture boss monsters or robots with it

/obj/item/mobcapsule/Destroy()
	if(captured)
		captured.ghostize()
		QDEL_NULL(captured)
	return ..()

/obj/item/mobcapsule/attack__legacy__attackchain(mob/living/simple_animal/S, mob/user, prox_flag)
	if(istype(S) && S.sentience_type == capture_type)
		capture(S, user)
		return TRUE
	return ..()

/obj/item/mobcapsule/proc/capture(mob/living/simple_animal/S, mob/living/M)
	if(captured)
		to_chat(M, "<span class='notice'>Capture failed!</span>: The capsule already has a mob registered to it!")
	else
		if("neutral" in S.faction)
			S.forceMove(src)
			var/obj/item/petcollar/collar = S.get_item_by_slot(ITEM_SLOT_COLLAR)
			if(collar)
				name = "Lazarus Capsule: [S.name]"
			else
				S.name = "[M.name]'s [initial(S.name)]"
				name = "Lazarus Capsule: [initial(S.name)]"
			S.cancel_camera()
			to_chat(M, "<span class='notice'>You placed a [S.name] inside the Lazarus Capsule!</span>")
			captured = S
		else
			to_chat(M, "You can't capture that mob!")

/obj/item/mobcapsule/throw_impact(atom/A, mob/user)
	..()
	if(captured)
		dump_contents(user)

/obj/item/mobcapsule/proc/dump_contents(mob/user)
	if(captured)
		captured.forceMove(get_turf(src))
		captured = null

/obj/item/mobcapsule/attack_self__legacy__attackchain(mob/user)
	colorindex += 1
	if(colorindex >= 6)
		colorindex = 0
	update_icon(UPDATE_ICON_STATE)

/obj/item/mobcapsule/update_icon_state()
	icon_state = "mobcap[colorindex]"
