checkWPFixedTime = function(thisElm, chn, prn) {
  var sTime = thisElm.value,
    arTime = sTime.split(":"),
    hr = parseInt(arTime[0]),
    min = parseInt(arTime[1]),
    elmHr = jQuery("#separate_CHANNEL_" + chn + "_" + prn),
    elmMin = jQuery("#separate_CHANNEL_" + chn + "_" + (parseInt(prn) + 1));

  hr = ((hr >= 0) && (hr <= 23)) ? hr : 0;
  min = ((min >= 0) && (min <= 59)) ? min : 0;

  elmHr.val(hr);
  elmMin.val(min);

  hr = (hr < 10) ? "0"+hr : hr.toString();
  min = (min < 10) ? "0"+min : min.toString();
  thisElm.value = hr + ":" + min;
};

checkWPMinMaxValue = function(thisElm, min, max) {
  var value = parseInt(thisElm.value);

  if (isNaN(value)) {thisElm.value = 0;} else {thisElm.value = value;}
  if (value < parseInt(min)) thisElm.value = min;
  if (value > parseInt(max)) thisElm.value = max;
};

setWPWeekday = function(thisElm, chn, prn) {
  var targetElm = jQuery("#separate_CHANNEL_"+chn+"_"+prn),
  iActiveWeekdays = parseInt(targetElm.val()),
  selectedVal = parseInt(thisElm.value);

  if (thisElm.checked) {
    iActiveWeekdays += selectedVal;
  } else {
    iActiveWeekdays -= selectedVal;
  }

  this.curWeekdays = iActiveWeekdays;

  targetElm.val(iActiveWeekdays);

};

reverseString = function (str) {
    return str.split("").reverse().join("");
};

setWPTargetChannels = function(thisElm, chn, prn) {
  var targetElm = jQuery("#separate_CHANNEL_"+chn+"_"+prn),
   iActiveChannels = parseInt(targetElm.val()),
   selectedVal = parseInt(thisElm.value);

  if (thisElm.checked) {
    iActiveChannels += selectedVal;
  } else {
    iActiveChannels -= selectedVal;
  }

  this.curTargetChannels = iActiveChannels;

  targetElm.val(iActiveChannels);

};

getOnlyNonExpertChannels = function(devId, chn) {
  var result = null,
  arEasyChannels = [];
  chn = parseInt(chn);

  var arNonExpertChannels = [];

  arNonExpertChannels["HMIP-FDT"] = [2];
  arNonExpertChannels["HMIP-FSM"] = [2];
  arNonExpertChannels["HMIP-FSM16"] = [2];
  arNonExpertChannels["HMIP-PCBS"] = [3];
  arNonExpertChannels["HMIP-PCBS-BAT"] = [3];
  arNonExpertChannels["HMIP-PCBS2"] = [4, 8];
  arNonExpertChannels["HMIP-PDT"] = [3];
  arNonExpertChannels["HMIP-PDT-UK"] = [3];
  arNonExpertChannels["HMIP-PS"] = [3];
  arNonExpertChannels["HMIP-PSM"] = [3];
  arNonExpertChannels["HMIP-PSM-CH"] = [3];
  arNonExpertChannels["HMIP-PSM-IT"] = [3];
  arNonExpertChannels["HMIP-PSM-PE"] = [3];
  arNonExpertChannels["HMIP-PSM-UK"] = [3];

  arNonExpertChannels["HMIP-BBL"] = [4];
  arNonExpertChannels["HMIP-BDT"] = [4];
  arNonExpertChannels["HMIP-BROLL"] = [4];
  arNonExpertChannels["HMIP-BSM"] = [4];
  arNonExpertChannels["HMIP-FBL"] = [4];
  arNonExpertChannels["HMIP-FROLL"] = [4];


  arNonExpertChannels["HMIP-BSL"] = [4,8,12];
  arNonExpertChannels["HMIP-MOD-OC8"] = [10,14,18,22,26,30,34,38];
  arNonExpertChannels["HMIP-WHS2"] = [3,7];
  arNonExpertChannels["HMIP-MIOB"] = [2,6];
  arNonExpertChannels["HMIP-MP3P"] = [2,6];
  arNonExpertChannels["HMIPW-DRBL4"] = [2,6,10,14];
  arNonExpertChannels["HMIPW-DRD3"] = [2,6,10];
  arNonExpertChannels["HMIPW-DRS4"] = [2,6,10,14];
  arNonExpertChannels["HMIPW-DRS8"] = [2,6,10,14,18,22,26,30];
  arNonExpertChannels["HMIPW-FIO6"] = [8,12,16,20,24,28];
  arNonExpertChannels["HMIP-MIO16-PCB"] = [18,22,26,30,34,38,42,46];

  jQuery.each(arNonExpertChannels[devId.toUpperCase()], function(index,val) {
    if (val == chn){
      result = chn;
      return false; // leave the each loop
    }
  });

  return result;
};

getWPVirtualChannels = function(devId, channels, expert) {
  var result = [];

  jQuery.each(channels, function(index, chn) {
    var virtualChID = "_VIRTUAL_RECEIVER",
      noExpertChn;
    if (chn.channelType.indexOf(virtualChID) !== -1) {
      if (expert == 1) {
        result.push(index);
      } else {
       noExpertChn = getOnlyNonExpertChannels(devId, index);
        if (noExpertChn) {
          result.push(noExpertChn);
        }
      }
    }
  });
  return result;
};

HmIPWeeklyProgram = Class.create();

