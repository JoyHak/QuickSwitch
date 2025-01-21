QuickSwitch modification by Rafaello. Based on `v0.5dw9a` by *NotNull*, *DaWolfi* and others: https://www.voidtools.com/forum/viewtopic.php?f=2&t=9881

#### ABOUT

QuickSwitch allows you to switch file dialogs (like Save-As or Open) to any folder opened in supported file managers (File Explorer, Directory Opus, Total Commander, XYPlorer). 

![](https://github.com/JoyHak/QuickSwitch-/blob/main/Images/(3).png)	
![](https://github.com/JoyHak/QuickSwitch-/blob/main/Images/(4).png)
![](https://github.com/JoyHak/QuickSwitch-/blob/main/Images/(5).png)

It has two modes:

1. **QuickSwitch Menu Mode**: Displays a list of opened folders. Selecting one switches the file dialog to that folder. The menu won't appear if no folders are open.

2. **AutoSwitch Mode**: After enabling this mode, the file dialog automatically opens the last active folder in the file manager when you Alt-Tab between them. If the file manager was active before opening the dialog, it opens that folder immediately. You can still use Control-Q to access the menu if needed.

There's also a "Never" option to disable QuickSwitch for specific dialogs, like web browsers, which manage their own folders.

#### CHANGELOG

- Following the clearance of the code, the syntax has been modified to closely resemble that of Autohotkey v2, facilitating further adaptation to v2.

- The code has been restructured to enhance its clarity and to facilitate self-documentation, with additional comments added to support its interpretation.

- The code has been modified to remove Spaggification and GOTO labels, and to add structure by dividing the key elements of the script into parts and adding them to `Libs`.

- Tthe speed at which `menu with paths` from file managers appear has been **increased**.

- `AutoSwitch` has been modified to **no longer iterate over all paths** and now works directly with the latest file manager.

- `AutoSwitch exception` has been rendered obsolete.

- The drive letter can be removed from the menu.

- The ability to shorten the displayed path and cut the path from either side *(left or right)* has now been added.

###### Extended support for XYplorer:
  
- If you open a Rapid Access Folder or a virtual path (Rapid/Music, Downloads), it can be displayed instead of the full path.
- The menu will display the paths from all open folders starting from the current one. Previously, only 1 path was displayed.
    ​		

#### TODO

- Autohotkey v2 port
- AutoSwitch on clipboard change
- drag and drop any file field
- get all File Explorer QTTabBar tabs
- get all Directory Opus panes
- Improve File Managers commands to avoid using clipboard

