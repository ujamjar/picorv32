module opicorv32_mul_wrap (
    pcpi_rs2,
    pcpi_rs1,
    pcpi_insn,
    pcpi_valid,
    resetn,
    clk,
    pcpi_wr,
    pcpi_rd,
    pcpi_wait,
    pcpi_ready
);

    input [31:0] pcpi_rs2;
    input [31:0] pcpi_rs1;
    input [31:0] pcpi_insn;
    input pcpi_valid;
    input resetn;
    input clk;
    output pcpi_wr;
    output [31:0] pcpi_rd;
    output pcpi_wait;
    output pcpi_ready;

    /* signal declarations */
    wire _1749;
    wire _1745;
    wire compare_pcpi_ready;
    wire _1751;
    wire _1752;
    wire _1746;
    wire compare_pcpi_wait;
    wire _1754;
    wire [31:0] _1755;
    wire [31:0] _1747;
    wire [31:0] compare_pcpi_rd;
    wire [31:0] _1757;
    wire [34:0] _1742;
    wire _1758;
    wire [34:0] _1744;
    wire _1748;
    wire compare_pcpi_wr;
    wire _1760;

    /* logic */
    assign _1749 = _1742[34:34];
    assign _1745 = _1744[34:34];
    assign compare_pcpi_ready = _1745 ^ _1749;
    assign _1751 = compare_pcpi_ready ^ _1749;
    assign _1752 = _1742[33:33];
    assign _1746 = _1744[33:33];
    assign compare_pcpi_wait = _1746 ^ _1752;
    assign _1754 = compare_pcpi_wait ^ _1752;
    assign _1755 = _1742[32:1];
    assign _1747 = _1744[32:1];
    assign compare_pcpi_rd = _1747 ^ _1755;
    assign _1757 = compare_pcpi_rd ^ _1755;
    picorv32_mul
        the_picorv32_mul
        ( .clk(clk), .resetn(resetn), .pcpi_valid(pcpi_valid), .pcpi_insn(pcpi_insn), .pcpi_rs1(pcpi_rs1), .pcpi_rs2(pcpi_rs2), .pcpi_ready(_1742[34:34]), .pcpi_wait(_1742[33:33]), .pcpi_rd(_1742[32:1]), .pcpi_wr(_1742[0:0]) );
    assign _1758 = _1742[0:0];
    opicorv32_mul
        the_opicorv32_mul
        ( .clk(clk), .resetn(resetn), .pcpi_valid(pcpi_valid), .pcpi_insn(pcpi_insn), .pcpi_rs1(pcpi_rs1), .pcpi_rs2(pcpi_rs2), .pcpi_ready(_1744[34:34]), .pcpi_wait(_1744[33:33]), .pcpi_rd(_1744[32:1]), .pcpi_wr(_1744[0:0]) );
    assign _1748 = _1744[0:0];
    assign compare_pcpi_wr = _1748 ^ _1758;
    assign _1760 = compare_pcpi_wr ^ _1758;

    /* aliases */

    /* output assignments */
    assign pcpi_wr = _1760;
    assign pcpi_rd = _1757;
    assign pcpi_wait = _1754;
    assign pcpi_ready = _1751;

endmodule
