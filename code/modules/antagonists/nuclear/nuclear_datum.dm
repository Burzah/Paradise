RESTRICT_TYPE(/datum/antagonist/nuclear)

/datum/antagonist/nuclear
	name = "Nuclear Operative"
	job_rank = ROLE_OPERATIVE
	give_objectives = FALSE
	antag_hud_name = "hudnuclear"
	antag_hud_type = ANTAG_HUD_OPS
	wiki_page_name = "Operative"

/datum/antagonist/nuclear/on_gain()
	create_team()
	..()
	owner.current.faction |= "operative"
	SEND_SOUND(owner.current, sounds('sound/ambience/antag/ops.ogg'))
	owner.current.create_log(MISC_LOG)

