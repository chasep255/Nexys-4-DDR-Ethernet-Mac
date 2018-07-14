set build_dir ./build
set project_name ethernet_mac

file mkdir $build_dir

create_project -force $project_name $build_dir/$project_name -part xc7a100tcsg324-1

set design_files     [glob src/*]
set constraint_files [glob const/*]
set simulation_files [glob sim/*]

add_files -fileset sources_1 $design_files
add_files -fileset constrs_1 $constraint_files
add_files -fileset sim_1     $simulation_files

set_property top test_bench [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

start_gui