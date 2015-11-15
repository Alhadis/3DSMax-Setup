/*
Arch&Design (mi) material template script

Revision history:
	Jun 2006, initial implementation, Pierre-Felix Breton

Description:

Script populating the currently used mrArch & Design material with predefined values.
The material to operate on is passed through global variable mrArchTemplate_ActiveMaterial

*/

(
	SetProperty mrArchTemplate_ActiveMaterial #opts_ao_on true

	SetProperty mrArchTemplate_ActiveMaterial #opts_ao_samples 8
	SetProperty mrArchTemplate_ActiveMaterial #opts_ao_distance (InchesToSystemScale(4)) --sets the distance to about 4 inches and adapt it to the units setup of the model
	SetProperty mrArchTemplate_ActiveMaterial #opts_ao_dark (color 51 51 51)
	SetProperty mrArchTemplate_ActiveMaterial #opts_ao_use_global_ambient true
	SetProperty mrArchTemplate_ActiveMaterial #opts_ao_ambient (color 0 0 0)
	SetProperty mrArchTemplate_ActiveMaterial #opts_ao_do_details true
)
