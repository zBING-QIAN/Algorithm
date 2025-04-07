
`ifndef ENV_DEFINE
`define ENV_DEFINE 
`include "./verification/driver.sv"
`include "./verification/score_board.sv"
`include "./verification/score_board_NTT.sv"
`include "./verification/generator.sv"
`include "./verification/transaction.sv"
`include "./verification/dut_if.sv"
`include "./verification/aux_if.sv"


class environment #(
    parameter int DEPTH,
    parameter int SIZE,
    parameter int MOD

);
  driver #(
      .DEPTH(DEPTH),
      .SIZE (SIZE),
      .MOD  (MOD)
  ) drv;
  generator #(.DEPTH(DEPTH)) gen;
  score_board #(.DEPTH(DEPTH)) scb;
  score_board_NTT #(.DEPTH(DEPTH)) scb_ntt;
  mailbox gen2drv = new(), drv2scb_conv = new(), drv2scb_ntt = new();
  event case_done;
  int case_num;
  virtual conv_if conv_vif;
  virtual ntt_if ntt_vif;
  RAM_OBJ #(
      .DEPTH(DEPTH),
      .SIZE (SIZE)
  )
      a, b, res;
  function new(int case_num, virtual conv_if conv_vif, virtual ntt_if ntt_vif,
               virtual memory_if #(
                   .DEPTH(DEPTH),
                   .SIZE (SIZE)
               ) a_vif,
               virtual memory_if #(
                   .DEPTH(DEPTH),
                   .SIZE (SIZE)
               ) b_vif,
               virtual memory_if #(
                   .DEPTH(DEPTH),
                   .SIZE (SIZE)
               ) res_vif);
    this.case_num = case_num;
    this.gen = new(this.gen2drv, case_num, case_done);
    this.scb = new(this.drv2scb_conv, case_done);
    this.scb_ntt = new(this.drv2scb_ntt);

    a = new(a_vif, case_done, "");
    b = new(b_vif, case_done, "");
    res = new(res_vif, case_done, "");

    this.drv =
        new(conv_vif, ntt_vif, a, b, res, gen2drv, drv2scb_conv, drv2scb_ntt, case_num, case_done);
  endfunction  //new()
  virtual task automatic run();
    fork

      gen.main();
      drv.main();
      scb.main();
      scb_ntt.main();
    join
  endtask  //automatic


endclass  //environment
`endif
