/datum/game_mode/proc/get_nuke_team()
	if(!nuke_team)
		new /datum/team/nuke()
	return nuke_team

/proc/issyndicate(mob/living/M as mob)
	return istype(M) && M.mind && SSticker && SSticker.mode && (M.mind in SSticker.mode.operatives)

/datum/game_mode/nuclear
	name = "nuclear emergency"
	config_tag = "nuclear"
	tdm_gamemode = TRUE
	// 30 players - 5 players to be the nuke ops = 25 players remaining
	required_players = 30
	required_enemies = 5
	recommended_enemies = 5
	single_antag_positions = list()


	// Numver of operatives possible
	var/const/operatives_possible = 5

	var/nukes_left = 1
	/// Used for tracking if the syndies actually haul the nuke to the station
	var/nuke_off_station = 0
	/// Used for tracking if the syndies got the shuttle off of the z-level
	var/syndies_didnt_escape = 0

/datum/game_mode/nuclear/announce()
	to_chat(world, "<B>The current game mode is - Nuclear Emergency!</B>")
	to_chat(world, "<B>A [syndicate_name()] Strike Force is approaching [station_name()]!</B>")
	to_chat(world, "A nuclear explosive was being transported by Nanotrasen to a military base. The transport ship mysteriously lost contact with Space Traffic Control (STC). About that time a strange disk was discovered around [station_name()]. It was identified by Nanotrasen as a nuclear authentication disk and now Syndicate Operatives have arrived to retake the disk and detonate SS13! There are most likely Syndicate starships are in the vicinity, so take care not to lose the disk!\n<B>Syndicate</B>: Reclaim the disk and detonate the nuclear bomb anywhere on SS13.\n<B>Personnel</B>: Hold the disk and <B>escape with the disk</B> on the shuttle!")

/datum/game_mode/nuclear/can_start()
	if(!..())
		return 0

	var/list/possible_operatives = get_players_for_role(ROLE_OPERATIVE)
	var/agent_number = 0

	if(length(possible_operatives) < 1)
		return 0

	if(LAZYLEN(possible_operatives) > operatives_possible)
		agent_number = operatives_possible
	else
		agent_number = length(possible_operatives)

	var/n_players = num_players()
	if(agent_number > n_players)
		agent_number = n_players/2

	while(agent_number > 0)
		var/datum/mind/new_operative = pick(possible_operatives)
		operatives += new_operative
		possible_operatives -= new_operative //So it doesn't pick the same guy each time.
		agent_number--

	return 1


/datum/game_mode/nuclear/pre_setup()
	..()
	return 1

// TODO: look over what can be moved to antag datum and team datum before deleting
// TODO: setup similar to cult gamemode when finished with above
/datum/game_mode/nuclear/post_setup()
	new /datum/team/nuke

	// var/list/turf/synd_spawn = list()

	// for(var/obj/effect/landmark/spawner/syndie/S in GLOB.landmarks_list)
	// 	synd_spawn += get_turf(S)
	// 	qdel(S)
	// 	continue

	// var/obj/machinery/nuclearbomb/syndicate/the_bomb
	// var/nuke_code = rand(10000, 99999)
	// var/leader_selected = 0
	// var/agent_number = 1
	// var/spawnpos = 1

	// for(var/obj/effect/landmark/spawner/nuclear_bomb/syndicate/nuke_spawn in GLOB.landmarks_list)
	// 	if(!length(synd_spawn))
	// 		break

	// 	the_bomb = new /obj/machinery/nuclearbomb/syndicate(get_turf(nuke_spawn))
	// 	the_bomb.r_code = nuke_code
	// 	break

	// for(var/datum/mind/synd_mind in syndicates)
	// 	if(spawnpos > length(synd_spawn))
	// 		spawnpos = 2
	// 	synd_mind.current.loc = synd_spawn[spawnpos]
	// 	synd_mind.offstation_role = TRUE
	// 	forge_syndicate_objectives(synd_mind)
	// 	create_syndicate(synd_mind, the_bomb)
	// 	greet_syndicate(synd_mind)
	// 	// equip_syndicate(synd_mind.current)

	// 	if(!leader_selected)
	// 		prepare_syndicate_leader(synd_mind, the_bomb)
	// 		leader_selected = 1
	// 	else
	// 		synd_mind.current.real_name = "[syndicate_name()] Operative #[agent_number]"
	// 		update_syndicate_id(synd_mind, FALSE)

	// 		agent_number++
	// 	spawnpos++
	// 	// update_synd_icons_added(synd_mind)

	// scale_telecrystals() // TODO: proc moved out gamemode to datum
	// share_telecrystals() // TODO: proc moved out gamemode to datum

	// return ..()

