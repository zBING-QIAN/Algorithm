library verilog;
use verilog.vl_types.all;
entity mytb is
    generic(
        DEPTH           : integer := 256;
        SIZE            : integer := 20;
        PRIMITIVEROOT   : integer := 3;
        \MOD\           : integer := 257;
        NINV            : integer := 256
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DEPTH : constant is 2;
    attribute mti_svvh_generic_type of SIZE : constant is 2;
    attribute mti_svvh_generic_type of PRIMITIVEROOT : constant is 2;
    attribute mti_svvh_generic_type of \MOD\ : constant is 2;
    attribute mti_svvh_generic_type of NINV : constant is 2;
end mytb;
