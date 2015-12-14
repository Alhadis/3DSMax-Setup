(
SetProperty photometricLight_ActiveLight #type "Free_Linear"
SetProperty photometricLight_ActiveLight #useKelvin off
SetProperty photometricLight_ActiveLight #kelvin 2940.
SetProperty photometricLight_ActiveLight #distribution 3
SetProperty photometricLight_ActiveLight #intensityType 0

SetProperty photometricLight_ActiveLight #webfile ((getDir #maxroot) + "sceneassets\\photometric\\linear_cove.ies")

SetProperty photometricLight_ActiveLight #Flux 3200.0
SetProperty photometricLight_ActiveLight #light_length (InchesToSystemScale(48))--calls a dimension conversion function defined in the \stdplugs\editfunction.ms
SetProperty photometricLight_ActiveLight #zrotation 90
SetProperty photometricLight_ActiveLight #useMultiplier on
)