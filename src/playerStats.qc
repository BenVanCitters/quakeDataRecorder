// this stat/analytics tracking package is intended to mostly work as a drop-in package for a given mod/addon
// the idea is that tracked variables are added to the entity structure here and are modified only in functions
// the functions have a variable level of understanding of the game itself - some functions know that armor for
// instance has three distinct item types - so in a sense the code in this file can't live completely in
// isolation from the game code
// The main intention is to provide very simple code hooks outside of this grouping of functions and variables
// so that all that needs to happen to record something like damage is one line of code added in the 
// game logic
//
// This file is intended to be the only place where the records are actually touched (even if it can't be enforced)
// and also where the values can be displayed
//
// because there is no way in the supported quake c for the quake remaster to create new structures or 'objects'
// the means for recording are fairly limited - in addition there is a cap on the total number entities that can
// exist at once in a game - ~8129 - which although large is too few to use individual entities for event capture
// when there might be 16+ players continuously shooting at each other for hours at a stretch
//
// -Ben Van Citters AKA teamred (Dec 31 2021)

.float distance_travelled; // how far the player walked, moved, jumped, teleported...
.float times_died; // death count
.float kills; //number of kills
.float alive_time; //how long the player was alive
.float water_time; //time under water

//amount of ammo collected
.float shells_collected;
.float nails_collected;
.float rockets_collected;
.float cells_collected;

//duration the player held powerups
.float quad_time;
.float ring_time;
.float pent_time;

//number of times power ups collected
.float ring_collected;
.float quads_collected;
.float pent_collected;
.float super_health_collected;

//total points of healing collected
.float health_collected;

//number of times each armor was collected
.float green_armors_collected;
.float yellow_armors_collected;
.float red_armors_collected;

//damage dealt with each weapon
.float axe_damage_dealt;
.float shotgun_damage_dealt;
.float sshotgun_damage_dealt;
.float nailgun_damage_dealt;
.float snailgun_damage_dealt;
.float grenade_damage_dealt;
.float rocket_damage_dealt;
.float lightning_damage_dealt;

//damage received from each weapon
.float axe_damage_taken;
.float shotgun_damage_taken;
.float sshotgun_damage_taken;
.float nailgun_damage_taken;
.float snailgun_damage_taken;
.float grenade_damage_taken;
.float rocket_damage_taken;
.float lightning_damage_taken;

//the world, falling, smashing
.float other_damage_taken;

//number of times the player fired their weapon
.float axe_shots_fired;
.float shotgun_shots_fired;
.float sshotgun_shots_fired;
.float nailgun_shots_fired;
.float snailgun_shots_fired;
.float grenade_shots_fired;
.float rocket_shots_fired;
.float lightning_shots_fired;

//how many hits
.float axe_shots_hits;
.float shotgun_shots_hits;
.float sshotgun_shots_hits;
.float nailgun_shots_hits;
.float snailgun_shots_hits;
.float grenade_shots_hits;
.float rocket_shots_hits;
.float lightning_shots_hits;

//length of time weapon is out
.float axe_time;
.float shotgun_time;
.float sshotgun_time;
.float nailgun_time;
.float snailgun_time;
.float grenade_time;
.float rocket_time;
.float lightning_time;

//the statcontroller itself
.entity statsController;



//picked up armor item
void(entity statsController, entity item) record_stat_pickedUpArmor=
{
	if(item.items == IT_ARMOR1)//green
	{ statsController.green_armors_collected = statsController.green_armors_collected  + 1; }
	else if (item.items == IT_ARMOR2)//yellow
	{statsController.yellow_armors_collected = statsController.yellow_armors_collected + 1; }
	else if (item.items == IT_ARMOR3)//red
	{statsController.red_armors_collected = statsController.red_armors_collected + 1;}
}

// increase alive timer
void(entity statsController, float duration) record_stat_addAliveTime=
{	
	if(statsController.owner.deadflag == DEAD_NO)
	{
		statsController.alive_time = statsController.alive_time + duration;
	}
}

//increase water timer
void(entity statsController, float duration) record_stat_addWaterTime=
{	
	if(statsController.owner.deadflag == DEAD_NO && statsController.owner.flags & FL_INWATER)
	{
		statsController.water_time = statsController.water_time + duration;
	}
}

//increase powerup timers
void(entity statsController, float duration) record_stat_addPowerUpTime=
{	
	if(statsController.owner.deadflag == DEAD_NO)
	{
		if(statsController.owner.invincible_finished > time)
		{statsController.pent_time = statsController.pent_time + duration;}
		if(statsController.owner.invisible_finished > time)
		{statsController.ring_time = statsController.ring_time + duration;}
		if(statsController.owner.super_damage_finished > time)
		{statsController.quad_time = statsController.quad_time + duration;}		
	}
}

.float healtype; //defined later in items.qc
// increment power up counters
void(entity statsController, entity item) record_stat_pickedUpPowerUp=
{
	if(item.healtype == 2)//superhealth
	{ statsController.super_health_collected = statsController.super_health_collected  + 1; }

	else if (self.classname == "item_artifact_invulnerability")
	{statsController.pent_collected = statsController.pent_collected + 1; }

	else if (self.classname == "item_artifact_invisibility")
	{statsController.ring_collected = statsController.ring_collected + 1;}

	else if (self.classname == "item_artifact_super_damage")
	{statsController.quads_collected = statsController.quads_collected + 1;}
}


//picked up health
void(entity statsController, float heal_amt) record_stat_pickedUpHealth=
{
	statsController.health_collected = statsController.health_collected  + heal_amt;
}


//picked up ammo
void(entity statsController, float shells, float nails, float rockets, float cells) record_stat_pickedUpAmmo=
{
	statsController.shells_collected = statsController.shells_collected  + shells;
	statsController.nails_collected = statsController.nails_collected +nails;
	statsController.rockets_collected = statsController.rockets_collected + rockets;
	statsController.cells_collected = statsController.cells_collected + cells;
}

// player successfully hit something with a weapon
void(entity statsController) record_stat_addWeaponHit=
{
	if (statsController.owner.weapon == IT_AXE)
	{ statsController.axe_shots_hits = statsController.axe_shots_hits + 1; }
	else if (statsController.owner.weapon == IT_SHOTGUN)
	{ statsController.shotgun_shots_hits = statsController.shotgun_shots_hits + 1; }
	else if (statsController.owner.weapon == IT_SUPER_SHOTGUN)
	{ statsController.sshotgun_shots_hits = statsController.sshotgun_shots_hits + 1; }
	else if (statsController.owner.weapon == IT_NAILGUN)
	{ statsController.nailgun_shots_hits = statsController.nailgun_shots_hits + 1; }
	else if (statsController.owner.weapon == IT_SUPER_NAILGUN)
	{ statsController.snailgun_shots_hits = statsController.snailgun_shots_hits + 1; }
	else if (statsController.owner.weapon == IT_GRENADE_LAUNCHER)
	{ statsController.grenade_shots_hits = statsController.grenade_shots_hits + 1; }
	else if (statsController.owner.weapon == IT_ROCKET_LAUNCHER)
	{ statsController.rocket_shots_hits = statsController.rocket_shots_hits + 1; }
	else if (statsController.owner.weapon == IT_LIGHTNING)
	{ statsController.lightning_shots_hits = statsController.lightning_shots_hits  + 1; }
}

// add up all different kinds of hits
float(entity statsController) record_stat_getTotalHits=
{
	return statsController.axe_shots_hits + statsController.shotgun_shots_hits + statsController.sshotgun_shots_hits + 
	statsController.nailgun_shots_hits + statsController.snailgun_shots_hits + statsController.grenade_shots_hits + 
	statsController.rocket_shots_hits +  statsController.lightning_shots_hits;
}

void(entity statsController, float duration) record_stat_addWeaponTime=
{
	if (statsController.owner.weapon == IT_AXE)
	{ statsController.axe_time = statsController.axe_time + duration; }
	else if (statsController.owner.weapon == IT_SHOTGUN)
	{ statsController.shotgun_time = statsController.shotgun_time + duration; }
	else if (statsController.owner.weapon == IT_SUPER_SHOTGUN)
	{ statsController.sshotgun_time = statsController.sshotgun_time + duration; }
	else if (statsController.owner.weapon == IT_NAILGUN)
	{ statsController.nailgun_time = statsController.nailgun_time + duration; }
	else if (statsController.owner.weapon == IT_SUPER_NAILGUN)
	{ statsController.snailgun_time = statsController.snailgun_time + duration; }
	else if (statsController.owner.weapon == IT_GRENADE_LAUNCHER)
	{ statsController.grenade_time = statsController.grenade_time + duration; }
	else if (statsController.owner.weapon == IT_ROCKET_LAUNCHER)
	{ statsController.rocket_time = statsController.rocket_time + duration; }
	else if (statsController.owner.weapon == IT_LIGHTNING)
	{ statsController.lightning_time = statsController.lightning_time + duration; }
}

float(entity statsController) record_stat_getTotalShotsFired=
{
	return statsController.axe_shots_fired + statsController.shotgun_shots_fired + statsController.sshotgun_shots_fired + 
	 statsController.nailgun_shots_fired + statsController.snailgun_shots_fired + statsController.grenade_shots_fired + 
	  statsController.rocket_shots_fired + statsController.lightning_shots_fired; 
}

void(entity statsController) record_stat_recordShotFired=
{
	if (statsController.owner.weapon == IT_AXE)
	{ statsController.axe_shots_fired = statsController.axe_shots_fired  + 1; }
	else if (statsController.owner.weapon == IT_SHOTGUN)
	{ statsController.shotgun_shots_fired = statsController.shotgun_shots_fired  + 1; }
	else if (statsController.owner.weapon == IT_SUPER_SHOTGUN)
	{ statsController.sshotgun_shots_fired = statsController.sshotgun_shots_fired  + 1; }
	else if (statsController.owner.weapon == IT_NAILGUN)
	{ statsController.nailgun_shots_fired = statsController.nailgun_shots_fired  + 1; }
	else if (statsController.owner.weapon == IT_SUPER_NAILGUN)
	{ statsController.snailgun_shots_fired = statsController.snailgun_shots_fired  + 1; }
	else if (statsController.owner.weapon == IT_GRENADE_LAUNCHER)
	{ statsController.grenade_shots_fired = statsController.grenade_shots_fired  + 1; }
	else if (statsController.owner.weapon == IT_ROCKET_LAUNCHER)
	{ statsController.rocket_shots_fired = statsController.rocket_shots_fired  + 1; }
	else if (statsController.owner.weapon == IT_LIGHTNING)
	{ statsController.lightning_shots_fired = statsController.lightning_shots_fired  + 1; }
}

