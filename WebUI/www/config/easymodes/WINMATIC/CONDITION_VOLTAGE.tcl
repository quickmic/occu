#!/bin/tclsh

source [file join $env(DOCUMENT_ROOT) config/easymodes/em_common.tcl]
source [file join $env(DOCUMENT_ROOT) config/easymodes/EnterFreeValue.tcl]
source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/options.tcl]


set PROFILES_MAP(0) "\${expert}"
set PROFILES_MAP(1) "\${window_tilt}"
set PROFILES_MAP(2) "\${window_close}"

set PROFILE_0(UI_HINT)	0
set PROFILE_0(UI_DESCRIPTION)	"Expertenprofil"
set PROFILE_0(UI_TEMPLATE)	"Expertenprofil"

# hier folgen die verschiedenen Profile

set PROFILE_1(SHORT_CT_RAMPOFF)	0
set PROFILE_1(SHORT_CT_RAMPON)	0
set PROFILE_1(SHORT_CT_OFF)	0
set PROFILE_1(SHORT_CT_ON)	0
set PROFILE_1(SHORT_COND_VALUE_LO)	50
set PROFILE_1(SHORT_COND_VALUE_HI)	100
set PROFILE_1(SHORT_JT_OFF)			2
set PROFILE_1(SHORT_JT_ON)			2
set PROFILE_1(SHORT_JT_RAMPOFF)		6
set PROFILE_1(SHORT_JT_RAMPON)		7
set PROFILE_1(SHORT_OFF_LEVEL)		-0.005
set PROFILE_1(SHORT_OFF_TIME)		111600.0
set PROFILE_1(SHORT_ON_LEVEL)		1
set PROFILE_1(SHORT_ON_TIME)		111600.0
set PROFILE_1(SHORT_RAMPOFF_SPEED)	1
set PROFILE_1(SHORT_RAMPON_SPEED)	1
set PROFILE_1(UI_DESCRIPTION)	""
set PROFILE_1(UI_TEMPLATE)		$PROFILE_1(UI_DESCRIPTION)
set PROFILE_1(UI_HINT)	1

set PROFILE_2(SHORT_CT_RAMPOFF)	0
set PROFILE_2(SHORT_CT_RAMPON)	0
set PROFILE_2(SHORT_CT_OFF)	0
set PROFILE_2(SHORT_CT_ON)	0
set PROFILE_2(SHORT_COND_VALUE_HI)	100
set PROFILE_2(SHORT_COND_VALUE_LO)	50
set PROFILE_2(SHORT_JT_OFF)			5
set PROFILE_2(SHORT_JT_ON)			5
set PROFILE_2(SHORT_JT_RAMPOFF)		5
set PROFILE_2(SHORT_JT_RAMPON)		5
set PROFILE_2(SHORT_OFF_LEVEL)		-0.005
set PROFILE_2(SHORT_OFF_TIME)		111600.0
set PROFILE_2(SHORT_ON_LEVEL)		1
set PROFILE_2(SHORT_ON_TIME)		111600.0
set PROFILE_2(SHORT_RAMPOFF_SPEED)	1
set PROFILE_2(SHORT_RAMPON_SPEED)	1
set PROFILE_2(UI_DESCRIPTION)	""
set PROFILE_2(UI_TEMPLATE)		$PROFILE_2(UI_DESCRIPTION)
set PROFILE_2(UI_HINT)	2


# hier folgen die eventuellen Subsets

