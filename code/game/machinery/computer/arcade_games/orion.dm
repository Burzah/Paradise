#define ORION_TRAIL_RAIDERS			"Raiders"
#define ORION_TRAIL_FLUX			"Interstellar Flux"
#define ORION_TRAIL_ILLNESS			"Illness"
#define ORION_TRAIL_BREAKDOWN		"Breakdown"
#define ORION_TRAIL_LING			"Changelings?"
#define ORION_TRAIL_LING_ATTACK 	"Changeling Ambush"
#define ORION_TRAIL_MALFUNCTION		"Malfunction"
#define ORION_TRAIL_COLLISION		"Collision"
#define ORION_TRAIL_SPACEPORT		"Spaceport"
#define ORION_TRAIL_BLACKHOLE		"BlackHole"

#define ORION_TRAIL_WINTURN			9

/obj/machinery/computer/arcade/orion_trail
	name = "The Orion Trail"
	desc = "Learn how our ancestors got to Orion, and have fun in the process!"
	icon_state = "arcade"
	icon_screen = "orion"
	circuit = /obj/item/circuitboard/arcade/orion_trail
	var/busy = FALSE //prevent clickspam that allowed people to ~speedrun~ the game.
	var/engine = 0
	var/hull = 0
	var/electronics = 0
	var/food = 80
	var/fuel = 60
	var/turns = 4
	var/playing = FALSE
	var/game_over = 0
	var/alive = 4
	var/eventdat = null
	var/event = null
	var/list/stops = list()
	var/list/stopblurbs = list()
	var/list/settlers = list(
		"John Syndicate",
		"Larry Nanotrasen",
		"Bob The Wizard",
	)
	var/list/events = list(
		ORION_TRAIL_RAIDERS		= 3,
		ORION_TRAIL_FLUX		= 1,
		ORION_TRAIL_ILLNESS		= 3,
		ORION_TRAIL_BREAKDOWN	= 2,
		ORION_TRAIL_LING		= 3,
		ORION_TRAIL_MALFUNCTION	= 2,
		ORION_TRAIL_COLLISION	= 1,
		ORION_TRAIL_SPACEPORT	= 2,
	)
	var/lings_aboard = 0
	var/spaceport_raided = 0
	var/spaceport_freebie = 0
	var/last_spaceport_action = ""

/obj/machinery/computer/arcade/orion_trail/Reset()
	// Sets up the main trail
	stops = list(
		"Pluto",
		"Asteroid Belt",
		"Proxima Centauri",
		"Dead Space",
		"Rigel Prime",
		"Tau Ceti Beta",
		"Black Hole",
		"Space Outpost Beta-9",
		"Orion Prime",
	)
	stopblurbs = list(
		"Pluto, long since occupied with long-range sensors and scanners, stands ready to, and indeed continues to probe the far reaches of the galaxy.",
		"At the edge of the Sol system lies a treacherous asteroid belt. Many have been crushed by stray asteroids and misguided judgement.",
		"The nearest star system to Sol, in ages past it stood as a reminder of the boundaries of sub-light travel, now a low-population sanctuary for adventurers and traders.",
		"This region of space is particularly devoid of matter. Such low-density pockets are known to exist, but the vastness of it is astounding.",
		"Rigel Prime, the center of the Rigel system, burns hot, basking its planetary bodies in warmth and radiation.",
		"Tau Ceti Beta has recently become a waypoint for colonists headed towards Orion. There are many ships and makeshift stations in the vicinity.",
		"Sensors indicate that a black hole's gravitational field is affecting the region of space we were headed through. We could stay of course, but risk of being overcome by its gravity, or we could change course to go around, which will take longer.",
		"You have come into range of the first man-made structure in this region of space. It has been constructed not by travellers from Sol, but by colonists from Orion. It stands as a monument to the colonists' success.",
		"You have made it to Orion! Congratulations! Your crew is one of the few to start a new foothold for mankind!"
	)

/obj/machinery/computer/arcade/recruiter/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/arcade/orion_trail/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OrionTrail", name)
		ui.open()

/obj/machinery/computer/arcade/orion_trail/ui_data(mob/user)
	var/list/data = list(
		"engine" = engine,
		"hull" = hull,
		"electronics" = electronics,
		"food" = food,
		"fuel" = fuel,
		"playing" = playing,
		"turns" = turns,
		"gameOver" = game_over,
	)
	return data

