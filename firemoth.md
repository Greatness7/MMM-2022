# Project Firemoth

## Index

1. Introduction
    * Members
    * Overview
    * Dependencies
2. Story
    * Characters
    * Quest
3. Visuals
    * Island
	* Fort
    * Ebony Mine
    * Velothi Tomb
4. Gameplay
    * Enemies
	* Hazards
	* The Curse of Rot
    * Fort Management

## 1 - Introduction

### Members

* Greatness7 - Assets, Exterior Design
* Remiros - Assets, Interior Design, Writing/Quest Design(?)
* Ohayo - Writing, Scripting(?)
* Sephumbra - Scripting (Gameplay), Writing/Quest Design(?)
* Safebox - Scripting (Visuals), Shaders

### Overview

The scope of the mod will be an overhaul of the Firemoth DLC originally developed by Bethesda. This encompasses a complete recreation of all associated content.
It is split into 4 distinct areas: The island, the fort, the ebony mine and the velothi tomb/dungeon. More details on each section will be provided throughout this document.
The fort will be rebuilt at the end of the quest and be placed under the players care, offering up new gameplay mechanics for the player to engage with.

### Dependencies

The project will use MGE XE, MWSE Lua scripting, as well as assets found in OAAB and TD. Users are required to have these installed in order for the mod to work.

## 2 - Story

### Characters

#### Grurn

The antagonist and main threat. A powerful mage, specialized in necromancy and illusion magic. Was buried in a velothi tomb, which was uncovered during digging operations in the ebony mine of the fort. Has now taken over the entire fort and mine with an army of undead. The velothi tomb is his main base of operations.

#### Sellus Gravius

A vanilla NPC. Will act as a gatekeeper to the mod and its quest content. Quest reward will also be given by this NPC.

#### Aronil

An Altmer mercenary hired by the Imperial Legion to help reclaim Fort Firemoth. A very powerful mage from the Summerset Isles. Wears a robe and some magic scrolls/items and a unique enchanted staff. Specialized in destruction and illusion magic. Will later die when attempting to open the seal (with a special scroll he carries with him) protecting the velothi tomb that Grurn resides in, if not previously killed.

#### Hjrondir

A Nord mercenary hired by the Imperial Legion to help reclaim Fort Firemoth. A very powerful fighter wielding a unique silver war axe and regular steel armor with bracers. Will go insane and attack the player during the expedition into the velothi tomb, if not previously killed.

#### Mara Varius

An imperial lower ranking member of the Imperial Legion sent to help reclaim Fort Firemoth. As a former Imperial Cult priestess she is specialized in healing and holy (Turn Undead) magic. Wears regular heavy imperial legion armor with a shield and mace. Can become a companion/underling if she survives the entire quest chain and you return to Sellus Gravius.

#### Lexion Pontius

A member of the EEC tasked with the rebuild and management of Fort Firemoth along with the player. Can be found inside the rebuilt Fort. Acts as a host for the Fort Management gameplay section.

## Quest

The quest can be started by reading a report in Sellus Gravius office regarding Fort Firemoth.
Afterwards, the player can ask Sellus Gravius about Fort Firemoth, as long as he has reached Champion rank (4) within the imperial legion.
He will refuse to disclose details and start the quest otherwise.
Talking to him about Fort Firemoth reveals that it has been overrun by the undead and a specialist team consisting of Aronil, Hyrondir and Mara Varius has been formed to purge the undead threat from the island.
Sellus Gravius was supposed to lead the charge, but will request your aid instead.

After teaming up with the rest of the party the player takes a boat to head to the island, where they will proceed to retake the island before heading into the ebony mines of the fort.
Upon reaching the entrance of the velothi tomb at the end of the mines Aronil will attempt to unlock the seal protecting the entrance with a special scroll he has prepared beforehand.
Upon using it the seal will be broken, Aronil dies and all remaining members will be afflicted by a curse.
If Aronil dies beforehand the player is required to break the seal with the scroll found on his body instead.
The player will not die doing this, but still get afflicted by the curse.

