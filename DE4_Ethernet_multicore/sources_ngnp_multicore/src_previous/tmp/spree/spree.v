//
module spree ( 
	clk,
	resetn,
	boot_iaddr,
	boot_idata,
	boot_iwe,
	boot_daddr,
	boot_ddata,
	boot_dwe,
	pipereg19_q,
	ifetch_next_pc, //inst_mem_addr
	ifetch_instr, //inst_mem_data_in
	d_wr,
	d_byteena, //data_bs
	d_writedatamem, //data_mem_data_out
	d_readdatain, //data_mem_data_in
	addersub_result //data_mem_addr
	);


/****************************************************************************
          ISA definition file

  - The MIPS I ISA has a 6 bit opcode in the upper 6 bits.  
  - The opcode can also specify a "class".  There are two classes:
            1.  SPECIAL - look in lowest 6 bits to find operation
            2.  REGIMM - look in [20:16] to find type of branch

****************************************************************************/

/****** OPCODES - bits 31...26 *******/

parameter     OP_SPECIAL      = 6'b000000;
parameter     OP_REGIMM       = 6'b000001;
parameter     OP_J            = 6'b000010;
parameter     OP_JAL          = 6'b000011;
parameter     OP_BEQ          = 6'b000100;
parameter     OP_BNE          = 6'b000101;
parameter     OP_BLEZ         = 6'b000110;
parameter     OP_BGTZ         = 6'b000111;

parameter     OP_ADDI         = 6'b001000;
parameter     OP_ADDIU        = 6'b001001;
parameter     OP_SLTI         = 6'b001010;
parameter     OP_SLTIU        = 6'b001011;
parameter     OP_ANDI         = 6'b001100;
parameter     OP_ORI          = 6'b001101;
parameter     OP_XORI         = 6'b001110;
parameter     OP_LUI          = 6'b001111;

parameter     OP_LB           = 6'b100000;
parameter     OP_LH           = 6'b100001;
parameter     OP_LWL          = 6'b100010;
parameter     OP_LW           = 6'b100011;
parameter     OP_LBU          = 6'b100100;
parameter     OP_LHU          = 6'b100101;
parameter     OP_LWR          = 6'b100110;

parameter     OP_SB           = 6'b101x00;
parameter     OP_SH           = 6'b101x01;
parameter     OP_SWL          = 6'b101010;
parameter     OP_SW           = 6'b101x11;
parameter     OP_SWR          = 6'b101110;

/****** FUNCTION CLASS - bits 5...0 *******/
parameter     FUNC_SLL        = 6'b000000;
parameter     FUNC_SRL        = 6'b000010;
parameter     FUNC_SRA        = 6'b000011;
parameter     FUNC_SLLV       = 6'b000100;
parameter     FUNC_SRLV       = 6'b000110;
parameter     FUNC_SRAV       = 6'b000111;

parameter     FUNC_JR         = 6'b001xx0;
parameter     FUNC_JALR       = 6'b001xx1;

parameter     FUNC_MFHI       = 6'bx10x00;
parameter     FUNC_MTHI       = 6'bx10x01;
parameter     FUNC_MFLO       = 6'bx10x10;
parameter     FUNC_MTLO       = 6'bx10x11;

parameter     FUNC_MULT       = 6'bx11x00;
parameter     FUNC_MULTU      = 6'bx11x01;
parameter     FUNC_DIV        = 6'bx11x10;
parameter     FUNC_DIVU       = 6'bx11x11;

parameter     FUNC_ADD        = 6'b100000;
parameter     FUNC_ADDU       = 6'b100001;
parameter     FUNC_SUB        = 6'b100010;
parameter     FUNC_SUBU       = 6'b100011;
parameter     FUNC_AND        = 6'b100100;
parameter     FUNC_OR         = 6'b100101;
parameter     FUNC_XOR        = 6'b100110;
parameter     FUNC_NOR        = 6'b100111;

parameter     FUNC_SLT        = 6'b101010;
parameter     FUNC_SLTU       = 6'b101011;

/****** REGIMM Class - bits 20...16 *******/
parameter     FUNC_BLTZ       = 1'b0;
parameter     FUNC_BGEZ       = 1'b1;

parameter     OP_COP2       = 6'b010010;
parameter     COP2_FUNC_CFC2     = 6'b111000;
parameter     COP2_FUNC_CTC2     = 6'b111010;
parameter     COP2_FUNC_MTC2     = 6'b111011;

//parameter     FUNC_BLTZAL     = 5'b10000;
//parameter     FUNC_BGEZAL     = 5'b10001;

/****** 
 * Original REGIMM class, compressed above to save decode logic
parameter     FUNC_BLTZ       = 5'b00000;
parameter     FUNC_BGEZ       = 5'b00001;
parameter     FUNC_BLTZAL     = 5'b10000;
parameter     FUNC_BGEZAL     = 5'b10001;
*/

/************************* IO Declarations *********************/
input clk;
input resetn;
input [31:0] boot_iaddr;
input [31:0] boot_idata;
input boot_iwe;
input [31:0] boot_daddr;
input [31:0] boot_ddata;
input boot_dwe;
output [31:0] pipereg19_q;
output [31:0] ifetch_next_pc;
input [31:0] ifetch_instr;
output d_wr;
output [3:0] d_byteena; //data_bs
output [31:0] d_writedatamem; //data_mem_data_out
input [31:0] d_readdatain; //data_mem_data_in
output [31:0] addersub_result; //data_mem_addr


/*********************** Signal Declarations *******************/
wire	branch_mispred;
wire	stall_2nd_delayslot;
wire	has_delayslot;
wire	haz_pipereg5_q_pipereg27_q;
wire	haz_pipereg4_q_pipereg27_q;
wire	haz_pipereg5_q_pipereg26_q;
wire	haz_pipereg4_q_pipereg26_q;
wire	haz_pipereg5_q_pipereg25_q;
wire	haz_pipereg4_q_pipereg25_q;
wire	haz_pipereg5_q_pipereg12_q;
wire	haz_pipereg4_q_pipereg12_q;
		// Datapath signals declarations
wire	addersub_result_slt;
wire	[ 31 : 0 ]	addersub_result;
wire	[ 31 : 0 ]	mul_shift_result;
wire	[ 31 : 0 ]	mul_lo;
wire	[ 31 : 0 ]	mul_hi;
wire	[ 31 : 0 ]	ifetch_pc_out;
wire	[ 31 : 0 ]	ifetch_instr;
wire	[ 5 : 0 ]	ifetch_opcode;
wire	[ 5 : 0 ]	ifetch_func;
wire	[ 4 : 0 ]	ifetch_rs;
wire	[ 4 : 0 ]	ifetch_rt;
wire	[ 4 : 0 ]	ifetch_rd;
wire	[ 25 : 0 ]	ifetch_instr_index;
wire	[ 15 : 0 ]	ifetch_offset;
wire	[ 4 : 0 ]	ifetch_sa;
wire	[ 31 : 0 ]	ifetch_next_pc;
wire	[ 31 : 0 ]	data_mem_d_loadresult;
wire	[ 31 : 0 ]	reg_file_b_readdataout;
wire	[ 31 : 0 ]	reg_file_a_readdataout;
wire	[ 31 : 0 ]	logic_unit_result;
wire	[ 31 : 0 ]	pcadder_result;
wire	[ 31 : 0 ]	signext16_out;
wire	[ 31 : 0 ]	merge26lo_out;
wire	branchresolve_eqz;
wire	branchresolve_gez;
wire	branchresolve_gtz;
wire	branchresolve_lez;
wire	branchresolve_ltz;
wire	branchresolve_ne;
wire	branchresolve_eq;
wire	[ 31 : 0 ]	hi_reg_q;
wire	[ 31 : 0 ]	lo_reg_q;
wire	[ 31 : 0 ]	const20_out;
wire	[ 31 : 0 ]	const_out;
wire	[ 4 : 0 ]	pipereg5_q;
wire	[ 4 : 0 ]	pipereg11_q;
wire	[ 15 : 0 ]	pipereg1_q;
wire	[ 4 : 0 ]	pipereg4_q;
wire	[ 4 : 0 ]	pipereg_q;
wire	[ 25 : 0 ]	pipereg2_q;
wire	[ 31 : 0 ]	pipereg6_q;
wire	[ 31 : 0 ]	pipereg3_q;
wire	[ 25 : 0 ]	pipereg7_q;
wire	[ 4 : 0 ]	pipereg8_q;
wire	[ 31 : 0 ]	const21_out;
wire	[ 31 : 0 ]	pipereg9_q;
wire	[ 31 : 0 ]	pipereg17_q;
wire	[ 4 : 0 ]	pipereg18_q;
wire	[ 31 : 0 ]	pipereg19_q;
wire	[ 31 : 0 ]	pipereg16_q;
wire	[ 31 : 0 ]	pipereg15_q;
wire	pipereg14_q;
wire	[ 31 : 0 ]	pipereg13_q;
wire	[ 31 : 0 ]	pipereg22_q;
wire	[ 4 : 0 ]	pipereg12_q;
wire	[ 31 : 0 ]	pipereg23_q;
wire	[ 4 : 0 ]	pipereg25_q;
wire	[ 4 : 0 ]	pipereg26_q;
wire	[ 4 : 0 ]	pipereg27_q;
wire	[ 31 : 0 ]	fakedelay_q;
wire	[ 4 : 0 ]	zeroer0_q;
wire	[ 4 : 0 ]	zeroer10_q;
wire	[ 4 : 0 ]	zeroer_q;
wire	[ 31 : 0 ]	pipereg24_q;
wire	[ 31 : 0 ]	mux2to1_mul_opA_out;
wire	[ 31 : 0 ]	mux2to1_pipereg6_d_out;
wire	[ 31 : 0 ]	mux2to1_addersub_opA_out;
wire	[ 31 : 0 ]	mux4to1_reg_file_c_writedatain_out;
wire	[ 4 : 0 ]	mux3to1_pipereg18_d_out;
wire	[ 31 : 0 ]	mux3to1_pipereg16_d_out;
wire	mux6to1_pipereg14_d_out;
wire	[ 31 : 0 ]	mux2to1_pipereg24_d_out;
wire	[ 31 : 0 ]	mux3to1_pipereg13_d_out;
wire	[ 4 : 0 ]	mux3to1_zeroer10_d_out;
wire	[ 31 : 0 ]	mux3to1_pipereg22_d_out;
wire	[ 5 : 0 ]	pipereg28_q;
wire	[ 5 : 0 ]	pipereg31_q;
wire	[ 5 : 0 ]	pipereg32_q;
wire	[ 5 : 0 ]	pipereg34_q;
wire	[ 4 : 0 ]	pipereg33_q;
wire	[ 4 : 0 ]	pipereg36_q;
wire	[ 5 : 0 ]	pipereg35_q;
wire	[ 4 : 0 ]	pipereg30_q;
wire	[ 5 : 0 ]	pipereg29_q;
wire	[ 5 : 0 ]	pipereg38_q;
wire	[ 4 : 0 ]	pipereg39_q;
wire	[ 5 : 0 ]	pipereg40_q;
wire	[ 5 : 0 ]	pipereg41_q;
wire	[ 4 : 0 ]	pipereg42_q;
wire	[ 5 : 0 ]	pipereg37_q;
wire	branch_detector_is_branch;
wire	pipereg43_q;
wire	pipereg44_q;
/***************** Control Signals ***************/
		//Decoded Opcode signal declarations
