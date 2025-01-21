QuickSwitch modification by Rafaello. Based on `v0.5dw9a` by *NotNull*, *DaWolfi* and others: https://www.voidtools.com/forum/viewtopic.php?f=2&t=9881
		

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

- AuotSwitch on clipboard change
- drag and drop any file field
- get all File Explorer QTTabBar tabs
- get all Directory Opus panes
- Improve File Managers commands to avoid using clipboard

