
`include "defines.vh"
//---------------------------------------------------------------------------
// DUT 
//---------------------------------------------------------------------------
module MyDesign(
//---------------------------------------------------------------------------
//System signals
  input wire reset_n                      ,  
  input wire clk                          ,

//---------------------------------------------------------------------------
//Control signals
  input wire dut_valid                    , 
  output wire dut_ready                   ,

//---------------------------------------------------------------------------
//q_state_input SRAM interface
  output wire                                               q_state_input_sram_write_enable  ,
  output wire [`Q_STATE_INPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_input_sram_write_address ,
  output wire [`Q_STATE_INPUT_SRAM_DATA_UPPER_BOUND-1:0]    q_state_input_sram_write_data    ,
  output wire [`Q_STATE_INPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_input_sram_read_address  , 
  input  wire [`Q_STATE_INPUT_SRAM_DATA_UPPER_BOUND-1:0]    q_state_input_sram_read_data     ,

//---------------------------------------------------------------------------
//q_state_output SRAM interface
  output wire                                                q_state_output_sram_write_enable  ,
  output wire [`Q_STATE_OUTPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_output_sram_write_address ,
  output wire [`Q_STATE_OUTPUT_SRAM_DATA_UPPER_BOUND-1:0]    q_state_output_sram_write_data    ,
  output wire [`Q_STATE_OUTPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_output_sram_read_address  , 
  input  wire [`Q_STATE_OUTPUT_SRAM_DATA_UPPER_BOUND-1:0]    q_state_output_sram_read_data     ,

//---------------------------------------------------------------------------
//scratchpad SRAM interface                                                       
  output wire                                                scratchpad_sram_write_enable        ,
  output wire [`SCRATCHPAD_SRAM_ADDRESS_UPPER_BOUND-1:0]     scratchpad_sram_write_address       ,
  output wire [`SCRATCHPAD_SRAM_DATA_UPPER_BOUND-1:0]        scratchpad_sram_write_data          ,
  output wire [`SCRATCHPAD_SRAM_ADDRESS_UPPER_BOUND-1:0]     scratchpad_sram_read_address        , 
  input  wire [`SCRATCHPAD_SRAM_DATA_UPPER_BOUND-1:0]        scratchpad_sram_read_data           ,

//---------------------------------------------------------------------------
//q_gates SRAM interface                                                       
  output wire                                                q_gates_sram_write_enable           ,
  output wire [`Q_GATES_SRAM_ADDRESS_UPPER_BOUND-1:0]        q_gates_sram_write_address          ,
  output wire [`Q_GATES_SRAM_DATA_UPPER_BOUND-1:0]           q_gates_sram_write_data             ,
  output wire [`Q_GATES_SRAM_ADDRESS_UPPER_BOUND-1:0]        q_gates_sram_read_address           ,  
  input  wire [`Q_GATES_SRAM_DATA_UPPER_BOUND-1:0]           q_gates_sram_read_data              
);

  localparam inst_sig_width = 52;
  localparam inst_exp_width = 11;
  localparam inst_ieee_compliance = 3;

  reg  [inst_sig_width+inst_exp_width : 0] inst_a;
  reg  [inst_sig_width+inst_exp_width : 0] inst_b;
  reg  [inst_sig_width+inst_exp_width : 0] inst_c;
  reg  [2 : 0] inst_rnd;
  wire [inst_sig_width+inst_exp_width : 0] z_inst;
  wire [7 : 0] status_inst;

  // This is test stub for passing input/outputs to a DP_fp_mac, there many
  // more DW macros that you can choose to use


parameter [3:0] S0=4'b0000, S1=4'b0001, S2=4'b0010, S3=4'b0011, S4=4'b0100, S5=4'b0101, S5_before = 4'b1011, S6=4'b0110, S7=4'b0111, S8=4'b1000, S9=4'b1001, S10=4'b1010, S4_before=4'b1100, S9_before=4'b1101;
reg[3:0] current_state, next_state;
reg [63:0]Q;
reg [63:0]M;
reg dut_ready_r;
wire [127:0]read_data_q_state;
reg [127:0] q_gate_demux;
reg SRAM_sel_mux;
reg[1:0]  read_address_select_q_state;
reg[1:0]  read_address_select_q_gates;
reg[1:0] read_address_select_scratchpad;
reg data_demux_q_m;
reg data_demux_r_i;
reg z_select;
reg [5:0] num_of_reads_from_q_state;
reg [8:0] num_of_reads_from_q_gate;
reg [10:0] total_number_of_multiplications;
reg [1:0] control_counter;
reg [1:0] control_counter_n;
reg [8:0] control_counter_r;
reg [8:0] control_counter_n_r;
reg [8:0] q_state_reset_counter;
reg [8:0] q_gate_hold_counter;
reg write_enable_q_state;
reg write_enable_scratchpad;
reg write_enable_output_sram;
reg write_data_output_sram;
reg [1:0]  write_address_select_scratchpad;
reg [1:0] write_address_select_output_sram;
reg write_enable_q_gate;
reg write_data_scratchpad;
wire [63:0] R_q_gate;
wire [63:0] I_q_gate;
reg [`Q_STATE_OUTPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_input_sram_read_address_r;
reg [`Q_GATES_SRAM_ADDRESS_UPPER_BOUND-1:0]  q_gates_sram_read_address_r;
reg [`SCRATCHPAD_SRAM_ADDRESS_UPPER_BOUND-1:0] scratchpad_sram_write_address_r;
reg [`SCRATCHPAD_SRAM_DATA_UPPER_BOUND-1:0] scratchpad_sram_write_data_r;
reg [`Q_STATE_OUTPUT_SRAM_DATA_UPPER_BOUND-1:0] q_state_output_sram_write_data_r;
reg [`SCRATCHPAD_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_output_sram_write_address_r;
reg [`SCRATCHPAD_SRAM_DATA_UPPER_BOUND-1:0] scratchpad_sram_read_address_r;
reg q_state_input_sram_write_enable_r;
reg q_state_output_sram_write_enable_r;
reg q_gates_sram_write_enable_r;
reg scratchpad_sram_write_enable_r;
wire [63:0] R_q_state;
wire [63:0] I_q_state;
reg [63:0] R_total;
reg [63:0] I_total;
wire [63:0] r_total;
wire [63:0] i_total;
reg [1:0] R_add_sel;
wire [63:0] neta;
wire [63:0] netb;
wire [63:0] netc;
wire [63:0] netd;
wire [63:0] za;
wire [63:0] zb;
wire [63:0] zc;
wire [63:0] zd;
reg [63:0] Z_r_a;
reg [63:0] Z_r_b;
reg [63:0] Z_r_c;
wire [63:0] Z_r_d;
wire [63:0] neg_Z_r_b;
wire [63:0] neg_Z_r_d;
wire [63:0] R_before_add;
wire [63:0] I_before_add;

wire  [7:0] status1;
wire  [7:0] status2;
wire  [7:0] status3;
wire  [7:0] status4;
wire  [7:0] status5;
wire  [7:0] status6;


reg [1:0] scratch_write_counter;
reg [63:0] scratch_write_counter_r;
reg [1:0] multiplication_counter;
reg [63:0] multiplication_counter_r;
always @(posedge clk or negedge reset_n)
begin
  if(!reset_n) current_state<=S0;
  else current_state<=next_state;
end
reg [63:0] num_of_reads_from_q_state_1;
assign dut_ready = dut_ready_r;

always @(*)

begin
casex(current_state)
      S0:begin
        dut_ready_r = 1;
        control_counter = 0;
        SRAM_sel_mux = 0;
        control_counter_n=0;
        multiplication_counter = 0;
        R_add_sel = 0;
        read_address_select_q_state = 0;
        read_address_select_q_gates = 0;
        read_address_select_scratchpad = 0; 
        write_address_select_scratchpad = 0;
        write_enable_q_state =0;
        write_enable_scratchpad = 0;
        write_data_scratchpad = 0;
        data_demux_q_m = 1;
        write_enable_output_sram = 0;
        write_data_output_sram = 0;
        scratch_write_counter = 0;
        write_address_select_output_sram = 0;
        if(dut_valid) 
	    begin
        data_demux_q_m = 1;
        read_address_select_q_gates = 0;
        scratch_write_counter = 0;
        write_address_select_scratchpad = 0;
        write_enable_scratchpad = 0;
        write_data_scratchpad = 0;
        control_counter = 0;
        write_address_select_output_sram = 0;
        write_data_output_sram = 0;
        read_address_select_q_state = 0;
	    SRAM_sel_mux = 0;
        control_counter_n=0;
        read_address_select_scratchpad = 0; 
        multiplication_counter = 0;
	    write_enable_output_sram = 0;
        dut_ready_r = 1;
        R_add_sel = 0;
	    next_state = S1;
	    end
        else
 	    begin
        data_demux_q_m = 1;
        read_address_select_q_state = 0;
	    SRAM_sel_mux = 0;
        read_address_select_q_gates = 0;
        scratch_write_counter = 0;
        write_enable_scratchpad = 0;
        read_address_select_scratchpad = 0; 
        write_data_output_sram = 0;
        write_address_select_scratchpad = 0;
        control_counter = 0;
        write_data_scratchpad = 0;
        write_address_select_output_sram = 0;
        control_counter_n=0;
        multiplication_counter = 0;
	    write_enable_output_sram = 0;
        R_add_sel = 0;
        dut_ready_r = 1;
 	    next_state = S0;
	    end
    end
     S1:begin
        write_enable_q_state =0;
        write_enable_scratchpad = 0;
        dut_ready_r = 0;
        control_counter = 0;
	    scratch_write_counter = 0;
        write_address_select_scratchpad = 0;
        write_data_output_sram = 0;
        write_data_scratchpad = 0;
	    write_enable_output_sram = 0;
        data_demux_q_m =1;
        write_address_select_output_sram = 0;
        read_address_select_scratchpad = 0; 
        control_counter_n=0;
        read_address_select_q_state = 3;
        multiplication_counter = 0;
        read_address_select_q_gates = 0;
        R_add_sel = 0;
        SRAM_sel_mux = 0;
        next_state = S2;
    end
      S2:begin
      	write_enable_q_state =0;
      	write_enable_scratchpad = 0;
	    write_enable_output_sram = 0;
	    dut_ready_r = 0;
        scratch_write_counter = 0;
	    read_address_select_q_state = 2;
        write_data_scratchpad = 0;
        read_address_select_scratchpad = 0; 
        multiplication_counter = 0;
        write_data_output_sram = 0;
      	write_address_select_scratchpad = 2;
        read_address_select_q_gates = 2;
        SRAM_sel_mux = 0;
        control_counter_n=0;
        control_counter = 2;
	    R_add_sel = 2;
	    data_demux_q_m =0;
	    num_of_reads_from_q_state_1=Q-1;
	    write_address_select_output_sram = 2;
	    if(scratchpad_sram_write_address_r < (1<<Q))
	    begin
        dut_ready_r = 0;
	    data_demux_q_m =0;
		scratch_write_counter = 0;
      	read_address_select_scratchpad = 0; 
	    R_add_sel = 2;
        multiplication_counter = 0;
        write_address_select_output_sram = 2;
        write_data_scratchpad = 0;
	    read_address_select_q_gates = 2;
      	write_address_select_scratchpad = 2;
        write_data_output_sram = 0;
        write_enable_scratchpad = 0;
        control_counter = 2;
	    read_address_select_q_state = 2;
        control_counter_n=0;
	    SRAM_sel_mux = 0;
	    write_enable_output_sram = 0;
	    next_state=S3;
	    end
      	else
	    begin
        dut_ready_r = 0;
	    data_demux_q_m =0;
	    R_add_sel = 2;
	    SRAM_sel_mux = 0;
        write_data_scratchpad = 0;
        control_counter = 2;
      	control_counter_n=0;
       	write_address_select_output_sram = 2;
     	write_enable_scratchpad = 0;
	    read_address_select_q_state = 2;
      	write_data_output_sram = 0;
	    read_address_select_q_gates = 2;
      	write_address_select_scratchpad = 2;
		scratch_write_counter = 0;
	    write_enable_output_sram = 0;
        read_address_select_scratchpad = 0; 
		multiplication_counter=1;
	    next_state=S6;
        end
    end
      S3:begin
      	 write_enable_q_state =0;
      	 write_enable_scratchpad = 0;
      	 multiplication_counter = 2;
      	 write_data_scratchpad = 0;
		 scratch_write_counter = 0;
	     SRAM_sel_mux = 0;
      	 write_address_select_output_sram = 2;
      	 write_address_select_scratchpad = 2;
	     read_address_select_q_gates = 2;
      	 write_data_output_sram = 0;
         read_address_select_scratchpad = 0; 
	     read_address_select_q_state = 2;
         control_counter = 2;
	     dut_ready_r = 0;
         control_counter_n=0;
	      R_add_sel = 2;
	      write_enable_output_sram = 0;
	      data_demux_q_m =0;
	      if(control_counter_r < num_of_reads_from_q_state)
	      begin
		  scratch_write_counter = 0;
          dut_ready_r = 0;
		  R_add_sel = 1;
	      read_address_select_q_state = 1;
          write_enable_scratchpad = 0;
          multiplication_counter = 2;
          read_address_select_q_gates = 1;
          SRAM_sel_mux = 0;
          write_address_select_scratchpad = 2;
          write_data_output_sram = 0;
          write_address_select_output_sram = 2;
          control_counter_n=0;
          write_data_scratchpad = 0;
          write_enable_output_sram = 0;
          read_address_select_scratchpad = 0; 
	      data_demux_q_m =0;
          control_counter = 1;
	      next_state=S2;
	     end
	     else
	     begin
          dut_ready_r = 0;
	      R_add_sel = 2;
          multiplication_counter = 2;
          control_counter = 2;
      	  write_address_select_scratchpad = 2;
	      read_address_select_q_state = 2;
          write_address_select_output_sram = 2;
          read_address_select_scratchpad = 0; 
          write_data_output_sram = 0;
          write_enable_scratchpad = 0;
	      SRAM_sel_mux = 0;
          write_data_scratchpad = 0;
	      read_address_select_q_gates = 2;
	      write_enable_output_sram = 0;
          control_counter_n=0;
		  scratch_write_counter = 0;
	      data_demux_q_m =0;
		  next_state = S4_before;
	     end
     end
       S4_before:
	      begin
          dut_ready_r = 0;
	      R_add_sel = 2;
          control_counter = 2;
          multiplication_counter = 2;
		  scratch_write_counter = 0;
      	  write_address_select_scratchpad = 2;
	      read_address_select_q_gates = 2;
          write_data_scratchpad = 0;
          read_address_select_scratchpad = 0; 
          write_enable_scratchpad = 0;
          write_data_output_sram = 0;
          write_address_select_output_sram = 2;
	      SRAM_sel_mux = 0;
          control_counter_n=0;
	      write_enable_output_sram = 0;
	      data_demux_q_m =0;
		  if(M!=1)
		  begin
		  read_address_select_q_state = 2;
		  read_address_select_q_gates = 2;
          control_counter_n=0;
          multiplication_counter = 2;
          write_enable_scratchpad = 1;
          write_address_select_output_sram = 2;
          scratch_write_counter = 0;
          write_enable_output_sram = 0;
          SRAM_sel_mux = 0;
          read_address_select_scratchpad = 0; 
          write_data_output_sram = 0;
          dut_ready_r = 0;
		  R_add_sel = 2;
	      data_demux_q_m =0;
	      write_data_scratchpad = 1;
      	  control_counter = 0;
      	  write_address_select_scratchpad = 2;
		  next_state = S4;
	      end
	      else
	      begin
	      read_address_select_q_state = 2;
		  read_address_select_q_gates = 2;
          multiplication_counter = 2;
          control_counter_n=0;
          read_address_select_scratchpad = 0; 
		  write_enable_output_sram = 1;
		  scratch_write_counter = 0;
	      SRAM_sel_mux = 0;
          write_enable_scratchpad = 0;
		  R_add_sel = 2;
	      write_data_scratchpad = 0;
      	  write_address_select_scratchpad = 2;
	      data_demux_q_m =0;
          dut_ready_r = 0;
		  write_data_output_sram = 1;
      	  control_counter = 0;
		  write_address_select_output_sram = 2;
		  next_state = S5_before;
	     end
     end
      S4:begin
	      write_enable_q_state =0;
	      write_address_select_scratchpad = 1;
          control_counter_n=0;
          multiplication_counter = 2;
     	  dut_ready_r = 0;
          control_counter = 2;
	      write_enable_scratchpad = 1;
	      read_address_select_q_state = 3;
	      write_address_select_output_sram = 0;
          write_data_output_sram = 0;
		  write_enable_output_sram = 1;
	      read_address_select_q_gates = 2;
		  scratch_write_counter = 0;
	      data_demux_q_m =0;
	      read_address_select_scratchpad = 0;
	      write_data_scratchpad = 0;
	      SRAM_sel_mux = 0;
	      R_add_sel = 0;
	      next_state = S2;
     end
    S5_before:    // 11
    begin
		  write_enable_output_sram = 0;
	      read_address_select_q_state = 2;
          write_enable_scratchpad = 0;
      	  write_address_select_scratchpad = 2;
	      SRAM_sel_mux = 0;
	      read_address_select_q_gates = 2;
          dut_ready_r = 0;
	      write_data_scratchpad = 0;
          write_address_select_output_sram = 2;
          control_counter = 2;
          control_counter_n=0;
		  scratch_write_counter = 0;
          multiplication_counter = 2;
	      R_add_sel = 0;
          read_address_select_scratchpad = 0; 
		  write_data_output_sram = 0;
	      data_demux_q_m =0;
		  next_state = S5;
	     end
     S5:begin
	      write_enable_q_state =0;
	      write_address_select_output_sram = 1;
          control_counter_n=0;
     	  dut_ready_r = 0;
          multiplication_counter = 2;
	      read_address_select_q_state = 3;
          read_address_select_scratchpad = 0; 
      	  write_address_select_scratchpad = 2;
		  scratch_write_counter = 0;
	      write_data_scratchpad = 0;
          control_counter = 2;
	      data_demux_q_m =0;
          write_enable_scratchpad = 0;
          write_enable_output_sram = 0;
	      read_address_select_q_gates = 2;
	      write_data_output_sram = 0;
	      SRAM_sel_mux = 0;
	      R_add_sel = 0;
	      if(q_state_output_sram_write_address<num_of_reads_from_q_state)
	      begin
          dut_ready_r = 0;
	      data_demux_q_m =0;
          control_counter = 2;
	      write_data_scratchpad = 0;
      	  write_address_select_scratchpad = 2;
	   	  scratch_write_counter = 0;
          read_address_select_scratchpad = 0; 
	      read_address_select_q_state = 3;
          multiplication_counter = 2;
          write_data_output_sram = 0;
          write_enable_scratchpad = 0;
	      SRAM_sel_mux = 0;
	      read_address_select_q_gates = 2;
	      write_address_select_output_sram = 1;
	      R_add_sel = 0;
          control_counter_n=0;
		  write_enable_output_sram = 0;
		  next_state = S2;
          end
	      else
	      begin
	      dut_ready_r = 1;
	      R_add_sel = 0;
		  write_enable_output_sram = 0;
          read_address_select_scratchpad = 0; 
	      write_address_select_output_sram = 1;
	      write_data_scratchpad = 0;
	      read_address_select_q_gates = 2;
	      read_address_select_q_state = 3;
          write_data_output_sram = 0;
	      data_demux_q_m =0;
          control_counter = 2;
          control_counter_n=0;
    	  SRAM_sel_mux = 0;
          write_enable_scratchpad = 0;
          multiplication_counter = 2;
		  scratch_write_counter = 0;
		  next_state = S0;    
	      end
        end
	S6: begin 
		   scratch_write_counter = 2;
		   dut_ready_r = 0;
	       data_demux_q_m =0;
		   control_counter_n = 2;
	       read_address_select_q_state = 2;
		   multiplication_counter = 2;
      	   write_enable_scratchpad = 0;
           control_counter = 0;
           write_data_output_sram = 0;
	       write_enable_output_sram = 0;
	       data_demux_q_m =0;
	       read_address_select_scratchpad = 2;
      	   write_address_select_scratchpad = 2;
	       write_data_scratchpad = 0;
	       write_address_select_output_sram = 2;
	       read_address_select_q_gates = 2;
	       SRAM_sel_mux = 1;
	       R_add_sel = 2;
	      next_state = S7;
	end
	S7: begin 
		  dut_ready_r = 0;
      	  write_enable_scratchpad = 0;
		  scratch_write_counter = 2;
	      read_address_select_q_state = 2;
          control_counter = 0;
          write_data_output_sram = 0;
          multiplication_counter = 2;
		  write_enable_output_sram = 0;
	      write_address_select_output_sram = 2;
	      write_data_scratchpad = 0;
		  control_counter_n = 2;
	      read_address_select_scratchpad = 2;
      	  write_address_select_scratchpad = 2;
	      data_demux_q_m =0;
	      read_address_select_q_gates = 2;
	      SRAM_sel_mux = 1;
	      R_add_sel = 2;
	      next_state = S8;
	end
	S8:begin
		  dut_ready_r = 0;
          control_counter = 0;
		  scratch_write_counter = 2;
		  write_enable_output_sram = 0;
          multiplication_counter = 2;
	      read_address_select_q_state = 2;
	      read_address_select_q_gates = 2;
	      R_add_sel = 2;
          write_data_output_sram = 0;
	      write_data_scratchpad = 0;
      	  write_address_select_scratchpad = 2;
	      read_address_select_scratchpad = 2;
	      write_address_select_output_sram = 2;
		  control_counter_n = 2;
	      data_demux_q_m =0;
	      SRAM_sel_mux = 1;
		  write_enable_scratchpad = 0;
	      if(control_counter_n_r < num_of_reads_from_q_state)
	      begin
		  R_add_sel = 1;
		  dut_ready_r = 0;
	      read_address_select_q_state = 2;
		  scratch_write_counter = 2;
          write_enable_scratchpad = 0;
		  write_enable_output_sram = 0;
      	  write_address_select_scratchpad = 2;
          write_data_output_sram = 0;
	      read_address_select_q_gates = 1;
	      write_address_select_output_sram = 2;
          multiplication_counter = 2;
	      write_data_scratchpad = 0;
	      SRAM_sel_mux = 1;
	      read_address_select_scratchpad = 1;
	      data_demux_q_m =0;
		  control_counter_n = 1;
		  next_state = S6;
	      end
	      else
    	  begin
		  dut_ready_r = 0;
		  write_enable_output_sram = 0;
		  scratch_write_counter = 2;
	      R_add_sel = 2;
          write_enable_scratchpad = 0;
	      read_address_select_q_state = 2;
	      write_data_scratchpad = 0;
          write_data_output_sram = 0;
          multiplication_counter = 2;
		  control_counter_n = 2;
	      read_address_select_q_gates = 2;
          control_counter = 0;
	      write_address_select_output_sram = 2;
      	  write_address_select_scratchpad = 2;
	      read_address_select_scratchpad = 2;
	      SRAM_sel_mux = 1;
	      data_demux_q_m =0;
		  next_state = S9_before;
	       end
         end
	   S9_before:
	      begin
	      data_demux_q_m =0;
		  write_enable_output_sram = 0;
		  scratch_write_counter = 2;
          write_enable_scratchpad = 0;
	      read_address_select_q_gates = 2;
	      write_data_scratchpad = 0;
	      read_address_select_q_state = 2;
	      read_address_select_scratchpad = 2;
	      write_address_select_output_sram = 2;
		  control_counter_n = 2;
      	  write_address_select_scratchpad = 2;
	      SRAM_sel_mux = 1;
          write_data_output_sram = 0;
          control_counter = 0;
	      R_add_sel = 2;
		  dut_ready_r = 0;
          multiplication_counter = 2;
		  if(multiplication_counter_r < (M-1))
		  begin
		  read_address_select_q_gates = 2;
          control_counter = 0;
	      SRAM_sel_mux = 1;
		  dut_ready_r = 0;
          multiplication_counter = 2;
		  write_enable_output_sram = 0;
	      read_address_select_scratchpad = 2;
	      write_address_select_output_sram = 2;
	      read_address_select_q_state = 2;
	      data_demux_q_m =0;
          write_data_output_sram = 0;
	      write_enable_scratchpad = 1;
		  R_add_sel = 0;
	      write_data_scratchpad = 1;
      	  control_counter_n = 0;
      	  write_address_select_scratchpad = 2;
		  scratch_write_counter = 1;
		  next_state = S9;
		end
		else
			begin
		  write_enable_output_sram = 1;
		  dut_ready_r = 0;
	      read_address_select_q_state = 2;
          multiplication_counter = 2;
          control_counter = 0;
	      SRAM_sel_mux = 1;
		  read_address_select_q_gates = 2;
      	  write_address_select_scratchpad = 2;
          write_enable_scratchpad = 0;
	      read_address_select_scratchpad = 2;
		  R_add_sel = 0;
	      data_demux_q_m =0;
	      write_data_scratchpad = 0;
	      write_data_output_sram = 1;
		  scratch_write_counter = 2;
      	  control_counter_n = 0;
      	  write_address_select_output_sram = 2;
		  next_state = S10;
		end
	   end
	S9:begin
	      write_enable_q_state =0;
	      write_address_select_scratchpad = 1;
          write_enable_scratchpad = 1;
     	  dut_ready_r = 0;
	      read_address_select_q_state = 2;
          multiplication_counter = 2;
          write_data_output_sram = 0;
	      read_address_select_q_gates = 2;
		  write_enable_output_sram = 1;
          control_counter = 0;
	      read_address_select_scratchpad = 2;
		  control_counter_n = 2;
	      write_data_scratchpad = 0;
	      write_address_select_output_sram = 2;
	      SRAM_sel_mux = 1;
	      data_demux_q_m = 0;
	      R_add_sel = 0;
		  scratch_write_counter = 2;
		  if(scratch_write_counter_r < num_of_reads_from_q_state)
		  begin
	      read_address_select_scratchpad = 3;
	      SRAM_sel_mux = 1;
	      write_address_select_scratchpad = 1;
	      R_add_sel = 0;
		  control_counter_n = 2;
          control_counter = 0;
	      write_address_select_output_sram = 2;
          write_enable_scratchpad = 1;
	      write_data_scratchpad = 0;
          write_data_output_sram = 0;
	  	  scratch_write_counter = 2;
          multiplication_counter = 2;
	      read_address_select_q_gates = 2;
		  dut_ready_r = 0;
		  write_enable_output_sram = 0;
	      data_demux_q_m =0;
	      next_state = S6;
		 end
		 else
		 begin
		  read_address_select_scratchpad = 2;
		  dut_ready_r = 0;
		  write_enable_output_sram = 0;
	      SRAM_sel_mux = 1;
	      read_address_select_q_state = 0;
          write_enable_scratchpad = 1;
          write_data_output_sram = 0;
          control_counter = 0;
	      write_data_scratchpad = 0;
	      read_address_select_q_gates = 2;
	      data_demux_q_m =0;
	      write_address_select_output_sram = 2;
		  control_counter_n = 2;
	      R_add_sel = 0;
	      write_address_select_scratchpad = 1;
		  multiplication_counter = 1;
		  scratch_write_counter = 0;
		  next_state = S6;
	      end
           end
     S10:begin
	       write_enable_q_state =0;
	       write_address_select_output_sram = 1;
		   scratch_write_counter = 0;
	       write_enable_output_sram = 0;
	       read_address_select_scratchpad = 2;
           control_counter = 0;
           multiplication_counter = 2;
           write_data_output_sram = 1;
           write_enable_scratchpad = 0;
		   control_counter_n = 2;
      	   write_address_select_scratchpad = 2;
	       read_address_select_q_state = 0;
     	   dut_ready_r = 0;
	       read_address_select_q_gates = 2;
	        write_data_scratchpad = 0;
	        SRAM_sel_mux = 1;
	        data_demux_q_m = 0;
	        R_add_sel = 0;
	        if(q_state_output_sram_write_address<num_of_reads_from_q_state)
	        begin
	        read_address_select_scratchpad = 3;
	        R_add_sel = 0;
	        read_address_select_q_gates = 2;
      	    write_address_select_scratchpad = 2;
            write_data_output_sram = 1;
	   	    scratch_write_counter = 0;
            control_counter = 0;
	        write_address_select_output_sram = 1;
            multiplication_counter = 2;
			write_enable_output_sram = 0;
	        read_address_select_q_state = 0;
	        write_data_scratchpad = 0;
		    control_counter_n = 2;
            write_enable_scratchpad = 0;
	        SRAM_sel_mux = 1;
		    dut_ready_r = 0;
	      	data_demux_q_m =0;
		    next_state = S6;
	        end
	        else
	        begin
		    dut_ready_r = 1;
			write_enable_output_sram = 0;
		    scratch_write_counter = 0;
	        R_add_sel = 0;
	        read_address_select_q_state = 0;
            multiplication_counter = 2;
	        read_address_select_scratchpad = 2;
	        read_address_select_q_gates = 2;
            write_data_output_sram = 1;
	        write_data_scratchpad = 0;
	        write_address_select_output_sram = 1;
	 	    control_counter_n = 2;
            write_enable_scratchpad = 0;
            control_counter = 0;
      	    write_address_select_scratchpad = 2;
	        SRAM_sel_mux = 1;
	        data_demux_q_m =0;
		    next_state = S0;
	        end
          end
     default:begin
	        dut_ready_r =1;
		    scratch_write_counter = 0;
	        SRAM_sel_mux = 0;
			write_enable_output_sram = 0;
		    control_counter_n = 2;
	        read_address_select_q_gates = 2;
	        write_address_select_output_sram = 0;
	        read_address_select_scratchpad = 2;
            write_data_output_sram = 0;
	        read_address_select_q_state = 0;
            multiplication_counter = 2;
            write_enable_scratchpad = 0;
	        write_data_scratchpad = 0;
            control_counter = 0;
	        R_add_sel = 0;
	        data_demux_q_m = 0;
       	    write_address_select_scratchpad = 2;
		    next_state = S0;
	        end
       endcase
	end

always@(posedge clk)
begin
	casex(scratch_write_counter)
	0: scratch_write_counter_r <= 0;
	1: scratch_write_counter_r <= scratch_write_counter_r+1;
	2: scratch_write_counter_r <= scratch_write_counter_r;
	default: scratch_write_counter_r <= 0;
endcase
end

always@(posedge clk)
begin
	casex(multiplication_counter)
	0: multiplication_counter_r <= 0;
	1: multiplication_counter_r <= multiplication_counter_r+1;
	2: multiplication_counter_r <= multiplication_counter_r;
	default: multiplication_counter_r <= 0;
endcase
end
always@(posedge clk)
begin
casex(control_counter)
		    0: control_counter_r <= 0;
		    1: control_counter_r <= control_counter_r + 1;
		    2: control_counter_r <= control_counter_r;
		    default: control_counter_r <= 0;
endcase
end
always@(posedge clk)
begin
casex(control_counter_n)
		    0: control_counter_n_r <= 0;
		    1: control_counter_n_r <= control_counter_n_r + 1;
		    2: control_counter_n_r <= control_counter_n_r;
		    default: control_counter_n_r <= 0;
endcase
end

assign q_state_input_sram_read_address = q_state_input_sram_read_address_r;
always @(posedge clk) 
begin
	casex(read_address_select_q_state)
		0:		begin
				q_state_input_sram_read_address_r <= 0;
				q_state_reset_counter <= 0;
				end
		1:		 begin
				 q_state_input_sram_read_address_r <= q_state_input_sram_read_address_r + 1;
				 q_state_reset_counter <= q_state_reset_counter + 1;
     				 end
		2:		begin
				q_state_input_sram_read_address_r <= q_state_input_sram_read_address_r;
				q_state_reset_counter <= q_state_reset_counter;
				end
		3:		begin
				q_state_input_sram_read_address_r <= 1;
				q_state_reset_counter <= 1;
				end
		default:		begin
				q_state_input_sram_read_address_r <= 0;
				q_state_reset_counter <= 0;
				end

			endcase


end
assign scratchpad_sram_read_address = scratchpad_sram_read_address_r;
always @(posedge clk) 
begin
	casex(read_address_select_scratchpad)
		0:		begin
				scratchpad_sram_read_address_r <= 0;
				end
		1:		begin
				 scratchpad_sram_read_address_r <= scratchpad_sram_read_address_r + 1;
     			end
		2:		begin
				scratchpad_sram_read_address_r <= scratchpad_sram_read_address_r;
				end
		3:     begin
			   scratchpad_sram_read_address_r <= scratchpad_sram_read_address_r - num_of_reads_from_q_state;
		        end
		default:		begin
				scratchpad_sram_read_address_r <= 0;
				end

			endcase
		end


assign q_gates_sram_read_address = q_gates_sram_read_address_r;
always @(posedge clk) 
begin
	casex(read_address_select_q_gates)
			
			0:      begin
				q_gates_sram_read_address_r <= 0;
				q_gate_hold_counter <= 0;
				end
			1:
     				begin
				q_gates_sram_read_address_r <= q_gates_sram_read_address_r + 1;
				q_gate_hold_counter <= q_gate_hold_counter + 1;
     				end
			2:
				begin
				q_gates_sram_read_address_r <= q_gates_sram_read_address_r;
				q_gate_hold_counter <= q_gate_hold_counter;
				end
			default:      begin
				q_gates_sram_read_address_r <= 0;
				q_gate_hold_counter <= 0;
				end
			endcase
end

           assign read_data_q_state = SRAM_sel_mux ? scratchpad_sram_read_data : q_state_input_sram_read_data;

	   assign R_q_gate = q_gates_sram_read_data[127:64];
	   assign I_q_gate = q_gates_sram_read_data[63:0];
		
  	   always @(posedge clk) begin
  	   	casex (data_demux_q_m)
  	   		0: begin
  	   			Q <= Q;
  	   			M <= M;
  	   			num_of_reads_from_q_state <= (1<<Q);
  	   	        end
  
  	   		1: begin
  	   			Q <= read_data_q_state[127:64];
  	   			M <= read_data_q_state[63:0];
  	   			num_of_reads_from_q_state <= (1<<Q);
  	   		end
			default:begin
				Q<=0;
				M<=0;
  	   			num_of_reads_from_q_state <= 0;
			end

  	   	endcase
  	   end

	  assign R_q_state = read_data_q_state[127:64];
	  assign I_q_state = read_data_q_state[63:0];

	  assign q_state_input_sram_write_enable = 0;
	 assign  q_gates_sram_write_enable  = 0;
	  assign q_state_output_sram_write_enable = q_state_output_sram_write_enable_r;
	  always@(posedge clk) begin
	  	casex (write_enable_output_sram)
	  		0: begin
	  			q_state_output_sram_write_enable_r<= 0;
	  		end
	  		1: begin
	  			q_state_output_sram_write_enable_r <= 1;
	  		end
	  		default: begin
	  			q_state_output_sram_write_enable_r <= 0;
	  		end
	  	endcase
	  end
	 assign scratchpad_sram_write_enable = write_enable_scratchpad ?1:0;
	 assign scratchpad_sram_write_address = scratchpad_sram_write_address_r;
	 assign scratchpad_sram_write_data = scratchpad_sram_write_data_r;
	 always@(posedge clk) begin
	 	casex(write_address_select_scratchpad)
	 		0:begin
	 			scratchpad_sram_write_address_r <= 0;
	 		end
	 		1:
	 		begin
	 			scratchpad_sram_write_address_r <= scratchpad_sram_write_address_r +1;
	 		end
			2:begin
				scratchpad_sram_write_address_r <= scratchpad_sram_write_address_r;
			end	
	 		default:begin
	 			scratchpad_sram_write_address_r <= 0;
	 		end
	 	endcase
	 end
	 always@(posedge clk) begin
		 casex(write_data_scratchpad)
			 0:begin
				 scratchpad_sram_write_data_r <= 0;
			 end
			 1:begin
				 scratchpad_sram_write_data_r[127:64] <= R_total;
				 scratchpad_sram_write_data_r[63:0] <= I_total;
			 end
			 default:begin
				 scratchpad_sram_write_data_r <= 0;
			 end
		 endcase
	 end
	assign q_state_output_sram_write_address = q_state_output_sram_write_address_r;
	assign q_state_output_sram_write_data = q_state_output_sram_write_data_r;
	 always@(posedge clk) begin
	 	casex(write_address_select_output_sram)
	 		0:begin
	 			q_state_output_sram_write_address_r <= 0;
	 		end
	 		1:
	 		begin
	 			q_state_output_sram_write_address_r <= q_state_output_sram_write_address_r +1;
	 		end
			2:begin
				q_state_output_sram_write_address_r <= q_state_output_sram_write_address_r;
			end	
	 		default:begin
	 			q_state_output_sram_write_address_r <= 0;
	 		end
	 	endcase
	 end
	 always@(posedge clk) begin
		 casex(write_data_output_sram)
			 0:begin
				 q_state_output_sram_write_data_r <= 0;
			 end
			 1:begin
				 q_state_output_sram_write_data_r[127:64] <= R_total;
				 q_state_output_sram_write_data_r[63:0] <= I_total;
			 end
			 default:begin
				 q_state_output_sram_write_data_r <= 0;
			 end
		 endcase
	 end

	 always@(posedge clk) begin
		 casex (R_add_sel)
			 0: R_total <= 0;
			 1: R_total <= r_total;
			 2: R_total <= R_total;
			 default : R_total <=0;

		 endcase
	 end
	 always@(posedge clk) begin
		 casex (R_add_sel)
			 0: I_total <= 0;
			 1: I_total <= i_total;
			 2: I_total <= I_total;
			 default : I_total <=0;
		 endcase
	 end


	assign I_before_add = zc;
	assign R_before_add = za;		 
	assign Z_r_d = zd;
 	assign neg_Z_r_b = {~zb[63],zb[62:0]};



  DW_fp_mac_inst FP_MAC1 ( 
    .inst_a(R_q_state),
    .inst_b(R_q_gate),
    .inst_c(neg_Z_r_b),
    .inst_rnd (3'd0),
    .z_inst(za),
    .status_inst (status1)
  );

  DW_fp_mac_inst FP_MAC3 ( 
    .inst_a(R_q_state),
    .inst_b(I_q_gate),
    .inst_c(Z_r_d),
    .inst_rnd(3'd0),
    .z_inst(zc),
    .status_inst (status2)
  );
 
      DW_fp_add  #(
      .sig_width        (52),
      .exp_width        (11),
      .ieee_compliance  (1)
   ) fp_add_mod1 (
     .a                (R_before_add),
     .b                (R_total),
     .rnd              (3'd0),
     .z                (r_total),
     .status           (status3));

      DW_fp_add  #(
      .sig_width        (52),
      .exp_width        (11),
      .ieee_compliance  (1)
    ) fp_add_mod2 (
      .a                (I_before_add),
      .b                (I_total),
      .rnd              (3'd0),
      .z                (i_total),
      .status           (status4));

       DW_fp_mac_inst   FP_MAC2 (
       .inst_a                (I_q_state),
       .inst_b                (I_q_gate),
       .inst_rnd              (3'd0),
	   .inst_c                (64'b0),
       .z_inst                (zb),
       .status_inst           (status5));
 
 
       DW_fp_mac_inst  FP_MAC4 (
       .inst_a               (I_q_state),
       .inst_b                (R_q_gate),
	   .inst_c                (64'b0),
       .inst_rnd              (3'd0),
       .z_inst                (zd),
       .status_inst           (status6));
	   
////synopsys translate_off
//  real real_R_q_state;
//  assign real_R_q_state = $bitstoreal(R_q_state);
//  real real_I_q_state;
//  assign real_I_q_state = $bitstoreal(I_q_state);
//  real real_R_q_gate;
//  assign real_R_q_gate = $bitstoreal(R_q_gate);
//  real real_I_q_gate;
//  assign real_I_q_gate = $bitstoreal(I_q_gate);
//  real real_zb;
//  assign real_zb = $bitstoreal(zb);
//  real real_za;
//  assign real_za = $bitstoreal(za);
//  real real_zc;
//  assign real_zc = $bitstoreal(zc);
//  real real_zd;
//  assign real_zd = $bitstoreal(zd);
//  real real_r_total;
//  assign real_r_total = $bitstoreal(r_total);
//  real real_i_total;
//  assign real_i_total = $bitstoreal(i_total);
//  real real_R_total;
//  assign real_R_total = $bitstoreal(R_total);
//  real real_I_total;
//  assign real_I_total = $bitstoreal(I_total);
//  real real_R_before_add;
//  assign real_R_before_add = $bitstoreal(R_before_add);
//  real real_I_before_add;
//  assign real_I_before_add = $bitstoreal(I_before_add);
////synopsys translate_on  
  
endmodule


module DW_fp_mac_inst #(
  parameter inst_sig_width = 52,
  parameter inst_exp_width = 11,
  parameter inst_ieee_compliance = 1 // These need to be fixed to decrease error
) ( 
  input wire [inst_sig_width+inst_exp_width : 0] inst_a,
  input wire [inst_sig_width+inst_exp_width : 0] inst_b,
  input wire [inst_sig_width+inst_exp_width : 0] inst_c,
  input wire [2 : 0] inst_rnd,
  output wire [inst_sig_width+inst_exp_width : 0] z_inst,
  output wire [7 : 0] status_inst
);

  // Instance of DW_fp_mac
  DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U1 (
    .a(inst_a),
    .b(inst_b),
    .c(inst_c),
    .rnd(inst_rnd),
    .z(z_inst),
    .status(status_inst) 
  );
  
endmodule