/obj/machinery/computer/arcade/orion_trail/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if (..())
		return




/obj/machinery/computer/arcade/orion_trail/proc/new_game()
	// Set names of settlers in crew
	settlers = list()
	// for(var/i in 1 to 3)
	// 	add_crewmember()
	// add_crewmember("[usr]")
	// Re-set items to defaults
	engine = 1
	hull = 1
	electronics = 1
	food = 80
	fuel = 60
	alive = 4
	turns = 1
	event = null
	playing = TRUE
	game_over = 0
	lings_aboard = 0

	//spaceport junk
	spaceport_raided = 0
	spaceport_freebie = 0
	last_spaceport_action = ""

/obj/machinery/computer/arcade/orion_trail/attack_hand(mob/user)
	ui_interact(user)

// /obj/machinery/computer/arcade/orion_trail/proc/event()
// 	eventdat = "<center><h1>[event]</h1></center>"

// 	switch(event)
// 		if(ORION_TRAIL_RAIDERS)
// 			eventdat += "Raiders have come aboard your ship!"
// 			if(prob(50))
// 				var/sfood = rand(1,10)
// 				var/sfuel = rand(1,10)
// 				food -= sfood
// 				fuel -= sfuel
// 				eventdat += "<br>They have stolen [sfood] <b>Food</b> and [sfuel] <b>Fuel</b>."
// 			else if(prob(10))
// 				var/deadname = remove_crewmember()
// 				eventdat += "<br>[deadname] tried to fight back but was killed."
// 			else
// 				eventdat += "<br>Fortunately you fended them off without any trouble."
// 			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];eventclose=1'>Continue</a></P>"
// 			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"

// 		if(ORION_TRAIL_FLUX)
// 			eventdat += "This region of space is highly turbulent. <br>If we go slowly we may avoid more damage, but if we keep our speed we won't waste supplies."
// 			eventdat += "<br>What will you do?"
// 			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];slow=1'>Slow Down</a> <a href='byond://?src=[UID()];keepspeed=1'>Continue</a></P>"
// 			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"

// 		if(ORION_TRAIL_ILLNESS)
// 			eventdat += "A deadly illness has been contracted!"
// 			var/deadname = remove_crewmember()
// 			eventdat += "<br>[deadname] was killed by the disease."
// 			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];eventclose=1'>Continue</a></P>"
// 			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"

// 		if(ORION_TRAIL_BREAKDOWN)
// 			eventdat += "Oh no! The engine has broken down!"
// 			eventdat += "<br>You can repair it with an engine part, or you can make repairs for 3 days."
// 			if(engine >= 1)
// 				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];useengine=1'>Use Part</a><a href='byond://?src=[UID()];wait=1'>Wait</a></P>"
// 			else
// 				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];wait=1'>Wait</a></P>"
// 			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"

// 		if(ORION_TRAIL_MALFUNCTION)
// 			eventdat += "The ship's systems are malfunctioning!"
// 			eventdat += "<br>You can replace the broken electronics with spares, or you can spend 3 days troubleshooting the AI."
// 			if(electronics >= 1)
// 				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];useelec=1'>Use Part</a><a href='byond://?src=[UID()];wait=1'>Wait</a></P>"
// 			else
// 				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];wait=1'>Wait</a></P>"
// 			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"

// 		if(ORION_TRAIL_COLLISION)
// 			eventdat += "Something hit us! Looks like there's some hull damage."
// 			if(prob(25))
// 				var/sfood = rand(5,15)
// 				var/sfuel = rand(5,15)
// 				food -= sfood
// 				fuel -= sfuel
// 				eventdat += "<br>[sfood] <b>Food</b> and [sfuel] <b>Fuel</b> was vented out into space."
// 			if(prob(10))
// 				var/deadname = remove_crewmember()
// 				eventdat += "<br>[deadname] was killed by rapid depressurization."
// 			eventdat += "<br>You can repair the damage with hull plates, or you can spend the next 3 days welding scrap together."
// 			if(hull >= 1)
// 				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];usehull=1'>Use Part</a><a href='byond://?src=[UID()];wait=1'>Wait</a></P>"
// 			else
// 				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];wait=1'>Wait</a></P>"
// 			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"

