RESTRICT_TYPE(/datum/antagonist/nuclear_operatives)

/datum/antagonist/nuclear_operatives
	name = "Nuclear Operative"
	job_rank = ROLE_OPERATIVE
	special_role = SPECIAL_ROLE_NUKEOPS
	give_objectives = FALSE
	antag_hud_name = "hudops"
	antag_hud_type = ANTAG_HUD_OPS
	wiki_page_name = "Operative"

/datum/antagonist/nuclear_operatives/on_gain()
	create_team()
	..()
	owner.current.faction |= "operative"
	owner.current.create_log(CONVERSION_LOG, "Joined as Nuclear Operative")
	SEND_SOUND(owner.current, sounds('sound/ambience/antag/ops.ogg'))

	var/datum/team/nuke/nuke = get_team()
	nuke.study_objectives(owner.current)

/datum/antagonist/nuclear_operatives/detach_from_owner()
	if(!owner.current)
		return ..()
	owner.current.faction -= "operative"
	owner.current.create_log(CONVERSION_LOG, "Removed from Nuclear Operatives")

// TODO: change syndicates in gamemode code to operative for clarity
/datum/antagonist/nuclear_operatives/add_owner_to_gamemode()
	SSticker.mode.syndicates |= owner

// TODO: change syndicates in gamemode code to operative for clarity
/datum/antagonist/nuclear_operatives/remove_owner_from_gamemode()
	SSticker.mode.syndicates -= owner

// TODO: Figure out greeting (might not need this?)
/datum/antagonist/nuclear_operatives/greet()
	return

// TODO: Figure out farewell (might not need this?)
/datum/antagonist/nuclear_operatives/farewell()
	return

/datum/antagonist/nuclear_operatives/create_team(team)
	return SSticker.mode.get_nuke_team()

/datum/antagonist/nuclear_operatives/get_team()
	return SSticker.mode.nuke_team

/// Used for equipping nuclear operatives
/datum/antagonist/nuclear_operatives/proc/equip_operatives(/mob/living/carbon/human/operative, uplink_uses = 100)
	var/radio_freq = SYND_FREQ

	var/obj/item/radio/R = new /obj/item/radio/headset/syndicate/alt(synd_mob)
	R.set_frequency(radio_freq)
	operative.equip_to_slot_or_del(R, ITEM_SLOT_LEFT_EAR)

	var/back

	switch(operative.backbag)
		if(GBACKPACK, DBACKPACK)
			back = /obj/item/storage/backpack
		if(GSATCHEL, DSATCHEL)
			back = /obj/item/storage/backpack/satchel_norm
		if(GDUFFLEBAG, DDUFFLEBAG)
			back = /obj/item/storage/backpack/duffel
		if(LSATCHEL)
			back = /obj/item/storage/backpack/satchel
		else
			back = /obj/item/storage/backpack

	operative.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(synd_mob), ITEM_SLOT_JUMPSUIT)
	operative.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(synd_mob), ITEM_SLOT_SHOES)
	operative.equip_or_collect(new /obj/item/clothing/gloves/combat(synd_mob), ITEM_SLOT_GLOVES)
	operative.equip_to_slot_or_del(new /obj/item/card/id/syndicate(synd_mob), ITEM_SLOT_ID)
	operative.equip_to_slot_or_del(new back(synd_mob), ITEM_SLOT_BACK)
	operative.equip_to_slot_or_del(new /obj/item/gun/projectile/automatic/pistol(synd_mob), ITEM_SLOT_BELT)
	operative.equip_to_slot_or_del(new /obj/item/storage/box/survival_syndi(synd_mob.back), ITEM_SLOT_IN_BACKPACK)
	operative.equip_to_slot_or_del(new /obj/item/pinpointer/nukeop(synd_mob), ITEM_SLOT_PDA)
	var/obj/item/radio/uplink/nuclear/U = new /obj/item/radio/uplink/nuclear(synd_mob)
	U.hidden_uplink.uplink_owner="[synd_mob.key]"
	U.hidden_uplink.uses = uplink_uses
	operative.equip_to_slot_or_del(U, ITEM_SLOT_IN_BACKPACK)
	operative.mind.offstation_role = TRUE

	if(operative.dna.species)
		var/race = synd_mob.dna.species.name

		switch(race)
			if("Vox")
				operative.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(operative), ITEM_SLOT_MASK)
				operative.equip_to_slot_or_del(new /obj/item/tank/internals/emergency_oxygen/double/vox(operative), ITEM_SLOT_LEFT_HAND)
				operative.internal = operative.l_hand
				operative.update_action_buttons_icon()

			if("Plasmaman")
				operative.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(operative), ITEM_SLOT_MASK)
				operative.equip_or_collect(new /obj/item/tank/internals/plasmaman(operative), ITEM_SLOT_SUIT_STORE)
				operative.equip_or_collect(new /obj/item/extinguisher_refill(operative), ITEM_SLOT_IN_BACKPACK)
				operative.equip_or_collect(new /obj/item/extinguisher_refill(operative), ITEM_SLOT_IN_BACKPACK)
				operative.internal = synd_mob.get_item_by_slot(ITEM_SLOT_SUIT_STORE)
				operative.update_action_buttons_icon()

	operative.rejuvenate()
	var/obj/item/bio_chip/explosive/E = new/obj/item/bio_chip/explosive(operative)
	E.implant(operative)
	return TRUE

