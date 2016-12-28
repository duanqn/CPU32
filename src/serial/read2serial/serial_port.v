
// interrupt for serial port

module serial_port
	#(parameter CLK_FREQ = 50000000 )
	(input clk,
	input rst,
  input [15:0]data_in,

	// when write_busy == 0, assert for one cycle to enable write,
	input write_enable,
  output write_not_busy,
	// physical interface
  output TxD);

	// ------------------------------------------------------------------

	localparam BAUD = 115200;
	wire write_busy;
  assign write_not_busy = !write_busy;

  uart_async_transmitter #(.ClkFrequency(CLK_FREQ), .Baud(BAUD)) utrans
  (.clk(clk), .TxD_start(write_enable && !write_busy), .TxD_data(data_in),
  .TxD(TxD), .TxD_busy(write_busy));

endmodule
