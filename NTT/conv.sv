
`include "./verification/dut_if.sv"
`include "./verification/aux_if.sv"
`include "./ntt.sv"
module conv #(
    parameter int DEPTH,
    parameter int SIZE,
    parameter int MOD,
    parameter int PRIMITIVEROOT,
    parameter int NINV
) (
    conv_if   convif,
    memory_if a_if,
    memory_if b_if,
    memory_if res_if
);

  localparam logic[3:0] IDLE = 0, NTTA = 1, NTTB = 2,
DOTPRODUCT = 3, NTTRES = 4, REVERSE = 5, DONE = 6;
  localparam logic [3:0] REVR = 0, REVWAIT = 1, REVW = 2;

  reg [1:0] product_state;

  localparam logic [1:0] PRODUCTINIT = 0, PRODUCTREAD = 1, PRODUCTWRITE = 2, PRODUCTDONE = 3;
  memory_linker_if #(
      .DEPTH(DEPTH),
      .SIZE (SIZE)
  ) ntt_memif (
      .clk(convif.clk),
      .rst(convif.rst)
  );
  ntt_if nttif (
      .clk(convif.clk),
      .rst(convif.rst)
  );

  ntt #(
      .DEPTH(DEPTH),
      .SIZE(SIZE),
      .MOD(MOD),
      .PRIMITIVEROOT(PRIMITIVEROOT)
  ) u_ntt (
      .nttif(nttif.DUT),
      .memif(ntt_memif.MASTER)
  );
  reg [3:0] cur_state, nxt_state, cur_rev;
  reg [$clog2(DEPTH):0] product_idx, product_idx_w, reverse_idx, reverse_idx_0, reverse_idx_1;

  reg prod_WE, prod_RE, rev_RE, rev_WE, rcnt, ntt_en;
  reg [SIZE-1:0] prod_res, rev_0, rev_1, rev_D;
  always_comb begin
    case (cur_state)
      IDLE: begin
        if (convif.enable) nxt_state = NTTA;
        else nxt_state = IDLE;
      end
      NTTA: begin
        if (nttif.done) nxt_state = NTTB;
        else nxt_state = NTTA;
      end
      NTTB: begin
        if (nttif.done) nxt_state = DOTPRODUCT;
        else nxt_state = NTTB;
      end
      DOTPRODUCT: begin
        if (product_state == PRODUCTDONE) nxt_state = NTTRES;
        else nxt_state = DOTPRODUCT;
      end
      NTTRES: begin
        if (nttif.done) nxt_state = REVERSE;
        else nxt_state = NTTRES;
      end
      REVERSE: begin
        if (reverse_idx_0 == (DEPTH / 2 + 1)) nxt_state = DONE;
        else nxt_state = REVERSE;
      end
      DONE: begin
        nxt_state = IDLE;
      end
      default: nxt_state = IDLE;
    endcase
  end

  always_comb begin
    case (cur_state)
      NTTA: begin
        ntt_memif.Q = a_if.Q;
        ntt_memif.valid = a_if.valid;
        a_if.addr_r = ntt_memif.addr_r;
        a_if.addr_w = ntt_memif.addr_w;
        a_if.D = ntt_memif.D;
        a_if.WE = ntt_memif.WE;
        a_if.RE = ntt_memif.RE;

        b_if.addr_r = 0;
        b_if.addr_w = 0;
        b_if.D = 0;
        b_if.WE = 0;
        b_if.RE = 0;

        res_if.addr_r = 0;
        res_if.addr_w = 0;
        res_if.D = 0;
        res_if.WE = 0;
        res_if.RE = 0;
      end
      NTTB: begin
        ntt_memif.Q = b_if.Q;
        ntt_memif.valid = b_if.valid;

        a_if.addr_r = 0;
        a_if.addr_w = 0;
        a_if.D = 0;
        a_if.WE = 0;
        a_if.RE = 0;

        b_if.addr_r = ntt_memif.addr_r;
        b_if.addr_w = ntt_memif.addr_w;
        b_if.D = ntt_memif.D;
        b_if.WE = ntt_memif.WE;
        b_if.RE = ntt_memif.RE;

        res_if.addr_r = 0;
        res_if.addr_w = 0;
        res_if.D = 0;
        res_if.WE = 0;
        res_if.RE = 0;
      end
      NTTRES: begin
        ntt_memif.Q = res_if.Q;
        ntt_memif.valid = res_if.valid;

        a_if.addr_r = 0;
        a_if.addr_w = 0;
        a_if.D = 0;
        a_if.WE = 0;
        a_if.RE = 0;

        b_if.addr_r = 0;
        b_if.addr_w = 0;
        b_if.D = 0;
        b_if.WE = 0;
        b_if.RE = 0;

        res_if.addr_r = ntt_memif.addr_r;
        res_if.addr_w = ntt_memif.addr_w;
        res_if.D = ntt_memif.D;
        res_if.WE = ntt_memif.WE;
        res_if.RE = ntt_memif.RE;
      end
      DOTPRODUCT: begin
        ntt_memif.Q = 0;
        ntt_memif.valid = 0;

        a_if.addr_r = product_idx;
        a_if.addr_w = 0;
        a_if.D = 0;
        a_if.WE = 0;
        a_if.RE = prod_RE;

        b_if.addr_r = product_idx;
        b_if.addr_w = 0;
        b_if.D = 0;
        b_if.WE = 0;
        b_if.RE = prod_RE;

        res_if.addr_r = 0;
        res_if.addr_w = product_idx_w;
        res_if.D = prod_res;
        res_if.WE = prod_WE;
        res_if.RE = 0;
      end
      REVERSE: begin
        ntt_memif.Q = 0;
        ntt_memif.valid = 0;

        a_if.addr_r = 0;
        a_if.addr_w = 0;
        a_if.D = 0;
        a_if.WE = 0;
        a_if.RE = 0;

        b_if.addr_r = 0;
        b_if.addr_w = 0;
        b_if.D = 0;
        b_if.WE = 0;
        b_if.RE = 0;

        res_if.addr_r = reverse_idx;
        res_if.addr_w = reverse_idx;
        res_if.D = rev_D;
        res_if.WE = rev_WE;
        res_if.RE = rev_RE;
      end
      default: begin
        ntt_memif.Q = 0;
        ntt_memif.valid = 0;

        a_if.addr_r = 0;
        a_if.addr_w = 0;
        a_if.D = 0;
        a_if.WE = 0;
        a_if.RE = 0;

        b_if.addr_r = 0;
        b_if.addr_w = 0;
        b_if.D = 0;
        b_if.WE = 0;
        b_if.RE = 0;

        res_if.addr_r = 0;
        res_if.addr_w = 0;
        res_if.D = 0;
        res_if.WE = 0;
        res_if.RE = 0;
      end

    endcase

  end
  always_comb begin
    convif.done   = cur_state == DONE;
    reverse_idx_1 = DEPTH - reverse_idx_0;
    nttif.enable  = ntt_en;
  end
  always @(posedge convif.clk, posedge convif.rst) begin
    if (convif.rst) begin
      product_idx <= 0;
      product_idx_w <= 0;
      prod_res <= 0;
      prod_RE <= 0;
      prod_WE <= 0;
      reverse_idx <= 0;
      reverse_idx_0 <= 0;
      rev_RE <= 0;
      rev_WE <= 0;
      rcnt <= 0;
      cur_rev <= REVR;
      cur_state <= IDLE;
      ntt_en <= 0;
      product_state <= 0;
    end else begin
      cur_state <= nxt_state;
      case (cur_state)
        NTTA: begin
          ntt_en <= ~nttif.busy;
        end
        NTTB: begin
          ntt_en <= ~nttif.busy;

          product_state <= PRODUCTINIT;
        end

        DOTPRODUCT: begin
          case (product_state)
            PRODUCTINIT: begin
              product_idx <= 0;
              prod_RE <= 1;
              product_state <= PRODUCTREAD;
            end
            PRODUCTREAD: begin
              prod_WE <= 0;
              if (a_if.valid && b_if.valid) begin
                product_idx <= product_idx + 1;
                product_idx_w <= product_idx;
                prod_res <= a_if.Q * b_if.Q;
                prod_RE <= 1;
                product_state <= PRODUCTWRITE;
              end
            end
            PRODUCTWRITE: begin
              prod_res <= prod_res % MOD;
              prod_WE <= 1;
              prod_RE <= 0;
              product_state <= (product_idx < DEPTH) ? PRODUCTREAD : PRODUCTDONE;
            end
            PRODUCTDONE: begin
            end
            default begin

            end
          endcase

        end
        NTTRES: begin
          ntt_en <= ~nttif.busy;
        end
        REVERSE: begin
          case (cur_rev)
            REVR: begin
              reverse_idx <= (rcnt) ? reverse_idx_1 : reverse_idx_0;
              rev_RE <= 1;
              rev_WE <= 0;
              cur_rev <= REVWAIT;
            end
            REVWAIT: begin
              rev_RE <= 0;
              rev_WE <= 0;
              if (res_if.valid) begin
                cur_rev <= (rcnt == 1) ? REVW : REVR;
                if (rcnt == 0) rev_0 <= res_if.Q * NINV;
                else rev_1 <= res_if.Q * NINV;
                rcnt <= 1;
              end
            end
            REVW: begin
              reverse_idx <= (rcnt) ? reverse_idx_0 : reverse_idx_1;
              rev_D <= ((rcnt) ? rev_1 : rev_0) % MOD;
              rev_WE <= 1;
              rcnt <= 0;
              rev_RE <= 0;
              if (rcnt == 0) begin
                cur_rev <= REVR;
                reverse_idx_0 <= reverse_idx_0 + 1;
              end
            end
            default: begin

            end
          endcase

        end
        default: begin

        end
      endcase
    end
  end
endmodule
