library verilog;
use verilog.vl_types.all;
entity rearrange is
    generic(
        DEPTH           : vl_logic_vector(31 downto 0);
        SIZE            : vl_logic_vector(31 downto 0)
    );
    port(
        rst             : in     vl_logic;
        enable          : in     vl_logic;
        busy            : out    vl_logic;
        done            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DEPTH : constant is 6;
    attribute mti_svvh_generic_type of SIZE : constant is 6;
end rearrange;
