(
SetProperty photometricLight_ActiveLight #type "Free_Point"
SetProperty photometricLight_ActiveLight #useKelvin off
SetProperty photometricLight_ActiveLight #kelvin 2800.
SetProperty photometricLight_ActiveLight #distribution 3
SetProperty photometricLight_ActiveLight #intensityType 0
if ProductAppID == #VIZR then
(
	SetProperty photometricLight_ActiveLight #webfile ((getDir #maxroot) + "ies\\point_recessed_medium_75W.ies")
	--LOC NOTE: do not localize this
)
else
(
	SetProperty photometricLight_ActiveLight #webfile ((getDir #maxroot) + "sceneassets\\photometric\\point_recessed_medium_75W.ies")
	--LOC NOTE: do not localize this
)
SetProperty photometricLight_ActiveLight #Flux 1100.0
SetProperty photometricLight_ActiveLight #useMultiplier on
)