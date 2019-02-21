jQuery.extend(true,langJSON, {
  "en" : {

    "comment" : "This is for the Smoke-Detector certification",

    "checkSmokeDetectorSelfTest" : "To make sure the smoke detector is working properly, please  perform a self-test by pressing the operating key.",
    "hintActivateDetectorSelfTest" : "The firmware update was successful. ",
    "hintReInclusionDetectorFailed" : "A problem occurred while updating the firmware. ",

    "lblRename" : "Rename",
    "askRenameAllChannels" : "Automatically assign standard channel names?",
    "lblDeviceName" : "Device description",
    "lblChannelNames" : "Preview of channel names",

    "stringTableDisplayContrast" : "Display contrast",

    "dialogFirmwareUpdateUnknownError" : "An unknown error has occurred<br/><br/>Please check whether the device can be accessed.",

    "lblHmIPWIdentification" : "Identification",
    "lbDisplayBacklight" : "Lighting<br/>Display",
    "lblLightingKeyVisual" : "Lighting<br/>System key",

    "optionUnit10SShort" : "10 s",
    "optionUnit30SShort" : "30 s",
    "optionUnit1MShort" : "1 min",
    "optionUnit5MSShort" : "5 min",
    "optionUnit10MShort" : "10 min",
    "optionUnit30MShort" : "30 min",

    "stringTableErrorCoProcessor" : "The channel cannot be accessed.",
    "stringTableErrorRestartNeeded" : "The device must be restarted.",

    "helpAccessPointOffline" :
    "An internet connection is needed to <u>commission</u> the Homematic IP Wired Access Point.<br/><br/>" +
    "Following successful commissioning (the system key is lit turquoise) the system can be operated offline. Operation then no longer requires an internet connection.<br/><br/>" +
    "If you would like to use offline operation and train additional wired devices, use the training dialogue in the field <b>" + langJSON.de.dialogNewDevicesHmIPWithoutInternet + "</b>" +
    "Enter the KEY and the SGTIN from the device label.",

    "drapMaxCurrentBus" : "Maximum current consumption by the bus",
    "drapHelpMaxCurrentBus" : "Configuration of the parameter is dependent on the power pack.",
    "drapBusConfig" : "Bus configuration",
    "drapHelpBusConfig" : "Configuration of the parameter is dependent on the bus topology.",

    "optionRingMode" : "Ring topology",
    "optionTwoSeparateBusSystems" : "Two separate bus strings",

    "AccessPointConfigurationFinished" : "Settings successfully saved.",

    "dialogMigrationRCV50Title" : langJSON.en.dialogHint,

    "dialogMigrationRCV50" : "Starting with this release, 50 virtual remote operation channels can also be used for Homematic IP for the first time.<br/><br/>" +
    "To enable them to be used in full, trained Homematic IP sensors already set in the programs will need to be reconfigured. " +
    "This configuration runs automatically in the background, with appropriate service messages displayed (\"Configuration data ready for transfer\"). " +
    "Please do not use the virtual remote operation channels until the configuration data has been transferred.<br/><br/>" +
    "The changes do not impact existing programs and links.",

    "btnAccessPointConfig" : "Configuration",

    "lblQueryConfig" : "Query configuration",
    "lblSetConfig" : "Save configuration",
    "lblConfigNotChanged" : "No changes were made to the configuration.",

    "noMoreKeys" : ""
  }
});

langJSON.en.hintActivateDetectorSelfTest += langJSON.en.checkSmokeDetectorSelfTest;
langJSON.en.hintReInclusionDetectorFailed += langJSON.en.checkSmokeDetectorSelfTest;