// 		if(ORION_TRAIL_BLACKHOLE)
// 			eventdat += "You were swept away into the black hole."
// 			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];holedeath=1'>Oh...</a></P>"
// 			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"
// 			settlers = list()

// 		if(ORION_TRAIL_LING)
// 			eventdat += "Strange reports warn of changelings infiltrating crews on trips to Orion..."
// 			if(length(settlers) <= 2)
// 				eventdat += "<br>Your crew's chance of reaching Orion is so slim the changelings likely avoided your ship..."
// 				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];eventclose=1'>Continue</a></P>"
// 				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"
// 				if(prob(10)) // "likely", I didn't say it was guaranteed!
// 					lings_aboard = min(++lings_aboard,2)
// 			else
// 				if(lings_aboard) //less likely to stack lings
// 					if(prob(20))
// 						lings_aboard = min(++lings_aboard,2)
// 				else if(prob(70))
// 					lings_aboard = min(++lings_aboard,2)

// 				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];killcrew=1'>Kill a crewmember</a></P>"
// 				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];eventclose=1'>Risk it</a></P>"
// 				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"

// 		if(ORION_TRAIL_LING_ATTACK)
// 			if(lings_aboard <= 0) //shouldn't trigger, but hey.
// 				eventdat += "Haha, fooled you, there are no changelings on board!"
// 				eventdat += "<br>(You should report this to a coder :S)"
// 			else
// 				var/ling1 = remove_crewmember()
// 				var/ling2 = ""
// 				if(lings_aboard >= 2)
// 					ling2 = remove_crewmember()

// 				eventdat += "Oh no, some of your crew are Changelings!"
// 				if(ling2)
// 					eventdat += "<br>[ling1] and [ling2]'s arms twist and contort into grotesque blades!"
// 				else
// 					eventdat += "<br>[ling1]'s arm twists and contorts into a grotesque blade!"

// 				var/chance2attack = alive*20
// 				if(prob(chance2attack))
// 					var/chancetokill = 30*lings_aboard-(5*alive) //eg: 30*2-(10) = 50%, 2 lings, 2 crew is 50% chance
// 					if(prob(chancetokill))
// 						var/deadguy = remove_crewmember()
// 						eventdat += "<br>The Changeling[ling2 ? "s":""] run[ling2 ? "":"s"] up to [deadguy] and capitulates them!"
// 					else
// 						eventdat += "<br>You valiantly fight off the Changeling[ling2 ? "s":""]!"
// 						eventdat += "<br>You cut the Changeling[ling2 ? "s":""] up into meat... Eww"
// 						if(ling2)
// 							food += 30
// 							lings_aboard = max(0,lings_aboard-2)
// 						else
// 							food += 15
// 							lings_aboard = max(0,--lings_aboard)
// 				else
// 					eventdat += "<br>The Changeling[ling2 ? "s":""] run[ling2 ? "":"s"] away, What wimps!"
// 					if(ling2)
// 						lings_aboard = max(0,lings_aboard-2)
// 					else
// 						lings_aboard = max(0,--lings_aboard)

// 			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];eventclose=1'>Continue</a></P>"
// 			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"


// 		if(ORION_TRAIL_SPACEPORT)
// 			if(spaceport_raided)
// 				eventdat += "The Spaceport is on high alert! They wont let you dock since you tried to attack them!"
// 				if(last_spaceport_action)
// 					eventdat += "<br>Last Spaceport Action: [last_spaceport_action]"
// 				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];leave_spaceport=1'>Depart Spaceport</a></P>"
// 				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"
// 			else
// 				eventdat += "You pull the ship up to dock at a nearby Spaceport, lucky find!"
// 				eventdat += "<br>This Spaceport is home to travellers who failed to reach Orion, but managed to find a different home..."
// 				eventdat += "<br>Trading terms: FU = Fuel, FO = Food"
// 				if(last_spaceport_action)
// 					eventdat += "<br>Last Spaceport Action: [last_spaceport_action]"
// 				eventdat += "<h3><b>Crew:</b></h3>"
// 				eventdat += english_list(settlers)
// 				eventdat += "<br><b>Food: </b>[food] | <b>Fuel: </b>[fuel]"
// 				eventdat += "<br><b>Engine Parts: </b>[engine] | <b>Hull Panels: </b>[hull] | <b>Electronics: </b>[electronics]"


