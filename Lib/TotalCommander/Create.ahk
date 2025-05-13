CreateTotalUserCommand(ByRef ini, ByRef cmd, ByRef internalCmd, ByRef param := "") {
    ; Creates cmd in specified ini config.
    ; "cmd" param must start with EM_

    try {
        loop, 4 {
            ; Read the contents of the config until it appears or the loop ends with an error
            IniRead, _section, % ini, % cmd
            if (_section && _section != "ERROR") {
                LogInfo("Created [" cmd "] command:`n" _section "`nin `'" ini "`'`n")
                return true
            }

            if FileExist(ini) {
                ; Set normal attributes (write access)
                FileSetAttrib, n, % ini
                sleep, 20 * A_Index

                FileGetAttrib, _attr, % ini
                if InStr(_attr, "R")
                    throw Exception("Unable to get write access", "")
            }

            ; Create new section
            FileAppend, % "
            (LTrim
                # Please dont add commands with the same name
                [" cmd "]
                cmd="   internalCmd  "
                param=" param        "

            )", % ini

            sleep, 50 * A_Index
        }
        throw Exception("Unable to create configuration", "")

    } catch _e {
        throw Exception("Please create this file manually: `'" ini "`'"
                      , "TotalCmd config"
                      , _e.what " " _e.message " " _e.extra "`n"
                      . ValidateFile(ini))
    }
}