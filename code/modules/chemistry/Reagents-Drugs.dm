//Contains wacky space drugs

ABSTRACT_TYPE(/datum/reagent/drug)

datum
	reagent
		drug/
			name = "some drug"

		drug/spacewalker //Add pressure damage prevention when pressure damage is added.-fluidhelix
			name = "spacewalker"
			id = "spacewalker"
			description = "Somehow, this drug adapts your body to living in space by preventing it from damaging you. Breathing oxygen with it in your system is a very bad idea."
			reagent_state = LIQUID
			fluid_r = 60
			fluid_g = 130
			fluid_b = 75
			transparency = 200
			depletion_rate = 0.1

			on_mob_life(var/mob/M, var/mult = 1) //oxygen toxicity handled in lung.dm, cold protection handled in life.dm
				if(!M) M = holder.my_atom
				if(M.health > 0)
					M.take_oxygen_deprivation(-15)
					if(M.losebreath)
						M.losebreath = max(0, M.losebreath-(5 * mult))
					M.take_brain_damage(0.5 * mult)
				..()
				return



		bathsalts
			name = "bath salts"
			id = "bathsalts"
			description = "Sometimes packaged as a refreshing bathwater additive, these crystals are definitely not for human consumption."
			reagent_state = SOLID
			fluid_r = 250
			fluid_g = 250
			fluid_b = 250
			transparency = 100
			addiction_prob = 15//80
			addiction_min = 5
			overdose = 20
			depletion_rate = 0.6
			energy_value = 1
			hunger_value = -0.1
			bladder_value = -0.1
			thirst_value = -0.05

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_bathsalts", 3)
				return

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_bathsalts")
				return

			on_mob_life(var/mob/M, var/mult = 1) // commence bad times
				if(!M) M = holder.my_atom

				var/check = rand(0,100)
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (check < 8 && H.bioHolder.mobAppearance.customization_second.id != "tramp") // M.is_hobo = very yes
						H.bioHolder.mobAppearance.customization_second = new /datum/customization_style/beard/tramp
						H.set_face_icon_dirty()
						boutput(M, "<span class='alert'><b>You feel gruff!</b></span>")
						SPAWN_DBG(0.3 SECONDS)
							M.visible_message("<span class='alert'><b>[M.name]</b> has a wild look in their eyes!</span>")
					if(check < 60)
						if(H.getStatusDuration("paralysis")) H.delStatus("paralysis")
						H.delStatus("stunned")
						H.delStatus("weakened")
					if(check < 30)
						H.emote(pick("twitch", "twitch_s", "scream", "drool", "grumble", "mumble"))

				M.druggy = max(M.druggy, 15)
				if(check < 20)
					M.change_misstep_chance(10 * mult)
				// a really shitty form of traitor stimulants - you'll be tough to take down but nearly uncontrollable anyways and you won't heal the way stims do


				if(check < 8)
					M.reagents.add_reagent(pick("methamphetamine", "crank", "neurotoxin"), rand(1,5))
					M.visible_message("<span class='alert'><b>[M.name]</b> scratches at something under their skin!</span>")
					random_brute_damage(M, 5 * mult)
				else if (check < 16)
					switch(rand(1,2))
						if(1)
							if(prob(20))
								fake_attackEx(M, 'icons/misc/critter.dmi', "death", "death")
								boutput(M, "<span class='alert'><b>OH GOD LOOK OUT!!!</b>!</span>")
								M.emote("scream")
								M.playsound_local(M.loc, 'sound/musical_instruments/Bell_Huge_1.ogg', 50, 1)
							else if(prob(50))
								fake_attackEx(M, 'icons/misc/critter.dmi', "mimicface", "smiling thing")
								boutput(M, "<span class='alert'><b>The smiling thing</b> laughs!</span>")
								M.playsound_local(M.loc, pick("sound/voice/cluwnelaugh1.ogg", "sound/voice/cluwnelaugh2.ogg", "sound/voice/cluwnelaugh3.ogg"), 35, 1)
							else
								M.playsound_local(M.loc, pick('sound/machines/ArtifactEld1.ogg', 'sound/machines/ArtifactEld2.ogg'), 50, 1)
								boutput(M, "<span class='alert'><b>You hear something strange behind you...</b></span>")
								var/ants = rand(1,3)
								for(var/i = 0, i < ants, i++)
									fake_attackEx(M, 'icons/effects/genetics.dmi', "psyche", "stranger")
						if(2)
							var/halluc_state = null
							var/halluc_name = null
							switch(rand(1,5))
								if(1)
									halluc_state = "husk"
									halluc_name = pick("dad", "mom")
								if(2)
									halluc_state = "fire3"
									halluc_name = pick("vision of your future", "dad", "mom")
								if(3)
									halluc_state = "eaten"
									halluc_name = pick("???", "bad bad BAD")
								if(4)
									halluc_state = "decomp3"
									halluc_name = pick("result of your poor life decisions", "grampa")
								if(5)
									halluc_state = "fire2"
									halluc_name = pick("mom", "dad", "why are they burning WHY")
							fake_attackEx(M, 'icons/mob/human.dmi', halluc_state, halluc_name)
				else if(check < 24)
					boutput(M, "<span class='alert'><b>They're coming for you!</b></span>")
				else if(check < 28)
					boutput(M, "<span class='alert'><b>THEY'RE GONNA GET YOU!</b></span>")
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					boutput(M, "<span class='alert'><font face='[pick("Curlz MT", "Comic Sans MS")]' size='[rand(4,6)]'>You feel FUCKED UP!!!!!!</font></span>")
					M.playsound_local(M.loc, 'sound/effects/heartbeat.ogg', 50, 1)
					M.emote("faint")
					//var/mob/living/carbon/human/H = M
					//if (istype(H))
					M.changeStatus("radiation", 3 SECONDS, 2)
					M.take_toxin_damage(5)
					M.take_brain_damage(10)
				else
					boutput(M, "<span class='notice'>You feel a bit more salty than usual.</span>")
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> flails around like a lunatic!</span>")
						M.change_misstep_chance(25 * mult)
						M.make_jittery(10)
						M.emote("scream")
						M.reagents.add_reagent("salts1", 5 * mult)
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> eyes dilate!</span>")
						M.emote("twitch_s")
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 4 SECONDS))
						M.change_eye_blurry(7, 7)
						M.reagents.add_reagent("salts1", 5 * mult)
					else if (effect <= 7)
						M.emote("faint")
						M.reagents.add_reagent("salts1", 5 * mult)
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> eyes dilate!</span>")
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 4 SECONDS))
						M.change_eye_blurry(7, 7)
						M.reagents.add_reagent("salts1", 5 * mult)
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> convulses violently and falls to the floor!</span>")
						M.make_jittery(50)
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 9 SECONDS))
						M.emote("gasp")
						M.reagents.add_reagent("salts1", 5 * mult)
					else if (effect <= 7)
						M.emote("scream")
						M.visible_message("<span class='alert'><b>[M.name]</b> tears at their own skin!</span>")
						random_brute_damage(M, 5 * mult)
						M.reagents.add_reagent("salts1", 5 * mult)
						M.emote("twitch")

		drug/crank
			name = "crank"
			id = "crank"
			description = "A cheap and dirty stimulant drug, commonly used by space biker gangs."
			reagent_state = SOLID
			fluid_r = 250
			fluid_b = 0
			fluid_g = 200
			transparency = 40
			addiction_prob = 10//50
			addiction_min = 5
			overdose = 20
			value = 20 // 10 2 1 3 1 heat explosion :v
			energy_value = 1.5
			bladder_value = -0.1
			hunger_value = -0.05
			thirst_value = -0.05
			stun_resist = 60

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(probmult(15)) M.emote(pick("twitch", "twitch_s", "grumble", "laugh"))
				if(prob(8))
					boutput(M, "<span class='notice'><b>You feel great!</b></span>")
					M.reagents.add_reagent("methamphetamine", rand(1,2) * mult)
					M.emote(pick("laugh", "giggle"))
				if(prob(6))
					boutput(M, "<span class='notice'><b>You feel warm.</b></span>")
					M.bodytemperature += rand(1,10) * mult
				if(prob(4))
					boutput(M, "<span class='alert'><b>You feel kinda awful!</b></span>")
					M.take_toxin_damage(1 * mult)
					M.make_jittery(30 * mult)
					M.emote(pick("groan", "moan"))
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> looks confused!</span>")
						M.change_misstep_chance(20 * mult)
						M.make_jittery(20)
						M.emote("scream")
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> is all sweaty!</span>")
						M.bodytemperature += rand(5,30) * mult
						M.take_brain_damage(1 * mult)
						M.take_toxin_damage(1 * mult)
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 3 SECONDS))
					else if (effect <= 7)
						M.make_jittery(30)
						M.emote("grumble")
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> is sweating like a pig!</span>")
						M.bodytemperature += rand(20,100) * mult
						M.take_toxin_damage(5 * mult)
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 4 SECONDS))
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> starts tweaking the hell out!</span>")
						M.make_jittery(100)
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(8 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 4 SECONDS))
						M.change_misstep_chance(25 * mult)
						M.emote("scream")
						M.reagents.add_reagent("salts1", 5 * mult)
					else if (effect <= 7)
						M.emote("scream")
						M.visible_message("<span class='alert'><b>[M.name]</b> nervously scratches at their skin!</span>")
						M.make_jittery(10)
						random_brute_damage(M, 5 * mult)
						M.emote("twitch")

		drug/LSD
			name = "lysergic acid diethylamide"
			id = "LSD"
			description = "A highly potent hallucinogenic substance. Far out, maaaan."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 255
			transparency = 20
			value = 6 // 4 2
			thirst_value = -0.03

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
//				if(M.canmove) step(M, pick(cardinal))
//				if(prob(7)) M.emote(pick("twitch","drool","moan","giggle"))
				if(probmult(6))
					switch(rand(1,2))
						if(1)
							if(prob(50))
								fake_attack(M)
							else
								var/monkeys = rand(1,3)
								for(var/i = 0, i < monkeys, i++)
									fake_attackEx(M, 'icons/mob/monkey.dmi', "monkey_hallucination", "monkey ([rand(1, 1000)])")
						if(2)
							var/halluc_state = null
							var/halluc_name = null
							switch(rand(1,5))
								if(1)
									halluc_state = "pig"
									halluc_name = pick("pig", "DAT FUKKEN PIG", "Oinkalicious")
								if(2)
									halluc_state = "spider"
									halluc_name = pick("giant black widow", "queen bitch spider", "OH FUCK A SPIDER")
								if(3)
									halluc_state = "dragon"
									halluc_name = pick("dragon", "Lord Cinderbottom", "SOME FUKKEN LIZARD THAT BREATHES FIRE")
								if(4)
									halluc_state = "slime"
									halluc_name = pick("red slime", "some gooey thing", "ANGRY CRIMSON POO")
								if(5)
									halluc_state = "shambler"
									halluc_name = pick("shambler", "strange creature", "OH GOD WHAT THE FUCK IS THAT THING?")
							fake_attackEx(M, 'icons/effects/hallucinations.dmi', halluc_state, halluc_name)
				if(probmult(9))
					M.playsound_local(M.loc, pick("explosion", "punch", 'sound/vox/poo-vox.ogg', "clownstep", 'sound/weapons/armbomb.ogg', 'sound/weapons/Gunshot.ogg'), 50, 1)
				if(probmult(8))
					boutput(M, "<b>You hear a voice in your head... <i>[phrase_log.random_phrase("say")]</i></b>")
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					boutput(M, "<span class='alert'><font face='[pick("Arial", "Georgia", "Impact", "Mucida Console", "Symbol", "Tahoma", "Times New Roman", "Verdana")]' size='[rand(3,6)]'>Holy shit, you start tripping balls!</font></span>")
				return

		drug/lsd_bee
			name = "lsbee"
			id = "lsd_bee"
			description = "A highly potent hallucinogenic substance. It smells like honey."
			taste = "sweet"
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 235
			fluid_b = 0
			transparency = 100
			value = 5
			thirst_value = -0.03

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 5)
				if (probmult(10))
					var/hstate = null
					var/hname = null
					switch(rand(1,5))
						if(1)
							hstate = "zombee-wings"
							hname = pick("zombee", "undead bee", "BZZZZZZZZ")
						if(2)
							hstate = "syndiebee-wings"
							hname = pick("syndiebee", "evil bee", "syndicate assassin bee", "IT HAS A GUN")
						if(3)
							hstate = "bigbee-angry"
							hname = pick("very angry bee", "extremely angry bee", "GIANT FRICKEN BEE")
						if(4)
							hstate = "lichbee-wings"
							hname = pick("evil bee", "demon bee", "YOU CAN'T BZZZZ FOREVER")
						if(5)
							hstate = "voorbees-wings"
							hname = pick("killer bee", "murder bee", "bad news bee", "RUN")
					fake_attackEx(M, 'icons/misc/bee.dmi', hstate, hname)
				if (probmult(12))
					M.visible_message(pick("<b>[M]</b> makes a buzzing sound.", "<b>[M]</b> buzzes."),pick("BZZZZZZZZZZZZZZZ", "<span class='alert'><b>THE BUZZING GETS LOUDER</b></span>", "<span class='alert'><b>THE BUZZING WON'T STOP</b></span>"))
				if (probmult(15))
					switch(rand(1,2))
						if(1)
							M.emote("twitch")
						if(2)
							M.emote("scream")
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					boutput(M, "Your ears start buzzing.")

		drug/lean
			name = "lean"
			id = "lean"
			description = "A cheap and unsafe painkiller drink."
			reagent_state = LIQUID
			fluid_r = 150
			fluid_g = 110
			fluid_b = 220
			addiction_min = 10
			addiction_prob = 35
			depletion_rate = 0.5
			viscosity = 0.1
			thirst_value = 0.7
			overdose = 20
			var/counter = 0

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/lean, src.type)
				..()

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/lean, src.type)
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(probmult(7)) M.emote(pick("twitch","drool","moan","giggle"))
				M.take_brain_damage(0.5 * mult)
				if (!counter) counter = 1
				switch(counter+= (1 * mult))
					if (1 to 11)
						return
					if (12 to INFINITY)
						M.change_misstep_chance(2 * mult)
				..()
				return

		drug/space_drugs
			name = "MDMA"
			id = "space_drugs"
			description = "An illegal chemical compound used as a cheap hallucinogen and party enhancer."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_g = 185
			fluid_b = 230
			addiction_prob = 15//65
			addiction_min = 10
			depletion_rate = 0.2
			value = 3 // 1c + 1c + 1c
			viscosity = 0.2
			thirst_value = -0.03

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				if(probmult(50)) M.emote(pick("giggle","smile","laugh"))
				if(probmult(30))
					. = ""
					switch (rand(1, 9))
						if (1)
							. = "appreciated"
						if (2)
							. = "loved"
						if (3)
							. = "pretty good"
						if (4)
							. = "really nice"
						if (5)
							. = "cared for"
						if (6)
							. = "like you belong"
						if (7)
							. = "accepted for who you are"
						if (8)
							. = "like things will be okay"
						if (9)
							. = "pretty happy with yourself, even though things haven't always gone as well as they could"


					boutput(M, "<span class='notice'>You feel [.].</span>")

				if (prob(50) && !M.restrained() && ishuman(M)) // only humans hug, I think?
					var/mob/living/carbon/human/H = M
					for (var/mob/living/carbon/human/hugTarget in orange(1,H))
						if (hugTarget == H)
							continue
						if (!hugTarget.stat)
							H.emote(prob(50)?"sidehug":"hug", emoteTarget="[hugTarget]")
							break



				..()
				return

		drug/THC
			name = "tetrahydrocannabinol"
			id = "THC"
			description = "A mild psychoactive chemical extracted from the cannabis plant."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 225
			fluid_b = 0
			transparency = 200
			value = 3
			viscosity = 0.4
			hunger_value = -0.04
			thirst_value = -0.04

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.stuttering += rand(0,2)
				if(M.client && probmult(5))
					for (var/obj/critter/domestic_bee/bee in view(7,M))
						var/chat_text = null
						var/text = pick_smart_string("shit_bees_say_when_youre_high.txt", "strings", list(
							"M"="[M]",
							"beeMom"=bee.beeMom ? bee.beeMom : "Mom",
							"other_bee"=istype(bee, /obj/critter/domestic_bee/sea) ? "Spacebee" : "Seabee",
							"bee"=istype(bee, /obj/critter/domestic_bee/sea) ? "Seabee" : "Spacebee"
							))
						if(!M.client.preferences.flying_chat_hidden)
							var/speechpopupstyle = "font-family: 'Comic Sans MS'; font-size: 8px;"
							chat_text = make_chat_maptext(bee, text, "color: [rgb(194,190,190)];" + speechpopupstyle, alpha = 140)
						M.show_message("[bee] buzzes \"[text]\"",2, assoc_maptext = chat_text)
						break

				if(probmult(5))
					M.emote(pick("laugh","giggle","smile"))
				if(probmult(5))
					boutput(M, "[pick("You feel hungry.","Your stomach rumbles.","You feel cold.","You feel warm.")]")
				if(prob(4))
					M.change_misstep_chance(10 * mult)
				if (holder.get_reagent_amount(src.id) >= 50 && probmult(25))
					if(prob(10))
						M.setStatus("drowsy", 20 SECONDS)
				..()
				return

		drug/CBD
			name = "cannabidiol"
			id = "CBD"
			description = "A non-psychoactive phytocannabinoid extracted from the cannabis plant."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 225
			fluid_b = 0
			transparency = 200
			value = 3
			viscosity = 0.4
			hunger_value = -0.04
			thirst_value = 0.03

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(probmult(5))
					M.emote(pick("sigh","yawn","hiccup","cough"))
				if(probmult(5))
					boutput(M, "[pick("You feel peaceful.","You breathe softly.","You feel chill.","You vibe.")]")
				if(probmult(10))
					M.change_misstep_chance(-5)
					M.delStatus("weakened")
				if (holder.get_reagent_amount(src.id) >= 70 && probmult(25))
					if (holder.get_reagent_amount("THC") <= 20)
						M.setStatus("drowsy", 20 SECONDS)
				if(prob(25))
					M.HealDamage("All", 2 * mult, 0)
				..()
				return

		drug/nicotine
			name = "nicotine"
			id = "nicotine"
			description = "A highly addictive stimulant extracted from the tobacco plant."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			viscosity = 0.2
			transparency = 190
			addiction_prob = 15//70
			addiction_min = 10
			max_addiction_severity = "LOW"
			overdose = 35 // raise if too low - trying to aim for one sleepypen load being problematic, two being deadlyish
			//var/counter = 1
			//note that nicotine is also horribly poisonous in concentrated form IRM - could be used as a poor-man's toxin?
			//just comment that out if you don't think it's any good.
			// Gonna try this out. Not good for you but won't horribly maim you from taking a quick puff of a cigarette - ISN
			value = 3
			thirst_value = -0.07
			stun_resist = 8

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_nicotine", 1)
				..()

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_nicotine")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(probmult(50))
					M.make_jittery(5)

				if(src.volume > src.overdose)
					M.take_toxin_damage(1 * mult)
				..()

			//cogwerks - improved nicotine poisoning?
			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> looks nervous!</span>")
						M.change_misstep_chance(15 * mult)
						M.take_toxin_damage(2 * mult)
						M.make_jittery(10)
						M.emote("twitch")
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> is all sweaty!</span>")
						M.bodytemperature += rand(15,30) * mult
						M.take_toxin_damage(3 * mult)
					else if (effect <= 7)
						M.take_toxin_damage(4 * mult)
						M.emote("twitch_v")
						M.make_jittery(10)
				else if (severity == 2)
					if (effect <= 2)
						M.emote("gasp")
						boutput(M, "<span class='alert'><b>You can't breathe!</b></span>")
						M.take_oxygen_deprivation(15 * mult)
						M.take_toxin_damage(3 * mult)
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 1 SECOND * mult))
					else if (effect <= 4)
						boutput(M, "<span class='alert'><b>You feel terrible!</b></span>")
						M.emote("drool")
						M.make_jittery(10)
						M.take_toxin_damage(5 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 1 SECOND * mult))
						M.change_misstep_chance(33 * mult)
					else if (effect <= 7)
						M.emote("collapse")
						boutput(M, "<span class='alert'><b>Your heart is pounding!</b></span>")
						M << sound('sound/effects/heartbeat.ogg')
						M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 5 SECONDS * mult))
						M.make_jittery(30)
						M.take_toxin_damage(6 * mult)
						M.take_oxygen_deprivation(20 * mult)

		drug/nicotine/nicotine2
			name = "nicotwaine"
			id = "nicotine2"
			description = "A highly addictive stimulant derived from the twobacco plant."
			addiction_prob = 100
			overdose = 70
			stun_resist = 11

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_nicotine2", 3)
				..()

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_nicotine2")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.sims)
						H.sims.affectMotive("fun", 2)
				if(probmult(75))
					M.make_jittery(10)
				if(probmult(25))
					M.emote(pick("drool","shudder","groan","moan","shiver"))
					boutput(M, "<span class='success'><b>You feel... pretty good... and calm... weird.</b></span>")
				if(probmult(10))
					M.make_jittery(20)
					M.emote(pick("twitch","twitch_v","shiver","shudder","flinch","blink_r"))
					boutput(M, "<span class='alert'><b>You can feel your heartbeat in your throat!</b></span>")
					M.playsound_local(M.loc, 'sound/effects/heartbeat.ogg', 50, 1)
					M.take_toxin_damage(2)
				if(probmult(5))
					M.delStatus("paralysis")
					M.delStatus("stunned")
					M.delStatus("weakened")
					M.delStatus("paralysis")
					M.sleeping = 0
					M.make_jittery(30)
					M.emote(pick("twitch","twitch_v","shiver","shudder","flinch","blink_r"))
					boutput(M, "<span class='alert'><b>Your heart's beating really really fast!</b></span>")
					M.playsound_local(M.loc, 'sound/effects/heartbeat.ogg', 50, 1)
					M.take_toxin_damage(4)
				if(src.volume > src.overdose)
					M.take_toxin_damage(2)
				..(M)

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				..()
				..()
				/*var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> looks really nervous!</span>")
						boutput(M, "<span class='alert'><b>You feel really nervous!</b></span>")
						M.change_misstep_chance(30)
						M.take_toxin_damage(3)
						M.make_jittery(20)
						M.emote("twitch")
						M.emote("twitch")
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> is super sweaty!</span>")
						boutput(M, "<span class='alert'><b>You feel hot! Is it hot in here?!</b></span>")
						M.bodytemperature += rand(30,60)
						M.take_toxin_damage(4)
					else if (effect <= 7)
						M.take_toxin_damage(5)
						M.emote("twitch_v")
						M.emote("twitch_v")
						M.make_jittery(20)
				else if (severity == 2)
					if (effect <= 2)
						M.emote("gasp")
						M.emote("gasp")
						boutput(M, "<span class='alert'><b>You really can't breathe!</b></span>")
						M.take_oxygen_deprivation(15)
						M.take_toxin_damage(4)
						M.changeStatus("stunned", 10 * mult)
					else if (effect <= 4)
						boutput(M, "<span class='alert'><b>You feel really terrible!</b></span>")
						M.emote("drool")
						M.emote("drool")
						M.make_jittery(20)
						M.take_toxin_damage(5)
						M.changeStatus("weakened", 10 * mult)
						M.change_misstep_chance(66)
					else if (effect <= 7)
						M.emote("collapse")
						boutput(M, "<span class='alert'><b>Your heart is pounding! You need help!</b></span>")
						M << sound('sound/effects/heartbeat.ogg')
						M.changeStatus("weakened", 50 * mult)
						M.make_jittery(60)
						M.take_toxin_damage(5)
						M.take_oxygen_deprivation(20)*/

		drug/psilocybin
			name = "psilocybin"
			id = "psilocybin"
			description = "A powerful hallucinogenic chemical produced by certain mushrooms."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 230
			fluid_b = 200
			transparency = 200
			value = 3
			viscosity = 0.1
			thirst_value = -0.3

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				if(probmult(8))
					boutput(M, "<b>You hear a voice in your head... <i>[phrase_log.random_phrase("say")]</i></b>")
				if(probmult(8))
					M.emote(pick("scream","cry","laugh","moan","shiver"))
				if(probmult(3))
					switch (rand(1,3))
						if(1)
							boutput(M, "<B>The Emergency Shuttle has docked with the station! You have 3 minutes to board the Emergency Shuttle.</B>")
						if(2)
							boutput(M, "<span class='alert'><b>Restarting world!</b> </span><span class='notice'>Initiated by Administrator!</span>")
							SPAWN_DBG(2 SECONDS) M.playsound_local(M.loc, pick('sound/misc/NewRound.ogg', 'sound/misc/NewRound2.ogg', 'sound/misc/NewRound3.ogg', 'sound/misc/NewRound4.ogg', 'sound/misc/TimeForANewRound.ogg'), 50, 1)
						if(3)
							switch (rand(1,4))
								if(1)
									boutput(M, "<span class='alert'><b>Unknown fires the revolver at [M]!</b></span>")
									M.playsound_local(M.loc, 'sound/weapons/Gunshot.ogg', 50, 1)
								if(2)
									boutput(M, "<span class='alert'><b>[M] has been attacked with the fire extinguisher by Unknown</b></span>")
									M.playsound_local(M.loc, 'sound/impact_sounds/Metal_Hit_1.ogg', 50, 1)
								if(3)
									boutput(M, "<span class='alert'><b>Unknown has punched [M]</b></span>")
									boutput(M, "<span class='alert'><b>Unknown has weakened [M]</b></span>")
									M.setStatus("weakened", max(M.getStatusDuration("weakened"), 1 SECOND))
									M.playsound_local(M.loc, pick(sounds_punch), 50, 1)
								if(4)
									boutput(M, "<span class='alert'><b>[M] has been attacked with the taser gun by Unknown</b></span>")
									boutput(M, "<i>You can almost hear someone talking...</i>")
									M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 3 SECONDS))
				..()


		drug/krokodil
			name = "krokodil"
			id = "krokodil"
			description = "A sketchy homemade opiate, often used by disgruntled Cosmonauts."
			reagent_state = SOLID
			fluid_r = 0
			fluid_g = 100
			fluid_b = 180
			transparency = 250
			addiction_prob = 10//50
			addiction_min = 10
			overdose = 20
			hunger_value = -0.1
			thirst_value = -0.09

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.jitteriness -= 40
				if(prob(25)) M.take_brain_damage(1 * mult)
				if(probmult(15)) M.emote(pick("smile", "grin", "yawn", "laugh", "drool"))
				if(prob(10))
					boutput(M, "<span class='notice'><b>You feel pretty chill.</b></span>")
					M.bodytemperature -= 1 * mult
					M.emote("smile")
				if(prob(5))
					boutput(M, "<span class='alert'><b>You feel too chill!</b></span>")
					M.emote(pick("yawn", "drool"))
					M.setStatus("stunned", max(M.getStatusDuration("stunned"), 2 SECONDS * mult))
					M.take_toxin_damage(1 * mult)
					M.take_brain_damage(1 * mult)
					M.bodytemperature -= 20 * mult
				if(prob(2))
					boutput(M, "<span class='alert'><b>Your skin feels all rough and dry.</b></span>")
					random_brute_damage(M, 2 * mult)
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> looks dazed!</span>")
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 4 SECONDS))
						M.emote("drool")
					else if (effect <= 4)
						M.emote("shiver")
						M.bodytemperature -= 40 * mult
					else if (effect <= 7)
						boutput(M, "<span class='alert'><b>Your skin is cracking and bleeding!</b></span>")
						random_brute_damage(M, 5 * mult)
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.emote("cry")
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> sways and falls over!</span>")
						M.take_toxin_damage(3 * mult)
						M.take_brain_damage(3 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 9 SECONDS * mult))
						M.emote("faint")
					else if (effect <= 4)
						if(ishuman(M))
							M.visible_message("<span class='alert'><b>[M.name]'s</b> skin is rotting away!</span>")
							random_brute_damage(M, 25 * mult)
							M.emote("scream")
							M.bioHolder.AddEffect("eaten") //grody. changed line in human.dm to use decomp1 now
							M.emote("faint")
					else if (effect <= 7)
						M.emote("shiver")
						M.bodytemperature -= 70 * mult
