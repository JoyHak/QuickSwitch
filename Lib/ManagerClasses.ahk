/*
    Contains getters whose names correspond to classes of known file managers.
    All functions add values to the global "Paths" array.
    "winId" param must be existing window uniq ID (window handle / HWND)
*/

GroupAdd, ManagerClasses, ahk_class TTOTAL_CMD
GroupAdd, ManagerClasses, ahk_class CabinetWClass
GroupAdd, ManagerClasses, ahk_class ThunderRT6FormDC
GroupAdd, ManagerClasses, ahk_class dopus.lister


TTOTAL_CMD(ByRef winId) {
    GetTotalPaths(winId)
}

CabinetWClass(ByRef winId) {
    ; Analyzes open Explorer windows (tabs) and looks for non-virtual paths
    global Paths

    try {
        for _instance in ComObjCreate("Shell.Application").Windows {
            if (winId == _instance.hwnd) {
                _path := _instance.Document.Folder.Self.Path
                if !InStr(_path, "::{") {
                    Paths.push(_path)
                }
            }
        }

    } catch _error {
        if InStr(_error.message, "0x80004005") {
            RegExMatch(_error.message, "([^`r`n]+)", _message)

            if MsgWarn("
                (LTrim
                    System error occurred while retrieving Explorer paths: " _message "

                    Restart all Explorer instances to fix?
                )") {
                CloseProcess("explorer.exe")
                Run ::{20D04FE0-3AEA-1069-A2D8-08002B30309D}
                return
            }
        }

        LogError(_error)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ThunderRT6FormDC(ByRef winId) {
;─────────────────────────────────────────────────────────────────────────────
    ; Sends script to XYplorer and parses the clipboard.
    global Paths

    try {
        ; Save clipboard to restore later
        _clipSaved := ClipboardAll
        Clipboard  := ""

        static script := "
        ( LTrim Join Comments
            ::$paths = <get tabs_sf | a>, 'r'`;         ; Get tabs from the active panel, resolve native variables
            if (get('#800')) {                          ; Second panel is enabled
                $paths .= '|' . <get tabs_sf | i>`;     ; Get tabs from second panels
            }
            $reals = ''`;
            foreach($path, $paths, '|') {               ; Path separator is |
                $reals .= '|' . pathreal($path)`;       ; Get the real path (XY has special and virtual paths)
            }
            $reals = trim($reals, '|', 'L')`;           ; Remove the extra  | from the beginning of $reals
            copytext $reals`;                           ; Place $reals to the clipboard, faster then copydata
        )"

        SendXyplorerScript(winId, script)

        ClipWait 2
        _clip     := Clipboard
        Clipboard := _clipSaved

        if _clip {
            Loop, parse, _clip, `|
                Paths.push(A_LoopField)
        }

    } catch _error {
        LogError(_error)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
Dopus(ByRef winId) {
;─────────────────────────────────────────────────────────────────────────────
    ; Analyzes the text of address bars of each tab using MS C++ functions.
    ; Searches for active tab using DOpus window title
    global Paths

    try {
        WinGetTitle, _title, ahk_id %winId%

        ; Each tab has its own address bar, so we can use it to determine the path of each tab
        static ADDRESS_BAR_CLASS := "dopus.filedisplaycontainer"
        ; Defined in AutoHotkey source
        static WINDOW_TEXT_SIZE := 32767
        VarSetCapacity(_text, WINDOW_TEXT_SIZE * 2)

        ; Find the first address bar HWND
        ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-findwindowexw
        _previousHwnd := DllCall("FindWindowExW", "ptr", winId, "ptr", 0, "str", ADDRESS_BAR_CLASS, "ptr", 0)
        _startHwnd    := _previousHwnd
        _paths        := []
        _active       := 1

        loop {
            ; Pass every HWND to GetWindowText() and get the content
            ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowtextw
            if DllCall("GetWindowTextW", "ptr", _previousHwnd, "str", _text, "int", WINDOW_TEXT_SIZE) {
                _paths.push(_text)

                if InStr(_text, _title)
                    _active := A_Index
            }
            _nextHwnd := DllCall("FindWindowExW", "ptr", winId, "ptr", _previousHwnd, "str", ADDRESS_BAR_CLASS, "ptr", 0)

            ; The loop iterates through all the tabs over and over again,
            ; so we must stop when it repeats
            if (_nextHwnd = _startHwnd)
                break

            _previousHwnd := _nextHwnd
        }

        ; Push the active tab to the global array first
        ; Remove duplicate and add the remaining tabs
        Paths.push(_paths.removeAt(_active))
        Paths.push(_paths*)

    } catch _error {
        LogError(_error)
    }
}