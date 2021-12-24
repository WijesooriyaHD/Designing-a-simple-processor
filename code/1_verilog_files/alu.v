`timescale  1ns/100ps
// Lab05 - Part1 - ALU




// implementing the alu module
module alu(DATA1,DATA2,RESULT,SELECT,ZERO);

	input [7:0] DATA1,DATA2; // declare 8 bit input ports
	input [2:0] SELECT;      // declare a 3 bit input port
	output reg [7:0] RESULT;  // 8 bit output port decleration, register type is used because we assign a value to this port later
	output ZERO;  // declare 1 bit output port


	wire  [7:0] result1,result2,result3,result4;  //declare  wires to connect the ouputs of the instances to the output port of the alu (RESULT) 
	
	// making instances from the all fuctional units
	
	FORWARD_FUNC forward1(DATA2,result1);  // instanciate FORWARD_FUNC , call it forward
	ADD_FUNC add1(DATA1,DATA2,result2);  // instanciate ADD_FUNC , call it add1
	AND_FUNC and1(DATA1,DATA2,result3);  // instanciate AND_FUNC , call it and1
	OR_FUNC or1(DATA1,DATA2,result4);  // instanciate OR_FUNC , call it or1

	// always block is executed when there is a change in the sensitivity list
	always @ (*) // sensityvity list contains DATA1 , DATA2  and SELECT
	begin // begining of the always block

		//implimenting a MUX using a case structure to pick one of the functional units' output and send it to RESULT based on the SELECT value

		case(SELECT)

			3'b000 : RESULT = result1; // if SELECT=3'b000 then RESULT = result1 , pick FORWARD fuction
			3'b001 : RESULT = result2; // if SELECT=3'b001 then RESULT = result2 , pick ADD fuction
			3'b010 : RESULT = result3; // if SELECT=3'b010 then RESULT = result3 , pick AND fuction
			3'b011 : RESULT = result4; // if SELECT=3'b011 then RESULT = result4 , pick OR fuction


		endcase  //end of the case structure

	end // end of the always block


	nor nor1(ZERO,RESULT[7],RESULT[6],RESULT[5],RESULT[4],RESULT[3],RESULT[2],RESULT[1],RESULT[0]); // instanciate an inbuild nor gate ,call it as nor1

	// ZERO=1 (output of the nor gate)  when RESULT=00000000


endmodule //end of the module
