/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	restricted_jobs = list("Cyborg")//They are part of the AI if he is traitor so are they, they use to get double chances
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Magistrate", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer", "Trans-Solar Federation General", "Nanotrasen Career Trainer", "Research Director", "Head of Personnel", "Chief Medical Officer", "Chief Engineer", "Quartermaster")
	required_enemies = 1
	recommended_enemies = 4
	/// Hard limit on traitors if scaling is turned off.
	var/traitors_possible = 4
	/// How much the amount of players get divided by to determine the number of traitors.
	var/const/traitor_scaling_coeff = 5

/datum/game_mode/traitor/announce()
	to_chat(world, "<B>The current game mode is - Traitor!</B>")
	to_chat(world, "<B>There is a syndicate traitor on the station. Do not let the traitor succeed!</B>")

/datum/game_mode/traitor/pre_setup()

	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs

	var/list/possible_traitors = get_players_for_role(ROLE_TRAITOR)

	for(var/datum/mind/candidate in possible_traitors)
		if(candidate.special_role == SPECIAL_ROLE_VAMPIRE || candidate.special_role == SPECIAL_ROLE_CHANGELING || candidate.special_role == SPECIAL_ROLE_MIND_FLAYER) // no traitor vampires, changelings, or mindflayers
			possible_traitors.Remove(candidate)

	// stop setup if no possible traitors
	if(!length(possible_traitors))
		return FALSE

	var/num_traitors = 1

	num_traitors = traitors_to_add()

	for(var/i in 1 to num_traitors)
		if(!length(possible_traitors))
			break
		var/datum/mind/traitor = pick_n_take(possible_traitors)
		pre_traitors += traitor
		traitor.special_role = SPECIAL_ROLE_TRAITOR
		traitor.restricted_roles = restricted_jobs

	if(!length(pre_traitors))
		return FALSE
	return TRUE

/datum/game_mode/traitor/post_setup()
	. = ..()

	var/random_time = rand(5 MINUTES, 15 MINUTES)
	if(length(pre_traitors))
		addtimer(CALLBACK(src, PROC_REF(fill_antag_slots)), random_time)

	for(var/datum/mind/traitor in pre_traitors)
		var/datum/antagonist/traitor/traitor_datum = new(src)
		if(ishuman(traitor.current))
			traitor_datum.delayed_objectives = TRUE
			traitor_datum.addtimer(CALLBACK(traitor_datum, TYPE_PROC_REF(/datum/antagonist/traitor, reveal_delayed_objectives)), random_time, TIMER_DELETE_ME)

		traitor.add_antag_datum(traitor_datum)

/datum/game_mode/traitor/traitors_to_add()
	if(GLOB.configuration.gamemode.traitor_scaling)
		. = max(1, round(num_players() / traitor_scaling_coeff))
	else
		. = max(1, min(num_players(), traitors_possible))

	if(!length(traitors))
		return

	for(var/datum/mind/traitor_mind as anything in traitors)
		if(!QDELETED(traitor_mind) && traitor_mind.current) // Explicitly no client check in case you happen to fall SSD when this gets ran
			continue
		.++
		traitors -= traitor_mind

/datum/game_mode/traitor/declare_completion()
	..()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder.

/datum/game_mode/proc/auto_declare_completion_traitor()
	if(length(traitors))
		var/list/text = list("<FONT size = 2><B>The traitors were:</B></FONT><br>")
		for(var/datum/mind/traitor in traitors)
			var/traitorwin = TRUE
			text += printplayer(traitor)

			var/TC_uses = 0
			var/used_uplink = FALSE
			var/purchases = ""
			for(var/obj/item/uplink/H in GLOB.world_uplinks)
				if(H && H.uplink_owner && H.uplink_owner == traitor.key)
					TC_uses += H.used_TC
					used_uplink = TRUE
					purchases += H.purchase_log

			if(used_uplink)
				text += " (used [TC_uses] TC) [purchases]"

			var/all_objectives = traitor.get_all_objectives(include_team = FALSE)

			if(length(all_objectives))//If the traitor had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in all_objectives)
					if(objective.check_completion())
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						if(istype(objective, /datum/objective/steal))
							var/datum/objective/steal/S = objective
							SSblackbox.record_feedback("nested tally", "traitor_steal_objective", 1, list("Steal [S.steal_target]", "SUCCESS"))
						else
							SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[objective.type]", "SUCCESS"))
					else
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						if(istype(objective, /datum/objective/steal))
							var/datum/objective/steal/S = objective
							SSblackbox.record_feedback("nested tally", "traitor_steal_objective", 1, list("Steal [S.steal_target]", "FAIL"))
						else
							SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[objective.type]", "FAIL"))
						traitorwin = FALSE
					count++

			var/special_role_text
			if(traitor.special_role)
				special_role_text = lowertext(traitor.special_role)
			else
				special_role_text = "antagonist"

			var/datum/contractor_hub/H = LAZYACCESS(GLOB.contractors, traitor)
			if(H)
				var/count = 1
				var/earned_tc = H.reward_tc_paid_out
				for(var/c in H.contracts)
					var/datum/syndicate_contract/C = c
					// Locations
					var/locations = list()
					for(var/a in C.contract.candidate_zones)
						var/area/A = a
						locations += (A == C.contract.extraction_zone ? "<b><u>[A.map_name]</u></b>" : A.map_name)
					var/display_locations = english_list(locations, and_text = " or ")
					// Result
					var/result = ""
					if(C.status == CONTRACT_STATUS_COMPLETED)
						result = "<font color='green'><B>Success!</B></font>"
					else if(C.status != CONTRACT_STATUS_INACTIVE)
						result = "<font color='red'>Fail.</font>"
					text += "<br><font color='orange'><B>Contract #[count]</B></font>: Kidnap and extract [C.target_name] at [display_locations]. [result]"
					count++
				text += "<br><font color='orange'><B>[earned_tc] TC were earned from the contracts.</B></font>"

			if(traitorwin)
				text += "<br><font color='green'><B>The [special_role_text] was successful!</B></font><br>"
				SSblackbox.record_feedback("tally", "traitor_success", 1, "SUCCESS")
			else
				text += "<br><font color='red'><B>The [special_role_text] has failed!</B></font><br>"
				SSblackbox.record_feedback("tally", "traitor_success", 1, "FAIL")

		if(length(SSticker.mode.implanted))
			text += "<br><br><FONT size = 2><B>The mindslaves were:</B></FONT><br>"
			for(var/datum/mind/mindslave in SSticker.mode.implanted)
				text += printplayer(mindslave)
				var/datum/mind/master_mind = SSticker.mode.implanted[mindslave]
				text += " (slaved by: <b>[master_mind.current]</b>)<br>"

		var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
		var/responses = jointext(GLOB.syndicate_code_response, ", ")

		text += "<br><br><b>The code phrases were:</b> <span class='danger'>[phrases]</span><br>\
					<b>The code responses were:</b> <span class='danger'>[responses]</span><br><br>"

		return text.Join("")
