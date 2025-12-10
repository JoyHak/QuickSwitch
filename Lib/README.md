QuickSwitch is divided into many libraries that interact closely with each other. Each library is not an independent separate unit, as it can depend on other libraries. The correct initialization order for each library is written in the main file, with the name `QuickSwitch-v1.0*.ahk`.

The getter of paths from Total Commander is not in [ManagerClasses.ahk](https://github.com/JoyHak/QuickSwitch/blob/main/Lib/ManagerClasses.ahk), but in a [separate file](https://github.com/JoyHak/QuickSwitch/blob/main/Lib/TotalCommander.ahk), see documentation [here](https://github.com/JoyHak/QuickSwitch/tree/main/Lib/TotalCommander).

| Library          | Purpose                                  | Description                                                  |
| ---------------- | ---------------------------------------- | ------------------------------------------------------------ |
| Log              | Write errors to the log file       | Contains functions to determine the cause of any issue. All unexpected exceptions are passed to `LogException()` in the `catch {}` block. All expected exceptions are passed to `LogError()` with a short friendly message, brief reason and technical details.  |
| Debug            | Show info about active file dialog                 | GUI: shows info about file dialog controls. Allows to export all info. |
| Values           | Declare, validate and save global values | Contains all global variables necessary for the application; validators of values; functions for read / write to the `INI` configuration. If `INI` can't be created, app always uses the default values. |
| FileDialogs      | Get dialog type, fill the dialog             | Contains functions for determining whether an open window is a file dialog; for filling it with the specified path. |
| Elevated         | Get and store process status         | Contains functions for determing and saving PID of elevated process in the dictionary. |
| Processes        | Interact with other processes            | Contains functions for getting information about the process; terminating process; closing windows. |
| ManagerMessages  | Send message to other process            | Contains functions for communication between different processes. |
| ManagerClasses   | Get paths from a specific file manager   | Contains functions for getting paths from specific file manager. The name of each function corresponds to the class of the file manager window. |
| GetPaths         | Get all possible paths                            | Contains functions for getting different [types of paths](https://github.com/JoyHak/QuickSwitch#menu-sections), including all possible paths from file managers. |
| SettingsBackend  | Save and change settings values          | Contains functions that are responsible for the GUI functionality and app initialization. |
| SettingsMouse    | Select mouse buttons, special keys in GUI. | Contains functions for selecting mouse buttons and specialkeys in the GUI; togglers for keyboard input and mouse button selection contrcon; mouse buttons converter. |
| MenuBackend      | Select path, change options                     | Contains functions that are responsible for the Menu functionality. |
| DarkTheme        | Set theme and font for Menu and GUI                | Contains functions for changing theme and font for Menu and GUI. Contains initialization for default theme. |
| SettingsFrontend | Change global variables                  | GUI: shows app settings. Uses global variables.              |
| MenuFrontend     | Select paths and options                 | Menu: shows paths and options. Displayed and actual paths are independent of each other, which allows Menu to display anything *(e.g. short path)* |
