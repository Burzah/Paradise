// Pumpkin
/obj/item/seeds/pumpkin
	name = "pack of pumpkin seeds"
	desc = "These seeds grow into pumpkin vines."
	icon_state = "seed-pumpkin"
	species = "pumpkin"
	plantname = "Pumpkin Vines"
	product = /obj/item/food/grown/pumpkin
	lifespan = 50
	endurance = 40
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "pumpkin-grow"
	icon_dead = "pumpkin-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/pumpkin/blumpkin)
	reagents_add = list("vitamin" = 0.04, "plantmatter" = 0.2)


/obj/item/food/grown/pumpkin
	seed = /obj/item/seeds/pumpkin
	name = "pumpkin"
	desc = "It's large and scary."
	icon_state = "pumpkin"
	filling_color = "#FFA500"
	bitesize_mod = 2
	tastes = list("pumpkin" = 1)
	wine_power = 0.2
	var/carved_type = /obj/item/clothing/head/hardhat/pumpkinhead

/obj/item/food/grown/pumpkin/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob, params)
	if(W.sharp)
		user.show_message("<span class='notice'>You carve a face into [src]!</span>", 1)
		new carved_type(user.loc)
		qdel(src)
		return
	else
		return ..()

// Blumpkin
/obj/item/seeds/pumpkin/blumpkin
	name = "pack of blumpkin seeds"
	desc = "These seeds grow into blumpkin vines."
	icon_state = "seed-blumpkin"
	species = "blumpkin"
	plantname = "Blumpkin Vines"
	product = /obj/item/food/grown/pumpkin/blumpkin
	mutatelist = list()
	reagents_add = list("ammonia" = 0.2, "chlorine" = 0.1, "plasma" = 0.1, "plantmatter" = 0.2)
	rarity = 20


/obj/item/food/grown/pumpkin/blumpkin
	seed = /obj/item/seeds/pumpkin/blumpkin
	name = "blumpkin"
	desc = "The pumpkin's toxic sibling."
	icon_state = "blumpkin"
	filling_color = "#87CEFA"
	tastes = list("blumpkin" = 1)
	wine_power = 0.5
	carved_type = /obj/item/clothing/head/hardhat/pumpkinhead/blumpkin