//owner was killed by something
void(entity statsController) record_stat_recordDied=
{
	statsController.times_died = statsController.times_died  + 1;
}

//owner killed something
void(entity statsController) record_stat_recordKill=
{
	statsController.kills = statsController.kills  + 1;
}


//this damage might happen after the player already changed waepons 
void(entity statsController, float dmg, entity inflictor) recordDelayedDamageDealt=
{
	//sprint(statsController.owner, "dmg del: ");
	//sprint(statsController.owner, ftos(dmg));
	//sprint(statsController.owner, " -  ");
	//sprint(statsController.owner, inflictor.classname);
	//sprint(statsController.owner, "\n");
	if (inflictor.model == "progs/spike.mdl")//nailgun
	{ statsController.nailgun_damage_dealt = statsController.nailgun_damage_dealt  + dmg; }
	else if (inflictor.model == "progs/s_spike.mdl")//super nailgun
	{ statsController.snailgun_damage_dealt = statsController.snailgun_damage_dealt  + dmg; }
	else if (inflictor.classname == "grenade")
	{ statsController.grenade_damage_dealt = statsController.grenade_damage_dealt  + dmg; }
	else if (inflictor.classname == "missile")
	{ statsController.rocket_damage_dealt = statsController.rocket_damage_dealt  + dmg; }
}

//this damage we can be pretty sure about the weapon causing it
void(entity statsController, float dmg) recordDamageDealt=
{
	if (statsController.owner.weapon == IT_AXE)
	{ statsController.axe_damage_dealt = statsController.axe_damage_dealt  + dmg; }
	else if (statsController.owner.weapon == IT_SHOTGUN)
	{ statsController.shotgun_damage_dealt = statsController.shotgun_damage_dealt  + dmg; }
	else if (statsController.owner.weapon == IT_SUPER_SHOTGUN)
	{ statsController.sshotgun_damage_dealt = statsController.sshotgun_damage_dealt  + dmg; }
	else if (statsController.owner.weapon == IT_LIGHTNING)
	{ statsController.lightning_damage_dealt = statsController.lightning_damage_dealt  + dmg; }

}

//received damage later - from a rocket or something - maybe the player changed weapons since
void(entity statsController, float dmg, entity inflictor) recordDelayedDamageReceived=
{

	if (inflictor.model == "progs/spike.mdl")//nailgun
	{ statsController.nailgun_damage_taken = statsController.nailgun_damage_taken  + dmg; }
	else if (inflictor.model == "progs/s_spike.mdl")//super nailgun
	{ statsController.snailgun_damage_taken = statsController.snailgun_damage_taken + dmg; }
	else if (inflictor.classname == "grenade")
	{ statsController.grenade_damage_taken = statsController.grenade_damage_taken  + dmg; }
	else if (inflictor.classname == "missile")
	{ statsController.rocket_damage_taken = statsController.rocket_damage_taken  + dmg; }
	else
	{ statsController.other_damage_taken = statsController.other_damage_taken + dmg; }
	

	//statsController.damage_taken = statsController.damage_taken + dmg;
}

//received damage right away
void(entity statsController, float dmg, entity dealer) recordDamageReceived=
{
	if(dealer.classname == "player")
	{
		if (dealer.weapon == IT_AXE)
		{ statsController.axe_damage_taken = statsController.axe_damage_taken  + dmg; }
		else if (dealer.weapon == IT_SHOTGUN)
		{ statsController.shotgun_damage_taken = statsController.shotgun_damage_taken  + dmg; }
		else if (dealer.weapon == IT_SUPER_SHOTGUN)
		{ statsController.sshotgun_damage_taken = statsController.sshotgun_damage_taken  + dmg; }
		else if (dealer.weapon == IT_LIGHTNING)
		{ statsController.lightning_damage_taken = statsController.lightning_damage_taken  + dmg; }
	}
	else
	{
		statsController.other_damage_taken = statsController.other_damage_taken + dmg;
	}

	//statsController.damage_taken = statsController.damage_taken + dmg;
}

void(entity statsController, float distance) record_stat_addDistance=
{
	statsController.distance_travelled = statsController.distance_travelled + distance;
}




//====================================
//Helper Functions
//====================================
float(entity statsController) getTotalDamageDealt=
{
	return statsController.axe_damage_dealt+
		statsController.shotgun_damage_dealt+
		statsController.sshotgun_damage_dealt+
		statsController.nailgun_damage_dealt+
		statsController.snailgun_damage_dealt+
		statsController.grenade_damage_dealt+
		statsController.rocket_damage_dealt+
		statsController.lightning_damage_dealt;
}

float(entity statsController) getTotalDamageReceived=
{
	return statsController.axe_damage_taken+
		statsController.shotgun_damage_taken+
		statsController.sshotgun_damage_taken+
		statsController.nailgun_damage_taken+
		statsController.snailgun_damage_taken+
		statsController.grenade_damage_taken+
		statsController.rocket_damage_taken+
		statsController.other_damage_taken+
		statsController.lightning_damage_taken;
}

float(entity statsController) getTotalShotsFired=
{
	return statsController.axe_shots_fired + 
		statsController.shotgun_shots_fired+
		statsController.sshotgun_shots_fired+
		statsController.nailgun_shots_fired+
		statsController.snailgun_shots_fired+
		statsController.grenade_shots_fired+
		statsController.rocket_shots_fired+
		statsController.lightning_shots_fired;
}


float(entity statsController) getTotalShotsHit=
{
	return statsController.axe_shots_hits+
		statsController.shotgun_shots_hits+
		statsController.sshotgun_shots_hits+
		statsController.nailgun_shots_hits+
		statsController.snailgun_shots_hits+
		statsController.grenade_shots_hits+
		statsController.rocket_shots_hits+
		statsController.lightning_shots_hits;
}





//====================================
//Print Functions
//====================================

//show armor details
void() printArmorPickups=
{
	sprint(self.owner,", armor pickup count G/Y/R:"); 
	sprint(self.owner,ftos( self.green_armors_collected )); sprint(self.owner,"/"); 
	sprint(self.owner,ftos( self.yellow_armors_collected )); sprint(self.owner,"/"); 
	sprint(self.owner,ftos( self.red_armors_collected )); 
}

//powerup details
void() printPowerUps=
{
	sprint(self.owner,", powerup count/times quad:"); sprint(self.owner,ftos( self.quads_collected )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.quad_time )); 
			   sprint(self.owner," ring:"); sprint(self.owner,ftos( self.ring_collected ));  sprint(self.owner,"/"); sprint(self.owner,ftos( self.ring_time )); 
			   sprint(self.owner," pent:"); sprint(self.owner,ftos( self.pent_collected ));  sprint(self.owner,"/"); sprint(self.owner,ftos( self.pent_time )); 
			   sprint(self.owner," 100H:"); sprint(self.owner,ftos( self.super_health_collected ));
}

//per-weapon damage
void() printPerWeaponDmg=
{
	sprint(self.owner,", dmg g/r a:"); sprint(self.owner,ftos( self.axe_damage_dealt )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.axe_damage_taken ));
	sprint(self.owner," s:"); sprint(self.owner,ftos( self.shotgun_damage_dealt ));  sprint(self.owner,"/"); sprint(self.owner,ftos( self.shotgun_damage_taken ));
	sprint(self.owner," ss:"); sprint(self.owner,ftos( self.sshotgun_damage_dealt )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.sshotgun_damage_taken ));
	sprint(self.owner," n:"); sprint(self.owner,ftos( self.nailgun_damage_dealt )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.nailgun_damage_taken ));
	sprint(self.owner," sn:"); sprint(self.owner,ftos( self.snailgun_damage_dealt )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.snailgun_damage_taken ));
	sprint(self.owner," g:"); sprint(self.owner,ftos( self.grenade_damage_dealt )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.grenade_damage_taken ));
	sprint(self.owner," r:"); sprint(self.owner,ftos( self.rocket_damage_dealt )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.rocket_damage_taken ));
	sprint(self.owner," l:"); sprint(self.owner,ftos( self.lightning_damage_dealt )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.lightning_damage_taken ));
	sprint(self.owner," ?:"); sprint(self.owner,ftos( self.other_damage_taken )); //other types of damage?? mosters, world, etc
}

// how long player has had weapon out
void() printWeaponTimes=
{	  
	sprint(self.owner,", weapon hold times a:"); sprint(self.owner,ftos( self.axe_time )); 
	sprint(self.owner," s:"); sprint(self.owner,ftos( self.shotgun_time )); 
	sprint(self.owner," ss:"); sprint(self.owner,ftos( self.sshotgun_time )); 
	sprint(self.owner," n:"); sprint(self.owner,ftos( self.nailgun_time )); 
	sprint(self.owner," sn:"); sprint(self.owner,ftos( self.snailgun_time )); 
	sprint(self.owner," g:"); sprint(self.owner,ftos( self.grenade_time )); 
	sprint(self.owner," r:"); sprint(self.owner,ftos( self.rocket_time )); 
	sprint(self.owner," l:"); sprint(self.owner,ftos( self.lightning_time )); 
}

//how many armor pick ups
void() printAmmoPickUps=
{	  
	sprint(self.owner,", ammo pick ups s:"); sprint(self.owner,ftos( self.shells_collected )); 	
	sprint(self.owner," n:"); sprint(self.owner,ftos( self.nails_collected )); 	
	sprint(self.owner," r:"); sprint(self.owner,ftos( self.rockets_collected )); 
	sprint(self.owner," c:"); sprint(self.owner,ftos( self.cells_collected )); 
}