reg	[ 2 : 0 ]	ctrl_mux6to1_pipereg14_d_sel;
reg	[ 1 : 0 ]	ctrl_mux4to1_reg_file_c_writedatain_sel;
reg	ctrl_mux2to1_addersub_opA_sel;
reg	ctrl_mux2to1_pipereg24_d_sel;
reg	[ 1 : 0 ]	ctrl_mux3to1_pipereg22_d_sel;
reg	[ 1 : 0 ]	ctrl_mux3to1_pipereg18_d_sel;
reg	[ 1 : 0 ]	ctrl_mux3to1_pipereg16_d_sel;
reg	ctrl_mux2to1_mul_opA_sel;
reg	[ 1 : 0 ]	ctrl_mux3to1_pipereg13_d_sel;
reg	[ 1 : 0 ]	ctrl_mux3to1_zeroer10_d_sel;
reg	ctrl_mux2to1_pipereg6_d_sel;
reg	ctrl_zeroer10_en;
reg	ctrl_zeroer_en;
reg	ctrl_zeroer0_en;
reg	[ 2 : 0 ]	ctrl_addersub_op;
reg	ctrl_ifetch_op;
reg	[ 3 : 0 ]	ctrl_data_mem_op;
reg	[ 2 : 0 ]	ctrl_mul_op;
reg	[ 1 : 0 ]	ctrl_logic_unit_op;
		//Enable signal declarations
reg	ctrl_lo_reg_en;
reg	ctrl_hi_reg_en;
reg	ctrl_branchresolve_en;
reg	ctrl_reg_file_c_we;
reg	ctrl_reg_file_b_en;
reg	ctrl_reg_file_a_en;
reg	ctrl_ifetch_we;
reg	ctrl_data_mem_en;
reg	ctrl_ifetch_en;
		//Other Signals
wire	squash_stage6;
wire	stall_out_stage6;
wire	squash_stage5;
wire	stall_out_stage5;
wire	ctrl_pipereg24_squashn;
wire	ctrl_pipereg27_squashn;
wire	ctrl_pipereg23_squashn;
wire	ctrl_pipereg40_squashn;
wire	ctrl_pipereg41_squashn;
wire	ctrl_pipereg42_squashn;
wire	ctrl_pipereg24_resetn;
wire	ctrl_pipereg27_resetn;
wire	ctrl_pipereg23_resetn;
wire	ctrl_pipereg40_resetn;
wire	ctrl_pipereg41_resetn;
wire	ctrl_pipereg42_resetn;
wire	ctrl_pipereg24_en;
wire	ctrl_pipereg27_en;
wire	ctrl_pipereg23_en;
wire	ctrl_pipereg40_en;
wire	ctrl_pipereg41_en;
wire	ctrl_pipereg42_en;
wire	squash_stage4;
wire	stall_out_stage4;
wire	ctrl_pipereg22_squashn;
wire	ctrl_pipereg26_squashn;
wire	ctrl_pipereg37_squashn;
wire	ctrl_pipereg38_squashn;
wire	ctrl_pipereg39_squashn;
wire	ctrl_pipereg22_resetn;
wire	ctrl_pipereg26_resetn;
wire	ctrl_pipereg37_resetn;
wire	ctrl_pipereg38_resetn;
wire	ctrl_pipereg39_resetn;
wire	ctrl_pipereg22_en;
wire	ctrl_pipereg26_en;
wire	ctrl_pipereg37_en;
wire	ctrl_pipereg38_en;
wire	ctrl_pipereg39_en;
wire	squash_stage3;
wire	stall_out_stage3;
wire	ctrl_pipereg16_squashn;
wire	ctrl_pipereg25_squashn;
wire	ctrl_pipereg17_squashn;
wire	ctrl_pipereg18_squashn;
wire	ctrl_pipereg19_squashn;
wire	ctrl_pipereg13_squashn;
wire	ctrl_pipereg15_squashn;
wire	ctrl_pipereg14_squashn;
wire	ctrl_pipereg34_squashn;
wire	ctrl_pipereg35_squashn;
wire	ctrl_pipereg36_squashn;
wire	ctrl_pipereg16_resetn;
wire	ctrl_pipereg25_resetn;
wire	ctrl_pipereg17_resetn;
wire	ctrl_pipereg18_resetn;
wire	ctrl_pipereg19_resetn;
wire	ctrl_pipereg13_resetn;
wire	ctrl_pipereg15_resetn;
wire	ctrl_pipereg14_resetn;
wire	ctrl_pipereg34_resetn;
wire	ctrl_pipereg35_resetn;
wire	ctrl_pipereg36_resetn;
wire	ctrl_pipereg16_en;
wire	ctrl_pipereg25_en;
wire	ctrl_pipereg17_en;
wire	ctrl_pipereg18_en;
wire	ctrl_pipereg19_en;
wire	ctrl_pipereg13_en;
wire	ctrl_pipereg15_en;
wire	ctrl_pipereg14_en;
wire	ctrl_pipereg34_en;
wire	ctrl_pipereg35_en;
wire	ctrl_pipereg36_en;
wire	squash_stage2;
wire	stall_out_stage2;
wire	ctrl_pipereg6_squashn;
wire	ctrl_pipereg12_squashn;
wire	ctrl_pipereg8_squashn;
wire	ctrl_pipereg9_squashn;
wire	ctrl_pipereg7_squashn;
wire	ctrl_pipereg31_squashn;
wire	ctrl_pipereg32_squashn;
wire	ctrl_pipereg33_squashn;
wire	ctrl_pipereg6_resetn;
wire	ctrl_pipereg12_resetn;
wire	ctrl_pipereg8_resetn;
wire	ctrl_pipereg9_resetn;
wire	ctrl_pipereg7_resetn;
wire	ctrl_pipereg31_resetn;
wire	ctrl_pipereg32_resetn;
wire	ctrl_pipereg33_resetn;
wire	ctrl_pipereg6_en;
wire	ctrl_pipereg12_en;
wire	ctrl_pipereg8_en;
wire	ctrl_pipereg9_en;
wire	ctrl_pipereg7_en;
wire	ctrl_pipereg31_en;
wire	ctrl_pipereg32_en;
wire	ctrl_pipereg33_en;
wire	squash_stage1;
wire	stall_out_stage1;
wire	ctrl_pipereg44_squashn;
wire	ctrl_pipereg1_squashn;
wire	ctrl_pipereg11_squashn;
wire	ctrl_pipereg4_squashn;
wire	ctrl_pipereg5_squashn;
wire	ctrl_pipereg_squashn;
wire	ctrl_pipereg3_squashn;
wire	ctrl_pipereg2_squashn;
wire	ctrl_pipereg28_squashn;
wire	ctrl_pipereg29_squashn;
wire	ctrl_pipereg30_squashn;
wire	ctrl_pipereg44_resetn;
wire	ctrl_pipereg1_resetn;
wire	ctrl_pipereg11_resetn;
wire	ctrl_pipereg4_resetn;
wire	ctrl_pipereg5_resetn;
wire	ctrl_pipereg_resetn;
wire	ctrl_pipereg3_resetn;
wire	ctrl_pipereg2_resetn;
wire	ctrl_pipereg28_resetn;
wire	ctrl_pipereg29_resetn;
wire	ctrl_pipereg30_resetn;
wire	ctrl_pipereg44_en;
wire	ctrl_pipereg1_en;
wire	ctrl_pipereg11_en;
wire	ctrl_pipereg4_en;
wire	ctrl_pipereg5_en;
wire	ctrl_pipereg_en;
wire	ctrl_pipereg3_en;
wire	ctrl_pipereg2_en;
wire	ctrl_pipereg28_en;
wire	ctrl_pipereg29_en;
wire	ctrl_pipereg30_en;


/****************************** Control **************************/
		//Decode Logic for Opcode and Multiplex Select signals
