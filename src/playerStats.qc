
.float distance_travelled;
.float rocket_time;
.float times_died;
.float kills;
.float damage_done;
.float damage_taken;
.entity statsController;


void(entity statsController) resetStats=
{
	statsController.distance_travelled = 0;
	statsController.rocket_time = 0;
	statsController.times_died = 0;
	statsController.kills = 0;
	statsController.rocket_time = 0;
	statsController.damage_done = 0;
	statsController.damage_taken = 0;
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

void() statsThink=
{
	sprint(self.owner,"dmg dealt: ");
	sprint(self.owner,ftos(self.damage_done));
	sprint(self.owner,", recvd: ");
	sprint(self.owner,ftos(self.damage_taken));
	sprint(self.owner,", K/D: ");
	sprint(self.owner,ftos(self.kills));
	sprint(self.owner,"/");
	sprint(self.owner,ftos(self.times_died));
	sprint(self.owner,"\n");
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