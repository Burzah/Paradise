/*	Photography!
 *	Contains:
 *		Camera
 *		Camera Film
 *		Photos
 *		Photo Albums
 */

/*******
* film *
*******/
/obj/item/camera_film
	name = "film cartridge"
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	item_state = "electropack"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE


/********
* photo *
********/
/obj/item/photo
	name = "photo"
	icon_state = "photo"
	item_state = "paper"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 50
	var/blueprints = 0 // Does this have the blueprints?
	var/icon/img	//Big photo image
	var/scribble	//Scribble on the back.
	var/icon/tiny
	var/photo_size = 3
	scatter_distance = 8

/obj/item/photo/attack_self__legacy__attackchain(mob/user as mob)
	user.examinate(src)

/obj/item/photo/attackby__legacy__attackchain(obj/item/P as obj, mob/user as mob, params)
	if(is_pen(P) || istype(P, /obj/item/toy/crayon))
		var/txt = tgui_input_text(user, "What would you like to write on the back?", "Photo Writing")
		if(!txt)
			return
		txt = copytext(txt, 1, 128)
		if(loc == user && user.stat == CONSCIOUS)
			scribble = txt
	else if(P.get_heat())
		burnphoto(P, user)
	..()

/obj/item/photo/proc/burnphoto(obj/item/P, mob/user)
	if(user.restrained())
		return

	var/class = "warning"
	if(istype(P, /obj/item/lighter/zippo))
		class = "rose"

	user.visible_message("<span class='[class]'>[user] holds [P] up to [src], it looks like [user.p_theyre()] trying to burn it!</span>", \
	"<span class='[class]'>You hold [P] up to [src], burning it slowly.</span>")

	if(!do_after(user, 5 SECONDS, target = src))
		return

	if(user.get_active_hand() != P || !P.get_heat())
		to_chat(user, "<span class='warning'>You must hold [P] steady to burn [src].</span>")
		return

	user.visible_message("<span class='[class]'>[user] burns right through [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>", \
	"<span class='[class]'>You burn right through [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>")

	if(user.is_in_inactive_hand(src))
		user.unequip(src)

	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/item/photo/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		show(user)
	else
		. += "<span class='notice'>It is too far away.</span>"
	. += "<span class='notice'><b>Alt-Click</b> [src] with a pen in hand to rename it.</span>"

/obj/item/photo/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(is_pen(user.get_active_hand()))
		rename(user)
	else
		return ..()

/obj/item/photo/proc/show(mob/user as mob)
	var/icon/img_shown = new/icon(img)
	var/colormatrix = user.get_screen_colour()
	// Apply colorblindness effects, if any.
	if(islist(colormatrix))
		img_shown.MapColors(
			colormatrix[1], colormatrix[2], colormatrix[3],
			colormatrix[4], colormatrix[5], colormatrix[6],
			colormatrix[7], colormatrix[8], colormatrix[9],
		)
	usr << browse_rsc(img_shown, "tmp_photo.png")
	usr << browse("<html><meta charset='utf-8'><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo.png' width='[64*photo_size]' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>", "window=Photo[UID()];size=[64*photo_size]x[scribble ? 400 : 64*photo_size]")
	onclose(usr, "Photo[UID()]")

/obj/item/photo/proc/rename(mob/user)
	var/n_name = tgui_input_text(user, "What would you like to label the photo?", "Photo Labelling", name)
	if(!n_name)
		return
	//loc.loc check is for making possible renaming photos in clipboards
	if(((loc == user || (loc.loc && loc.loc == user)) && !user.stat))
		name = "[(n_name ? "[n_name]" : "photo")]"
	add_fingerprint(user)

/**************
* photo album *
**************/
/obj/item/storage/photo_album
	name = "Photo album"
	desc = "A slim book with little plastic coverings to keep photos from deteriorating, it reminds you of the good ol' days."
	icon = 'icons/obj/items.dmi'
	icon_state = "album"
	item_state = "syringe_kit"
	can_hold = list(/obj/item/photo)
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_SMALL
	storage_slots = 14
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound =  'sound/items/handling/book_pickup.ogg'

