module opicorv32_rv32_wrap (
    irq,
    pcpi_ready,
    pcpi_wait,
    pcpi_rd,
    pcpi_wr,
    mem_rdata,
    mem_ready,
    resetn,
    clk,
    trap,
    mem_valid,
    mem_instr,
    mem_addr,
    mem_wdata,
    mem_wstrb,
    mem_la_read,
    mem_la_write,
    mem_la_addr,
    mem_la_wdata,
    mem_la_wstrb,
    pcpi_valid,
    pcpi_insn,
    pcpi_rs1,
    pcpi_rs2,
    eoi
);

    input [31:0] irq;
    input pcpi_ready;
    input pcpi_wait;
    input [31:0] pcpi_rd;
    input pcpi_wr;
    input [31:0] mem_rdata;
    input mem_ready;
    input resetn;
    input clk;
    output trap;
    output mem_valid;
    output mem_instr;
    output [31:0] mem_addr;
    output [31:0] mem_wdata;
    output [3:0] mem_wstrb;
    output mem_la_read;
    output mem_la_write;
    output [31:0] mem_la_addr;
    output [31:0] mem_la_wdata;
    output [3:0] mem_la_wstrb;
    output pcpi_valid;
    output [31:0] pcpi_insn;
    output [31:0] pcpi_rs1;
    output [31:0] pcpi_rs2;
    output [31:0] eoi;

    /* signal declarations */
    wire [31:0] _9632;
    wire [31:0] _9616;
    wire [31:0] compare_eoi;
    wire [31:0] _9634;
    wire [31:0] _9635;
    wire [31:0] _9617;
    wire [31:0] compare_pcpi_rs2;
    wire [31:0] _9637;
    wire [31:0] _9638;
    wire [31:0] _9618;
    wire [31:0] compare_pcpi_rs1;
    wire [31:0] _9640;
    wire [31:0] _9641;
    wire [31:0] _9619;
    wire [31:0] compare_pcpi_insn;
    wire [31:0] _9643;
    wire _9644;
    wire _9620;
    wire compare_pcpi_valid;
    wire _9646;
    wire [3:0] _9647;
    wire [3:0] _9621;
    wire [3:0] compare_mem_la_wstrb;
    wire [3:0] _9649;
    wire [31:0] _9650;
    wire [31:0] _9622;
    wire [31:0] compare_mem_la_wdata;
    wire [31:0] _9652;
    wire [31:0] _9653;
    wire [31:0] _9623;
    wire [31:0] compare_mem_la_addr;
    wire [31:0] _9655;
    wire _9656;
    wire _9624;
    wire compare_mem_la_write;
    wire _9658;
    wire _9659;
    wire _9625;
    wire compare_mem_la_read;
    wire _9661;
    wire [3:0] _9662;
    wire [3:0] _9626;
    wire [3:0] compare_mem_wstrb;
    wire [3:0] _9664;
    wire [31:0] _9665;
    wire [31:0] _9627;
    wire [31:0] compare_mem_wdata;
    wire [31:0] _9667;
    wire [31:0] _9668;
    wire [31:0] _9628;
    wire [31:0] compare_mem_addr;
    wire [31:0] _9670;
    wire _9671;
    wire _9629;
    wire compare_mem_instr;
    wire _9673;
    wire _9674;
    wire _9630;
    wire compare_mem_valid;
    wire _9676;
    wire [269:0] _9613;
    wire _9677;
    wire [269:0] _9615;
    wire _9631;
    wire compare_trap;
    wire _9679;

    /* logic */
    assign _9632 = _9613[269:238];
    assign _9616 = _9615[269:238];
    assign compare_eoi = _9616 ^ _9632;
    assign _9634 = compare_eoi ^ _9632;
    assign _9635 = _9613[237:206];
    assign _9617 = _9615[237:206];
    assign compare_pcpi_rs2 = _9617 ^ _9635;
    assign _9637 = compare_pcpi_rs2 ^ _9635;
    assign _9638 = _9613[205:174];
    assign _9618 = _9615[205:174];
    assign compare_pcpi_rs1 = _9618 ^ _9638;
    assign _9640 = compare_pcpi_rs1 ^ _9638;
    assign _9641 = _9613[173:142];
    assign _9619 = _9615[173:142];
    assign compare_pcpi_insn = _9619 ^ _9641;
    assign _9643 = compare_pcpi_insn ^ _9641;
    assign _9644 = _9613[141:141];
    assign _9620 = _9615[141:141];
    assign compare_pcpi_valid = _9620 ^ _9644;
    assign _9646 = compare_pcpi_valid ^ _9644;
    assign _9647 = _9613[140:137];
    assign _9621 = _9615[140:137];
    assign compare_mem_la_wstrb = _9621 ^ _9647;
    assign _9649 = compare_mem_la_wstrb ^ _9647;
    assign _9650 = _9613[136:105];
    assign _9622 = _9615[136:105];
    assign compare_mem_la_wdata = _9622 ^ _9650;
    assign _9652 = compare_mem_la_wdata ^ _9650;
    assign _9653 = _9613[104:73];
    assign _9623 = _9615[104:73];
    assign compare_mem_la_addr = _9623 ^ _9653;
    assign _9655 = compare_mem_la_addr ^ _9653;
    assign _9656 = _9613[72:72];
    assign _9624 = _9615[72:72];
    assign compare_mem_la_write = _9624 ^ _9656;
    assign _9658 = compare_mem_la_write ^ _9656;
    assign _9659 = _9613[71:71];
    assign _9625 = _9615[71:71];
    assign compare_mem_la_read = _9625 ^ _9659;
    assign _9661 = compare_mem_la_read ^ _9659;
    assign _9662 = _9613[70:67];
    assign _9626 = _9615[70:67];
    assign compare_mem_wstrb = _9626 ^ _9662;
    assign _9664 = compare_mem_wstrb ^ _9662;
    assign _9665 = _9613[66:35];
    assign _9627 = _9615[66:35];
    assign compare_mem_wdata = _9627 ^ _9665;
    assign _9667 = compare_mem_wdata ^ _9665;
    assign _9668 = _9613[34:3];
    assign _9628 = _9615[34:3];
    assign compare_mem_addr = _9628 ^ _9668;
    assign _9670 = compare_mem_addr ^ _9668;
    assign _9671 = _9613[2:2];
    assign _9629 = _9615[2:2];
    assign compare_mem_instr = _9629 ^ _9671;
    assign _9673 = compare_mem_instr ^ _9671;
    assign _9674 = _9613[1:1];
    assign _9630 = _9615[1:1];
    assign compare_mem_valid = _9630 ^ _9674;
    assign _9676 = compare_mem_valid ^ _9674;
    picorv32_rv32
        the_picorv32_rv32
        ( .clk(clk), .resetn(resetn), .mem_ready(mem_ready), .mem_rdata(mem_rdata), .pcpi_wr(pcpi_wr), .pcpi_rd(pcpi_rd), .pcpi_wait(pcpi_wait), .pcpi_ready(pcpi_ready), .irq(irq), .eoi(_9613[269:238]), .pcpi_rs2(_9613[237:206]), .pcpi_rs1(_9613[205:174]), .pcpi_insn(_9613[173:142]), .pcpi_valid(_9613[141:141]), .mem_la_wstrb(_9613[140:137]), .mem_la_wdata(_9613[136:105]), .mem_la_addr(_9613[104:73]), .mem_la_write(_9613[72:72]), .mem_la_read(_9613[71:71]), .mem_wstrb(_9613[70:67]), .mem_wdata(_9613[66:35]), .mem_addr(_9613[34:3]), .mem_instr(_9613[2:2]), .mem_valid(_9613[1:1]), .trap(_9613[0:0]) );
    assign _9677 = _9613[0:0];
    opicorv32_rv32
        the_opicorv32_rv32
        ( .clk(clk), .resetn(resetn), .mem_ready(mem_ready), .mem_rdata(mem_rdata), .pcpi_wr(pcpi_wr), .pcpi_rd(pcpi_rd), .pcpi_wait(pcpi_wait), .pcpi_ready(pcpi_ready), .irq(irq), .eoi(_9615[269:238]), .pcpi_rs2(_9615[237:206]), .pcpi_rs1(_9615[205:174]), .pcpi_insn(_9615[173:142]), .pcpi_valid(_9615[141:141]), .mem_la_wstrb(_9615[140:137]), .mem_la_wdata(_9615[136:105]), .mem_la_addr(_9615[104:73]), .mem_la_write(_9615[72:72]), .mem_la_read(_9615[71:71]), .mem_wstrb(_9615[70:67]), .mem_wdata(_9615[66:35]), .mem_addr(_9615[34:3]), .mem_instr(_9615[2:2]), .mem_valid(_9615[1:1]), .trap(_9615[0:0]) );
    assign _9631 = _9615[0:0];
    assign compare_trap = _9631 ^ _9677;
    assign _9679 = compare_trap ^ _9677;

    /* aliases */

    /* output assignments */
    assign trap = _9679;
    assign mem_valid = _9676;
    assign mem_instr = _9673;
    assign mem_addr = _9670;
    assign mem_wdata = _9667;
    assign mem_wstrb = _9664;
    assign mem_la_read = _9661;
    assign mem_la_write = _9658;
    assign mem_la_addr = _9655;
    assign mem_la_wdata = _9652;
    assign mem_la_wstrb = _9649;
    assign pcpi_valid = _9646;
    assign pcpi_insn = _9643;
    assign pcpi_rs1 = _9640;
    assign pcpi_rs2 = _9637;
    assign eoi = _9634;

endmodule
