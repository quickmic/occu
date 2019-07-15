##
# Device.getRFAddressByAddress
# Gibt die Funk-Addresse eines Ger�tes aufgrund der Seriennummer zur�ck
# 
# Parameter:
#   address: [string] SerienNummer des Ger�ts
#
# R�ckgabewer: [string]
# Funkaddresse
#
##

set script {
  string data = "";
  string rfAddress = "unknown";
  string id;

  foreach(id, root.Devices().EnumIDs()) {
    var dev = dom.GetObject(id);
    if (dev.Address() == address) {
      string metaData = dev.MetaData("DEVDESC");
      foreach (data, metaData.Split(",")) {
        if (data.Substr(0,10) == "RF_ADDRESS") {
          rfAddress = data;
        }
      }
    }
  }

  if (rfAddress != "unknown") {
    Write(rfAddress)
  } else {
    Write("unknown");
  }

}

jsonrpc_response [json_toString [hmscript $script args]]
