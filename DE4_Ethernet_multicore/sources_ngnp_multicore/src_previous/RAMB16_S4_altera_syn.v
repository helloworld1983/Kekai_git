// megafunction wizard: %RAM: 1-PORT%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: altsyncram 

// ============================================================
// File Name: RAMB16_S4_altera.v
// Megafunction Name(s):
// 			altsyncram
//
// Simulation Library Files(s):
// 			altera_mf
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 10.1 Build 197 01/19/2011 SP 1 SJ Full Version
// ************************************************************


//Copyright (C) 1991-2011 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


//altsyncram CLOCK_ENABLE_INPUT_A="NORMAL" CLOCK_ENABLE_OUTPUT_A="NORMAL" DEVICE_FAMILY="Stratix II" ENABLE_RUNTIME_MOD="NO" INIT_FILE="./sources_ngnp_multicore/src/lr0_0.mif" NUMWORDS_A=4096 OPERATION_MODE="SINGLE_PORT" OUTDATA_ACLR_A="CLEAR0" OUTDATA_REG_A="CLOCK0" POWER_UP_UNINITIALIZED="FALSE" WIDTH_A=4 WIDTH_BYTEENA_A=1 WIDTHAD_A=12 aclr0 address_a clock0 clocken0 data_a q_a wren_a
//VERSION_BEGIN 10.1SP1 cbx_altsyncram 2011:01:19:21:13:40:SJ cbx_cycloneii 2011:01:19:21:13:40:SJ cbx_lpm_add_sub 2011:01:19:21:13:40:SJ cbx_lpm_compare 2011:01:19:21:13:40:SJ cbx_lpm_decode 2011:01:19:21:13:40:SJ cbx_lpm_mux 2011:01:19:21:13:40:SJ cbx_mgl 2011:01:19:21:15:40:SJ cbx_stratix 2011:01:19:21:13:40:SJ cbx_stratixii 2011:01:19:21:13:40:SJ cbx_stratixiii 2011:01:19:21:13:40:SJ cbx_stratixv 2011:01:19:21:13:40:SJ cbx_util_mgl 2011:01:19:21:13:40:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463


