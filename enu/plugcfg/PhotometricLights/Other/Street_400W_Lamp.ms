(
SetProperty photometricLight_ActiveLight #type "Free_Point"	
SetProperty photometricLight_ActiveLight #useKelvin off
SetProperty photometricLight_ActiveLight #kelvin 1800.
SetProperty photometricLight_ActiveLight #distribution 3
SetProperty photometricLight_ActiveLight #intensityType 0
if ProductAppID == #VIZR then
(
	SetProperty photometricLight_ActiveLight #webfile ((getDir #maxroot) + "ies\\point_street.ies")
	--LOC NOTE: do not localize this
)
else
(
	SetProperty photometricLight_ActiveLight #webfile ((getDir #maxroot) + "sceneassets\\photometric\\point_street.ies")
	--LOC NOTE: do not localize this
)
SetProperty photometricLight_ActiveLight #Flux 50000.0
SetProperty photometricLight_ActiveLight #useMultiplier on
)