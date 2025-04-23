//~ `New testbench
`timescale  1ns / 1ps

module tb_CPU;

// CPU Parameters
parameter PERIOD  = 10;


// CPU Inputs
logic clk                            = 0 ;
logic rst_n                          = 0 ;

// CPU Outputs



initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

CPU  u_CPU (
    .clk               (clk     ),
    .rst_n             (rst_n   )
);

initial
begin

    #(PERIOD*50) $finish;
end

endmodule