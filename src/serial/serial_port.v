/*
 * $File: serial_port.v
 * $Date: Sat Nov 23 22:45:23 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


// interrupt for serial port

module serial_port
	#(parameter CLK_FREQ = 50000000 )
	(input clk,
	input rst,
	output reg int_req,
	input int_ack,
	output reg [15:0] data_out,
	//output wire[7:0] light,

	// when write_busy == 0, assert for one cycle to enable write,
	input write_enable,
	//input fuck1,
	//output fuck2,
	output write_not_busy,
	output RxD_data_ready_out,
	// physical interface
	input RxD);

	// ------------------------------------------------------------------

	localparam BAUD = 115200;

	wire write_busy;
	reg [15:0] data2flash;
	reg shift;

	assign light = data_in;
	//assign fuck2=!fuck1;
	assign write_not_busy=!write_busy;
	assign RxD_data_ready_out = RxD_data_ready;

	wire RxD_data_ready;
	wire [7:0] RxD_data;
	uart_async_receiver #(.ClkFrequency(CLK_FREQ), .Baud(BAUD)) urecv
		(.clk(clk), .rst(rst), .RxD(RxD),
		.RxD_data_ready(RxD_data_ready), .RxD_waiting_data(),
		.RxD_data(RxD_data));

	always @(posedge clk or negedge rst)
		if (rst == 1'b0) begin
			int_req <= 0;
			shift <= 0;
			data2flash <= 16'h0000;
			data_out <= 16'h0000;
		end else if (int_ack) begin
			int_req <= 0;
		end else if (RxD_data_ready && !int_req) begin
			if(shift == 0) begin
			 shift <= 1;
			 data2flash[15:8] <= RxD_data;
			end else if(shift == 1) begin
			  shift <= 0;
			  //data2flash[7:0] <= RxD_data;
			  //data_out <= data2flash;
			  data_out <= {data2flash[15:8],RxD_data};
			  //int_req <= 1;
			end
		end

endmodule
