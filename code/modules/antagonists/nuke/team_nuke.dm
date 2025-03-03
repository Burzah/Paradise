/datum/team/nuke
	name = "Nuclear Operatives"
	antag_datum_type = /datum/antagonist/nuclear_operatives

	var/syndicate_name
	var/obj/machinery/nuclearbomb/tracked_nuke
	var/core_objective = /datum/objective/nuclear


/datum/team/nuke/create_team()

/datum/team/nuke/proc/study_objectives(mob/living/M)
	if(!M)
		return

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