/obj/item/storage/photo_album/MouseDrop(obj/over_object as obj)

	if(ishuman(usr))
		var/mob/M = usr
		if(!is_screen_atom(over_object))
			return ..()
		playsound(loc, "rustle", 50, TRUE, -5)
		if((!M.restrained() && !M.stat && M.back == src))
			switch(over_object.name)
				if("r_hand")
					M.unequip(src)
					M.put_in_r_hand(src)
				if("l_hand")
					M.unequip(src)
					M.put_in_l_hand(src)
			add_fingerprint(usr)
			return
		if(over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			if(usr.s_active)
				usr.s_active.close(usr)
			show_to(usr)
			return
	return

/*********
* camera *
*********/
/obj/item/camera
	name = "camera"
	desc = "A polaroid camera."
	icon_state = "camera"
	item_state = "camera"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_NECK
	var/list/matter = list("metal" = 2000)
	var/pictures_max = 10
	// cameras historically were varedited to start with 30 shots despite
	// cartridges only being 10 extra shots, hency why pictures_left >
	// pictures_max, at least to start
	var/pictures_left = 30
	var/on = TRUE
	var/on_cooldown = FALSE
	var/blueprints = 0
	var/icon_on = "camera"
	var/icon_off = "camera_off"
	var/size = 3
	var/see_ghosts = FALSE //for the spoop of it
	/// Cult portals and unconcealed runes have a minor form of invisibility
	var/see_cult = TRUE
	var/current_photo_num = 1
	var/digital = FALSE
	/// Should camera light up the scene
	var/flashing_light = TRUE
	actions_types = list(/datum/action/item_action/toogle_camera_flash)

/obj/item/camera/autopsy
	name = "autopsy camera"

/obj/item/camera/detective
	name = "detective's camera"

/obj/item/camera/examine(mob/user)
	. = ..()
	if(!digital)
		. += "<span class='notice'>There is [pictures_left] photos left.</span>"
	. += "<span class='notice'><b>Alt-Click</b> [src] to change the photo size.</span>"

/obj/item/camera/spooky/CheckParts(list/parts_list)
	..()
	var/obj/item/camera/C = locate(/obj/item/camera) in contents
	if(C)
		pictures_max = C.pictures_max
		pictures_left = C.pictures_left
		visible_message("[C] has been imbued with godlike power!")
		qdel(C)


GLOBAL_LIST_INIT(SpookyGhosts, list("ghost","shade","shade2","ghost-narsie","horror","shadow","ghostian2"))

/obj/item/camera/spooky
	name = "camera obscura"
	desc = "A polaroid camera, some say it can see ghosts!"
	see_ghosts = TRUE

/obj/item/camera/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	change_size(user)

/obj/item/camera/ui_action_click(mob/user, actiontype)
	toggle_flash(user)

/obj/item/camera/proc/toggle_flash(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	flashing_light = !flashing_light

	to_chat(user, "<span class='notice'>You turn [src]'s flash [flashing_light ? "on" : "off"].</span>")

/obj/item/camera/proc/change_size(mob/user)
	var/nsize = tgui_input_list(user, "Photo Size", "Pick a size of resulting photo.", list(1,3,5,7))
	if(nsize)
		size = nsize
		to_chat(user, "<span class='notice'>Camera will now take [size]x[size] photos.</span>")

/obj/item/camera/attack__legacy__attackchain(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/camera/attack_self__legacy__attackchain(mob/user)
	if(on_cooldown)
		to_chat(user, "<span class='notice'>[src] is still on cooldown!</span>")
		return
	on = !on
	if(on)
		icon_state = icon_on
	else
		icon_state = icon_off
	to_chat(user, "You switch the camera [on ? "on" : "off"].")

/obj/item/camera/attackby__legacy__attackchain(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/camera_film))
		if(pictures_left)
			to_chat(user, "<span class='notice'>[src] still has some film in it!</span>")
			return
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		user.drop_item()
		qdel(I)
		pictures_left = pictures_max
		return
	..()


/obj/item/camera/proc/get_icon(list/turfs, turf/center, mob/user)

	//Bigger icon base to capture those icons that were shifted to the next tile
	//i.e. pretty much all wall-mounted machinery
	var/icon/res = icon('icons/effects/96x96.dmi', "")
	res.Scale(size*32, size*32)
	// Initialize the photograph to black.
	res.Blend("#000", ICON_OVERLAY)

	var/atoms[] = list()
	for(var/turf/the_turf in turfs)
		// Add ourselves to the list of stuff to draw
		atoms.Add(the_turf)
		// As well as anything that isn't invisible.
		for(var/atom/A in the_turf)
			if(istype(A, /atom/movable/lighting_object)) //Add lighting to make image look nice
				atoms.Add(A)
				continue

			// AI can't see unconcealed runes or cult portals
			if(A.invisibility == INVISIBILITY_RUNES && see_cult)
				atoms.Add(A)
				continue
			if(A.invisibility)
				if(see_ghosts && isobserver(A))
					var/mob/dead/observer/O = A
					if(O.orbiting_uid)
						continue
					if(user.mind && !(user.mind.assigned_role == "Chaplain"))
						atoms.Add(image('icons/mob/mob.dmi', O.loc, pick(GLOB.SpookyGhosts), 4, SOUTH))
					else
						atoms.Add(image('icons/mob/mob.dmi', O.loc, "ghost", 4, SOUTH))
				else//its not a ghost
					continue
			else//not invisable, not a spookyghost add it.
				var/disguised = null
				if(user.viewing_alternate_appearances && length(user.viewing_alternate_appearances) && ishuman(A) && A.alternate_appearances && length(A.alternate_appearances)) //This whole thing and the stuff below just checks if the atom is a Solid Snake cosplayer.
					for(var/datum/alternate_appearance/alt_appearance in user.viewing_alternate_appearances)
						if(alt_appearance.owner == A) //If it turns out they are, don't blow their cover. That'd be rude.
							atoms.Add(image(alt_appearance.img, A.loc, layer = 4, dir = A.dir)) //Render their disguise.
							atoms.Remove(A) //Don't blow their cover.
							disguised = 1
							continue
				if(!disguised) //If they aren't, treat them normally.
					atoms.Add(A)


	// Sort the atoms into their layers
	var/list/sorted = sort_atoms(atoms)
	var/center_offset = (size-1)/2 * 32 + 1
	for(var/i; i <= length(sorted); i++)
		var/atom/A = sorted[i]
		if(istype(A, /atom/movable/lighting_object))
			continue //Lighting objects render last, need to be above all atoms and turfs displayed

		if(A)
			var/icon/img = getFlatIcon(A)//build_composite_icon(A)
			if(istype(A, /obj/item/areaeditor/blueprints/ce))
				blueprints = 1

			// If what we got back is actually a picture, draw it.
			if(istype(img, /icon))
				// Check if we're looking at a mob that's lying down
				if(isliving(A))
					var/mob/living/L = A
					if(IS_HORIZONTAL(L))
						// If they are, apply that effect to their picture.
						img.BecomeLying()
				// Calculate where we are relative to the center of the photo
				var/xoff = (A.x - center.x) * 32 + center_offset
				var/yoff = (A.y - center.y) * 32 + center_offset
				if(istype(A,/atom/movable))
					xoff+=A:step_x
					yoff+=A:step_y
				else
					// In case of an issue where icon size of a turf is different from 32x32 (grass, alien weeds, etc.)
					xoff += (32 - img.Width()) / 2
					yoff += (32 - img.Height()) / 2

				res.Blend(img, blendMode2iconMode(A.blend_mode),  A.pixel_x + xoff, A.pixel_y + yoff)

	// Lastly, render any contained effects on top.
	for(var/turf/the_turf in turfs)
		// Calculate where we are relative to the center of the photo
		var/xoff = (the_turf.x - center.x) * 32 + center_offset
		var/yoff = (the_turf.y - center.y) * 32 + center_offset
		res.Blend(getFlatIcon(the_turf.loc), blendMode2iconMode(the_turf.blend_mode),xoff,yoff)

	// Render lighting objects to make picture look nice.
	for(var/atom/movable/lighting_object/light in sorted)
		var/xoff = (light.x - center.x) * 32 + center_offset
		var/yoff = (light.y - center.y) * 32 + center_offset
		res.Blend(getFlatIcon(light), blendMode2iconMode(BLEND_MULTIPLY),  light.pixel_x + xoff, light.pixel_y + yoff)

	return res


/obj/item/camera/proc/get_mobs(turf/the_turf as turf)
	var/mob_detail
	for(var/mob/M in the_turf)
		if(M.invisibility)
			if(see_ghosts && isobserver(M))
				var/mob/dead/observer/O = M
				if(O.orbiting_uid)
					continue
				if(!mob_detail)
					mob_detail = "You can see a g-g-g-g-ghooooost! "
				else
					mob_detail += "You can also see a g-g-g-g-ghooooost!"
			else
				continue

		var/holding = null

		if(iscarbon(M))
			var/mob/living/carbon/A = M
			if(A.l_hand || A.r_hand)
				if(A.l_hand) holding = "They are holding \a [A.l_hand]"
				if(A.r_hand)
					if(holding)
						holding += " and \a [A.r_hand]"
					else
						holding = "They are holding \a [A.r_hand]"

			if(!mob_detail)
				mob_detail = "You can see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]. "
			else
				mob_detail += "You can also see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]."
	return mob_detail

/obj/item/camera/afterattack__legacy__attackchain(atom/target, mob/user, flag)
	if(!on || !pictures_left || ismob(target.loc))
		return

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, TRUE, -3)
	if(flashing_light)
		set_light(3, 2, LIGHT_COLOR_TUNGSTEN)
		sleep(0.2 SECONDS) //Allow lights to update before capturing image
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light), 0), 0.1 SECONDS)

	captureimage(target, user, flag)
	pictures_left--
	to_chat(user, "<span class='notice'>[pictures_left] photos left.</span>")
	icon_state = icon_off
	on = FALSE
	on_cooldown = TRUE

	handle_haunt(user)
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), 6.4 SECONDS) // fucking magic numbers

