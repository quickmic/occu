proc getMinValue {param} {
  global psDescr
  upvar psDescr descr
  array_clear param_descr
  array set param_descr $descr($param)
  set min [format {%1.1f} $param_descr(MIN)]
  return "$min"
}

proc getMaxValue {param} {
  global psDescr
  upvar psDescr descr
  array_clear param_descr
  array set param_descr $descr($param)
  set max [format {%1.1f} $param_descr(MAX)]
  return "$max"
}

proc getMinMaxValueDescr {param} {
  global psDescr dev_descr
  upvar psDescr descr
  array_clear param_descr
  array set param_descr $descr($param)
  set min $param_descr(MIN)
  set max $param_descr(MAX)

  # SPHM-118 (the max value of the DRBL4 = autoconfig which isn't supported by this device)
  if {[string equal $dev_descr(TYPE) "HmIPW-DRBL4"] == 1} {
    set max [expr $param_descr(MAX) - 0.1]
  }

  set unit "noUnit"

  catch {set unit $param_descr(UNIT)}

  if {($unit == "100%") && ($max <= 1)} {
    set min [format %.0f [expr $min * 100]]
    set max [format %.0f [expr $max * 100]]
  }

  # Limit float to 2 decimal places
  if {[llength [split $min "."]] == 2} {
    set min [format {%1.2f} $min]
    set max [format {%1.2f} $max]
  }
  return "($min - $max)"
}

proc getUnit {param} {
  global psDescr
  upvar psDescr descr
  array_clear param_descr
  array set param_descr $descr($param)

  if { [catch {set unit $param_descr(UNIT)}]} {
    set unit "<span class=\"attention\">missing unit</span>"
  }

  if {$unit == "100%"} {
    set unit "%"
  }

  if {$unit == "minutes"} {
   set unit "\${lblMinutes}"
  }

  if {($unit == "K") || ($unit == "??C") || ($unit == "°C")} {
    set unit "&#176;C"
  }

  if {$unit == "_Grad_"} {
    set unit "&#176;"
  }

  return "$unit"
}

proc getTextField {param value chn prn {extraparam ""}} {
  global psDescr dev_descr
  upvar psDescr descr
  array_clear param_descr
  array set param_descr $descr($param)
  set minValue [format {%1.1f} $param_descr(MIN)]
  set maxValue [format {%1.1f} $param_descr(MAX)]

  # SPHM-118 (the max value of the DRBL4 = autoconfig which isn't supported by this device)
  if {[string equal $dev_descr(TYPE) "HmIPW-DRBL4"] == 1} {
    set maxValue [expr $param_descr(MAX) - 0.1]
  }

  set elemId 'separate_CHANNEL\_$chn\_$prn'

  # Limit float to 2 decimal places
  if {[llength [split $value "."]] == 2} {
    set value [format {%1.2f} $value]
  }

  set s "<input id=$elemId type=\"text\" size=\"5\" value=$value name=$param onblur=\"ProofAndSetValue(this.id, this.id, $minValue, $maxValue, 1)\" $extraparam>"
  return $s
}

proc getTextField100Percent {param value chn prn {extraparam ""}} {
  global psDescr
  upvar psDescr descr
  array_clear param_descr
  array set param_descr $descr($param)
  set minValue [format {%1.1f} $param_descr(MIN)]
  set maxValue [format {%1.1f} $param_descr(MAX)]

  set minValue [expr $minValue * 100]
  set maxValue [expr $maxValue * 100]

  set elemIdTmp 'separate_CHANNEL\_$chn\_$prn\_tmp'
  set elemId 'separate_CHANNEL\_$chn\_$prn'

  # Limit float to 2 decimal places
  if {[llength [split $value "."]] == 2} {
    set value [format {%1.2f} $value]
  }

  set s "<input id=$elemIdTmp type=\"text\" size=\"5\" value=[format %.0f [expr $value * 100]] name=$param\_tmp onblur="
  append s "\"ProofAndSetValue(this.id, this.id, $minValue, $maxValue, 1);"
  append s "jQuery('#separate_CHANNEL\_$chn\_$prn').val(this.value / 100);\">"

  append s "<input id=$elemId type=\"text\" size=\"5\" class=\"hidden\" value=$value name=$param>"
  return $s
}

proc getOptionBox {param options value chn prn {extraparam ""}} {
  upvar $options optionValues

  set s "<select id='separate_CHANNEL\_$chn\_$prn' name=$param $extraparam>"
  set select ""
  foreach val [lsort -real [array names optionValues]] {

     if {$val == $value} {
      set select "selected=\"selected\""
     } else {
      set select ""
     }

     append s "<option class=\"[extractParamFromTranslationKey $optionValues($val)]\" value=$val $select>$optionValues($val)</option>"
  }

  append s "</select>"

  return $s
}

