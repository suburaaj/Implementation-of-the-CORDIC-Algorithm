`timescale 1 ns/100 ps

module CORDIC (clock, angle, Xin, Yin, Xout, Yout);
   
   parameter XY_SZ = 16;   
   
   localparam STG = XY_SZ; 
   
   input                      clock;
   input  signed       [31:0] angle;
   input  signed  [XY_SZ-1:0] Xin;
   input  signed  [XY_SZ-1:0] Yin;
   output signed    [XY_SZ:0] Xout;
   output signed    [XY_SZ:0] Yout;
   wire signed [XY_SZ:0] X [0:STG-1];
   wire signed [XY_SZ:0] Y [0:STG-1];
   wire signed    [31:0] Z [0:STG-1]; 
   
   wire  signed [1:0] quadrant;
   assign   quadrant = angle[31:30];
   reg signed [16:0] temp_xin;
   reg signed [16:0] temp_yin;
   reg signed [31:0] temp_z;
   always @(posedge clock)
   begin 
      case (quadrant)
         2'b00,
         2'b11:   
         begin    
            temp_xin  <= Xin;
            temp_yin <= Yin;
            temp_z <= angle;
         end
         
         2'b01:
         begin
          temp_xin <= -Yin;
            temp_yin <= Xin;
         temp_z <= {2'b00,angle[29:0]}; 
         end
         
         2'b10:
         begin
            temp_xin <= Yin;
            temp_yin <= -Xin;
           temp_z <= {2'b11,angle[29:0]}; 
         end
         
      endcase
   end
    assign X[0] = temp_xin;
    assign Y[0] = temp_yin;
  
    assign Z[0] = temp_z;
   
   
   genvar i;

   generate
   for (i=0; i < (STG-1); i=i+1)
   begin: XYZ
   
     
      sub c1(.clock(clock),.x_in(X[i]),.y_in(Y[i]),.angle_in(Z[i]),.k(i),.angle_out(Z[i+1]),.x_out(X[i+1]),.y_out(Y[i+1]));
   end
   endgenerate
     
   assign Xout = X[STG-1];
   assign Yout = Y[STG-1];

endmodule









module sub(clock,angle_in,x_in,y_in,k,angle_out,x_out,y_out);
input clock;
input [3:0]k;
input signed [16:0] x_in;
input signed[16:0] y_in;
input signed [31:0] angle_in;
output  signed [16:0] x_out;
output  signed[16:0] y_out;
output  signed [31:0]angle_out;

reg signed[16:0] temp_x_out;
reg signed[16:0] temp_y_out;
reg signed[31:0] temp_angle_out;


assign x_out=temp_x_out;
assign y_out=temp_y_out;
assign angle_out=temp_angle_out;


wire signed [31:0] atan_table [0:30];

    
   
   assign atan_table[00] = 32'b00100000000000000000000000000000;
   assign atan_table[01] = 32'b00010010111001000000010100011101; 
   assign atan_table[02] = 32'b00001001111110110011100001011011; 
   assign atan_table[03] = 32'b00000101000100010001000111010100; 
   assign atan_table[04] = 32'b00000010100010110000110101000011;
   assign atan_table[05] = 32'b00000001010001011101011111100001;
   assign atan_table[06] = 32'b00000000101000101111011000011110;
   assign atan_table[07] = 32'b00000000010100010111110001010101;
   assign atan_table[08] = 32'b00000000001010001011111001010011;
   assign atan_table[09] = 32'b00000000000101000101111100101110;
   assign atan_table[10] = 32'b00000000000010100010111110011000;
   assign atan_table[11] = 32'b00000000000001010001011111001100;
   assign atan_table[12] = 32'b00000000000000101000101111100110;
   assign atan_table[13] = 32'b00000000000000010100010111110011;
   assign atan_table[14] = 32'b00000000000000001010001011111001;
   assign atan_table[15] = 32'b00000000000000000101000101111101;
   assign atan_table[16] = 32'b00000000000000000010100010111110;
   assign atan_table[17] = 32'b00000000000000000001010001011111;
   assign atan_table[18] = 32'b00000000000000000000101000101111;
   assign atan_table[19] = 32'b00000000000000000000010100011000;
   assign atan_table[20] = 32'b00000000000000000000001010001100;
   assign atan_table[21] = 32'b00000000000000000000000101000110;
   assign atan_table[22] = 32'b00000000000000000000000010100011;
   assign atan_table[23] = 32'b00000000000000000000000001010001;
   assign atan_table[24] = 32'b00000000000000000000000000101000;
   assign atan_table[25] = 32'b00000000000000000000000000010100;
   assign atan_table[26] = 32'b00000000000000000000000000001010;
   assign atan_table[27] = 32'b00000000000000000000000000000101;
   assign atan_table[28] = 32'b00000000000000000000000000000010;
   assign atan_table[29] = 32'b00000000000000000000000000000001; 
   assign atan_table[30] = 32'b00000000000000000000000000000000;
   
   
      wire                   Z_sign;
      wire signed  [16:0] X_shr, Y_shr; 
   
      assign X_shr = x_in >>> k; 
      assign Y_shr = y_in >>> k;
   
     
      assign Z_sign = angle_in[31]; 
   
      always @(posedge clock)
      begin
         
      temp_x_out     <= Z_sign ? x_in + Y_shr                    : x_in - Y_shr;
      temp_y_out     <= Z_sign ? y_in - X_shr                   : y_in + X_shr;
      temp_angle_out <= Z_sign ? angle_in + atan_table[k]       : angle_in - atan_table[k];
      end
	  endmodule




