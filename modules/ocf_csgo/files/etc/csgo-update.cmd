// steamcmd command script to update the cs:go server
//
// run with:
//     ./steamcmd.sh +runscript /opt/csgo/etc/csgo-update.cmd
// a full run takes about ~2 minutes (even if no updates exist)
//
// see https://developer.valvesoftware.com/wiki/SteamCMD#Automating_SteamCMD

@ShutdownOnFailedCommand 1
@NoPromptForPassword 1

login anonymous

// install or update cs:go
force_install_dir /opt/csgo/srcds
app_update 740 validate

quit
