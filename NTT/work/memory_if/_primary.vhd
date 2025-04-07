library verilog;
use verilog.vl_types.all;
entity memory_if is
    generic(
        DEPTH           : integer := 256;
        SIZE            : integer := 20
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DEPTH : constant is 2;
    attribute mti_svvh_generic_type of SIZE : constant is 2;
end memory_if;
