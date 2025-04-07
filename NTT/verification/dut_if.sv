`ifndef DUTIF
`define DUTIF 
interface conv_if (
    input logic clk
);
  logic rst;
  logic done, enable;
  clocking cbd @(posedge clk);
    input done;
    output enable, rst;
  endclocking
  modport DUT(input clk, rst, enable, output done);
endinterface

interface ntt_if (
    input logic clk,
    input logic rst
);
  logic done, enable, busy;
  // modport MASTER(input clk, done, output rst, enable);
  modport DUT(input clk, rst, enable, output done, busy);
endinterface
`endif
