-- MacroScript File
-- Created:       Feb 09 2005
-- Last Modified: Feb 25 2005
-- Medit Utilities
-- Version: 3dsmax 8
-- Author: Alexander Esppeschit Bicalho, Discreet
-- Modified: Alexander Esppeschit Bicalho, Discreet
--***********************************************************************************************
-- MODIFY THIS AT YOUR OWN RISK

/* History

Feb 09 - created script
Feb 10 - fixed problem where defaults.ini uses Hex number and ClassID is an Int
Feb 10 - added Restore Medit Slots script
Feb 11 - added Localization Notes
Feb 25 - added Condense Medit
Feb 25 - moved functions to meditfunctions.ms in StdScripts

NOTE TO LOCALIZATION
Only the headers should be localized

*/

macroScript clear_medit_slots 
enabledIn:#("MAX", "VIZ")
	category:"Medit Tools" 
	internalCategory:"Medit Tools"
	ButtonText:"Reset Material Editor Slots" 
	tooltip:"Reset Material Editor Slots"
(


on execute do(
	defaultsFile	=	MeditUtilities.getDefaultsFile()
	defaultMtl		=	MeditUtilities.getDefaultMaterial defaultsFile
	global _meditMaterialsBeforeReset = #()
	for i in 1 to meditMaterials.count do(
		append _meditMaterialsBeforeReset meditMaterials[i]
		index	=	(if(i < 10) then "0" else "") + (i as String);
		matName	=	index + " - Default";
		blank				=	(classof defaultMtl)();
		blank.name			=	matName;
		meditMaterials[i]	=	blank;
	)
--	medit.SetActiveMtlSlot (medit.GetActiveMtlSlot()) true
)

)

macroScript restore_medit_slots 
enabledIn:#("MAX", "VIZ")
	category:"Medit Tools" 
	internalCategory:"Medit Tools"
	ButtonText:"Restore Material Editor Slots" 
	tooltip:"Restore Material Editor Slots"
(

on isEnabled do (if classof _meditMaterialsBeforeReset == Array do _meditMaterialsBeforeReset.count > 0)

on execute do
(
	if _meditMaterialsBeforeReset.count == meditMaterials.count do
	(
		for i in 1 to meditMaterials.count do
		(	
			meditMaterials[i] = _meditMaterialsBeforeReset[i]
		)
		_meditMaterialsBeforeReset = undefined
	)
)

)

macroScript condense_medit_slots 
enabledIn:#("MAX", "VIZ")
	category:"Medit Tools" 
	internalCategory:"Medit Tools"
	ButtonText:"Condense Material Editor Slots" 
	tooltip:"Condense Material Editor Slots"
(


on execute do
(
	usedMtls = #()
	for i in 1 to meditMaterials.count do
	(
		if MeditUtilities.isMaterialInUse meditMaterials[i] == true do
			append usedMtls meditMaterials[i]
	)
	defaultsFile = MeditUtilities.getDefaultsFile()
	defaultMtl = MeditUtilities.getDefaultMaterial defaultsFile
	global _meditMaterialsBeforeReset = #()
	for i in 1 to meditMaterials.count do
	(	
		append _meditMaterialsBeforeReset meditMaterials[i]
		if i <= usedMtls.count then
			meditMaterials[i] = usedMtls[i]
		else
			meditMaterials[i] = defaultMtl name:(defaultMtl.localizedName + #'_' as string + i as string)
	)
)

)