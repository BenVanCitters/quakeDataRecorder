
.float distance_travelled;
.float times_died;
.float kills;
.float damage_done;
.float damage_taken;

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

.entity statsController;


void(entity statsController) resetStats=
{
	statsController.axe_shots_hits = 0;
	statsController.shotgun_shots_hits = 0;
	statsController.sshotgun_shots_hits = 0;
	statsController.nailgun_shots_hits = 0;
	statsController.snailgun_shots_hits = 0;
	statsController.grenade_shots_hits = 0;
	statsController.rocket_shots_hits = 0;
	statsController.lightning_shots_hits = 0;

	statsController.axe_shots_fired = 0;
	statsController.shotgun_shots_fired = 0;
	statsController.sshotgun_shots_fired = 0;
	statsController.nailgun_shots_fired = 0;
	statsController.snailgun_shots_fired = 0;
	statsController.grenade_shots_fired = 0;
	statsController.rocket_shots_fired = 0;
	statsController.lightning_shots_fired = 0;
	
	statsController.axe_time = 0;
	statsController.shotgun_time = 0;
	statsController.sshotgun_time = 0;
	statsController.nailgun_time = 0;
	statsController.snailgun_time = 0;
	statsController.grenade_time = 0;
	statsController.rocket_time = 0;
	statsController.lightning_time = 0;
	
	statsController.distance_travelled = 0;
	statsController.rocket_time = 0;
	statsController.times_died = 0;
	statsController.kills = 0;
	statsController.rocket_time = 0;
	statsController.damage_done = 0;
	statsController.damage_taken = 0;
}



void(entity statsController) addWeaponHit=
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
float(entity statsController) getTotalHits=
{
	return statsController.axe_shots_hits + statsController.shotgun_shots_hits + statsController.sshotgun_shots_hits + 
	statsController.nailgun_shots_hits + statsController.snailgun_shots_hits + statsController.grenade_shots_hits + 
	statsController.rocket_shots_hits +  statsController.lightning_shots_hits;
}

void(entity statsController, float duration) addWeaponTime=
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

float(entity statsController) getTotalShotsFired=
{
	return statsController.axe_shots_fired + statsController.shotgun_shots_fired + statsController.sshotgun_shots_fired + 
	 statsController.nailgun_shots_fired + statsController.snailgun_shots_fired + statsController.grenade_shots_fired + 
	  statsController.rocket_shots_fired + statsController.lightning_shots_fired; 
}

void(entity statsController) recordShotFired=
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

void(entity statsController) recordDied=
{
	statsController.times_died = statsController.times_died  + 1;
}

void(entity statsController) recordKill=
{
	statsController.kills = statsController.kills  + 1;
}

void(entity statsController, float dmg) recordDamageDealt=
{
	statsController.damage_done = statsController.damage_done + dmg;
}

void(entity statsController, float dmg) recordDamageReceived=
{
	statsController.damage_taken = statsController.damage_taken + dmg;
}

void(entity statsController, float distance) addDistance=
{
	statsController.distance_travelled = statsController.distance_travelled + distance;
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

void() printAll=
{
	sprint(self.owner,"dmg dealt: ");
	sprint(self.owner,ftos(self.damage_done));
	sprint(self.owner,", recvd: ");
	sprint(self.owner,ftos(self.damage_taken));
	sprint(self.owner,", K/D: ");
	sprint(self.owner,ftos(self.kills));
	sprint(self.owner,"/");
	sprint(self.owner,ftos(self.times_died));
	sprint(self.owner," dist: ");
	sprint(self.owner,ftos( self.distance_travelled ));
	sprint(self.owner," shots hit/ttl: ");
	sprint(self.owner,ftos( getTotalHits(self) ));
	sprint(self.owner,"/");
	sprint(self.owner,ftos( getTotalShotsFired(self) ));
	sprint(self.owner,"\n");
}
void() statsThink=
{
	printHitsMisses();
	
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
	resetStats(playerStatsController);
	self.statsController = playerStatsController;
}