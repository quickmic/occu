source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/uiElements.tcl]
source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/hmip_helper.tcl]
source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/hmipDSTPanel.tcl]
source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/options.tcl]


proc isDevFALMOT {device} {
  set result "false"
  if {[string first "-FALMOT-" $device] != -1} {
    set result "true"
  }
  return $result
}

proc getNoParametersToSet {} {
  return "<tr><td class=\"CLASS22003\"><div class=\"CLASS22004\">\${deviceAndChannelParamsLblNoParamsToSet}</div></td></tr>"
}

proc getMaintenanceFloorHeating {chn p descr} {
  global dev_descr

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set CHANNEL $special_input_id

  set devIsHmIPWired [isDevHmIPW $dev_descr(TYPE)]
  set devIsFalmot [isDevFALMOT $dev_descr(TYPE)]
  set html ""

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HmIP-FAL_MIOB.js');load_JSFunc('/config/easymodes/MASTER_LANG/HEATINGTHERMOSTATE_2ND_GEN.js');;load_JSFunc('/config/easymodes/MASTER_LANG/HmIP-ParamHelp.js');</script>"

  set prn 0

  set param CYCLIC_INFO_MSG
  if { ! [catch {set tmp $ps($param)}] } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableCyclicInfoMsg}</td>"
      append html  "<td>[getCheckBoxCyclicInfoMsg $param $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param CYCLIC_INFO_MSG_DIS
  if { ! [catch {set tmp $ps($param)}] } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableCyclicInfoMsgDis}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param CYCLIC_INFO_MSG_DIS_UNCHANGED
  if { ! [catch {set tmp $ps($param)}] } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableCyclicInfoMsgDisUnChanged}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param LOCAL_RESET_DISABLED
  if { ! [catch {set tmp $ps($param)}] } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableLocalResetDisable}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param ENABLE_ROUTING
  if { ! [catch {set tmp $ps($param)}]} {
    if {$devIsHmIPWired == "false"} {
      incr prn
      append html "<tr>"
       append html "<td>\${stringTableEnableRouting}</td>"
       append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
      append html "</tr>"
    }
  }

  incr prn
  append html "[getDSTPanel ps psDescr]"

  append html "[getHorizontalLine]"

  set param COOLING_EMERGENCY_PWM_SIGNAL
  if { ! [catch {set tmp $ps($param)}]} {
    incr prn
    append html "<tr>"
      append html "<td>\${lblCoolingEmergencyPWMSignal}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;* 100[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param HEATING_EMERGENCY_PWM_SIGNAL
  if { ! [catch {set tmp $ps($param)}]} {
    incr prn
    append html "<tr>"
      append html "<td>\${lblHeatingEmergencyPWMSignal}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;* 100[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param FROST_PROTECTION_TEMPERATURE
  if { ! [catch {set tmp $ps($param)}]} {
    incr prn
    append html "<tr>"
      append html "<td>\${lblFrostProtectionTemperature}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param HEATING_LOAD_TYPE
  if { ! [catch {set tmp $ps($param)}]} {
    incr prn
    append html "<tr>"
      append html "<td>\${lblHeatingLoadType}</td>"
      option HEATING_LOAD_TYPE
      append html  "<td>[getOptionBox $param options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param HEATING_PUMP_CONTROL
  if { ! [catch {set tmp $ps($param)}]} {
    incr prn
    append html "<tr>"
      append html "<td>\${lblHeatingPumpControl}</td>"
      option HEATING_PUMP_CONTROL
      append html  "<td>[getOptionBox $param options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param HEATING_VALVE_TYPE
  if { ! [catch {set tmp $ps($param)}]} {
    incr prn
    append html "<tr>"
      append html "<td>\${lblHeatingValveType}</td>"
      option HEATING_VALVE_TYPE
      append html  "<td>[getOptionBox $param options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  # SPHM-308
  if {$devIsFalmot == "false"} {

    # SWITCHING_INTERVAL_BASE and INTERVAL_FACTOR

    set param SWITCHING_INTERVAL_BASE
    if { ! [catch {set tmp $ps($param)}]} {
      append html "[getHorizontalLine]"
      incr prn
      append html "<tr>"
      append html "<td>\${lblDecalcificationInterval}</td>"
      append html [getComboBox $chn $prn "$specialID" "switchingInterval"]
      append html "</tr>"


      append html [getTimeUnitComboBoxB $param $ps($param) $chn $prn $special_input_id]

      incr prn
      set param SWITCHING_INTERVAL_FACTOR
      append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableSwitchingIntervalValue}</td>"

      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

      append html "</tr>"
      append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentSwitchingIntervalOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"

      # END SWITCHING_INTERVAL_BASE and INTERVAL_FACTOR

      # ON_TIME_BASE and ON_TIME_FACTOR

      incr prn
      append html "<tr>"
      append html "<td>\${stringTableOnTime}</td>"
      append html [getComboBox $chn $prn "$specialID" "switchingIntervalOnTime"]
      append html "</tr>"

      set param ON_TIME_BASE
      append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

      incr prn
      set param ON_TIME_FACTOR
      append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableOnTimeValue}</td>"

      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

      append html "</tr>"
      append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentSwitchingIntervalOnTimeOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"

      # END ON_TIME_BASE and ON_TIME_FACTOR
     }
  } else {
    set param DECALCIFICATION_WEEKDAY
    if { ! [catch {set tmp $ps($param)}]} {
      append html "[getHorizontalLine]"
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableClimateControlRegDecalcDay}</td>"

        append html "<td>"
           append html "<select id='separate_$CHANNEL\_$prn' class='SUNDAY' name='DECALCIFICATION_WEEKDAY'>"
            append html "<option value='0'>\${optionSun}</option>"
            append html "<option value='1'>\${optionMon}</option>"
            append html "<option value='2'>\${optionTue}</option>"
            append html "<option value='3'>\${optionWed}</option>"
            append html "<option value='4'>\${optionThu}</option>"
            append html "<option value='5'>\${optionFri}</option>"
            append html "<option value='6'>\${optionSat}</option>"
          append html "</select>"
        append html "</td>"

      append html "</tr>"
      append html "<script type=\"text/javascript\">jQuery('\#separate_$CHANNEL\_$prn\').val($ps($param));</script>"
      append html "<tr>"
        incr prn
        set param  DECALCIFICATION_TIME
        array_clear options
        for {set i 0} {$i <= 23} {incr i} {
          set hour $i
          if {$i < 10} {set hour "0$i"}
          set options([expr $i * 2]) "$hour:00"
        }
        append html "<td>\${stringTableClimateControlRegDecalcTime}</td>"
        append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]</td>"

      append html "</tr>"
    }
  }

  return $html
}

proc getClimateControlHeatDemandBoilerTransmitter {chn p descr} {

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set html ""

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HmIP-FAL_MIOB.js');</script>"

  append html "<tr>"
  append html "<td>\${lblLeadTime}</td>"
  append html [getComboBox $chn $prn "$specialID" "delay0To20M_step2M"]
  append html "</tr>"

  set param ONDELAY_TIME_BASE
  append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

  incr prn
  set param ONDELAY_TIME_FACTOR
  append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
  append html "<td>\${stringTableSwitchingIntervalValue}</td>"

  append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

  append html "</tr>"
  append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
  append html "<script type=\"text/javascript\">setTimeout(function() {setDelay0to20M_step2MOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"

  # next
  incr prn;
  append html "<tr>"
  append html "<td>\${lblFollowUpTime}</td>"
  append html [getComboBox $chn $prn "$specialID" "delay0To20M_step2M"]
  append html "</tr>"

  set param OFFDELAY_TIME_BASE
  append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

  incr prn
  set param OFFDELAY_TIME_FACTOR
  append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
  append html "<td>\${stringTableSwitchingIntervalValue}</td>"

  append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

  append html "</tr>"
  append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
  append html "<script type=\"text/javascript\">setTimeout(function() {setDelay0to20M_step2MOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"

  return $html
}


proc getClimateControlHeatDemandPumpTransmitter {chn p descr} {

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set html ""

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HmIP-FAL_MIOB.js');</script>"

  set prn 0

  set param ONDELAY_TIME_BASE
  if { ! [catch {set tmp $ps($param)}]  } {
    incr prn;
    append html "<tr>"
    append html "<td>\${lblLeadTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "delay0To20M_step2M"]
    append html "</tr>"

    append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param ONDELAY_TIME_FACTOR
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableSwitchingIntervalValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setDelay0to20M_step2MOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  # next
  set param OFFDELAY_TIME_BASE
  if { ! [catch {set tmp $ps($param)}]  } {
    incr prn;
    append html "<tr>"
    append html "<td>\${lblFollowUpTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "delay0To20M_step2M"]
    append html "</tr>"

    append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param OFFDELAY_TIME_FACTOR
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableSwitchingIntervalValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setDelay0to20M_step2MOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  # next
  set param SWITCHING_INTERVAL_BASE
  if { ! [catch {set tmp $ps($param)}]  } {
    incr prn;
    append html "<tr>"
    append html "<td>\${lblDecalcificationInterval}</td>"
    append html [getComboBox $chn $prn "$specialID" "switchingInterval"]
    append html "</tr>"

    append html [getTimeUnitComboBoxB $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param SWITCHING_INTERVAL_FACTOR
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableSwitchingIntervalValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentSwitchingIntervalOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  # next
  set param ON_TIME_BASE
  if { ! [catch {set tmp $ps($param)}]  } {
    incr prn;
    append html "<tr>"
    append html "<td>\${stringTableOnTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "switchingIntervalOnTime"]
    append html "</tr>"

    append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param ON_TIME_FACTOR
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableOnTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentSwitchingIntervalOnTimeOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  return $html
}