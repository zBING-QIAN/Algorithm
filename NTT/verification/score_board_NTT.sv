`ifndef SCBNTT_DEFINE
`define SCBNTT_DEFINE 
`include "./verification/transaction.sv"
import "DPI-C" function bit SW_NTT_check(
  input int arr[],
  input int res[]
);
class score_board_NTT #(
    parameter int DEPTH
);
  mailbox drv2scb;
  NTT_TRX #(.DEPTH(DEPTH)) trans;
  function new(mailbox drv2scb);
    this.drv2scb = drv2scb;
  endfunction
  int i;
  function verify();
    return SW_NTT_check(trans.a, trans.res);
  endfunction
  task main();
    while (1) begin
      // $display("scoreboard wait result");
      drv2scb.get(trans);
      $display("scoreboard NTT get result");

      if (!verify()) begin
        $error("NTT fail");
        $finish;
      end else begin
        $display("NTT pass");
      end
    end

  endtask

endclass
`endif
