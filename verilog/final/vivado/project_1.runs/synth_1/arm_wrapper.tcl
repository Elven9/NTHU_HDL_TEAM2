# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param xicom.use_bs_reader 1
create_project -in_memory -part xc7a35tcpg236-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir C:/Users/Administrator/verilog/NTHU_HDL_TEAM2/verilog/final/vivado/project_1.cache/wt [current_project]
set_property parent.project_path C:/Users/Administrator/verilog/NTHU_HDL_TEAM2/verilog/final/vivado/project_1.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_repo_paths c:/Users/Administrator/verilog/NTHU_HDL_TEAM2/verilog/final/vivado/ip [current_project]
set_property ip_output_repo c:/Users/Administrator/verilog/NTHU_HDL_TEAM2/verilog/final/vivado/project_1.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_verilog -library xil_defaultlib {
  C:/Users/Administrator/verilog/NTHU_HDL_TEAM2/verilog/final/source_codes/clockDivider.v
  C:/Users/Administrator/verilog/NTHU_HDL_TEAM2/verilog/final/source_codes/keyboard.v
  C:/Users/Administrator/verilog/NTHU_HDL_TEAM2/verilog/final/source_codes/onePulse.v
  C:/Users/Administrator/verilog/NTHU_HDL_TEAM2/verilog/final/source_codes/servo.v
  C:/Users/Administrator/verilog/NTHU_HDL_TEAM2/verilog/final/source_codes/switchPulse.v
  C:/Users/Administrator/verilog/NTHU_HDL_TEAM2/verilog/final/source_codes/main.v
}
read_ip -quiet C:/Users/Administrator/verilog/NTHU_HDL_TEAM2/verilog/final/vivado/project_1.srcs/sources_1/ip/KeyboardCtrl_0/KeyboardCtrl_0.xci

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc C:/Users/Administrator/verilog/NTHU_HDL_TEAM2/verilog/final/vivado/project_1.srcs/constrs_1/new/cos.xdc
set_property used_in_implementation false [get_files C:/Users/Administrator/verilog/NTHU_HDL_TEAM2/verilog/final/vivado/project_1.srcs/constrs_1/new/cos.xdc]

set_param ips.enableIPCacheLiteLoad 0
close [open __synthesis_is_running__ w]

synth_design -top arm_wrapper -part xc7a35tcpg236-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef arm_wrapper.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file arm_wrapper_utilization_synth.rpt -pb arm_wrapper_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]