//hit and missed
void() printHitsMisses=
{	  
	sprint(self.owner,", hits a:"); sprint(self.owner,ftos( self.axe_shots_hits )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.axe_shots_fired ));
	sprint(self.owner," s: "); sprint(self.owner,ftos( self.shotgun_shots_hits ));  sprint(self.owner,"/"); sprint(self.owner,ftos( self.shotgun_shots_fired ));
	sprint(self.owner," ss: "); sprint(self.owner,ftos( self.sshotgun_shots_hits )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.sshotgun_shots_fired ));
	sprint(self.owner," n: "); sprint(self.owner,ftos( self.nailgun_shots_hits )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.nailgun_shots_fired ));
	sprint(self.owner," sn: "); sprint(self.owner,ftos( self.snailgun_shots_hits )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.snailgun_shots_fired ));
	sprint(self.owner," g: "); sprint(self.owner,ftos( self.grenade_shots_hits )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.grenade_shots_fired ));
	sprint(self.owner," r: "); sprint(self.owner,ftos( self.rocket_shots_hits )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.rocket_shots_fired ));
	sprint(self.owner," l: "); sprint(self.owner,ftos( self.lightning_shots_hits )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.lightning_shots_fired ));
}

//show total health collected
void() printHealthCollected=
{
	sprint(self.owner,"health collected: ");
	sprint(self.owner,ftos(self.health_collected));
}

//various
void() printMisc=
{
	sprint(self.owner,"K/D: ");
	sprint(self.owner,ftos(self.kills));
	sprint(self.owner,"/");
	sprint(self.owner,ftos(self.times_died));
	sprint(self.owner," dist: ");
	sprint(self.owner,ftos( self.distance_travelled ));
	sprint(self.owner,", watertm:"); sprint(self.owner,ftos( self.water_time ));
	sprint(self.owner,", livetm:"); sprint(self.owner,ftos( self.alive_time ));		
}

void() printAll=
{
	sprint(self.owner,"Player Report:");
	sprint(self.owner, self.owner.netname);
	sprint(self.owner,"\n==================\n");
	sprint(self.owner,"\n");
	printArmorPickups();
	printPowerUps();
	printPerWeaponDmg();
	printWeaponTimes();
	printAmmoPickUps();
	printHitsMisses();
	printHealthCollected();
	printMisc();
	sprint(self.owner,"\n");
}

//div by zero protection
string(float hits,float shots) getAcu=
{
	local float result = 0.0001;
	if(shots > 0)
		result = result + hits/shots;
	
	return ftos(100*result);
}

string(float val) spacedfloat=
{
	local float result = val + 0.0001;		
	return ftos(result);
}

string(float val) roundedStr=
{
	local float result = floor(val);
	return ftos(result);
}


void() printLine12=
{
local float msg_type = MSG_ONE;
	msg_entity = self.owner;
	WriteByte(msg_type,SVC_PRINT); // SVC_CENTERPRINT	
	//WriteByte(msg_type,SVC_CENTERPRINT); // SVC_PRINT	
	WriteShort(msg_type,1); // '3' is the number of writestrings including args
	WriteString(msg_type,"           Axe   S   SS   NG    SSN   GL   RL   LG\n         =========================================\n");//%{}%{}%{}%{}%{}%{}%{}%{}%\ntime     {}{}{}{} {}{}{}{}\ndmg taken{} {} {} {} {} {} {} {}\ndmg done {} {} {} {} {} {} {} {}\ntotal shells: {} nails: {} rockets: {} cells: {} \n\n                Quad  Ring  Pent  Mega            \n               ========================           \npowerup count: {} {} {} {}            \npoweruptime:   {} {} {}                  \n\nk/d ratio:{}/{}  avg life time: {}            \nkills per minute: {}                                        \n\ndist travelled: {}      Water time: {}      \ndmg ratio:      {} = {}/{}             \n");
}
void() printLine23=
{
	local float msg_type = MSG_ONE;
	msg_entity = self.owner;
	WriteByte(msg_type,SVC_PRINT); // SVC_CENTERPRINT	
	//WriteByte(msg_type,SVC_CENTERPRINT); // SVC_PRINT	
	WriteShort(msg_type,17); // '3' is the number of writestrings including args
	WriteString(msg_type,"%{}%{}%{}%{}%{}%{}%{}%{}%\ntime     {}{}{}{} {}{}{}{}\n");//dmg taken{} {} {} {} {} {} {} {}\ndmg done {} {} {} {} {} {} {} {}\ntotal shells: {} nails: {} rockets: {} cells: {} \n\n                Quad  Ring  Pent  Mega            \n               ========================           \npowerup count: {} {} {} {}            \npoweruptime:   {} {} {}                  \n\nk/d ratio:{}/{}  avg life time: {}            \nkills per minute: {}                                        \n\ndist travelled: {}      Water time: {}      \ndmg ratio:      {} = {}/{}             \n");

	//accuracy
	WriteString(msg_type, getAcu(self.axe_shots_hits, self.axe_shots_fired) );//axe
	WriteString(msg_type, getAcu(self.shotgun_shots_hits, self.shotgun_shots_fired) );//shotgun
	WriteString(msg_type, getAcu(self.sshotgun_shots_hits, self.sshotgun_shots_fired) );//dbl shot
	WriteString(msg_type, getAcu(self.nailgun_shots_hits, self.nailgun_shots_fired) );//nail
	WriteString(msg_type, getAcu(self.snailgun_shots_hits, self.snailgun_shots_fired) );//super nail
	WriteString(msg_type, getAcu(self.grenade_shots_hits, self.grenade_shots_fired) );//grenade
	WriteString(msg_type, getAcu(self.rocket_shots_hits, self.rocket_shots_fired) );//rock
	WriteString(msg_type, getAcu(self.lightning_shots_hits, self.lightning_shots_fired) );//lightning
		//time
	WriteString(msg_type,spacedfloat( self.axe_time ));//axe
	WriteString(msg_type,spacedfloat(self.shotgun_time));//shotgun
	WriteString(msg_type,spacedfloat(self.sshotgun_time));//dbl shot
	WriteString(msg_type,spacedfloat(self.nailgun_time));//nail
	WriteString(msg_type,spacedfloat(self.snailgun_time));//super nail
	WriteString(msg_type,spacedfloat(self.grenade_time));//grenade
	WriteString(msg_type,spacedfloat(self.rocket_time));//rock
	WriteString(msg_type,spacedfloat(self.lightning_time));//lightning
	//dmg taken
}

void() printLine45=
{
	local float msg_type = MSG_ONE;
	msg_entity = self.owner;
	WriteByte(msg_type,SVC_PRINT); // SVC_CENTERPRINT	
	//WriteByte(msg_type,SVC_CENTERPRINT); // SVC_PRINT	
	WriteShort(msg_type,17); // '3' is the number of writestrings including args
	WriteString(msg_type,"dmg taken{} {} {} {} {} {} {} {}\ndmg done {} {} {} {} {} {} {} {}\n");//total shells: {} nails: {} rockets: {} cells: {} \n\n                Quad  Ring  Pent  Mega            \n               ========================           \npowerup count: {} {} {} {}            \npoweruptime:   {} {} {}                  \n\nk/d ratio:{}/{}  avg life time: {}            \nkills per minute: {}                                        \n\ndist travelled: {}      Water time: {}      \ndmg ratio:      {} = {}/{}             \n");
	//dmg taken
	WriteString(msg_type,roundedStr(self.axe_damage_taken));//axe
	WriteString(msg_type,roundedStr(self.shotgun_damage_taken));//shotgun
	WriteString(msg_type,roundedStr(self.sshotgun_damage_taken));//dbl shot
	WriteString(msg_type,roundedStr(self.nailgun_damage_taken));//nail
	WriteString(msg_type,roundedStr(self.snailgun_damage_taken));//super nail
	WriteString(msg_type,roundedStr(self.grenade_damage_taken));//grenade
	WriteString(msg_type,roundedStr(self.rocket_damage_taken));//rock
	WriteString(msg_type,roundedStr(self.lightning_damage_taken));//lightning
	//dmg done
	WriteString(msg_type,roundedStr(self.axe_damage_dealt));//axe
	WriteString(msg_type,roundedStr(self.shotgun_damage_dealt));//shotgun
	WriteString(msg_type,roundedStr(self.sshotgun_damage_dealt));//dbl shot
	WriteString(msg_type,roundedStr(self.nailgun_damage_dealt));//nail
	WriteString(msg_type,roundedStr(self.snailgun_damage_dealt));//super nail
	WriteString(msg_type,roundedStr(self.grenade_damage_dealt));//grenade
	WriteString(msg_type,roundedStr(self.rocket_damage_dealt));//rock
	WriteString(msg_type,roundedStr(self.lightning_damage_dealt));//lightning
}



void() printLine69=
{
	local float msg_type = MSG_ONE;
	msg_entity = self.owner;
	WriteByte(msg_type,SVC_PRINT); // SVC_CENTERPRINT	
	//WriteByte(msg_type,SVC_CENTERPRINT); // SVC_PRINT	
	WriteShort(msg_type,5); // '3' is the number of writestrings including args
	WriteString(msg_type,"total shells: {} nails: {} rockets: {} cells: {} \n\n                Quad  Ring  Pent  Mega            \n               ========================           \n");//powerup count: {} {} {} {}            \npoweruptime:   {} {} {}                  \n\nk/d ratio:{}/{}  avg life time: {}            \nkills per minute: {}                                        \n\ndist travelled: {}      Water time: {}      \ndmg ratio:      {} = {}/{}             \n");

//ammo
	WriteString(msg_type,roundedStr(self.shells_collected));//dbl shot
	WriteString(msg_type,roundedStr(self.nails_collected));//nail
	WriteString(msg_type,roundedStr(self.rockets_collected));//rock
	WriteString(msg_type,roundedStr(self.cells_collected));//lightning
}