/obj/item/camera/proc/reset_cooldown()
	icon_state = icon_on
	on = TRUE
	on_cooldown = FALSE

/obj/item/camera/proc/can_capture_turf(turf/T, mob/user)
	var/viewer = user
	if(user.client)		//To make shooting through security cameras possible
		viewer = user.client.eye
	var/can_see = (T in view(viewer)) //No x-ray vision cameras.
	return can_see

/obj/item/camera/proc/captureimage(atom/target, mob/user, flag)
	var/x_c = target.x - (size-1)/2
	var/y_c = target.y + (size-1)/2
	var/z_c	= target.z
	var/list/turfs = list()
	var/mobs = ""
	for(var/i = 1; i <= size; i++)
		for(var/j = 1; j <= size; j++)
			var/turf/T = locate(x_c, y_c, z_c)
			if(can_capture_turf(T, user))
				turfs.Add(T)
				mobs += get_mobs(T)
			x_c++
		y_c--
		x_c = x_c - size

	var/datum/picture/P = createpicture(target, user, turfs, mobs, flag, blueprints)
	printpicture(user, P)

/obj/item/camera/proc/createpicture(atom/target, mob/user, list/turfs, mobs, flag)
	var/icon/photoimage = get_icon(turfs, target, user)

	var/icon/small_img = icon(photoimage)
	var/icon/tiny_img = icon(photoimage)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	var/icon/pc = icon('icons/obj/bureaucracy.dmi', "photo")
	small_img.Scale(8, 8)
	tiny_img.Scale(4, 4)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	pc.Blend(tiny_img,ICON_OVERLAY, 12, 19)

	var/datum/picture/P = new()
	if(digital)
		P.fields["name"] = tgui_input_text(user, "Name photo:", "Photo", encode = FALSE)
		if(!P.fields["name"])
			P.fields["name"] = "Photo [current_photo_num]"
			current_photo_num++
		P.name = P.fields["name"] //So the name is displayed on the print/delete list.
	else
		P.fields["name"] = "photo"
	P.fields["author"] = user
	P.fields["icon"] = ic
	P.fields["tiny"] = pc
	P.fields["img"] = photoimage
	P.fields["desc"] = mobs
	P.fields["pixel_x"] = rand(-10, 10)
	P.fields["pixel_y"] = rand(-10, 10)
	P.fields["size"] = size

	return P