Once entering the velothi tomb the difficulty will increase a lot, so the player might not be able to get rid of the curse by killing Grurn immediately and needs to deal with its effects.
Throughout it the player is tasked with solving multiple puzzles or illusions in order to advance.
A shade of Grurn (Strongly weakened version of Grurn) will randomly spawn throughout the dungeon and attack the party.
The player can decide to never engage this threat without failing the quest.
In one room Hyrondir will talk to the player, babbling paranoid nonsense and going insane. He will then attack the player and Mara Varius.
A later room will have the player fight an illusionary copy of Mara Varius.
The player is not aware of this and will only realize this after the room has left and Mara is still with them.
Talking to her will reveal that she had no idea what is going on and will be concerned about you going insane too.

Upon reaching the final room where Grurn resides the party is forced to fight.
The player must find the phylactery (Stated in an optional note found in the ebony mine from a previous team sent to purge the undead) before being able to damage Grurn.
The Ward of Akavir can be found within the room (?).
Killing him will free the player and Mara Varius (If alive) of the curse and they can return to Sellus Gravius to complete the quest.

Upon completing the quest Sellus Gravius places Mara Varius (If alive) under your command, making her a permanent companion.
If the player has the rank of Knight Protector (7) within the legion Sellus Gravius will have an additional reward available: Rebuilding and managing Fort Firemoth and its ebony mine.

Rebuilding the fort to its basic form will only consist of being informed that they cooperated with the EEC to shore up reconstruction costs and waiting a week (?).
Once rebuilt the quest can be completed by talking to Sellus Gravius once more, referring you to Lexion Pontius inside the rebuilt Fort. The legion can't expend any more forces to protect the Fort so its up to the player to hire Mercenaries to do this.
The player is now free to manage the fort and the ebony mine with the help of the EEC on the island as stated under the corresponding gameplay section.

## 3 - Visuals

The overall color palette for the environments of this mod will be grey/green, with some exceptions stated further below.

### Island

- [ ] Approaching Fort Firemoth, the sky should take on a dark tone with a slight green tint
- [x] Shaders will be used to change the sky and water colors (if possible).

Further details need to be filled in.

### Fort

The fort will be expanded to include a large dock for shipping and housing for workers and mercenaries.

Further details need to be filled in.

### Ebony Mine

Will contain a large industrial imperial ebony mine with corpses of former miners and parties that failed to break through to the tomb.
Pools of lava may also be found, perhaps a heatwave shader could be used here?

Further details need to be filled in.

### Velothi Tomb

The player may find themselves in various situation throughout the dungeon where trickery or illusion magic is at work.
During those a screen-space shader (perhaps a slight distortion effect) should be used to indicate that things might not be right.

Further details need to be filled in.

## 4 - Gameplay

### Enemies

#### Grurn

Grurn is the main boss at the deepest part of the velothi dungeon.
Has a large selection of illusion and destruction spells, as well as summoning spells.
Will be invincible unless the player finds the phylactery hidden within the room.
Has a artifact level staff equipped.

#### Shade of Grurn

Occasionally, a Shade of Grurn will spawn when the player is affected by the curse.
This will be done at random through scripting, with larger periods between them.
These shades will roughly resembly a much weaker version of Grurn with a limited set of magic.

Further enemies need to be filled in.

### The Curse of Rot

The player will suffer from a permanent curse (ability) when opening the seal on the door to the velothi tomb.
The curse lowers the players attributes and has a permanent 1 point per second magicka/fatigue damage (Done through lua to avoid visual magic effects).
While affected by the curse Shades of Grurn can spawn at any time around the player.
The player will sometimes see shades of random NPCs throughout the world that they cant interact with and that will not do anything.
The players equipped weapons and armor will very slowly degrade over time.
The players vision will rarely get a bit blurry for a short period of time, while also hearing whispering (To indicate insanity).

### Hazards

Throughout the velothi tomb various hazards will be introduced, including endless skeleton spawners (which can be disabled), corridors, a player clone fight, gas chambers, illusionary chambers where the player needs to kill their companions and more.

Further details need to be filled in.

### Fort Management

Upon completing the quest the player can talk to Lexion Pontius to manage the fort.
This includes upgrading/changing various sets of furnite/banners etc. throughout the fort, as well as managing Miners and Mercenaries used to extract/protect and ship the ebony.

Further details coming soon.
