##
# CCU.createFile
# Legt eine Datei an, der Pfad muss mit angegeben werden
#
# Parameter:
# file: [string] Dateiname. Alles inclusive Pfad.
#
# R�ckgabewert: result
#                 false - error
#                 true - ok
##

set result false

catch {exec touch $args(file)} e

if {[string trim $e] == ""} {
  set result true
}

jsonrpc_response $result
