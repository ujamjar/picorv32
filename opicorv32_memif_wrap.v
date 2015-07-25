module opicorv32_memif_wrap (
    mem_do_wdata,
    mem_do_rdata,
    mem_do_prefetch,
    mem_wordsize,
    mem_rdata,
    mem_do_rinst,
    mem_ready,
    next_pc,
    reg_op2,
    reg_op1,
    resetn,
    clk,
    mem_done,
    mem_valid,
    mem_instr,
    mem_addr,
    mem_wdata,
    mem_wstrb,
    mem_rdata_latched,
    mem_rdata_q,
    mem_rdata_word,
    mem_la_read,
    mem_la_write,
    mem_la_addr,
    mem_la_wdata,
    mem_la_wstrb
);

    input mem_do_wdata;
    input mem_do_rdata;
    input mem_do_prefetch;
    input [1:0] mem_wordsize;
    input [31:0] mem_rdata;
    input mem_do_rinst;
    input mem_ready;
    input [31:0] next_pc;
    input [31:0] reg_op2;
    input [31:0] reg_op1;
    input resetn;
    input clk;
    output mem_done;
    output mem_valid;
    output mem_instr;
    output [31:0] mem_addr;
    output [31:0] mem_wdata;
    output [3:0] mem_wstrb;
    output [31:0] mem_rdata_latched;
    output [31:0] mem_rdata_q;
    output [31:0] mem_rdata_word;
    output mem_la_read;
    output mem_la_write;
    output [31:0] mem_la_addr;
    output [31:0] mem_la_wdata;
    output [3:0] mem_la_wstrb;

    /* signal declarations */
    wire [3:0] _1518;
    wire [3:0] _1504;
    wire [3:0] compare_mem_la_wstrb;
    wire [3:0] _1520;
    wire [31:0] _1521;
    wire [31:0] _1505;
    wire [31:0] compare_mem_la_wdata;
    wire [31:0] _1523;
    wire [31:0] _1524;
    wire [31:0] _1506;
    wire [31:0] compare_mem_la_addr;
    wire [31:0] _1526;
    wire _1527;
    wire _1507;
    wire compare_mem_la_write;
    wire _1529;
    wire _1530;
    wire _1508;
    wire compare_mem_la_read;
    wire _1532;
    wire [31:0] _1533;
    wire [31:0] _1509;
    wire [31:0] compare_mem_rdata_word;
    wire [31:0] _1535;
    wire [31:0] _1536;
    wire [31:0] _1510;
    wire [31:0] compare_mem_rdata_q;
    wire [31:0] _1538;
    wire [31:0] _1539;
    wire [31:0] _1511;
    wire [31:0] compare_mem_rdata_latched;
    wire [31:0] _1541;
    wire [3:0] _1542;
    wire [3:0] _1512;
    wire [3:0] compare_mem_wstrb;
    wire [3:0] _1544;
    wire [31:0] _1545;
    wire [31:0] _1513;
    wire [31:0] compare_mem_wdata;
    wire [31:0] _1547;
    wire [31:0] _1548;
    wire [31:0] _1514;
    wire [31:0] compare_mem_addr;
    wire [31:0] _1550;
    wire _1551;
    wire _1515;
    wire compare_mem_instr;
    wire _1553;
    wire _1554;
    wire _1516;
    wire compare_mem_valid;
    wire _1556;
    wire [236:0] _1501;
    wire _1557;
    wire [236:0] _1503;
    wire _1517;
    wire compare_mem_done;
    wire _1559;

    /* logic */
    assign _1518 = _1501[236:233];
    assign _1504 = _1503[236:233];
    assign compare_mem_la_wstrb = _1504 ^ _1518;
    assign _1520 = compare_mem_la_wstrb ^ _1518;
    assign _1521 = _1501[232:201];
    assign _1505 = _1503[232:201];
    assign compare_mem_la_wdata = _1505 ^ _1521;
    assign _1523 = compare_mem_la_wdata ^ _1521;
    assign _1524 = _1501[200:169];
    assign _1506 = _1503[200:169];
    assign compare_mem_la_addr = _1506 ^ _1524;
    assign _1526 = compare_mem_la_addr ^ _1524;
    assign _1527 = _1501[168:168];
    assign _1507 = _1503[168:168];
    assign compare_mem_la_write = _1507 ^ _1527;
    assign _1529 = compare_mem_la_write ^ _1527;
    assign _1530 = _1501[167:167];
    assign _1508 = _1503[167:167];
    assign compare_mem_la_read = _1508 ^ _1530;
    assign _1532 = compare_mem_la_read ^ _1530;
    assign _1533 = _1501[166:135];
    assign _1509 = _1503[166:135];
    assign compare_mem_rdata_word = _1509 ^ _1533;
    assign _1535 = compare_mem_rdata_word ^ _1533;
    assign _1536 = _1501[134:103];
    assign _1510 = _1503[134:103];
    assign compare_mem_rdata_q = _1510 ^ _1536;
    assign _1538 = compare_mem_rdata_q ^ _1536;
    assign _1539 = _1501[102:71];
    assign _1511 = _1503[102:71];
    assign compare_mem_rdata_latched = _1511 ^ _1539;
    assign _1541 = compare_mem_rdata_latched ^ _1539;
    assign _1542 = _1501[70:67];
    assign _1512 = _1503[70:67];
    assign compare_mem_wstrb = _1512 ^ _1542;
    assign _1544 = compare_mem_wstrb ^ _1542;
    assign _1545 = _1501[66:35];
    assign _1513 = _1503[66:35];
    assign compare_mem_wdata = _1513 ^ _1545;
    assign _1547 = compare_mem_wdata ^ _1545;
    assign _1548 = _1501[34:3];
    assign _1514 = _1503[34:3];
    assign compare_mem_addr = _1514 ^ _1548;
    assign _1550 = compare_mem_addr ^ _1548;
    assign _1551 = _1501[2:2];
    assign _1515 = _1503[2:2];
    assign compare_mem_instr = _1515 ^ _1551;
    assign _1553 = compare_mem_instr ^ _1551;
    assign _1554 = _1501[1:1];
    assign _1516 = _1503[1:1];
    assign compare_mem_valid = _1516 ^ _1554;
    assign _1556 = compare_mem_valid ^ _1554;
    picorv32_memif
        the_picorv32_memif
        ( .clk(clk), .resetn(resetn), .reg_op1(reg_op1), .reg_op2(reg_op2), .next_pc(next_pc), .mem_ready(mem_ready), .mem_do_rinst(mem_do_rinst), .mem_rdata(mem_rdata), .mem_wordsize(mem_wordsize), .mem_do_prefetch(mem_do_prefetch), .mem_do_rdata(mem_do_rdata), .mem_do_wdata(mem_do_wdata), .mem_la_wstrb(_1501[236:233]), .mem_la_wdata(_1501[232:201]), .mem_la_addr(_1501[200:169]), .mem_la_write(_1501[168:168]), .mem_la_read(_1501[167:167]), .mem_rdata_word(_1501[166:135]), .mem_rdata_q(_1501[134:103]), .mem_rdata_latched(_1501[102:71]), .mem_wstrb(_1501[70:67]), .mem_wdata(_1501[66:35]), .mem_addr(_1501[34:3]), .mem_instr(_1501[2:2]), .mem_valid(_1501[1:1]), .mem_done(_1501[0:0]) );
    assign _1557 = _1501[0:0];
    opicorv32_memif
        the_opicorv32_memif
        ( .clk(clk), .resetn(resetn), .reg_op1(reg_op1), .reg_op2(reg_op2), .next_pc(next_pc), .mem_ready(mem_ready), .mem_do_rinst(mem_do_rinst), .mem_rdata(mem_rdata), .mem_wordsize(mem_wordsize), .mem_do_prefetch(mem_do_prefetch), .mem_do_rdata(mem_do_rdata), .mem_do_wdata(mem_do_wdata), .mem_la_wstrb(_1503[236:233]), .mem_la_wdata(_1503[232:201]), .mem_la_addr(_1503[200:169]), .mem_la_write(_1503[168:168]), .mem_la_read(_1503[167:167]), .mem_rdata_word(_1503[166:135]), .mem_rdata_q(_1503[134:103]), .mem_rdata_latched(_1503[102:71]), .mem_wstrb(_1503[70:67]), .mem_wdata(_1503[66:35]), .mem_addr(_1503[34:3]), .mem_instr(_1503[2:2]), .mem_valid(_1503[1:1]), .mem_done(_1503[0:0]) );
    assign _1517 = _1503[0:0];
    assign compare_mem_done = _1517 ^ _1557;
    assign _1559 = compare_mem_done ^ _1557;

    /* aliases */

    /* output assignments */
    assign mem_done = _1559;
    assign mem_valid = _1556;
    assign mem_instr = _1553;
    assign mem_addr = _1550;
    assign mem_wdata = _1547;
    assign mem_wstrb = _1544;
    assign mem_rdata_latched = _1541;
    assign mem_rdata_q = _1538;
    assign mem_rdata_word = _1535;
    assign mem_la_read = _1532;
    assign mem_la_write = _1529;
    assign mem_la_addr = _1526;
    assign mem_la_wdata = _1523;
    assign mem_la_wstrb = _1520;

endmodule
