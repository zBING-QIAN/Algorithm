`ifndef TRANS_DEFINE
`define TRANS_DEFINE 

import "DPI-C" function gencase(
  inout int a[],
  inout int b[]
);
class NTT_TRX #(
    parameter int DEPTH = 256
);
  int a[DEPTH], res[DEPTH];
endclass


class CONV_TRX #(
    parameter int DEPTH = 256
);
  int a[DEPTH], b[DEPTH], res[DEPTH], a_res[DEPTH], b_res[DEPTH];
  string file_name, line;
  int fd, i;
  function random();
    gencase(a, b);
    // for (int i = 0; i < DEPTH; i++) begin
    //   $display("a[%d] = %d", i, a[i]);
    // end
  endfunction
endclass


`endif