/obj/item/camera/proc/printpicture(mob/user, datum/picture/P)
	var/obj/item/photo/Photo = new/obj/item/photo()
	Photo.loc = user.loc
	if(!user.get_inactive_hand())
		user.put_in_inactive_hand(Photo)

	if(blueprints)
		Photo.blueprints = 1
		blueprints = 0
	Photo.construct(P)

/obj/item/photo/proc/construct(datum/picture/P)
	name = P.fields["name"]
	icon = P.fields["icon"]
	tiny = P.fields["tiny"]
	img = P.fields["img"]
	desc = P.fields["desc"]
	pixel_x = P.fields["pixel_x"]
	pixel_y = P.fields["pixel_y"]
	photo_size = P.fields["size"]

/obj/item/photo/proc/copy()
	var/obj/item/photo/p = new/obj/item/photo()

	p.icon = icon(icon, icon_state)
	p.img = icon(img)
	p.tiny = icon(tiny)
	p.name = name
	p.desc = desc
	p.scribble = scribble
	p.blueprints = blueprints

	return p

/*****************
* digital camera *
******************/
/obj/item/camera/digital
	name = "digital camera"
	desc = "A digital camera."
	digital = TRUE
	var/list/datum/picture/saved_pictures = list()
	var/max_storage = 10

