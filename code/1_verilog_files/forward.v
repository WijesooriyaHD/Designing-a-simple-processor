`timescale  1ns/100ps
// Lab05 - FORWARD module


// implement FORWARD function using behavioural modeling
module FORWARD_FUNC(DATA2,RESULT);

	input [7:0] DATA2; // declare 8 bit input port
	output  [7:0] RESULT; // 8 bit output port decleration

	
	assign #1  RESULT=  DATA2;  // mov the value of DATA2 to the output port after 1s time delay
	

endmodule //end of the module
