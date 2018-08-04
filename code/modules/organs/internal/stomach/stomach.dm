/**
	Stomach organ

	An organ used for handling the transfer of consumed reagents to the human body.
**/

/datum/organ/internal/stomach
	name = "stomach"
	parent_organ = LIMB_CHEST
	organ_type = "stomach"
	var/reagent_size = 200
	removed_type = /obj/item/organ/internal/stomach
	var/base_intake_rate = 1	// rate at which reagents enter the system
	var/obj/item/organ/internal/stomach/reagents_holder = null // need this since /datum/reagents needs an atom

/datum/organ/internal/stomach/New()
	..()
	reagents_holder = new()
	reagents_holder.create_reagents(reagent_size)

/datum/organ/internal/stomach/Copy()
	var/datum/organ/internal/stomach/S = ..()
	S.reagent_size = reagent_size
	return S

/datum/organ/internal/stomach/process()
	..()
	if(is_bruised()) // damage should also tie into hunger calculations
		var/chance = min(50, (damage-min_bruised_damage)/min_broken_damage*50)
		if(prob(chance) && owner.feels_pain())
			to_chat(owner, "<spawn class='warning'>You feel a sharp pain in your gut!</span>")

	var/current_volume = reagents_holder.reagents.total_volume

	if(current_volume >= 0.9 * reagent_size)
		damage += 0.1 // damage from being too full

	// process contents of stomach, slowly moving reagents to bloodstream
	for(var/datum/reagent/R in reagents_holder.reagents.reagent_list)
		// transfer reagents as a weighted average of the current contents times a basic intake rate
		R.digest(owner, current_volume)

	damage = Clamp(damage - 0.02, 0, INFINITY) // natural healing - clamps to be minimum of zero, will account for any healing reagents in the stomach

/datum/organ/internal/stomach/remove(var/mob/user, var/quiet=0)
	var/obj/item/organ/internal/stomach/S = ..()
	reagents_holder.reagents.trans_to(S, reagents_holder.reagents.total_volume)
	return S

/datum/organ/internal/stomach/proc/get_reagents()
	return reagents_holder.reagents

// return volume of a given reagent
/datum/organ/internal/stomach/proc/get_reagent_volume(var/id)
	var/datum/reagent/R = reagents_holder.reagents.get_reagent(id)
	if(R)
		return R.volume
	return 0