// TODO: finish renaming all instances of create_syndicate to create_operative
/datum/antagonist/nuclear_operatives/proc/create_operative(datum/mind/operative, obj/machinery/nuclearbomb/syndicate/the_bomb)
	var/mob/living/carbon/human/M = operative.current

	M.set_species(/datum/species/human, TRUE)
	M.dna.flavor_text = null
	M.flavor_text = null
	M.dna.ready_dna(M)
	M.dna.species.create_organs(M)
	M.cleanSE()
	M.overeatduration = 0

	var/obj/item/organ/external/head/head_organ = M.get_organ("head")
	var/hair_c = pick("#8B4513","#000000","#FF4500","#FFD700")
	var/eye_c = pick("#000000","#8B4513","1E90FF")
	var/skin_tone = pick(-50, -30, -10, 0, 0, 0, 10)
	head_organ.facial_colour = hair_c
	head_organ.sec_facial_colour = hair_c
	head_organ.hair_colour = hair_c
	head_organ.sec_hair_colour = hair_c
	M.change_eye_color(eye_c)
	M.s_tone = skin_tone
	head_organ.h_style = random_hair_style(M.gender, head_organ.dna.species.name)
	head_organ.f_style = random_facial_hair_style(M.gender, head_organ.dna.species.name)
	M.body_accessory = null
	M.regenerate_icons()
	M.update_body()

	if(!the_bomb)
		the_bomb = locate(/obj/machinery/nuclearbomb/syndicate) in GLOB.poi_list

	if(the_bomb)
		operative.store_memory("<b>Syndicate [the_bomb.name] Code</b>: [the_bomb.r_code]")
		to_chat(operative.current, "The code for \the [the_bomb.name] is: <b>[the_bomb.r_code]</b>")

// TODO: make sure all instances of prepare_syndicate_leader are changed to prepare_leader
/datum/antagonist/nuclear_operatives/proc/prepare_leader(datum/mind/operative, obj/machinery/nuclearbomb/syndicate/the_bomb)
	var/leader_title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	operative.current.real_name = "[syndicate_name()] Team [leader_title]"
	to_chat(operative.current, "<b>You are the Syndicate leader for this mission. You are responsible for the distribution of telecrystals and your ID is the only one who can open the launch bay doors.</b>")
	to_chat(operative.current, "<b>If you feel you are not up to this task, give your ID to another operative.</b>")
	to_chat(operative.current, "<b>In your hand you will find a special item capable of triggering a greater challenge for your team. Examine it carefully and consult with your fellow operatives before activating it.</b>")

	var/obj/item/nuclear_challenge/challenge = new /obj/item/nuclear_challenge
	operative.current.equip_to_slot_or_del(challenge, ITEM_SLOT_RIGHT_HAND)

	update_syndicate_id(operative, leader_title, TRUE)

	if(the_bomb)
		var/obj/item/paper/P = new
		P.info = "The code for \the [the_bomb.name] is: <b>[the_bomb.r_code]</b>"
		P.name = "nuclear bomb code"
		var/obj/item/stamp/syndicate/stamp = new
		P.stamp(stamp)
		qdel(stamp)

		if(SSticker.mode.config_tag=="nuclear")
			P.loc = operative.current.loc
		else
			var/mob/living/carbon/human/H = operative.current
			P.loc = H.loc
			H.equip_to_slot_or_del(P, ITEM_SLOT_RIGHT_POCKET, 0)
			H.update_icons()


// TODO: set for use in this datum - originally part of gamemode post setup
// TODO: Possibly move this to team datum
/datum/antagonist/nuclear_operatives/proc/scale_telecrystals()
	var/list/living_crew = get_living_players(exclude_nonhuman = FALSE, exclude_offstation = TRUE)
	var/danger = length(living_crew)
	while(!ISMULTIPLE(++danger, 10)) //Increments danger up to the nearest multiple of ten

	total_tc += danger * NUKESCALINGMODIFIER // TODO: reimplement define

// TODO: set for use in this datum - originally part of gamemode post setup
// TODO: Possibly move this to team datum
/datum/antagonist/nuclear_operatives/proc/share_telecrystals()
	var/player_tc
	var/remainder

	player_tc = round(total_tc / length(GLOB.nuclear_uplink_list)) //round to get an integer and not floating point
	remainder = total_tc % length(GLOB.nuclear_uplink_list)

	for(var/obj/item/radio/uplink/nuclear/U in GLOB.nuclear_uplink_list)
		U.hidden_uplink.uses += player_tc
	while(remainder > 0)
		for(var/obj/item/radio/uplink/nuclear/U in GLOB.nuclear_uplink_list)
			if(remainder <= 0)
				break
			U.hidden_uplink.uses++
			remainder--

/datum/game_mode/proc/update_syndicate_id(datum/mind/operative, is_leader = FALSE)
	var/list/found_ids = operative.current.search_contents_for(/obj/item/card/id)

	if(length(found_ids))
		for(var/obj/item/card/id/ID in found_ids)
			ID.name = "[operative.current.real_name] ID card"
			ID.registered_name = operative.current.real_name
			if(is_leader)
				ID.access += ACCESS_SYNDICATE_LEADER
	else
		message_admins("Warning: Operative [key_name_admin(operative.current)] spawned without an ID card!")

