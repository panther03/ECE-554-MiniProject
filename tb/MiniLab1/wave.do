onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /MiniLab1_tb/iDUT/clk
add wave -noupdate /MiniLab1_tb/iDUT/RST_n
add wave -noupdate /MiniLab1_tb/iDUT/halt
add wave -noupdate /MiniLab1_tb/iDUT/SW
add wave -noupdate /MiniLab1_tb/iDUT/LEDR
add wave -noupdate /MiniLab1_tb/iDUT/RX
add wave -noupdate /MiniLab1_tb/iDUT/TX
add wave -noupdate /MiniLab1_tb/iDUT/rst_n
add wave -noupdate /MiniLab1_tb/iDUT/iaddr
add wave -noupdate /MiniLab1_tb/iDUT/daddr
add wave -noupdate /MiniLab1_tb/iDUT/inst
add wave -noupdate /MiniLab1_tb/iDUT/data_mem_to_proc_map
add wave -noupdate /MiniLab1_tb/iDUT/data_mem_to_proc_dmem
add wave -noupdate /MiniLab1_tb/iDUT/data_proc_to_mem
add wave -noupdate /MiniLab1_tb/iDUT/we_map
add wave -noupdate /MiniLab1_tb/iDUT/re_map
add wave -noupdate /MiniLab1_tb/iDUT/we_dmem
add wave -noupdate /MiniLab1_tb/iDUT/LEDR_en
add wave -noupdate /MiniLab1_tb/iDUT/LEDR_r
add wave -noupdate /MiniLab1_tb/iDUT/spart_iocs_n
add wave -noupdate /MiniLab1_tb/iDUT/spart_iorw_n
add wave -noupdate /MiniLab1_tb/iDUT/spart_ioaddr
add wave -noupdate /MiniLab1_tb/iDUT/spart_databus_in
add wave -noupdate /MiniLab1_tb/iDUT/spart_databus
add wave -noupdate -expand -group {New Group} -color {Slate Blue} -radix hexadecimal /MiniLab1_tb/iDUT/SPART/tx_queue/mem
add wave -noupdate -expand -group {New Group} -color {Slate Blue} -radix hexadecimal /MiniLab1_tb/iDUT/SPART/rx_queue/mem
add wave -noupdate -expand -group {New Group} -color {Slate Blue} /MiniLab1_tb/iDUT/SPART/tx_old_ptr
add wave -noupdate -expand -group {New Group} -color {Slate Blue} /MiniLab1_tb/iDUT/SPART/tx_new_ptr
add wave -noupdate -expand -group {New Group} -color {Slate Blue} /MiniLab1_tb/iDUT/SPART/rx_old_ptr
add wave -noupdate -expand -group {New Group} -color {Slate Blue} /MiniLab1_tb/iDUT/SPART/rx_new_ptr
add wave -noupdate -expand -group tx /MiniLab1_tb/iDUT/SPART/uart_tx/queue_not_empty
add wave -noupdate -expand -group tx /MiniLab1_tb/iDUT/SPART/uart_tx/tx_data
add wave -noupdate -expand -group tx /MiniLab1_tb/iDUT/SPART/uart_tx/baud
add wave -noupdate -expand -group tx /MiniLab1_tb/iDUT/SPART/uart_tx/tx_started
add wave -noupdate -expand -group tx /MiniLab1_tb/iDUT/SPART/uart_tx/TX
add wave -noupdate -expand -group tx /MiniLab1_tb/iDUT/SPART/uart_tx/bit_cnt
add wave -noupdate -expand -group tx /MiniLab1_tb/iDUT/SPART/uart_tx/baud_cnt
add wave -noupdate -expand -group tx /MiniLab1_tb/iDUT/SPART/uart_tx/tx_shift_reg
add wave -noupdate -expand -group tx /MiniLab1_tb/iDUT/SPART/uart_tx/init
add wave -noupdate -expand -group tx /MiniLab1_tb/iDUT/SPART/uart_tx/shift
add wave -noupdate -expand -group tx /MiniLab1_tb/iDUT/SPART/uart_tx/transmitting
add wave -noupdate -expand -group tx /MiniLab1_tb/iDUT/SPART/uart_tx/state
add wave -noupdate -expand -group tx /MiniLab1_tb/iDUT/SPART/uart_tx/nxt_state
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/RX
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/baud
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/rx_data
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/rdy
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/RX_flop1
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/RX_flop2
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/RX_ms
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/bit_cnt
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/baud_cnt
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/rx_shift_reg
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/start
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/shift
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/receiving
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/set_done
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/state
add wave -noupdate -expand -group rx /MiniLab1_tb/iDUT/SPART/uart_rx/nxt_state
add wave -noupdate -color Magenta /MiniLab1_tb/iDUT/PROC/MEM_WB_alu_out_out
add wave -noupdate -color Magenta /MiniLab1_tb/iDUT/PROC/MEM_WB_mem_out_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3568881900 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 313
configure wave -valuecolwidth 237
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {3568678300 ps} {3569221700 ps}
