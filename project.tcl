set build_dir ./build
set project_name ethernet_mac

file mkdir $build_dir

create_project -force $project_name $build_dir/$project_name -part xc7a100tcsg324-1

set design_files     [glob -nocomplain rtl/*]
set constraint_files [glob -nocomplain const/*]
set simulation_files [glob -nocomplain sim/*]

set has_example [expr [llength $argv] >= 1 && [lindex $argv 0]]

if $has_example {
	set design_files     [concat $design_files     [glob -nocomplain example/rtl/*]]
	set constraint_files [concat $constraint_files [glob -nocomplain example/const/*]]
	set simulation_files [concat $simulation_files [glob -nocomplain example/sim/*]]
}

if [llength $design_files]     {add_files -fileset sources_1 $design_files}
if [llength $constraint_files] {add_files -fileset constrs_1 $constraint_files}
if [llength $simulation_files] {add_files -fileset sim_1     $simulation_files}

if $has_example {set_property top test_bench [get_filesets sim_1]}

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1