void() printLine10_12=
{
	local float msg_type = MSG_ONE;
	msg_entity = self.owner;
	WriteByte(msg_type,SVC_PRINT); // SVC_CENTERPRINT	
	//WriteByte(msg_type,SVC_CENTERPRINT); // SVC_PRINT	
	WriteShort(msg_type,8); // '3' is the number of writestrings including args
	WriteString(msg_type,"powerup count: {} {} {} {}            \npoweruptime:   {} {} {}                  \n\n");//k/d ratio:{}/{}  avg life time: {}            \nkills per minute: {}                                        \n\ndist travelled: {}      Water time: {}      \ndmg ratio:      {} = {}/{}             \n");

	//powerups
	//count
	WriteString(msg_type,roundedStr(self.quads_collected));//quad
	WriteString(msg_type,roundedStr(self.ring_collected));//ring
	WriteString(msg_type,roundedStr(self.pent_collected));//pent
	WriteString(msg_type,roundedStr(self.super_health_collected));//mega
	
	//time	
	WriteString(msg_type,spacedfloat(self.quad_time));//quad
	WriteString(msg_type,spacedfloat(self.ring_time));//ring
	WriteString(msg_type,spacedfloat(self.pent_time));//pent
}


void() printLine13_14=
{
	local float msg_type = MSG_ONE;
	msg_entity = self.owner;
	WriteByte(msg_type,SVC_PRINT); // SVC_CENTERPRINT	
	//WriteByte(msg_type,SVC_CENTERPRINT); // SVC_PRINT	
	WriteShort(msg_type,5); // '3' is the number of writestrings including args
	WriteString(msg_type,"k/d ratio:{}/{}  avg life time: {}            \nkills per minute: {}                                        \n");//\ndist travelled: {}      Water time: {}      \ndmg ratio:      {} = {}/{}             \n");

	//random	
	WriteString(msg_type,roundedStr(self.kills));// K/d
	WriteString(msg_type,roundedStr(self.times_died));// k/D
	WriteString(msg_type,spacedfloat(self.alive_time / self.times_died));// avg life time
	local float killsPerMinute = self.kills/(self.alive_time/60.0);
	WriteString(msg_type,spacedfloat(killsPerMinute));// kills per minute
	
}


void() printLine15_17=
{
	local float msg_type = MSG_ONE;
	msg_entity = self.owner;
	WriteByte(msg_type,SVC_PRINT); // SVC_CENTERPRINT	
	//WriteByte(msg_type,SVC_CENTERPRINT); // SVC_PRINT	
	WriteShort(msg_type,6); // '3' is the number of writestrings including args
	WriteString(msg_type,"\ndist travelled: {}      Water time: {}      \ndmg ratio:      {} = {}/{}             \n");

	WriteString(msg_type,spacedfloat( self.distance_travelled ) );//dist travelled
	WriteString(msg_type,spacedfloat( self.water_time));//Water time
	local float dealt = getTotalDamageDealt( self );
	local float received = getTotalDamageReceived( self );
	WriteString(msg_type, spacedfloat( dealt / received ) ); //dmg ratio
	WriteString(msg_type,roundedStr( dealt ));               //dmg done =
	WriteString(msg_type,roundedStr( received )); //dmg received
}




.float printLineNum;

// think action for entity - prints all lines one a frame (so they
// all make it into the console) and then removes 'self'
void() newPrint2= 
{
	local entity sc = self.statsController;
	
	

	local string line00_ = "Player Report: {}\n";
	local string line01_ = "           Axe   S   SS   NG    SSN   GL   RL   LG\n";
	local string line02_ = "         =========================================\n";
	local string line03_ = "%{}%{}%{}%{}%{}%{}%{}%{}%\n";
	local string line04_ = "time     {}{}{}{} {}{}{}{}\n";
	local string line05_ = "dmg taken{} {} {} {} {} {} {} {}\n";
	local string line06_ = "dmg done {} {} {} {} {} {} {} {}\n";
	local string line07_ = "total shells: {} nails: {} rockets: {} cells: {} \n";
	local string line08_ = "\n";
	local string line09_ = "                Quad  Ring  Pent  Mega            \n";
	local string line10_ = "               ========================           \n";
	local string line11_ = "powerup count: {} {} {} {}            \n";
	local string line12_ = "poweruptime:   {} {} {}                  \n";
	local string line13_ = "\n";
	local string line14_ = "k/d ratio:{}/{}  avg life time: {}            \n";
	local string line15_ = "kills per minute: {}                                        \n";
	local string line17_ = "dist travelled: {}      Water time: {}      \n";
	local string line18_ = "dmg ratio:      {} = {}/{}             \n";
	
	local float msg_type = MSG_ONE;
	msg_entity = self.owner;
	WriteByte(msg_type,SVC_PRINT); // SVC_CENTERPRINT	SVC_PRINT	
	
	if(self.printLineNum == 0)
	{
		WriteShort(msg_type, 2); 
		WriteString(msg_type, line00_ );

		WriteString(msg_type, self.owner.netname );//player name
	}
	else if(self.printLineNum == 1)
	{
		WriteShort(msg_type, 1); 
		WriteString(msg_type, line01_ );
	}
	else if(self.printLineNum == 2)
	{
		WriteShort(msg_type, 1); 
		WriteString(msg_type, line02_ );
	}
	else if(self.printLineNum == 3)
	{
		WriteShort(msg_type, 9); 
		WriteString(msg_type, line03_ );

		//accuracy
		WriteString(msg_type, getAcu(sc.axe_shots_hits, sc.axe_shots_fired) );//axe
		WriteString(msg_type, getAcu(sc.shotgun_shots_hits, sc.shotgun_shots_fired) );//shotgun
		WriteString(msg_type, getAcu(sc.sshotgun_shots_hits, sc.sshotgun_shots_fired) );//dbl shot
		WriteString(msg_type, getAcu(sc.nailgun_shots_hits, sc.nailgun_shots_fired) );//nail
		WriteString(msg_type, getAcu(sc.snailgun_shots_hits, sc.snailgun_shots_fired) );//super nail
		WriteString(msg_type, getAcu(sc.grenade_shots_hits, sc.grenade_shots_fired) );//grenade
		WriteString(msg_type, getAcu(sc.rocket_shots_hits, sc.rocket_shots_fired) );//rock
		WriteString(msg_type, getAcu(sc.lightning_shots_hits, sc.lightning_shots_fired) );//lightning
	}
	else if(self.printLineNum == 4)
	{
		WriteShort(msg_type, 9); 
		WriteString(msg_type, line04_ );

		//time
		WriteString(msg_type,spacedfloat( sc.axe_time ));//axe
		WriteString(msg_type,spacedfloat(sc.shotgun_time));//shotgun
		WriteString(msg_type,spacedfloat(sc.sshotgun_time));//dbl shot
		WriteString(msg_type,spacedfloat(sc.nailgun_time));//nail
		WriteString(msg_type,spacedfloat(sc.snailgun_time));//super nail
		WriteString(msg_type,spacedfloat(sc.grenade_time));//grenade
	   	WriteString(msg_type,spacedfloat(sc.rocket_time));//rock
		WriteString(msg_type,spacedfloat(sc.lightning_time));//lightning	
	} 
	else if(self.printLineNum == 5)
	{
		WriteShort(msg_type, 9); 
		WriteString(msg_type, line05_ );

		//dmg taken
		WriteString(msg_type,roundedStr( sc.axe_damage_taken));//axe
		WriteString(msg_type,roundedStr( sc.shotgun_damage_taken));//shotgun
		WriteString(msg_type,roundedStr( sc.sshotgun_damage_taken));//dbl shot
		WriteString(msg_type,roundedStr( sc.nailgun_damage_taken));//nail
		WriteString(msg_type,roundedStr( sc.snailgun_damage_taken));//super nail
		WriteString(msg_type,roundedStr( sc.grenade_damage_taken));//grenade
		WriteString(msg_type,roundedStr( sc.rocket_damage_taken));//rock
		WriteString(msg_type,roundedStr( sc.lightning_damage_taken));//lightning
	}
	else if(self.printLineNum == 6)
	{
		WriteShort(msg_type, 9); 
		WriteString(msg_type, line06_ );

		//dmg done
		WriteString(msg_type,roundedStr( sc.axe_damage_dealt));//axe
		WriteString(msg_type,roundedStr( sc.shotgun_damage_dealt));//shotgun
		WriteString(msg_type,roundedStr( sc.sshotgun_damage_dealt));//dbl shot
		WriteString(msg_type,roundedStr( sc.nailgun_damage_dealt));//nail
		WriteString(msg_type,roundedStr( sc.snailgun_damage_dealt));//super nail
		WriteString(msg_type,roundedStr( sc.grenade_damage_dealt));//grenade
		WriteString(msg_type,roundedStr( sc.rocket_damage_dealt));//rock
		WriteString(msg_type,roundedStr( sc.lightning_damage_dealt));//lightning
	}
	else if(self.printLineNum == 7)
	{
		WriteShort(msg_type, 5); 
		WriteString(msg_type, line07_ );

		//ammo
		WriteString(msg_type,roundedStr( sc.shells_collected));//dbl shot
		WriteString(msg_type,roundedStr( sc.nails_collected));//nail
		WriteString(msg_type,roundedStr( sc.rockets_collected));//rock
		WriteString(msg_type,roundedStr( sc.cells_collected));//lightning
	}
	else if(self.printLineNum == 8)
	{
		WriteShort(msg_type, 1); 
		WriteString(msg_type, line08_ );
	}
	else if(self.printLineNum == 9)
	{
		WriteShort(msg_type, 1); 
		WriteString(msg_type, line09_ );
	}
	else if(self.printLineNum == 10)
	{
		WriteShort(msg_type, 1); 
		WriteString(msg_type, line10_ );
	}
	else if(self.printLineNum == 11)
	{
		WriteShort(msg_type, 5); 
		WriteString(msg_type, line11_ );
		
		//powerups
		//count
		WriteString(msg_type,roundedStr( sc.quads_collected));//quad
		WriteString(msg_type,roundedStr( sc.ring_collected));//ring
		WriteString(msg_type,roundedStr( sc.pent_collected));//pent
		WriteString(msg_type,roundedStr( sc.super_health_collected));//mega	
	}
	else if(self.printLineNum == 12)
	{
		WriteShort(msg_type,4); 
		WriteString(msg_type, line12_ );
		//time	
		WriteString(msg_type,spacedfloat( sc.quad_time));//quad
		WriteString(msg_type,spacedfloat( sc.ring_time));//ring
		WriteString(msg_type,spacedfloat( sc.pent_time));//pent
	}
	else if(self.printLineNum == 13)
	{
		WriteShort(msg_type,1); 
		WriteString(msg_type, line13_ );
	}
	else if(self.printLineNum == 14)
	{
		WriteShort(msg_type,4); 
		WriteString(msg_type, line14_ );

		//random	
		WriteString(msg_type,roundedStr( sc.kills));// KILLS/d
		WriteString(msg_type,roundedStr( sc.times_died));// k/DEATHS
		WriteString(msg_type,spacedfloat( sc.alive_time / self.times_died));// avg life time
	}
	else if(self.printLineNum == 15)
	{
		WriteShort(msg_type,2); 
		WriteString(msg_type, line15_ );
		
		local float killsPerMinute = sc.kills/( sc.alive_time/60.0);
		WriteString(msg_type,spacedfloat(killsPerMinute));// kills per minute
	}
	else if(self.printLineNum == 16)
	{
		WriteShort(msg_type,1); 
		local string line16_ = "\n";
		WriteString(msg_type, line16_ );
	}
	else if(self.printLineNum == 17)
	{
		WriteShort(msg_type,3); 
		WriteString(msg_type, line17_ );

		WriteString(msg_type,spacedfloat( sc.distance_travelled ) );//dist travelled
		WriteString(msg_type,spacedfloat( sc.water_time));//Water time
	}
	else if(self.printLineNum == 18)
	{
		WriteShort(msg_type,4); 
		WriteString(msg_type, line18_ );

		local float dealt = getTotalDamageDealt( sc );
		local float received = getTotalDamageReceived( sc );
		WriteString(msg_type, spacedfloat( dealt / (received +0.0001)) ); //dmg ratio
		WriteString(msg_type,roundedStr( dealt ));               //dmg done =
		WriteString(msg_type,roundedStr( received )); //dmg received
	}

	
	self.printLineNum = self.printLineNum +1;	
	
	self.nextthink = time + 0.01;
	self.think = newPrint2;
	
	if(self.printLineNum > 18)
	{
		self.think = SUB_Remove;
		//wrap in debug
		self.printLineNum = 0;
	}
}



