##
# User.getUserPWD
# Ermittelt das Passwort des Anwenders
#
# Parameter:
#   userID: [string] Id des Anwenders
#
# R�ckgabewert: [string]
#    Userpasswort
##

set script {
  var user = dom.GetObject(userID);
  if ( user )
  {
    if ( user.UserPwd() == "" )
    {
      Write("VAL { false } ");
    }
    else
    {
      Write("VAL { true } ");
    }
  }
  else
  {
    Write(false);
  }
}


array set user [hmscript $script args]

set result "\{"
append result "\"UserPWD\" : $user(VAL)"
append result "\}"

jsonrpc_response $result.UserPWD
