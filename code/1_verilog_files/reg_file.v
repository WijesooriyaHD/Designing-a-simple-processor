`timescale  1ns/100ps
// Lab 05 - register file module




//implementing the module reg_file
module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS, WRITE, CLK, RESET) ;



	input [7:0] IN; // decleration of an 8 bit input port
	output [7:0] OUT1,OUT2; // decleare 8 bit output ports
	input [2:0] INADDRESS,OUT1ADDRESS,OUT2ADDRESS; // decleare 3 bit input ports
	input WRITE,CLK,RESET; // decleare 1 bit input ports

	// creating an array of registers to store eight 8-bits values
	reg signed [7:0] register[7:0]; 

	integer count; // decleration of an integer variable 

	initial
	begin
	#5;
	$display("\n\t\t\t---------------------------------------------------------------\n");
	$display("\t\ttime\treg0\treg1\treg2\treg3\treg4\treg5\treg6\treg7\n");
	$display("\n\t\t\t---------------------------------------------------------------\n");
	$monitor($time, "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",register[0],register[1],register[2],register[3],register[4],register[5],register[6],register[7]);
	end

	always @ (posedge CLK) ///this always block runs at the positive edge of the clock
	begin // begining of the always block

		if(RESET==1)begin  // check whether if the RESET input is high or not

		//if RESET is high at a positive edge of the clock (CLK) the following code part will be executed

			#1; // 1 unit time delay ( writting delay)

			for(count=0;count<8;count++)begin   // loop through the register array

				register[count]<=0;  // clear the all 8 registers ( assign 00000000 to the all registers in the register file)
						     // writting is done synchronously
			end // end of the loop


		end 
		 

	end // end of the always block


	always @ (posedge CLK) ///this always block runs at the positive edge of the clock
	begin // begining of the always block

		 #0.1
		 if(WRITE==1 && RESET==0) begin // check whether if the input WRITE is high and the input RESET is low

		// if WRITE=1 and RESET=0 ,the following code part will be executed

			// 1 unit time delay (writting delay)
			#0.9 register[INADDRESS] =IN;  // put the input data IN , to the corresponding register according to the given INADDDRESS
					  // writting is done synchronously	
		end // end of the if statement	

		 

	end // end of the always block


	


	//reading the inputs from the corresponding registers according to the given inputs OUT1ADDRESS and OUT2ADDRESS
	assign #2 OUT1=register[OUT1ADDRESS];
	assign #2 OUT2=register[OUT2ADDRESS]; // reading the inputs asynchronously with 2 unit time delay (reading delay)


	
endmodule  // end of the reg_file module
