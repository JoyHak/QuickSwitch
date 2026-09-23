<div align="center">
<a href="#installation">
<img src="https://raw.githubusercontent.com/JoyHak/QuickSwitch/main/Images/banner-wide.png"></a>
<a href="https://github.com/xsnowfoxcode/QuickSwitch/releases/latest">
<img src="https://raw.githubusercontent.com/JoyHak/QuickSwitch/main/Images/badges/Download.svg" alt="从 GitHub Releases 下载"></a>
<br>快速帮助<br>
<a href="https://github.com/xsnowfoxcode/QuickSwitch/discussions/new/choose">
<img src="https://img.shields.io/github/discussions-search?query=repo%3Axsnowfoxcode%2FQuickSwitch%20is%3Aopen&style=flat&logo=TheConversation&logoColor=white&label=%E6%8F%90%E9%97%AE" alt="讨论区"></a>
<a href="https://github.com/xsnowfoxcode/QuickSwitch/issues/new/choose">
<img src="https://img.shields.io/github/issues-search?query=repo%3Axsnowfoxcode%2FQuickSwitch%20is%3Aopen%20label%3Abug&style=flat&logo=ghostery&logoColor=white&label=%E6%96%B0%E5%BB%BA%E9%94%99%E8%AF%AF&color=fdc12c" alt="提交问题"></a>
<br>相关讨论<br>
<a href="https://www.autohotkey.com/boards/viewtopic.php?f=6&t=102377&sd=d">
<img src="https://raw.githubusercontent.com/JoyHak/QuickSwitch/main/Images/badges/AutoHotkey.svg" alt="AutoHotkey"></a>
<a href="https://www.xyplorer.com/xyfc/viewtopic.php?t=28304&sd=d">
<img src="https://raw.githubusercontent.com/JoyHak/QuickSwitch/main/Images/badges/Xyplorer.svg" alt="Xyplorer"></a>
<a href="https://www.ghisler.ch/board/viewtopic.php?t=76254&sd=d">
<img src="https://raw.githubusercontent.com/JoyHak/QuickSwitch/main/Images/badges/TotalCommander.svg" alt="TotalCommander"></a>
<a href="https://resource.dopus.com/t/quickswitch/40965/20">
<img src="https://raw.githubusercontent.com/JoyHak/QuickSwitch/main/Images/badges/DirectoryOpus.svg" alt="DirectoryOpus"></a>
<a href="https://www.voidtools.com/forum/viewtopic.php?t=9881&sd=d">
<img src="https://img.shields.io/badge/Everything-orange?style=for-the-badge&logo=startpage&logoColor=ff8000&color=6c4028" alt="Everything"></a>
</div>

## 项目简介

QuickSwitch 是一个用于 Windows 文件打开/保存对话框的快速路径切换工具。它可以收集资源管理器和常用文件管理器中的已打开目录，让你在其他应用的文件对话框中快速跳转，而不必重复浏览目录。

