RESTRICT_TYPE(/datum/antagonist/nuke)

/datum/antagonist/nuke
	name = "Nuclear Operative"
	job_rank = ROLE_OPERATIVE
	special_role = SPECIAL_ROLE_NUKEOPS
	give_objectives = FALSE
	antag_hud_name = "hudops"
	antag_hud_type = ANTAG_HUD_OPS
	wiki_page_name = "Operative"

/datum/antagonist/nuke/on_gain()
	create_team()
	..()
	owner.current.faction |= "operative"
	SEND_SOUND(owner.current, sounds('sound/ambience/antag/ops.ogg'))

	var/datum/team/nuke/nuke = get_team()
	ASSERT(nuke)

/datum/antagonist/nuke/add_owner_to_gamemode()
	SSticker.mode.syndicates |= owner

/datum/antagonist/nuke/remove_owner_from_gamemode()
	SSticker.mode.syndicate -= owner

/datum/antagonist/nuke/greet() //TODO: Figure out greeting
	return

/datum/antagonist/nuke/farewell() //TODO: Figure out farewell
	return

/datum/antagonist/nuke/create_team(team)
	return SSticker.mode.get_nuke_team()

/datum/antagonist/nuke/get_team()
	return SSticker.mode.nuke_team

///Used for setting up the mobs and equipping them
/datum/antagonist/nuke/proc/equip_nukies()
	var/radio_freq = SYND_FREQ

	var/obj/item/radio/R = new /obj/item/radio/headset/syndicate/alt(synd_mob)
	R.set_frequency(radio_freq)
	synd_mob.equip_to_slot_or_del(R, ITEM_SLOT_LEFT_EAR)

	var/back

	switch(synd_mob.backbag)
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

	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(synd_mob), ITEM_SLOT_JUMPSUIT)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(synd_mob), ITEM_SLOT_SHOES)
	synd_mob.equip_or_collect(new /obj/item/clothing/gloves/combat(synd_mob), ITEM_SLOT_GLOVES)
	synd_mob.equip_to_slot_or_del(new /obj/item/card/id/syndicate(synd_mob), ITEM_SLOT_ID)
	synd_mob.equip_to_slot_or_del(new back(synd_mob), ITEM_SLOT_BACK)
	synd_mob.equip_to_slot_or_del(new /obj/item/gun/projectile/automatic/pistol(synd_mob), ITEM_SLOT_BELT)
	synd_mob.equip_to_slot_or_del(new /obj/item/storage/box/survival_syndi(synd_mob.back), ITEM_SLOT_IN_BACKPACK)
	synd_mob.equip_to_slot_or_del(new /obj/item/pinpointer/nukeop(synd_mob), ITEM_SLOT_PDA)
	var/obj/item/radio/uplink/nuclear/U = new /obj/item/radio/uplink/nuclear(synd_mob)
	U.hidden_uplink.uplink_owner="[synd_mob.key]"
	U.hidden_uplink.uses = uplink_uses
	synd_mob.equip_to_slot_or_del(U, ITEM_SLOT_IN_BACKPACK)
	synd_mob.mind.offstation_role = TRUE

	if(synd_mob.dna.species)
		var/race = synd_mob.dna.species.name

		switch(race)
			if("Vox")
				synd_mob.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(synd_mob), ITEM_SLOT_MASK)
				synd_mob.equip_to_slot_or_del(new /obj/item/tank/internals/emergency_oxygen/double/vox(synd_mob), ITEM_SLOT_LEFT_HAND)
				synd_mob.internal = synd_mob.l_hand
				synd_mob.update_action_buttons_icon()

			if("Plasmaman")
				synd_mob.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(synd_mob), ITEM_SLOT_MASK)
				synd_mob.equip_or_collect(new /obj/item/tank/internals/plasmaman(synd_mob), ITEM_SLOT_SUIT_STORE)
				synd_mob.equip_or_collect(new /obj/item/extinguisher_refill(synd_mob), ITEM_SLOT_IN_BACKPACK)
				synd_mob.equip_or_collect(new /obj/item/extinguisher_refill(synd_mob), ITEM_SLOT_IN_BACKPACK)
				synd_mob.internal = synd_mob.get_item_by_slot(ITEM_SLOT_SUIT_STORE)
				synd_mob.update_action_buttons_icon()

	synd_mob.rejuvenate() //fix any damage taken by naked vox/plasmamen/etc while round setups
	var/obj/item/bio_chip/explosive/E = new/obj/item/bio_chip/explosive(synd_mob)
	E.implant(synd_mob)
	// synd_mob.faction |= "syndicate" //TODO: DELETE ME
	// synd_mob.update_icons()
	return TRUE

