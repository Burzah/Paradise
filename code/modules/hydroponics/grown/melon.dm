// Watermelon
/obj/item/seeds/watermelon
	name = "pack of watermelon seeds"
	desc = "These seeds grow into watermelon plants."
	icon_state = "seed-watermelon"
	species = "watermelon"
	plantname = "Watermelon Vines"
	product = /obj/item/food/grown/watermelon
	lifespan = 50
	endurance = 40
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_dead = "watermelon-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/watermelon/holy)
	reagents_add = list("water" = 0.2, "vitamin" = 0.04, "plantmatter" = 0.2)

/obj/item/seeds/watermelon/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is swallowing [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.gib()
	new product(drop_location())
	qdel(src)
	return OBLITERATION

/obj/item/food/grown/watermelon
	seed = /obj/item/seeds/watermelon
	name = "watermelon"
	desc = "It's full of watery goodness."
	icon_state = "watermelon" // Sprite created by https://github.com/binarysudoku for Goonstation, They have relicensed it for our use.
	slice_path = /obj/item/food/sliced/watermelon
	slices_num = 5
	dried_type = null
	w_class = WEIGHT_CLASS_NORMAL
	filling_color = "#008000"
	tastes = list("watermelon" = 1)
	bitesize_mod = 3
	wine_power = 0.4

// Holymelon
/obj/item/seeds/watermelon/holy
	name = "pack of holymelon seeds"
	desc = "These seeds grow into holymelon plants."
	icon_state = "seed-holymelon"
	species = "holymelon"
	plantname = "Holy Melon Vines"
	product = /obj/item/food/grown/holymelon
	mutatelist = list()
	reagents_add = list("holywater" = 0.2, "vitamin" = 0.04, "nutriment" = 0.1)
	rarity = 20

/obj/item/food/grown/holymelon
	seed = /obj/item/seeds/watermelon/holy
	name = "holymelon"
	desc = "The water within this melon has been blessed by some deity that's particularly fond of watermelon."
	icon_state = "holymelon" // Sprite created by https://github.com/binarysudoku for Goonstation, They have relicensed it for our use.
	filling_color = "#FFD700"
	dried_type = null
	wine_power = 0.7 //Water to wine, baby.
	tastes = list("melon" = 1, "divinity" = 1)
	wine_flavor = "divinity"
