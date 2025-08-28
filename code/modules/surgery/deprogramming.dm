/datum/surgery/deprogramming
	name = "Deprogramming"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/drill,
		/datum/surgery_step/implant_disruptor,
		/datum/surgery_step/secure_disruptor,
		/datum/surgery_step/generic/cauterize,
	)
	possible_locs = list(BODY_ZONE_HEAD)

/datum/surgery_step/implant_disruptor
	name = "implant disruptor"
	time = 5 SECONDS

/datum/surgery_step/implant_disruptor/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(

/datum/surgery_step/secure_disruptor
	name = "secure disruptor"
	allowed_tools = list(
		TOOL_HEMOSTAT = 100,
		/obj/item/stack/cable_coil = 90,
		/obj/item/stack/sheet/sinew = 80,
		/obj/item/stack/tape_roll = 25,
	)
	time = 7 SECONDS
	preop_sound = 'sound/surgery/hemostat1.ogg'

