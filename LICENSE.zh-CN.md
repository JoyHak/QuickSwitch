# 上游与许可证

## 项目来源

该项目的中文版本由作者 [xsnowfoxcode](https://github.com/xsnowfoxcode) 负责维护

- 上游仓库：<https://github.com/JoyHak/QuickSwitch>
- 当前 Fork：<https://github.com/xsnowfoxcode/QuickSwitch>
- 本地 Git 远程：`origin` 指向 Fork，`upstream` 指向原项目。

不需要持续获得上游作者许可，也不要求 Fork 与上游自动同步。日后如需吸收上游修复，应先比较差异、单独测试，再通过 `upstream/main` 合并；不能直接覆盖本地改进。

## GPL-3.0 要求

仓库保留上游的 `LICENSE` 文件，并继续按照 GNU GPL v3 分发。发布修改版本时：

1. 保留原版权和许可证声明。
2. 在变更记录或源文件中说明这是修改后的版本。
3. 分发 EXE 时同时提供对应源代码或可获取源代码的位置。
4. 不把本项目的派生代码改成仅允许闭源使用的许可证。
5. 新增代码默认按 GPL-3.0 兼容方式发布。

本 Fork 的修改记录见 [CHANGELOG.md](https://github.com/xsnowfoxcode/QuickSwitch/blob/main/docs/%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E.md)。本项目不代表上游作者，也不使用上游的代码签名证书或发布签名声明。

## 构建依赖

AutoHotkey、Ahk2Exe 和 7-Zip 是构建依赖，不作为本仓库源码的一部分提交。编译器缓存、旧 EXE、用户配置和运行日志均被 `.gitignore` 排除；如分发这些工具，必须同时遵守各自的许可证文件。