void() newPrint=
{
	/*
a       "playerReport: teamred                             \n
a       "           Axe   S   SS   NG    SSN   GL   RL   LG\n
b	"         =========================================\n
c	"accuracy [000][000][200][000] [000][000][000][000]\n
d	"time     [000][000][200][000] [000][000][000][000]\n"
e	"dmg taken[000][000][200][000] [000][000][000][000]\n"
f	"dmg done [000][000][200][000] [000][000][000][000]\n"
g	"ammo     [000][000][200][000] [000][000][000][000]\n"
h	"                                                  \n"
i	"                Quad  Ring  Pent  Mega            \n'
j	"               ========================           \n"	
k	"powerup count: [000] [000] [300] [000]            \n"
l	"poweruptime:   [000] [000] [300]                  \n"
m	"                                                  \n"
n	"k/d ratio:[000] 0/0    avg life time: [000]       \n"	
o	"kpm: [000]                                        \n"
p	"                                                  \n'
q	"dist travelled: [000]      Water time: [000]      \n'	
r	"dmg ratio:      [000] = [0000]/[0000]             \n"
s*/

//local string lineA = "           Axe   S   SS   NG    SSN   GL   RL   LG\n";
//"         =========================================\n
//"accuracy {}{}{}{} {}{}{}{}\n"

       local float msg_type = MSG_ONE;
	msg_entity = self.owner;
	WriteByte(msg_type,SVC_PRINT); // SVC_CENTERPRINT	
	//WriteByte(msg_type,SVC_CENTERPRINT); // SVC_PRINT	
	WriteShort(msg_type,54); // '3' is the number of writestrings including args
	WriteString(msg_type,
"Player Report: {}\n           Axe   S   SS   NG    SSN   GL   RL   LG\n         =========================================\n%{}%{}%{}%{}%{}%{}%{}%{}%\ntime     {}{}{}{} {}{}{}{}\ndmg taken{} {} {} {} {} {} {} {}\ndmg done {} {} {} {} {} {} {} {}\ntotal shells: {} nails: {} rockets: {} cells: {} \n\n                Quad  Ring  Pent  Mega            \n               ========================           \npowerup count: {} {} {} {}            \npoweruptime:   {} {} {}                  \n\nk/d ratio:{}/{}  avg life time: {}            \nkills per minute: {}                                        \n\ndist travelled: {}      Water time: {}      \ndmg ratio:      {} = {}/{}             \n");

	WriteString(msg_type, self.owner.netname );//player name
	
	//accuracy
	WriteString(msg_type, getAcu(self.axe_shots_hits, self.axe_shots_fired) );//axe
	WriteString(msg_type, getAcu(self.shotgun_shots_hits, self.shotgun_shots_fired) );//shotgun
	WriteString(msg_type, getAcu(self.sshotgun_shots_hits, self.sshotgun_shots_fired) );//dbl shot
	WriteString(msg_type, getAcu(self.nailgun_shots_hits, self.nailgun_shots_fired) );//nail
	WriteString(msg_type, getAcu(self.snailgun_shots_hits, self.snailgun_shots_fired) );//super nail
	WriteString(msg_type, getAcu(self.grenade_shots_hits, self.grenade_shots_fired) );//grenade
	WriteString(msg_type, getAcu(self.rocket_shots_hits, self.rocket_shots_fired) );//rock
	WriteString(msg_type, getAcu(self.lightning_shots_hits, self.lightning_shots_fired) );//lightning
	//time
	WriteString(msg_type,spacedfloat(self.axe_time ));//axe
	WriteString(msg_type,spacedfloat(self.shotgun_time));//shotgun
	WriteString(msg_type,spacedfloat(self.sshotgun_time));//dbl shot
	WriteString(msg_type,spacedfloat(self.nailgun_time));//nail
	WriteString(msg_type,spacedfloat(self.snailgun_time));//super nail
	WriteString(msg_type,spacedfloat(self.grenade_time));//grenade
	WriteString(msg_type,spacedfloat(self.rocket_time));//rock
	WriteString(msg_type,spacedfloat(self.lightning_time));//lightning
	//dmg taken
	WriteString(msg_type,roundedStr(self.axe_damage_taken));//axe
	WriteString(msg_type,roundedStr(self.shotgun_damage_taken));//shotgun
	WriteString(msg_type,roundedStr(self.sshotgun_damage_taken));//dbl shot
	WriteString(msg_type,roundedStr(self.nailgun_damage_taken));//nail
	WriteString(msg_type,roundedStr(self.snailgun_damage_taken));//super nail
	WriteString(msg_type,roundedStr(self.grenade_damage_taken));//grenade
	WriteString(msg_type,roundedStr(self.rocket_damage_taken));//rock
	WriteString(msg_type,roundedStr(self.lightning_damage_taken));//lightning
	//dmg done
	WriteString(msg_type,roundedStr(self.axe_damage_dealt));//axe
	WriteString(msg_type,roundedStr(self.shotgun_damage_dealt));//shotgun
	WriteString(msg_type,roundedStr(self.sshotgun_damage_dealt));//dbl shot
	WriteString(msg_type,roundedStr(self.nailgun_damage_dealt));//nail
	WriteString(msg_type,roundedStr(self.snailgun_damage_dealt));//super nail
	WriteString(msg_type,roundedStr(self.grenade_damage_dealt));//grenade
	WriteString(msg_type,roundedStr(self.rocket_damage_dealt));//rock
	WriteString(msg_type,roundedStr(self.lightning_damage_dealt));//lightning
	//ammo
	WriteString(msg_type,roundedStr(self.shells_collected));//dbl shot
	WriteString(msg_type,roundedStr(self.nails_collected));//nail
	WriteString(msg_type,roundedStr(self.rockets_collected));//rock
	WriteString(msg_type,roundedStr(self.cells_collected));//lightning
	
	
		//powerups
	//count
	WriteString(msg_type,roundedStr(self.quads_collected));//quad
	WriteString(msg_type,roundedStr(self.ring_collected));//ring
	WriteString(msg_type,roundedStr(self.pent_collected));//pent
	WriteString(msg_type,roundedStr(self.super_health_collected));//mega
	
	//time	
	WriteString(msg_type,spacedfloat(self.quad_time));//quad
	WriteString(msg_type,spacedfloat(self.ring_time));//ring
	WriteString(msg_type,spacedfloat(self.pent_time));//pent

	//random	
	WriteString(msg_type,roundedStr(self.kills));// K/d
	WriteString(msg_type,roundedStr(self.times_died));// k/D
	WriteString(msg_type,spacedfloat(self.alive_time / self.times_died));// avg life time
	local float killsPerMinute = self.kills/(self.alive_time/60.0);
	WriteString(msg_type,spacedfloat(killsPerMinute));// kills per minute
	
	
	WriteString(msg_type,spacedfloat( self.distance_travelled ) );//dist travelled
	WriteString(msg_type,spacedfloat( self.water_time));//Water time
	local float dealt = getTotalDamageDealt( self );
	local float received = getTotalDamageReceived( self );
	WriteString(msg_type, spacedfloat( dealt / received ) ); //dmg ratio
	WriteString(msg_type,roundedStr( dealt ));               //dmg done =
	WriteString(msg_type,roundedStr( received )); //dmg received
	
}

