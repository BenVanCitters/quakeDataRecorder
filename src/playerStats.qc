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
//Print Functions
//====================================

//show armor details
void() printArmorPickups=
{
	sprint(self.owner,"armor pickup count G/Y/R:"); 
	sprint(self.owner,ftos( self.green_armors_collected )); sprint(self.owner,"/"); 
	sprint(self.owner,ftos( self.yellow_armors_collected )); sprint(self.owner,"/"); 
	sprint(self.owner,ftos( self.red_armors_collected )); 
	sprint(self.owner,"\n");
}


void() printPowerUps=
{
	sprint(self.owner,"powerup count/times quad:"); sprint(self.owner,ftos( self.quads_collected )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.quad_time )); 
			   sprint(self.owner," ring:"); sprint(self.owner,ftos( self.ring_collected ));  sprint(self.owner,"/"); sprint(self.owner,ftos( self.ring_time )); 
			   sprint(self.owner," pent:"); sprint(self.owner,ftos( self.pent_collected ));  sprint(self.owner,"/"); sprint(self.owner,ftos( self.pent_time )); 
			   sprint(self.owner," 100H:"); sprint(self.owner,ftos( self.super_health_collected ));
			   sprint(self.owner,"\n");
}

void() printPerWeaponDmg=
{
	sprint(self.owner,"dmg g/r a:"); sprint(self.owner,ftos( self.axe_damage_dealt )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.axe_damage_taken ));
	sprint(self.owner," s:"); sprint(self.owner,ftos( self.shotgun_damage_dealt ));  sprint(self.owner,"/"); sprint(self.owner,ftos( self.shotgun_damage_taken ));
	sprint(self.owner," ss:"); sprint(self.owner,ftos( self.sshotgun_damage_dealt )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.sshotgun_damage_taken ));
	sprint(self.owner," n:"); sprint(self.owner,ftos( self.nailgun_damage_dealt )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.nailgun_damage_taken ));
	sprint(self.owner," sn:"); sprint(self.owner,ftos( self.snailgun_damage_dealt )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.snailgun_damage_taken ));
	sprint(self.owner," g:"); sprint(self.owner,ftos( self.grenade_damage_dealt )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.grenade_damage_taken ));
	sprint(self.owner," r:"); sprint(self.owner,ftos( self.rocket_damage_dealt )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.rocket_damage_taken ));
	sprint(self.owner," l:"); sprint(self.owner,ftos( self.lightning_damage_dealt )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.lightning_damage_taken ));
	sprint(self.owner," ?:"); sprint(self.owner,ftos( self.other_damage_taken )); //other types of damage?? mosters, world, etc
	sprint(self.owner,"\n");
}

void() printWeaponTimes=
{	  
	sprint(self.owner,"weapon hold times a:"); sprint(self.owner,ftos( self.axe_time )); 
	sprint(self.owner," s:"); sprint(self.owner,ftos( self.shotgun_time )); 
	sprint(self.owner," ss:"); sprint(self.owner,ftos( self.sshotgun_time )); 
	sprint(self.owner," n:"); sprint(self.owner,ftos( self.nailgun_time )); 
	sprint(self.owner," sn:"); sprint(self.owner,ftos( self.snailgun_time )); 
	sprint(self.owner," g:"); sprint(self.owner,ftos( self.grenade_time )); 
	sprint(self.owner," r:"); sprint(self.owner,ftos( self.rocket_time )); 
	sprint(self.owner," l:"); sprint(self.owner,ftos( self.lightning_time )); 
	sprint(self.owner,"\n");
}


void() printAmmoPickUps=
{	  
	sprint(self.owner,"ammo pick ups s:"); sprint(self.owner,ftos( self.shells_collected )); 	
	sprint(self.owner," n:"); sprint(self.owner,ftos( self.nails_collected )); 	
	sprint(self.owner," r:"); sprint(self.owner,ftos( self.rockets_collected )); 
	sprint(self.owner," c:"); sprint(self.owner,ftos( self.cells_collected )); 
	sprint(self.owner,"\n");
}


void() printHitsMisses=
{	  
	sprint(self.owner,"hits a:"); sprint(self.owner,ftos( self.axe_shots_hits )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.axe_shots_fired ));
	sprint(self.owner," s: "); sprint(self.owner,ftos( self.shotgun_shots_hits ));  sprint(self.owner,"/"); sprint(self.owner,ftos( self.shotgun_shots_fired ));
	sprint(self.owner," ss: "); sprint(self.owner,ftos( self.sshotgun_shots_hits )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.sshotgun_shots_fired ));
	sprint(self.owner," n: "); sprint(self.owner,ftos( self.nailgun_shots_hits )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.nailgun_shots_fired ));
	sprint(self.owner," sn: "); sprint(self.owner,ftos( self.snailgun_shots_hits )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.snailgun_shots_fired ));
	sprint(self.owner," g: "); sprint(self.owner,ftos( self.grenade_shots_hits )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.grenade_shots_fired ));
	sprint(self.owner," r: "); sprint(self.owner,ftos( self.rocket_shots_hits )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.rocket_shots_fired ));
	sprint(self.owner," l: "); sprint(self.owner,ftos( self.lightning_shots_hits )); sprint(self.owner,"/"); sprint(self.owner,ftos( self.lightning_shots_fired ));
	sprint(self.owner,"\n");
}

void() printHealthCollected=
{
	sprint(self.owner,"health collected: ");
	sprint(self.owner,ftos(self.health_collected));
	sprint(self.owner,"\n");
}

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
	sprint(self.owner,"\n");
}

void() printAll=
{
	sprint(self.owner," Player Report:");
	sprint(self.owner, self.owner.netname);
	sprint(self.owner,"\n");
	printArmorPickups();
	//sprint(self.owner,"\n==================\n");
	//printHitsMisses();
	//printHealthCollected();
	//printPowerUps();
	//printAmmoPickUps();
	//printPerWeaponDmg();
	//printWeaponTimes();
	printMisc();
}

//====================================
//controller entity stuff
//====================================


void() statsThink=
{
	printAll();
	self.think = statsThink;
	self.nextthink = time + 0.1;
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