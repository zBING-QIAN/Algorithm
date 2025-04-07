
module ntt #(
    parameter int DEPTH,
    parameter int SIZE,
    parameter int MOD,
    parameter int PRIMITIVEROOT
) (
    ntt_if nttif,
    memory_linker_if memif
);
  localparam logic [3:0] IDLE = 0, REARRANGE = 1, LOOP_0 = 2,
   LOOP_1 = 3, LOOPREAD0_2 = 4, LOOPREAD1_2 = 5, LOOPCALC0_2 = 6,
   LOOPCALC1_2 = 7, LOOPWRITE_2 = 8 ,LOOPEND_2 = 9, LOOPEND_1 = 10,
   LOOPEND_0 = 11, DONE = 12;
  reg
      rearrange_en,
      rearrange_done,
      rearrange_busy,
      fastpow_en,
      fastpow_busy,
      fastpow_done,
      mul_done,
      mod_done,
      loop_WE,
      loop_RE;
  reg [3:0] cur_state, nxt_state;
  reg [$clog2(DEPTH):0] loop_t, loop_k, loop_i, loop_j;
  reg [SIZE-1:0] fast_p, loop_data, fastpow_out, ker, ker_i;
  reg [SIZE-1:0] buffer0, buffer1, tmp, tmp1, tmp0, prt;
  reg [1:0] rcnt;
  int i;
  reg [$clog2(DEPTH):0] loop_idx_r, loop_idx_w;

  memory_linker_if #(
      .DEPTH(DEPTH),
      .SIZE (SIZE)
  ) rearrange_memif (
      .clk(nttif.clk),
      .rst(nttif.rst)
  );
  rearrange #(
      .DEPTH(DEPTH),
      .SIZE (SIZE)
  ) u_rearrange (
      .rst(nttif.rst),
      .enable(rearrange_en),
      .busy(rearrange_busy),
      .done(rearrange_done),
      .memif(rearrange_memif.MASTER)
  );

  fastpow #(
      .DEPTH(DEPTH),
      .SIZE (SIZE),
      .MOD  (MOD)
  ) u_fastpow (
      .clk(nttif.clk),
      .rst(nttif.rst),
      .enable(fastpow_en),
      .a(prt),
      .p(fast_p),
      .out(fastpow_out),
      .busy(fastpow_busy),
      .done(fastpow_done)
  );

  always_comb begin
    case (cur_state)
      IDLE: nxt_state = (nttif.enable) ? REARRANGE : IDLE;
      REARRANGE: nxt_state = (rearrange_done) ? LOOP_0 : REARRANGE;
      LOOP_0: nxt_state = fastpow_done ? LOOP_1 : LOOP_0;
      LOOP_1: nxt_state = LOOPREAD0_2;
      LOOPREAD0_2: nxt_state = LOOPREAD1_2;
      LOOPREAD1_2: nxt_state = (rcnt == 2) ? LOOPCALC0_2 : LOOPREAD1_2;
      LOOPCALC0_2: nxt_state = LOOPCALC1_2;
      LOOPCALC1_2: nxt_state = LOOPWRITE_2;
      LOOPWRITE_2: nxt_state = (rcnt > 1) ? LOOPWRITE_2 : LOOPEND_2;
      LOOPEND_2: nxt_state = (loop_j + loop_t < DEPTH) ? LOOPREAD0_2 : LOOPEND_1;
      LOOPEND_1: nxt_state = (loop_i + 1 < loop_k) ? LOOP_1 : LOOPEND_0;
      LOOPEND_0: nxt_state = ((loop_t << 1) <= DEPTH) ? LOOP_0 : DONE;
      default: nxt_state = IDLE;
    endcase
  end

  always_comb begin
    nttif.done = cur_state == DONE;
    nttif.busy = cur_state != IDLE;
    mul_done = 1;
    mod_done = 1;
    rearrange_memif.Q = memif.Q;
    rearrange_memif.valid = memif.valid;
    prt = PRIMITIVEROOT;
  end
  always_comb begin
    case (cur_state)
      REARRANGE: begin
        memif.addr_r = rearrange_memif.addr_r;
        memif.addr_w = rearrange_memif.addr_w;
        memif.D = rearrange_memif.D;
        memif.WE = rearrange_memif.WE;
        memif.RE = rearrange_memif.RE;
      end
      default: begin
        memif.addr_r = loop_idx_r;
        memif.addr_w = loop_idx_w;
        memif.D = loop_data;
        memif.WE = loop_WE;
        memif.RE = loop_RE;
      end
    endcase
  end
  always @(posedge nttif.clk, posedge nttif.rst) begin
    if (nttif.rst) begin
      cur_state <= IDLE;
      rcnt <= '0;
      rearrange_en <= '0;
      fastpow_en <= '0;
      loop_idx_r <= '0;
      loop_idx_w <= '0;
      loop_data <= '0;
      loop_WE <= '0;
      loop_RE <= '0;
      loop_k <= '0;
      loop_t <= '0;
      loop_i <= '0;
      loop_j <= '0;
      fast_p <= '0;
    end else begin
      cur_state <= nxt_state;
      case (cur_state)
        REARRANGE: begin
          rearrange_en <= ~rearrange_busy;
          loop_t <= 2;

          loop_k <= 1;

        end
        LOOP_0: begin
          fastpow_en <= ~fastpow_busy;
          fast_p <= (MOD - 1) / loop_t;  // this div can be replace by shifting
          ker <= fastpow_out;
          ker_i <= 1;
          loop_i <= '0;

          loop_k <= loop_t >> 1;
          //   $display("LOOP0 t = %d, k = %d", loop_t, loop_k);
        end
        LOOP_1: begin
          //   $display("LOOP1 t = %d, j = %d", loop_t, loop_j);
          loop_j <= '0;
          ker_i  <= ker_i % MOD;
        end
        LOOPREAD0_2: begin
          //   $display("LOOP2 t = %d, i = %d, j = %d, k = %d", loop_t, loop_i, loop_j, loop_k);
          loop_idx_r <= loop_i + loop_j + loop_k;
          loop_RE <= 1;
        end
        LOOPREAD1_2: begin
          loop_idx_r <= loop_i + loop_j;
          loop_RE <= 1;
          if (memif.valid && rcnt < 2) begin
            if (rcnt == 0) buffer1 <= memif.Q;
            else buffer0 <= memif.Q;
            rcnt <= rcnt + 1;
          end
          tmp <= buffer1 * ker_i;
        end

        LOOPCALC0_2: begin
          loop_WE <= '0;
          loop_RE <= '0;
          tmp <= tmp % MOD;
        end
        LOOPCALC1_2: begin
          tmp1 <= (buffer0 + MOD - tmp);
          tmp0 <= (buffer0 + tmp);
        end
        LOOPWRITE_2: begin
          loop_WE <= rcnt > '0;
          if (rcnt == 2) begin
            loop_idx_w <= loop_i + loop_j + loop_k;
          end else begin
            loop_idx_w <= loop_i + loop_j;
          end
          loop_data <= ((rcnt == 2) ? tmp1 : tmp0) % MOD;
          if (rcnt > 0) rcnt <= rcnt - 1;
        end
        LOOPEND_2: begin
          loop_j  <= loop_j + loop_t;
          loop_WE <= '0;
          loop_RE <= '0;
        end
        LOOPEND_1: begin
          ker_i  <= ker_i * ker;
          loop_i <= loop_i + 1;
        end
        LOOPEND_0: begin
          loop_t <= loop_t << 1;
        end
        default: begin

        end
      endcase
    end
  end