always@(ifetch_opcode or ifetch_func or ifetch_rt)
begin
		// Initialize control opcodes to zero
	ctrl_mux3to1_zeroer10_d_sel = 0;
	ctrl_zeroer10_en = 0;
	ctrl_zeroer_en = 0;
	ctrl_zeroer0_en = 0;
	
	casex (ifetch_opcode)
		OP_ADDI:
		begin
			ctrl_mux3to1_zeroer10_d_sel = 2;
			ctrl_zeroer10_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_ADDIU:
		begin
			ctrl_mux3to1_zeroer10_d_sel = 2;
			ctrl_zeroer10_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_ANDI:
		begin
			ctrl_mux3to1_zeroer10_d_sel = 2;
			ctrl_zeroer10_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_BEQ:
		begin
			ctrl_zeroer_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_BGTZ:
			ctrl_zeroer0_en = 1;
		OP_BLEZ:
			ctrl_zeroer0_en = 1;
		OP_BNE:
		begin
			ctrl_zeroer_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_JAL:
		begin
			ctrl_mux3to1_zeroer10_d_sel = 0;
			ctrl_zeroer10_en = 1;
		end
		OP_LB:
		begin
			ctrl_mux3to1_zeroer10_d_sel = 2;
			ctrl_zeroer10_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_LBU:
		begin
			ctrl_mux3to1_zeroer10_d_sel = 2;
			ctrl_zeroer10_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_LH:
		begin
			ctrl_mux3to1_zeroer10_d_sel = 2;
			ctrl_zeroer10_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_LHU:
		begin
			ctrl_mux3to1_zeroer10_d_sel = 2;
			ctrl_zeroer10_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_LUI:
		begin
			ctrl_mux3to1_zeroer10_d_sel = 2;
			ctrl_zeroer10_en = 1;
		end
		OP_LW:
		begin
			ctrl_mux3to1_zeroer10_d_sel = 2;
			ctrl_zeroer10_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_ORI:
		begin
			ctrl_mux3to1_zeroer10_d_sel = 2;
			ctrl_zeroer10_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_REGIMM:
		casex (ifetch_rt[0])
			FUNC_BGEZ:
				ctrl_zeroer0_en = 1;
			FUNC_BLTZ:
				ctrl_zeroer0_en = 1;
		endcase
		OP_SB:
		begin
			ctrl_zeroer_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_SH:
		begin
			ctrl_zeroer_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_SLTI:
		begin
			ctrl_mux3to1_zeroer10_d_sel = 2;
			ctrl_zeroer10_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_SLTIU:
		begin
			ctrl_mux3to1_zeroer10_d_sel = 2;
			ctrl_zeroer10_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_SPECIAL:
		casex (ifetch_func)
			FUNC_ADD:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
				ctrl_zeroer0_en = 1;
			end
			FUNC_ADDU:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
				ctrl_zeroer0_en = 1;
			end
			FUNC_AND:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
				ctrl_zeroer0_en = 1;
			end
			FUNC_JALR:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer0_en = 1;
			end
			FUNC_JR:
				ctrl_zeroer0_en = 1;
			FUNC_MFHI:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
			end
			FUNC_MFLO:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
			end
			FUNC_MULT:
			begin
				ctrl_zeroer_en = 1;
				ctrl_zeroer0_en = 1;
			end
			FUNC_MULTU:
			begin
				ctrl_zeroer_en = 1;
				ctrl_zeroer0_en = 1;
			end
			FUNC_NOR:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
				ctrl_zeroer0_en = 1;
			end
			FUNC_OR:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
				ctrl_zeroer0_en = 1;
			end
			FUNC_SLL:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
			end
			FUNC_SLLV:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
				ctrl_zeroer0_en = 1;
			end
			FUNC_SLT:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
				ctrl_zeroer0_en = 1;
			end
			FUNC_SLTU:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
				ctrl_zeroer0_en = 1;
			end
			FUNC_SRA:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
			end
			FUNC_SRAV:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
				ctrl_zeroer0_en = 1;
			end
			FUNC_SRL:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
			end
			FUNC_SRLV:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
				ctrl_zeroer0_en = 1;
			end
			FUNC_SUB:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
				ctrl_zeroer0_en = 1;
			end
			FUNC_SUBU:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
				ctrl_zeroer0_en = 1;
			end
			FUNC_XOR:
			begin
				ctrl_mux3to1_zeroer10_d_sel = 1;
				ctrl_zeroer10_en = 1;
				ctrl_zeroer_en = 1;
				ctrl_zeroer0_en = 1;
			end
		endcase
		OP_SW:
		begin
			ctrl_zeroer_en = 1;
			ctrl_zeroer0_en = 1;
		end
		OP_XORI:
		begin
			ctrl_mux3to1_zeroer10_d_sel = 2;
			ctrl_zeroer10_en = 1;
			ctrl_zeroer0_en = 1;
		end
	endcase
end
		//Logic for enable signals in Pipe Stage 1
always@(ifetch_opcode or ifetch_func or ifetch_rt[0] or stall_out_stage2 or stall_2nd_delayslot)
begin
	ctrl_ifetch_en = 1 &~stall_2nd_delayslot&~stall_out_stage2;
end
		//Decode Logic for Opcode and Multiplex Select signals
always@(pipereg28_q or pipereg29_q or pipereg30_q)
begin
		// Initialize control opcodes to zero
	ctrl_mux2to1_pipereg6_d_sel = 0;
	
	casex (pipereg28_q)
		OP_ADDI:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_ADDIU:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_ANDI:
			ctrl_mux2to1_pipereg6_d_sel = 1;
		OP_BEQ:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_BGTZ:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_BLEZ:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_BNE:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_LB:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_LBU:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_LH:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_LHU:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_LUI:
			ctrl_mux2to1_pipereg6_d_sel = 1;
		OP_LW:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_ORI:
			ctrl_mux2to1_pipereg6_d_sel = 1;
		OP_REGIMM:
		casex (pipereg30_q[0])
			FUNC_BGEZ:
				ctrl_mux2to1_pipereg6_d_sel = 0;
			FUNC_BLTZ:
				ctrl_mux2to1_pipereg6_d_sel = 0;
		endcase
		OP_SB:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_SH:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_SLTI:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_SLTIU:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_SW:
			ctrl_mux2to1_pipereg6_d_sel = 0;
		OP_XORI:
			ctrl_mux2to1_pipereg6_d_sel = 1;
	endcase
end
		//Logic for enable signals in Pipe Stage 2
always@(pipereg28_q or pipereg29_q or pipereg30_q[0] or stall_out_stage3 or haz_pipereg5_q_pipereg12_q or haz_pipereg4_q_pipereg25_q or haz_pipereg5_q_pipereg25_q or haz_pipereg4_q_pipereg12_q or haz_pipereg4_q_pipereg26_q or haz_pipereg5_q_pipereg26_q or haz_pipereg4_q_pipereg27_q or haz_pipereg5_q_pipereg27_q)
begin
	ctrl_reg_file_b_en = 1 &~haz_pipereg5_q_pipereg27_q&~haz_pipereg4_q_pipereg27_q&~haz_pipereg5_q_pipereg26_q&~haz_pipereg4_q_pipereg26_q&~haz_pipereg4_q_pipereg12_q&~haz_pipereg5_q_pipereg25_q&~haz_pipereg4_q_pipereg25_q&~haz_pipereg5_q_pipereg12_q&~stall_out_stage3;
	ctrl_reg_file_a_en = 1 &~haz_pipereg5_q_pipereg27_q&~haz_pipereg4_q_pipereg27_q&~haz_pipereg5_q_pipereg26_q&~haz_pipereg4_q_pipereg26_q&~haz_pipereg4_q_pipereg12_q&~haz_pipereg5_q_pipereg25_q&~haz_pipereg4_q_pipereg25_q&~haz_pipereg5_q_pipereg12_q&~stall_out_stage3;
end
		//Decode Logic for Opcode and Multiplex Select signals
always@(pipereg31_q or pipereg32_q or pipereg33_q)
begin
		// Initialize control opcodes to zero
	ctrl_mux6to1_pipereg14_d_sel = 0;
	ctrl_mux3to1_pipereg18_d_sel = 0;
	ctrl_mux3to1_pipereg16_d_sel = 0;
	ctrl_mux3to1_pipereg13_d_sel = 0;
	
	casex (pipereg31_q)
		OP_ADDI:
			ctrl_mux3to1_pipereg16_d_sel = 2;
		OP_ADDIU:
			ctrl_mux3to1_pipereg16_d_sel = 2;
		OP_ANDI:
			ctrl_mux3to1_pipereg16_d_sel = 2;
		OP_BEQ:
		begin
			ctrl_mux6to1_pipereg14_d_sel = 5;
			ctrl_mux3to1_pipereg13_d_sel = 2;
		end
		OP_BGTZ:
		begin
			ctrl_mux6to1_pipereg14_d_sel = 0;
			ctrl_mux3to1_pipereg13_d_sel = 2;
		end
		OP_BLEZ:
		begin
			ctrl_mux6to1_pipereg14_d_sel = 3;
			ctrl_mux3to1_pipereg13_d_sel = 2;
		end
		OP_BNE:
		begin
			ctrl_mux6to1_pipereg14_d_sel = 4;
			ctrl_mux3to1_pipereg13_d_sel = 2;
		end
		OP_J:
			ctrl_mux3to1_pipereg13_d_sel = 1;
		OP_JAL:
			ctrl_mux3to1_pipereg13_d_sel = 1;
		OP_LB:
			ctrl_mux3to1_pipereg16_d_sel = 2;
		OP_LBU:
			ctrl_mux3to1_pipereg16_d_sel = 2;
		OP_LH:
			ctrl_mux3to1_pipereg16_d_sel = 2;
		OP_LHU:
			ctrl_mux3to1_pipereg16_d_sel = 2;
		OP_LUI:
		begin
			ctrl_mux3to1_pipereg18_d_sel = 1;
			ctrl_mux3to1_pipereg16_d_sel = 2;
		end
		OP_LW:
			ctrl_mux3to1_pipereg16_d_sel = 2;
		OP_ORI:
			ctrl_mux3to1_pipereg16_d_sel = 2;
		OP_REGIMM:
		casex (pipereg33_q[0])
			FUNC_BGEZ:
			begin
				ctrl_mux6to1_pipereg14_d_sel = 1;
				ctrl_mux3to1_pipereg13_d_sel = 2;
			end
			FUNC_BLTZ:
			begin
				ctrl_mux6to1_pipereg14_d_sel = 2;
				ctrl_mux3to1_pipereg13_d_sel = 2;
			end
		endcase
		OP_SB:
			ctrl_mux3to1_pipereg16_d_sel = 2;
		OP_SH:
			ctrl_mux3to1_pipereg16_d_sel = 2;
		OP_SLTI:
			ctrl_mux3to1_pipereg16_d_sel = 2;
		OP_SLTIU:
			ctrl_mux3to1_pipereg16_d_sel = 2;
		OP_SPECIAL:
		casex (pipereg32_q)
			FUNC_ADD:
				ctrl_mux3to1_pipereg16_d_sel = 1;
			FUNC_ADDU:
				ctrl_mux3to1_pipereg16_d_sel = 1;
			FUNC_AND:
				ctrl_mux3to1_pipereg16_d_sel = 1;
			FUNC_JALR:
				ctrl_mux3to1_pipereg13_d_sel = 0;
			FUNC_JR:
				ctrl_mux3to1_pipereg13_d_sel = 0;
			FUNC_NOR:
				ctrl_mux3to1_pipereg16_d_sel = 1;
			FUNC_OR:
				ctrl_mux3to1_pipereg16_d_sel = 1;
			FUNC_SLL:
			begin
				ctrl_mux3to1_pipereg18_d_sel = 0;
				ctrl_mux3to1_pipereg16_d_sel = 1;
			end
			FUNC_SLLV:
			begin
				ctrl_mux3to1_pipereg18_d_sel = 2;
				ctrl_mux3to1_pipereg16_d_sel = 1;
			end
			FUNC_SLT:
				ctrl_mux3to1_pipereg16_d_sel = 1;
			FUNC_SLTU:
				ctrl_mux3to1_pipereg16_d_sel = 1;
			FUNC_SRA:
			begin
				ctrl_mux3to1_pipereg18_d_sel = 0;
				ctrl_mux3to1_pipereg16_d_sel = 1;
			end
			FUNC_SRAV:
			begin
				ctrl_mux3to1_pipereg18_d_sel = 2;
				ctrl_mux3to1_pipereg16_d_sel = 1;
			end
			FUNC_SRL:
			begin
				ctrl_mux3to1_pipereg18_d_sel = 0;
				ctrl_mux3to1_pipereg16_d_sel = 1;
			end
			FUNC_SRLV:
			begin
				ctrl_mux3to1_pipereg18_d_sel = 2;
				ctrl_mux3to1_pipereg16_d_sel = 1;
			end
			FUNC_SUB:
				ctrl_mux3to1_pipereg16_d_sel = 1;
			FUNC_SUBU:
				ctrl_mux3to1_pipereg16_d_sel = 1;
			FUNC_XOR:
				ctrl_mux3to1_pipereg16_d_sel = 1;
		endcase
		OP_SW:
			ctrl_mux3to1_pipereg16_d_sel = 2;
		OP_XORI:
			ctrl_mux3to1_pipereg16_d_sel = 2;
	endcase
