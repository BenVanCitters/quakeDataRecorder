# quakeDataRecorder
example of player data analytics 
A example pattern for how player stats like kills to deaths ('k/d ratio') or accuracy or favorite weapon can be determined.

stats are shown via 'impulse 100' in game

JSON output is printed to the in-game console at the end of multiplayer games

## Currently included records

**WEAPONS/DAMAGE**
*  Total death count
*  suicide count
*  Total kill count
*  Damage dealt with each weapon (axe-lightning gun)
*  Damage received from each weapon (axe-lightning gun)
*  Other Damage received from the world, falling, smashing, etc
*  Individuialized number of times the player fired weapons (axe-lightning gun)
*  Individuialized number of times the player scored hits with each weapons (axe-lightning gun) 
*  Duration of time the player had each weapon selected
*  Kills per minute, avg. life span, K/D ratio, etc

**ITEMS**
*  Individual amounts of ammo collected (shells, nails, rockets, cells)
*  Total points of healing collected
*  Number of times power ups collected (ring of shadows, pentagram of protection, mega health, quad damage)
*  Duration the player held each powerup in the game (ring of shadows, pentagram of protection, quad damage)
*  Number of times each armor(green/yellow/red) was collected 

**MISC**
*  How far the player walked, moved, jumped...
*  How long the player is/was alive
*  How long the player was in the water

