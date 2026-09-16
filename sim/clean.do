# Force a clean rebuild without closing the ModelSim GUI.
# Run from the Transcript window with:
#     do clean.do

quietly catch {quit -sim}

if {[file isdirectory work]} {
    vdel -lib work -all
}

do run.do