proc getCheckBox {param value chn prn {extraparam ""}} {
  set checked ""
  if { $value } then { set checked "checked=\"checked\"" }
  set s "<input id='separate_CHANNEL\_$chn\_$prn' type='checkbox' $checked value='dummy' name=$param $extraparam>"
  return $s
}

# This is necessary because the parameter CYCLIC_INFO_MSG is an int instead of a bool
# Here we are mapping the int (text field 0 - 255) to a checkbox (bool)
proc getCheckBoxCyclicInfoMsg {param value chn prn {extraparam ""}} {
  global psDescr
  upvar psDescr psDescr

  set hlpBoxWidth  450
  set hlpBoxHeight  350

  set s  "[getCheckBox '$param' $value $chn $prn\_tmp "onchange=\"setCyclicInfoMsg(this, '$chn', '$prn');\""]&nbsp;[getHelpIcon $param $hlpBoxWidth $hlpBoxHeight]"
  append s  "<td class=\"hidden\">[getTextField $param $value $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

  append s "<script type=\"text/javascript\">"
    append s "setCyclicInfoMsg = function(elm, chn, prn) \{"
      append s " var value = (jQuery(elm).prop('checked')) ? 1 : 0; "
      # don`t use jQuery - the dirty flag will not be recognized
      append s " document.getElementById('separate_CHANNEL_' + chn + '_' + prn ).value = value; "
    append s "\};"
  append s "</script>"
  return $s
}

proc getButton {id btnTxt callBack} {
  set s "&nbsp<input id='$id' type=button onclick=$callBack>"
  # This translates the text of the button to the parameter btnTxt
  puts "<script type=\"text/javascript\">translateAttribute(\"#$id\", \"value\", $btnTxt);</script>"
  return $s
}

proc getButtonChannelConfiguration {{extraDescription ""}} {
  global dev_descr_sender
  set html ""

  # The extraDescription allows it to place a description freely as you wish
  # Without it, the default description will be used.
  # Example:
  #  Default description: [getButtonChannelConfiguration]
  #  Special description: [getButtonChannelConfiguration helpDecisionValAndThreshold]

  if {$extraDescription == ""} {
    append html "<tr><td colspan='2'>\${helpBtnChannelConfiguration}</td></tr>"
  } else {
    append html "<tr><td colspan='2'>\${$extraDescription}</td></tr>"
  }

  append html "<tr>"
  append html "<td>\${SENDER_CHANNEL_SETTINGS}</td>"
  append html "<td><input type=\"button\" value=\${btnEdit} onclick=\"WebUI.enter(DeviceConfigPage, {'iface': 'HmIP-RF','address': '$dev_descr_sender(ADDRESS)', 'redirect_url': 'IC_SETPROFILES'});\" ></td>"
  append html "</tr>"

  return $html
}

proc getHorizontalLine {{extraparam ""}} {
  return "<tr $extraparam><td colspan=\"2\"><hr></td></tr>"
}

proc getHelpIcon {topic {x 0} {y 0}} {

  # Default
  if {$x == 0} {set x 450}
  if {$y == 0} {set y 260}


  # Set the size for known parameters
  switch $topic {
   "BLIND_AUTOCALIBRATION" {set x 450; set y 75}
   "BLIND_REFERENCE_RUNNING_TIME" {set x 450; set y 160}
   "BLOCKING_PERIOD" {set x 450; set y 100}
   "BOOST_TIME_PERIOD" {set x 450; set y 120}
   "COND_TX_DECISION_ABOVE_BELOW" {set x 450; set y 80}
   "DELAY_COMPENSATION" {set x 450; set y 100}
   "DURATION_5MIN" {set x 500; set y 160}
   "ENABLE_ROUTING" {set x 500; set y 120}
   "EVENT_FILTER_NUMBER_motionDetect" {set x 400; set y 60}
   "EVENT_FILTER_PERIOD" {set x 450; set y 120}
   "EVENT_FILTER_TIME" {set x 400; set y 90}
   "HEATING_COOLING" {set x 450; set y 160}
   "HUMIDITY_LIMIT_DISABLE" {set x 500; set y 200}
   "LOCAL_RESET_DISABLED" {set x 500; set y 130}
   "OPTIMUM_START_STOP" {set x 450; set y 80}
   "PERMANENT_FULL_RX" {set x 500; set y 160}
   "ROUTER_MODULE_ENABLED" {set x 500; set y 120}
   "SPDR_CHANNEL_MODE" {set x 600; set y 600}
   "TEMPERATURE_OFFSET" {set x 500; set y 160}
   "TWO_POINT_HYSTERESIS" {set x 450; set y 160}
   "WEEK_PROGRAM_POINTER" {set x 400; set y 100}
   "WEEK_PROGRAM_POINTER_group" {set x 400; set y 100}

  }

  set ret "<img src=\"/ise/img/help.png\" style=\"cursor: pointer; width:18px; height:18px; position:relative; top:2px\" onclick=\"showParamHelp('$topic', '$x', '$y')\">"
  return $ret
}

