macroScript ToggleMeditLock category:"Krakatoa" tooltip:"Toggle Material Editor Renderer Lock To Production Renderer" icon:#("Maintoolbar",66)
(
	on isChecked return renderers.medit_locked
	on execute do renderers.medit_locked = not renderers.medit_locked
)
