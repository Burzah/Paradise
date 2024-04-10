GLOBAL_LIST_EMPTY(sounds_cache)

/client/proc/stop_global_admin_sounds()
	set category = "Event"
	set name = "Stop Global Admin Sounds"
	if(!check_rights(R_SOUNDS))
		return

	var/sound/awful_sound = sound(null, repeat = 0, wait = 0, channel = CHANNEL_ADMIN)

	log_admin("[key_name(src)] stopped admin sounds.")
	message_admins("[key_name_admin(src)] stopped admin sounds.", 1)
	for(var/mob/M in GLOB.player_list)
		M << awful_sound

/client/proc/play_sound(S as sound)
	set category = "Event"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUNDS))	return

	var/sound/uploaded_sound = sound(S, repeat = 0, wait = 1, channel = CHANNEL_ADMIN)
	uploaded_sound.priority = 250

	GLOB.sounds_cache += S

	if(tgui_alert(usr, "Are you sure you want to play [S]?\nYou can now play this sound using \"Play Server Sound\".", "Confirmation Request", list("Okay", "Cancel")) != "Okay")
		return

	if(holder.fakekey)
		if(tgui_alert(usr, "Playing this sound will expose your real ckey despite being in stealth mode. Continue?", "Double check", list("Okay", "Cancel")) != "Okay")
			return

	log_admin("[key_name(src)] played sound [S]")
	message_admins("[key_name_admin(src)] played sound [S]", 1)

	for(var/mob/M in GLOB.player_list)
		if(M.client.prefs.sound & SOUND_MIDI)
			if(ckey in M.client.prefs.admin_sound_ckey_ignore)
				continue // This player has this admin muted
			if(isnewplayer(M) && (M.client.prefs.sound & SOUND_LOBBY))
				M.stop_sound_channel(CHANNEL_LOBBYMUSIC)
			uploaded_sound.volume = 100 * M.client.prefs.get_channel_volume(CHANNEL_ADMIN)

			var/this_uid = M.client.UID()
			to_chat(M, "<span class='boldannounceic'>[ckey] played <code>[S]</code> (<a href='?src=[this_uid];action=silenceSound'>SILENCE</a>) (<a href='?src=[this_uid];action=muteAdmin&a=[ckey]'>ALWAYS SILENCE THIS ADMIN</a>)</span>")
			SEND_SOUND(M, uploaded_sound)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Global Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/play_local_sound(S as sound)
	set category = "Event"
	set name = "Play Local Sound"
	if(!check_rights(R_SOUNDS))	return

	log_admin("[key_name(src)] played a local sound [S]")
	message_admins("[key_name_admin(src)] played a local sound [S]", 1)
	playsound(get_turf(src.mob), S, 50, FALSE, 0)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Local Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/play_server_sound()
	set category = "Event"
	set name = "Play Server Sound"
	if(!check_rights(R_SOUNDS))	return

	var/list/sounds = file2list("sound/serversound_list.txt")
	sounds += GLOB.sounds_cache

	// Selects the sound that will be played
	var/melody = tgui_input_list(usr, "Select a sound from the server to play.", "Server Sound List", sounds)
	if(!melody)
		return

	play_sound(melody)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Server Sound") //If you are copy-pasting this, ensure the 2nd paramter is unique to the new proc!

/client/proc/play_intercom_sound()
	set category = "Event"
	set name = "Play Sound via Intercoms"
	set desc = "Plays a sound at every intercom on the station z level. Works best with small sounds."

	if(!check_rights(R_SOUNDS))
		return

	// Prompts the user with a warning about playing sounds over intercom
	var/warning = tgui_alert(usr, "WARNING! Sound will play at every intercom! Would you like to continue?", "Warning", list("Okay", "Cancel"))
	if(warning != "Okay")
		return

	var/list/sounds = file2list("sound/serversound_list.txt")
	sounds += GLOB.sounds_cache

	// Selects the sound that will be played
	var/melody = tgui_input_list(usr, "Select a sound from the server to play.", "Server Sound List", sounds)
	if(!melody)
		return

	// Allows for override to utilize intercoms on all z-levels
	var/zlevel_override = tgui_alert(usr, "Do you want to play through intercoms on ALL Z-levels, or just the station?", "Z-level Override", list("Yes", "No"))
	var/ignore_z = FALSE
	if(zlevel_override == "Yes")
		ignore_z = TRUE

	// Allows for override to utilize incomplete and unpowered intercoms
	var/power_override = tgui_alert(usr, "Do you want to play through unpowered and incomplete intercoms?", "Power Override", list("Yes", "No"))
	var/ignore_power = FALSE
	if(power_override == "Yes")
		ignore_power = TRUE

	// Loops through the intercoms based on our choices
	for(var/O in GLOB.global_intercoms)
		var/obj/item/radio/intercom/I = O
		if(!is_station_level(I.z) && !ignore_z)
			continue
		if(!I.on && !ignore_power)
			continue
		play_sound(melody)
		return
