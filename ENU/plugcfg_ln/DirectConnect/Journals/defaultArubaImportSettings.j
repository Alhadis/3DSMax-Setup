# This file should be installed with the Max Direct Connect Import
# plug-in.  It is an Aruba journal file, and provides default
# settings for DC to use during import.

# Note to Users: Be careful when modifying this file.  Make a backup copy so
# that default settings can be easily restored. Various options can interfere
# with the import process used by 3ds Max DC import.  For example, using
# "create unloadfile" can sometimes interfere with the ability to run multiple
# imports during the same run of 3ds Max, by tying up the temporary
# APF file.  Using "edit autostitch createnewmodel true" prevents the
# importer from bringing in any geometry unless the spline data is
# regenerated after the autostitch via "create splinefit".  However,
# disabling createnewmodel prevents the autostitch from taking full effect.
# Also, make sure to *close this file* before running an import, as the
# import may sometimes crash if this file is in use by other programs.

edit autostitch createnewmodel true
edit autostitch separatestyles true
edit autostitch separatelayers true
edit autostitch tolerance 0.1
create autostitch
create splinefit true true true