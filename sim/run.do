# Pure RTL ModelSim compile and simulation flow.
# From the ModelSim Transcript window, rerun everything with:
#     do run.do

transcript on

# -----------------------------------------------------------------------------
# Project settings: edit these when reusing the template.


# TOP is the top-level design unit/module name (for example: tb), not a source filename.
set TOP       tb

# RUN_TIME is passed to `run $RUN_TIME`; use `-all` (not `all`) to run until completion.
set RUN_TIME  250ns

# Sources are compiled in this order: RTL first, then testbench.
set RTL_FILES [concat \
    [glob -nocomplain ../rtl/*.v] \
    [glob -nocomplain ../rtl/*.sv]]

set TB_FILES [concat \
    [glob -nocomplain ../tb/*.v] \
    [glob -nocomplain ../tb/*.sv]]

if {[llength $RTL_FILES] == 0} {
    error "No RTL source files found under ../rtl"
}
if {[llength $TB_FILES] == 0} {
    error "No testbench source files found under ../tb"
}

# -----------------------------------------------------------------------------
# Unload, incrementally compile, elaborate, load and run.
# quit -sim only unloads the current design; it does not close ModelSim.
# -----------------------------------------------------------------------------
quietly catch {quit -sim}

if {![file isdirectory work]} {
    vlib work
}
vmap work work

# All source paths are supplied so dependencies remain explicit. With -incr,
# vlog skips unchanged compilation units and recompiles the changed units.
eval vlog -sv -incr -work work $RTL_FILES $TB_FILES

# Loading a design changes ModelSim's command context. Schedule the remaining
# commands after loading so both first launch and Transcript reruns are reliable.
set POST_LOAD_DO "add wave *; view wave; view structure; view signals; run $RUN_TIME; wave zoom full"
vsim -voptargs=+acc -do $POST_LOAD_DO work.$TOP