proc set_htmlParams {iface address pps pps_descr special_input_id peer_type} {

	global dev_descr_sender dev_descr_receiver  
	upvar PROFILES_MAP  PROFILES_MAP
	upvar HTML_PARAMS   HTML_PARAMS
	upvar PROFILE_PNAME PROFILE_PNAME
	upvar $pps          ps      
	upvar $pps_descr    ps_descr
	
	foreach pro [array names PROFILES_MAP] {
		upvar PROFILE_$pro PROFILE_$pro
	}
	 		
	set cur_profile [get_cur_profile2 ps PROFILES_MAP PROFILE_TMP $peer_type]
	
	#global SUBSETS
	set name "x"
	set i 1
	while {$name != ""} {
		upvar SUBSET_$i SUBSET_$i
		array set subset [array get SUBSET_$i]
		set name ""
		catch {set name $subset(NAME)}
		array_clear subset
		incr i
	}
#	die Texte der Platzhalter einlesen
	puts "<script type=\"text/javascript\">getLangInfo('CONDITION_X', '$dev_descr_receiver(TYPE)');</script>"
	set prn 0	
	append HTML_PARAMS(separate_$prn) "<div id=\"param_$prn\"><textarea id=\"profile_$prn\" style=\"display:none\">"
	append HTML_PARAMS(separate_$prn) [cmd_link_paramset2 $iface $address ps_descr ps "LINK" ${special_input_id}_$prn]
	append HTML_PARAMS(separate_$prn) "</textarea></div>"

# hier folgt die Profildarstellung
#1
	incr prn
	set pref 1
	if {$cur_profile == $prn} then {array set PROFILE_$prn [array get ps]}
	append HTML_PARAMS(separate_$prn) "<div id=\"param_$prn\"><textarea id=\"profile_$prn\" style=\"display:none\">"
	append HTML_PARAMS(separate_$prn) "\${description_$prn} \${descrHint}"
	append HTML_PARAMS(separate_$prn) "<table class=\"ProfileTbl\">"

	append HTML_PARAMS(separate_$prn) "<tr><td>\${WINDOW_OPEN_LEVEL}</td><td>"
	option WINDOW_OPEN_LEVEL
	append HTML_PARAMS(separate_$prn) [get_ComboBox options SHORT_ON_LEVEL separate_${special_input_id}_$prn\_$pref PROFILE_$prn SHORT_ON_LEVEL]
	append HTML_PARAMS(separate_$prn) "</td></tr>"

	incr pref ;# 2
	append HTML_PARAMS(separate_$prn) "<tr><td>\${WINDOW_RUNNING_SPEED}&nbsp;\${when_tilting}</td><td>"
	option WINDOW_RUNNING_SPEED
	append HTML_PARAMS(separate_$prn) [get_ComboBox options SHORT_RAMPON_SPEED separate_${special_input_id}_$prn\_$pref PROFILE_$prn SHORT_RAMPON_SPEED]
	append HTML_PARAMS(separate_$prn) "</td></tr>"

	append HTML_PARAMS(separate_$prn) "</table></textarea></div>"

#2
	incr prn
	set pref 1
	if {$cur_profile == $prn} then {array set PROFILE_$prn [array get ps]}
	append HTML_PARAMS(separate_$prn) "<div id=\"param_$prn\"><textarea id=\"profile_$prn\" style=\"display:none\">"
	append HTML_PARAMS(separate_$prn) "\${description_$prn} \${descrHint}"
	append HTML_PARAMS(separate_$prn) "<table class=\"ProfileTbl\">"

	append HTML_PARAMS(separate_$prn) "<tr><td>\${ACTION}</td><td>"
	array_clear options
	set options(0) "\${only_close}"
	set options(-0.005) "\${close_lock}"
	append HTML_PARAMS(separate_$prn) [get_ComboBox options SHORT_OFF_LEVEL separate_${special_input_id}_$prn\_$pref PROFILE_$prn SHORT_OFF_LEVEL]
	append HTML_PARAMS(separate_$prn) "</td></tr>"

	incr pref ;# 2
	append HTML_PARAMS(separate_$prn) "<tr><td>\${WINDOW_RUNNING_SPEED}&nbsp;\${when_closing}</td><td>"
	option WINDOW_RUNNING_SPEED
	append HTML_PARAMS(separate_$prn) [get_ComboBox options SHORT_RAMPOFF_SPEED separate_${special_input_id}_$prn\_$pref PROFILE_$prn SHORT_RAMPOFF_SPEED]
	append HTML_PARAMS(separate_$prn) "</td></tr>"

	append HTML_PARAMS(separate_$prn) "</table></textarea></div>"

}

constructor
