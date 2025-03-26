The application is divided into many files that interact closely. It is not safe to change function names in them. It is not safe to change the order in which they are imported into `QuickSwitch.ahk` (main file).

| Library          | Purpose                                         | Description                                                  |
| ---------------- | ----------------------------------------------- | ------------------------------------------------------------ |
| Log              | Log all special info and errors                 | Additional functions allow me to determine the approximate cause of an unexpected problem. All **thrown / catched / not catched errors** should be sent to the `LogError()` instead of `MsgBox()` |
| Values           | Declare, validate and save global values        | Uses an `INI` file to **read/write** values. If it cannot be created, app always uses the default values |
| FileDialogs      | Functions to work with known dialogues          | There are a few different types of possible dialogues, and each one has its own *function*.     `GetFileDialog()`  returns the `FuncObj` to call it later and feed the current dialogue. |
| GetPaths         | Functions to work with paths from File Managers | All functions add values to the global `paths` array.        |
| AutoSwitch       | Add options to Paths Menu                       | `AutoSwitch()` is called each time a dialogue is opened if it is enabled.  Depends on `DialogAction` variable, which is bound to each window's *FingerPrint*. |
| Debug            | Show list of system values                      | GUI: system & dialogue variables, states, coordinates, sizes, … |
| SettingsBackend  | Functions to save and change settings options   | All functions that are bound to GUI Settings Controls are here. |
| SettingsFrontend | Change global variables                         | GUI. All entered/checked values are saved in the `INI` only when you click **OK** |
| PathsMenu        | Main context menu                               | Displayed and actual paths are independent of each other, which allows you to display anything *(e.g. virtual paths from XYplorer and Explorer).* |

