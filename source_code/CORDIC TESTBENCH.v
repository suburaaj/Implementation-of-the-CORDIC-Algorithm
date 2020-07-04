`timescale 1 ns/100 ps
module CORDIC_TESTBENCH;

  localparam width = 16; //width of x and y

  // Inputs
  reg signed[width-1:0] Xin, Yin;
  reg signed[31:0] angle;
  reg clk;
  reg signed  [63:0] i;
wire signed [width-1:0] COSout, SINout;

  localparam An = 32000/1.647;

  initial 
  begin

    //set initial values
    angle = 32'b0;
    Xin = An;     // Xout = 32000*cos(angle)
    Yin = 0;      // Yout = 32000*sin(angle)

    //set clock
    clk = 'b0;
  end
    
      always
      #5 clk = ~clk;
    

    initial
    begin
      #500
         
         for (i = 0; i <= 360; i = i + 1)     
       begin
      angle = ((1 << 32)*i)/360;
      #200
      $display ("angle = %d, xout = %d, yout = %d",i, COSout, SINout);
    end

  
   #200 $write("Simulation has finished");
   $stop;

  end

  CORDIC s1(.clock(clk),.angle(angle),.Xin(Xin),.Yin(Yin),.Xout(COSout),.Yout(SINout));

  // Monitor the output
  
endmodule

