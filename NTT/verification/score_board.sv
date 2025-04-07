`ifndef SCBCONV_DEFINE
`define SCBCONV_DEFINE 
`include "./verification/transaction.sv"
import "DPI-C" function bit SW_CONV_check(
  input int a[],
  input int b[],
  input int a_res[],
  input int b_res[],
  input int res[]
);

class score_board #(
    parameter int DEPTH
);
  mailbox drv2scb;
  CONV_TRX #(.DEPTH(DEPTH)) trans;
  event conv_pass;
  function new(mailbox drv2scb, event conv_pass);
    this.drv2scb   = drv2scb;
    this.conv_pass = conv_pass;
  endfunction
  function bit verify();
    return SW_CONV_check(trans.a, trans.b, trans.a_res, trans.b_res, trans.res);
  endfunction
  task main();
    while (1) begin
      // $display("scoreboard wait result");
      drv2scb.get(trans);
      $display("scoreboard CONV get result");
      if (!verify()) begin
        $error("CONV fail");
        $finish;
      end else begin
        $display("CONV pass");
        ->conv_pass;
      end
    end

  endtask

endclass
`endif
