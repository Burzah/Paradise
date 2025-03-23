/datum/team/nuke
	name = "Nuclear Operatives"
	antag_datum_type = /datum/antagonist/nuclear_operative

	var/syndicate_name
	var/obj/machinery/nuclearbomb/tracked_nuke
	var/core_objective = /datum/objective/nuclear

	var/nuke_scaling_modifier = 6
	/// Total amount of telecrystals shared between nuke ops
	var/total_tc

/datum/team/nuke/create_team(list/operatives)
	. = ..()
	objective_holder.add_objective(/datum/objective/nuclear)

	for(var/datum/mind/M as anything in operatives)
		var/datum/antagonist/nuclear_operative/operative = M.has_antag_datum(/datum/antagonist/nuclear_operative)
		operative.equip_operatives()

/datum/team/nuke/can_create_team()
	return isnull(SSticker.mode.nuke_team)

/datum/team/nuke/assign_team()
	SSticker.mode.nuke_team = src

/datum/team/nuke/clear_team_reference()
	if(SSticker.mode.nuke_team == src)
		SSticker.mode.nuke_team = null
	else
		CRASH("[src] ([type]) attempted to clear a team reference that wasn't itself!")

// TODO: Figure out how to use this properly vs. declare_completion in game mode
/datum/team/nuke/on_round_end()
	var/list/end_text = list()
	end_text += "<br><b>Nuclear Operatives' objectives:</b>"
	for(var/datum/objective/obj in objective_holder.get_objectives())
		end_text += "<br>[obj.explanation_text] - "
		if(!obj.check_completion())
			end_text += "<font color='red'>Fail.</font>"
		else
			end_text += "<font color='green'><b>Success!</b></font>"
	to_chat(world, end_text.Join(""))


/datum/team/nuke/proc/get_operatives()
	var/operatives = 0
	var/cyborgs = 0
	var/list/minds_to_remove = list()

	for(var/datum/mind/M as anything in member)
		if(isnull(M))
			stack_trace("Found a null mind in /datum/team/nuke's members. Removing...")
			minds_to_remove |= M
			continue
		if(isnull(M.current))
			stack_trace("Found a mind with no body in /datum/team/nuke's members. Removing...")
			minds_to_remove |= M
			continue
		if(QDELETED(M) || M.current.stat == DEAD)
			continue
		if(ishuman(M.current))
			operatives++
		// else if(istype(M.current, ) // TODO: Figure out how to plug cyborgs into this

	if(length(minds_to_remove))
		for(var/datum/mind/M as anything in minds_to_remove)
			remove_member(M)

	return operatives + cyborgs

// TODO: set for use in this datum - originally part of gamemode post setup
/datum/antagonist/nuclear_operative/proc/scale_telecrystals()
	var/list/living_crew = get_living_players(exclude_nonhuman = FALSE, exclude_offstation = TRUE)
	var/danger = length(living_crew)
	while(!ISMULTIPLE(++danger, 10)) //Increments danger up to the nearest multiple of ten

	total_tc += danger * nuke_scaling_modifier

// TODO: set for use in this datum - originally part of gamemode post setup
/datum/antagonist/nuclear_operative/proc/share_telecrystals()
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