// 				//If your crew is pathetic you can get freebies (provided you haven't already gotten one from this port)
// 				if(!spaceport_freebie && (fuel < 20 || food < 20))
// 					spaceport_freebie++
// 					var/FU = 10
// 					var/FO = 10
// 					var/freecrew = 0
// 					if(prob(30))
// 						FU = 25
// 						FO = 25

// 					if(prob(10))
// 						add_crewmember()
// 						freecrew++

// 					eventdat += "<br>The traders of the spaceport take pitty on you, and give you some food and fuel (+[FU]FU,+[FO]FO)"
// 					if(freecrew)
// 						eventdat += "<br>You also gain a new crewmember!"

// 					fuel += FU
// 					food += FO

// 				//CREW INTERACTIONS
// 				eventdat += "<P ALIGN=Right>Crew Management:</P>"

// 				//Buy crew
// 				if(food > 10 && fuel > 10)
// 					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];buycrew=1'>Hire a new Crewmember (-10FU,-10FO)</a></P>"
// 				else
// 					eventdat += "<P ALIGN=Right>Cant afford a new Crewmember</P>"

// 				//Sell crew
// 				if(length(settlers) > 1)
// 					eventdat += "<p ALIGN=Right><a href='byond://?src=[UID()];sellcrew=1'>Sell crew for Fuel and Food (+7FU,+7FO)</a></p>"
// 				else
// 					eventdat += "<P ALIGN=Right>Cant afford to sell a Crewmember</P>"

// 				//BUY/SELL STUFF
// 				eventdat += "<P ALIGN=Right>Spare Parts:</P>"

// 				//Engine parts
// 				if(fuel > 5)
// 					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];buyparts=1'>Buy Engine Parts (-5FU)</a></P>"
// 				else
// 					eventdat += "<P ALIGN=Right>Cant afford to buy Engine Parts</a>"

// 				//Hull plates
// 				if(fuel > 5)
// 					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];buyparts=2'>Buy Hull Plates (-5FU)</a></P>"
// 				else
// 					eventdat += "<P ALIGN=Right>Cant afford to buy Hull Plates</a>"

// 				//Electronics
// 				if(fuel > 5)
// 					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];buyparts=3'>Buy Spare Electronics (-5FU)</a></P>"
// 				else
// 					eventdat += "<P ALIGN=Right>Cant afford to buy Spare Electronics</a>"

// 				//Trade
// 				if(fuel > 5)
// 					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];trade=1'>Trade Fuel for Food (-5FU,+5FO)</a></P>"
// 				else
// 					eventdat += "<P ALIGN=Right>Cant afford to Trade Fuel for Food</P"

// 				if(food > 5)
// 					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];trade=2'>Trade Food for Fuel (+5FU,-5FO)</a></P>"
// 				else
// 					eventdat += "<P ALIGN=Right>Cant afford to Trade Food for Fuel</P"

// 				//Raid the spaceport
// 				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];raid_spaceport=1'>!! Raid Spaceport !!</a></P>"

// 				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];leave_spaceport=1'>Depart Spaceport</a></P>"


// //Add Random/Specific crewmember
// /obj/machinery/computer/arcade/orion_trail/proc/add_crewmember(specific = "")
// 	var/newcrew = ""
// 	if(specific)
// 		newcrew = specific
// 	else
// 		if(prob(50))
// 			newcrew = pick(GLOB.first_names_male)
// 		else
// 			newcrew = pick(GLOB.first_names_female)
// 	if(newcrew)
// 		settlers += newcrew
// 		alive++
// 	return newcrew

// //Remove Random/Specific crewmember
// /obj/machinery/computer/arcade/orion_trail/proc/remove_crewmember(specific = "", dont_remove = "")
// 	var/list/safe2remove = settlers
// 	var/removed = ""
// 	if(dont_remove)
// 		safe2remove -= dont_remove
// 	if(specific && specific != dont_remove)
// 		safe2remove = list(specific)
// 	else
// 		if(length(safe2remove) >= 1) //need to make sure we even have anyone to remove
// 			removed = pick(safe2remove)

// 	if(removed)
// 		if(lings_aboard && prob(40*lings_aboard)) //if there are 2 lings you're twice as likely to get one, obviously
// 			lings_aboard = max(0,--lings_aboard)
// 		settlers -= removed
// 		alive--
// 	return removed


