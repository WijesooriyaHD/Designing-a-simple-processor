`timescale  1ns/100ps

// Lab05 - ADD module



// implement ADD function using behavioural modeling
module ADD_FUNC(DATA1,DATA2,RESULT);

	input [7:0] DATA1,DATA2; // declare 8 bit input ports
	output [7:0] RESULT; // 8 bit output port decleration

	assign #2 RESULT=  (DATA1+DATA2); // add the values of DATA1 and DATA2 ,assign it to output port RESULT after 2s time delay
	
endmodule //end of the module

