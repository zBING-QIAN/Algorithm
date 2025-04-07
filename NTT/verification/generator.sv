`ifndef GEN_DEFINE
`define GEN_DEFINE 
`include "./verification/transaction.sv"

class generator #(
    parameter int DEPTH
);
  CONV_TRX #(.DEPTH(DEPTH)) trans;
  mailbox gen2drv;
  int case_num, case_i;
  event case_done;
  function new(mailbox gen2drv, int case_num, event case_done);
    this.gen2drv = gen2drv;
    this.case_num = case_num;
    this.case_i = 0;
    this.case_done = case_done;
  endfunction

  virtual task automatic main();
    trans = new();

    while (case_i < case_num) begin

      $display("gen trans");

      // trans.randomize();
      trans.random();  //write my own randomize dut to no license
      case_i++;


      $display("gen send trans");

      gen2drv.put(trans);

      $display("gen wait case done");
      @(case_done);
    end
  endtask  //automatic

endclass
`endif
