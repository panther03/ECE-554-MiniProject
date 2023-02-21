onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /spart_tb/clk
add wave -noupdate /spart_tb/rst_n
add wave -noupdate /spart_tb/tx_q_full
add wave -noupdate /spart_tb/rx_q_empty
add wave -noupdate /spart_tb/spart_rx
add wave -noupdate /spart_tb/spart_tx
add wave -noupdate /spart_tb/srb_reg_temp
add wave -noupdate /spart_tb/db_temp
add wave -noupdate /spart_tb/uart_rx_temp
add wave -noupdate /spart_tb/new_uart_rx_data
add wave -noupdate /spart_tb/tx_fifo_half_full
add wave -noupdate /spart_tb/rx_fifo_half_full
add wave -noupdate /spart_tb/tx_fifo_stim
add wave -noupdate /spart_tb/rx_fifo_stim
add wave -noupdate /spart_tb/tx_fill_fifo_ind
add wave -noupdate /spart_tb/rx_empty_fifo_ind
add wave -noupdate /spart_tb/tx_fifo_ind
add wave -noupdate /spart_tb/rx_fifo_ind
add wave -noupdate -expand -group {Spart Reg Bus} -color Magenta /spart_tb/srb/iocs_n
add wave -noupdate -expand -group {Spart Reg Bus} -color Magenta /spart_tb/srb/iorw_n
add wave -noupdate -expand -group {Spart Reg Bus} -color Magenta /spart_tb/srb/ioaddr
add wave -noupdate -expand -group {Spart Reg Bus} -color Magenta -radix hexadecimal /spart_tb/srb/databus_out
add wave -noupdate -expand -group {Spart Reg Bus} -color Magenta -radix hexadecimal -childformat {{{/spart_tb/srb/databus[7]} -radix hexadecimal} {{/spart_tb/srb/databus[6]} -radix hexadecimal} {{/spart_tb/srb/databus[5]} -radix hexadecimal} {{/spart_tb/srb/databus[4]} -radix hexadecimal} {{/spart_tb/srb/databus[3]} -radix hexadecimal} {{/spart_tb/srb/databus[2]} -radix hexadecimal} {{/spart_tb/srb/databus[1]} -radix hexadecimal} {{/spart_tb/srb/databus[0]} -radix hexadecimal}} -subitemconfig {{/spart_tb/srb/databus[7]} {-color Magenta -height 17 -radix hexadecimal} {/spart_tb/srb/databus[6]} {-color Magenta -height 17 -radix hexadecimal} {/spart_tb/srb/databus[5]} {-color Magenta -height 17 -radix hexadecimal} {/spart_tb/srb/databus[4]} {-color Magenta -height 17 -radix hexadecimal} {/spart_tb/srb/databus[3]} {-color Magenta -height 17 -radix hexadecimal} {/spart_tb/srb/databus[2]} {-color Magenta -height 17 -radix hexadecimal} {/spart_tb/srb/databus[1]} {-color Magenta -height 17 -radix hexadecimal} {/spart_tb/srb/databus[0]} {-color Magenta -height 17 -radix hexadecimal}} /spart_tb/srb/databus
add wave -noupdate -expand -group SPART -expand -group {Queue Signals} -color Orange /spart_tb/iDUT/tx_q_full
add wave -noupdate -expand -group SPART -expand -group {Queue Signals} -color Orange /spart_tb/iDUT/rx_q_empty
add wave -noupdate -expand -group SPART -expand -group {Queue Signals} -color Orange /spart_tb/iDUT/tx_q_empty_n
add wave -noupdate -expand -group SPART -expand -group {Queue Signals} -color Orange /spart_tb/iDUT/rx_q_full_n
add wave -noupdate -expand -group SPART -expand -group {Queue Signals} -color Orange /spart_tb/iDUT/tx_old_ptr
add wave -noupdate -expand -group SPART -expand -group {Queue Signals} -color Orange /spart_tb/iDUT/tx_new_ptr
add wave -noupdate -expand -group SPART -expand -group {Queue Signals} -color Orange /spart_tb/iDUT/tx_queue_in
add wave -noupdate -expand -group SPART -expand -group {Queue Signals} -color Orange /spart_tb/iDUT/tx_queue_write
add wave -noupdate -expand -group SPART -expand -group {Queue Signals} -color Orange /spart_tb/iDUT/rx_old_ptr
add wave -noupdate -expand -group SPART -expand -group {Queue Signals} -color Orange /spart_tb/iDUT/rx_new_ptr
add wave -noupdate -expand -group SPART -expand -group {Queue Signals} -color Orange /spart_tb/iDUT/rx_queue_out
add wave -noupdate -expand -group SPART -expand -group {Queue Signals} -color Orange /spart_tb/iDUT/rx_queue_write
add wave -noupdate -expand -group SPART /spart_tb/iDUT/databuffer_reg_write
add wave -noupdate -expand -group SPART /spart_tb/iDUT/databuffer_reg_read
add wave -noupdate -expand -group SPART /spart_tb/iDUT/divbuffer_l_reg_read
add wave -noupdate -expand -group SPART /spart_tb/iDUT/divbuffer_h_reg_read
add wave -noupdate -expand -group SPART /spart_tb/iDUT/tx_data
add wave -noupdate -expand -group SPART /spart_tb/iDUT/new_data_ready
add wave -noupdate -expand -group SPART /spart_tb/iDUT/rx_data
add wave -noupdate -expand -group SPART /spart_tb/iDUT/status_reg
add wave -noupdate -expand -group SPART /spart_tb/iDUT/databus_in
add wave -noupdate -expand -group SPART /spart_tb/iDUT/databus_out
add wave -noupdate -expand -group SPART /spart_tb/iDUT/DB
add wave -noupdate -expand -group SPART /spart_tb/iDUT/tx_started
add wave -noupdate -group rx_queue /spart_tb/iDUT/rx_queue/enable
add wave -noupdate -group rx_queue /spart_tb/iDUT/rx_queue/raddr
add wave -noupdate -group rx_queue /spart_tb/iDUT/rx_queue/waddr
add wave -noupdate -group rx_queue /spart_tb/iDUT/rx_queue/wdata
add wave -noupdate -group rx_queue /spart_tb/iDUT/rx_queue/rdata
add wave -noupdate -group rx_queue /spart_tb/iDUT/rx_queue/rdata_r
add wave -noupdate -group tx_queue /spart_tb/iDUT/tx_queue/enable
add wave -noupdate -group tx_queue /spart_tb/iDUT/tx_queue/raddr
add wave -noupdate -group tx_queue /spart_tb/iDUT/tx_queue/waddr
add wave -noupdate -group tx_queue /spart_tb/iDUT/tx_queue/wdata
add wave -noupdate -group tx_queue /spart_tb/iDUT/tx_queue/rdata
add wave -noupdate -group tx_queue /spart_tb/iDUT/tx_queue/rdata_r
add wave -noupdate -group tx_queue /spart_tb/iDUT/tx_queue/i
add wave -noupdate -group uart_tx /spart_tb/iDUT/uart_tx/queue_not_empty
add wave -noupdate -group uart_tx /spart_tb/iDUT/uart_tx/tx_data
add wave -noupdate -group uart_tx /spart_tb/iDUT/uart_tx/TX
add wave -noupdate -group uart_tx /spart_tb/iDUT/uart_tx/bit_cnt
add wave -noupdate -group uart_tx -radix hexadecimal /spart_tb/iDUT/uart_tx/baud_cnt
add wave -noupdate -group uart_tx /spart_tb/iDUT/uart_tx/tx_shift_reg
add wave -noupdate -group uart_tx /spart_tb/iDUT/uart_tx/init
add wave -noupdate -group uart_tx /spart_tb/iDUT/uart_tx/shift
add wave -noupdate -group uart_tx /spart_tb/iDUT/uart_tx/transmitting
add wave -noupdate -group uart_tx /spart_tb/iDUT/uart_tx/state
add wave -noupdate -group uart_tx /spart_tb/iDUT/uart_tx/nxt_state
add wave -noupdate -expand -group Memory -color {Slate Blue} -radix hexadecimal /spart_tb/iDUT/tx_queue/mem
add wave -noupdate -expand -group Memory -color {Slate Blue} -radix hexadecimal /spart_tb/iDUT/rx_queue/mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 321
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {2734567500 ps}
