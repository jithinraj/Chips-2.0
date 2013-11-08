//name : response
//tag : c components
//input : input_in:16
//source_file : response.c
///Response
///========
///
///*Created by C2CHIP*

  
`timescale 1ns/1ps
module response(input_in,input_in_stb,clk,rst,input_in_ack);
  input     [15:0] input_in;
  input     input_in_stb;
  input     clk;
  input     rst;
  output    input_in_ack;
  reg       [15:0] timer;
  reg       [1:0] program_counter;
  reg       [15:0] address;
  reg       [15:0] data_out;
  reg       [15:0] data_in;
  reg       write_enable;
  reg       [15:0] register_0;
  reg       [15:0] register_1;
  reg       [15:0] register_2;
  reg       [15:0] s_input_in_ack;
  reg [15:0] memory [-1:0];

  //////////////////////////////////////////////////////////////////////////////
  // MEMORY INITIALIZATION                                                      
  //                                                                            
  // In order to reduce program size, array contents have been stored into      
  // memory at initialization. In an FPGA, this will result in the memory being 
  // initialized when the FPGA configures.                                      
  // Memory will not be re-initialized at reset.                                
  // Dissable this behaviour using the no_initialize_memory switch              
  
  initial
  begin
  end


  //////////////////////////////////////////////////////////////////////////////
  // FSM IMPLEMENTAION OF C PROCESS                                             
  //                                                                            
  // This section of the file contains a Finite State Machine (FSM) implementing
  // the C process. In general execution is sequential, but the compiler will   
  // attempt to execute instructions in parallel if the instruction dependencies
  // allow. Further concurrency can be achieved by executing multiple C         
  // processes concurrently within the device.                                  
  
  always @(posedge clk)
  begin

    if (write_enable == 1'b1) begin
      memory[address] <= data_in;
    end

    data_out <= memory[address];
    write_enable <= 1'b0;
    timer <= 16'h0000;

    case(program_counter)

      16'd0:
      begin
        program_counter <= 16'd1;
        program_counter <= 16'd3;
        register_0 <= 16'd1;
      end

      16'd1:
      begin
        program_counter <= 16'd3;
        program_counter <= program_counter;
      end

      16'd3:
      begin
        program_counter <= 16'd2;
        register_2 <= input_in;
        program_counter <= 3;
        s_input_in_ack <= 1'b1;
       if (s_input_in_ack == 1'b1 && input_in_stb == 1'b1) begin
          s_input_in_ack <= 1'b0;
          program_counter <= 16'd2;
        end
      end

      16'd2:
      begin
        program_counter <= 16'd6;
        register_1 <= 16'd0;
        program_counter <= register_0;
      end

    endcase
    if (rst == 1'b1) begin
      program_counter <= 0;
      s_input_in_ack <= 0;
    end
  end
  assign input_in_ack = s_input_in_ack;

endmodule
