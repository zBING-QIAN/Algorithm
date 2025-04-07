library verilog;
use verilog.vl_types.all;
entity fastpow is
    generic(
        DEPTH           : vl_logic_vector(31 downto 0);
        SIZE            : vl_logic_vector(31 downto 0);
        \MOD\           : vl_logic_vector(31 downto 0)
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        enable          : in     vl_logic;
        a               : in     vl_logic_vector;
        p               : in     vl_logic_vector;
        \out\           : out    vl_logic_vector;
        busy            : out    vl_logic;
        done            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DEPTH : constant is 6;
    attribute mti_svvh_generic_type of SIZE : constant is 6;
    attribute mti_svvh_generic_type of \MOD\ : constant is 6;
end fastpow;
