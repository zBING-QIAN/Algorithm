`ifndef DRV_DEFINE
`define DRV_DEFINE 
`include "./verification/transaction.sv"
`include "./verification/dut_if.sv"
`include "./verification/aux_if.sv"

class driver #(
    parameter int DEPTH,
    parameter int SIZE,
    parameter int MOD
);
  mailbox gen2drv, drv2scb_conv, drv2scb_ntt;
  CONV_TRX #(.DEPTH(DEPTH)) trans;
  NTT_TRX #(.DEPTH(DEPTH)) trans_ntt;
  event case_done;
  int case_num, case_i;
  virtual conv_if conv_vif;
  virtual ntt_if ntt_vif;
  RAM_OBJ #(
      .DEPTH(DEPTH),
      .SIZE (SIZE)
  )
      a, b, res;


  function new(virtual conv_if conv_vif, virtual ntt_if ntt_vif,
               RAM_OBJ#(
                   .DEPTH(DEPTH),
                   .SIZE (SIZE)
               ) a,
               RAM_OBJ#(
                   .DEPTH(DEPTH),
                   .SIZE (SIZE)
               ) b,
               RAM_OBJ#(
                   .DEPTH(DEPTH),
                   .SIZE (SIZE)
               ) res,
               mailbox gen2drv,
               mailbox drv2scb_conv,
               mailbox drv2scb_ntt, int case_num, event case_done);
    this.a = a;
    this.b = b;
    this.res = res;
    this.conv_vif = conv_vif;
    this.ntt_vif = ntt_vif;
    this.gen2drv = gen2drv;
    this.drv2scb_conv = drv2scb_conv;
    this.drv2scb_ntt = drv2scb_ntt;
    this.case_done = case_done;
    this.case_num = case_num;
    this.case_i = 0;
  endfunction

  task reset();
    conv_vif.rst = 1;
    fork
      a.run();
      b.run();
      res.run();
    join_none
    repeat (5) @(posedge conv_vif.clk);

    for (int i = 0; i < DEPTH; i++) begin
      a.memory[i] = trans.a[i];
      b.memory[i] = trans.b[i];
    end
    conv_vif.rst = 0;
    conv_vif.enable = 1;
    @(posedge conv_vif.clk);
    conv_vif.enable = 0;
  endtask
  int tmpcnt = 0;
  task automatic main();
    trans_ntt = new();
    trans = new();
    while (case_num > case_i) begin
      case_i = case_i + 1;
      $display("case :%d / %d", case_i, case_num);
      $display("driver case :%d get trans", case_i);
      gen2drv.get(trans);
      reset();
      $display("driver get trans and wait ntt done");
      // check a ntt
      @(posedge ntt_vif.done);
      for (int i = 0; i < DEPTH; i++) trans_ntt.a[i] = trans.a[i];
      for (int i = 0; i < DEPTH; i++) trans_ntt.res[i] = a.memory[i];
      drv2scb_ntt.put(trans_ntt);
      // check b ntt
      @(posedge ntt_vif.done);
      for (int i = 0; i < DEPTH; i++) trans_ntt.a[i] = trans.b[i];
      for (int i = 0; i < DEPTH; i++) trans_ntt.res[i] = b.memory[i];
      drv2scb_ntt.put(trans_ntt);

      // INNT
      @(posedge ntt_vif.done);
      for (int i = 0; i < DEPTH; i++) trans_ntt.a[i] = (a.memory[i] * b.memory[i]) % MOD;
      for (int i = 0; i < DEPTH; i++) trans_ntt.res[i] = res.memory[i];
      drv2scb_ntt.put(trans_ntt);


      @(posedge conv_vif.done);
      for (int i = 0; i < DEPTH; i++) begin
        trans.res[i]   = res.memory[i];
        trans.a_res[i] = a.memory[i];
        trans.b_res[i] = b.memory[i];
        // $display("a[%d] = %d", i, trans.a[i]);
      end

      @(posedge ntt_vif.clk);
      drv2scb_conv.put(trans);
      wait (case_done.triggered);
      @(posedge ntt_vif.clk);
    end
    $display("ALL PASS");
    $finish;
  endtask  //automatic
endclass



`endif
