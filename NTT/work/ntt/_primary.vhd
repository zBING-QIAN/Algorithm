library verilog;
use verilog.vl_types.all;
entity ntt is
    generic(
        DEPTH           : vl_logic_vector(31 downto 0);
        SIZE            : vl_logic_vector(31 downto 0);
        \MOD\           : vl_logic_vector(31 downto 0);
        PRIMITIVEROOT   : vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DEPTH : constant is 6;
    attribute mti_svvh_generic_type of SIZE : constant is 6;
    attribute mti_svvh_generic_type of \MOD\ : constant is 6;
    attribute mti_svvh_generic_type of PRIMITIVEROOT : constant is 6;
end ntt;
