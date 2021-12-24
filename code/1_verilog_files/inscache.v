
`timescale  1ns/100ps

	 
	// lab 6 part3
// instruction cache module
module inscache (cbusywait,Cins,caddress,mbusywait,mread,minstruction,maddress,clock,reset);

	//declare inpurt ports
	input clock,reset,mbusywait;
	input [9:0] caddress;
	input [127:0] minstruction;
	
	//declare output ports
	output cbusywait,mread;
	output [5:0] maddress;
	output reg [31:0] Cins;
	

	// declare some reg type data	
	reg cbusywait,mread,readaccess,valid;
	reg [1:0] offset;
	reg [2:0] tag,index;
    	reg [5:0] maddress;
	reg [127:0] ins;
	reg [31:0] cinstruction;  //store the read data temeparary 


	// create 36 bits , 8 reg type arrays
	reg [127:0] block[7:0];	// bit ranges ------ [31-0] -data block , [32]-dirty bit , [33]-valid bit ,[34-36] - tag
	reg validbit[7:0]; // valid bit array
	reg [2:0] tagarray[7:0]; // tag bit array

	// declare some wire type data

	wire tb1,tb2,tb3;  // tag bits
	wire hit;   // hit signal


	//........................................................................................................................................................//

	//always block ,executes when there is a change in cache address
	always @(caddress)
	begin
			// generate control signals 

		cbusywait = 1;   // stall the cpu
		readaccess = 1; // readaccess=1 
		
	end

	
	always @(*)
	begin
		
		// extracting some essential bits from the block when readacces=1 	
	
		if(readaccess == 1'b1)begin

		
		// extract index,offset from the address comming from the program counter(caddress)
		
			#1; // indexing latency
			index =caddress[6:4]; // extract index
			offset=caddress[3:2]; //extract offset
			
			ins = block[index]; //instruction  in the cache
			tag = tagarray[index];  // current tag in the  cache block
			
			valid = validbit[index];  // current valid bit in the cache block
			
			
		end

	end

//...........................................................................................................................//

	always@(ins[31:0],ins[63:32],ins[95:64],ins[127:96],offset)
	begin
		
			case(offset)  // read the corresponding word according to the offset

			
			 
				//store the data in a  temparary reg cinstruction
				2'b00 : #1 cinstruction=ins[31:0];
				2'b01 : #1 cinstruction=ins[63:32];
				2'b10 : #1 cinstruction=ins[95:64];
				2'b11 : #1 cinstruction=ins[127:96];
			endcase
	end


//.................................................................................................................................................//
	
 	// tag comparison using in build xnor gates
	// #0.9 tag comparison latency	
	
	// instanciate ubnbuid xnor gates
	
	xnor #0.9  bit3tag(tb3,tag[2],caddress[9]); // output=tb1 , inputs - tag[2],caddress[7]
	xnor  #0.9 bit2tag(tb2,tag[1],caddress[8]);
	xnor  #0.9 bit1tag(tb1,tag[0],caddress[7]);

//.....................................................................................................................................................//


	// detecting hits and misses
	// tb1,tb2,tb3 - tag bits
	// instanciate inbuild and gate  

	and hit_miss(hit,tb1,tb2,tb3,valid);  // output=hit 
	
	
//.................................................................................................................................................//


	//assign the ins to the output port
	always@(cinstruction)
	begin

		if(hit==1) begin //read hit

			Cins=cinstruction; // assign the read ins for the output port
		end




	end

//.........................................................................................................................................//


	// always block ,executes at the positive edge of the clock

	always @(posedge clock)begin 


		// check whether it is a read hit or not
		if(readaccess == 1'b1 && hit == 1'b1)begin 

			// read hit

			readaccess = 1'b0; // deassert readaccess signal
			cbusywait = 1'b0; // deaseert the cpu busywait signal


			
		end 

	end
	
	
//.....................................................................................................................................................................//	
	
    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001 , CACHE_UPDATE = 3'b010 ;  // state assignments
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin

	// defining next state depending on the current sate and control signals

        case (state)
            IDLE:
                if (readaccess==1&&!hit)  //read miss
                    next_state = MEM_READ; // memory reading

             
                else 
                    next_state = IDLE;
            
            MEM_READ:
                if (mbusywait==0) //memory busywait 
                    next_state = CACHE_UPDATE;	//write memory block to the cache
                else    
                    next_state = MEM_READ;	//reading the memory
	
	CACHE_UPDATE:  // updating the cache
                 
		if(cbusywait==0)begin  // if the busywait signal connected to the cpu is low
                    next_state = IDLE;
		end
      
        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mread = 1'd0;  // ins memory  read signal
               maddress = 6'dx; // ins memory address
               
    
            end
         
            MEM_READ: 
            begin
                mread = 1'd1; // ins mem read signal
                
                maddress = caddress[9:4]; // caddress -last 10 bits of the PC 
               
                
            end
			
	    
			
	    CACHE_UPDATE: 
            begin
                mread = 1'd0; // deassert mem read signal
               
                maddress = 6'dx;
                

		#1 // writting delay
		block[index] = minstruction;	//write new ins block to the cache
		tagarray[index]= caddress[9:7];//update tag according to the cache address
		
		validbit[index] = 1'd1; // update valid bit
		


            end
            
            
            
        endcase
    end

    // sequential logic for state transitioning 
    always @(posedge clock, reset)
    begin
        if(reset)begin
            state = IDLE;

			cbusywait = 1'b0;
			
			
			//set valid bits to 0
			validbit[0] = 0;
			validbit[1] = 0;
			validbit[2] = 0;
			validbit[3] = 0;
			validbit[4] = 0;
			validbit[5] = 0;
			validbit[6] = 0;
			validbit[7] = 0;
			
			
		end
        else begin
			//change the state of FSM in a positive clock edge
            state = next_state;
	end
    end
	
	

    /* Cache Controller FSM End */

endmodule
