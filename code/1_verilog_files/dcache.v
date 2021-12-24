
`timescale  1ns/100ps
	
	// lab 6 part2 

// data cache module
module dcache (cbusywait,cread,cwrite,cwritedata,creaddata,caddress,mbusywait,mread,mwrite,mwritedata,mreaddata,maddress,clock,reset);

	//declare inpurt ports
	input clock,reset,cread,cwrite,mbusywait;
	input [7:0] caddress,cwritedata;
	input [31:0] mreaddata;
	
	//declare output ports
	output cbusywait,mread,mwrite;
	output [5:0] maddress;
	output [7:0] creaddata;
	output [31:0] mwritedata;

	// declare some reg type data	
	reg cbusywait,mread,mwrite,readaccess, writeaccess,valid,dirty;
	reg [1:0] offset;
	reg [2:0] tag,index;
    	reg [5:0] maddress;
	reg [31:0] mwritedata,data;
	reg [7:0] creaddata;


	// create 36 bits , 8 reg type arrays
	reg [36:0] cache[7:0];	// bit ranges ------ [31-0] -data block , [32]-dirty bit , [33]-valid bit ,[34-36] - tag
	
	// declare some wire type data

	wire tb1,tb2,tb3;  // tag bits
	wire hit;  



	//................................................................................................................................................//

	//always block ,executes when there is a change in cread or cwrite signals (cread=cache read / read signal comming out from the cpu)
	always @(cread, cwrite)
	begin
			// generate control signals according to the cread and cwrite signals

		cbusywait = (cread || cwrite)? 1 : 0;   // cbusywait (c-cpu) =1 when cread =1 or cwrite=1 , stall the cpu
		readaccess = (cread && !cwrite)? 1 : 0; // readaccess=1 when cread=1 and cwrite=0
		writeaccess = (!cread && cwrite)? 1 : 0; // writeaccess=1 when cread=0 and cwrite=1
	end

	//.................................................................................................................................................//

	
	always @(*)
	begin
		
		// extracting some essential bits from the block when readacces=1 or writeaccess=1	
	
		if(readaccess == 1'b1 || writeaccess == 1'b1)begin

		
		// extract index,offset from the address comming from the cpu (caddress)
		
			#1; // indexing latency
			index = caddress[4:2];
			offset = caddress[1:0];
			
			data = cache[index][31:0]; //data in the cache
			tag = cache[index][36:34];  // current tag in the  cache block
			dirty = cache[index][32];  // current  dirty bit in the cache block 
			valid = cache[index][33];  // current valid bit in the cache block
			
			
		end

	end


	
	
	

//......................................................................................................................//
	always@(data[7:0],data[15:8],data[23:16],data[23:16],data[31:24],offset,hit)

	begin
			
			#1
			if(hit==1)
			case(offset)  // read the corresponding word according to the offset

			//creaddata = readdata signal which is connected to the cpu
			// #1 readig delay

				2'b00 : creaddata=data[7:0];
				2'b01 :  creaddata=data[15:8];
				2'b10 :  creaddata=data[23:16];
				2'b11 :  creaddata=data[31:24];
			endcase
			



	end

	//.................................................................................................................................................//
	
 	// tag comparison using in build xnor gates
	// #1 tag comparison latency	
	
	// instanciate ubnbuid xnor gates
	xnor  bit3tag(tb3,tag[2],caddress[7]); // output=tb1 , inputs - tag[2],caddress[7]
	xnor bit2tag(tb2,tag[1],caddress[6]);
	xnor bit1tag(tb1,tag[0],caddress[5]);

//.....................................................................................................................................................//


	// detecting hits and misses
	// tb1,tb2,tb3 - tag bits
	// instanciate inbuild and gate  

	and #0.9 hit_miss(hit,tb1,tb2,tb3,valid);  // output=hit 
	
	
	

	


//........................................................................................................................................................//

	// always block ,executes at the positive edge of the clock

	always @(posedge clock)begin 


		// check whether it is a read hit or not
		if(readaccess == 1'b1 && hit == 1'b1)begin 

			readaccess = 1'b0; // deassert readaccess signal
			cbusywait = 1'b0; // deaseert the cpu busywait signal

			
			
			
	
		end else if(writeaccess == 1'b1 && hit == 1'b1)begin //check whether is a write hit or not
			
		// handling write hit	


				
				cbusywait = 1'b0; // deassert cpu busywait siganal
			
			#1

			// write the word in the cwritedata signal in to the corresponding cache entry depending on the offset
			case(offset)
							

				//writing the data word to the cache
				// #1 writting delay
				2'd0 : cache[index][7:0] = cwritedata;
				2'd1 :  cache[index][15:8] = cwritedata;
				2'd2 :  cache[index][23:16] = cwritedata;
				2'd3 :  cache[index][31:24] = cwritedata;
		
			endcase
			cache[index][32] =1;	//dirty bit = 1 (memory!= cache)

			cache[index][33] =1;  // valid bit=1
			writeaccess = 1'b0; // deassert writeaccess signal

			
		 
		 end


	end




	

	

	

	
	


	
//.....................................................................................................................................................................//	
	
    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_WRITE = 3'b001 , MEM_READ = 3'b010 , CACHE_UPDATE = 3'b011;  // state assignments
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin

	// defining next state depending on the current sate and control signals

        case (state)
            IDLE:
                if ((cread || cwrite) && !dirty && !hit)  //misses without dirty
                    next_state = MEM_READ; // memory reading

                else if ((cread || cwrite) && dirty && !hit)	//misses with dirty

                    next_state = MEM_WRITE;	// write back to the memory
                else
                    next_state = IDLE;
            
            MEM_READ:
                if (mbusywait==0) //memory busywait 
                    next_state = CACHE_UPDATE;	//write data block to the cache
                else    
                    next_state = MEM_READ;	//reading the memory
					
	MEM_WRITE:
                if (mbusywait==0)
                    next_state = MEM_READ;	//after memory writing,start the memory reading
                else    
                    next_state = MEM_WRITE;	//write back to the memory
					
	CACHE_UPDATE:  // updating the cache
                 
		if((cread || cwrite) && dirty && !hit)begin  // if the busywait signal connected to the cpu is low
                    next_state =CACHE_UPDATE;
		end else begin
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
                mread = 1'd0;
                mwrite = 1'd0;  // generate output signals
                maddress = 6'dx;
                mwritedata = 32'dx;
    
            end
         
            MEM_READ: 
            begin
                mread = 1'd1;
                mwrite = 1'd0;
                maddress = caddress[7:2]; // caddress - address comming out from the cpu ,maddress contains the tag and index bits
                mwritedata = 32'dx;
                cbusywait=1;
            end
			
	    MEM_WRITE:   //write old data block to the mem
            begin
                mread = 1'd0;
                mwrite = 1'd1;
                maddress = {tag,index};	//cureent tag and index in the coreesponding  block
                mwritedata = data;  // assign old data block to the mem write data signal
              	cbusywait=1;
              
            end
			
	    CACHE_UPDATE: 
            begin
                mread = 1'd0;
                mwrite = 1'd0;
                maddress = 6'dx;
                mwritedata = 32'dx;
		cbusywait=1;

		#1 // writting delay
		cache[index][31:0] = mreaddata;	//write new data block to the cache
		cache[index][36:34] = caddress[7:5];//update tag according to the cache address
		cache[index][32] = 1'd0;  // update dirty bit ( birty bit=0 , mem=cache)
		cache[index][33] = 1'd1; // update valid bit
		


            end
            
            
            
        endcase
    end

    // sequential logic for state transitioning 
    always @(posedge clock, reset)
    begin
        if(reset)begin
            state = IDLE;

			cbusywait = 1'b0;
			
			
			
			//resetting the cache
			cache[0] = 37'd0;
			cache[1] = 37'd0;
			cache[2] = 37'd0;
			cache[3] = 37'd0;
			cache[4] = 37'd0;
			cache[5] = 37'd0;
			cache[6] = 37'd0;
			cache[7] = 37'd0;
			
			
		end
        else begin
			//change the state of FSM in a positive clock edge
            state = next_state;
		end
    end
	
	

    /* Cache Controller FSM End */

endmodule