// /obj/machinery/computer/arcade/orion_trail/proc/win()
// 	playing = FALSE
// 	turns = 1
// 	atom_say("Congratulations, you made it to Orion!")
// 	if(emagged)
// 		new /obj/item/orion_ship(get_turf(src))
// 		message_admins("[key_name_admin(usr)] made it to Orion on an emagged machine and got an explosive toy ship.")
// 		log_game("[key_name(usr)] made it to Orion on an emagged machine and got an explosive toy ship.")
// 	else
// 		var/score = 10 * (alive - lings_aboard) + 5 * (engine + hull + electronics)
// 		prizevend(score)
// 	emagged = FALSE
// 	name = "The Orion Trail"
// 	desc = "Learn how our ancestors got to Orion, and have fun in the process!"

// /obj/machinery/computer/arcade/orion_trail/emag_act(mob/user)
// 	if(!emagged)
// 		to_chat(user, "<span class='notice'>You override the cheat code menu and skip to Cheat #[rand(1, 50)]: Realism Mode.</span>")
// 		name = "The Orion Trail: Realism Edition"
// 		desc = "Learn how our ancestors got to Orion, and try not to die in the process!"
// 		add_hiddenprint(user)
// 		new_game()
// 		emagged = TRUE
// 		return TRUE

// /mob/living/simple_animal/hostile/syndicate/ranged/orion
// 	name = "spaceport security"
// 	desc = "Premier corporate security forces for all spaceports found along the Orion Trail."
// 	faction = list("orion")
// 	loot = list()
// 	del_on_death = TRUE

// /obj/item/orion_ship
// 	name = "model settler ship"
// 	desc = "A model spaceship, it looks like those used back in the day when travelling to Orion! It even has a miniature FX-293 reactor, which was renowned for its instability and tendency to explode..."
// 	icon = 'icons/obj/toy.dmi'
// 	icon_state = "ship"
// 	w_class = WEIGHT_CLASS_SMALL
// 	var/active = FALSE //if the ship is on

// /obj/item/orion_ship/examine(mob/user)
// 	. = ..()
// 	if(in_range(user, src))
// 		if(!active)
// 			. += "<span class='notice'>There's a little switch on the bottom. It's flipped down.</span>"
// 		else
// 			. += "<span class='notice'>There's a little switch on the bottom. It's flipped up.</span>"

// /obj/item/orion_ship/attack_self(mob/user) //Minibomb-level explosion. Should probably be more because of how hard it is to survive the machine! Also, just over a 5-second fuse
// 	if(active)
// 		return

// 	message_admins("[key_name_admin(usr)] primed an explosive Orion ship for detonation.")
// 	log_game("[key_name(usr)] primed an explosive Orion ship for detonation.")

// 	to_chat(user, "<span class='warning'>You flip the switch on the underside of [src].</span>")
// 	active = TRUE
// 	visible_message("<span class='notice'>[src] softly beeps and whirs to life!</span>")
// 	playsound(loc, 'sound/machines/defib_saftyon.ogg', 25, TRUE)
// 	atom_say("This is ship ID #[rand(1,1000)] to Orion Port Authority. We're coming in for landing, over.")
// 	sleep(20)
// 	visible_message("<span class='warning'>[src] begins to vibrate...</span>")
// 	atom_say("Uh, Port? Having some issues with our reactor, could you check it out? Over.")
// 	sleep(30)
// 	atom_say("Oh, God! Code Eight! CODE EIGHT! IT'S GONNA BL-")
// 	playsound(loc, 'sound/machines/buzz-sigh.ogg', 25, TRUE)
// 	sleep(3.6)
// 	visible_message("<span class='userdanger'>[src] explodes!</span>")
// 	explosion(src.loc, 1,2,4, flame_range = 3)
// 	qdel(src)


// #undef ORION_TRAIL_WINTURN
// #undef ORION_TRAIL_RAIDERS
// #undef ORION_TRAIL_FLUX
// #undef ORION_TRAIL_ILLNESS
// #undef ORION_TRAIL_BREAKDOWN
// #undef ORION_TRAIL_LING
// #undef ORION_TRAIL_LING_ATTACK
// #undef ORION_TRAIL_MALFUNCTION
// #undef ORION_TRAIL_COLLISION
// #undef ORION_TRAIL_SPACEPORT
// #undef ORION_TRAIL_BLACKHOLE