proc _getParamDescrKey {param} {

  set lParam [lreplace [split $param "_"] 0 0]
  set _paramDescr ""
  foreach val $lParam {
    append _paramDescr "$val"
    append _paramDescr "_"
  }
  return [string trimright $_paramDescr "_"]
}

proc getTimeSelector {paramDescr p profile type prn special_input_id timebase optionValues {extraparam ""}} {

  # paramDescr        Text vor der Auswahlbox
  # p                 Paramset
  # profile           the profile (e. g. PROFILE_1)
  # type              delay delayShort timeOnOff timeOnOffShort (determines the kind of the optionbox)
  # prn               profile number
  # special_input_id  special_input_id
  # timebase          SHORT_ON_TIME
  # optionValues      Option values when entering a user specific value (Enter value)

  # Example
  # [getTimeSelector ON_TIME_FACTOR_DESCR ps PROFILE_$prn timeOnOff $prn $special_input_id SHORT_ONDELAY_TIME TIMEBASE_LONG]

  upvar $profile PROFILE
  upvar $p ps
  upvar pref pref
  upvar cur_profile cur_profile

  set timeBaseParam "$timebase\_BASE"
  set timeFactorParam "$timebase\_FACTOR"

  set paramBaseDescr [_getParamDescrKey $timeBaseParam]
  set paramFactorDescr [_getParamDescrKey $timeFactorParam]

  set javascriptDelay 100

  incr pref
  append html "<tr $extraparam>"
  append html "<td>\${$paramDescr}</td>"
  append html [getComboBox $prn $pref $special_input_id $type] ;# hmip_helper
  append html "</tr>"

  append html "<tr id=\"timeBase\_$prn\_$pref\" class=\"hidden\"><td>\${$paramBaseDescr}</td><td>"
  option $optionValues
  append html [get_ComboBox options $timeBaseParam separate_${special_input_id}_$prn\_$pref PROFILE $timeBaseParam]

  append html "</td></tr>"

  if {$prn == $cur_profile} {
    switch $type {
      delay {
        # setCurrentDelayOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }
      delayShort {
        # setCurrentDelayShortOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }
      timeOnOff {
        # setCurrentTimeOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }
      timeOnOffShort {
        # setCurrentTimeShortOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeShortOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }
      rampOnOff {
        # setCurrentRampOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentRampOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

      switchingInterval {
        # setCurrentSwitchingIntervalOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentSwitchingIntervalOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

      switchingIntervalOnTime {
        # setCurrentSwitchingIntervalOnTimeOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentSwitchingIntervalOnTimeOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

      delay0To20M_step2M {
        # setDelay0to20M_step2MOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setDelay0to20M_step2MOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

      alarmTimeMax10Min {
        # setDelay0to20M_step2MOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentAlarmTimeMax10MinOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

      blink {
        # setCurrentBlinkOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlinkOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

      blink0 {
        # setCurrentBlinkOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlinkOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

    }
  } else {
    switch $type {
      delay {
        # setCurrentDelayOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }
      delayShort {
        # setCurrentDelayShortOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }
      timeOnOff {
        # setCurrentTimeOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }
      timeOnOffShort {
        # setCurrentTimeShortOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeShortOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }
      rampOnOff {
        # setCurrentRampOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentRampOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }

      switchingInterval {
        # setCurrentSwitchingIntervalOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentSwitchingIntervalOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }

      delay0To20M_step2M {
        append html "<script type=\"text/javascript\">setTimeout(function() {setDelay0to20M_step2MOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }

      alarmTimeMax10Min {
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentAlarmTimeMax10MinOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }

      blink {
        # default 1s on / off
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlinkOption($prn, $pref, \"$special_input_id\",1,1);}, $javascriptDelay)</script>"
      }

      blink0 {
        # default 0s on / off
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlinkOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

    }
  }
  incr pref
  append html "<tr id=\"timeFactor\_$prn\_$pref\" class=\"hidden\"><td>\${$paramFactorDescr}</td>"

  append html "<td>[get_InputElem $timeFactorParam separate_${special_input_id}_$prn\_$pref ps $timeFactorParam onchange=ProofAndSetValue(this.id,this.id,0,31,1)]&nbsp;(0-31)</td>"
  append html "</tr>"
  append html "<tr id=\"space_$prn\_$pref\" class=\"hidden\"><td><br/></td></tr>"

  return $html

}

proc getPowerUpSelector {chn p special_input_id} {
  global psDescr dev_descr
  upvar psDescr psDescr
  upvar $p ps
  upvar prn prn

  set specialID "[getSpecialID $special_input_id]"

  set param POWERUP_JUMPTARGET
  incr prn
  set powerupModePrn $prn
  set html "<tr>"
    append html "<td>\${stringTableDimmerPowerUpAction}</td>"
    option POWERUP_JUMPTARGET_HMIP
    append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn "onchange=\"powerUP_showRelevantData($chn, this.value,true);\""]</td>"
  append html "</tr>"

  append html "<tr id=\"powerUpPanelON_$chn\"><td colspan=\"2\"><table>"
    ###
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableOnDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "delayShort"]
    append html "</tr>"

    set param POWERUP_ONDELAY_UNIT
    if { ! [catch {set tmp $ps($param)}]  } {

        append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

        incr prn
        set param POWERUP_ONDELAY_VALUE
        append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
        append html "<td>\${stringTableOnDelayValue}</td>"

        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

        append html "</tr>"
        append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
       append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
    }

    ###
    set param POWERUP_ONTIME_UNIT
    if { ! [catch {set tmp $ps($param)}]  } {
      incr prn
      append html "<tr>"
      append html "<td>\${stringTableOnTime}</td>"
      append html [getComboBox $chn $prn "$specialID" "timeOnOff"]
      append html "</tr>"

      append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

      incr prn
      set param POWERUP_ONTIME_VALUE
      append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableOnTimeValue}</td>"

      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

      append html "</tr>"
      append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
    }

    ###
    set param POWERUP_ON_LEVEL
    if { ! [catch {set tmp $ps($param)}]  } {
      incr prn
      set powerUpLevelPRN $prn
      append html "<tr>"
        append html "<td>\${stringTableDimmerLevel}</td>"
        option RAW_0_100Percent
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
      append html "</tr>"
    }


    set param POWERUP_OUTPUT_BEHAVIOUR
    if { ! [catch {set tmp $ps($param)}] } {
      if {[string equal $dev_descr(TYPE) HmIP-MP3P] == 1} {
        # set listColor "colorBLACK  colorBLUE colorGREEN colorTURQUOISE colorRED colorPURPLE colorYELLOW colorWHITE randomPlayback colorOldValue lblIgnore"
        set listColor "colorBLACK  colorBLUE colorGREEN colorTURQUOISE colorRED colorPURPLE colorYELLOW colorWHITE"
        set select ""
        incr prn
        append html "<tr>"
          append html "<td>\${lblColorValue}</td>"
          append html "<td>"
            append html "<select id='separate_CHANNEL\_$chn\_$prn' name=$param>"
              append html "<option value=\"253\" $select>\${randomPlayback}</option>"
              append html "<option value=\"254\" $select>\${colorOldValue}</option>"
              # append html "<option value=\"255\" $select>\${lblIgnore}</option>"
              for {set loop 0} {$loop <= [expr [llength $listColor] -1]} {incr loop} {
                if {$tmp == $loop} {set select "selected=\"selected\""} else {set select ""}
                append html "<option value=\"$loop\" $select>\${[lindex $listColor $loop]}</option>"
              }
            append html "</select>"
          append html "</td>"

          set param POWERUP_PROFILE_REPETITIONS
          if { ! [catch {set tmp $ps($param)}]  } {
            incr prn
            append html "<td>\${lblRepetition}</td>"
            append html "<td>"
              append html "<select id='separate_CHANNEL\_$chn\_$prn' name=$param>"
                append html "<option value=\"0\">\${optionNoRepetition}</option>"
                append html "<option value=\"255\">\${optionInfiniteRepetition}</option>"
                  for {set loop 1} {$loop <= 254} {incr loop} {
                    if {$tmp == $loop} {set select "selected=\"selected\""} else {set select ""}
                    append html "<option value=\"$loop\" $select>$loop</option>"
                  }
              append html "</select>"
              append html "[getHelpIcon repetitionOffTimeDimmer 450 100]"
            append html "</td>"
          }

          # Show this element only if the parameter POWERUP_PROFILE_REPETITIONS exits.
          # POWERUP_PROFILE_REPETITIONS works only if the value of the parameter OFFTIME is set != permanently
          set param POWERUP_OFFTIME_UNIT
          if { ! [catch {set tmp $ps(POWERUP_PROFILE_REPETITIONS)}]  } {
            incr prn
            append html "<tr>"
            append html "<td>\${stringTableOffTime}</td>"
            append html [getComboBox $chn $prn "$specialID" "blink"]
            append html "</tr>"

            append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

            incr prn
            set param POWERUP_OFFTIME_VALUE
            append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
            append html "<td>\${stringTableOffTimeValue}</td>"

            append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

            append html "</tr>"
            append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
            append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlinkOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
          }

        append html "</tr>"
      }
    }


  append html "</table></td></tr>"

# *******
  if { ! [catch {set tmp $ps(POWERUP_OFFTIME_UNIT)}]  } {
    append html "<tr id=\"powerUpPanelOFF_$chn\"><td><table>"

      set comment {
        set param POWERUP_OFFDELAY_UNIT
        if { ! [catch {set tmp $ps($param)}]  } {
          incr prn
          append html "<tr>"
          append html "<td>\${stringTableOffDelay}</td>"
          append html [getComboBox $chn $prn "$specialID" "delayShort"]
          append html "</tr>"

          append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

          incr prn
          set param POWERUP_OFFDELAY_VALUE
          append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
          append html "<td>\${stringTableOffDelayValue}</td>"

          append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

          append html "</tr>"
          append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
          append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
        }
      }
      ###
      set param POWERUP_OFFTIME_UNIT
      if { ! [catch {set tmp $ps($param)}]  } {
        incr prn
        append html "<tr>"
        append html "<td>\${stringTableOffTime}</td>"
        append html [getComboBox $chn $prn "$specialID" "timeOnOff"]
        append html "</tr>"

        append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

        incr prn
        set param POWERUP_OFFTIME_VALUE
        append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
        append html "<td>\${stringTableOffTimeValue}</td>"

        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

        append html "</tr>"
        append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
      }

      ###
      set param POWERUP_OFF_LEVEL
      if { ! [catch {set tmp $ps($param)}]  } {
        incr prn
        append html "<tr>"
          append html "<td>\${stringTableDimmerLevel}</td>"
          option RAW_0_100Percent
          append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
        append html "</tr>"
      }
    append html "</table></td></tr>"
  }
# *******

  append html "<script type=\"text/javascript\">"

    append html "powerUP_showRelevantData = function(chn, val, valChanged) {"
      append html "var panelOnElm = jQuery(\"#powerUpPanelON_\" + chn),"
      append html "panelOffElm = jQuery(\"#powerUpPanelOFF_\" + chn);"
      append html "switch (parseInt(val)) {"
        append html "case 0:"
          # OFF
          append html "jQuery(\"#timeDelay_\" + chn + \"_7\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_8\").val(0).change().prop(\"disabled\", true);"
          # append html "jQuery(\"#timeDelay_\" + chn + \"_9\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_10\").val(0).change().prop(\"disabled\", true);"
          #catch {append html "jQuery(\"#separate_CHANNEL_\" + chn + \"_$powerUpLevelPRN\").val(0);"}
          append html "panelOnElm.hide();"
          append html "panelOffElm.show();"
          append html "break;"
        append html "case 1:"
          # ON_DELAY
          append html "jQuery(\"#timeDelay_\" + chn + \"_2\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_3\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_4\").prop(\"disabled\", false);"
          catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_$powerUpLevelPRN\").val(100);}"}
          append html "panelOnElm.show();"
          append html "panelOffElm.hide();"
          append html "break;"
        append html "case 2:"
          # ON
          append html "jQuery(\"#timeDelay_\" + chn + \"_2\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_3\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_4\").val(0).change().prop(\"disabled\", true);"
          catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_$powerUpLevelPRN\").val(100);}"}
          append html "panelOnElm.show();"
          append html "panelOffElm.hide();"
          append html "break;"
        append html "case 3:"
          # OFF_DELAY
          append html "jQuery(\"#timeDelay_\" + chn + \"_7\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_8\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_9\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_10\").prop(\"disabled\", false);"
          append html "panelOnElm.hide();"
          append html "panelOffElm.show();"
          append html "break;"
        append html "default:"
          append html "panelOnElm.show();"
          append html "panelOffElm.show();"
      append html "}"
    append html "};"

    append html "window.setTimeout(function() {"
      append html "var selectedPowerMode = jQuery(\"#separate_CHANNEL_$chn\_$powerupModePrn\").val();"
      append html "powerUP_showRelevantData($chn, selectedPowerMode, false);"
    append html "},100);"
  append html "</script>"
  return $html
}


# ***********

proc getPowerUpSelectorAcousticSignal {chn p special_input_id} {
  global psDescr
  upvar psDescr psDescr
  upvar $p ps
  upvar prn prn

  set specialID "[getSpecialID $special_input_id]"

  set powerOutputBehaviourPrn 0

  set param POWERUP_JUMPTARGET
  incr prn
  set powerupModePrn $prn
  set html "<tr>"
    append html "<td>\${stringTableDimmerPowerUpAction}"
      set options(0) "\${stringTableStateFalse}"
      set options(1) "\${stringTableOnDelay}"
      set options(2) "\${stringTableStateTrue}"
      # set options(3) "\${stringTableOffDelay}"
      append html  "&nbsp;[getOptionBox '$param' options $ps($param) $chn $prn "onchange=\"powerUPAcousticSignal_showRelevantData($chn, this.value, true, true);\""]"
    append html "</td>"
  append html "</tr>"

  append html "<tr id=\"powerUpPanelON_$chn\"><td colspan=\"2\"><table>"
    ###
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableOnDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "delayShort"]
    append html "</tr>"

    set param POWERUP_ONDELAY_UNIT
    if { ! [catch {set tmp $ps($param)}]  } {

        append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

        incr prn
        set param POWERUP_ONDELAY_VALUE
        append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
        append html "<td>\${stringTableOnDelayValue}</td>"

        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

        append html "</tr>"
        append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"

      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"

    }

    ###
    set param POWERUP_ONTIME_UNIT
    if { ! [catch {set tmp $ps($param)}]  } {
      incr prn
      append html "<tr>"
      append html "<td>\${stringTableOnTime}</td>"
      append html [getComboBox $chn $prn "$specialID" "timeOnOff"]
      append html "</tr>"

      append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

      incr prn
      set param POWERUP_ONTIME_VALUE
      append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableOnTimeValue}</td>"

      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

      append html "</tr>"
      append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
    }

    ###
    set param POWERUP_ON_LEVEL
    if { ! [catch {set tmp $ps($param)}]  } {
      incr prn
      set powerUpLevelPRN $prn
      append html "<tr>"
        append html "<td>\${lblVolume}</td>"
        option RAW_0_100Percent
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
      append html "</tr>"
    }

    set param POWERUP_OUTPUT_BEHAVIOUR
    if { ! [catch {set tmp $ps($param)}]  } {
      set select ""
      incr prn
      set powerOutputBehaviourPrn $prn
      append html "<tr>"
        append html "<td>\${lblSoundFileNr}</td>"
        append html "<td>"
          append html "<select id='separate_CHANNEL\_$chn\_$prn' name=$param onchange='selectedFileHint(this.value, $chn)'>"
            if {$tmp == 0} {set select "selected=\"selected\""}
            append html "<option value=\"0\" $select>\${internalSystemSound}</option>"
            if {$tmp == 253} {set select "selected=\"selected\""} else {set select ""}
            append html "<option value=\"253\" $select>\${randomPlayback}</option>"
            if {$tmp == 254} {set select "selected=\"selected\""} else {set select ""}
            append html "<option value=\"254\" $select>\${soundOldValue}</option>"
            # if {$tmp == 255} {set select "selected=\"selected\""} else {set select ""}
            # append html "<option value=\"255\" $select>\${lblIgnore}</option>"
            for {set loop 1} {$loop <= 252} {incr loop} {
              if {$tmp == $loop} {set select "selected=\"selected\""} else {set select ""}
              append html "<option value=\"$loop\" $select>$loop</option>"
            }
          append html "</select>"
        append html "</td>"

        set param POWERUP_PROFILE_REPETITIONS
        if { ! [catch {set tmp $ps($param)}]  } {
          incr prn
          append html "<td>\${lblRepetition}</td>"
          append html "<td>"
            append html "<select id=\"separate_CHANNEL\_$chn\_$prn\" name=$param>"
              append html "<option value=\"0\">\${optionNoRepetition}</option>"
              append html "<option value=\"255\">\${optionInfiniteRepetition}</option>"
                for {set loop 1} {$loop <= 254} {incr loop} {
                  if {$tmp == $loop} {set select "selected=\"selected\""} else {set select ""}
                  append html "<option value=\"$loop\" $select>$loop</option>"
                }
            append html "</select>"
            append html "[getHelpIcon repetitionOffTimeSound 450 100]"
          append html "</td>"
        }
      append html "</tr>"

      append html "<tr id=\"soundFileHint_$chn\" class=\"hidden\">"
        append html "<td></td><td colspan=\"2\">\${hintSoundFileRandom20}</td>"
      append html "</tr>"

          set param POWERUP_OFFTIME_UNIT
          if { ! [catch {set tmp $ps($param)}]  } {
            incr prn
            append html "<tr>"
            append html "<td>\${stringTableOffTime}</td>"
            append html [getComboBox $chn $prn "$specialID" "blink"]
            append html "</tr>"

            append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

            incr prn
            set param POWERUP_OFFTIME_VALUE
            append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
            append html "<td>\${stringTableOffTimeValue}</td>"

            append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

            append html "</tr>"
            append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
            append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlinkOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
          }

    }



  append html "</table></td></tr>"

set comment {
  append html "<tr id=\"powerUpPanelOFF_$chn\"><td><table>"
    ### OFF
    set param POWERUP_OFFDELAY_UNIT
    if { ! [catch {set tmp $ps($param)}]  } {
      incr prn
      append html "<tr>"
      append html "<td>\${stringTableOffDelay}</td>"
      append html [getComboBox $chn $prn "$specialID" "delayShort"]
      append html "</tr>"

      append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

      incr prn
      set param POWERUP_OFFDELAY_VALUE
      append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableOffDelayValue}</td>"

      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

      append html "</tr>"
      append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
    }

    set param POWERUP_OFFTIME_UNIT
    if { ! [catch {set tmp $ps($param)}]  } {
      incr prn
      append html "<tr>"
      append html "<td>\${stringTableOffTime}</td>"
      append html [getComboBox $chn $prn "$specialID" "timeOnOff"]
      append html "</tr>"

      append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

      incr prn
      set param POWERUP_OFFTIME_VALUE
      append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableOffTimeValue}</td>"

      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

      append html "</tr>"
      append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlinkOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
    }

    set param POWERUP_OFF_LEVEL
    if { ! [catch {set tmp $ps($param)}]  } {
      incr prn
      append html "<tr>"
        append html "<td>\${lblVolume}</td>"
        option RAW_0_100Percent
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
      append html "</tr>"
    }
  append html "</table></td></tr>"
}

  append html "<script type=\"text/javascript\">"

    append html "selectedFileHint = function(val, chn) {"
      append html "if (val == \"253\") {"
        # 253 = RANDOM_SOUNDFILE
        append html "jQuery(\"#soundFileHint_\" + chn).show();"
      append html "} else {"
        append html "jQuery(\"#soundFileHint_\" + chn).hide();"
      append html "}"
    append html "};"

    append html "powerUPAcousticSignal_showRelevantData = function(chn, val, valChanged) {"
      append html "var panelOnElm = jQuery(\"#powerUpPanelON_\" + chn),"
      append html "panelOffElm = jQuery(\"#powerUpPanelOFF_\" + chn);"
      append html "switch (parseInt(val)) {"
        append html "case 0:"
          # OFF
          append html "jQuery(\"#timeDelay_\" + chn + \"_7\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_8\").val(0).change().prop(\"disabled\", true);"
          # append html "jQuery(\"#timeDelay_\" + chn + \"_9\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#separate_CHANNEL_\" + chn + \"_$powerUpLevelPRN\").val(0);"
          append html "panelOnElm.hide();"
          append html "panelOffElm.hide();"
          append html "break;"
        append html "case 1:"
          # ON_DELAY
          append html "jQuery(\"#timeDelay_\" + chn + \"_2\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_3\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_4\").prop(\"disabled\", false);"
          catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_$powerUpLevelPRN\").val(100);}"}
          append html "panelOnElm.show();"
          append html "panelOffElm.hide();"
          append html "break;"
        append html "case 2:"
          # ON
          append html "jQuery(\"#timeDelay_\" + chn + \"_2\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_3\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_4\").val(0).change().prop(\"disabled\", true);"
          catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_$powerUpLevelPRN\").val(100);}"}
          append html "panelOnElm.show();"
          append html "panelOffElm.hide();"
          append html "break;"
        append html "case 3:"
          # OFF_DELAY
          append html "jQuery(\"#timeDelay_\" + chn + \"_7\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_8\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_9\").prop(\"disabled\", false);"
          append html "panelOnElm.hide();"
          append html "panelOffElm.hide();"
          append html "break;"
        append html "default:"
          append html "panelOnElm.show();"
          append html "panelOffElm.show();"
      append html "}"
    append html "};"

    append html "window.setTimeout(function() {"
      append html "var selectedPowerMode = jQuery(\"#separate_CHANNEL_$chn\_$powerupModePrn\").val();"
      append html "var selectedSoundFile = jQuery(\"#separate_CHANNEL_$chn\_$powerOutputBehaviourPrn\").val();"
      append html "powerUPAcousticSignal_showRelevantData($chn, selectedPowerMode, false);"
      append html "if (selectedSoundFile == '253') {"
        append html "selectedFileHint(selectedSoundFile, $chn)"
      append html "}"
    append html "},100);"
  append html "</script>"
  return $html
}

proc getAcousticdDisplayReceiverConfig {special_input_id chn valText valAlignment valBgColor valTextColor valIcon} {
  upvar prn prn

  set specialID "[getSpecialID $special_input_id]"

    set html "<tr>"
      append html "<td colspan=\"2\"><table><tbody style=\"background-color:white\">"
        append html "<tr>"
          append html "<th>\${lblText}</th>"
          append html "<th>\${lblAlign}</th>"
          append html "<th>\${lblBGColorBR}</th>"
          append html "<th>\${lblTextColorBR}</th>"
          append html "<th>\${lblIcon}</th>"
          append html "</tr>"
        append html "<tr>"
          # TEXT
          append html "<td>"
            append html "<input id='separate_$special_input_id\_$prn' name='TEXT' type='text' value='$valText' maxlength='15' size='15'>"
            append html "<script type=\"text/javascript\">"
              append html "var elm = document.getElementById('separate_$special_input_id\_$prn');"
              append html "elm.defaultValue = elm.value;"
            append html "</script>"

          append html "</td>"
          incr prn

          # Align
          set selLeft ""
          set selCenter ""
          set selRight ""
          if {$valAlignment == 0} {set selLeft  "selected=\"selected\"" }
          if {$valAlignment == 1} {set selCenter  "selected=\"selected\"" }
          if {$valAlignment == 2} {set selRight  "selected=\"selected\"" }
          append html "<td>"
            append html "<select class='centerSelect' id='separate_$special_input_id\_$prn' name='TEXT_ALIGNMENT' onchange='setTextAlignment(this.value, $chn, [expr $prn - 1]);'>"
              append html "<option value='0' $selLeft>\${lblLeft}</option>"
              append html "<option value='1' $selCenter>\${lblCenter}</option>"
              append html "<option value='2' $selRight>\${lblRight}</option>"
            append html "</select>"
          append html "</td>"
          append html "<script type=\"text/javascript\">"
            append html "var elm = document.getElementById('separate_$special_input_id\_$prn');"
            append html "elm.defaultSelected = elm.value;"

            append html "setTextAlignment = function(alignment, chn, prevElmPrn) \{"
              append html "var align = \['left', 'center', 'right'\];"
              append html "var textElm = jQuery(\"\#separate\_$specialID\_\"\+chn+\"_\"+prevElmPrn);"
              append html "textElm.attr(\"style\", \"text-align:\" + align\[alignment\]);"
            append html "\};"

            append html "setTextAlignment($valAlignment, $chn, [expr $prn - 1]);"

          append html "</script>"
          incr prn

          # BgColor
          set colorWhite ""
          set colorBlack ""
          set colorRed ""
          if {$valBgColor == 0} {set colorWhite  "selected=\"selected\"" }
          if {$valBgColor == 1} {set colorBlack  "selected=\"selected\"" }
          if {$valBgColor == 2} {set colorRed  "selected=\"selected\"" }
          append html "<td>"
            append html "<select class='centerSelect' id='separate_$special_input_id\_$prn' name='TEXT_BACKGROUND_COLOR'>"
              append html "<option value='0' $colorWhite >\${colorWHITE}</option>"
              append html "<option value='1' $colorBlack>\${colorBLACK_A}</option>"
              append html "<option value='2' $colorRed>\${colorRED}</option>"
            append html "</select>"
          append html "</td>"
          append html "<script type=\"text/javascript\">"
            append html "var elm = document.getElementById('separate_$special_input_id\_$prn');"
            append html "elm.defaultSelected = elm.value;"
           append html "</script>"
          incr prn

          # TextColor
          set colorWhite ""
          set colorBlack ""
          set colorRed ""
          if {$valTextColor == 0} {set colorWhite  "selected=\"selected\"" }
          if {$valTextColor == 1} {set colorBlack  "selected=\"selected\"" }
          if {$valTextColor == 2} {set colorRed  "selected=\"selected\"" }
          append html "<td>"
            append html "<select class='centerSelect' id='separate_$special_input_id\_$prn' name='TEXT_COLOR'>"
              append html "<option value='0' $colorWhite >\${colorWHITE}</option>"
              append html "<option value='1' $colorBlack>\${colorBLACK_A}</option>"
              append html "<option value='2' $colorRed>\${colorRED}</option>"
            append html "</select>"
          append html "</td>"
          append html "<script type=\"text/javascript\">"
            append html "var elm = document.getElementById('separate_$special_input_id\_$prn');"
            append html "elm.defaultSelected = elm.value;"
           append html "</script>"
          incr prn

          # Icon
          append html "<td>"
            append html "<select class='centerSelect' id='separate_$special_input_id\_$prn' name='TEXT_ICON' onchange='setIconPreview(this.value, \"$chn\")'>"
              set iconCounter 0
              foreach icon {stringTableNotUsed iconLampOff iconLampOn iconPadlockOpen iconPadlockClosed iconX iconTick iconInfo iconEnvelope iconWrench iconSun iconMoon iconWind
              iconCloud iconCloudBolt iconCloudLightRain iconCloudMoon iconCloudRain iconCloudSnow iconCloudSun iconCloundSunRain iconSnowFlake iconRainDrop iconFlame
              iconWindowOpen iconShutter iconEco iconProtectionOff iconProtectionExternal iconProtectionInternal iconBell iconClock} {
                append html "<option value='$iconCounter'>\${$icon}</option>"
                incr iconCounter
              }
            append html "</select>"
          append html "</td>"
          append html "<td id=\"iconPreview_$chn\"></td>"

          append html "<script type=\"text/javascript\">"
            append html "setIconPreview = function(picNr, chn) \{"
              append html "var picPath = \"/ise/img/icons_hmip_wrcd/24/\","
              append html "previewElm = jQuery(\"\#iconPreview_\"+chn);"

              append html "if (picNr != 0) \{"
                append html "previewElm.html(\" <img src='\" + picPath + picNr + \".png' alt='' style = 'height:20px; background-color:\#f0f0f0;'>\");"
              append html "\} else \{"
                append html "previewElm.html(\"\");"
              append html "\}"

            append html "\};"

            append html "window.setTimeout(function() \{"
              append html "jQuery(\"\#separate\_$special_input_id\_$prn option\[value='$valIcon'\]\").prop(\"selected\",true).change();"

              append html "var elm = document.getElementById('separate_$special_input_id\_$prn');"
              append html "elm.options\[elm.selectedIndex\].defaultSelected = elm.value;"
            append html "\},100);"
          append html "</script>"
          incr prn
        append html "</tr>"
      append html "</tbody></table></td>"
    append html "</tr>"
  return $html
}