本项目基于 [JoyHak/QuickSwitch](https://github.com/JoyHak/QuickSwitch) 开源项目进行维护，保留原项目功能、版权声明和 GPL-3.0 许可证，并将界面与使用说明调整为简体中文，同时补充本地化修复、文档和发布流程。上游来源及许可证信息请参阅[上游与许可证说明](docs/上游与许可证.md)。

当前版本为 `v1.9.1`。此版本修复了 UNC 网络共享路径在处理过程中丢失开头两个反斜杠的问题，例如：`\\10.0.99.201\QuickSwitch-main`。修复覆盖路径校验、资源管理器 URL 解码和自动跳转流程。

### 主要功能

- 在文件打开/保存对话框中快速切换目录。
- 支持 Windows 资源管理器、Directory Opus、Total Commander 和 XYplorer 等文件管理器。
- 使用 `Ctrl+Q` 打开路径菜单，使用 `Ctrl+Shift+Win+0` 在任意应用中强制打开菜单。
- 支持固定路径、剪贴板路径和收藏路径。
- 支持 AutoSwitch，在文件对话框打开时自动切换到合适的目录。
- 简体中文界面，并保留必要的 Windows、AutoHotkey 和文件管理器名称。
- 支持本地磁盘路径、相对路径以及 `\\server\share` 形式的 UNC 网络路径。

假设你正在打开或保存文件，QuickSwitch 可以直接显示最近使用的目录：

![](Images/menu.gif)

在支持的文件管理器中打开几个标签页后，按 `Ctrl+Q` 即可在菜单中切换这些路径。你也可以[固定和保存常用路径](#menu-sections)，稍后在其他文件管理器或应用中打开。

启用“AutoSwitch”后，文件对话框可以自动切换路径：

![](Images/autoswitch.gif)

菜单的样式、快捷键和显示方式也可以按需调整：

<img src="Images/settings.gif" width=720>

## 安装

<a name="installation"></a>
<a href="https://github.com/xsnowfoxcode/QuickSwitch/releases/latest">
<img src="https://img.shields.io/github/v/release/xsnowfoxcode/QuickSwitch?display_name=tag&style=flat" alt="版本"></a>
<a href="https://github.com/xsnowfoxcode/QuickSwitch/releases/latest">
<img src="https://img.shields.io/github/downloads/xsnowfoxcode/QuickSwitch/total?style=flat&color=fb9233" alt="下载量"></a>

本 Fork 通过 [GitHub Releases](https://github.com/xsnowfoxcode/QuickSwitch/releases) 提供可校验的压缩包。请从本 Fork 的 Release 下载，不要使用 `JoyHak.QuickSwitch` 等上游包管理器命令，因为它们安装的是原项目版本。

### 手动安装

1. 根据系统架构下载最新的 [x64 或 x32 压缩包](https://github.com/xsnowfoxcode/QuickSwitch/releases/latest)。不确定时通常先选择 x64；不要在 x64 系统上无必要地使用 x32 版本。
2. 新建一个固定目录，例如 `C:\QuickSwitch`，将压缩包解压到该目录。升级时直接覆盖程序文件即可，已有 `.ini` 配置不会被替换。
3. 运行 `QuickSwitch.exe`，然后在支持的文件管理器中打开几个目录；也可以在 `Favorites` 目录中创建 `.lnk` 快捷方式。
4. 打开记事本或其他应用的文件打开/保存对话框，例如“文件 - 打开”。
5. 按 `Ctrl+Q` 打开菜单，检查已打开的目录是否显示。
6. 在“菜单设置”中按需调整菜单样式、快捷键和路径显示方式。

![安装示例](Images/installation.avif)

## 外观与路径显示

<a name="appearance"></a>

### 缩短路径

在“设置 > 短路径”中，可以设置显示的目录层数和每个目录名称的最大长度。例如，将“目录层数”设置为 `2`，路径 `C:\Windows\System32\Resources` 可以缩短为 `System32\Resources`；将“目录名称长度”设置为 `3`，则可以显示为 `Sys..\Res..`。

你还可以显示盘符、修改目录分隔符，或选择缩短路径的开头/结尾。菜单中的下划线字母可以直接作为快捷键，例如 `C̲:\Windows` 按 `C` 即可选择该路径。

<details><summary>下划线快捷键示例</summary>

`C̲:\Windows`：按 `C` 选择路径。<br>
`W̲indows\System32`：按 `W` 选择路径。<br>
`.̲.̲Windows`：按 `.` 选择路径。<br>
`~̲Windows`：按 `~` 选择路径。

</details>

### 菜单分区

<a name="menu-sections"></a>

除了文件管理器中的路径，还可以在“设置 > 外观”中启用置顶路径、剪贴板目录和收藏夹。

<a name="pinned"></a>

<details><summary>固定路径（始终显示）</summary>

启用“设置 > 外观 > 置顶路径”，再到“设置 > 应用 > 置顶路径”选择固定路径的按键或鼠标按钮。打开菜单后按住该键并单击路径，即可将路径固定到配置中，之后每次启动都会显示。

关闭显示选项只会暂时隐藏置顶路径；重新启用后仍会显示。若要删除所有置顶路径，可在“设置 > 重置 > 置顶路径”中确认删除。

</details>

<a name="clipboard"></a>

<details><summary>剪贴板路径（临时显示）</summary>

复制文件或目录路径后，路径会显示在菜单中，并持续到你在另一个应用中打开新的文件对话框。若希望长期保留，请改为置顶路径。

如果复制的是文件，QuickSwitch 会去掉最后一个反斜杠后的文件名，只使用文件所在目录。使用 `Ctrl+Shift+Win+0` 强制打开菜单时，剪贴板路径仍会保留，便于在多个应用中使用。

</details>

<a name="favorites"></a>

<details><summary>收藏路径（可自定义图标和名称）</summary>

启用“设置 > 外观 > 收藏夹”，并指定存放 `.lnk` 快捷方式的目录。QuickSwitch 会递归读取其中的快捷方式；快捷方式的目标路径、`Start in`、注释和图标都会影响菜单中的显示效果。

快捷方式的 `Comment` 可用来设置菜单名称，`Target` 或 `Start in` 用来指定路径。所有相关字段都支持[变量](#variables)。不再需要的快捷方式可以移除扩展名，或通过 `Settings > Reset > Delete favorite paths` 移到回收站。

</details>

#### 变量

<a name="variables"></a>

路径设置支持绝对路径、相对于 QuickSwitch 所在目录的相对路径、[Windows 环境变量](https://learn.microsoft.com/en-us/windows/deployment/usmt/usmt-recognized-environment-variables)、[AutoHotkey 内置变量](https://www.autohotkey.com/docs/v1/Variables.htm#BuiltIn)和 [QuickSwitch 变量](Lib/Values.ahk)。变量需要使用百分号包围，例如：

```text
Icons
%AppData%\Icons
%A_ScriptDir%\Icons
%SYSTEM_PATH%\%IconsDir%\SubDir
C:\%IconsDir%
```

如果启用了“设置 > 外观 > 剪贴板目录”，剪贴板中的变量也会自动展开。

## 快捷键

<a name="keyboard"></a>

设置中的选项和按钮通常带有一个下划线字母，按下该字母可以快速定位到对应选项。主要按键如下：

- 路径：`0-9`
- AutoSwitch：`A`
- 黑名单：`B`
- 设置：`S`
- 隐藏菜单：`Esc` 或单击任意位置

在“设置 > 应用”中可以修改主快捷键、置顶路径按键和重启按键，也可以选择 `CapsLock`、`Win` 或鼠标中键。文件对话框打开时，`Space`、`Win`、`CapsLock` 等按键可能被 QuickSwitch 占用，这是为了支持对应的快捷操作。

## 在任意应用中强制打开菜单

<a name="enforce-menu"></a>

使用 `Ctrl+Shift+Win+0` 可以在任意应用中打开 QuickSwitch 菜单，包括支持的文件管理器。菜单会显示上一次打开文件对话框时收集的路径，并在下一次打开文件对话框前保持不变。第一次使用此功能时菜单可能为空；建议[固定常用路径](#menu-sections)以便始终显示。

例如，在 Notepad++ 中按下该快捷键，然后选择一个路径，Notepad++ 可以打开该目录中的文件。

## UNC 网络共享路径

QuickSwitch `v1.9.1` 已修复 UNC 路径处理问题。以下路径的开头两个反斜杠会在整个流程中保留：

```text
\\10.0.99.201\QuickSwitch-main
```

因此，来自文件管理器或剪贴板的网络共享目录可以正常完成路径校验、资源管理器 URL 解码和文件对话框自动跳转。使用网络共享目录时，当前 Windows 账户仍必须拥有相应的访问权限。

## 使用限制与排查

- 当前 Windows 账户必须能够访问目标本地目录或网络共享目录。
- 虚拟目录、快速访问、桌面等位置可能无法被文件管理器接口稳定识别。
- 建议定期打开需要使用的文件管理器；同时打开大量窗口时，程序较难判断最后使用的窗口。
- QuickSwitch 与其他应用交互时会受到 Windows 权限隔离（UIPI）影响。若目标应用以管理员身份运行，QuickSwitch 也可能需要以管理员身份运行；两者尽量保持相同权限级别。

## 反馈与贡献

请通过 [本 Fork 的 Issues](https://github.com/xsnowfoxcode/QuickSwitch/issues/new/choose) 报告问题或提出建议，也可以阅读[贡献指南](CONTRIBUTING.md)。提交 UNC 路径问题时，建议同时说明 Windows 版本、QuickSwitch 架构、目标应用和可复现的路径形式。

## 编译与维护

<a href="https://deepwiki.com/JoyHak/QuickSwitch/11.1-build-system">
<img src="https://deepwiki.com/badge.svg" alt="构建系统"></a>

QuickSwitch 使用 AutoHotkey v1 编写，可以通过 Ahk2Exe 编译为单文件 EXE。运行源码版本需要 AutoHotkey v1.1.37.02 Unicode；运行构建脚本 `Utilities/Build.ahk` 需要 AutoHotkey v2。Ahk2Exe 通常随 AutoHotkey 安装程序提供。

1. 克隆或[下载本仓库](https://github.com/xsnowfoxcode/QuickSwitch/archive/refs/heads/main.zip)。
2. 使用 AutoHotkey v2 打开并运行 [`Utilities/Build.ahk`](Utilities/Build.ahk)。
3. 根据需要设置构建脚本中的路径和选项；主源码文件为 `QuickSwitch-1.9.1.ahk`。
4. 构建完成后，在 `dist` 目录检查 x64/x32 产物。

完整的构建、测试、发布和上游同步流程请参阅[维护与发布说明](docs/维护与发布.md)。发布包提供 SHA-256 校验值；本项目目前没有代码签名证书，不声明官方签名。

## 许可证与致谢

本项目以 GPL-3.0 许可证发布，完整条款见 [`LICENSE`](LICENSE)。这是由 `xsnowfoxcode` 维护的社区 Fork，原始项目为 [JoyHak/QuickSwitch](https://github.com/JoyHak/QuickSwitch)。本项目保留原作者及历史贡献者的版权和致谢信息，详细来源记录见[上游与许可证说明](docs/上游与许可证.md)。

QuickSwitch 的早期基础来自 [Gepruts](https://github.com/gepruts)，后续得到 DaWolfi、NotNull、Tuska、highend、Dalai、Horst、Arsiendle、Noticz、eddablin 和 FuPeiJiang 等贡献者在功能设计、文件管理器支持、测试和问题修复方面的帮助。感谢所有参与开发和测试的人。

版本变更记录请参阅 [`CHANGELOG.md`](CHANGELOG.md)，安全问题请参阅 [`SECURITY.md`](SECURITY.md)。