//FINISH LATER -fluidhelix
		drug/ambuprophen
			name = "ambuprophen"
			id = "ambuprophen"
			description = "A cheap and effective painkiller."
			reagent_state = SOLID
			fluid_r = 165
			fluid_g = 185
			fluid_b = 220
			addiction_min = 15
			addiction_prob = 100
			transparency = 50
			overdose = 25

			on_add()
				if (ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					boutput(M, "You stop feeling any pain from your less severe wounds...")
					boutput(M, "<b>You hear a voice in your head say 'This chemical is under construction, its supposed to fix staminaloss from damage above crit but that feature hasn't been implimented yet!'. Wonder what that means.</b>")
/*					M.bioHolder.AddEffect("r_ambuprophen")

			on_remove()
				if (ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.bioHolder.RemoveEffect("r_ambuprophen")
				..()*/

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.take_toxin_damage(1 * mult)
				holder.remove_reagent("mannitol", 5)
				holder.remove_reagent("syaptizine", 5)
				holder.remove_reagent("leocizumab", 5)
				..()


		drug/plasmorphine
			name = "plasmorphine"
			id = "plasmorphine"
			description = "Chemically similar to morphine, this drug has the same effects but doesn't damage the brain. Popular with spacers all over the Sphere."
			reagent_state = LIQUID
			fluid_r = 160
			fluid_g = 150
			fluid_b = 190
			transparency = 75
			depletion_rate = 0.4

			on_add()
				if (ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					boutput(M, "Every sensation on your skin stops...")
					boutput(M, "<b>You hear a voice in your head say 'This chemical is under construction, its supposed to undo disorientation from shocks and give you immunity to tasers but that feature hasn't been implimented yet!'. Wonder what that means.</b>")
/*					M.bioHolder.AddEffect("r_plasmorphine")

			on_remove()
				if (ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.bioHolder.RemoveEffect("r_plasmorphine")
				..()*/

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.take_toxin_damage(0.5 * mult)
				M.take_brain_damage(1 * mult)
				..()

		drug/jarhead
			name = "Jarhead"
			id = "jarhead"
			description = "The most powerful painkiller in the world. EXTREMELY expensive, dangerous and powerful. Popular with spec-ops units."
			reagent_state = LIQUID
			fluid_r = 30
			fluid_g = 15
			fluid_b = 25
			transparency = 255

			on_add()
				if (ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					boutput(M, "You feel like a living tank!")
					boutput(M, "<b>You hear a voice in your head say 'This chemical is under construction, its supposed to prevent you from falling over in crit and give you immunity to stagger but that feature hasn't been implimented yet!'. Wonder what that means.</b>")
/*					M.bioHolder.AddEffect("r_plasmorphine")

			on_remove()
				if (ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.bioHolder.RemoveEffect("r_plasmorphine")
				..()*/

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.take_brain_damage(1 * mult)
				M.HealDamage("All", 1, 1)
				..()

		drug/catdrugs
			name = "cat drugs"
			id = "catdrugs"
			description = "Uhhh..."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 0
			transparency = 20
			viscosity = 0.14
			thirst_value = -0.1

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				if(probmult(11))
					M.visible_message("<span class='notice'><b>[M.name]</b> hisses!</span>")
					playsound(M.loc, "sound/voice/animal/cat_hiss.ogg", 50, 1)
				if(probmult(9))
					M.visible_message("<span class='notice'><b>[M.name]</b> meows! What the fuck?</span>")
					playsound(M.loc, "sound/voice/animal/cat.ogg", 50, 1)
				if(probmult(7))
					switch(rand(1,2))
						if(1)
							var/ghostcats = rand(1,3)
							for(var/i = 0, i < ghostcats, i++)
								fake_attackEx(M, 'icons/misc/critter.dmi', "cat-ghost", "ghost cat")
								M.playsound_local(M.loc, pick('sound/voice/animal/cat.ogg', 'sound/voice/animal/cat_hiss.ogg'), 50, 1)
						if(2)
							var/wildcats = rand(1,3)
							for(var/i = 0, i < wildcats, i++)
								fake_attackEx(M, 'icons/misc/critter.dmi', "cat1-wild", "wild cat")
								M.playsound_local(M.loc, pick('sound/voice/animal/cat.ogg', 'sound/voice/animal/cat_hiss.ogg'), 50, 1)
				if(probmult(20))
					M.playsound_local(M.loc, pick('sound/voice/animal/cat.ogg', 'sound/voice/animal/cat_hiss.ogg'), 50, 1)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					M.playsound_local(M.loc, pick('sound/voice/animal/cat.ogg', 'sound/voice/animal/cat_hiss.ogg'), 50, 1)
					boutput(M, "<span class='alert'><font face='[pick("Arial", "Georgia", "Impact", "Mucida Console", "Symbol", "Tahoma", "Times New Roman", "Verdana")]' size='[rand(3,6)]'>Holy shit, you start tripping balls!</font></span>")
				return

		drug/triplemeth
			name = "triple meth"
			id = "triplemeth"
			description = "Hot damn ... i don't even ..."
			reagent_state = SOLID
			fluid_r = 250
			fluid_g = 250
			fluid_b = 250
			transparency = 220
			addiction_prob = 100
			addiction_min = 0
			overdose = 20
			depletion_rate = 0.2
			value = 39 // 13c * 3  :v
			energy_value = 3
			bladder_value = -0.1
			hunger_value = -0.3
			thirst_value = -0.2

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "triplemeth")
					M.remove_stun_resist_mod("triplemeth")

				if(hascall(holder.my_atom,"removeOverlayComposition"))
					holder.my_atom:removeOverlayComposition(/datum/overlayComposition/triplemeth)
				..()


			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom

				if(holder.has_reagent("methamphetamine")) return ..() //Since is created by a meth overdose, dont react while meth is in their system.
				M.add_stun_resist_mod("triplemeth", 98)
				APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "triplemeth", 1000)

				if(hascall(holder.my_atom,"addOverlayComposition"))
					holder.my_atom:addOverlayComposition(/datum/overlayComposition/triplemeth)

				if(probmult(50)) M.emote(pick("twitch","blink_r","shiver"))
				M.make_jittery(5)
				M.make_dizzy(5 * mult)
				M.change_misstep_chance(15 * mult)
				M.take_brain_damage(1 * mult)
				M.delStatus("disorient")
				if(M.sleeping) M.sleeping = 0
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if(holder.has_reagent("methamphetamine")) return ..() //Since is created by a meth overdose, dont react while meth is in their system.
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> can't seem to control their legs!</span>")
						M.change_misstep_chance(12 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 5 SECONDS * mult))
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> hands flip out and flail everywhere!</span>")
						M.drop_item()
						M.hand = !M.hand
						M.drop_item()
						M.hand = !M.hand
					else if (effect <= 7)
						M.emote("laugh")
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> hands flip out and flail everywhere!</span>")
						M.drop_item()
						M.hand = !M.hand
						M.drop_item()
						M.hand = !M.hand
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> falls to the floor and flails uncontrollably!</span>")
						M.make_jittery(10)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 10 SECONDS * mult))
					else if (effect <= 7)
						M.emote("laugh")

		drug/methamphetamine
			name = "methamphetamine"
			id = "methamphetamine"
			description = "Methamphetamine is a effective and dangerous stimulant drug."
			reagent_state = SOLID
			fluid_r = 250
			fluid_g = 250
			fluid_b = 250
			transparency = 220
			addiction_prob = 50//60
			addiction_min = 5
			overdose = 25
			depletion_rate = 0.4

			value = 13 // 9c + 1c + 1c + 1c + heat


			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_methamphetamine", 2)
					M.add_stam_mod_max("methamphetamine", 30)

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_methamphetamine")
					M.remove_stam_mod_max(src.id)


			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.take_brain_damage(0.5 * mult)
				if(probmult(5)) M.emote(pick("twitch","blink_r","shiver"))
				M.make_jittery(5)
				if(probmult(5))
					M.reagents.add_reagent("histamine", 10 * mult)
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				if (severity >= 0)
					M.take_toxin_damage(2 * mult)
				if(probmult(50))
					M.take_brain_damage(2 * mult)

		drug/necrotonium
			name = "necrotonium"
			id = "necrotonium"
			description = "A rare drug that causes the user to appear dead for some time." //dead appearance handled in human.dm
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 145
			fluid_b = 110
			transparency = 50
			depletion_rate = 0.3


		drug/ampuline
			name = "ampuline"
			id = "ampuline"
			description = "An unusual drug that harmlessly eletrifies the user. Mostly safe."
			reagent_state = LIQUID
			fluid_r = 180
			fluid_g = 250
			fluid_b = 50
			transparency = 150
			depletion_rate = 0.4
			addiction_prob = 50
			addiction_min = 15
			overdose = 25


			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_ampuline", 1)
					if(!M.bioHolder.HasEffect("resist_electric_heal"))
						M.bioHolder.AddEffect("resist_electric_heal")
					boutput(M, ("<span class='notice'>Electricity is flowing through your blood. It feels pleasant.</span>"))

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_ampuline")
					M.bioHolder.RemoveEffect("resist_electric_heal")


			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.make_jittery(5)
				data = pick("You feel positively electric!","You've got some negative feelings.","You feel weird. How shocking.","You're snapping, crackling and popping all over.","Your hands buzz from static electricity.","You feel like a goddamned pikachu.")
				if(probmult(10)) boutput(M, ("<span class='notice'>[data]</span>"))
				if(probmult(10)) elecflash(M, 1, 4, 1)
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				if (severity == 1)
					M.stuttering += 1
					if(probmult(10))
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 3 SECONDS * mult))
					M.TakeDamage("chest", 0, 2 * mult, 0, DAMAGE_BURN)
				else if (severity >= 2)
					M.stuttering += 2
					if(probmult(20))
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 3 SECONDS * mult))
					M.TakeDamage("chest", 0, 4 * mult, 0, DAMAGE_BURN)


		drug/phoronic_smelling_salts
			name = "phoronic smelling salts"
			id = "phoronic_smelling_salts"
			description = "A very potent stimulant. Mostly unsafe and extremely addictive."
			reagent_state = SOLID
			fluid_r = 70
			fluid_g = 55
			fluid_b = 65
			transparency = 255
			addiction_prob = 80
			addiction_min = 5
			depletion_rate = 0.5
			overdose = 20

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_phoronic_smelling_salts", 6)
					APPLY_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/phoronic_smelling_salts, src.type)
					M.add_stam_mod_max("phoronic smelling salts", 40)

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_phoronic_smelling_salts")
					REMOVE_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/phoronic_smelling_salts, src.type)
					M.remove_stam_mod_max("phoronic smelling salts")


			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.take_brain_damage(1 * mult)
				if(probmult(5)) M.emote(pick("twitch","blink_r","shiver"))
				M.make_jittery(5)
				data = pick("Your heart is pounding!","You're sweating buckets. Thats concerning.","Your arms are twitching like crazy.","You feel UNSTOPPABLE. And warm. Mostly unstoppable, though","You feel like you're as powerful as a god.")
				if(probmult(20)) boutput(M, pick("<span class='notice'>[data]</span>"))
				M.bodytemperature = max(M.base_body_temp, M.bodytemperature+(10 * mult))
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/mob/living/carbon/human/H = M
				if (severity == 1)
					M.stuttering += 1
					if(probmult(20))
						M.visible_message("<span class='alert'>[M] pukes all over \himself.</span>", "<span class='alert'>You puke all over yourself!</span>")
						M.vomit()
					M.take_toxin_damage(1 * mult)
					if (H.organHolder)
						H.organHolder.damage_organ(0, 0, 2, "heart")
				else if (severity >= 2)
					M.stuttering += 2
					if(probmult(35))
						M.visible_message("<span class='alert'>[M] pukes all over \himself.</span>", "<span class='alert'>You puke all over yourself!</span>")
						M.vomit()
						M.take_toxin_damage(2 * mult)
					if (H.organHolder)
						H.organHolder.damage_organ(0, 0, 4, "heart")
					M.take_toxin_damage(2 * mult)

		drug/adrenomax
			name = "Adreno-Max"
			id = "adreno-max"
			description = "The most powerful stimulant in the world. Doesn't mix well with your brain or things that heal your brain."
			reagent_state = SOLID
			fluid_r = 15
			fluid_g = 230
			fluid_b = 190
			addiction_min = 10
			addiction_prob = 100
			overdose = 20
			transparency = 255
			depletion_rate = 0.4

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_adrenomax", 20)
					APPLY_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/adrenomax, src.type)
					M.add_stam_mod_max("adrenomax", 120)

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_adrenomax")
					REMOVE_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/adrenomax, src.type)
					M.remove_stam_mod_max("adrenomax")


			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.take_brain_damage(2 * mult)
				if(probmult(30)) M.emote(pick("twitch","blink_r","shiver"))
				M.make_jittery(5)
				data = pick("<b>HAHAHAHAHAHAHAHAHAHAH!!!!</b>","You feel like you can fight the fucking sun and <b>WIN</b>!","KILL THEM! KILL THEM ALL!", "WOOOOOOOO!!!!!","You feel <b>GOOD</b>.")
				if(probmult(20)) boutput(M, pick("<span class='notice'>[data]</span>"))
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				if (severity == 1)
					M.stuttering += 1
					if(probmult(20))
						M.visible_message("<span class='alert'>[M] pukes all over \himself.</span>", "<span class='alert'>You puke all over yourself!</span>")
						M.vomit()
					M.take_toxin_damage(1 * mult)
					M.take_brain_damage(2 * mult)
				else if (severity >= 2)
					M.stuttering += 2
					if(probmult(35))
						M.visible_message("<span class='alert'>[M] pukes all over \himself.</span>", "<span class='alert'>You puke all over yourself!</span>")
						M.vomit()
						M.take_toxin_damage(2 * mult)
					M.take_brain_damage(4 * mult)
					M.take_toxin_damage(2 * mult)


		drug/ambrosia
			name = "Ambrosia"
			id = "ambrosia"
			description = "I- how- damn, I dont even-"
			reagent_state = SOLID
			fluid_r = 80
			fluid_g = 20
			fluid_b = 130
			transparency = 255
			depletion_rate = 0.25
			var/counter = 1

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					counter = 1
					if(volume < 10) boutput(M, "You feel like you need more of... whatever this is before it becomes effective.")

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.deity == 0 && volume >= 10)
					M.deity = 1
					boutput(M, "<span class='alert'><b>You are as powerful as the gods.</b></span>")
					APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_ambrosia", 999990)
					M.add_stam_mod_max("ambrosia", 1000)
				if(M.deity == 1)
					if(volume < 3)boutput(M, "<span class='alert'><b>You need more ambrosia. Now. NOW.</b></span>")
					if(volume <= 1)
						holder.remove_reagent("ambrosia", 1)
						M.gib()
					if(M.get_oxygen_deprivation())
						M.take_oxygen_deprivation(-250 * mult)
					M.take_brain_damage(-250 * mult)
					M.HealDamage("All", 250 * mult, 250 * mult, 250 * mult)
					M.delStatus("radiation")
					M.delStatus("paralysis")
					M.delStatus("weakened")
					M.delStatus("stunned")
					M.stuttering = 0
					M.take_ear_damage(-INFINITY)
					M.take_ear_damage(-INFINITY, 1)
					M.change_eye_blurry(-INFINITY)
					if(M.losebreath > 0)
						M.losebreath = (0 * mult)
					counter += 1
					if(counter > 280)boutput(M, "<span class='alert'><b>Time is running out. Nothing can save you now.</b></span>")
					if(counter == 299) boutput(M, "<span class='alert'><b>The time has come.</b></span>")
					if(counter == 300)
						boutput(M, "<span class='alert'><b>It's too late.</b></span>")
						holder.remove_reagent("ambrosia", 330)
						M.gib()
				..()
				return



		drug/hellshroom_extract
			name = "Hellshroom extract"
			id = "hellshroom_extract"
			description = "TEMP"
			reagent_state = SOLID
			fluid_r = 163
			fluid_g = 17
			fluid_b = 63
			transparency = 100
			depletion_rate = 0.3

			on_mob_life(var/mob/M, var/mult = 1) // commence bad times
				if(!M) M = holder.my_atom
				if(ishuman(M))
					var/mob/living/carbon/human/K = M
					if (K.sims)
						K.sims.affectMotive("Energy", 2)
						K.sims.affectMotive("fun", 1)
						K.sims.affectMotive("Bladder", -0.5)
						K.sims.affectMotive("Hunger", -1)
						K.sims.affectMotive("Thirst", -2)
				var/mob/living/H = M
				var/check = rand(0,100)
				if (istype(H))
					if (M.reagents.has_reagent("milk"))
						boutput(M, "<span class='notice'>The milk stops the burning. Ahhh.</span>")
						M.reagents.del_reagent("milk")
						M.reagents.del_reagent("hellshroom_extract")
					if (check < 20)
						src.breathefire(M)
					if(check < 5)
						var/bats = rand(2,3)
						for(var/i = 0, i < bats, i++)
						fake_attackEx(M, 'icons/misc/AzungarAdventure.dmi', "hellbat", "hellbat")
						boutput(M, "<span class='alert'><b>A hellbat begins to chase you</b>!</span>")
						M.emote("scream")
					if(check < 20)
						boutput(M, "<span class='alert'><b>Oh god! Oh GODD!!</b></span>")
					if(check < 20)
						boutput(M, "<span class='alert'><b>You feel like you are melting from the inside!</b></span>")
					if(check < 20)
						boutput(M, "<span class='alert'>Your throat feels like it's on fire!</span>")
						M.emote(pick("scream","cry","twitch_s","choke","gasp","grumble"))
						M.changeStatus("paralysis", 2 SECONDS)
					if(check < 20)
						boutput(M, "<span class='notice'><b>You feel A LOT warmer.</b></span>")
						M.bodytemperature += rand(30,60)
				..()
				return


datum/reagent/drug/hellshroom_extract/proc/breathefire(var/mob/M)
	var/temp = 3000
	var/range = 1

	var/turf/T = get_step(M,M.dir)
	T = get_step(T,M.dir)
	var/list/affected_turfs = getline(M, T)

	M.visible_message("<span class='alert'><b>[M] burps a stream of fire!</b></span>")
	playsound(M.loc, "sound/effects/mag_fireballlaunch.ogg", 30, 0)

	var/turf/currentturf
	var/turf/previousturf
	for(var/turf/F in affected_turfs)
		previousturf = currentturf
		currentturf = F
		if(currentturf.density || istype(currentturf, /turf/space))
			break
		if(previousturf && LinkBlocked(previousturf, currentturf))
			break
		if (F == get_turf(M))
			continue
		if (get_dist(M,F) > range)
			continue
		tfireflash(F,1,temp)
