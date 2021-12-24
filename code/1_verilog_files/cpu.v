`timescale  1ns/100ps


// Lab 05 - Part 03








// implement a DECODER to generate signals from the given instructions
module DECODER(READREG1,READREG2,WRITEREG,ALUOP,IMMEDIATE,IMMEDIATE_OFFSET,SELECT1,SELECT2,JUMP,BEQ,INSTRUCTION,READ,WRITE,SELECT4,BUSYWAIT);

	output reg [2:0] READREG1,READREG2,WRITEREG,ALUOP;  // declare 3 bit output ports
	output reg [7:0] IMMEDIATE;  // declare an 8 bit output port
	output  reg signed [7:0] IMMEDIATE_OFFSET; // declare an 8 bit output port
	output reg SELECT1,SELECT2,JUMP,BEQ,READ,WRITE,SELECT4;  // declare 1 bit output ports

	input [31:0] INSTRUCTION;  // declare 32 bit input port
	input BUSYWAIT;

	reg  [7:0] opcode;    // declare reg type variable
	
	always @ (INSTRUCTION)  // always block ,executes when there is a change in INSTRUCTION  
	begin  //begining of the always block

		opcode = INSTRUCTION[31:24];  // extract the bits corresponding to the opcode from the instruction
		
	end   // end of the always block 


	always @ (*)   // always block ,executes when there is a change in the instruction
	begin	//begining of the always block

		if(opcode ==8'b00000000 || opcode ==8'b00000001 || opcode==8'b00000111) begin   //check the opcodes ---  add =0 , sub=1 ,beq=7

			ALUOP= #1 3'b001;    // ALUOP =001 if the instruction is add or sub or beq

		end else if (opcode==8'b00000010) begin   // check the opcode--- and=2

			ALUOP = #1 3'b010;  //  ALUOP =010 if it is an and instruction

	
		end else if (opcode==8'b00000011) begin  // check the opcode ---- or=3

			ALUOP=#1 3'b011;   // ALUOP =011 if it is an or instruction

		end else if (opcode==8'b00000100 || opcode==8'b00000101 || opcode==8'b00001000 || opcode==8'b00001001 || opcode==8'b00001010 || opcode==8'b00001011) begin  //check the opcodes ---  mov =4 , loadi=5 ,lwd=8,lwi=9,swd=10,swi=11

			ALUOP=#1 3'b000;     // ALUOP=0000  (forward )if it is a mov ,loadi ,lwd,lwi,swd,swi instructions

		end else if(opcode==8'b00000110) begin  // check opcodes --- jump=6

			ALUOP=#1 3'b100;   // ALUOP=100 , jump 
		end
	end    // end of the always block


	always @ (*)  // always block ,executes when there is a change in the instruction
	begin    //begining of the always block

		if(opcode==8'b00000101) begin  // check whether the given instruction is loadi or not

			WRITEREG=INSTRUCTION[18:16];  //assign bits in the instruction to the corresponding  output ports
			IMMEDIATE=INSTRUCTION[7:0];	

	
		end else if(opcode==8'b00000100)begin  // check whether the given instruction is mov or not

			WRITEREG=INSTRUCTION[18:16];   //assign bits in the instruction to the corresponding  output ports
			READREG2=INSTRUCTION[2:0];

		end else if(opcode==8'b00000111) begin   // check whether the given instruction is beq or not

			IMMEDIATE_OFFSET=INSTRUCTION[23:16]; // assign bits in the instruction to the corresponding  output ports
			READREG1=INSTRUCTION[10:8];
			READREG2=INSTRUCTION[2:0];
			
		end else if (opcode==8'b00000110) begin // check whether the instruction is jump or not

			IMMEDIATE_OFFSET=INSTRUCTION[23:16];
	
		end else if (opcode==8'b00001000) begin  // check whether the instruction is lwd or not

			READREG2=INSTRUCTION[2:0];
			WRITEREG=INSTRUCTION[18:16];
	
		end else if (opcode==8'b00001001) begin   // check whether the instruction is lwi or not

			IMMEDIATE=INSTRUCTION[7:0];
			WRITEREG=INSTRUCTION[18:16];

		end else if (opcode==8'b00001010) begin // check whether the instruction is swd or not

			READREG1=INSTRUCTION[10:8];
			READREG2=INSTRUCTION[2:0];

		end else if (opcode==8'b00001011) begin // check whether the instruction is swi or not

			READREG1=INSTRUCTION[10:8];
			IMMEDIATE=INSTRUCTION[7:0];
			
		end else begin  // if the instuction is an or ,and ,add or sub instruction the following code part will execute
	
			WRITEREG=INSTRUCTION[18:16];   
			READREG1=INSTRUCTION[10:8];      //assign bits in the instruction to the corresponding  output ports
			READREG2=INSTRUCTION[2:0];


		end

		if(opcode==8'b00000001 || opcode==8'b00000111) begin    // check whether the given instruction is SUB ,BEQ or not

			SELECT1=1;  // assign 1 to SELELCT1  ( for sub and beq instructions)
	
		end else begin

			SELECT1=0;  // assign 0 to SELECT1 (for add,and,or,mov,loadi  instructions)

		end

	
		if(opcode ==8'b00000101 || opcode==8'b00001001 || opcode==8'b00001011 )begin   // check whether the given instruction is loadi,lwi,swi or not

			SELECT2=0;   //assign 0 to SELECT2 (for loadi,lwi,swi instructions)

		end else begin

			SELECT2=1;    // assign 1 to SELECT2 (for add,and,or,mov,sub  instructions)
		
		end	


		if(opcode==8'b00000110) begin // check whether the instruction is jump or not

			JUMP=1;   // assign 1 to jump for jump instruction
		end else begin
			JUMP=0;
		end

		if(opcode==8'b00000111) begin // check whether the instruction is beq or not

			BEQ=1;   //  assign beq to 1 for beq instruction
		end else begin
			BEQ=0;
		end

		if(opcode==8'b00001000 || opcode==8'b00001001) begin // check whether the instruction is lwd or lwi

			READ=1;
		end else begin
		
			READ=0;
		end

		

		if(opcode==8'b00001010 || opcode==8'b00001011) begin //  check whether the instruction is swd or swi

			WRITE=1;
		end else begin

			WRITE=0;
		end


		if( opcode==8'b00001000 || opcode==8'b00001001 || opcode==8'b00001010 || opcode==8'b00001011) begin
		
			SELECT4=0;  // if the instruction is lwd ,lwi,swd,swi then assign 0 to SELECT4
		end else begin

			SELECT4=1;
		end

			
	end

	always@(negedge BUSYWAIT)  // check whether the busywait signal is negative or not in a positive clk edge
	begin
		if(BUSYWAIT==0) begin // if busywait is 0 then assign 0 to both write and read signals
	
			WRITE=0;
			READ=0;
		end
	end

endmodule   // end of the decoder module



module PC_ADDER(PC,PCNEXT);  // module to iplement PC adder

	input [31:0] PC;  // 32 bit input port decleration
	output [31:0] PCNEXT;  // 32 bit output port decleration

	assign #1 PCNEXT=PC + 32'd4;  // increment PC by 4 and assignned it to the PCNEXT after 1 unit time delay

endmodule //end module



module PRO_COUNTER(PC,PCNEXT,CLK,RESET,BUSYWAIT);  // module to implement program counter

	input CLK,RESET;  //1 bit input ports
	input [31:0] PCNEXT; // 32 bit input port decleration
	output reg [31:0] PC; // 32 bit output port decleration
	input BUSYWAIT;   // 1 bit input port

	always @ (posedge CLK)  // always block , executes at a positive edge of the clk
	begin
		# 0.1
		if(RESET==1 && BUSYWAIT==0) begin  // check whether if reset==1 or not

			#0.9 PC=  0;	//  assign 0 to the PC after 1 unit time delay	
	
		end else if(BUSYWAIT==0)begin  // if busywait=0 then update the pc value

			#0.9 PC = PCNEXT;  // assign the next pro.counter value to the PC after 1 unit time delay

		end

	end // enfd of the always block

endmodule // end of the module



module NEW_ADDER(IN,OFFSET,OUT);  // module to implement  new adder

	input [31:0] IN ,OFFSET;  // declare 32 bit input ports
	output [31:0] OUT;    // declare 32 bit output port

	assign #2 OUT = IN+OFFSET;    // calculate the new value of the program counter ans assign it to out after 2 unit delay


endmodule   // end of the module



module complement(IN,OUT);   // implement 2s complement module

	input [7:0] IN;  // declare 8 bit input port
	output  [7:0] OUT;  // 8 bit output port

	assign #1 OUT = ~(IN) + 8'b00000001;   // evaluate the 2s complement and assign it to the output after 1 unit time delay

endmodule  // end of the module



module MUX1(REGOUT2,SELECT1,OUTPUT1); // implemet a mux to do the evaluations on the REGOUT2 before sending it to the alu

	input [7:0] REGOUT2;    // declare an 8 bit input port
	input SELECT1;   // 1 bit input port

	output  reg [7:0] OUTPUT1;  // declare an 8 bit outputport
	wire  [7:0] b1;   // wire type data decleraion
	
	complement comp(REGOUT2,b1);  // instanciate 2s complement module,call it as comp 
	
	always  @ (*) // always block ,executes when there is a change in SELECT1 or REGOUT2
	begin //  begining of the always block
	
		if(SELECT1==1) begin  // check whether select1=1 or not ( sub instruction or not)
	
			OUTPUT1=b1;	// if it is a sub instruction the output of the complement module is assigned to the output of the mux		

		end else begin

		 	OUTPUT1=REGOUT2;  // if it is not a sub instruction REGOUT2 is assigned to the output of the mux

		end
	end  // end of the always block

endmodule  //end of the module


module MUX2(IMMEDIATE,INPUT1,SELECT2,OPERAND2);  // implemet a mux to do the evaluations on the output of the MUX1  before sending it to the alu

	input [7:0] IMMEDIATE,INPUT1;  // declare 8 bit input ports, INPUT1 = output of the MUX1
	input SELECT2;   // 1 bit input port

	output reg [7:0]  OPERAND2;  // declare an 8 bit output port

	always @ (*) //always block ,executes when there is a change in SELECT2,INPUT1 ,IMMEDIATE
	begin  // begining of the always block

		if(SELECT2==1)begin  // check whether SELECT2=1 or not	

			OPERAND2=INPUT1; // if the instruction is not loadi ,then the output of the MUX1 is assigned to the output of the MUX2
		
		end else begin

			OPERAND2=IMMEDIATE; // If it is a loadi instruction the value in the input IMMEDIATE is assigned to the ouput of the MUX2
	
		end
	end

endmodule  // end of the module


module MUX3(SELECT3,IN1,IN0,PCNEXT);   // implement a mux to do the selections before sending the next pc value to the pc_counter

	input SELECT3;      // 1 bit input port
	input [31:0] IN1,IN0;   // 32 bits input ports
	output reg [31:0] PCNEXT;  // 32 bit output port
	
	always @ (*)   //  always, block executes when there is a change in the inputs
	begin  // begining of the always block

		if(SELECT3==1)begin  // check whether the select3==1 or not  , select3==1 if the the signals JUMP=1 or (BEQ=1 and ZERO=1)

			PCNEXT=IN1;  // assign IN1 to PCNEXT if select3=1 , IN1=pc+4+offset

		end else begin

			PCNEXT=IN0;  // assign IN0 to PCNEXT if select3=0 ,  IN0= pc+4

		end

	end  // end of the always block

endmodule  //  end of the module



module SHIFT_LEFT(IMMEDIATE_OFFSET,OFFSET);   // implement a module to multiply the IMMEDIATE_OFFSET value by 4 

	input [7:0] IMMEDIATE_OFFSET;    // 8 bit input port 
	output [9:0] OFFSET;  // 10 bit output port
	
	assign OFFSET[0]=0;  // assign 0 to the least significant bit of the value OFFSET
	assign OFFSET[1]=0;  // assign 0 to the OFFSET[1]
	assign OFFSET[9:2]= IMMEDIATE_OFFSET;	// assign IMMEDIATE_OFFSET to the bits OFFSET[9:2]

endmodule  // end of the module


module EXTEND_BITS(IN,OFFSET);  // implement a module to extend a 10 bit binary number to a 32 bit binary number

	input [9:0] IN;  // 10 bit input port
	output reg [31:0] OFFSET;  // 32 bit output port
	reg bit1;  // 1 bit register
	integer count1;  //  integer type variable
	
		
	
	always @ (*)  //  always block , executes when there is a change in an input 
	begin //begining of the always block

		bit1=IN[9];  // assign the most significant bit of the input IN to register  bit
		OFFSET[9:0] = IN;  // assign input IN to the OFFSET[9:0]  , OFFSET is the ouput of this module
		
		if(bit1==1) begin
			OFFSET[31:10] = 22'b1111111111111111111111;   // extend the sign bit
		end else begin
			OFFSET[31:10] = 22'b0000000000000000000000;
		end
		
	end // end of the always block
	
endmodule


module MUX4(SELECT4,IN1,IN0,OUT);  // implementing a module called MUX4 , to check whether a given instruction is lwd,lwi,swd or swi 

	input SELECT4;  // declare input and output ports
	input [7:0] IN1,IN0;
	output reg [7:0] OUT;  // this is conected to the reg file OUT=DATAIN

	always @(*) // always block
	begin

		if(SELECT4==0) begin  // select4=0 if the insrtuction is lwd,lwi,swd or swi
 		
			OUT=IN0;  // if select4=0 ,assign IN0 to OUT , IN0 = READDATA output of the adata memmory 
		
		end else begin
		
			OUT=IN1;  // if select4=1, assign IN1 to OUT , IN1=ALURESULT 

		end

	end

endmodule



module control_unit(READREG1,READREG2,WRITEREG,WRITEENABLE,ALUOP,SELECT1,SELECT2,JUMP,BEQ,IMMEDIATE,IMMEDIATE_OFFSET,INSTRUCTION,READ,WRITE,SELECT4,BUSYWAIT);  // implement the control unit


	input [31:0] INSTRUCTION; //declare  32 bit input port
	output  [2:0] READREG1,READREG2,WRITEREG,ALUOP;  // declare 3 bit output ports
	output  [7:0] IMMEDIATE,IMMEDIATE_OFFSET;  // declare an 8 bit output port

	output  reg WRITEENABLE;  // declare output ports
	output SELECT1,SELECT2,JUMP,BEQ,SELECT4,READ,WRITE;
	input BUSYWAIT;

	DECODER decoder1(READREG1,READREG2,WRITEREG,ALUOP,IMMEDIATE,IMMEDIATE_OFFSET,SELECT1,SELECT2,JUMP,BEQ,INSTRUCTION,READ,WRITE,SELECT4,BUSYWAIT); //instanciate DECODER ,call it as decoder1

	always @ (*)
	begin
	if(INSTRUCTION[31:24]==8'b00000110 || INSTRUCTION[31:24]==8'b00000111 || INSTRUCTION[31:24]==8'b00001010 || INSTRUCTION[31:24]==8'b00001011 || BUSYWAIT==1)begin   // check wherthe the instruction is beq , jaump,swd,swi or not (opcode 6 ,7,10,11)
		 WRITEENABLE=0; // assign 1 to write enable
	end else begin

		WRITEENABLE=1;
	end
	end

endmodule //end of the module



module cpu(PC, INSTRUCTION, CLK, RESET,READDATA,BUSYWAIT,WRITEDATA,ADDRESS,WRITE,READ);  // implemet the cpu module

	input CLK,RESET,BUSYWAIT;  // declare 1 bit input ports
	input [31:0] INSTRUCTION;  // declare 32 bit input port
	input [7:0] READDATA;

	output  [31:0] PC; // declare 32 bit output port
	output [7:0] WRITEDATA,ADDRESS;
	output WRITE,READ;

	wire [2:0] readreg1,readreg2,writereg,aluop;  // declare wire type variables
	wire [7:0] immediate,aluresult,regout1,regout2,output1,operand2,immediate_offset,wire5;
	wire [31:0] pcnext,wire1,offset,wire2;
	wire [9:0] wire4;
	wire select1,select2,select3,writeenable,wire3,zero,beq,jump,select4,read,write;




	control_unit  my_control_unit(readreg1,readreg2,writereg,writeenable,aluop,select1,select2,jump,beq,immediate,immediate_offset,INSTRUCTION,read,write,select4,BUSYWAIT); // instanciate control_unit ,call it as my_control_unit


	MUX4     my_mux4(select4,aluresult,READDATA,wire5);  // instanciate MUX4 and call it as my_mux4
	
	reg_file      my_reg_file(wire5,regout1,regout2,writereg,readreg1,readreg2,writeenable,CLK,RESET);  // instanciate re_file,call it as my_reg_file

	MUX1     my_mux1(regout2,select1,output1); // intancitae MUX1 ,call it as my_mux1

	MUX2     my_mux2(immediate,output1,select2,operand2); // instanciate MUX2 ,call it as my_mux2
	
	alu      my_alu(regout1,operand2,aluresult,aluop,zero);  // instanciate alu,call it as my_alu

	
	and and1 (wire3,zero,beq);  // instanciate the inbuild and module ,call it as and1

	or or1(select3,wire3,jump); // instanciate the inbuild or  module ,call it as or1

	SHIFT_LEFT shift(immediate_offset,wire4);  // instanciate SHIFT_LEFT module, call it as shift , wire4=immediate_offset<<2

	EXTEND_BITS extend(wire4,offset);   // instanciate EXTEND_BITS , call it as extend , (offset-32 bits wire4= 10 bits) 

	PC_ADDER   pc_adder1(PC,wire1);  //  instanciate PC_ADDER module,call it as pc_adder , ( wire1 = PC+4 )

	
	NEW_ADDER new_adder1(wire1,offset,wire2); // instanciate NEW_ADDER module ,call it as new_adder1 , ( wire2 = PC+4+offset)
	

	MUX3   my_mux3(select3,wire2,wire1,pcnext);   // instanciate MUX3 ,call it as my_mux3

	PRO_COUNTER pro_counter1(PC,pcnext,CLK,RESET,BUSYWAIT);     //instanciate PRO_COUNTER ,call it as pro_counter1

	assign WRITEDATA=regout1;  // assign values to corespondig output ports
	assign ADDRESS=aluresult;
	assign WRITE=write;
	assign READ=read;

endmodule  //end of the module