void() testPrint=
{
	//"0000000001000000000020000000003000000004000000000500"//max-width 52 characters or 51 w/ '\n'
	//if too many characters  in a single line- it swallows two chars for the endl/'\n'
	//it can print lines a-w (w is half off screen - and t-w are overlapping the regular hud
	//multiple calls to 'centerprint will overwrite one another
	// characters per line isn't limited by the resolution, but can go off the edge of the screen
	//typeface is not monospaced ('.' is narrower than '4') but will only print 50 chars on a line
	//      ftos(3) will print      '3' - ie taking  one/1 space
	//    ftos(3.0) will print      '3' - ie taking  one/1 space
	//    ftos(3.1) will print  '  3.1' - ie taking five/5 spaces
	//   ftos(23.1) will print  ' 23.1' - ie taking five/5 spaces
	//  ftos(123.1) will print  '123.1' - ie taking five/5 spaces
	// ftos(1234.1) will print '1234.1' - ie taking six/6 spaces
	
	/* 0123456789012345678901234567890123456789012345678901
		   a000000001000000000020000000003000000004000000000a\n
		   b000000001000000000020000000003000000004000000000b\n
		   c000000001000000000020000000003000000004000000000c\n
		   d000000001000000000020000000003000000004000000000d\n
		   e000000001000000000020000000003000000004000000000e\n
		   f000000001000000000020000000003000000004000000000f\n
           g000000001000000000020000000003000000004000000000g\n
           h000000001000000000020000000003000000004000000000h\n
           i000000001000000000020000000003000000004000000000i\n
           j000000001000000000020000000003000000004000000000j\n
           k000000001000000000020000000003000000004000000000k\n
           l000000001000000000020000000003000000004000000000l\n
           m000000001000000000020000000003000000004000000000m\n
           n000000001000000000020000000003000000004000000000n\n
           o000000001000000000020000000003000000004000000000o\n
           p000000001000000000020000000003000000004000000000p\n
           q000000001000000000020000000003000000004000000000q\n
           r000000001000000000020000000003000000004000000000r\n
           s000000001000000000020000000003000000004000000000s\n
           t000000001000000000020000000003000000004000000000t\n
           u000000001000000000020000000003000000004000000000u\n
           v000000001000000000020000000003000000004000000000v\n
           w000000001000000000020000000003000000004000000000w\n
           x000000001000000000020000000003000000004000000000x
           
           
        .......................................................
	a00000000  Axe   S   SS   NG    SSN   GL   RL   LG\n
	=========[===][===][===][===]=[===][===][===][===]\n
	accuracy01000000000020000000003000000004000000000c\n
	time000001000000000020000000003000000004000000000d\n
	dmg taken1000000000020000000003000000004000000000f\n
	dmg done01000000000020000000003000000004000000000g\n
	ammo   001000000000020000000003000000004000000000r\n
	q000000001000000000020000000003000000004000000000q\n
	n0000000010000  quad    ring  pent  mega 00000000n\n
	===============[===]===[===]=[===]=[===]==========\n	
	powerup count000000020000000003000000004000000000m\n
	poweruptime00000000020000000003000000004000000000k\n
	o000000001000000000020000000003000000004000000000o\n
	avg life time000000020000000003000000004000000000l\n	
	k/d ratio:[000]0000020000000003000000004000000000e\n
	h000000001000000000020000000003000000004000000000i\n
	dist travelled0000002000000water time:04000000000h\n	
	dmg ratio1000000000020000000003000000004000000000j\n
	s000000001000000000020000000003000000004000000000s\n
	t000000001000000000020000000003000000004000000000t\n
	u000000001000000000020000000003000000004000000000u\n
	v000000001000000000020000000003000000004000000000v\n
	w000000001000000000020000000003000000004000000000w\n
           
           
           "a000000001000000000020000000003000000004000000000a",
           "b000000001000000000020000000003000000004000000000b",
           "c000000001000000000020000000003000000004000000000c",
           "d000000001000000000020000000003000000004000000000d",
           "e000000001000000000020000000003000000004000000000e",
           "f000000001000000000020000000003000000004000000000f",
           "g000000001000000000020000000003000000004000000000g",
           "h000000001000000000020000000003000000004000000000h",
           "i000000001000000000020000000003000000004000000000i",
           "j000000001000000000020000000003000000004000000000j",
           "k000000001000000000020000000003000000004000000000k",
           "l000000001000000000020000000003000000004000000000l",
           "m000000001000000000020000000003000000004000000000m",
           "n000000001000000000020000000003000000004000000000n",
           "o000000001000000000020000000003000000004000000000o",
           "p000000001000000000020000000003000000004000000000p",
           "q000000001000000000020000000003000000004000000000q",
           "r000000001000000000020000000003000000004000000000r",
           "s000000001000000000020000000003000000004000000000s",
           "t000000001000000000020000000003000000004000000000t",
           "u000000001000000000020000000003000000004000000000u",
           "v000000001000000000020000000003000000004000000000v",
           "w000000001000000000020000000003000000004000000000w",
           "x000000001000000000020000000003000000004000000000x",
           
	*/
//centerprint(self.owner,"000000f"      );


centerprint(self.owner,  "w000000001000000000020000000003000000004000000000w\n", 
"v000000001000000000020000000003000000004000", ftos(21.0), "kk" );
//this sprint doesn't seem to make it to the console... maybe because there isn't a newline char
//no newlines means the whole screen will fill up...
//looks like sprint has variable width depending on the horizontal resolution of the window/screen as well
//I can get 8 lines top to bottom with three sprints - one longer than scrw an ftos and an endline
//four lines with just ftos and endline or just text with endl
//i get 20 lines  with a single sprint w four new lines in it / only first is visible in console
//20 lines game overlay with two sprints one an ftos and the other w/four endls BUT only one (the first) line is visible in the console
//un lined sprint will slowly fill and go off screen
// '\0' char seems to make it not rec endline
//changing resolution will blank scree chars
// 5 sprints shows in game 4 lines and in console 1st is lost
//text in console wraps as well and is significantly different for diff resolutions - always seems to print last 4 messages though - even if they aren't in the same func
//maybe you only get 4 lines per 'think' routine??
// with the new format strings {{ prints a '{' and }} prints a '}'	
//can print 1109 chars at once 2033 yep, 2055? NO - over 2048 is too many for one print statement
        //sprint(self.owner,"000000000100000000002000000000300000000400000000050000000006000000000700000000080000000009");
        //sprint(self.owner,"0000000001000000000020000000003000000004000000000500000000060000000-0700000000080000000009");
        //sprint(self.owner,ftos(time));
        
        //sprint(self.owner,"1000000000100000000002000000000300000000400000000050000000006000000000700000000080000000009000000000a000000000b000000000c000000000d000000000e\n");
        //sprint(self.owner,"2000000000100000000002000000000300000000400000000050000000006000000000700000000080000000009000000000a000000000b000000000c000000000d000000000e\n");
        //sprint(self.owner,"3000000000100000000002000000000300000000400000000050000000006000000000700000000080000000009000000000a000000000b000000000c000000000d000000000e\n");
        //sprint(self.owner,"4000000000100000000002000000000300000000400000000050000000006000000000700000000080000000009000000000a000000000b000000000c000000000d000000000e\n");
       // sprint(self.owner,"5000000000100000000002000000000300000000400000000050000000006000000000700000000080000000009000000000a000000000b000000000c000000000d000000000e\n");
        
        //sprint(self.owner,"BLAH!\nBLBH!\nBLCH!\nBLDH!\nBLEH!\n");
        //dprint("000000000100000000002000000000300000000400000000050000000006000000000700000000080000000009");
        //local float msg_type = MSG_ONE;
	//msg_entity = self.owner;
	//WriteByte(msg_type,SVC_PRINT); // SVC_PRINT	
	//WriteShort(msg_type,3); // '3' is the number of writestrings including args
	//WriteString(msg_type,"{}\n{}");
	//WriteString(msg_type,"a000000001000000000020000000003000000004000000000a");
	//WriteString(msg_type,"b000000001000000000020000000003000000004000000000b");

}

void() printOneCR={
	sprint(self.owner,"\n");
	sprint(self.owner,"\n");
	sprint(self.owner,"\n");
	sprint(self.owner,"\n");
	self.think = SUB_Remove;
	
}