end
		//Logic for enable signals in Pipe Stage 3
always@(pipereg31_q or pipereg32_q or pipereg33_q[0] or stall_out_stage4)
begin
	ctrl_branchresolve_en = 0;
	casex (pipereg31_q)
		OP_BEQ:
			ctrl_branchresolve_en = 1 &~stall_out_stage4;
		OP_BGTZ:
			ctrl_branchresolve_en = 1 &~stall_out_stage4;
		OP_BLEZ:
			ctrl_branchresolve_en = 1 &~stall_out_stage4;
		OP_BNE:
			ctrl_branchresolve_en = 1 &~stall_out_stage4;
		OP_REGIMM:
		casex (pipereg33_q[0])
			FUNC_BGEZ:
				ctrl_branchresolve_en = 1 &~stall_out_stage4;
			FUNC_BLTZ:
				ctrl_branchresolve_en = 1 &~stall_out_stage4;
		endcase
	endcase
end
		//Decode Logic for Opcode and Multiplex Select signals
always@(pipereg34_q or pipereg35_q or pipereg36_q)
begin
		// Initialize control opcodes to zero
	ctrl_mux2to1_addersub_opA_sel = 0;
	ctrl_mux3to1_pipereg22_d_sel = 0;
	ctrl_mux2to1_mul_opA_sel = 0;
	ctrl_addersub_op = 0;
	ctrl_ifetch_op = 0;
	ctrl_data_mem_op = 0;
	ctrl_mul_op = 0;
	ctrl_logic_unit_op = 0;
	
	casex (pipereg34_q)
		OP_ADDI:
		begin
			ctrl_mux2to1_addersub_opA_sel = 0;
			ctrl_mux3to1_pipereg22_d_sel = 2;
			ctrl_addersub_op = 3;
		end
		OP_ADDIU:
		begin
			ctrl_mux2to1_addersub_opA_sel = 0;
			ctrl_mux3to1_pipereg22_d_sel = 2;
			ctrl_addersub_op = 1;
		end
		OP_ANDI:
		begin
			ctrl_mux3to1_pipereg22_d_sel = 0;
			ctrl_logic_unit_op = 0;
		end
		OP_BEQ:
			ctrl_ifetch_op = 0;
		OP_BGTZ:
			ctrl_ifetch_op = 0;
		OP_BLEZ:
			ctrl_ifetch_op = 0;
		OP_BNE:
			ctrl_ifetch_op = 0;
		OP_J:
			ctrl_ifetch_op = 1;
		OP_JAL:
		begin
			ctrl_mux2to1_addersub_opA_sel = 1;
			ctrl_mux3to1_pipereg22_d_sel = 2;
			ctrl_addersub_op = 1;
			ctrl_ifetch_op = 1;
		end
		OP_LB:
		begin
			ctrl_mux2to1_addersub_opA_sel = 0;
			ctrl_addersub_op = 3;
			ctrl_data_mem_op = 7;
		end
		OP_LBU:
		begin
			ctrl_mux2to1_addersub_opA_sel = 0;
			ctrl_addersub_op = 3;
			ctrl_data_mem_op = 3;
		end
		OP_LH:
		begin
			ctrl_mux2to1_addersub_opA_sel = 0;
			ctrl_addersub_op = 3;
			ctrl_data_mem_op = 5;
		end
		OP_LHU:
		begin
			ctrl_mux2to1_addersub_opA_sel = 0;
			ctrl_addersub_op = 3;
			ctrl_data_mem_op = 1;
		end
		OP_LUI:
		begin
			ctrl_mux2to1_mul_opA_sel = 0;
			ctrl_mul_op = 0;
		end
		OP_LW:
		begin
			ctrl_mux2to1_addersub_opA_sel = 0;
			ctrl_addersub_op = 3;
			ctrl_data_mem_op = 0;
		end
		OP_ORI:
		begin
			ctrl_mux3to1_pipereg22_d_sel = 0;
			ctrl_logic_unit_op = 1;
		end
		OP_REGIMM:
		casex (pipereg36_q[0])
			FUNC_BGEZ:
				ctrl_ifetch_op = 0;
			FUNC_BLTZ:
				ctrl_ifetch_op = 0;
		endcase
		OP_SB:
		begin
			ctrl_mux2to1_addersub_opA_sel = 0;
			ctrl_addersub_op = 3;
			ctrl_data_mem_op = 11;
		end
		OP_SH:
		begin
			ctrl_mux2to1_addersub_opA_sel = 0;
			ctrl_addersub_op = 3;
			ctrl_data_mem_op = 9;
		end
		OP_SLTI:
		begin
			ctrl_mux2to1_addersub_opA_sel = 0;
			ctrl_mux3to1_pipereg22_d_sel = 1;
			ctrl_addersub_op = 6;
		end
		OP_SLTIU:
		begin
			ctrl_mux2to1_addersub_opA_sel = 0;
			ctrl_mux3to1_pipereg22_d_sel = 1;
			ctrl_addersub_op = 4;
		end
		OP_SPECIAL:
		casex (pipereg35_q)
			FUNC_ADD:
			begin
				ctrl_mux2to1_addersub_opA_sel = 0;
				ctrl_mux3to1_pipereg22_d_sel = 2;
				ctrl_addersub_op = 3;
			end
			FUNC_ADDU:
			begin
				ctrl_mux2to1_addersub_opA_sel = 0;
				ctrl_mux3to1_pipereg22_d_sel = 2;
				ctrl_addersub_op = 1;
			end
			FUNC_AND:
			begin
				ctrl_mux3to1_pipereg22_d_sel = 0;
				ctrl_logic_unit_op = 0;
			end
			FUNC_JALR:
			begin
				ctrl_mux2to1_addersub_opA_sel = 1;
				ctrl_mux3to1_pipereg22_d_sel = 2;
				ctrl_addersub_op = 1;
				ctrl_ifetch_op = 1;
			end
			FUNC_JR:
				ctrl_ifetch_op = 1;
			FUNC_MULT:
			begin
				ctrl_mux2to1_mul_opA_sel = 1;
				ctrl_mul_op = 6;
			end
			FUNC_MULTU:
			begin
				ctrl_mux2to1_mul_opA_sel = 1;
				ctrl_mul_op = 4;
			end
			FUNC_NOR:
			begin
				ctrl_mux3to1_pipereg22_d_sel = 0;
				ctrl_logic_unit_op = 3;
			end
			FUNC_OR:
			begin
				ctrl_mux3to1_pipereg22_d_sel = 0;
				ctrl_logic_unit_op = 1;
			end
			FUNC_SLL:
			begin
				ctrl_mux2to1_mul_opA_sel = 0;
				ctrl_mul_op = 0;
			end
			FUNC_SLLV:
			begin
				ctrl_mux2to1_mul_opA_sel = 0;
				ctrl_mul_op = 0;
			end
			FUNC_SLT:
			begin
				ctrl_mux2to1_addersub_opA_sel = 0;
				ctrl_mux3to1_pipereg22_d_sel = 1;
				ctrl_addersub_op = 6;
			end
			FUNC_SLTU:
			begin
				ctrl_mux2to1_addersub_opA_sel = 0;
				ctrl_mux3to1_pipereg22_d_sel = 1;
				ctrl_addersub_op = 4;
			end
			FUNC_SRA:
			begin
				ctrl_mux2to1_mul_opA_sel = 0;
				ctrl_mul_op = 3;
			end
			FUNC_SRAV:
			begin
				ctrl_mux2to1_mul_opA_sel = 0;
				ctrl_mul_op = 3;
			end
			FUNC_SRL:
			begin
				ctrl_mux2to1_mul_opA_sel = 0;
				ctrl_mul_op = 1;
			end
			FUNC_SRLV:
			begin
				ctrl_mux2to1_mul_opA_sel = 0;
				ctrl_mul_op = 1;
			end
			FUNC_SUB:
			begin
				ctrl_mux2to1_addersub_opA_sel = 0;
				ctrl_mux3to1_pipereg22_d_sel = 2;
				ctrl_addersub_op = 0;
			end
			FUNC_SUBU:
			begin
				ctrl_mux2to1_addersub_opA_sel = 0;
				ctrl_mux3to1_pipereg22_d_sel = 2;
				ctrl_addersub_op = 2;
			end
			FUNC_XOR:
			begin
				ctrl_mux3to1_pipereg22_d_sel = 0;
				ctrl_logic_unit_op = 2;
			end
		endcase
		OP_SW:
		begin
			ctrl_mux2to1_addersub_opA_sel = 0;
			ctrl_addersub_op = 3;
			ctrl_data_mem_op = 8;
		end
		OP_XORI:
		begin
			ctrl_mux3to1_pipereg22_d_sel = 0;
			ctrl_logic_unit_op = 2;
		end
	endcase
end
		//Logic for enable signals in Pipe Stage 4
always@(pipereg34_q or pipereg35_q or pipereg36_q[0] or stall_out_stage5)
begin
	ctrl_data_mem_en = 0;
	ctrl_ifetch_we = 0;
	casex (pipereg34_q)
		OP_BEQ:
			ctrl_ifetch_we = 1 &~stall_out_stage5;
		OP_BGTZ:
			ctrl_ifetch_we = 1 &~stall_out_stage5;
		OP_BLEZ:
			ctrl_ifetch_we = 1 &~stall_out_stage5;
		OP_BNE:
			ctrl_ifetch_we = 1 &~stall_out_stage5;
		OP_J:
			ctrl_ifetch_we = 1 &~stall_out_stage5;
		OP_JAL:
			ctrl_ifetch_we = 1 &~stall_out_stage5;
		OP_LB:
			ctrl_data_mem_en = 1 &~stall_out_stage5;
		OP_LBU:
			ctrl_data_mem_en = 1 &~stall_out_stage5;
		OP_LH:
			ctrl_data_mem_en = 1 &~stall_out_stage5;
		OP_LHU:
			ctrl_data_mem_en = 1 &~stall_out_stage5;
		OP_LW:
			ctrl_data_mem_en = 1 &~stall_out_stage5;
		OP_REGIMM:
		casex (pipereg36_q[0])
			FUNC_BGEZ:
				ctrl_ifetch_we = 1 &~stall_out_stage5;
			FUNC_BLTZ:
				ctrl_ifetch_we = 1 &~stall_out_stage5;
		endcase
		OP_SB:
			ctrl_data_mem_en = 1 &~stall_out_stage5;
		OP_SH:
			ctrl_data_mem_en = 1 &~stall_out_stage5;
		OP_SPECIAL:
		casex (pipereg35_q)
			FUNC_JALR:
				ctrl_ifetch_we = 1 &~stall_out_stage5;
			FUNC_JR:
				ctrl_ifetch_we = 1 &~stall_out_stage5;
		endcase
		OP_SW:
			ctrl_data_mem_en = 1 &~stall_out_stage5;
	endcase
