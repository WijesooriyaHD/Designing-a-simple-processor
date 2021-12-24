
`timescale  1ns/100ps
// Lab05 - AND module


// implement bitwise AND function using behavioural modeling
module AND_FUNC(DATA1,DATA2,RESULT);

	input [7:0] DATA1,DATA2;   // declare 8 bit input ports
	output  [7:0] RESULT;    // 8 bit output port decleration

	assign #1 RESULT =( DATA1 & DATA2); //do the biwise AND operation between DATA1 and DATA2 , assign it to output port RESULT after 1s time delay
 	
endmodule  //end of the module