/obj/item/camera/digital/examine(mob/user)
	. = ..()
	. += "<span class='notice'>A small screen shows that there are currently [length(saved_pictures)] pictures stored.</span>"
	. += "<span class='notice'><b>Alt-Shift-Click</b> [src] to print a specific photo.</span>"
	. += "<span class='notice'><b>Ctrl-Shift-Click</b> [src] to delete a specific photo.</span>"

/obj/item/camera/digital/afterattack__legacy__attackchain(atom/target, mob/user, flag)
	if(!on || !pictures_left || ismob(target.loc))
		return

	captureimage(target, user, flag)
	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, TRUE, -3)

	icon_state = icon_off
	on = FALSE
	on_cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), 6.4 SECONDS) // magic numbers here too

/obj/item/camera/digital/captureimage(atom/target, mob/user, flag)
	if(length(saved_pictures) >= max_storage)
		to_chat(user, "<span class='notice'>Maximum photo storage capacity reached.</span>")
		return
	to_chat(user, "Picture saved.")
	var/x_c = target.x - (size-1)/2
	var/y_c = target.y + (size-1)/2
	var/z_c	= target.z
	var/list/turfs = list()
	var/mobs = ""
	for(var/i = 1; i <= size; i++)
		for(var/j = 1; j <= size; j++)
			var/turf/T = locate(x_c, y_c, z_c)
			if(can_capture_turf(T, user))
				turfs.Add(T)
				mobs += get_mobs(T)
			x_c++
		y_c--
		x_c = x_c - size

	var/datum/picture/P = createpicture(target, user, turfs, mobs, flag)
	saved_pictures += P

/obj/item/camera/digital/AltShiftClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(!length(saved_pictures))
		to_chat(user, "<span class='userdanger'>No images saved.</span>")
		return
	if(!pictures_left)
		to_chat(user, "<span class='userdanger'>There is no film left to print.</span>")
		return

	var/datum/picture/picture
	picture = tgui_input_list(user, "Select image to print", "Print image", saved_pictures)
	if(picture)
		printpicture(user, picture)
		pictures_left --

/obj/item/camera/digital/CtrlShiftClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(!length(saved_pictures))
		to_chat(user, "<span class='userdanger'>No images saved</span>")
		return
	var/datum/picture/picture
	picture = tgui_input_list(user, "Select image to delete", "Delete image", saved_pictures)
	if(picture)
		saved_pictures -= picture

