# ModelSim RTL Workflow

一个轻量、无 FPGA 厂商 IP 依赖的 ModelSim RTL 前仿真模板。

模板包含一个简单的 LED 分频示例：

- `rtl/top.v`：计数器驱动 LED。
- `tb/tb.v`：生成时钟与复位，并检查 LED 是否翻转。
- `sim/run.do`：增量编译、加载、添加顶层波形并运行。
- `sim/clean.do`：删除 `work` 后做一次全量重建。
- `do.bat`：从终端启动 ModelSim GUI。

## 要求

- Windows PowerShell 5.1 或 PowerShell 7+
- ModelSim 的 `win64` 目录已加入 `PATH`

`do.bat` 会自动执行 `where modelsim.exe`。如果找不到，会给出错误并退出，不包含任何本机安装路径硬编码。

## 创建项目

安装 `eda` 函数后，在指定目录创建模板：

```powershell
eda new .\my-rtl-project
```

或者先进入一个空目录：

```powershell
mkdir my-rtl-project
cd my-rtl-project
eda init
```

两种命令都只下载并复制模板文件，不会保留模板仓库的 `.git`，也不会执行 `git init`。

## 仿真工作流

首次启动：

```powershell
.\do.bat
```

修改 RTL 或 testbench 后，在 ModelSim Transcript 中执行：

```tcl
do run.do
```

它只卸载当前仿真实例，不关闭 GUI；然后使用 `vlog -incr` 增量编译并重新加载设计。

需要排除增量缓存问题时执行：

```tcl
do clean.do
```

## 复用

1. 把 RTL 放入 `rtl/`。
2. 把 testbench 放入 `tb/`。
3. 修改 `sim/run.do` 顶部的 `TOP` 和 `RUN_TIME`。

脚本自动收集 `rtl/`、`tb/` 下的 `.v` 和 `.sv`。如果文件之间有严格编译顺序，请把 `glob` 改成显式文件列表。

## License

[MIT](LICENSE)
