# ----------------------------------------------------------------------------
#       _____
#      *     *
#     *____   *____
#    * *===*   *==*
#   *___*===*___**  AVNET
#        *======*
#         *====*
# ----------------------------------------------------------------------------
# 
#  This design is the property of Avnet.  Publication of this
#  design is not authorized without written consent from Avnet.
# 
#  Please direct any questions to the PicoZed community support forum:
#     http://www.picozed.org/forum
# 
#  Product information is available at:
#     http://www.picozed.org/product/picozed
# 
#  Disclaimer:
#     Avnet, Inc. makes no warranty for the use of this code or design.
#     This code is provided  "As Is". Avnet, Inc assumes no responsibility for
#     any errors, which may appear in this code, nor does it make a commitment
#     to update the information contained herein. Avnet, Inc specifically
#     disclaims any implied warranties of fitness for a particular purpose.
#                      Copyright(c) 2015 Avnet, Inc.
#                              All rights reserved.
# 
# ----------------------------------------------------------------------------
# 
#  Create Date:         Nov 23, 2015
#  Design Name:         PicoZed FMC2 + ALI3 Display Kit
#  Module Name:         pz_fmc2_ali3_sharp7_sdk.tcl
#  Project Name:        PicoZed FMC2 + ALI3 Display Kit
#  Target Devices:      Xilinx Zynq-7000
#  Hardware Boards:     PicoZed, PicoZed FMC2 Carrier, ALI3 Display Kit
# 
#  Tool versions:       Vivado 2015.2
# 
#  Description:         Build Script for Zed Display Kit design
# 
#  Dependencies:        To be called from a configured make script call
#                       Calls support scripts, such as board configuration 
#                       scripts IP generation scripts or others as needed
# 
#
#  Revision:            Nov 23, 2015: 1.00 Initial version
# 
# ----------------------------------------------------------------------------

# 'private' used to allow this project to be privately tagged
# 'public' used to allow this project to be publicly tagged
set release_state public

# Generate Avnet IP
puts "***** Generating IP..."
source ./makeip.tcl -notrace
avnet_generate_ip debounce
avnet_generate_ip vtiming_gen
avnet_generate_ip zed_ali3_controller

# Create Vivado project
puts "***** Creating Vivado Project..."
source ../Boards/$board/$board.tcl -notrace
avnet_create_project $project $projects_folder $scriptdir

# Remove the default master constraints that are used in creating the project
remove_files -fileset constrs_1 *.xdc

# Add the display kit constraints for the verison of SOM that is being built.
avnet_add_ali3_display_kit $project $projects_folder $scriptdir

# Add the User IO constraints for the verison of SOM that is being built.
avnet_add_user_io $project $projects_folder $scriptdir

# Add timing constraints for the project being built.
add_files -fileset constrs_1 -norecurse ${projects_folder}/../pz_fmc2_ali3_pmod.xdc

# Add Avnet IP Repository
puts "***** Updating Vivado to include IP Folder"
cd ../Projects/$project
set_property ip_repo_paths  ../../IP [current_fileset]
update_ip_catalog

# Create Block Design and Add PS core
puts "***** Creating Block Design..."
create_bd_design ${project}

# Add the Processing System according to custom PicoZed presets
avnet_add_custom_ps $project $projects_folder $scriptdir

# General Config
puts "***** General Configuration for Design..."
set_property target_language VHDL [current_project]

# Create Block Diagram
set design_name ${project}
source ../../Scripts/ProjectScripts/${project}_bd.tcl

# Add Project source files
puts "***** Adding Source Files to Block Design..."
make_wrapper -files [get_files ${projects_folder}/${project}.srcs/sources_1/bd/${project}/${project}.bd] -top
add_files -norecurse ${projects_folder}/${project}.srcs/sources_1/bd/${project}/hdl/${project}_wrapper.vhd

# Build the binary
#*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#*- KEEP OUT, do not touch this section unless you know what you are doing! -*
#*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
puts "***** Building Binary..."
# add this to allow up+enter rebuild capability 
cd $scripts_folder
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
save_bd_design
launch_runs impl_1 -to_step write_bitstream
#*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#*- KEEP OUT, do not touch this section unless you know what you are doing! -*
#*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