HmIPWeeklyProgram.prototype = {
  initialize: function (address, ps, psDescr, sessionIsExpert) {
    self = this;

    this.DIMMER = "DIMMER_WEEK_PROFILE";
    this.DIMMER_OUTPUT_BEHAVIOUR = "DIMMER_OUTPUT_BEHAVIOUR_WEEK_PROFILE";
    this.SWITCH = "SWITCH_WEEK_PROFILE";
    this.BLIND = "BLIND_WEEK_PROFILE";

    this.address = address;
    this.arAddress = this.address.split(":");
    this.devAddress = this.arAddress[0];
    this.chn = this.arAddress[1];

    this.device = DeviceList.getDeviceByAddress(this.devAddress);
    this.isWired = (this.device.deviceType.id.split("-")[0] == "HmIPW") ? true : false;

    this.chnType = (this.device.channels[this.chn].channelType == this.DIMMER_OUTPUT_BEHAVIOUR) ? this.DIMMER : this.device.channels[this.chn].channelType;

    // The device type of the HmIP-BSL is DIMMER_WEEK_PROFILE but the weekly program should act as a SWITCH_WEEK_PROFILE
    this.chnType = (this._isDeviceType("HmIP-BSL")) ? this.SWITCH : this.chnType;

    this.ps = ps;
    this.psDescr = psDescr;
    this.sessionIsExpert = sessionIsExpert;
    this.prn = 0;
    this.weekDayID = [];
    this.condition = []; // selected value of the parameter WP_CONDITION (_getConditionElm)
    this.activeEntries = []; // active week programs
    this.numberOfActiveEntries = 0;
    this.curWeekdays = 0;
    this.curTargetChannels = 0;
    this.targetChannelTypes = {};

    this.targetChannelTypesVirtualBlind = [];  // only in use for some wired blinds which can be used as a shutter

    this.anchor = jQuery("#weeklyProgram_" + this.chn);
    this.maxEntries = this._getMaxEntries();

    this.virtualChannels = getWPVirtualChannels(this.device.deviceType.id, this.device.channels, this.sessionIsExpert);

    // The HmIP-BSL consists of SWITCH and DIMMER channels. For the weekly program we are currently using only the SWITCH channels.
    if (this._isDeviceType("HmIP-BSL")) {
      this.virtualChannels = (this.sessionIsExpert) ? [4, 5, 6] : [4];
    }

    this._getTargetChannelTypes();

    this.devHasVirtualBlindReceiver = (this.isWired) ? this.hasActiveVirtualBlindReceiver() : true;
    //this.devHasVirtualBlindReceiver = this.hasActiveVirtualBlindReceiver();

    var table = "";
    table += "<table class='ProfileTbl'><tbody>";

    table += "<tr id='weeklyProgramNotActive'><td>"+translateKey('lblWeeklyProgramNotActive')+"</td></tr>";

    table += this._getDelAddElm("ADD_FIRST_ELEM", 0);

    for (var i = 1; i <= this.maxEntries; i++) {
      table += this._getEntry((i < 10) ? "0" + i : i.toString());
    }
    table += "</tbody></table>";

    this.anchor.html(table);

    if ((this.numberOfActiveEntries > 0) && (this.activeEntries["01"] == true)) {
      window.setTimeout(function() {
        jQuery("#weeklyProgramNotActive").hide();
        jQuery("#btnAddNewEntry0").hide();
      }, 250);
    } else if ((this.numberOfActiveEntries > 0) && (this.activeEntries["01"] == false)) {
      window.setTimeout(function() {
        jQuery("#weeklyProgramNotActive").hide();
      }, 250);
    }
  },

  hasActiveVirtualBlindReceiver: function() {
    var result = false,
      self = this;
      jQuery.each(this.virtualChannels, function (index, chnId) {
        var chType = self.device.channels[chnId].virtChannelType;

        self.targetChannelTypesVirtualBlind.push(chType);

        if (chType == "BLIND_VIRTUAL_RECEIVER") {
          result = true;
        }
      });

    return result;
  },


  // Checks if the device type is of a particular kind
  // This is useful for the treatment of special cases (e.g. the HmIP-BSL which is a DIMMER_WEEKLY_PROFILE but must be treated as a SWITCH_WEEKLY_PROFILE
  _isDeviceType: function(devType) {
    return (this.device.deviceType.id == devType) ? true : false;
  },

  _getEntry: function(number) {
    var programEntry = "";
    var extraClass = "hidden";
    var entryVisibilityCSS = "hidden";

    this._setEntryVisibility(number);

    if (this.activeEntries[number] == true) {
      entryVisibilityCSS = "";
      this.numberOfActiveEntries++;
    }


    showSlatPosHelp = function() {
      var width = 400,
      height = 75;
      MessageBox.show(translateKey("HmIPWPSlatPosHelpTitle"), translateKey("HmIPWPSlatPosHelp"), "", width, height);
    };

    programEntry += "<tr id='entry"+number+"' class="+entryVisibilityCSS+"><td><table>";
      programEntry += "<tbody>";
      programEntry += "<tr><td colspan='6'><hr class='CLASS10400'></td></tr>";
      programEntry += "<tr><td>"+translateKey('lblWeeklyProgramSwitchpoint')+ number +"</td></tr>";
        programEntry += "<tr>";
          programEntry += "<td>";

            // CONDITION
            programEntry += "<tr>";
              programEntry += "<td>"+translateKey('lblWPCondition')+"</td>";
              programEntry += "<td colspan='3'>" + this._getConditionElm(number) + "</td>";
            programEntry += "</tr>";

            if (this.condition[number] != 0) {extraClass = "";} else {extraClass="hidden";}

            // ASTRO / FIXED TIME
            programEntry += "<tr id='astroTypeOffset_"+number+"' class="+extraClass+">";
              programEntry += "<td>"+translateKey('lblWPAstroType')+"</td><td>" + this._getAstroType(number) + "</td>";
              programEntry += "<td>"+translateKey('lblWPAstroOffset')+"</td><td>" + this._getAstroOffset(number) + "</td>";
            programEntry += "</tr>";

            if (this.condition[number] == 0 || this.condition[number] > 1) {extraClass="";} else {extraClass="hidden";}

            // FIXED TIME
            programEntry += "<tr id='fixedTime_"+number+"' class="+extraClass+">";
              programEntry += "<td>"+translateKey('lblWPFixedTime')+"</td>";
              programEntry +=" <td>" + this._getFixedTime(number) + "</td>";
            programEntry += "</tr>";

            programEntry += this._getHR();

            // RAMPTIME / LEVEL
            programEntry += "<tr>";
              if (this.chnType == this.DIMMER) {
                // RAMPTIME
                programEntry += "<td id='lblWPRamptime_" + number + "'>" + translateKey('lblWPRamptime') + "</td>";
                programEntry += "<td>" + this._getRampTime(number) + "</td>";
              }

              // LEVEL
              if ((this.chnType == this.DIMMER)) {
                programEntry += "<td id='lblWPBrightness_" + number + "'>" + translateKey('lblWPBrightness') + "</td>";
              } else if (this.chnType == this.SWITCH) {
                programEntry += "<td>" + translateKey('lblWPState') + "</td>"; // Is Level, but we call it here state because it's only on/off
              } else if (this.chnType == this.BLIND) {
                programEntry += "<td>" + translateKey('lblWPBlindLevel') + "</td>";
              }

              programEntry += "<td>" + this._getLevel(number) + "</td>";

              // SLAT LEVEL for Blinds
              if (this.chnType == this.BLIND && this.devHasVirtualBlindReceiver) {
                programEntry += "<td name='elmSlatPos_"+number+"'>" + translateKey('lblWPSlatLevel') + "</td>";
                programEntry += "<td name='elmSlatPos_"+number+"'>" + this._getSlatLevel(number);
                if (this.isWired) {
                  programEntry += "<img src='/ise/img/help.png' style='cursor: pointer; width:18px; height:18px; position:relative; top:2px' alt='' onclick='showSlatPosHelp();'>";
                }
                programEntry += "</td>";
              }

              // Song no. and color of channel type DIMMER_OUTPUT_BEHAVIOUR
              if (this.device.channels[this.chn].channelType == this.DIMMER_OUTPUT_BEHAVIOUR) {
                this.prn++;
                programEntry += "<td name='lblWPColorSelector_" + number + "' class='hidden'>"+translateKey('lblColorNr')+": </td></td><td name='lblWPColorSelector_" + number + "' class='hidden'>"+this._getColorSelector(number)+"</td>";
                programEntry += "<td name='lblWPSoundSelector_" + number + "' class='hidden'>"+translateKey('lblSoundFileNr')+": </td><td name='lblWPSoundSelector_" + number + "' class='hidden'>"+this._getSoundSelector(number)+"</td>";
                programEntry += "<td name='lblWPColorSoundSelector_" + number + "' class='hidden'>"+translateKey('lblColorSongNr')+": </td><td name='lblWPColorSoundSelector_" + number + "' class='hidden'>"+this._getColorSoundSelector(number)+"</td>";
              }

            programEntry += "</tr>";

                // DURATION
            if ((this.chnType == this.DIMMER) || (this.chnType == this.SWITCH)) {
              programEntry += "<tr id='trDurationMode"+number+"'>";
              programEntry += "<td>" + translateKey('lblWPDuration') + "</td>";
              programEntry += "<td>" + this._getDurationMode(number) + "</td>";
              programEntry += "</tr>";

              programEntry += "<tr id='trDurationValue" + number + "'>";
              programEntry += "<td></td>";
              programEntry += "<td>" + this._getDuration(number) + "</td>";
              programEntry += "</tr>";
            }

            programEntry += this._getHR();

            // WEEKDAY
            programEntry += "<tr>";
              programEntry += "<td>"+ translateKey('lblWPWeekday') +"</td>";
              programEntry += "<td colspan='3'>"+ this._getWeekDay(number) +"</td>";
            programEntry += "</tr>";

            // TARGET CHANNELS
            programEntry += "<tr>";
              programEntry += "<td>"+ translateKey('lblWPTargetChannels') +"</td>";
              programEntry += "<td colspan='3'>"+ this._getTargetChannels(number) +"</td>";
            programEntry += "</tr>";
          programEntry += "</td>";
        programEntry += "</tr>";

        // Is the next entry not active AND it's not the last one? If so, then allow to add a new one.
        if ((this.ps[(this._addLeadingZero(parseInt(number) + 1)) + "_WP_WEEKDAY"] == "0") && (parseInt(number) < this.maxEntries)) {
          programEntry += this._getDelAddElm("DEL ADD", number);
        } else {
          programEntry += this._getDelAddElm("DEL", number);
        }

      programEntry += "</tbody>";
    programEntry += "</table></td></tr>";

    return programEntry;
  },

  _isNextEntryInUse: function(number) {
    var nextEntry = parseInt(number) + 1;
    nextEntry = (nextEntry < 10) ? "0" + nextEntry : nextEntry.toString();
    var val = parseInt(jQuery("#separate_CHANNEL_" + this.weekDayID[nextEntry]).val());
    return ( (isNaN(val)) || (val == undefined) || (val == 0)) ? false : true ;
  },


  _getConditionElm: function(number) {
    var self = this,
    result = "",
    selected = "",
    arOptions = [
      translateKey("optionWeekPrgFixed"),
      translateKey("optionWeekPrgAstro"),
      translateKey("optionWeekPrgFixedIfBeforeAstro"),
      translateKey("optionWeekPrgAstroIfBeforeFixed"),
      translateKey("optionWeekPrgFixedIfAfterAstro"),
      translateKey("optionWeekPrgAstroIfAfterFixed"),
      translateKey("optionWeekPrgEarliestOfFixedAndAstro"),
      translateKey("optionWeekPrgLatestOfFixedAndAstro")
    ],

    // If the entry is not active the selected value should be 0
    sel = (this.activeEntries[number] == true ) ? parseInt(this.ps[number +"_WP_CONDITION"]) : 0;

    this.prn++;
    this.condition[number] = parseInt(sel);

    showAstroFixedInputElm = function(elmID, condition) {
      elmID = self._addLeadingZero(elmID);
      self.condition[elmID] = condition;
      var fixedTimeElm = jQuery("#fixedTime_" + elmID),
        astroTypeAndOffset = jQuery("#astroTypeOffset_" + elmID);

      if (condition == 0) {fixedTimeElm.show();astroTypeAndOffset.hide();}
       else if (condition == 1) {fixedTimeElm.hide();astroTypeAndOffset.show();}
       else if (condition > 1)  {fixedTimeElm.show();astroTypeAndOffset.show();}
    };

    showConditionHelp = function() {
      var width = 600,
      height = 450;
      MessageBox.show(translateKey("HmIPWPHelpTitle"), translateKey("HmIPWPConditionHelp"), "", width, height);
    };

    result += "<select id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+number+"_WP_CONDITION' onchange='showAstroFixedInputElm("+number+",parseInt(this.value));'>";
      for (var loop = 0; loop < arOptions.length; loop++) {
        selected = (sel == loop) ? "selected='selected'" : "";
        result += "<option value='"+loop+"' "+selected+">"+arOptions[loop]+"</option>";
      }
    result += "</select>";
    result += "<img src='/ise/img/help.png' style='cursor: pointer; width:18px; height:18px; position:relative; top:2px' alt='' onclick='showConditionHelp();'>";

    return result;
  },

  _getFixedTime: function(number) {
    var result = "",
    valHr = (this.activeEntries[number] == true ) ?  parseInt(this.ps[number +"_WP_FIXED_HOUR"]): 0,
    valMin = (this.activeEntries[number] == true ) ? parseInt(this.ps[number +"_WP_FIXED_MINUTE"]) : 0,
    curTime = this._addLeadingZero(valHr) + ":" + this._addLeadingZero(valMin);

    result += "<input type='text' id='fixedTime"+number+"' style='text-align:center' maxlength='5' size='7' value='"+curTime+"'  onblur='checkWPFixedTime(this, "+this.chn+","+(parseInt(this.prn)+1)+")'>";

    result += "<script type='text/javascript'>";
    result += "jQuery( '#fixedTime"+number+"').on( 'keydown', function(event) {";
    result += "    if(event.which == 13)";
    result += "      checkWPFixedTime(this, "+this.chn+","+(parseInt(this.prn)+1)+")";
    result += "  });";
    result += "</script>";

    this.prn++;
    result += "<input type='text' class='hidden' id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+number+"_WP_FIXED_HOUR' value='"+valHr+"' size='2'>";
    this.prn++;
    result += "<input type='text' class='hidden' id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+number+"_WP_FIXED_MINUTE' value='"+valMin+"' size='2'>";
    return result;
  },

  _getAstroType: function(number) {
    var result = "";
    var selected = "";
    var arOptions = [
      translateKey("optionSunrise"),
      translateKey("optionSunset")
    ];

    var sel = (this.activeEntries[number] == true ) ? parseInt(this.ps[number +"_WP_ASTRO_TYPE"]) : 0;
    this.prn++;

    result += "<select id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+number+"_WP_ASTRO_TYPE' >";

    for (var loop = 0; loop < arOptions.length; loop++) {
      selected = (sel == loop) ? "selected='selected'" : "";
      result += "<option value='"+loop+"' "+selected+">"+arOptions[loop]+"</option>";
    }
    result += "</select";

    return result;
  },

  _getAstroOffset: function(number) {
    var result = "",
    astroMin = this.psDescr.ASTRO_OFFSET_MIN,
    astroMax = this.psDescr.ASTRO_OFFSET_MAX,
    astroUnit = this.psDescr.ASTRO_OFFSET_UNIT,
    val = (this.activeEntries[number] == true ) ? parseInt(this.ps[number +"_WP_ASTRO_OFFSET"]) : 0;

    this.prn++;
    result += "<input type='text' id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+number+"_WP_ASTRO_OFFSET' value='"+val+"' size='2' onblur='checkWPMinMaxValue(this,"+astroMin+","+astroMax+")'> "+astroUnit+" ("+astroMin+" - "+astroMax+")";

    result += "<script type='text/javascript'>";
    result += "jQuery( '#separate_CHANNEL_"+this.chn+"_"+this.prn+"').on( 'keydown', function(event) {";
    result += "    if(event.which == 13)";
    result += "      checkWPMinMaxValue(this,"+astroMin+","+astroMax+")";
    result += "  });";
    result += "</script>";
    return result;
  },

  _getDurationMode: function(number) {
    var self = this;

    initDurationMode = function(nr) {
      var number = self._addLeadingZero(nr);
      var valBaseID = number +"_WP_DURATION_BASE",
      valFactorID = number +"_WP_DURATION_FACTOR";

      var valBase = (self.activeEntries[number] == true ) ? parseInt(self.ps[valBaseID]) : 0;
      var valFactor = (self.activeEntries[number] == true ) ? parseInt(self.ps[valFactorID]) : 0;

      var setDurationValueElm = jQuery('#trDurationValue'+number);
      var setDurationModeElm = jQuery('#durationMode'+number);

      if((valBase == 7) && (valFactor == 31)) {
        setDurationValueElm.hide();
        setDurationModeElm.val('0');
        } else {
        setDurationValueElm.show();
        setDurationModeElm.val('1');
      }
    };

    showHideUserValue = function(value, number, prn) {
      var setDurationModeElm = jQuery('#trDurationValue'+self._addLeadingZero(number));
      var factorElm = jQuery("#separate_CHANNEL_"+ self.chn + "_" + (parseInt(prn) + 1));
      var baseElm = jQuery("#separate_CHANNEL_"+ self.chn + "_" + (parseInt(prn) + 2));

      if (parseInt(value) == 0) {
        setDurationModeElm.hide();
        factorElm.val(31);
        baseElm.val(7);
      } else {
        setDurationModeElm.show();
      }
    };

    var result = "";

    result += "<select id='durationMode"+number+"' onchange='showHideUserValue(this.value,"+number+","+this.prn+")'>";
      result += "<option value='0'>"+translateKey('optionPermanent')+"</option>";
      result += "<option value='1'>"+translateKey('optionEnterValue')+"</option>";
    result += "</select>";

    result += "<script type='text/javascript'>";
      result += "window.setTimeout(function(){";
        result += "initDurationMode("+number+");";
      result += "},50)";

    result += "</script>";

    return result;
  },

  _getDuration: function(number) {
    var result = "",
    factorMin = this.psDescr.DURATION_FACTOR_MIN,
    factorMax = this.psDescr.DURATION_FACTOR_MAX,
    valBaseID = number +"_WP_DURATION_BASE",
    valFactorID = number +"_WP_DURATION_FACTOR";

    var valBase = (this.activeEntries[number] == true ) ? parseInt(this.ps[valBaseID]) : 0;
    var valFactor = (this.activeEntries[number] == true ) ? parseInt(this.ps[valFactorID]) : 0;

    var arOptions = ["BASE_100_MS","BASE_1_S","BASE_5_S","BASE_10_S","BASE_1_M","BASE_5_M","BASE_10_M","BASE_1_H"];

    this.prn++;
    result += "<input type='text' id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+valFactorID+"' value='"+valFactor+"' size='2' class='alignCenter' onblur='checkWPMinMaxValue(this,"+factorMin+","+factorMax+")'>";
    result += " x ";

    result += "<script type='text/javascript'>";
    result += "jQuery( '#separate_CHANNEL_"+this.chn+"_"+this.prn+"').on( 'keydown', function(event) {";
    result += "    if(event.which == 13)";
    result += "      checkWPMinMaxValue(this,"+factorMin+","+factorMax+")";
    result += "  });";
    result += "</script>";

    this.prn++;
    result += "<select id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+valBaseID+"'>";
      jQuery.each(arOptions, function(index, value) {
        if (index != valBase) {
          result += "<option value='" + index + "'>" + translateKey(value) + "</options>";
        } else {
          result += "<option selected='selected' value='" + index + "'>" + translateKey(value) + "</options>";
        }
      });
    result += "</select>";

    return result;
  },

  _getRampTime: function(number) {
    var result = "",
    factorMin = this.psDescr.RAMP_TIME_FACTOR_MIN,
    factorMax = this.psDescr.RAMP_TIME_FACTOR_MAX,
    valBaseID = number +"_WP_RAMP_TIME_BASE",
    valFactorID = number +"_WP_RAMP_TIME_FACTOR";

    var valBase = (this.activeEntries[number] == true ) ? parseInt(this.ps[valBaseID]) : 0;
    var valFactor = (this.activeEntries[number] == true ) ? parseInt(this.ps[valFactorID]) : 0;

    var arOptions = ["BASE_100_MS","BASE_1_S","BASE_5_S","BASE_10_S","BASE_1_M","BASE_5_M","BASE_10_M","BASE_1_H"];

    this.prn++;
    result += "<input type='text' id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+valFactorID+"' value='"+valFactor+"' size='2' class='alignCenter' onblur='checkWPMinMaxValue(this,"+factorMin+","+factorMax+")'>";
    result += " x ";

    result += "<script type='text/javascript'>";
    result += "jQuery( '#separate_CHANNEL_"+this.chn+"_"+this.prn+"').on( 'keydown', function(event) {";
    result += "    if(event.which == 13)";
    result += "      checkWPMinMaxValue(this,"+factorMin+","+factorMax+")";
    result += "  });";
    result += "</script>";

    this.prn++;
    result += "<select id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+valBaseID+"'>";
      jQuery.each(arOptions, function(index, value) {
        if (index != valBase) {
          result += "<option value='" + index + "'>" + translateKey(value) + "</options>";
        } else {
          result += "<option selected='selected' value='" + index + "'>" + translateKey(value) + "</options>";
        }
      });
    result += "</select>";

    return result;
  },

  /*
  _getOutputBehaviourDimActor: function(number) {
    var result = "",
      paramID = number + "_WP_OUTPUT_BEHAVIOUR",
      val = (this.activeEntries[number] == true ) ? (1 * this.ps[paramID]) : 0,
      arColor = [
        translateKey("colorBLACK"),
        translateKey("colorBLUE"),
        translateKey("colorGREEN"),
        translateKey("colorTURQUOISE"),
        translateKey("colorRED"),
        translateKey("colorPURPLE"),
        translateKey("colorYELLOW"),
        translateKey("colorWHITE"),
      ];

    this.prn++;
    result += "<select id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+paramID+"'>";
      jQuery.each(arColor, function(index,color) {
        result += "<option  value='"+index+"'>"+color+"</option>";
      });
      result += "<option value='253'>"+translateKey("randomPlayback")+"</option>";
      result += "<option value='254'>"+translateKey("colorOldValue")+"</option>";
    result += "</select>";

    result += "<script type='text/javascript'>";
      result += "window.setTimeout(function(){";
        result += "jElm = jQuery('#separate_CHANNEL_"+this.chn+"_"+this.prn+"');";
        result += "jElm.val('"+val+"');";
        // don`t use jQuery - the dirty flag will not be recognized
        result += "document.getElementById('separate_CHANNEL_"+this.chn+"_"+this.prn+"')[jElm.prop('selectedIndex')].defaultSelected = true;";
      result += "},250);";
    result += "</script>";



    return result;
  },
 */
  /*
  _getOutputBehaviourDimMP3Player: function(number) {
    var result = "",
      paramID = number + "_WP_OUTPUT_BEHAVIOUR",
      val = (this.activeEntries[number] == true ) ? (1 * this.ps[paramID]) : 0;

    this.prn++;
    result += "<select id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+paramID+"'>";
      result += "<option value='0'>"+translateKey("internalSystemSound")+"</option>";
      for (var loop = 1; loop <= 252; loop++) {
        result += "<option value='"+loop+"'>"+loop+"</option>";
      }
      result += "<option value='253'>"+translateKey("randomPlayback")+"</option>";
      result += "<option value='254'>"+translateKey("soundOldValue")+"</option>";
    result += "</select>";

    result += "<script type='text/javascript'>";
      result += "window.setTimeout(function(){";
        result += "jElm = jQuery('#separate_CHANNEL_"+this.chn+"_"+this.prn+"');";
        result += "jElm.val('"+val+"');";
        // don`t use jQuery - the dirty flag will not be recognized
        result += "document.getElementById('separate_CHANNEL_"+this.chn+"_"+this.prn+"')[jElm.prop('selectedIndex')].defaultSelected = true;";
      result += "},50);";
    result += "</script>";

    return result;
  },
*/
  _getLevel: function(number) {
    var result = "",
    paramID = number +"_WP_LEVEL",
    val = (this.activeEntries[number] == true ) ? (1 * this.ps[paramID]).toFixed(3) : "0.000",
    optionVal;

    // For blinds this has no effect because there is no duration
    showHideDuration = function(val, elmNr) {
      elmNr = self._addLeadingZero(elmNr);
      var durationModeElm = jQuery('#durationMode'+elmNr),
      trDurationModeElm = jQuery('#trDurationMode'+elmNr),
      trDurationValueElm = jQuery('#trDurationValue'+elmNr);

      if ((val == "0") || (val == "0.000")) {
        trDurationModeElm.hide();
        trDurationValueElm.hide();
      } else {
        trDurationModeElm.show();
        if (durationModeElm.val() != "0") {
          trDurationValueElm.show();
        }
      }
    };

    this.prn++;
     result += "<select id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+paramID+"' onchange='showHideDuration(this.value, "+number+");'>";
      if ((this.chnType == this.DIMMER) || (this.chnType == this.BLIND)) {

        if ((this.chnType == this.DIMMER)) {
          result += (val == 0) ? "<option value='0' selected='selected'>" + translateKey('optionOFF') + "</option>" : "<option value='0'>" + translateKey('optionOFF') + "</option>";
          for (var loop = 5; loop <= 100; loop += 5) {
            optionVal = (loop / 100).toFixed(3);
            result += (val == optionVal) ?  "<option value='" + optionVal + "' selected='selected'>" + loop + " %</options>" : "<option value='" + optionVal + "'>" + loop + " %</options>";
          }
          result += (val == 1.005) ? "<option value='1.005' selected='selected'>"+translateKey('optionOldLevel')+"</option>" : "<option value='1.005'>"+translateKey('optionOldLevel')+"</option>";
          result += (val == 1.01) ? "<option value='1.010' selected='selected'>"+translateKey('optionNoChange')+"</option>" : "<option value='1.010'>"+translateKey('optionNoChange')+"</option>";
        } else {
          for (var loop = 0; loop <= 100; loop += 5) {
            optionVal = (loop / 100).toFixed(3);
            result += (val == optionVal) ? "<option value='" + optionVal + "' selected='selected'>" + loop + " %</options>" : "<option value='" + optionVal + "'>" + loop + " %</options>";
          }
        }
      } else if (this.chnType == this.SWITCH) {
        result += (val == 0) ? "<option value='0.000' selected='selected'>" + translateKey('optionStateOFF') + "</option>" : "<option value='0.000'>" + translateKey('optionStateOFF') + "</option>";
        result += (val == 1) ? "<option value='1.000' selected='selected'>" + translateKey('optionStateON') + "</option>" : "<option value='1.000'>" + translateKey('optionStateON') + "</option>";
      }

    result += "</select>";

    result += "<script type='text/javascript'>";
      result += "window.setTimeout(function(){";
        result += "showHideDuration("+val+","+number+");";
      result += "},100);";
    result += "</script>";
    return result;

  },

  _getColorSelector: function (number) {
    var result = "",
    paramID = number + "_WP_OUTPUT_BEHAVIOUR",
    val = (this.activeEntries[number] == true ) ? (1 * this.ps[paramID]) : 0,
    arColor = [
      translateKey("colorBLACK"),
      translateKey("colorBLUE"),
      translateKey("colorGREEN"),
      translateKey("colorTURQUOISE"),
      translateKey("colorRED"),
      translateKey("colorPURPLE"),
      translateKey("colorYELLOW"),
      translateKey("colorWHITE"),
    ];

    result += "<select id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+paramID+"' dataid='color_"+number+"'>";
      result += (val == 253) ? "<option value='253' selected='selected'>"+translateKey("randomPlayback")+"</option>" : "<option value='253'>"+translateKey("randomPlayback")+"</option>" ;
      result += (val == 254) ? "<option value='254' selected='selected'>"+translateKey("colorOldValue")+"</option>" : "<option value='254'>"+translateKey("colorOldValue")+"</option>" ;
      jQuery.each(arColor, function(index,color) {
        result += (val == index) ? "<option  value='"+index+"'  selected='selected'>"+color+"</option>" : "<option  value='"+index+"'>"+color+"</option>";
      });
    result += "</select>";

    return result;
  },

  _getSoundSelector: function (number) {
    var result = "",
    paramID = number + "_WP_OUTPUT_BEHAVIOUR",
    val = (this.activeEntries[number] == true ) ? (1 * this.ps[paramID]) : 0;

    result += "<select id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+paramID+"' dataid='sound_"+number+"'>";
      result += (val == 0) ? "<option value='0' selected='selected'>"+translateKey("internalSystemSound")+"</option>" : "<option value='0'>"+translateKey("internalSystemSound")+"</option>" ;
      result += (val == 253) ? "<option value='253' selected='selected'>"+translateKey("randomPlayback")+"</option>" : "<option value='253'>"+translateKey("randomPlayback")+"</option>" ;
      result += (val == 254) ? "<option value='254' selected='selected'>"+translateKey("soundOldValue")+"</option>" : "<option value='254'>"+translateKey("soundOldValue")+"</option>" ;

      for (var loop = 1; loop <= 252; loop++) {
        result += (val == loop) ? "<option value='"+loop+"' selected='selected'>"+loop+"</option>" : "<option value='"+loop+"'>"+loop+"</option>";
      }
    result += "</select>";

    return result;

  },

  _getColorSoundSelector: function (number) {
    var result = "",
    paramID = number + "_WP_OUTPUT_BEHAVIOUR",
    val = (this.activeEntries[number] == true ) ? (1 * this.ps[paramID]) : 0,
    arColor = [
      "",
      translateKey("colorBLUE"),
      translateKey("colorGREEN"),
      translateKey("colorTURQUOISE"),
      translateKey("colorRED"),
      translateKey("colorPURPLE"),
      translateKey("colorYELLOW"),
      translateKey("colorWHITE"),
    ];

    result += "<select id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+paramID+"' dataid='soundColor_"+number+"'>";
      result += (val == 0) ? "<option value='0' selected='selected'>"+translateKey("soundColorInternal") +"</option>" : "<option value='0'>"+translateKey("soundColorInternal") +"</option>";
      result += (val == 253) ? "<option value='253' selected='selected'>"+translateKey("soundColorRandomPlayback")+"</option>" : "<option value='253'>"+translateKey("soundColorRandomPlayback")+"</option>";
      result += "<option value='254'>"+translateKey("soundColorOldValue")+"</option>";

      for (var loop = 1; loop <= 7; loop++) {
        result += (val == loop) ? "<option value='"+loop+"' selected='selected'>"+loop+" / "+arColor[loop]+"</option>" : "<option value='"+loop+"'>"+loop+" / "+arColor[loop]+"</option>";
      }

      for (var loop = 8; loop <= 252; loop++) {
        result += (val == loop) ? "<option value='"+loop+"' selected='selected'>"+loop+"</option>" : "<option value='"+loop+"'>"+loop+"</option>";
      }
    result += "</select>";
    return result;
  },

  _getSlatLevel: function(number) {
    var result = "",
    paramID = number +"_WP_LEVEL_2",
    val = (this.activeEntries[number] == true ) ? (1 * this.ps[paramID]).toFixed(3) : "1.010";

    this.prn++;
    result += "<select id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+paramID+"'>";

      //result += "<option value='0'>"+translateKey('optionOFF')+"</option>";
      for (var loop = 0; loop <= 100; loop += 5) {
        result += "<option value='" + (loop / 100).toFixed(3) + "'>" + loop + " %</options>";
      }
      result += "<option value='1.005'>"+translateKey('optionOldLevel')+"</option>";
      result += "<option value='1.010'>"+translateKey('optionNoChange')+"</option>";

    result += "</select>";

    result += "<script type='text/javascript'>";
      result += "window.setTimeout(function(){";
      result += "jElm = jQuery('#separate_CHANNEL_"+this.chn+"_"+this.prn+"');";
      result += "jElm.val('"+val+"');";
      // don`t use jQuery - the dirty flag will not be recognized
      result += "document.getElementById('separate_CHANNEL_"+this.chn+"_"+this.prn+"')[jElm.prop('selectedIndex')].defaultSelected = true;";
      result += "},100);";
    result += "</script>";

    return result;
  },

  _getWeekDay: function(number) {
    var result = "";
    var paramID = number +"_WP_WEEKDAY";
    var val = parseInt(this.ps[paramID]);
    this.curWeekdays = val;
    this.prn++;
    this.weekDayID[number] = this.chn+"_"+this.prn;

    result += "<table><tbody><tr>";
      result += "<td>";
        result += "<label for='weekDayMO"+number+"'>"+translateKey('Mon')+"</label>";
        result += "<input id='weekDayMO"+number+"' type='checkbox' value='2' name='weekDay"+this.chn+"_"+number+"' onchange='setWPWeekday(this,"+this.chn+","+this.prn+")'>";
      result += "</td>";
      result += "<td>";
        result += "<label for='weekDayTU"+number+"'>"+translateKey('Tue')+"</label>";
        result += "<input id='weekDayTU"+number+"' type='checkbox' value='4' name='weekDay"+this.chn+"_"+number+"' onchange='setWPWeekday(this,"+this.chn+","+this.prn+")'>";
      result += "</td>";
      result += "<td>";
        result += "<label for='weekDayWED"+number+"'>"+translateKey('Wed')+"</label>";
        result += "<input id='weekDayWED"+number+"' type='checkbox' value='8' name='weekDay"+this.chn+"_"+number+"' onchange='setWPWeekday(this,"+this.chn+","+this.prn+")'>";
      result += "</td>";
      result += "<td>";
        result += "<label for='weekDayTHU"+number+"'>"+translateKey('Thu')+"</label>";
        result += "<input id='weekDayTHU"+number+"' type='checkbox' value='16' name='weekDay"+this.chn+"_"+number+"' onchange='setWPWeekday(this,"+this.chn+","+this.prn+")'>";
      result += "</td>";
      result += "<td>";
        result += "<label for='weekDayFR"+number+"'>"+translateKey('Fri')+"</label>";
        result += "<input id='weekDayFR"+number+"' type='checkbox' value='32' name='weekDay"+this.chn+"_"+number+"' onchange='setWPWeekday(this,"+this.chn+","+this.prn+")'>";
      result += "</td>";
      result += "<td>";
        result += "<label for='weekDaySAT"+number+"'>"+translateKey('Sat')+"</label>";
        result += "<input id='weekDaySAT"+number+"' type='checkbox' value='64' name='weekDay"+this.chn+"_"+number+"' onchange='setWPWeekday(this,"+this.chn+","+this.prn+")'>";
      result += "</td>";
      result += "<td>";
        result += "<label for='weekDaySUN"+number+"'>"+translateKey('Sun')+"</label>";
        result += "<input id='weekDaySUN"+number+"' type='checkbox' value='1' name='weekDay"+this.chn+"_"+number+"'  onchange='setWPWeekday(this,"+this.chn+","+this.prn+")'>";
      result += "</td>";
      result += "<td>";
        result += "<input type='text' id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+paramID+"' value='"+val+"' size='3' class='hidden'>";
      result += "</td>";
    result += "</tr></tbody></table>";

    // Init checkboxes
    result += "<script type='text/javascript'>";
      result += "window.setTimeout(function(){";
        result += "var iSelectedDays = " +parseInt(this.curWeekdays) + ";";
        result += "var bSelectedDays = iSelectedDays.toString(2);";
        result += "var tmp = '';";


        result += "for (var loop = 0; loop <= (6 - bSelectedDays.length); loop++) {";
          result += "tmp += '0';";
        result += "}";

        result += "bSelectedDays = tmp + bSelectedDays;";

        result += "jQuery('#weekDayMO"+number+"').attr('checked', (bSelectedDays[5] == '1') ? true : false );";
        result += "jQuery('#weekDayTU"+number+"').attr('checked', (bSelectedDays[4] == '1') ? true : false );";
        result += "jQuery('#weekDayWED"+number+"').attr('checked', (bSelectedDays[3] == '1') ? true : false );";
        result += "jQuery('#weekDayTHU"+number+"').attr('checked', (bSelectedDays[2] == '1') ? true : false );";
        result += "jQuery('#weekDayFR"+number+"').attr('checked', (bSelectedDays[1] == '1') ? true : false );";
        result += "jQuery('#weekDaySAT"+number+"').attr('checked', (bSelectedDays[0] == '1') ? true : false );";
        result += "jQuery('#weekDaySUN"+number+"').attr('checked', (bSelectedDays[6] == '1') ? true : false );";
      result += "},50);";
    result += "</script>";

    return result;
  },

  _getTargetChannels: function(number) {
    var self = this;
    var result = "";
    var paramID = number +"_WP_TARGET_CHANNELS";
    var val = (this.activeEntries[number] == true ) ? parseInt(this.ps[paramID]) : 0;
    var hasBlind = false;

    var valCheckBox,
    tmpVal;

    this.curTargetChannels = val;
    this.prn++;


    blindAvailable = function(elm,  number) {
      if (self.isWired) {
        var elmID = elm.id.split("_")[1];
        var arActiveChkBoxes = jQuery("[name='" + elm.name + "']:checked");
        var elmSlatPos = jQuery("[name='elmSlatPos_" + self._addLeadingZero(number) + "']");
        var showElmSlatPos = false;

        jQuery.each(arActiveChkBoxes, function (index, elm) {
          var elmIndex = elm.id.split("_")[1];
          if (self.targetChannelTypesVirtualBlind[elmIndex] == "BLIND_VIRTUAL_RECEIVER") {
            showElmSlatPos = true;
          }
        });

        if (showElmSlatPos) {
          elmSlatPos.show();
        } else {
          elmSlatPos.hide();
          jQuery(jQuery("[name='"+self._addLeadingZero(number)+"_WP_LEVEL_2']")[0]).val("1.010");
        }
      }
    };

    setDimmerOutputBehaviour = function(elm, number) {
      var number = self._addLeadingZero(number),
      paramID = number + "_WP_OUTPUT_BEHAVIOUR",
      arActiveChkBoxes = jQuery("[name='" + elm.name + "']:checked"),
      elmLblRamptime = jQuery('#lblWPRamptime_' + number),
      chType,
        activeElmID = "",
      elmLblBrightness = jQuery('#lblWPBrightness_' + number),
      hasDimmerVirtReceiver = false,
      hasAcousticVirtReceiver = false,
      elmLblWPColorSelector = jQuery("[name='lblWPColorSelector_"+number+"']"),
      elmLblWPSoundSelector = jQuery("[name='lblWPSoundSelector_"+number+"']"),
      elmLblWPColorSoundSelector = jQuery("[name='lblWPColorSoundSelector_"+number+"']"),
      colorSelector = jQuery("[dataid='color_"+number+"']"),
      soundSelector = jQuery("[dataid='sound_"+number+"']"),
      colorSoundSelector = jQuery("[dataid='soundColor_"+number+"']");

      if (elmLblWPColorSelector.css("display") != "none") {activeElmID = colorSelector[0].id;}
      if (elmLblWPSoundSelector.css("display") != "none") {activeElmID = soundSelector[0].id;}
      if (elmLblWPColorSoundSelector.css("display") != "none") {activeElmID = colorSoundSelector[0].id;}

      jQuery.each(arActiveChkBoxes, function (index, elm) {
        chType = elm.attributes.data.value;
        if (chType == 'DIMMER_VIRTUAL_RECEIVER') {hasDimmerVirtReceiver = true;}
        if (chType == 'ACOUSTIC_SIGNAL_VIRTUAL_RECEIVER') {hasAcousticVirtReceiver = true;}
      });


      if ((hasDimmerVirtReceiver && hasAcousticVirtReceiver) || (! hasDimmerVirtReceiver && ! hasAcousticVirtReceiver)) {
        elmLblBrightness.html(translateKey('lblVolume') + '<br/>' + translateKey('stringTableBrightness'));

        soundSelector.prop('id','noSound_'+number).prop('name','noSound_'+number);
        colorSelector.prop('id','noColor_'+number).prop('name', 'noColor_'+number);
        colorSoundSelector.prop('id',activeElmID).prop('name',paramID);

        elmLblWPSoundSelector.hide();
        elmLblWPColorSelector.hide();
        elmLblWPColorSoundSelector.show();

      } else if (! hasDimmerVirtReceiver && hasAcousticVirtReceiver) {
        elmLblBrightness.html(translateKey('lblVolume'));

        soundSelector.prop('id',activeElmID).prop('name',paramID);
        colorSelector.prop('id','noColor_'+number).prop('name','noColor_'+number);
        colorSoundSelector.prop('id','noColorSound_'+number).prop('name','noColorSound_'+number);

        elmLblWPSoundSelector.show();
        elmLblWPColorSelector.hide();
        elmLblWPColorSoundSelector.hide();

      } else if (hasDimmerVirtReceiver && !hasAcousticVirtReceiver) {
        elmLblBrightness.html(translateKey('stringTableBrightness'));

        soundSelector.prop('id','noSound_'+number).prop('name','noSound_'+number);
        colorSelector.prop('id',activeElmID).prop('name',paramID);
        colorSoundSelector.prop('id','noColorSound_'+number).prop('name','noColorSound_'+number);

        elmLblWPSoundSelector.hide();
        elmLblWPColorSelector.show();
        elmLblWPColorSoundSelector.hide();
      }
    };

    result += "<table><tbody><tr>";

      jQuery.each(this.virtualChannels,function(index,value){
        if (self.sessionIsExpert) {
          valCheckBox = Math.pow(2,index);
        } else {
          if (index == 0){
            valCheckBox = 1;
            tmpVal = 1;
          } else {
            valCheckBox = tmpVal << 3;
            tmpVal = valCheckBox;
          }
        }

        result += "<td>";
          result += "<label for='targetChannel"+number+"_"+index+"'>"+self.virtualChannels[index]+"</label>";
          if (self.chnType == self.BLIND) {
            result += "<input id='targetChannel" + number + "_" + index + "' data='" + self.targetChannelTypesVirtualBlind[index] + "' name='targetChannel" + self.chn + "_" + number + "' type='checkbox' value='" + valCheckBox + "' onchange='setWPTargetChannels(this," + self.chn + "," + self.prn + ");blindAvailable(this," + number + ");'>";
          } else if (self.device.channels[self.chn].channelType == self.DIMMER_OUTPUT_BEHAVIOUR) {
            result += "<input id='targetChannel" + number + "_" + index + "' data='" + self.targetChannelTypes[value] + "' name='targetChannel" + self.chn + "_" + number + "' type='checkbox' value='" + valCheckBox + "' onchange='setWPTargetChannels(this," + self.chn + "," + self.prn + ");setDimmerOutputBehaviour(this," + number + ");'>";
          } else {
            result += "<input id='targetChannel" + number + "_" + index + "' data='" + self.targetChannelTypes[value] + "' name='targetChannel" + self.chn + "_" + number + "' type='checkbox' value='" + valCheckBox + "' onchange='setWPTargetChannels(this," + self.chn + "," + self.prn + ");'>";
          }
            result += "</td>";
      });

      result += "<td>";
        result += "<input type='text' id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+paramID+"' value='"+val+"' size='3' class='hidden'>";
      result += "</td>";
    result += "</tr></tbody></table>";

    // Init checkboxes
    result += "<script type='text/javascript'>";
      result += "window.setTimeout(function(){";
      result += "var iSelectedChn = " +parseInt(this.curTargetChannels) + ";";
      result += "var bSelectedChn = iSelectedChn.toString(2);";
      result += "var reversedBinary = reverseString(bSelectedChn);";
      result += "var counter = 1;";

      if (this.sessionIsExpert) {
          result += "for (var loop = 0; loop < reversedBinary.length; loop++) {";
            result += "jQuery('#targetChannel"+number+"_'+loop).attr('checked', (reversedBinary[loop] == '1') ? true : false );";
          result += "}";
      } else {
        result += "jQuery('#targetChannel"+number+"_0').attr('checked', (reversedBinary[0] == '1') ? true : false );";
        result += "for (var loop = 3; loop < reversedBinary.length; loop+=3) {";
          result += "jQuery('#targetChannel"+number+"_'+counter).attr('checked', (reversedBinary[loop] == '1') ? true : false );";
          result += "counter++";
        result += "}";
      }
      if (this.isWired && this.activeEntries[number]) {
        // This should make LEVEL_2 invisible when no active target channel of the type BLIND available.
        //result += "jQuery('#targetChannel" + number + "_0').trigger('change').trigger('change');";
        result += "var arActiveChkBox = jQuery(\"[name='targetChannel"+self.chn+"_"+number+"']:checked\");" ;
        result += "var elmSlatPos = jQuery(\"[name='elmSlatPos_" + number + "']\");";
        result += "var showElmSlatPos = false;";
        result += "jQuery.each(arActiveChkBox, function(index, elm) {";
          result += "var chType = elm.attributes.data.value;";
          result += "if (chType == 'BLIND_VIRTUAL_RECEIVER') {showElmSlatPos = true;}";
          result += "if (showElmSlatPos) {elmSlatPos.show();} else {elmSlatPos.hide();}";
        result += "});";
      }

      if (this.device.channels[this.chn].channelType == this.DIMMER_OUTPUT_BEHAVIOUR) {
        result += "var arActiveChkBox = jQuery(\"[name='targetChannel"+self.chn+"_"+number+"']:checked\")," ;
        result += "elmLblRamptime = jQuery('#lblWPRamptime_" + number +"'),";
        result += "chType,";
        result += "elmLblBrightness = jQuery('#lblWPBrightness_" + number + "'),";

        result += "elmLblWPColorSelector = jQuery(\"[name='lblWPColorSelector_"+number+"']\"),";
        result += "elmLblWPSoundSelector = jQuery(\"[name='lblWPSoundSelector_"+number+"']\"),";
        result += "elmLblWPColorSoundSelector = jQuery(\"[name='lblWPColorSoundSelector_"+number+"']\"),";

        result += "hasDimmerVirtReceiver = false,";
        result += "hasAcousticVirtReceiver = false;";

        result += "jQuery.each(arActiveChkBox, function(index, elm) {";
          result += "chType = elm.attributes.data.value;";

          result += "if (chType == 'DIMMER_VIRTUAL_RECEIVER') {hasDimmerVirtReceiver = true;}";
          result += "if (chType == 'ACOUSTIC_SIGNAL_VIRTUAL_RECEIVER') {hasAcousticVirtReceiver = true;}";

        result += "});";

        result += "var colorSelector = jQuery(\"[dataid='color_"+number+"']\");";
        result += "var soundSelector = jQuery(\"[dataid='sound_"+number+"']\");";
        result += "var colorSoundSelector = jQuery(\"[dataid='soundColor_"+number+"']\");";

        result += "if ((hasDimmerVirtReceiver && hasAcousticVirtReceiver) || (! hasDimmerVirtReceiver && ! hasAcousticVirtReceiver)) {";
          // result += "elmLblBrightness.html('Lautstaerke<br/>Helligkeit');";

          result += "elmLblBrightness.html(translateKey('lblVolume') + '<br/>' + translateKey('stringTableBrightness'));";

          result += "soundSelector.prop('id','noSound_"+number+"').prop('name','noSound_"+number+"');";
          result += "colorSelector.prop('id','nocColor_"+number+"').prop('name','noColor_"+number+"');";

          result += "elmLblWPColorSoundSelector.show()";
        result += "} else if (hasAcousticVirtReceiver) {";
          result += "elmLblBrightness.html(translateKey('lblVolume'));";

          result += "colorSelector.prop('id','noColor_"+number+"').prop('name','noColor_"+number+"');";
          result += "colorSoundSelector.prop('id','noColorSound_"+number+"').prop('name','noColorSound_"+number+"');";

          result += "elmLblWPSoundSelector.show();";
        result += "} else {";
          result += "elmLblBrightness.html(translateKey('stringTableBrightness'));";

          result += "soundSelector.prop('id','noSound_"+number+"').prop('name','noSound_"+number+"');";
          result += "colorSoundSelector.prop('id','noColorSound_"+number+"').prop('name','noColorSound_"+number+"');";

          result += "elmLblWPColorSelector.show();";
        result += "}";

      }

    result += "},100);";

    result += "</script>";

    return result;
  },

  _getTargetChannelTypes: function() {
    var self = this;
    jQuery.each(this.virtualChannels, function(index,chn) {
      self.targetChannelTypes[chn] = self.device.channels[chn].channelType;
    });
  },

  // Check if one of the target channels of a given type is active (checked)
  isTargetChOfType: function(chType) {
    var self = this,
    result = false;

    jQuery.each(this.virtualChannels,function(index, chn){
      if (self.targetChannelTypes[chn] == chType) {
        result = true;
        return false; // leave the each loop
      }
    });
    return result;
  },



  _getHR: function() {
    return "<tr><td colspan='6'><hr></td></tr>";
  },

  _getDelAddElm: function(mode, number) {
    var self = this,
    classAddElm = "",
    classDelElm = "";

    deleteEntry = function(number) {
      self.numberOfActiveEntries--;
      if (parseInt(number) == 1) {
        jQuery("#btnDelEntry0").hide();
        jQuery("#btnAddNewEntry0").show();
      }

      if (self.numberOfActiveEntries >= 1) {
          number = self._addLeadingZero(number);
          jQuery("#weeklyProgramNotActive").hide();
          //jQuery("#entry" + number).hide();
          jQuery("#entry" + number).fadeOut();
          self.activeEntries[number] = false;
          jQuery("#separate_CHANNEL_" + self.weekDayID[number]).val(0);
          jQuery("#btnAddNewEntry" + (self._addLeadingZero(parseInt(number) - 1))).show();
      } else {
        self.numberOfActiveEntries = 0;
        number = self._addLeadingZero(number);
        //jQuery("#entry" + number).hide();
        jQuery("#entry" + number).fadeOut();
        jQuery("#separate_CHANNEL_" + self.weekDayID[number]).val(0);
        self.activeEntries[number] = false;
        jQuery("#weeklyProgramNotActive").show();
        jQuery("#btnAddNewEntry0").show();
      }
    };

    addEntry = function(elm, number) {
      self.numberOfActiveEntries++;
      var nextNumber = parseInt(number) + 1;

      jQuery("#weeklyProgramNotActive").hide();

      self.activeEntries[self._addLeadingZero(nextNumber)] = true;
      if(self.activeEntries["01"] == true) {
        jQuery("#btnAddNewEntry0").hide();
      }

      jQuery("#btnAddNewEntry" + (self._addLeadingZero(parseInt(number)))).hide();
      jQuery("#entry"+self._addLeadingZero(nextNumber)).show();

      jQuery("#separate_CHANNEL_" + self.weekDayID[self._addLeadingZero(nextNumber)]).val(127);
      jQuery("[name='weekDay"+self.chn+"_"+self._addLeadingZero(nextNumber)+"']").attr("checked", true);

      window.setTimeout(function() {self._initTargetChannels(number);},500);

      if ( (! self._isNextEntryInUse(nextNumber)) && (parseInt(nextNumber) < self.maxEntries)) {
        jQuery("#btnAddNewEntry" + (self._addLeadingZero(parseInt(nextNumber)))).show();
      } else {
        jQuery("#btnAddNewEntry" + (self._addLeadingZero(parseInt(nextNumber)))).hide();
      }
      jQuery("#btnDelEntry"+self._addLeadingZero(nextNumber)).get(0).scrollIntoView({behavior:'smooth', block:'end'});
      //jQuery("#btnDelEntry"+self._addLeadingZero(nextNumber)).get(0).scrollIntoView(false);
    };

    if (mode == "DEL") {
      classAddElm = "hidden";
    } else if (mode == "ADD_FIRST_ELEM") {
      classDelElm = "hidden";
    }

    var panel = "",
      delElm = "<td id='btnDelEntry"+number+"' class='"+classDelElm+"'><img src='/ise/img/cc_delete.png'  title='"+translateKey('lblDelSwitchPoint')+"' alt='Remove entry' style='width: 24px; height: 24px; cursor: pointer;' onclick='deleteEntry("+number+");'></td>",
      addElm = "<td id='btnAddNewEntry"+number+"' class='"+classAddElm+"'><img src='/ise/img/add.png' title='"+translateKey('lblAddSwitchPoint')+"' alt='Add entry' style='width: 24px; height: 24px; cursor: pointer;' onclick='addEntry(this,"+number+");'></td>";

    panel += "<tr>";
      panel += delElm;
      panel += addElm;
    panel += "</tr>";
    return panel;
  },

  _initTargetChannels: function(number) {
    var arTargetChannels = jQuery("[name='targetChannel"+this.chn +"_"+ this._addLeadingZero(parseInt(number +1))+"']"),
      elmTargetValue = jQuery("[name='"+this._addLeadingZero(parseInt(number +1))+"_WP_TARGET_CHANNELS']"),
      targetValue = 0;

    jQuery.each(arTargetChannels, function(index,elm) {
      jQuery(elm).attr('checked', true);
      targetValue += parseInt(jQuery(elm).val());
    });
    elmTargetValue.val(targetValue);
  },

  _getMaxEntries: function() {
    // return 5; // Set the value for testing reasons to a low level - remove this after testing

    //return 75;

    if (this._isDeviceType("HmIP-MP3P")) {return 69;}

    switch (this.chnType) {
      case this.DIMMER:
      case this.SWITCH:
      case this.BLIND:
        return 75;
      default: return -1;
    }
  },

  // Check if the parameter weekday is in use.
  // If this is not the case the entry shouldn`t be visible and all values of the entry are 0
  _setEntryVisibility: function(number) {
    var val = parseInt(this.ps[number +"_WP_WEEKDAY"]);
    this.activeEntries[number] = (val == 0) ? false : true ;
   },

  _addLeadingZero: function(val) {
    return (parseInt(val) < 10) ? "0"+val : val;
  }
};
