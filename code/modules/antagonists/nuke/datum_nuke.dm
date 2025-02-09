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


/datum/antagonist/nuke/proc/remove_owner_from_gamemode()
	SSticker.mode.syndicate -= owner
