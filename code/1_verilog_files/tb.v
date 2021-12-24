`timescale  1ns/100ps
//  Lab 6 Part1




// implement the test bench of the cpu
module cpu_tb;

    reg CLK, RESET;
    wire BUSYWAIT; 
    wire MEM_BUSYWAIT,IM_BUSYWAIT,IC_BUSYWAIT,DC_BUSYWAIT;
    wire [31:0] PC;   // declare input and output variables
    wire [31:0] INSTRUCTION;
    wire[7:0] READDATA;
    wire [7:0] WRITEDATA,ADDRESS;
    wire WRITE,READ;
    wire MEM_WRITE,MEM_READ,IM_READ;
    wire[31:0] MEM_WRITEDATA,MEM_READDATA;
    wire [5:0] MEM_ADDRESS,IM_ADDRESS;
    wire [127:0] IM_INS;

    
  
    cpu mycpu(PC, INSTRUCTION, CLK, RESET,READDATA,BUSYWAIT,WRITEDATA,ADDRESS,WRITE,READ);  // instantiate cpu model as mycpu

    or orgate(BUSYWAIT,IC_BUSYWAIT,DC_BUSYWAIT);

    inscache ins_cache(IC_BUSYWAIT,INSTRUCTION,PC[9:0],IM_BUSYWAIT,IM_READ,IM_INS,IM_ADDRESS,CLK,RESET);
    instruction_memory ins_mem(CLK,IM_READ,IM_ADDRESS,IM_INS,IM_BUSYWAIT);
    

    dcache datacache(DC_BUSYWAIT,READ,WRITE,WRITEDATA,READDATA,ADDRESS,MEM_BUSYWAIT,MEM_READ,MEM_WRITE,MEM_WRITEDATA,MEM_READDATA,MEM_ADDRESS,CLK,RESET);

    data_memory dm (CLK,RESET,MEM_READ,MEM_WRITE,MEM_ADDRESS,MEM_WRITEDATA,MEM_READDATA,MEM_BUSYWAIT);

    

    initial  // initial block
    begin
    
	
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
	$dumpvars(0, cpu_tb);
       
        CLK = 1'b0;   //  assign some values to variables
        RESET = 1'b1;
        
        
   	#5
	RESET=1'b0;


	
	 
        // finish simulation after some time
        #2750
        $finish;
        
    end

	
	/*always @ (*)    // create 32 bit instruction according to the value of PC
	begin
	if (BUSYWAIT==0) begin
		  #2;
		  INSTRUCTION[7:0]=instr_mem[PC];
		  INSTRUCTION[15:8]=instr_mem[PC+1];
    	          INSTRUCTION[23:16]=instr_mem[PC+2];
		  INSTRUCTION[31:24]=instr_mem[PC+3];
	end 
		
	end*/
	    


    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule // end of the test bench