void() oneLineJSON=
{
	//local string json = "{{ \"playerName\":\"{}\", \"distance_travelled\": \"{}\", \"times_died\": \"{}\", \"kills\": \"{}\", \"alive_time\": \"{}\", \"water_time\": \"{}\", \"health_collected\": \"{}\", \"killDeathratio\": \"{}\", \"avgLifeSpan\": \"{}\", \"killsPerMinute\": \"{}\", \"dmgGivenTakenRatio\": \"{}\", \"ammo_collected\": {{ \"shells_collected\": \"{}\", \"nails_collected\": \"{}\", \"rockets_collected\": \"{}\", \"cells_collected\": \"{}\" }}, \"powerups\": {{ \"quad_time\": \"{}\", \"ring_time\": \"{}\", \"pent_time\": \"{}\", \"ring_collected\": \"{}\", \"quads_collected\": \"{}\", \"pent_collected\": \"{}\", \"super_health_collected\": \"{}\" }}, \"armor\": {{ \"green_armors_collected\": \"{}\", \"yellow_armors_collected\": \"{}\", \"red_armors_collected\": \"{}\" }}, \"damageDealt\": {{ \"axe_damage_dealt\": \"{}\", \"shotgun_damage_dealt\": \"{}\", \"sshotgun_damage_dealt\": \"{}\", \"nailgun_damage_dealt\": \"{}\", \"snailgun_damage_dealt\": \"{}\", \"grenade_damage_dealt\": \"{}\", \"rocket_damage_dealt\": \"{}\", \"lightning_damage_dealt\": \"{}\", \"totalDamageDone\": {} }}, \"damageTaken\": {{ \"axe_damage_taken\": \"{}\", \"shotgun_damage_taken\": \"{}\", \"sshotgun_damage_taken\": \"{}\", \"nailgun_damage_taken\": \"{}\", \"snailgun_damage_taken\": \"{}\", \"grenade_damage_taken\": \"{}\", \"rocket_damage_taken\": \"{}\", \"lightning_damage_taken\": \"{}\", \"other_damage_taken\": \"{}\", \"totalDamageTaken\": {} }}, \"shotsFired\": {{ \"axe_shots_fired\": \"{}\", \"shotgun_shots_fired\": \"{}\", \"sshotgun_shots_fired\": \"{}\", \"nailgun_shots_fired\": \"{}\", \"snailgun_shots_fired\": \"{}\", \"grenade_shots_fired\": \"{}\", \"rocket_shots_fired\": \"{}\", \"lightning_shots_fired\": \"{}\", \"totalShotsFired\": \"{}\", }}, \"shotsHit\": {{ \"axe_shots_hits\": \"{}\", \"shotgun_shots_hits\": \"{}\", \"sshotgun_shots_hits\": \"{}\", \"nailgun_shots_hits\": \"{}\", \"snailgun_shots_hits\": \"{}\", \"grenade_shots_hits\": \"{}\", \"rocket_shots_hits\": \"{}\", \"lightning_shots_hits\": \"{}\", \"totalShotsHit\": \"{}\", }}, \"weaponHoldTime\": {{ \"axe_time\": \"{}\", \"shotgun_time\": \"{}\", \"sshotgun_time\": \"{}\", \"nailgun_time\": \"{}\", \"snailgun_time\": \"{}\", \"grenade_time\": \"{}\", \"rocket_time\": \"{}\", \"lightning_time\": \"{}\" }} \"accuracy\": {{\"axe_shots_acc\": \"{}\",\"shotgun_shots_acc\": \"{}\",\"sshotgun_shots_acc\": \"{}\",\"nailgun_shots_acc\": \"{}\",\"snailgun_shots_acc\": \"{}\",\"grenade_shots_acc\": \"{}\",\"rocket_shots_acc\": \"{}\",\"lightning_shots_acc\": \"{}\",\"totalAcc\": \"{}\"}}}}";
	//can print 1109 chars at once 2033 yep, 2055? NO - over 2048 is too many for one print statement
	//
	//local string json = "{{\"playerName\":\"{}\",\"distance_travelled\":\"{}\",\"times_died\":\"{}\",\"kills\":\"{}\",\"alive_time\":\"{}\",\"water_time\":\"{}\",\"health_collected\":\"{}\",\"killDeathratio\":\"{}\",\"avgLifeSpan\":\"{}\",\"killsPerMinute\":\"{}\",\"dmgGivenTakenRatio\":\"{}\",\"ammo_collected\":{{\"shells_collected\":\"{}\",\"nails_collected\":\"{}\",\"rockets_collected\":\"{}\",\"cells_collected\":\"{}\"}},\"powerups\":{{\"quad_time\":\"{}\",\"ring_time\":\"{}\",\"pent_time\":\"{}\",\"ring_collected\":\"{}\",\"quads_collected\":\"{}\",\"pent_collected\":\"{}\",\"super_health_collected\":\"{}\"}},\"armor\":{{\"green_armors_collected\":\"{}\",\"yellow_armors_collected\":\"{}\",\"red_armors_collected\":\"{}\"}},\"damageDealt\":{{\"axe_damage_dealt\":\"{}\",\"shotgun_damage_dealt\":\"{}\",\"sshotgun_damage_dealt\":\"{}\",\"nailgun_damage_dealt\":\"{}\",\"snailgun_damage_dealt\":\"{}\",\"grenade_damage_dealt\":\"{}\",\"rocket_damage_dealt\":\"{}\",\"lightning_damage_dealt\":\"{}\",";
	//local string j2 = "\"totalDamageDone\":{}}},\"damageTaken\":{{\"axe_damage_taken\":\"{}\",\"shotgun_damage_taken\":\"{}\",\"sshotgun_damage_taken\":\"{}\",\"nailgun_damage_taken\":\"{}\",\"snailgun_damage_taken\":\"{}\",\"grenade_damage_taken\":\"{}\",\"rocket_damage_taken\":\"{}\",\"lightning_damage_taken\":\"{}\",\"other_damage_taken\":\"{}\",\"totalDamageTaken\":{}}},\"shotsFired\":{{\"axe_shots_fired\":\"{}\",\"shotgun_shots_fired\":\"{}\",\"sshotgun_shots_fired\":\"{}\",\"nailgun_shots_fired\":\"{}\",\"snailgun_shots_fired\":\"{}\",\"grenade_shots_fired\":\"{}\",\"rocket_shots_fired\":\"{}\",\"lightning_shots_fired\":\"{}\",\"totalShotsFired\":\"{}\",}},\"shotsHit\":{{\"axe_shots_hits\":\"{}\",\"shotgun_shots_hits\":\"{}\",\"sshotgun_shots_hits\":\"{}\",\"nailgun_shots_hits\":\"{}\",\"snailgun_shots_hits\":\"{}\",\"grenade_shots_hits\":\"{}\",\"rocket_shots_hits\":\"{}\",\"lightning_shots_hits\":\"{}\",\"totalShotsHit\":\"{}\",}},\"weaponHoldTime\":{{\"axe_time\":\"{}\",\"shotgun_time\":\"{}\",\"sshotgun_time\":\"{}\",\"nailgun_time\":\"{}\",\"snailgun_time\":\"{}\",\"grenade_time\":\"{}\",\"rocket_time\":\"{}\",\"lightning_time\":\"{}\"}}\"accuracy\":{{\"axe_shots_acc\":\"{}\",\"shotgun_shots_acc\":\"{}\",\"sshotgun_shots_acc\":\"{}\",\"nailgun_shots_acc\":\"{}\",\"snailgun_shots_acc\":\"{}\",\"grenade_shots_acc\":\"{}\",\"rocket_shots_acc\":\"{}\",\"lightning_shots_acc\":\"{}\",\"totalAcc\":\"{}\"}}}}\n";
	//local string json = "{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}\n";
	local float print_type = SVC_PRINT;
	local float killsPerMinute = self.kills/(self.alive_time/60.0);	
	
	local float dealt = getTotalDamageDealt( self );
	local float received = getTotalDamageReceived( self );	
	local float ttlShotsFired = getTotalShotsFired( self );
	local float ttlShotsHit = getTotalShotsHit( self );
	
	local float msg_type = MSG_ONE;
	msg_entity = self.owner;
	
	WriteByte(msg_type, print_type); 
	WriteShort(msg_type, 12);
	local string json_random = "{{\"playerName\":\"{}\",\"distance_travelled\":\"{}\",\"times_died\":\"{}\",\"kills\":\"{}\",\"alive_time\":\"{}\",\"water_time\":\"{}\",\"health_collected\":\"{}\",\"killDeathratio\":\"{}\",\"avgLifeSpan\":\"{}\",\"killsPerMinute\":\"{}\",\"dmgGivenTakenRatio\":\"{}\",";
	WriteString(msg_type, json_random );//json
	WriteString(msg_type, self.owner.netname );//player name
	WriteString(msg_type, spacedfloat( self.distance_travelled ) );//dist travelled
	WriteString(msg_type, roundedStr(self.times_died));// k/D
	WriteString(msg_type, roundedStr(self.kills));// K/d
	WriteString(msg_type, spacedfloat(self.alive_time));// kills per minute
	WriteString(msg_type, spacedfloat( self.water_time));//Water time
	WriteString(msg_type, spacedfloat( self.health_collected) );//Water time
	WriteString(msg_type, roundedStr(self.kills/(self.times_died+0.0001) ) );// k/D
	WriteString(msg_type, spacedfloat(self.alive_time / (self.times_died+0.0001)));// avg life time
	WriteString(msg_type, spacedfloat(killsPerMinute));// kills per minute
	WriteString(msg_type, spacedfloat( dealt / (received +0.0001) ) ); //dmg ratio
	
	WriteByte(msg_type, print_type); 
	WriteShort(msg_type, 5);
	local string json_ammo= "\"ammo_collected\":{{\"shells_collected\":\"{}\",\"nails_collected\":\"{}\",\"rockets_collected\":\"{}\",\"cells_collected\":\"{}\"}},";
	WriteString(msg_type, json_ammo );//json
	WriteString(msg_type, roundedStr(self.shells_collected));//dbl shot//ammo
	WriteString(msg_type, roundedStr(self.nails_collected));//nail
	WriteString(msg_type, roundedStr(self.rockets_collected));//rock
	WriteString(msg_type, roundedStr(self.cells_collected));//lightning
	
	WriteByte(msg_type, print_type);
	WriteShort(msg_type, 8);	
	local string json_powerups = "\"powerups\":{{\"quad_time\":\"{}\",\"ring_time\":\"{}\",\"pent_time\":\"{}\",\"ring_collected\":\"{}\",\"quads_collected\":\"{}\",\"pent_collected\":\"{}\",\"super_health_collected\":\"{}\"}},";
	WriteString(msg_type, json_powerups );//json		
	WriteString(msg_type, spacedfloat(self.quad_time));//quad //powerups	//time	
	WriteString(msg_type, spacedfloat(self.ring_time));//ring
	WriteString(msg_type, spacedfloat(self.pent_time));//pent
	WriteString(msg_type, roundedStr(self.quads_collected));//quad //count
	WriteString(msg_type, roundedStr(self.ring_collected));//ring
	WriteString(msg_type, roundedStr(self.pent_collected));//pent
	WriteString(msg_type, roundedStr(self.super_health_collected));//mega
	
	WriteByte(msg_type, print_type); 
	WriteShort(msg_type, 4);	
	local string json_armor = "\"armor\":{{\"green_armors_collected\":\"{}\",\"yellow_armors_collected\":\"{}\",\"red_armors_collected\":\"{}\"}},";
	WriteString(msg_type, json_armor);
	WriteString(msg_type, roundedStr(self.green_armors_collected));//green //armor
	WriteString(msg_type, roundedStr(self.yellow_armors_collected));//yellow
	WriteString(msg_type, roundedStr(self.red_armors_collected));//red
	
	WriteByte(msg_type, print_type); 
	WriteShort(msg_type, 10);	
	local string json_dmgDealt = "\"damageDealt\":{{\"axe_damage_dealt\":\"{}\",\"shotgun_damage_dealt\":\"{}\",\"sshotgun_damage_dealt\":\"{}\",\"nailgun_damage_dealt\":\"{}\",\"snailgun_damage_dealt\":\"{}\",\"grenade_damage_dealt\":\"{}\",\"rocket_damage_dealt\":\"{}\",\"lightning_damage_dealt\":\"{}\",\"totalDamageDone\":{}}},";
	WriteString(msg_type, json_dmgDealt);
	WriteString(msg_type, roundedStr(self.axe_damage_dealt));//axe //dmg done
	WriteString(msg_type, roundedStr(self.shotgun_damage_dealt));//shotgun
	WriteString(msg_type, roundedStr(self.sshotgun_damage_dealt));//dbl shot
	WriteString(msg_type, roundedStr(self.nailgun_damage_dealt));//nail
	WriteString(msg_type, roundedStr(self.snailgun_damage_dealt));//super nail
	WriteString(msg_type, roundedStr(self.grenade_damage_dealt));//grenade	
	WriteString(msg_type, roundedStr(self.rocket_damage_dealt));//rock
	WriteString(msg_type, roundedStr(self.lightning_damage_dealt));//lightning	
	WriteString(msg_type, roundedStr( dealt ));               //total dmg done
	
	WriteByte(msg_type, print_type); 
	WriteShort(msg_type, 11);	
	local string json_dmgTaken = "\"damageTaken\":{{\"axe_damage_taken\":\"{}\",\"shotgun_damage_taken\":\"{}\",\"sshotgun_damage_taken\":\"{}\",\"nailgun_damage_taken\":\"{}\",\"snailgun_damage_taken\":\"{}\",\"grenade_damage_taken\":\"{}\",\"rocket_damage_taken\":\"{}\",\"lightning_damage_taken\":\"{}\",\"other_damage_taken\":\"{}\",\"totalDamageTaken\":{}}},";
	WriteString(msg_type, json_dmgTaken);
	WriteString(msg_type, roundedStr(self.axe_damage_taken));//axe //dmg taken
	WriteString(msg_type, roundedStr(self.shotgun_damage_taken));//shotgun
	WriteString(msg_type, roundedStr(self.sshotgun_damage_taken));//dbl shot
	WriteString(msg_type, roundedStr(self.nailgun_damage_taken));//nail
	WriteString(msg_type, roundedStr(self.snailgun_damage_taken));//super nail
	WriteString(msg_type, roundedStr(self.grenade_damage_taken));//grenade
	WriteString(msg_type, roundedStr(self.rocket_damage_taken));//rock
	WriteString(msg_type, roundedStr(self.lightning_damage_taken));//lightning
	WriteString(msg_type, roundedStr(self.other_damage_taken));//other
	WriteString(msg_type, roundedStr( received )); //total dmg received
	
	WriteByte(msg_type, print_type); 
	WriteShort(msg_type, 10);	
	local string json_shotFired = "\"shotsFired\":{{\"axe_shots_fired\":\"{}\",\"shotgun_shots_fired\":\"{}\",\"sshotgun_shots_fired\":\"{}\",\"nailgun_shots_fired\":\"{}\",\"snailgun_shots_fired\":\"{}\",\"grenade_shots_fired\":\"{}\",\"rocket_shots_fired\":\"{}\",\"lightning_shots_fired\":\"{}\",\"totalShotsFired\":\"{}\"}},";	
	WriteString(msg_type, json_shotFired);	
	WriteString(msg_type, roundedStr( self.axe_shots_fired) );//axe//fired
	WriteString(msg_type, roundedStr( self.shotgun_shots_fired) );//shotgun
	WriteString(msg_type, roundedStr( self.sshotgun_shots_fired) );//dbl shot
	WriteString(msg_type, roundedStr( self.nailgun_shots_fired) );//nail
	WriteString(msg_type, roundedStr( self.snailgun_shots_fired) );//super nail
	WriteString(msg_type, roundedStr( self.grenade_shots_fired) );//grenade
	WriteString(msg_type, roundedStr( self.rocket_shots_fired) );//rock
	WriteString(msg_type, roundedStr( self.lightning_shots_fired) );//lightning
	WriteString(msg_type, roundedStr( ttlShotsFired) );//total
	
	
	WriteByte(msg_type, print_type);
	WriteShort(msg_type,10);	
	local string json_shotsHit = "\"shotsHit\":{{\"axe_shots_hits\":\"{}\",\"shotgun_shots_hits\":\"{}\",\"sshotgun_shots_hits\":\"{}\",\"nailgun_shots_hits\":\"{}\",\"snailgun_shots_hits\":\"{}\",\"grenade_shots_hits\":\"{}\",\"rocket_shots_hits\":\"{}\",\"lightning_shots_hits\":\"{}\",\"totalShotsHit\":\"{}\"}},";
	WriteString(msg_type, json_shotsHit);
	WriteString(msg_type, roundedStr(self.axe_shots_hits) );//axe//hit
	WriteString(msg_type, roundedStr(self.shotgun_shots_hits) );//shotgun
	WriteString(msg_type, roundedStr(self.sshotgun_shots_hits) );//dbl shot
	WriteString(msg_type, roundedStr(self.nailgun_shots_hits) );//nail
	WriteString(msg_type, roundedStr(self.snailgun_shots_hits) );//super nail
	WriteString(msg_type, roundedStr(self.grenade_shots_hits) );//grenade
	WriteString(msg_type, roundedStr(self.rocket_shots_hits) );//rock
	WriteString(msg_type, roundedStr(self.lightning_shots_hits) );//lightning
	WriteString(msg_type, roundedStr(ttlShotsHit) );//total
	
	
	WriteByte(msg_type, print_type);
	WriteShort(msg_type,9);	
	local string json_weaponHoldTime = "\"weaponHoldTime\":{{\"axe_time\":\"{}\",\"shotgun_time\":\"{}\",\"sshotgun_time\":\"{}\",\"nailgun_time\":\"{}\",\"snailgun_time\":\"{}\",\"grenade_time\":\"{}\",\"rocket_time\":\"{}\",\"lightning_time\":\"{}\"}},";
	WriteString(msg_type, json_weaponHoldTime);
	WriteString(msg_type, spacedfloat(self.axe_time ));//axe//time
	WriteString(msg_type, spacedfloat(self.shotgun_time));//shotgun
	WriteString(msg_type, spacedfloat(self.sshotgun_time));//dbl shot
	WriteString(msg_type, spacedfloat(self.nailgun_time));//nail
	WriteString(msg_type, spacedfloat(self.snailgun_time));//super nail
	WriteString(msg_type, spacedfloat(self.grenade_time));//grenade
	WriteString(msg_type, spacedfloat(self.rocket_time));//rock
	WriteString(msg_type, spacedfloat(self.lightning_time));//lightning
	
	
	WriteByte(msg_type, print_type); 
	WriteShort(msg_type,10);	
	local string json_accuracy = "\"accuracy\":{{\"axe_shots_acc\":\"{}\",\"shotgun_shots_acc\":\"{}\",\"sshotgun_shots_acc\":\"{}\",\"nailgun_shots_acc\":\"{}\",\"snailgun_shots_acc\":\"{}\",\"grenade_shots_acc\":\"{}\",\"rocket_shots_acc\":\"{}\",\"lightning_shots_acc\":\"{}\",\"totalAcc\":\"{}\"}}}}\n";
	WriteString(msg_type, json_accuracy);
	WriteString(msg_type, getAcu( self.axe_shots_hits, self.axe_shots_fired) );//axe //shots
	WriteString(msg_type, getAcu( self.shotgun_shots_hits, self.shotgun_shots_fired) );//shotgun
	WriteString(msg_type, getAcu( self.sshotgun_shots_hits, self.sshotgun_shots_fired) );//dbl shot
	WriteString(msg_type, getAcu( self.nailgun_shots_hits, self.nailgun_shots_fired) );//nail
	WriteString(msg_type, getAcu( self.snailgun_shots_hits, self.snailgun_shots_fired) );//super nail
	WriteString(msg_type, getAcu( self.grenade_shots_hits, self.grenade_shots_fired) );//grenade
	WriteString(msg_type, getAcu( self.rocket_shots_hits, self.rocket_shots_fired) );//rock
	WriteString(msg_type, getAcu( self.lightning_shots_hits, self.lightning_shots_fired) );//lightning
	WriteString(msg_type, getAcu( ttlShotsHit, ttlShotsFired) );//TOTAL	
	
	//try to clear out the player screen...
	//local entity statPrinter = spawn();
	//statPrinter.think = printOneCR;
	//statPrinter.nextthink = time + .1; //wait .1 seconds...
	//statPrinter.owner = self.owner;
}