// TODO: move this to the antag datum
/datum/game_mode/proc/greet_syndicate(datum/mind/syndicate, you_are=1)
	SEND_SOUND(syndicate.current, sound('sound/ambience/antag/ops.ogg'))
	var/list/messages = list()
	if(you_are)
		messages.Add("<span class='notice'>You are a [syndicate_name()] agent!</span>")

	messages.Add(syndicate.prepare_announce_objectives(FALSE))
	messages.Add("<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Nuclear_Agent)</span>")
	to_chat(syndicate.current, chat_box_red(messages.Join("<br>")))
	syndicate.current.create_log(MISC_LOG, "[syndicate.current] was made into a nuclear operative")


/datum/game_mode/proc/random_radio_frequency()
	return 1337 // WHY??? -- Doohl


/datum/game_mode/proc/is_operatives_are_dead()
	for(var/datum/mind/operative_mind in operatives)
		if(!ishuman(operative_mind.current))
			if(operative_mind.current)
				if(operative_mind.current.stat!=2)
					return 0
	return 1


/datum/game_mode/nuclear/declare_completion()
	var/disk_rescued = 1
	for(var/obj/item/disk/nuclear/D in GLOB.poi_list)
		if(!D.onCentcom())
			disk_rescued = 0
			break
	var/crew_evacuated  = (SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
	//var/operatives_are_dead = is_operatives_are_dead()


	//nukes_left
	//station_was_nuked
	//derp //Used for tracking if the syndies actually haul the nuke to the station	//no
	//herp //Used for tracking if the syndies got the shuttle off of the z-level	//NO, DON'T FUCKING NAME VARS LIKE THIS

	if(!disk_rescued && station_was_nuked && !syndies_didnt_escape)
		SSticker.mode_result = "nuclear win - syndicate nuke"
		to_chat(world, "<FONT size = 3><B>Syndicate Major Victory!</B></FONT>")
		to_chat(world, "<B>[syndicate_name()] operatives have destroyed [station_name()]!</B>")

	else if(!disk_rescued && station_was_nuked && syndies_didnt_escape)
		SSticker.mode_result = "nuclear halfwin - syndicate nuke - did not evacuate in time"
		to_chat(world, "<FONT size = 3><B>Total Annihilation</B></FONT>")
		to_chat(world, "<B>[syndicate_name()] operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</B> Next time, don't lose the disk!")

	else if(!disk_rescued && !station_was_nuked && nuke_off_station && !syndies_didnt_escape)
		SSticker.mode_result = "nuclear halfwin - blew wrong station"
		to_chat(world, "<FONT size = 3><B>Crew Minor Victory</B></FONT>")
		to_chat(world, "<B>[syndicate_name()] operatives secured the authentication disk but blew up something that wasn't [station_name()].</B> Next time, don't lose the disk!")

	else if(!disk_rescued && !station_was_nuked && nuke_off_station && syndies_didnt_escape)
		SSticker.mode_result = "nuclear halfwin - blew wrong station - did not evacuate in time"
		to_chat(world, "<FONT size = 3><B>[syndicate_name()] operatives have earned Darwin Award!</B></FONT>")
		to_chat(world, "<B>[syndicate_name()] operatives blew up something that wasn't [station_name()] and got caught in the explosion.</B> Next time, don't lose the disk!")

	else if(disk_rescued && is_operatives_are_dead())
		SSticker.mode_result = "nuclear loss - evacuation - disk secured - syndi team dead"
		to_chat(world, "<FONT size = 3><B>Crew Major Victory!</B></FONT>")
		to_chat(world, "<B>The Research Staff has saved the disc and killed the [syndicate_name()] Operatives</B>")

	else if(disk_rescued)
		SSticker.mode_result = "nuclear loss - evacuation - disk secured"
		to_chat(world, "<FONT size = 3><B>Crew Major Victory</B></FONT>")
		to_chat(world, "<B>The Research Staff has saved the disc and stopped the [syndicate_name()] Operatives!</B>")

	else if(!disk_rescued && is_operatives_are_dead())
		SSticker.mode_result = "nuclear loss - evacuation - disk not secured"
		to_chat(world, "<FONT size = 3><B>Syndicate Minor Victory!</B></FONT>")
		to_chat(world, "<B>The Research Staff failed to secure the authentication disk but did manage to kill most of the [syndicate_name()] Operatives!</B>")

	else if(!disk_rescued && crew_evacuated)
		SSticker.mode_result = "nuclear halfwin - detonation averted"
		to_chat(world, "<FONT size = 3><B>Syndicate Minor Victory!</B></FONT>")
		to_chat(world, "<B>[syndicate_name()] operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</B> Next time, don't lose the disk!")

	else if(!disk_rescued && !crew_evacuated)
		SSticker.mode_result = "nuclear halfwin - interrupted"
		to_chat(world, "<FONT size = 3><B>Neutral Victory</B></FONT>")
		to_chat(world, "<B>Round was mysteriously interrupted!</B>")
	..()
	return


/datum/game_mode/proc/auto_declare_completion_nuclear()
	if(length(operatives) || GAMEMODE_IS_NUCLEAR)
		var/list/text = list("<br><FONT size=3><B>The syndicate operatives were:</B></FONT>")

		var/purchases = ""
		var/TC_uses = 0

		for(var/datum/mind/syndicate in operatives)

			text += "<br><b>[syndicate.get_display_key()]</b> was <b>[syndicate.name]</b> ("
			if(syndicate.current)
				if(syndicate.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(syndicate.current.real_name != syndicate.name)
					text += " as <b>[syndicate.current.real_name]</b>"
			else
				text += "body destroyed"
			text += ")"
			for(var/obj/item/uplink/H in GLOB.world_uplinks)
				if(H && H.uplink_owner && H.uplink_owner==syndicate.key)
					TC_uses += H.used_TC
					purchases += H.purchase_log

		text += "<br>"

		text += "(Syndicates used [TC_uses] TC) [purchases]"

		if(TC_uses==0 && station_was_nuked && !is_operatives_are_dead())
			text += "<BIG><IMG CLASS=icon SRC=\ref['icons/badass.dmi'] ICONSTATE='badass'></BIG>"

		return text.Join("")

/proc/nukelastname(mob/M as mob) //--All praise goes to NEO|Phyte, all blame goes to DH, and it was Cindi-Kate's idea. Also praise Urist for copypasta ho.
	var/randomname = pick(GLOB.last_names)
	var/newname = sanitize(copytext_char(input(M,"You are the nuke operative [pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")]. Please choose a last name for your family.", "Name change", randomname), 1, MAX_NAME_LEN))

	if(!newname)
		newname = randomname

	else
		if(newname == "Unknown" || newname == "floor" || newname == "wall" || newname == "rwall" || newname == "_")
			to_chat(M, "That name is reserved.")
			return nukelastname(M)

	return newname


/datum/game_mode/nuclear/set_scoreboard_vars()
	var/datum/scoreboard/scoreboard = SSticker.score
	var/foecount = 0

	for(var/datum/mind/M in SSticker.mode.operatives)
		foecount++
		if(!M || !M.current)
			scoreboard.score_ops_killed++
			continue

		if(M.current.stat == DEAD)
			scoreboard.score_ops_killed++

		else if(M.current.restrained())
			scoreboard.score_arrested++

	if(foecount == scoreboard.score_arrested)
		scoreboard.all_arrested = TRUE // how the hell did they manage that

	var/obj/machinery/nuclearbomb/syndicate/nuke = locate() in GLOB.poi_list
	if(nuke?.r_code != "Nope")
		var/area/A = get_area(nuke)

		var/list/thousand_penalty = list(/area/station/engineering/solar)
		var/list/fiftythousand_penalty = list(
			/area/station/security/main,
			/area/station/security/brig,
			/area/station/security/armory,
			/area/station/security/checkpoint/secondary
			)

		if(is_type_in_list(A, thousand_penalty))
			scoreboard.nuked_penalty = 1000

		else if(is_type_in_list(A, fiftythousand_penalty))
			scoreboard.nuked_penalty = 50000

		else if(istype(A, /area/station/engineering/engine))
			scoreboard.nuked_penalty = 100000

		else
			scoreboard.nuked_penalty = 10000

	var/killpoints = scoreboard.score_ops_killed * 250
	var/arrestpoints = scoreboard.score_arrested * 1000
	scoreboard.crewscore += killpoints
	scoreboard.crewscore += arrestpoints
	if(scoreboard.nuked)
		scoreboard.crewscore -= scoreboard.nuked_penalty



/datum/game_mode/nuclear/get_scoreboard_stats()
	var/datum/scoreboard/scoreboard = SSticker.score
	var/foecount = 0
	var/crewcount = 0

	var/diskdat = ""
	var/bombdat = null

	for(var/datum/mind/M in SSticker.mode.operatives)
		foecount++

	for(var/mob in GLOB.mob_living_list)
		var/mob/living/C = mob
		if(ishuman(C) || is_ai(C) || isrobot(C))
			if(C.stat == DEAD)
				continue
			if(!C.client)
				continue
			crewcount++

	var/obj/item/disk/nuclear/N = locate() in GLOB.poi_list
	if(istype(N))
		var/atom/disk_loc = N.loc
		while(!isturf(disk_loc))
			if(ismob(disk_loc))
				var/mob/M = disk_loc
				diskdat += "Carried by [M.real_name] "
			if(isobj(disk_loc))
				var/obj/O = disk_loc
				diskdat += "in \a [O]"
			disk_loc = disk_loc.loc
		diskdat += "in [disk_loc.loc]"


	if(!diskdat)
		diskdat = "WARNING: Nuked_penalty could not be found, look at [__FILE__], [__LINE__]."

	var/dat = ""
	dat += "<b><u>Mode Statistics</b></u><br>"

	dat += "<b>Number of Operatives:</b> [foecount]<br>"
	dat += "<b>Number of Surviving Crew:</b> [crewcount]<br>"

	dat += "<b>Final Location of Nuke:</b> [bombdat]<br>"
	dat += "<b>Final Location of Disk:</b> [diskdat]<br>"

	dat += "<br>"

	dat += "<b>Operatives Arrested:</b> [scoreboard.score_arrested] ([scoreboard.score_arrested * 1000] Points)<br>"
	dat += "<b>All Operatives Arrested:</b> [scoreboard.all_arrested ? "Yes" : "No"] (Score tripled)<br>"

	dat += "<b>Operatives Killed:</b> [scoreboard.score_ops_killed] ([scoreboard.score_ops_killed * 1000] Points)<br>"
	dat += "<b>Station Destroyed:</b> [scoreboard.nuked ? "Yes" : "No"] (-[scoreboard.nuked_penalty] Points)<br>"
	dat += "<hr>"

	return dat
