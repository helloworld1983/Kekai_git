// master_0.v

// 

`timescale 1 ps / 1 ps
module master_0 (
		input  wire        clk_clk,              //          clk.clk
		input  wire        clk_reset_reset,      //    clk_reset.reset
		output wire [31:0] master_address,       //       master.address
		input  wire [31:0] master_readdata,      //             .readdata
		output wire        master_read,          //             .read
		output wire        master_write,         //             .write
		output wire [31:0] master_writedata,     //             .writedata
		input  wire        master_waitrequest,   //             .waitrequest
		input  wire        master_readdatavalid, //             .readdatavalid
		output wire [3:0]  master_byteenable,    //             .byteenable
		output wire        master_reset_reset    // master_reset.reset
	);

	master_0_master_0 #(
		.USE_PLI     (0),
		.PLI_PORT    (50000),
		.FIFO_DEPTHS (2)
	) master_0_inst (
		.clk_clk              (clk_clk),              //          clk.clk
		.clk_reset_reset      (clk_reset_reset),      //    clk_reset.reset
		.master_address       (master_address),       //       master.address
		.master_readdata      (master_readdata),      //             .readdata
		.master_read          (master_read),          //             .read
		.master_write         (master_write),         //             .write
		.master_writedata     (master_writedata),     //             .writedata
		.master_waitrequest   (master_waitrequest),   //             .waitrequest
		.master_readdatavalid (master_readdatavalid), //             .readdatavalid
		.master_byteenable    (master_byteenable),    //             .byteenable
		.master_reset_reset   (master_reset_reset)    // master_reset.reset
	);

endmodule