end
		//Decode Logic for Opcode and Multiplex Select signals
always@(pipereg37_q or pipereg38_q or pipereg39_q)
begin
		// Initialize control opcodes to zero
	ctrl_mux2to1_pipereg24_d_sel = 0;
	
	casex (pipereg37_q)
		OP_ADDI:
			ctrl_mux2to1_pipereg24_d_sel = 1;
		OP_ADDIU:
			ctrl_mux2to1_pipereg24_d_sel = 1;
		OP_ANDI:
			ctrl_mux2to1_pipereg24_d_sel = 1;
		OP_JAL:
			ctrl_mux2to1_pipereg24_d_sel = 1;
		OP_LUI:
			ctrl_mux2to1_pipereg24_d_sel = 0;
		OP_ORI:
			ctrl_mux2to1_pipereg24_d_sel = 1;
		OP_SLTI:
			ctrl_mux2to1_pipereg24_d_sel = 1;
		OP_SLTIU:
			ctrl_mux2to1_pipereg24_d_sel = 1;
		OP_SPECIAL:
		casex (pipereg38_q)
			FUNC_ADD:
				ctrl_mux2to1_pipereg24_d_sel = 1;
			FUNC_ADDU:
				ctrl_mux2to1_pipereg24_d_sel = 1;
			FUNC_AND:
				ctrl_mux2to1_pipereg24_d_sel = 1;
			FUNC_JALR:
				ctrl_mux2to1_pipereg24_d_sel = 1;
			FUNC_NOR:
				ctrl_mux2to1_pipereg24_d_sel = 1;
			FUNC_OR:
				ctrl_mux2to1_pipereg24_d_sel = 1;
			FUNC_SLL:
				ctrl_mux2to1_pipereg24_d_sel = 0;
			FUNC_SLLV:
				ctrl_mux2to1_pipereg24_d_sel = 0;
			FUNC_SLT:
				ctrl_mux2to1_pipereg24_d_sel = 1;
			FUNC_SLTU:
				ctrl_mux2to1_pipereg24_d_sel = 1;
			FUNC_SRA:
				ctrl_mux2to1_pipereg24_d_sel = 0;
			FUNC_SRAV:
				ctrl_mux2to1_pipereg24_d_sel = 0;
			FUNC_SRL:
				ctrl_mux2to1_pipereg24_d_sel = 0;
			FUNC_SRLV:
				ctrl_mux2to1_pipereg24_d_sel = 0;
			FUNC_SUB:
				ctrl_mux2to1_pipereg24_d_sel = 1;
			FUNC_SUBU:
				ctrl_mux2to1_pipereg24_d_sel = 1;
			FUNC_XOR:
				ctrl_mux2to1_pipereg24_d_sel = 1;
		endcase
		OP_XORI:
			ctrl_mux2to1_pipereg24_d_sel = 1;
	endcase
end
		//Logic for enable signals in Pipe Stage 5
always@(pipereg37_q or pipereg38_q or pipereg39_q[0] or stall_out_stage6)
begin
	ctrl_lo_reg_en = 0;
	ctrl_hi_reg_en = 0;
	casex (pipereg37_q)
		OP_SPECIAL:
		casex (pipereg38_q)
			FUNC_MULT:
			begin
				ctrl_lo_reg_en = 1 &~stall_out_stage6;
				ctrl_hi_reg_en = 1 &~stall_out_stage6;
			end
			FUNC_MULTU:
			begin
				ctrl_lo_reg_en = 1 &~stall_out_stage6;
				ctrl_hi_reg_en = 1 &~stall_out_stage6;
			end
		endcase
	endcase
end
		//Decode Logic for Opcode and Multiplex Select signals
always@(pipereg40_q or pipereg41_q or pipereg42_q)
begin
		// Initialize control opcodes to zero
	ctrl_mux4to1_reg_file_c_writedatain_sel = 0;
	
	casex (pipereg40_q)
		OP_ADDI:
			ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
		OP_ADDIU:
			ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
		OP_ANDI:
			ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
		OP_JAL:
			ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
		OP_LB:
			ctrl_mux4to1_reg_file_c_writedatain_sel = 2;
		OP_LBU:
			ctrl_mux4to1_reg_file_c_writedatain_sel = 2;
		OP_LH:
			ctrl_mux4to1_reg_file_c_writedatain_sel = 2;
		OP_LHU:
			ctrl_mux4to1_reg_file_c_writedatain_sel = 2;
		OP_LUI:
			ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
		OP_LW:
			ctrl_mux4to1_reg_file_c_writedatain_sel = 2;
		OP_ORI:
			ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
		OP_SLTI:
			ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
		OP_SLTIU:
			ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
		OP_SPECIAL:
		casex (pipereg41_q)
			FUNC_ADD:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_ADDU:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_AND:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_JALR:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_MFHI:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 1;
			FUNC_MFLO:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 0;
			FUNC_NOR:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_OR:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_SLL:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_SLLV:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_SLT:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_SLTU:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_SRA:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_SRAV:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_SRL:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_SRLV:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_SUB:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_SUBU:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
			FUNC_XOR:
				ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
		endcase
		OP_XORI:
			ctrl_mux4to1_reg_file_c_writedatain_sel = 3;
	endcase
end
		//Logic for enable signals in Pipe Stage 6
always@(pipereg40_q or pipereg41_q or pipereg42_q[0]) //or 1'b0)
begin
	ctrl_reg_file_c_we = 0;
	casex (pipereg40_q)
		OP_ADDI:
			ctrl_reg_file_c_we = 1 &~1'b0;
		OP_ADDIU:
			ctrl_reg_file_c_we = 1 &~1'b0;
		OP_ANDI:
			ctrl_reg_file_c_we = 1 &~1'b0;
		OP_JAL:
			ctrl_reg_file_c_we = 1 &~1'b0;
		OP_LB:
			ctrl_reg_file_c_we = 1 &~1'b0;
		OP_LBU:
			ctrl_reg_file_c_we = 1 &~1'b0;
		OP_LH:
			ctrl_reg_file_c_we = 1 &~1'b0;
		OP_LHU:
			ctrl_reg_file_c_we = 1 &~1'b0;
		OP_LUI:
			ctrl_reg_file_c_we = 1 &~1'b0;
		OP_LW:
			ctrl_reg_file_c_we = 1 &~1'b0;
		OP_ORI:
			ctrl_reg_file_c_we = 1 &~1'b0;
		OP_SLTI:
			ctrl_reg_file_c_we = 1 &~1'b0;
		OP_SLTIU:
			ctrl_reg_file_c_we = 1 &~1'b0;
		OP_SPECIAL:
		casex (pipereg41_q)
			FUNC_ADD:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_ADDU:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_AND:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_JALR:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_MFHI:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_MFLO:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_NOR:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_OR:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_SLL:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_SLLV:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_SLT:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_SLTU:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_SRA:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_SRAV:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_SRL:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_SRLV:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_SUB:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_SUBU:
				ctrl_reg_file_c_we = 1 &~1'b0;
			FUNC_XOR:
				ctrl_reg_file_c_we = 1 &~1'b0;
		endcase
		OP_XORI:
			ctrl_reg_file_c_we = 1 &~1'b0;
	endcase
end

