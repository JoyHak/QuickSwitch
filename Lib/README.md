QuickSwitch is divided into many libraries that interact closely with each other. Each library is not an independent separate unit, as it can depend on other libraries. The correct initialization order for each library is written in the main file, with the name `QuickSwitch-v1.0*.ahk`.

The getter of paths from Total Commander is not in [ManagerClasses.ahk](https://github.com/JoyHak/QuickSwitch/blob/main/Lib/ManagerClasses.ahk), but in a [separate file](https://github.com/JoyHak/QuickSwitch/blob/main/Lib/TotalCommander.ahk), see documentation [here](https://github.com/JoyHak/QuickSwitch/tree/main/Lib/TotalCommander).

| Library          | Purpose                                  | Description                                                  |
| ---------------- | ---------------------------------------- | ------------------------------------------------------------ |
| Log              | Export all special info and errors       | Functions to determine the cause of an unexpected problem. All **thrown / catched / not catched errors** should be sent as `ExceptionObj` to the `LogError()` instead of `MsgBox()` |
| Debug            | Analyze code and dialogs                 | GUI: shows info about dialog controls. Contains functions for debugging and testing code. |
| Values           | Declare, validate and save global values | Contains all global variables necessary for the application, functions that validate values and read / write to the `INI` configuration. If `INI` can't be created, app always uses the default values. |
| FileDialogs      | Get dialog type, feed dialog             | Contains setters. `GetFileDialog()`  returns the `FuncObj` to call it later and feed the current dialog. |
| Elevated         | Get and store process permission         | Contains functions for determing and saving PID of elevated process in the dictionary. |
| Windows          | Interact with other windows              | Contains functions for interacting with windows.             |
| Processes        | Interact with other processes            | Contains getters.                                            |
| ManagerMessages  | Send message to other process            | Contains functions for communication between different processes. |
| ManagerClasses   | Get paths from a specific file manager   | Contains functions for getting paths from specific file manager. The name of each function corresponds to the class of the file manager window. |
| GetPaths         | Get all possible paths                            | Contains functions for getting different [types of paths](https://github.com/JoyHak/QuickSwitch#menu-sections), including all possible paths from file managers. |
| SettingsBackend  | Save and change settings values          | Contains functions that are responsible for the GUI functionality and app initialization. |
| SettingsMouse    | Select mouse buttons, special keys in GUI. | Contains functions for selecting mouse buttons and specialkeys in the GUI; togglers for keyboard input and mouse button selection contrcon; mouse buttons converter. |
| MenuBackend      | Select path, change options                     | Contains functions that are responsible for the Menu functionality. |
| DarkTheme        | Set theme and font for Menu and GUI                | Contains functions for changing theme and font for Menu and GUI. Contains initialization for default theme. |
| SettingsFrontend | Change global variables                  | GUI: shows app settings. Uses global variables.              |
| MenuFrontend     | Select paths and options                 | Menu: shows paths and options. Displayed and actual paths are independent of each other, which allows Menu to display anything *(e.g. short path)* |
