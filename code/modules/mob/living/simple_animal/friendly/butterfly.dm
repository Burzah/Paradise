/mob/living/simple_animal/butterfly
	name = "butterfly"
	desc = "A colorful butterfly, how'd it get up here?"
	icon_state = "butterfly"
	icon_living = "butterfly"
	icon_dead = "butterfly_dead"
	emote_see = list("flutters")
	faction = list("neutral", "jungle")
	response_help = "shoos"
	response_disarm = "brushes aside"
	response_harm = "squashes"
	maxHealth = 2
	health = 2
	harm_intent_damage = 1
	friendly = "nudges"
	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC | MOB_BUG
	butcher_results = list(/obj/item/food/meat = 0)
	gold_core_spawnable = FRIENDLY_SPAWN
	initial_traits = list(TRAIT_FLYING, TRAIT_EDIBLE_BUG)

/mob/living/simple_animal/butterfly/Initialize(mapload)
	. = ..()
	color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))

/mob/living/simple_animal/butterfly/npc_safe(mob/user)
	return TRUE
