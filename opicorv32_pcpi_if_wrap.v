module opicorv32_pcpi_if_wrap (
    pcpi_ready,
    pcpi_wait,
    pcpi_rd,
    pcpi_wr,
    pcpi_rs2,
    pcpi_rs1,
    pcpi_insn,
    pcpi_valid,
    resetn,
    clk,
    pcpi_int_wr,
    pcpi_int_rd,
    pcpi_int_wait,
    pcpi_int_ready
);

    input pcpi_ready;
    input pcpi_wait;
    input [31:0] pcpi_rd;
    input pcpi_wr;
    input [31:0] pcpi_rs2;
    input [31:0] pcpi_rs1;
    input [31:0] pcpi_insn;
    input pcpi_valid;
    input resetn;
    input clk;
    output pcpi_int_wr;
    output [31:0] pcpi_int_rd;
    output pcpi_int_wait;
    output pcpi_int_ready;

    /* signal declarations */
    wire _2565;
    wire _2561;
    wire compare_pcpi_int_ready;
    wire _2567;
    wire _2568;
    wire _2562;
    wire compare_pcpi_int_wait;
    wire _2570;
    wire [31:0] _2571;
    wire [31:0] _2563;
    wire [31:0] compare_pcpi_int_rd;
    wire [31:0] _2573;
    wire [34:0] _2558;
    wire _2574;
    wire [34:0] _2560;
    wire _2564;
    wire compare_pcpi_int_wr;
    wire _2576;

    /* logic */
    assign _2565 = _2558[34:34];
    assign _2561 = _2560[34:34];
    assign compare_pcpi_int_ready = _2561 ^ _2565;
    assign _2567 = compare_pcpi_int_ready ^ _2565;
    assign _2568 = _2558[33:33];
    assign _2562 = _2560[33:33];
    assign compare_pcpi_int_wait = _2562 ^ _2568;
    assign _2570 = compare_pcpi_int_wait ^ _2568;
    assign _2571 = _2558[32:1];
    assign _2563 = _2560[32:1];
    assign compare_pcpi_int_rd = _2563 ^ _2571;
    assign _2573 = compare_pcpi_int_rd ^ _2571;
    picorv32_pcpi_if
        #( .ENABLE_PCPI(0), .ENABLE_MUL(1) )
        the_picorv32_pcpi_if
        ( .clk(clk), .resetn(resetn), .pcpi_valid(pcpi_valid), .pcpi_insn(pcpi_insn), .pcpi_rs1(pcpi_rs1), .pcpi_rs2(pcpi_rs2), .pcpi_wr(pcpi_wr), .pcpi_rd(pcpi_rd), .pcpi_wait(pcpi_wait), .pcpi_ready(pcpi_ready), .pcpi_int_ready(_2558[34:34]), .pcpi_int_wait(_2558[33:33]), .pcpi_int_rd(_2558[32:1]), .pcpi_int_wr(_2558[0:0]) );
    assign _2574 = _2558[0:0];
    opicorv32_pcpi_if
        the_opicorv32_pcpi_if
        ( .clk(clk), .resetn(resetn), .pcpi_valid(pcpi_valid), .pcpi_insn(pcpi_insn), .pcpi_rs1(pcpi_rs1), .pcpi_rs2(pcpi_rs2), .pcpi_wr(pcpi_wr), .pcpi_rd(pcpi_rd), .pcpi_wait(pcpi_wait), .pcpi_ready(pcpi_ready), .pcpi_int_ready(_2560[34:34]), .pcpi_int_wait(_2560[33:33]), .pcpi_int_rd(_2560[32:1]), .pcpi_int_wr(_2560[0:0]) );
    assign _2564 = _2560[0:0];
    assign compare_pcpi_int_wr = _2564 ^ _2574;
    assign _2576 = compare_pcpi_int_wr ^ _2574;

    /* aliases */

    /* output assignments */
    assign pcpi_int_wr = _2576;
    assign pcpi_int_rd = _2573;
    assign pcpi_int_wait = _2570;
    assign pcpi_int_ready = _2567;

endmodule
