The application is divided into many files that interact closely. It is not safe to change function names in them. It is not safe to change the order in which they are imported into `QuickSwitch.ahk` (main file).

| Library          | Purpose                                  | Description                                                  |
| ---------------- | ---------------------------------------- | ------------------------------------------------------------ |
| Log              | Export all special info and errors       | Functions to determine the cause of an unexpected problem. All **thrown / catched / not catched errors** should be sent as `ExceptionObj` to the `LogError()` instead of `MsgBox()` |
| Debug            | Analyze code and dialogs                 | GUI: shows info about dialog controls. Contains functions for debugging and testing code. |
| Values           | Declare, validate and save global values | Contains all global variables necessary for the application, functions that validate values and read / write to the `INI` configuration. If `INI` can't be created, app always uses the default values. |
| FileDialogs      | Get dialog type, feed dialog             | Contains setters. `GetFileDialog()`  returns the `FuncObj` to call it later and feed the current dialog. |
| Elevated         | Get and store process permission         | Contains functions for determing and saving PID of elevated process in the dictionary. |
| Processes        | Interact with other processes            | Contains process information getters and functions for closing processes, windows. |
| ManagerMessages  | Send message to other process            | Contains functions for communication between different processes. |
| ManagerClasses   | Get paths from a specific file manager   | Contains file manger path getters. The getter names correspond to window classes. All functions add values to the global `Paths` array. |
| TotalCommander   | Get paths from TC                        | Contains setters to prepare TC to receive the desired requests and getters to receive paths. |
| GetPaths         | Get all paths                            | Top-level getters. Starts `Auto Switch` as soon as at least 1 path is found. |
| SettingsBackend  | Save and change settings values          | Contains functions that are bound to GUI Settings and out-of-category functions needed for the app. |
| SettingsFrontend | Change global variables                  | GUI: shows app settings. Uses global variables.              |
| MenuBackend      | Change menu behavior                     | Contains functions that are bound to Menu options and responsible for the Menu functionality. |
| MenuFrontend     | Select paths and options                 | Menu: shows paths and options. Displayed and actual paths are independent of each other,    which allows Menu to display anything *(e.g. short path)* |