/**************
*video camera *
***************/
/// The amount of time after being turned off that the camera is too hot to turn back on.
#define CAMERA_STATE_COOLDOWN 2 SECONDS

/obj/item/videocam
	name = "video camera"
	desc = "This video camera can send live feeds to the entertainment network. You must hold to use it."
	icon_state = "videocam"
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	var/on = FALSE
	var/obj/machinery/camera/camera
	var/icon_on = "videocam_on"
	var/icon_off = "videocam"
	var/canhear_range = 7

	COOLDOWN_DECLARE(video_cooldown)

/obj/item/videocam/proc/camera_state(mob/living/carbon/user)
	if(!on)
		on = TRUE
		camera = new /obj/machinery/camera(src)
		icon_state = icon_on
		camera.network = list("news")
		camera.c_tag = user.name
	else
		on = FALSE
		icon_state = icon_off
		camera.c_tag = null
		camera.turn_off(null, 0)
		QDEL_NULL(camera)
	visible_message("<span class='notice'>The video camera has been turned [on ? "on" : "off"].</span>")
	for(var/obj/machinery/computer/security/telescreen/entertainment/TV in GLOB.telescreens)
		if(on)
			TV.feeds_on++
		else
			TV.feeds_on--
		TV.update_icon(UPDATE_OVERLAYS)
	COOLDOWN_START(src, video_cooldown, CAMERA_STATE_COOLDOWN)

/obj/item/videocam/attack_self__legacy__attackchain(mob/user)
	if(!COOLDOWN_FINISHED(src, video_cooldown))
		to_chat(user, "<span class='warning'>[src] is overheating, give it some time.</span>")
		return
	camera_state(user)

/obj/item/videocam/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += "It's [on ? "" : "in"]active."

/obj/item/videocam/hear_talk(mob/M as mob, list/message_pieces)
	var/msg = multilingual_to_message(message_pieces)
	if(camera && on)
		if(get_dist(src, M) <= canhear_range)
			talk_into(M, msg)
		for(var/obj/machinery/computer/security/telescreen/entertainment/T in GLOB.telescreens)
			if(usr && (usr.unique_datum_id in T.watchers))
				T.atom_say("[M.name]: [msg]")  // Uses appearance for identifying speaker, not voice

/obj/item/videocam/hear_message(mob/M as mob, msg)
	if(camera && on)
		for(var/obj/machinery/computer/security/telescreen/entertainment/T in GLOB.telescreens)
			if(usr && (usr.unique_datum_id in T.watchers))
				T.atom_say("*[M.name] [msg]")  // Uses appearance for identifying speaker, not voice

/obj/item/videocam/advanced
	name = "advanced video camera"
	desc = "This video camera allows you to send live feeds even when attached to a belt."
	slot_flags = ITEM_SLOT_BELT

#undef CAMERA_STATE_COOLDOWN

///hauntings, like hallucinations but more spooky

/obj/item/camera/proc/handle_haunt(mob/user)
	return

/obj/item/camera/spooky/handle_haunt(mob/user)
	if(user.mind && user.mind.assigned_role == "Chaplain" && see_ghosts && prob(24))
		var/list/creepyasssounds = list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/heartbeat.ogg', 'sound/effects/screech.ogg',\
					'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',\
					'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
					'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
					'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg')
		SEND_SOUND(user, pick(creepyasssounds))


/obj/item/camera/proc/build_composite_icon(atom/A)
	var/icon/composite = icon(A.icon, A.icon_state, A.dir, 1)
	for(var/O in A.overlays)
		var/image/I = O
		composite.Blend(icon(I.icon, I.icon_state, I.dir, 1), ICON_OVERLAY)
	return composite

///Sorts atoms firstly by plane, then by layer on each plane
/obj/item/camera/proc/sort_atoms(list/atoms)
	var/list/sorted_atoms = sortTim(atoms, GLOBAL_PROC_REF(cmp_atom_layer_asc))
	return sorted_atoms