//synthesis_resources = ram_bits (AUTO) 16384 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
(* ALTERA_ATTRIBUTE = {"OPTIMIZE_POWER_DURING_SYNTHESIS=NORMAL_COMPILATION"} *)
module  RAMB16_S4_altera_altsyncram
	( 
	aclr0,
	address_a,
	clock0,
	clocken0,
	data_a,
	q_a,
	wren_a) /* synthesis synthesis_clearbox=1 */;
	input   aclr0;
	input   [11:0]  address_a;
	input   clock0;
	input   clocken0;
	input   [3:0]  data_a;
	output   [3:0]  q_a;
	input   wren_a;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   aclr0;
	tri1   clock0;
	tri1   clocken0;
	tri1   [3:0]  data_a;
	tri0   wren_a;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [0:0]   wire_ram_block1a_0portadataout;
	wire  [0:0]   wire_ram_block1a_1portadataout;
	wire  [0:0]   wire_ram_block1a_2portadataout;
	wire  [0:0]   wire_ram_block1a_3portadataout;
	wire  [11:0]  address_a_wire;

	stratixii_ram_block   ram_block1a_0
	( 
	.clk0(clock0),
	.clr0(aclr0),
	.ena0(clocken0),
	.portaaddr({address_a_wire[11:0]}),
	.portadatain({data_a[0]}),
	.portadataout(wire_ram_block1a_0portadataout[0:0]),
	.portawe(wren_a),
	.portbdataout()
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clk1(1'b0),
	.clr1(1'b0),
	.ena1(1'b1),
	.portaaddrstall(1'b0),
	.portabyteenamasks({1{1'b1}}),
	.portbaddr({1{1'b0}}),
	.portbaddrstall(1'b0),
	.portbbyteenamasks({1{1'b1}}),
	.portbdatain({1{1'b0}}),
	.portbrewe(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	defparam
		ram_block1a_0.connectivity_checking = "OFF",
		ram_block1a_0.init_file = "./sources_ngnp_multicore/src/lr0_0.mif",
		ram_block1a_0.init_file_layout = "port_a",
		ram_block1a_0.logical_ram_name = "ALTSYNCRAM",
		ram_block1a_0.mem_init0 = 2048'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
		ram_block1a_0.mem_init1 = 2048'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
		ram_block1a_0.operation_mode = "single_port",
		ram_block1a_0.port_a_address_width = 12,
		ram_block1a_0.port_a_data_out_clear = "clear0",
		ram_block1a_0.port_a_data_out_clock = "clock0",
		ram_block1a_0.port_a_data_width = 1,
		ram_block1a_0.port_a_disable_ce_on_input_registers = "off",
		ram_block1a_0.port_a_disable_ce_on_output_registers = "off",
		ram_block1a_0.port_a_first_address = 0,
		ram_block1a_0.port_a_first_bit_number = 0,
		ram_block1a_0.port_a_last_address = 4095,
		ram_block1a_0.port_a_logical_ram_depth = 4096,
		ram_block1a_0.port_a_logical_ram_width = 4,
		ram_block1a_0.power_up_uninitialized = "false",
		ram_block1a_0.ram_block_type = "AUTO",
		ram_block1a_0.lpm_type = "stratixii_ram_block",
		ram_block1a_0.lpm_hint = "DONT_POWER_OPTIMIZE=ON";
	stratixii_ram_block   ram_block1a_1
	( 
	.clk0(clock0),
	.clr0(aclr0),
	.ena0(clocken0),
	.portaaddr({address_a_wire[11:0]}),
	.portadatain({data_a[1]}),
	.portadataout(wire_ram_block1a_1portadataout[0:0]),
	.portawe(wren_a),
	.portbdataout()
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clk1(1'b0),
	.clr1(1'b0),
	.ena1(1'b1),
	.portaaddrstall(1'b0),
	.portabyteenamasks({1{1'b1}}),
	.portbaddr({1{1'b0}}),
	.portbaddrstall(1'b0),
	.portbbyteenamasks({1{1'b1}}),
	.portbdatain({1{1'b0}}),
	.portbrewe(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	defparam
		ram_block1a_1.connectivity_checking = "OFF",
		ram_block1a_1.init_file = "./sources_ngnp_multicore/src/lr0_0.mif",
		ram_block1a_1.init_file_layout = "port_a",
		ram_block1a_1.logical_ram_name = "ALTSYNCRAM",
		ram_block1a_1.mem_init0 = 2048'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
		ram_block1a_1.mem_init1 = 2048'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
		ram_block1a_1.operation_mode = "single_port",
		ram_block1a_1.port_a_address_width = 12,
		ram_block1a_1.port_a_data_out_clear = "clear0",
		ram_block1a_1.port_a_data_out_clock = "clock0",
		ram_block1a_1.port_a_data_width = 1,
		ram_block1a_1.port_a_disable_ce_on_input_registers = "off",
		ram_block1a_1.port_a_disable_ce_on_output_registers = "off",
		ram_block1a_1.port_a_first_address = 0,
		ram_block1a_1.port_a_first_bit_number = 1,
		ram_block1a_1.port_a_last_address = 4095,
		ram_block1a_1.port_a_logical_ram_depth = 4096,
		ram_block1a_1.port_a_logical_ram_width = 4,
		ram_block1a_1.power_up_uninitialized = "false",
		ram_block1a_1.ram_block_type = "AUTO",
		ram_block1a_1.lpm_type = "stratixii_ram_block",
		ram_block1a_1.lpm_hint = "DONT_POWER_OPTIMIZE=ON";
	stratixii_ram_block   ram_block1a_2
	( 
	.clk0(clock0),
	.clr0(aclr0),
	.ena0(clocken0),
	.portaaddr({address_a_wire[11:0]}),
	.portadatain({data_a[2]}),
	.portadataout(wire_ram_block1a_2portadataout[0:0]),
	.portawe(wren_a),
	.portbdataout()
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clk1(1'b0),
	.clr1(1'b0),
	.ena1(1'b1),
	.portaaddrstall(1'b0),
	.portabyteenamasks({1{1'b1}}),
	.portbaddr({1{1'b0}}),
	.portbaddrstall(1'b0),
	.portbbyteenamasks({1{1'b1}}),
	.portbdatain({1{1'b0}}),
	.portbrewe(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	defparam
		ram_block1a_2.connectivity_checking = "OFF",
		ram_block1a_2.init_file = "./sources_ngnp_multicore/src/lr0_0.mif",
		ram_block1a_2.init_file_layout = "port_a",
		ram_block1a_2.logical_ram_name = "ALTSYNCRAM",
		ram_block1a_2.mem_init0 = 2048'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001,
		ram_block1a_2.mem_init1 = 2048'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
		ram_block1a_2.operation_mode = "single_port",
		ram_block1a_2.port_a_address_width = 12,
		ram_block1a_2.port_a_data_out_clear = "clear0",
		ram_block1a_2.port_a_data_out_clock = "clock0",
		ram_block1a_2.port_a_data_width = 1,
		ram_block1a_2.port_a_disable_ce_on_input_registers = "off",
		ram_block1a_2.port_a_disable_ce_on_output_registers = "off",
		ram_block1a_2.port_a_first_address = 0,
		ram_block1a_2.port_a_first_bit_number = 2,
		ram_block1a_2.port_a_last_address = 4095,
		ram_block1a_2.port_a_logical_ram_depth = 4096,
		ram_block1a_2.port_a_logical_ram_width = 4,
		ram_block1a_2.power_up_uninitialized = "false",
		ram_block1a_2.ram_block_type = "AUTO",
		ram_block1a_2.lpm_type = "stratixii_ram_block",
		ram_block1a_2.lpm_hint = "DONT_POWER_OPTIMIZE=ON";
	stratixii_ram_block   ram_block1a_3
	( 
	.clk0(clock0),
	.clr0(aclr0),
	.ena0(clocken0),
	.portaaddr({address_a_wire[11:0]}),
	.portadatain({data_a[3]}),
	.portadataout(wire_ram_block1a_3portadataout[0:0]),
	.portawe(wren_a),
	.portbdataout()
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clk1(1'b0),
	.clr1(1'b0),
	.ena1(1'b1),
	.portaaddrstall(1'b0),
	.portabyteenamasks({1{1'b1}}),
	.portbaddr({1{1'b0}}),
	.portbaddrstall(1'b0),
	.portbbyteenamasks({1{1'b1}}),
	.portbdatain({1{1'b0}}),
	.portbrewe(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	defparam
		ram_block1a_3.connectivity_checking = "OFF",
		ram_block1a_3.init_file = "./sources_ngnp_multicore/src/lr0_0.mif",
		ram_block1a_3.init_file_layout = "port_a",
		ram_block1a_3.logical_ram_name = "ALTSYNCRAM",
		ram_block1a_3.mem_init0 = 2048'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001,
		ram_block1a_3.mem_init1 = 2048'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
		ram_block1a_3.operation_mode = "single_port",
		ram_block1a_3.port_a_address_width = 12,
		ram_block1a_3.port_a_data_out_clear = "clear0",
		ram_block1a_3.port_a_data_out_clock = "clock0",
		ram_block1a_3.port_a_data_width = 1,
		ram_block1a_3.port_a_disable_ce_on_input_registers = "off",
		ram_block1a_3.port_a_disable_ce_on_output_registers = "off",
		ram_block1a_3.port_a_first_address = 0,
		ram_block1a_3.port_a_first_bit_number = 3,
		ram_block1a_3.port_a_last_address = 4095,
		ram_block1a_3.port_a_logical_ram_depth = 4096,
		ram_block1a_3.port_a_logical_ram_width = 4,
		ram_block1a_3.power_up_uninitialized = "false",
		ram_block1a_3.ram_block_type = "AUTO",
		ram_block1a_3.lpm_type = "stratixii_ram_block",
		ram_block1a_3.lpm_hint = "DONT_POWER_OPTIMIZE=ON";
	assign
		address_a_wire = address_a,
		q_a = {wire_ram_block1a_3portadataout[0], wire_ram_block1a_2portadataout[0], wire_ram_block1a_1portadataout[0], wire_ram_block1a_0portadataout[0]};
	initial/*synthesis enable_verilog_initial_construct*/
 	begin
		$display("Warning: Memory initialization file ./sources_ngnp_multicore/src/lr0_0.mif is not of the dimensions 4096 X 4, the resulting memory design may not produce consistent simulation results.");
	end
endmodule //RAMB16_S4_altera_altsyncram
//VALID FILE


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module RAMB16_S4_altera (
	aclr,
	address,
	clken,
	clock,
	data,
	wren,
	q)/* synthesis synthesis_clearbox = 1 */;

	input	  aclr;
	input	[11:0]  address;
	input	  clken;
	input	  clock;
	input	[3:0]  data;
	input	  wren;
	output	[3:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0	  aclr;
	tri1	  clken;
	tri1	  clock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire [3:0] sub_wire0;
	wire [3:0] q = sub_wire0[3:0];

	RAMB16_S4_altera_altsyncram	RAMB16_S4_altera_altsyncram_component (
				.aclr0 (aclr),
				.address_a (address),
				.clock0 (clock),
				.data_a (data),
				.wren_a (wren),
				.clocken0 (clken),
				.q_a (sub_wire0));

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: ADDRESSSTALL_A NUMERIC "0"
// Retrieval info: PRIVATE: AclrAddr NUMERIC "0"
// Retrieval info: PRIVATE: AclrByte NUMERIC "0"
// Retrieval info: PRIVATE: AclrData NUMERIC "0"
// Retrieval info: PRIVATE: AclrOutput NUMERIC "1"
// Retrieval info: PRIVATE: BYTE_ENABLE NUMERIC "0"
// Retrieval info: PRIVATE: BYTE_SIZE NUMERIC "8"
// Retrieval info: PRIVATE: BlankMemory NUMERIC "0"
// Retrieval info: PRIVATE: CLOCK_ENABLE_INPUT_A NUMERIC "1"
// Retrieval info: PRIVATE: CLOCK_ENABLE_OUTPUT_A NUMERIC "1"
// Retrieval info: PRIVATE: Clken NUMERIC "1"
// Retrieval info: PRIVATE: DataBusSeparated NUMERIC "1"
// Retrieval info: PRIVATE: IMPLEMENT_IN_LES NUMERIC "0"
// Retrieval info: PRIVATE: INIT_FILE_LAYOUT STRING "PORT_A"
// Retrieval info: PRIVATE: INIT_TO_SIM_X NUMERIC "0"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Stratix II"
// Retrieval info: PRIVATE: JTAG_ENABLED NUMERIC "0"
// Retrieval info: PRIVATE: JTAG_ID STRING "NONE"
// Retrieval info: PRIVATE: MAXIMUM_DEPTH NUMERIC "0"
// Retrieval info: PRIVATE: MIFfilename STRING "./sources_ngnp_multicore/src/lr0_0.mif"
// Retrieval info: PRIVATE: NUMWORDS_A NUMERIC "4096"
// Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "0"
// Retrieval info: PRIVATE: READ_DURING_WRITE_MODE_PORT_A NUMERIC "3"
// Retrieval info: PRIVATE: RegAddr NUMERIC "1"
// Retrieval info: PRIVATE: RegData NUMERIC "1"
// Retrieval info: PRIVATE: RegOutput NUMERIC "1"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "1"
// Retrieval info: PRIVATE: SingleClock NUMERIC "1"
// Retrieval info: PRIVATE: UseDQRAM NUMERIC "1"
// Retrieval info: PRIVATE: WRCONTROL_ACLR_A NUMERIC "0"
// Retrieval info: PRIVATE: WidthAddr NUMERIC "12"
// Retrieval info: PRIVATE: WidthData NUMERIC "4"
// Retrieval info: PRIVATE: rden NUMERIC "0"
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: CONSTANT: CLOCK_ENABLE_INPUT_A STRING "NORMAL"
// Retrieval info: CONSTANT: CLOCK_ENABLE_OUTPUT_A STRING "NORMAL"
// Retrieval info: CONSTANT: INIT_FILE STRING "./sources_ngnp_multicore/src/lr0_0.mif"
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Stratix II"
// Retrieval info: CONSTANT: LPM_HINT STRING "ENABLE_RUNTIME_MOD=NO"
// Retrieval info: CONSTANT: LPM_TYPE STRING "altsyncram"
// Retrieval info: CONSTANT: NUMWORDS_A NUMERIC "4096"
// Retrieval info: CONSTANT: OPERATION_MODE STRING "SINGLE_PORT"
// Retrieval info: CONSTANT: OUTDATA_ACLR_A STRING "CLEAR0"
// Retrieval info: CONSTANT: OUTDATA_REG_A STRING "CLOCK0"
// Retrieval info: CONSTANT: POWER_UP_UNINITIALIZED STRING "FALSE"
// Retrieval info: CONSTANT: WIDTHAD_A NUMERIC "12"
// Retrieval info: CONSTANT: WIDTH_A NUMERIC "4"
// Retrieval info: CONSTANT: WIDTH_BYTEENA_A NUMERIC "1"
// Retrieval info: USED_PORT: aclr 0 0 0 0 INPUT GND "aclr"
// Retrieval info: USED_PORT: address 0 0 12 0 INPUT NODEFVAL "address[11..0]"
// Retrieval info: USED_PORT: clken 0 0 0 0 INPUT VCC "clken"
// Retrieval info: USED_PORT: clock 0 0 0 0 INPUT VCC "clock"
// Retrieval info: USED_PORT: data 0 0 4 0 INPUT NODEFVAL "data[3..0]"
// Retrieval info: USED_PORT: q 0 0 4 0 OUTPUT NODEFVAL "q[3..0]"
// Retrieval info: USED_PORT: wren 0 0 0 0 INPUT NODEFVAL "wren"
// Retrieval info: CONNECT: @aclr0 0 0 0 0 aclr 0 0 0 0
// Retrieval info: CONNECT: @address_a 0 0 12 0 address 0 0 12 0
// Retrieval info: CONNECT: @clock0 0 0 0 0 clock 0 0 0 0
// Retrieval info: CONNECT: @clocken0 0 0 0 0 clken 0 0 0 0
// Retrieval info: CONNECT: @data_a 0 0 4 0 data 0 0 4 0
// Retrieval info: CONNECT: @wren_a 0 0 0 0 wren 0 0 0 0
// Retrieval info: CONNECT: q 0 0 4 0 @q_a 0 0 4 0
// Retrieval info: GEN_FILE: TYPE_NORMAL RAMB16_S4_altera.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL RAMB16_S4_altera.inc TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL RAMB16_S4_altera.cmp TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL RAMB16_S4_altera.bsf TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL RAMB16_S4_altera_inst.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL RAMB16_S4_altera_bb.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL RAMB16_S4_altera_waveforms.html TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL RAMB16_S4_altera_wave*.jpg FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL RAMB16_S4_altera_syn.v TRUE
// Retrieval info: LIB_FILE: altera_mf