/********* Stall Network & PipeReg Control ********/
assign stall_out_stage1 = stall_out_stage2|stall_2nd_delayslot;
assign ctrl_pipereg30_en = ~stall_out_stage1;
assign ctrl_pipereg29_en = ~stall_out_stage1;
assign ctrl_pipereg28_en = ~stall_out_stage1;
assign ctrl_pipereg2_en = ~stall_out_stage1;
assign ctrl_pipereg3_en = ~stall_out_stage1;
assign ctrl_pipereg_en = ~stall_out_stage1;
assign ctrl_pipereg5_en = ~stall_out_stage1;
assign ctrl_pipereg4_en = ~stall_out_stage1;
assign ctrl_pipereg11_en = ~stall_out_stage1;
assign ctrl_pipereg1_en = ~stall_out_stage1;
assign ctrl_pipereg44_en = ~stall_out_stage1;
assign stall_out_stage2 = stall_out_stage3|haz_pipereg5_q_pipereg27_q|haz_pipereg4_q_pipereg27_q|haz_pipereg5_q_pipereg26_q|haz_pipereg4_q_pipereg26_q|haz_pipereg4_q_pipereg12_q|haz_pipereg5_q_pipereg25_q|haz_pipereg4_q_pipereg25_q|haz_pipereg5_q_pipereg12_q;
assign ctrl_pipereg33_en = ~stall_out_stage2;
assign ctrl_pipereg32_en = ~stall_out_stage2;
assign ctrl_pipereg31_en = ~stall_out_stage2;
assign ctrl_pipereg7_en = ~stall_out_stage2;
assign ctrl_pipereg9_en = ~stall_out_stage2;
assign ctrl_pipereg8_en = ~stall_out_stage2;
assign ctrl_pipereg12_en = ~stall_out_stage2;
assign ctrl_pipereg6_en = ~stall_out_stage2;
assign stall_out_stage3 = stall_out_stage4;
assign ctrl_pipereg36_en = ~stall_out_stage3;
assign ctrl_pipereg35_en = ~stall_out_stage3;
assign ctrl_pipereg34_en = ~stall_out_stage3;
assign ctrl_pipereg14_en = ~stall_out_stage3;
assign ctrl_pipereg15_en = ~stall_out_stage3;
assign ctrl_pipereg13_en = ~stall_out_stage3;
assign ctrl_pipereg19_en = ~stall_out_stage3;
assign ctrl_pipereg18_en = ~stall_out_stage3;
assign ctrl_pipereg17_en = ~stall_out_stage3;
assign ctrl_pipereg25_en = ~stall_out_stage3;
assign ctrl_pipereg16_en = ~stall_out_stage3;
assign stall_out_stage4 = stall_out_stage5;
assign ctrl_pipereg39_en = ~stall_out_stage4;
assign ctrl_pipereg38_en = ~stall_out_stage4;
assign ctrl_pipereg37_en = ~stall_out_stage4;
assign ctrl_pipereg26_en = ~stall_out_stage4;
assign ctrl_pipereg22_en = ~stall_out_stage4;
assign stall_out_stage5 = stall_out_stage6;
assign ctrl_pipereg42_en = ~stall_out_stage5;
assign ctrl_pipereg41_en = ~stall_out_stage5;
assign ctrl_pipereg40_en = ~stall_out_stage5;
assign ctrl_pipereg23_en = ~stall_out_stage5;
assign ctrl_pipereg27_en = ~stall_out_stage5;
assign ctrl_pipereg24_en = ~stall_out_stage5;
assign stall_out_stage6 = 1'b0;
assign branch_mispred = (((ctrl_ifetch_op==1) || (ctrl_ifetch_op==0 && pipereg14_q)) & ctrl_ifetch_we);
assign stall_2nd_delayslot = branch_detector_is_branch&has_delayslot;
assign has_delayslot = pipereg44_q|pipereg43_q;
assign squash_stage1 = ((stall_out_stage1&~stall_out_stage2))|~resetn;
assign ctrl_pipereg30_resetn = ~squash_stage1;
assign ctrl_pipereg29_resetn = ~squash_stage1;
assign ctrl_pipereg28_resetn = ~squash_stage1;
assign ctrl_pipereg2_resetn = ~squash_stage1;
assign ctrl_pipereg3_resetn = ~squash_stage1;
assign ctrl_pipereg_resetn = ~squash_stage1;
assign ctrl_pipereg5_resetn = ~squash_stage1;
assign ctrl_pipereg4_resetn = ~squash_stage1;
assign ctrl_pipereg11_resetn = ~squash_stage1;
assign ctrl_pipereg1_resetn = ~squash_stage1;
assign ctrl_pipereg44_resetn = ~squash_stage1;
assign ctrl_pipereg44_squashn = ~(branch_mispred&~(pipereg43_q&~stall_out_stage1 | pipereg44_q&stall_out_stage1));
assign ctrl_pipereg1_squashn = ~(branch_mispred&~(pipereg43_q&~stall_out_stage1 | pipereg44_q&stall_out_stage1));
assign ctrl_pipereg11_squashn = ~(branch_mispred&~(pipereg43_q&~stall_out_stage1 | pipereg44_q&stall_out_stage1));
assign ctrl_pipereg4_squashn = ~(branch_mispred&~(pipereg43_q&~stall_out_stage1 | pipereg44_q&stall_out_stage1));
assign ctrl_pipereg5_squashn = ~(branch_mispred&~(pipereg43_q&~stall_out_stage1 | pipereg44_q&stall_out_stage1));
assign ctrl_pipereg_squashn = ~(branch_mispred&~(pipereg43_q&~stall_out_stage1 | pipereg44_q&stall_out_stage1));
assign ctrl_pipereg3_squashn = ~(branch_mispred&~(pipereg43_q&~stall_out_stage1 | pipereg44_q&stall_out_stage1));
assign ctrl_pipereg2_squashn = ~(branch_mispred&~(pipereg43_q&~stall_out_stage1 | pipereg44_q&stall_out_stage1));
assign ctrl_pipereg28_squashn = ~(branch_mispred&~(pipereg43_q&~stall_out_stage1 | pipereg44_q&stall_out_stage1));
assign ctrl_pipereg29_squashn = ~(branch_mispred&~(pipereg43_q&~stall_out_stage1 | pipereg44_q&stall_out_stage1));
assign ctrl_pipereg30_squashn = ~(branch_mispred&~(pipereg43_q&~stall_out_stage1 | pipereg44_q&stall_out_stage1));
assign ctrl_ifetch_squashn = ~(branch_mispred&~(pipereg43_q));
assign squash_stage2 = ((stall_out_stage2&~stall_out_stage3))|~resetn;
assign ctrl_pipereg33_resetn = ~squash_stage2;
assign ctrl_pipereg32_resetn = ~squash_stage2;
assign ctrl_pipereg31_resetn = ~squash_stage2;
assign ctrl_pipereg7_resetn = ~squash_stage2;
assign ctrl_pipereg9_resetn = ~squash_stage2;
assign ctrl_pipereg8_resetn = ~squash_stage2;
assign ctrl_pipereg12_resetn = ~squash_stage2;
assign ctrl_pipereg6_resetn = ~squash_stage2;
assign ctrl_pipereg6_squashn = ~(branch_mispred&~(pipereg44_q&~stall_out_stage2 | 1&stall_out_stage2));
assign ctrl_pipereg12_squashn = ~(branch_mispred&~(pipereg44_q&~stall_out_stage2 | 1&stall_out_stage2));
assign ctrl_pipereg8_squashn = ~(branch_mispred&~(pipereg44_q&~stall_out_stage2 | 1&stall_out_stage2));
assign ctrl_pipereg9_squashn = ~(branch_mispred&~(pipereg44_q&~stall_out_stage2 | 1&stall_out_stage2));
assign ctrl_pipereg7_squashn = ~(branch_mispred&~(pipereg44_q&~stall_out_stage2 | 1&stall_out_stage2));
assign ctrl_pipereg31_squashn = ~(branch_mispred&~(pipereg44_q&~stall_out_stage2 | 1&stall_out_stage2));
assign ctrl_pipereg32_squashn = ~(branch_mispred&~(pipereg44_q&~stall_out_stage2 | 1&stall_out_stage2));
assign ctrl_pipereg33_squashn = ~(branch_mispred&~(pipereg44_q&~stall_out_stage2 | 1&stall_out_stage2));
assign squash_stage3 = ((stall_out_stage3&~stall_out_stage4))|~resetn;
assign ctrl_pipereg36_resetn = ~squash_stage3;
assign ctrl_pipereg35_resetn = ~squash_stage3;
assign ctrl_pipereg34_resetn = ~squash_stage3;
assign ctrl_pipereg14_resetn = ~squash_stage3;
assign ctrl_pipereg15_resetn = ~squash_stage3;
assign ctrl_pipereg13_resetn = ~squash_stage3;
assign ctrl_pipereg19_resetn = ~squash_stage3;
assign ctrl_pipereg18_resetn = ~squash_stage3;
assign ctrl_pipereg17_resetn = ~squash_stage3;
assign ctrl_pipereg25_resetn = ~squash_stage3;
assign ctrl_pipereg16_resetn = ~squash_stage3;
assign ctrl_pipereg16_squashn = ~(0);
assign ctrl_pipereg25_squashn = ~(0);
assign ctrl_pipereg17_squashn = ~(0);
assign ctrl_pipereg18_squashn = ~(0);
assign ctrl_pipereg19_squashn = ~(0);
assign ctrl_pipereg13_squashn = ~(0);
assign ctrl_pipereg15_squashn = ~(0);
assign ctrl_pipereg14_squashn = ~(0);
assign ctrl_pipereg34_squashn = ~(0);
assign ctrl_pipereg35_squashn = ~(0);
assign ctrl_pipereg36_squashn = ~(0);
assign squash_stage4 = ((stall_out_stage4&~stall_out_stage5))|~resetn;
assign ctrl_pipereg39_resetn = ~squash_stage4;
assign ctrl_pipereg38_resetn = ~squash_stage4;
assign ctrl_pipereg37_resetn = ~squash_stage4;
assign ctrl_pipereg26_resetn = ~squash_stage4;
assign ctrl_pipereg22_resetn = ~squash_stage4;
assign ctrl_pipereg22_squashn = ~(0);
assign ctrl_pipereg26_squashn = ~(0);
assign ctrl_pipereg37_squashn = ~(0);
assign ctrl_pipereg38_squashn = ~(0);
assign ctrl_pipereg39_squashn = ~(0);
assign squash_stage5 = ((stall_out_stage5&~stall_out_stage6))|~resetn;
assign ctrl_pipereg42_resetn = ~squash_stage5;
assign ctrl_pipereg41_resetn = ~squash_stage5;
assign ctrl_pipereg40_resetn = ~squash_stage5;
assign ctrl_pipereg23_resetn = ~squash_stage5;
assign ctrl_pipereg27_resetn = ~squash_stage5;
assign ctrl_pipereg24_resetn = ~squash_stage5;
assign ctrl_pipereg24_squashn = ~(0);
assign ctrl_pipereg27_squashn = ~(0);
assign ctrl_pipereg23_squashn = ~(0);
assign ctrl_pipereg40_squashn = ~(0);
assign ctrl_pipereg41_squashn = ~(0);
assign ctrl_pipereg42_squashn = ~(0);
assign squash_stage6 = ((stall_out_stage6&~1'b0))|~resetn;

/****************************** Datapath **************************/
/******************** Hazard Detection Logic ***********************/
assign haz_pipereg5_q_pipereg27_q = (pipereg5_q==pipereg27_q) && (|pipereg5_q);
assign haz_pipereg4_q_pipereg27_q = (pipereg4_q==pipereg27_q) && (|pipereg4_q);
assign haz_pipereg5_q_pipereg26_q = (pipereg5_q==pipereg26_q) && (|pipereg5_q);
assign haz_pipereg4_q_pipereg26_q = (pipereg4_q==pipereg26_q) && (|pipereg4_q);
assign haz_pipereg5_q_pipereg25_q = (pipereg5_q==pipereg25_q) && (|pipereg5_q);
assign haz_pipereg4_q_pipereg25_q = (pipereg4_q==pipereg25_q) && (|pipereg4_q);
assign haz_pipereg5_q_pipereg12_q = (pipereg5_q==pipereg12_q) && (|pipereg5_q);
assign haz_pipereg4_q_pipereg12_q = (pipereg4_q==pipereg12_q) && (|pipereg4_q);

/*************** DATAPATH COMPONENTS **************/
addersub addersub (
	.opB(pipereg16_q),
	.opA(mux2to1_addersub_opA_out),
	.op(ctrl_addersub_op),
	.result_slt(addersub_result_slt),
	.result(addersub_result));
	defparam
		addersub.WIDTH=32;

mul mul (
	.clk(clk),
	.resetn(resetn),
	.sa(pipereg18_q),
	.opB(pipereg19_q),
	.opA(mux2to1_mul_opA_out),
	.op(ctrl_mul_op),
	.shift_result(mul_shift_result),
	.lo(mul_lo),
	.hi(mul_hi));
	defparam
		mul.WIDTH=32;

ifetch ifetch (
	.clk(clk),
	.resetn(resetn),
	.boot_iaddr(boot_iaddr),
	.boot_idata(boot_idata),
	.boot_iwe(boot_iwe),
	.load(pipereg14_q),
	.load_data(pipereg13_q),
	.op(ctrl_ifetch_op),
	.we(ctrl_ifetch_we),
	.squashn(ctrl_ifetch_squashn),
	.en(ctrl_ifetch_en),
	.pc_out(ifetch_pc_out),
	.instr(ifetch_instr),
	.opcode(ifetch_opcode),
	.func(ifetch_func),
	.rs(ifetch_rs),
	.rt(ifetch_rt),
	.rd(ifetch_rd),
	.instr_index(ifetch_instr_index),
	.offset(ifetch_offset),
	.sa(ifetch_sa),
	.next_pc(ifetch_next_pc[31:2]));

data_mem data_mem (
	.clk(clk),
	.resetn(resetn),
	.boot_daddr(boot_daddr),
	.boot_ddata(boot_ddata),
	.boot_dwe(boot_dwe),
	.d_address(addersub_result),
	.d_writedata(pipereg19_q),
	.op(ctrl_data_mem_op),
	.en(ctrl_data_mem_en),
	.d_loadresult(data_mem_d_loadresult),
	.d_wr(d_wr),
	.d_byteena(d_byteena),
	.d_writedatamem(d_writedatamem),
	.d_readdatain(d_readdatain));

reg_file_spree reg_file (
	.clk(clk),
	.resetn(resetn),
	.c_writedatain(mux4to1_reg_file_c_writedatain_out),
	.c_reg(pipereg27_q),
	.b_reg(pipereg5_q),
	.a_reg(pipereg4_q),
	.c_we(ctrl_reg_file_c_we),
	.b_en(ctrl_reg_file_b_en),
	.a_en(ctrl_reg_file_a_en),
	.b_readdataout(reg_file_b_readdataout),
	.a_readdataout(reg_file_a_readdataout));

logic_unit logic_unit (
	.opB(pipereg16_q),
	.opA(pipereg17_q),
	.op(ctrl_logic_unit_op),
	.result(logic_unit_result));
	defparam
		logic_unit.WIDTH=32;

pcadder pcadder (
	.offset(pipereg6_q),
	.pc(pipereg9_q),
	.result(pcadder_result));

signext16 signext16 (
	.in(pipereg1_q),
	.out(signext16_out));

merge26lo merge26lo (
	.in2(pipereg7_q),
	.in1(pipereg9_q),
	.out(merge26lo_out));

branchresolve branchresolve (
	.rt(reg_file_b_readdataout),
	.rs(reg_file_a_readdataout),
	.en(ctrl_branchresolve_en),
	.eqz(branchresolve_eqz),
	.gez(branchresolve_gez),
	.gtz(branchresolve_gtz),
	.lez(branchresolve_lez),
	.ltz(branchresolve_ltz),
	.ne(branchresolve_ne),
	.eq(branchresolve_eq));
	defparam
		branchresolve.WIDTH=32;

hi_reg hi_reg (
	.clk(clk),
	.resetn(resetn),
	.d(mul_hi),
	.en(ctrl_hi_reg_en),
	.q(hi_reg_q));
	defparam
		hi_reg.WIDTH=32;

lo_reg lo_reg (
	.clk(clk),
	.resetn(resetn),
	.d(mul_lo),
	.en(ctrl_lo_reg_en),
	.q(lo_reg_q));
	defparam
		lo_reg.WIDTH=32;

const const20 (
	.out(const20_out));
	defparam
		const20.WIDTH=32,
		const20.VAL=0;

const const (
	.out(const_out));
	defparam
		const.WIDTH=32,
		const.VAL=31;

pipereg pipereg5 (
	.clk(clk),
	.resetn(ctrl_pipereg5_resetn),
	.d(zeroer_q),
	.squashn(ctrl_pipereg5_squashn),
	.en(ctrl_pipereg5_en),
	.q(pipereg5_q));
	defparam
		pipereg5.WIDTH=5;

pipereg pipereg11 (
	.clk(clk),
	.resetn(ctrl_pipereg11_resetn),
	.d(zeroer10_q),
	.squashn(ctrl_pipereg11_squashn),
	.en(ctrl_pipereg11_en),
	.q(pipereg11_q));
	defparam
		pipereg11.WIDTH=5;

pipereg pipereg1 (
	.clk(clk),
	.resetn(ctrl_pipereg1_resetn),
	.d(ifetch_offset),
	.squashn(ctrl_pipereg1_squashn),
	.en(ctrl_pipereg1_en),
	.q(pipereg1_q));
	defparam
		pipereg1.WIDTH=16;

pipereg pipereg4 (
	.clk(clk),
	.resetn(ctrl_pipereg4_resetn),
	.d(zeroer0_q),
	.squashn(ctrl_pipereg4_squashn),
	.en(ctrl_pipereg4_en),
	.q(pipereg4_q));
	defparam
		pipereg4.WIDTH=5;

pipereg pipereg (
	.clk(clk),
	.resetn(ctrl_pipereg_resetn),
	.d(ifetch_sa),
	.squashn(ctrl_pipereg_squashn),
	.en(ctrl_pipereg_en),
	.q(pipereg_q));
	defparam
		pipereg.WIDTH=5;

pipereg pipereg2 (
	.clk(clk),
	.resetn(ctrl_pipereg2_resetn),
	.d(ifetch_instr_index),
	.squashn(ctrl_pipereg2_squashn),
	.en(ctrl_pipereg2_en),
	.q(pipereg2_q));
	defparam
		pipereg2.WIDTH=26;

pipereg pipereg6 (
	.clk(clk),
	.resetn(ctrl_pipereg6_resetn),
	.d(mux2to1_pipereg6_d_out),
	.squashn(ctrl_pipereg6_squashn),
	.en(ctrl_pipereg6_en),
	.q(pipereg6_q));
	defparam
		pipereg6.WIDTH=32;

pipereg pipereg3 (
	.clk(clk),
	.resetn(ctrl_pipereg3_resetn),
	.d(ifetch_pc_out),
	.squashn(ctrl_pipereg3_squashn),
	.en(ctrl_pipereg3_en),
	.q(pipereg3_q));
	defparam
		pipereg3.WIDTH=32;

pipereg pipereg7 (
	.clk(clk),
	.resetn(ctrl_pipereg7_resetn),
	.d(pipereg2_q),
	.squashn(ctrl_pipereg7_squashn),
	.en(ctrl_pipereg7_en),
	.q(pipereg7_q));
	defparam
		pipereg7.WIDTH=26;

pipereg pipereg8 (
	.clk(clk),
	.resetn(ctrl_pipereg8_resetn),
	.d(pipereg_q),
	.squashn(ctrl_pipereg8_squashn),
	.en(ctrl_pipereg8_en),
	.q(pipereg8_q));
	defparam
		pipereg8.WIDTH=5;

const const21 (
	.out(const21_out));
	defparam
		const21.WIDTH=32,
		const21.VAL=16;

pipereg pipereg9 (
	.clk(clk),
	.resetn(ctrl_pipereg9_resetn),
	.d(pipereg3_q),
	.squashn(ctrl_pipereg9_squashn),
	.en(ctrl_pipereg9_en),
	.q(pipereg9_q));
	defparam
		pipereg9.WIDTH=32;

pipereg pipereg17 (
	.clk(clk),
	.resetn(ctrl_pipereg17_resetn),
	.d(reg_file_a_readdataout),
	.squashn(ctrl_pipereg17_squashn),
	.en(ctrl_pipereg17_en),
	.q(pipereg17_q));
	defparam
		pipereg17.WIDTH=32;

pipereg pipereg18 (
	.clk(clk),
	.resetn(ctrl_pipereg18_resetn),
	.d(mux3to1_pipereg18_d_out),
	.squashn(ctrl_pipereg18_squashn),
	.en(ctrl_pipereg18_en),
	.q(pipereg18_q));
	defparam
		pipereg18.WIDTH=5;

pipereg pipereg19 (
	.clk(clk),
	.resetn(ctrl_pipereg19_resetn),
	.d(reg_file_b_readdataout),
	.squashn(ctrl_pipereg19_squashn),
	.en(ctrl_pipereg19_en),
	.q(pipereg19_q));
	defparam
		pipereg19.WIDTH=32;

pipereg pipereg16 (
	.clk(clk),
	.resetn(ctrl_pipereg16_resetn),
	.d(mux3to1_pipereg16_d_out),
	.squashn(ctrl_pipereg16_squashn),
	.en(ctrl_pipereg16_en),
	.q(pipereg16_q));
	defparam
		pipereg16.WIDTH=32;

pipereg pipereg15 (
	.clk(clk),
	.resetn(ctrl_pipereg15_resetn),
	.d(fakedelay_q),
	.squashn(ctrl_pipereg15_squashn),
	.en(ctrl_pipereg15_en),
	.q(pipereg15_q));
	defparam
		pipereg15.WIDTH=32;

pipereg pipereg14 (
	.clk(clk),
	.resetn(ctrl_pipereg14_resetn),
	.d(mux6to1_pipereg14_d_out),
	.squashn(ctrl_pipereg14_squashn),
	.en(ctrl_pipereg14_en),
	.q(pipereg14_q));
	defparam
		pipereg14.WIDTH=1;

pipereg pipereg13 (
	.clk(clk),
	.resetn(ctrl_pipereg13_resetn),
	.d(mux3to1_pipereg13_d_out),
	.squashn(ctrl_pipereg13_squashn),
	.en(ctrl_pipereg13_en),
	.q(pipereg13_q));
	defparam
		pipereg13.WIDTH=32;

pipereg pipereg22 (
	.clk(clk),
	.resetn(ctrl_pipereg22_resetn),
	.d(mux3to1_pipereg22_d_out),
	.squashn(ctrl_pipereg22_squashn),
	.en(ctrl_pipereg22_en),
	.q(pipereg22_q));
	defparam
		pipereg22.WIDTH=32;

pipereg pipereg12 (
	.clk(clk),
	.resetn(ctrl_pipereg12_resetn),
	.d(pipereg11_q),
	.squashn(ctrl_pipereg12_squashn),
	.en(ctrl_pipereg12_en),
	.q(pipereg12_q));
	defparam
		pipereg12.WIDTH=5;

pipereg pipereg23 (
	.clk(clk),
	.resetn(ctrl_pipereg23_resetn),
	.d(data_mem_d_loadresult),
	.squashn(ctrl_pipereg23_squashn),
	.en(ctrl_pipereg23_en),
	.q(pipereg23_q));
	defparam
		pipereg23.WIDTH=32;

pipereg pipereg25 (
	.clk(clk),
	.resetn(ctrl_pipereg25_resetn),
	.d(pipereg12_q),
	.squashn(ctrl_pipereg25_squashn),
	.en(ctrl_pipereg25_en),
	.q(pipereg25_q));
	defparam
		pipereg25.WIDTH=5;

pipereg pipereg26 (
	.clk(clk),
	.resetn(ctrl_pipereg26_resetn),
	.d(pipereg25_q),
	.squashn(ctrl_pipereg26_squashn),
	.en(ctrl_pipereg26_en),
	.q(pipereg26_q));
	defparam
		pipereg26.WIDTH=5;

pipereg pipereg27 (
	.clk(clk),
	.resetn(ctrl_pipereg27_resetn),
	.d(pipereg26_q),
	.squashn(ctrl_pipereg27_squashn),
	.en(ctrl_pipereg27_en),
	.q(pipereg27_q));
	defparam
		pipereg27.WIDTH=5;

fakedelay fakedelay (
	.clk(clk),
	.d(pipereg3_q),
	.q(fakedelay_q));
	defparam
		fakedelay.WIDTH=32;

zeroer zeroer0 (
	.d(ifetch_rs),
	.en(ctrl_zeroer0_en),
	.q(zeroer0_q));
	defparam
		zeroer0.WIDTH=5;

zeroer zeroer10 (
	.d(mux3to1_zeroer10_d_out),
	.en(ctrl_zeroer10_en),
	.q(zeroer10_q));
	defparam
		zeroer10.WIDTH=5;

zeroer zeroer (
	.d(ifetch_rt),
	.en(ctrl_zeroer_en),
	.q(zeroer_q));
	defparam
		zeroer.WIDTH=5;

pipereg pipereg24 (
	.clk(clk),
	.resetn(ctrl_pipereg24_resetn),
	.d(mux2to1_pipereg24_d_out),
	.squashn(ctrl_pipereg24_squashn),
	.en(ctrl_pipereg24_en),
	.q(pipereg24_q));
	defparam
		pipereg24.WIDTH=32;

		// Multiplexor mux2to1_mul_opA instantiation
assign mux2to1_mul_opA_out = 
	(ctrl_mux2to1_mul_opA_sel==1) ? pipereg17_q :
	pipereg16_q;

		// Multiplexor mux2to1_pipereg6_d instantiation
assign mux2to1_pipereg6_d_out = 
	(ctrl_mux2to1_pipereg6_d_sel==1) ? pipereg1_q :
	signext16_out;

		// Multiplexor mux2to1_addersub_opA instantiation
assign mux2to1_addersub_opA_out = 
	(ctrl_mux2to1_addersub_opA_sel==1) ? pipereg15_q :
	pipereg17_q;

		// Multiplexor mux4to1_reg_file_c_writedatain instantiation
assign mux4to1_reg_file_c_writedatain_out = 
	(ctrl_mux4to1_reg_file_c_writedatain_sel==3) ? pipereg24_q :
	(ctrl_mux4to1_reg_file_c_writedatain_sel==2) ? pipereg23_q :
	(ctrl_mux4to1_reg_file_c_writedatain_sel==1) ? hi_reg_q :
	lo_reg_q;

		// Multiplexor mux3to1_pipereg18_d instantiation
assign mux3to1_pipereg18_d_out = 
	(ctrl_mux3to1_pipereg18_d_sel==2) ? reg_file_a_readdataout :
	(ctrl_mux3to1_pipereg18_d_sel==1) ? const21_out :
	pipereg8_q;

		// Multiplexor mux3to1_pipereg16_d instantiation
assign mux3to1_pipereg16_d_out = 
	(ctrl_mux3to1_pipereg16_d_sel==2) ? pipereg6_q :
	(ctrl_mux3to1_pipereg16_d_sel==1) ? reg_file_b_readdataout :
	const20_out;

		// Multiplexor mux6to1_pipereg14_d instantiation
assign mux6to1_pipereg14_d_out = 
	(ctrl_mux6to1_pipereg14_d_sel==5) ? branchresolve_eq :
	(ctrl_mux6to1_pipereg14_d_sel==4) ? branchresolve_ne :
	(ctrl_mux6to1_pipereg14_d_sel==3) ? branchresolve_lez :
	(ctrl_mux6to1_pipereg14_d_sel==2) ? branchresolve_ltz :
	(ctrl_mux6to1_pipereg14_d_sel==1) ? branchresolve_gez :
	branchresolve_gtz;

		// Multiplexor mux2to1_pipereg24_d instantiation
assign mux2to1_pipereg24_d_out = 
	(ctrl_mux2to1_pipereg24_d_sel==1) ? pipereg22_q :
	mul_shift_result;

		// Multiplexor mux3to1_pipereg13_d instantiation
assign mux3to1_pipereg13_d_out = 
	(ctrl_mux3to1_pipereg13_d_sel==2) ? pcadder_result :
	(ctrl_mux3to1_pipereg13_d_sel==1) ? merge26lo_out :
	reg_file_a_readdataout;

		// Multiplexor mux3to1_zeroer10_d instantiation
assign mux3to1_zeroer10_d_out = 
	(ctrl_mux3to1_zeroer10_d_sel==2) ? ifetch_rt :
	(ctrl_mux3to1_zeroer10_d_sel==1) ? ifetch_rd :
	const_out;

		// Multiplexor mux3to1_pipereg22_d instantiation
assign mux3to1_pipereg22_d_out = 
	(ctrl_mux3to1_pipereg22_d_sel==2) ? addersub_result :
	(ctrl_mux3to1_pipereg22_d_sel==1) ? addersub_result_slt :
	logic_unit_result;

pipereg pipereg28 (
	.clk(clk),
	.resetn(ctrl_pipereg28_resetn),
	.d(ifetch_opcode),
	.squashn(ctrl_pipereg28_squashn),
	.en(ctrl_pipereg28_en),
	.q(pipereg28_q));
	defparam
		pipereg28.WIDTH=6;

pipereg pipereg31 (
	.clk(clk),
	.resetn(ctrl_pipereg31_resetn),
	.d(pipereg28_q),
	.squashn(ctrl_pipereg31_squashn),
	.en(ctrl_pipereg31_en),
	.q(pipereg31_q));
	defparam
		pipereg31.WIDTH=6;

pipereg pipereg32 (
	.clk(clk),
	.resetn(ctrl_pipereg32_resetn),
	.d(pipereg29_q),
	.squashn(ctrl_pipereg32_squashn),
	.en(ctrl_pipereg32_en),
	.q(pipereg32_q));
	defparam
		pipereg32.WIDTH=6;

pipereg pipereg34 (
	.clk(clk),
	.resetn(ctrl_pipereg34_resetn),
	.d(pipereg31_q),
	.squashn(ctrl_pipereg34_squashn),
	.en(ctrl_pipereg34_en),
	.q(pipereg34_q));
	defparam
		pipereg34.WIDTH=6;

pipereg pipereg33 (
	.clk(clk),
	.resetn(ctrl_pipereg33_resetn),
	.d(pipereg30_q),
	.squashn(ctrl_pipereg33_squashn),
	.en(ctrl_pipereg33_en),
	.q(pipereg33_q));
	defparam
		pipereg33.WIDTH=5;

pipereg pipereg36 (
	.clk(clk),
	.resetn(ctrl_pipereg36_resetn),
	.d(pipereg33_q),
	.squashn(ctrl_pipereg36_squashn),
	.en(ctrl_pipereg36_en),
	.q(pipereg36_q));
	defparam
		pipereg36.WIDTH=5;

pipereg pipereg35 (
	.clk(clk),
	.resetn(ctrl_pipereg35_resetn),
	.d(pipereg32_q),
	.squashn(ctrl_pipereg35_squashn),
	.en(ctrl_pipereg35_en),
	.q(pipereg35_q));
	defparam
		pipereg35.WIDTH=6;

pipereg pipereg30 (
	.clk(clk),
	.resetn(ctrl_pipereg30_resetn),
	.d(ifetch_rt),
	.squashn(ctrl_pipereg30_squashn),
	.en(ctrl_pipereg30_en),
	.q(pipereg30_q));
	defparam
		pipereg30.WIDTH=5;

pipereg pipereg29 (
	.clk(clk),
	.resetn(ctrl_pipereg29_resetn),
	.d(ifetch_func),
	.squashn(ctrl_pipereg29_squashn),
	.en(ctrl_pipereg29_en),
	.q(pipereg29_q));
	defparam
		pipereg29.WIDTH=6;

pipereg pipereg38 (
	.clk(clk),
	.resetn(ctrl_pipereg38_resetn),
	.d(pipereg35_q),
	.squashn(ctrl_pipereg38_squashn),
	.en(ctrl_pipereg38_en),
	.q(pipereg38_q));
	defparam
		pipereg38.WIDTH=6;

pipereg pipereg39 (
	.clk(clk),
	.resetn(ctrl_pipereg39_resetn),
	.d(pipereg36_q),
	.squashn(ctrl_pipereg39_squashn),
	.en(ctrl_pipereg39_en),
	.q(pipereg39_q));
	defparam
		pipereg39.WIDTH=5;

pipereg pipereg40 (
	.clk(clk),
	.resetn(ctrl_pipereg40_resetn),
	.d(pipereg37_q),
	.squashn(ctrl_pipereg40_squashn),
	.en(ctrl_pipereg40_en),
	.q(pipereg40_q));
	defparam
		pipereg40.WIDTH=6;

pipereg pipereg41 (
	.clk(clk),
	.resetn(ctrl_pipereg41_resetn),
	.d(pipereg38_q),
	.squashn(ctrl_pipereg41_squashn),
	.en(ctrl_pipereg41_en),
	.q(pipereg41_q));
	defparam
		pipereg41.WIDTH=6;

pipereg pipereg42 (
	.clk(clk),
	.resetn(ctrl_pipereg42_resetn),
	.d(pipereg39_q),
	.squashn(ctrl_pipereg42_squashn),
	.en(ctrl_pipereg42_en),
	.q(pipereg42_q));
	defparam
		pipereg42.WIDTH=5;

pipereg pipereg37 (
	.clk(clk),
	.resetn(ctrl_pipereg37_resetn),
	.d(pipereg34_q),
	.squashn(ctrl_pipereg37_squashn),
	.en(ctrl_pipereg37_en),
	.q(pipereg37_q));
	defparam
		pipereg37.WIDTH=6;

branch_detector branch_detector (
	.func(ifetch_func),
	.opcode(ifetch_opcode),
	.is_branch(branch_detector_is_branch));

pipereg pipereg43 (
	.clk(clk),
	.resetn(resetn),
	.d(branch_detector_is_branch),
	.squashn(~branch_mispred),
	.en(~stall_out_stage1),
	.q(pipereg43_q));
	defparam
		pipereg43.WIDTH=1;

pipereg pipereg44 (
	.clk(clk),
	.resetn(ctrl_pipereg44_resetn),
	.d(pipereg43_q),
	.squashn(ctrl_pipereg44_squashn),
	.en(ctrl_pipereg44_en),
	.q(pipereg44_q));
	defparam
		pipereg44.WIDTH=1;



endmodule
