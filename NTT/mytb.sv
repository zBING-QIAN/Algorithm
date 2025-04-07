`timescale 1ns / 10ps
`define CYCLE_TIME 20
`define MAX_CYCLE 150000

`include "./verification/environment.sv"
`include "./verification/dut_if.sv"
`include "./verification/aux_if.sv"
`include "conv.sv"

module mytb #(
    parameter int DEPTH = 256,
    parameter int SIZE = 20,
    parameter int PRIMITIVEROOT = 3,
    parameter int MOD = 257,
    parameter int NINV = 256

    // parameter int DEPTH = 256,
    // parameter int SIZE = 64,
    // parameter int PRIMITIVEROOT = 11,
    // parameter int MOD = 12289,
    // parameter int NINV = 12241

);
  reg clk;
  environment #(
      .DEPTH(DEPTH),
      .SIZE (SIZE),
      .MOD  (MOD)
  ) env;
  conv_if convif (.clk(clk));
  memory_if #(
      .DEPTH(DEPTH),
      .SIZE (SIZE)
  ) a_if (
      .clk(clk),
      .rst(convif.rst)
  );
  memory_if #(
      .DEPTH(DEPTH),
      .SIZE (SIZE)
  ) b_if (
      .clk(clk),
      .rst(convif.rst)
  );
  memory_if #(
      .DEPTH(DEPTH),
      .SIZE (SIZE)
  ) res_if (
      .clk(clk),
      .rst(convif.rst)
  );
  conv #(
      .DEPTH(DEPTH),
      .SIZE(SIZE),
      .MOD(MOD),
      .PRIMITIVEROOT(PRIMITIVEROOT),
      .NINV(NINV)
  ) u_conv (
      .convif(convif.DUT),
      .a_if  (a_if.MASTER),
      .b_if  (b_if.MASTER),
      .res_if(res_if.MASTER)
  );
  always begin
    #(`CYCLE_TIME / 2) clk = ~clk;
  end

  initial begin
    clk = 0;
    env = new(3, convif, u_conv.nttif, a_if, b_if, res_if);
    $display("start simulation");
    env.run();
  end
endmodule