//====================================
//controller entity stuff
//====================================

void() statsThink=
{
	
	if(self.impulse == 100)
	{
		oneLineJSON();
		//spawn an entity whose sole purpose is to print stats out line by line to the console!
		//local entity statPrinter = spawn();
		//statPrinter.printLineNum = 0;
		//statPrinter.think = newPrint2;
		//statPrinter.nextthink = 0.1 + time;
		//statPrinter.statsController = self;	
		//statPrinter.owner = self.owner;	
		
		//printAll();
		//newPrint();//testPrint();
		self.impulse = 0;
	}
	self.think = statsThink;
	self.nextthink = time + 0.1;
}

// "do stuff" - right now just react to impulse commands
//self is expected to be the player/client
// pattern is copied fromw 'W_WeaponFrame' in client/weapons.qc
void() statsFrame=
{
	if(self.impulse == 100)
	{
		self.statsController.impulse = self.impulse;
		self.impulse = 0;
	}
}

void() spawnStatsController=
{
	local entity playerStatsController;
	
	bprint("making a stats for ");
	bprint(self.netname);
	bprint("\n");
	
	playerStatsController = spawn();
	playerStatsController.owner = self;
	playerStatsController.classname = "stats_controller";
	playerStatsController.think = statsThink;
	playerStatsController.nextthink = time + 0.1;
	self.statsController = playerStatsController;
}