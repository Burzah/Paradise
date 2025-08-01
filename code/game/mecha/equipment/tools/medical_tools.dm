// Sleeper, and Syringe gun

/obj/item/mecha_parts/mecha_equipment/medical

/obj/item/mecha_parts/mecha_equipment/medical/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/mecha_parts/mecha_equipment/medical/can_attach(obj/mecha/medical/M)
	if(..() && istype(M))
		return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/attach(obj/mecha/M)
	..()
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/medical/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/process()
	if(!chassis)
		STOP_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/medical/detach()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper
	name = "mounted sleeper"
	desc = "Equipment for medical exosuits. A mounted sleeper that stabilizes patients and can inject reagents in the exosuit's reserves."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper"
	origin_tech = "engineering=3;biotech=3;plasmatech=2"
	energy_drain = 20
	equip_cooldown = 20
	var/mob/living/carbon/patient = null
	var/inject_amount = 10
	salvageable = 0

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/AllowDrop()
	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Exit(atom/movable/O)
	return 0

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/action(mob/living/carbon/target)
	if(!action_checks(target))
		return
	if(!istype(target))
		return
	if(!patient_insertion_check(target))
		return
	occupant_message("<span class='notice'>You start putting [target] into [src]...</span>")
	chassis.visible_message("<span class='warning'>[chassis] starts putting [target] into \the [src].</span>")
	if(do_after_cooldown(target))
		if(!patient_insertion_check(target))
			return
		target.forceMove(src)
		patient = target
		START_PROCESSING(SSobj, src)
		update_equip_info()
		occupant_message("<span class='notice'>[target] successfully loaded into [src]. Life support functions engaged.</span>")
		chassis.visible_message("<span class='warning'>[chassis] loads [target] into [src].</span>")
		log_message("[target] loaded. Life support functions engaged.")

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/patient_insertion_check(mob/living/carbon/target)
	if(target.buckled)
		occupant_message("<span class='warning'>[target] will not fit into the sleeper because [target.p_they()] [target.p_are()] buckled to [target.buckled]!</span>")
		return FALSE
	if(target.has_buckled_mobs())
		occupant_message("<span class='warning'>[target] will not fit into the sleeper because of the creatures attached to it!</span>")
		return FALSE
	if(patient)
		occupant_message("<span class='warning'>The sleeper is already occupied!</span>")
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/go_out()
	if(!patient)
		return
	patient.forceMove(get_turf(src))
	occupant_message("[patient] ejected. Life support functions disabled.")
	log_message("[patient] ejected. Life support functions disabled.")
	STOP_PROCESSING(SSobj, src)
	patient = null
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/detach()
	if(patient)
		occupant_message("<span class='warning'>Unable to detach [src] - equipment occupied!</span>")
		return
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/get_equip_info()
	var/output = ..()
	if(output)
		var/temp = ""
		if(patient)
			temp = "<br />\[Occupant: [patient] ([patient.stat == DEAD ? "*DECEASED*" : "Health: [patient.health]%"])\]<br /><a href='byond://?src=[UID()];view_stats=1'>View stats</a>|<a href='byond://?src=[UID()];eject=1'>Eject</a>"
		return "[output] [temp]"

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Topic(href,href_list)
	if(..())
		return
	var/datum/topic_input/afilter = new /datum/topic_input(href,href_list)
	if(afilter.get("eject"))
		go_out()
	if(afilter.get("view_stats"))
		chassis.occupant << browse(get_patient_stats(),"window=msleeper")
		onclose(chassis.occupant, "msleeper")
		return
	if(afilter.get("inject"))
		inject_reagent(afilter.getType("inject",/datum/reagent),afilter.getObj("source"))
	return

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_patient_stats()
	if(!patient)
		return
	return {"<html><meta charset='utf-8'>
				<head>
				<title>[patient] statistics</title>
				<script language='javascript' type='text/javascript'>
				[JS_BYJAX]
				</script>
				<style>
				h3 {margin-bottom:2px;font-size:14px;}
				#lossinfo, #reagents, #injectwith {padding-left:15px;}
				</style>
				</head>
				<body>
				<h3>Health statistics</h3>
				<div id="lossinfo">
				[get_patient_dam()]
				</div>
				<h3>Reagents in bloodstream</h3>
				<div id="reagents">
				[get_patient_reagents()]
				</div>
				<div id="injectwith">
				[get_available_reagents()]
				</div>
				</body>
				</html>"}

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_patient_dam()
	var/t1
	switch(patient.stat)
		if(0)
			t1 = "Conscious"
		if(1)
			t1 = "Unconscious"
		if(2)
			t1 = "*dead*"
		else
			t1 = "Unknown"
	return {"<font color="[patient.health > 50 ? "blue" : "red"]"><b>Health:</b> [patient.stat == DEAD ? "[t1]" : "[patient.health]% ([t1])"]</font><br />
				<font color="[patient.bodytemperature > 50 ? "blue" : "red"]"><b>Core Temperature:</b> [patient.bodytemperature-T0C]&deg;C ([patient.bodytemperature*1.8-459.67]&deg;F)</font><br />
				<font color="[patient.getBruteLoss() < 60 ? "blue" : "red"]"><b>Brute Damage:</b> [patient.getBruteLoss()]%</font><br />
				<font color="[patient.getOxyLoss() < 60 ? "blue" : "red"]"><b>Respiratory Damage:</b> [patient.getOxyLoss()]%</font><br />
				<font color="[patient.getToxLoss() < 60 ? "blue" : "red"]"><b>Toxin Content:</b> [patient.getToxLoss()]%</font><br />
				<font color="[patient.getFireLoss() < 60 ? "blue" : "red"]"><b>Burn Severity:</b> [patient.getFireLoss()]%</font><br />
				<font color="red">[patient.getCloneLoss() ? "Subject appears to have cellular damage." : ""]</font><br />
				<font color="red">[patient.getBrainLoss() ? "Significant brain damage detected." : ""]</font><br />
				"}

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_patient_reagents()
	if(patient.reagents)
		for(var/datum/reagent/R in patient.reagents.reagent_list)
			if(R.volume > 0)
				. += "[R]: [round(R.volume,0.01)]<br />"
	return . || "None"

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_available_reagents()
	var/output
	var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/SG = locate(/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun) in chassis
	if(SG && SG.reagents && islist(SG.reagents.reagent_list))
		for(var/datum/reagent/R in SG.reagents.reagent_list)
			if(R.volume > 0)
				output += "<a href='byond://?src=[UID()];inject=\ref[R];source=\ref[SG]'>Inject [R.name]</a><br />"
	return output


/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/inject_reagent(datum/reagent/R,obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/SG)
	if(!R || !patient || !SG || !(SG in chassis.equipment))
		return
	var/to_inject = min(R.volume, inject_amount)
	if(to_inject && patient.reagents.get_reagent_amount(R.id) + to_inject <= inject_amount*2)
		occupant_message("Injecting [patient] with [to_inject] units of [R.name].")
		log_message("Injecting [patient] with [to_inject] units of [R.name].")
		add_attack_logs(chassis.occupant, patient, "Injected with [name] containing [R], transferred [to_inject] units", R.harmless ? ATKLOG_ALMOSTALL : null)
		SG.reagents.trans_id_to(patient,R.id,to_inject)
		update_equip_info()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/update_equip_info()
	if(..())
		if(patient)
			send_byjax(chassis.occupant,"msleeper.browser","lossinfo",get_patient_dam())
			send_byjax(chassis.occupant,"msleeper.browser","reagents",get_patient_reagents())
			send_byjax(chassis.occupant,"msleeper.browser","injectwith",get_available_reagents())

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/container_resist()
	go_out()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/process()
	if(..())
		return
	if(!chassis)
		STOP_PROCESSING(SSobj, src)
		return
	if(!chassis.has_charge(energy_drain))
		set_ready_state(1)
		log_message("Deactivated.")
		occupant_message("[src] deactivated - no power.")
		STOP_PROCESSING(SSobj, src)
		return
	var/mob/living/carbon/M = patient
	if(!M)
		return
	if(M.health > 0)
		M.adjustOxyLoss(-1)
	M.AdjustStunned(-8 SECONDS)
	M.AdjustWeakened(-8 SECONDS)
	if(M.reagents.get_reagent_amount("epinephrine") < 5)
		M.reagents.add_reagent("epinephrine", 5)
	chassis.use_power(energy_drain)
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/force_eject_occupant(mob/target)
	go_out()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun
	name = "exosuit syringe gun"
	desc = "Equipment for medical exosuits. A chem synthesizer with syringe gun. Reagents inside are held in stasis, so no reactions will occur."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "syringegun"
	var/list/syringes
	var/list/known_reagents
	var/list/processed_reagents
	var/max_syringes = 10
	var/max_volume = 75 //max reagent volume
	var/synth_speed = 5 //[num] reagent units per cycle
	energy_drain = 10
	var/mode = 0 //0 - fire syringe, 1 - analyze reagents.
	range = MECHA_MELEE | MECHA_RANGED
	equip_cooldown = 10
	origin_tech = "materials=3;biotech=4;magnets=4"

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Initialize(mapload)
	. = ..()
	create_reagents(max_volume)
	reagents.set_reacting(FALSE)
	syringes = new
	known_reagents = list("epinephrine"="Epinephrine","charcoal"="Charcoal")
	processed_reagents = new

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/detach()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/can_attach(obj/mecha/medical/M)
	if(..())
		if(istype(M))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[<a href='byond://?src=[UID()];toggle_mode=1'>[mode? "Analyze" : "Launch"]</a>\]<br />\[Syringes: [length(syringes)]/[max_syringes] | Reagents: [reagents.total_volume]/[reagents.maximum_volume]\]<br /><a href='byond://?src=[UID()];show_reagents=1'>Reagents list</a>"

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/action(atom/movable/target)
	if(!action_checks(target))
		return
	if(istype(target,/obj/item/reagent_containers/syringe))
		return load_syringe(target)
	if(isstorage(target))//Loads syringes from boxes
		for(var/obj/item/reagent_containers/syringe/S in target.contents)
			load_syringe(S)
		return
	if(mode)
		return analyze_reagents(target)
	if(!length(syringes))
		occupant_message("<span class='alert'>No syringes loaded.</span>")
		return
	if(reagents.total_volume<=0)
		occupant_message("<span class='alert'>No available reagents to load syringe with.</span>")
		return
	var/turf/trg = get_turf(target)
	var/obj/item/reagent_containers/syringe/mechsyringe = syringes[1]
	mechsyringe.forceMove(get_turf(chassis))
	mechsyringe.mode = SYRINGE_INJECT
	reagents.trans_to(mechsyringe, min(mechsyringe.volume, reagents.total_volume))
	syringes -= mechsyringe
	mechsyringe.icon = 'icons/obj/chemical.dmi'
	mechsyringe.icon_state = "syringeproj"
	playsound(chassis, 'sound/items/syringeproj.ogg', 50, 1)
	log_message("Launched [mechsyringe] from [src], targeting [target].")
	var/mob/originaloccupant = chassis.occupant
	var/original_target_zone = originaloccupant.zone_selected
	spawn(0)
		src = null //if src is deleted, still process the syringe
		var/max_range = 6
		for(var/i=0, i<max_range, i++)
			if(!mechsyringe)
				break
			if(!step_towards(mechsyringe,trg))
				break

			var/list/mobs = list()
			for(var/mob/living/carbon/M in mechsyringe.loc)
				mobs += M
			var/mob/living/carbon/M = safepick(mobs)
			if(M)
				var/R
				mechsyringe.visible_message("<span class='attack'> [M] was hit by the syringe!</span>")
				if(M.can_inject(originaloccupant, TRUE, original_target_zone))
					if(mechsyringe.reagents)
						for(var/datum/reagent/A in mechsyringe.reagents.reagent_list)
							R += A.id + " ("
							R += num2text(A.volume) + "),"
					add_attack_logs(originaloccupant, M, "Shot with [src] containing [R], transferred [mechsyringe.reagents.total_volume] units")
					mechsyringe.reagents.reaction(M, REAGENT_INGEST)
					mechsyringe.reagents.trans_to(M, mechsyringe.reagents.total_volume)
					if(!mechsyringe.reagents.total_volume)
						mechsyringe.mode = SYRINGE_DRAW
					M.take_organ_damage(2)
				break
			else if(mechsyringe.loc == trg)
				break
			sleep(1)
		if(mechsyringe)
			// Revert the syringe icon to normal one once it stops flying.
			mechsyringe.icon_state = initial(mechsyringe.icon_state)
			mechsyringe.icon = initial(mechsyringe.icon)
			mechsyringe.update_icon()


/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Topic(href,href_list)
	if(..())
		return
	var/datum/topic_input/afilter = new (href,href_list)
	if(afilter.get("toggle_mode"))
		mode = !mode
		update_equip_info()
		return
	if(afilter.get("select_reagents"))
		processed_reagents.len = 0
		var/m = 0
		var/message
		for(var/i=1 to length(known_reagents))
			if(m>=synth_speed)
				break
			var/reagent = afilter.get("reagent_[i]")
			if(reagent && (reagent in known_reagents))
				message = "[m ? ", " : null][known_reagents[reagent]]"
				processed_reagents += reagent
				m++
		if(length(processed_reagents))
			message += " added to production"
			START_PROCESSING(SSobj, src)
			occupant_message(message)
			occupant_message("Reagent processing started.")
			log_message("Reagent processing started.")
		return
	if(afilter.get("show_reagents"))
		chassis.occupant << browse(get_reagents_page(),"window=msyringegun")
	if(afilter.get("purge_reagent"))
		var/reagent = afilter.get("purge_reagent")
		if(reagent)
			reagents.del_reagent(reagent)
		return
	if(afilter.get("purge_all"))
		reagents.clear_reagents()
		return

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_reagents_page()
	var/output = {"<html><meta charset='utf-8'>
						<head>
						<title>Reagent Synthesizer</title>
						<script language='javascript' type='text/javascript'>
						[JS_BYJAX]
						</script>
						<style>
						h3 {margin-bottom:2px;font-size:14px;}
						#reagents, #reagents_form {}
						form {width: 90%; margin:10px auto; border:1px dotted #999; padding:6px;}
						#submit {margin-top:5px;}
						</style>
						</head>
						<body>
						<h3>Current reagents:</h3>
						<div id="reagents">
						[get_current_reagents()]
						</div>
						<h3>Reagents production:</h3>
						<div id="reagents_form">
						[get_reagents_form()]
						</div>
						</body>
						</html>
						"}
	return output

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_reagents_form()
	var/r_list = get_reagents_list()
	var/inputs
	if(r_list)
		inputs += "<input type=\"hidden\" name=\"src\" value=\"[UID()]\">"
		inputs += "<input type=\"hidden\" name=\"select_reagents\" value=\"1\">"
		inputs += "<input id=\"submit\" type=\"submit\" value=\"Apply settings\">"
	var/output = {"<form action="byond://" method="get">
						[r_list || "No known reagents"]
						[inputs]
						</form>
						[r_list? "<span style=\"font-size:80%;\">Only the first [synth_speed] selected reagent\s will be added to production</span>" : null]
						"}
	return output

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_reagents_list()
	var/output
	for(var/i=1 to length(known_reagents))
		var/reagent_id = known_reagents[i]
		output += {"<input type="checkbox" value="[reagent_id]" name="reagent_[i]" [(reagent_id in processed_reagents)? "checked=\"1\"" : null]> [known_reagents[reagent_id]]<br />"}
	return output

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_current_reagents()
	var/output
	for(var/datum/reagent/R in reagents.reagent_list)
		if(R.volume > 0)
			output += "[R]: [round(R.volume,0.001)] - <a href='byond://?src=[UID()];purge_reagent=[R.id]'>Purge Reagent</a><br />"
	if(output)
		output += "Total: [round(reagents.total_volume,0.001)]/[reagents.maximum_volume] - <a href='byond://?src=[UID()];purge_all=1'>Purge All</a>"
	return output || "None"

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/load_syringe(obj/item/reagent_containers/syringe/S)
	if(length(syringes)<max_syringes)
		if(get_dist(src,S) >= 2)
			occupant_message("The syringe is too far away.")
			return FALSE
		for(var/obj/structure/D in S.loc)//Basic level check for structures in the way (Like grilles and windows)
			if(!(D.CanPass(S,src.loc)))
				occupant_message("Unable to load syringe.")
				return FALSE
		for(var/obj/machinery/door/D in S.loc)//Checks for doors
			if(!(D.CanPass(S,src.loc)))
				occupant_message("Unable to load syringe.")
				return FALSE
		S.reagents.trans_to(src, S.reagents.total_volume)
		S.forceMove(src)
		syringes += S
		occupant_message("Syringe loaded.")
		update_equip_info()
		return TRUE
	occupant_message("[src] syringe chamber is full.")
	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/analyze_reagents(atom/A)
	if(get_dist(src,A) >= 4)
		occupant_message("The object is too far away.")
		return FALSE
	if(!A.reagents || ismob(A))
		occupant_message("<span class='alert'>No reagent info gained from [A].</span>")
		return FALSE
	occupant_message("Analyzing reagents...")
	for(var/datum/reagent/R as anything in A.reagents.reagent_list)
		if(initial(R.id) in GLOB.blocked_chems)
			occupant_message("Reagent unable to be analyzed, purging from analyzer.")
			return FALSE
		if(add_known_reagent(R.id, R.name))
			occupant_message("Reagent analyzed, identified as [R.name] and added to database.")
			send_byjax(chassis.occupant,"msyringegun.browser","reagents_form",get_reagents_form())
	occupant_message("Analysis complete.")
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/add_known_reagent(r_id,r_name)
	if(!(r_id in known_reagents))
		known_reagents += r_id
		known_reagents[r_id] = r_name
		return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/update_equip_info()
	if(..())
		send_byjax(chassis.occupant,"msyringegun.browser","reagents",get_current_reagents())
		send_byjax(chassis.occupant,"msyringegun.browser","reagents_form",get_reagents_form())

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/on_reagent_change()
	..()
	update_equip_info()


/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/process()
	if(..())
		return
	if(!length(processed_reagents) || reagents.total_volume >= reagents.maximum_volume || !chassis.has_charge(energy_drain))
		occupant_message("<span class='alert'>Reagent processing stopped.</a>")
		log_message("Reagent processing stopped.")
		STOP_PROCESSING(SSobj, src)
		return
	var/amount = synth_speed / length(processed_reagents)
	for(var/reagent in processed_reagents)
		reagents.add_reagent(reagent,amount)
		chassis.use_power(energy_drain)

/obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw
	name = "rescue jaw"
	desc = "Emergency rescue jaws, designed to help first responders reach their patients. Opens doors and removes obstacles."
	icon_state = "mecha_clamp"	//can work, might use a blue resprite later but I think it works for now
	equip_cooldown = 15
	energy_drain = 10
	var/dam_force = 20


/obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw/action(atom/target)
	if(!action_checks(target))
		return
	if(isobj(target))
		if(!isairlock(target))//early return if we're not trying to open a door
			return
		var/obj/machinery/door/D = target	//the door we want to open
		D.try_to_crowbar(chassis.occupant, src)//use the door's crowbar function
	if(isliving(target))	//interact with living beings
		var/mob/living/M = target
		if(chassis.occupant.a_intent == INTENT_HARM)//the patented, medical rescue claw is incapable of doing harm. Worry not.
			target.visible_message("<span class='notice'>[chassis] gently boops [target] on the nose, its hydraulics hissing as safety overrides slow a brutal punch down at the last second.</span>", \
								"<span class='notice'[chassis] gently boops [target] on the nose, its hydraulics hissing as safety overrides slow a brutal punch down at the last second.</span>")
		else
			push_aside(chassis, M)//out of the way, I have people to save!
			occupant_message("<span class='notice'>You gently push [target] out of the way.</span>")
			chassis.visible_message("<span class='notice'>[chassis] gently pushes [target] out of the way.</span>")

/obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw/proc/push_aside(obj/mecha/M, mob/living/L)
	switch(get_dir(M, L))
		if(NORTH, SOUTH)
			if(prob(50))
				step(L, WEST)
			else
				step(L, EAST)
		if(WEST, EAST)
			if(prob(50))
				step(L, NORTH)
			else
				step(L, SOUTH)

/obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw/can_attach(obj/mecha/M)
	if(istype(M, /obj/mecha/medical) || istype(M, /obj/mecha/working/ripley/firefighter))	//Odys or firefighters
		if(length(M.equipment) < M.max_equip)
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam
	name = "exosuit medical beamgun"
	desc = "Equipment for medical exosuits. A mounted medical nanite projector which will treat patients with a focused beam. Unlike its handheld counterpart, it is incapable of healing internal injuries."
	icon_state = "mecha_medigun"
	energy_drain = 20
	range = MECHA_MELEE | MECHA_RANGED
	origin_tech = "combat=5;materials=6;powerstorage=6;biotech=6"
	var/obj/item/gun/medbeam/mech/medigun
	materials = list(MAT_METAL = 15000, MAT_GLASS = 8000, MAT_PLASMA = 3000, MAT_GOLD = 8000, MAT_DIAMOND = 2000)

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/Initialize(mapload)
	. = ..()
	medigun = new(src)

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/Destroy()
	QDEL_NULL(medigun)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/process()
	if(..())
		return
	medigun.process()

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/action(atom/target)
	medigun.process_fire(target, loc)

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/detach()
	if(medigun)
		medigun.LoseTarget()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/can_attach(obj/mecha/medical/M)
	if(..())
		for(var/obj/item/beamgun in M)
			if(istype(beamgun, /obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam))
				return FALSE	//One beamgun per mech
		if(istype(M))
			return TRUE
	return FALSE
