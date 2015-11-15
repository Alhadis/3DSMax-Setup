(
SetProperty photometricLight_ActiveLight #type "Target_Point"
SetProperty photometricLight_ActiveLight #useKelvin off
SetProperty photometricLight_ActiveLight #kelvin 3000.
SetProperty photometricLight_ActiveLight #distribution 3
SetProperty photometricLight_ActiveLight #intensityType 0
if ProductAppID == #VIZR then
(
	SetProperty photometricLight_ActiveLight #webfile ((getDir #maxroot) + "ies\\point_stadium.ies")
	--LOC NOTE: do not localize this
)
else
(
	--SetProperty photometricLight_ActiveLight #webfile ((getDir #maxroot) + "sceneassets\\photometric\\point_stadium.ies")
	SetProperty photometricLight_ActiveLight #webfile ((getDir #maxroot) + "sceneassets\\photometric\\point_stadium.ies")
	--LOC NOTE: do not localize this
)
SetProperty photometricLight_ActiveLight #Flux 110000.0
SetProperty photometricLight_ActiveLight #useMultiplier on
)
