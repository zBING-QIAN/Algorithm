`ifndef AUXIF
`define AUXIF 
// memory_if for tb
interface memory_if #(
    parameter int DEPTH = 256,
    parameter int SIZE  = 20
) (
    input logic clk,
    input logic rst
);
  logic [$clog2(DEPTH)-1:0] addr_r;
  logic [$clog2(DEPTH)-1:0] addr_w;
  logic WE;
  logic RE;
  logic [SIZE-1:0] D;
  logic [SIZE-1:0] Q;
  logic valid;
  // delay for tb
  clocking scb @(posedge clk);
    default output #5;
    input addr_w;
    input addr_r;
    input D;
    input WE;
    input RE;
    output valid;
    output Q;
  endclocking
  // DUT control memory
  modport MASTER(input clk, rst, Q, valid, output addr_r, addr_w, D, WE, RE);

endinterface

// DUT interconnection
interface memory_linker_if #(
    parameter int DEPTH = 256,
    parameter int SIZE  = 20
) (
    input logic clk,
    input logic rst
);
  logic [$clog2(DEPTH)-1:0] addr_r;
  logic [$clog2(DEPTH)-1:0] addr_w;
  logic WE;
  logic RE;
  logic [SIZE-1:0] D;
  logic [SIZE-1:0] Q;
  logic valid;
  modport MASTER(input clk, rst, Q, valid, output addr_r, addr_w, D, WE, RE);

endinterface

// simple RAM with Delay
class RAM_OBJ #(
    parameter int DEPTH,
    parameter int SIZE,
    parameter int DELAY_CYCLE = 1
);
  virtual memory_if #(
      .DEPTH(DEPTH),
      .SIZE (SIZE)
  ) vif;
  // int DEPTH,SIZE;
  int fd;
  string file_name;
  int case_end;
  reg [SIZE-1:0] latched_V[DELAY_CYCLE+1];
  reg latched_valid[DELAY_CYCLE+1];
  reg [SIZE-1:0] memory[DEPTH];

  event case_done;


  function new(
  virtual memory_if #(
      .DEPTH(DEPTH),
      .SIZE (SIZE)
  ) vif,
  event case_done,
               string file_name = "");
    assert (DEPTH == vif.DEPTH && SIZE == vif.SIZE);
    this.case_done = case_done;
    this.vif = vif;
    if (file_name.len() > 0) begin
      this.file_name = file_name;
      this.fd = $fopen(file_name, "r");
      if (this.fd == 0) begin
        $display("Failed open %s", file_name);
        $finish;
      end
    end else this.fd = 0;
    for (int i = 0; i < DELAY_CYCLE; i++) begin
      latched_V[i] = 0;
      latched_valid[i] = 0;
    end
  endfunction  //new()

  task automatic reset();
    for (int i = 0; i < DEPTH; i++) begin
      memory[i] = 0;
      for (int i = 0; i <= DELAY_CYCLE; i++) latched_V[i] = 0;
    end
    case_end = 0;
  endtask
  virtual task load_data();
    reset();
  endtask
  virtual task run();
    load_data();
    fork
      while (case_end == 0)
      @(posedge vif.clk) begin
        if (vif.rst == 0) begin

          if (vif.scb.WE) begin
            memory[vif.scb.addr_w] = vif.scb.D;
          end
          latched_V[DELAY_CYCLE] = memory[vif.scb.addr_r];
          latched_valid[DELAY_CYCLE] = vif.scb.RE;

          if (DELAY_CYCLE > 0)
            for (int i = 0; i < DELAY_CYCLE; i++) begin
              latched_V[i] = latched_V[i+1];
              latched_valid[i] = latched_valid[i+1];
            end
          // clocking block
          vif.scb.valid <= latched_valid[0];
          vif.scb.Q <= latched_V[0];
        end
      end
      begin
        wait (case_done.triggered);
        case_end = 1;
      end
    join_none
  endtask

  virtual function destructor();  // Ensure files are closed
    $display("release file");
    if (this.fd) begin
      $fclose(this.fd);
      $display("release file");
    end
  endfunction
endclass

`endif
