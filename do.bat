@echo off
setlocal

set "SIM_DIR=%~dp0sim"
set "MODELSIM_EXE="

for /f "delims=" %%I in ('where modelsim.exe 2^>nul') do if not defined MODELSIM_EXE set "MODELSIM_EXE=%%I"

if not defined MODELSIM_EXE (
    echo ERROR: modelsim.exe was not found in PATH.
    echo Add the ModelSim win64 directory to PATH, then open a new terminal.
    exit /b 1
)

pushd "%SIM_DIR%"
if errorlevel 1 (
    echo ERROR: Cannot enter simulation directory: %SIM_DIR%
    exit /b 1
)

echo Using ModelSim: %MODELSIM_EXE%
start "ModelSim RTL Simulation" "%MODELSIM_EXE%" -do "do {run.do}" -l transcript.log
popd

endlocal