endmodule

module rearrange #(
    parameter int DEPTH,
    parameter int SIZE
) (
    input rst,
    input enable,
    output reg busy,
    output reg done,
    memory_linker_if memif
);
  localparam int IDLE = 0, BRANCH = 1, READ0 = 2, READ1 = 3;
  localparam int WRITE0 = 4, WRITE1 = 5, INDEX = 6, DONE = 7;
  reg [2:0] cur_state, nxt_state;
  reg [SIZE-1:0] buffer0, buffer1, buffer;
  reg [$clog2(DEPTH)-1:0] addr_r, addr_r0, addr_r1, addr_w;
  reg [1:0] rcnt;
  reg we, re, swap;
  int i;


  always_comb begin
    done = cur_state == DONE;
    for (i = '0; i < $clog2(DEPTH); i++) begin
      addr_r1[i] = addr_r0[$clog2(DEPTH)-1-i];
    end
    swap = addr_r0 < addr_r1;
    busy = cur_state != IDLE;
  end
  always_comb begin
    case (cur_state)
      IDLE: nxt_state = (enable) ? BRANCH : IDLE;
      BRANCH: nxt_state = (swap) ? READ0 : INDEX;
      READ0: nxt_state = READ1;
      READ1: nxt_state = (rcnt == 2) ? WRITE0 : READ1;
      WRITE0: nxt_state = WRITE1;
      WRITE1: nxt_state = INDEX;
      INDEX: nxt_state = (addr_r0 < DEPTH - 1) ? BRANCH : DONE;
      DONE: nxt_state = IDLE;
      default: nxt_state = IDLE;
    endcase
  end

  always_comb begin
    memif.addr_r = addr_r;
    memif.addr_w = addr_w;
    memif.D = buffer;
    memif.WE = we;
    memif.RE = re;
  end

  always @(posedge memif.clk, posedge rst) begin
    if (rst) begin
      cur_state <= IDLE;
      re <= '0;
      we <= '0;
      rcnt <= '0;
      addr_r <= '0;
      addr_r0 <= '0;
      addr_w <= '0;
      buffer <= '0;
    end else begin
      cur_state <= nxt_state;
      case (cur_state)
        IDLE: begin
          re <= '0;
          we <= '0;
          rcnt <= '0;
          addr_r <= '0;
          addr_r0 <= '0;
          addr_w <= '0;
          buffer <= '0;
        end
        BRANCH: begin
          re   <= '0;
          we   <= '0;
          rcnt <= '0;
        end
        READ0: begin
          addr_r <= addr_r0;
          re <= 1;
          we <= '0;
        end
        READ1: begin
          addr_r <= addr_r1;
          re <= 1;
          we <= '0;
          if (memif.valid) begin
            if (rcnt == 0) buffer0 <= memif.Q;
            else buffer1 <= memif.Q;
            rcnt <= rcnt + 1;
          end
        end
        WRITE0: begin
          re <= '0;
          we <= 1;
          //   assert (rcnt == 2);
          addr_w <= addr_r1;
          buffer <= buffer0;
          rcnt <= 1;
        end

        WRITE1: begin
          re <= '0;
          we <= 1;
          //   assert (rcnt == 1);
          addr_w <= addr_r0;
          buffer <= buffer1;
          rcnt <= '0;
        end

        INDEX: begin
          re <= '0;
          we <= '0;
          addr_r0 <= addr_r0 + 1;
        end
        default: begin

        end
      endcase
    end

  end
endmodule

module fastpow #(
    parameter int DEPTH,
    parameter int SIZE,
    parameter int MOD
) (
    input clk,
    input rst,
    input enable,
    input [SIZE-1:0] a,
    input [SIZE-1:0] p,
    output reg [SIZE-1:0] out,
    output reg busy,
    output reg done
);
  localparam int IDLE = 0, BRANCH = 1, INLOOP = 2, DONE = 3;
  reg [2:0] cur_state, nxt_state;
  reg [SIZE-1:0] p_r, a_r;
  reg mod_done;
  always_comb begin
    done = cur_state == DONE;
    busy = cur_state != IDLE;
    mod_done = 1;
  end
  always_comb begin
    case (cur_state)
      IDLE: nxt_state = (enable) ? BRANCH : IDLE;
      BRANCH: nxt_state = (p_r) ? INLOOP : DONE;
      INLOOP: nxt_state = (mod_done) ? BRANCH : INLOOP;
      DONE: nxt_state = IDLE;
      default: nxt_state = IDLE;
    endcase
  end

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      cur_state <= IDLE;
      p_r <= '0;
      a_r <= '0;
      out <= '0;
    end else begin
      cur_state <= nxt_state;
      case (cur_state)
        IDLE: begin
          p_r <= p;
          a_r <= a;
          out <= 1;
        end
        BRANCH: begin
          if (p_r & 1) begin
            out <= out * a_r;
          end
          a_r <= a_r * a_r;
        end
        INLOOP: begin
          if (p_r & 1) begin
            out <= out % MOD;
          end
          a_r = a_r % MOD;
          p_r <= (p_r) >> 1;
        end
        default: begin

        end
      endcase
    end

  end
endmodule
