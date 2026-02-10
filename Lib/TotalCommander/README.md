Thread on forum:<br> 
<a href="https://www.ghisler.ch/board/viewtopic.php?t=76254&sd=d">
<img src="https://raw.githubusercontent.com/JoyHak/QuickSwitch/main/Images/badges/TotalCommander.svg" alt="TotalCommander"></a>

QuickSwitch creates [user-defined command](https://www.ghisler.ch/wiki/index.php/User-defined_command) to interact with Total Commander. TC exports all tabs to the file after receiving a message via `SendMessage` (see `ManagerMedsages.ahk`) with this command name. 

QuickSwitch searches for the location of the [wincmd.ini](https://www.ghisler.ch/wiki/index.php?title=Finding_the_paths_of_Total_Commander_files) TC configuration file, then creates [usercmd.ini](https://www.ghisler.ch/board/viewtopic.php?t=50634) (if it does not exist) next to the found configuration and appends the command to the end of the file.

See technical details here: <a href="https://deepwiki.com/JoyHak/QuickSwitch/7.4-total-commander-integration">
<img src="https://deepwiki.com/badge.svg" alt="Ask DeepWiki"></a>

Search methods were suggested by Dalai. Search and parsing algorithms were written by Rafaello. The code was successfully tested by Horst:

- <img src="/Images/forums/TotalCommander.svg" width="25" height="25"/> [Algorithm by Dalai](https://www.ghisler.ch/board/viewtopic.php?p=470238#p470238)
- <img src="/Images/forums/TotalCommander.svg" width="25" height="25"/> [Implemented in 1.5](https://www.ghisler.ch/board/viewtopic.php?t=76254&start=105#p471010)

If an error occurs while retrieving tabs, QuickSwitch tries to create a command. If the command already exists, the error details are appended to the log.The command is created separately for each TC window. Tabs are requested independently from each file manager window. This allows you to work with both a portable and an installed TC at the same time (with different configuration paths) without issues.
```text
Lib/    
├── TotalCommander.ahk (requests paths from Total Commander and creation of `usercmd` *if necessary*)  
└── TotalCommander/
       ├── Ini.ahk (contains functions to find `wincmd` location)
       ├── Search.ahk (searches for the `wincmd` location using all possible functions)   
       ├── Create.ahk (creates required command in the `usercmd` in the `wincmd` location)  
       └── Tabs.ahk (contains getters of one or more tabs *depending on the settings*)
```
