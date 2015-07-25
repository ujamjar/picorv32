module opicorv32_control_wrap (
    irq,
    decoded_imm_uj,
    decoded_imm,
    decoded_rs2,
    decoded_rs1,
    decoded_rd,
    pcpi_int_rd,
    pcpi_int_wr,
    pcpi_int_wait,
    pcpi_int_ready,
    mem_done,
    mem_rdata_word,
    is_lui_auipc_jal,
    is_lb_lh_lw_lbu_lhu,
    is_slli_srli_srai,
    is_jalr_addi_slti_sltiu_xori_ori_andi,
    is_sb_sh_sw,
    is_sll_srl_sra,
    is_lui_auipc_jal_jalr_addi_add,
    is_slti_blt_slt,
    is_sltiu_bltu_sltu,
    is_beq_bne_blt_bge_bltu_bgeu,
    is_lbu_lhu_lw,
    is_alu_reg_imm,
    is_alu_reg_reg,
    is_compare,
    is_rdcycle_rdcycleh_rdinstr_rdinstrh,
    instr_lui,
    instr_auipc,
    instr_jal,
    instr_jalr,
    instr_beq,
    instr_bne,
    instr_blt,
    instr_bge,
    instr_bltu,
    instr_bgeu,
    instr_lb,
    instr_lh,
    instr_lw,
    instr_lbu,
    instr_lhu,
    instr_sb,
    instr_sh,
    instr_sw,
    instr_addi,
    instr_slti,
    instr_sltiu,
    instr_xori,
    instr_ori,
    instr_andi,
    instr_slli,
    instr_srli,
    instr_srai,
    instr_add,
    instr_sub,
    instr_sll,
    instr_slt,
    instr_sltu,
    instr_xor,
    instr_srl,
    instr_sra,
    instr_or,
    instr_and,
    instr_rdcycle,
    instr_rdcycleh,
    instr_rdinstr,
    instr_rdinstrh,
    instr_getq,
    instr_setq,
    instr_retirq,
    instr_maskirq,
    instr_waitirq,
    instr_timer,
    instr_trap,
    resetn,
    clk,
    next_pc,
    reg_op1,
    reg_op2,
    trap,
    mem_do_rinst,
    mem_do_wdata,
    mem_do_rdata,
    mem_wordsize,
    mem_do_prefetch,
    pcpi_valid,
    decoder_trigger,
    decoder_trigger_q,
    decoder_pseudo_trigger,
    eoi,
    ascii_state
);

    input [31:0] irq;
    input [31:0] decoded_imm_uj;
    input [31:0] decoded_imm;
    input [5:0] decoded_rs2;
    input [5:0] decoded_rs1;
    input [5:0] decoded_rd;
    input [31:0] pcpi_int_rd;
    input pcpi_int_wr;
    input pcpi_int_wait;
    input pcpi_int_ready;
    input mem_done;
    input [31:0] mem_rdata_word;
    input is_lui_auipc_jal;
    input is_lb_lh_lw_lbu_lhu;
    input is_slli_srli_srai;
    input is_jalr_addi_slti_sltiu_xori_ori_andi;
    input is_sb_sh_sw;
    input is_sll_srl_sra;
    input is_lui_auipc_jal_jalr_addi_add;
    input is_slti_blt_slt;
    input is_sltiu_bltu_sltu;
    input is_beq_bne_blt_bge_bltu_bgeu;
    input is_lbu_lhu_lw;
    input is_alu_reg_imm;
    input is_alu_reg_reg;
    input is_compare;
    input is_rdcycle_rdcycleh_rdinstr_rdinstrh;
    input instr_lui;
    input instr_auipc;
    input instr_jal;
    input instr_jalr;
    input instr_beq;
    input instr_bne;
    input instr_blt;
    input instr_bge;
    input instr_bltu;
    input instr_bgeu;
    input instr_lb;
    input instr_lh;
    input instr_lw;
    input instr_lbu;
    input instr_lhu;
    input instr_sb;
    input instr_sh;
    input instr_sw;
    input instr_addi;
    input instr_slti;
    input instr_sltiu;
    input instr_xori;
    input instr_ori;
    input instr_andi;
    input instr_slli;
    input instr_srli;
    input instr_srai;
    input instr_add;
    input instr_sub;
    input instr_sll;
    input instr_slt;
    input instr_sltu;
    input instr_xor;
    input instr_srl;
    input instr_sra;
    input instr_or;
    input instr_and;
    input instr_rdcycle;
    input instr_rdcycleh;
    input instr_rdinstr;
    input instr_rdinstrh;
    input instr_getq;
    input instr_setq;
    input instr_retirq;
    input instr_maskirq;
    input instr_waitirq;
    input instr_timer;
    input instr_trap;
    input resetn;
    input clk;
    output [31:0] next_pc;
    output [31:0] reg_op1;
    output [31:0] reg_op2;
    output trap;
    output mem_do_rinst;
    output mem_do_wdata;
    output mem_do_rdata;
    output [1:0] mem_wordsize;
    output mem_do_prefetch;
    output pcpi_valid;
    output decoder_trigger;
    output decoder_trigger_q;
    output decoder_pseudo_trigger;
    output [31:0] eoi;
    output [127:0] ascii_state;

    /* signal declarations */
    wire [127:0] _5565;
    wire [127:0] _5550;
    wire [127:0] compare_ascii_state;
    wire [127:0] _5567;
    wire [31:0] _5568;
    wire [31:0] _5551;
    wire [31:0] compare_eoi;
    wire [31:0] _5570;
    wire _5571;
    wire _5552;
    wire compare_decoder_pseudo_trigger;
    wire _5573;
    wire _5574;
    wire _5553;
    wire compare_decoder_trigger_q;
    wire _5576;
    wire _5577;
    wire _5554;
    wire compare_decoder_trigger;
    wire _5579;
    wire _5580;
    wire _5555;
    wire compare_pcpi_valid;
    wire _5582;
    wire _5583;
    wire _5556;
    wire compare_mem_do_prefetch;
    wire _5585;
    wire [1:0] _5586;
    wire [1:0] _5557;
    wire [1:0] compare_mem_wordsize;
    wire [1:0] _5588;
    wire _5589;
    wire _5558;
    wire compare_mem_do_rdata;
    wire _5591;
    wire _5592;
    wire _5559;
    wire compare_mem_do_wdata;
    wire _5594;
    wire _5595;
    wire _5560;
    wire compare_mem_do_rinst;
    wire _5597;
    wire _5598;
    wire _5561;
    wire compare_trap;
    wire _5600;
    wire [31:0] _5601;
    wire [31:0] _5562;
    wire [31:0] compare_reg_op2;
    wire [31:0] _5603;
    wire [31:0] _5604;
    wire [31:0] _5563;
    wire [31:0] compare_reg_op1;
    wire [31:0] _5606;
    wire [266:0] _5545;
    wire [31:0] _5607;
    wire [14:0] _5547;
    wire [47:0] _5546;
    wire [266:0] _5549;
    wire [31:0] _5564;
    wire [31:0] compare_next_pc;
    wire [31:0] _5609;

    /* logic */
    assign _5565 = _5545[266:139];
    assign _5550 = _5549[266:139];
    assign compare_ascii_state = _5550 ^ _5565;
    assign _5567 = compare_ascii_state ^ _5565;
    assign _5568 = _5545[138:107];
    assign _5551 = _5549[138:107];
    assign compare_eoi = _5551 ^ _5568;
    assign _5570 = compare_eoi ^ _5568;
    assign _5571 = _5545[106:106];
    assign _5552 = _5549[106:106];
    assign compare_decoder_pseudo_trigger = _5552 ^ _5571;
    assign _5573 = compare_decoder_pseudo_trigger ^ _5571;
    assign _5574 = _5545[105:105];
    assign _5553 = _5549[105:105];
    assign compare_decoder_trigger_q = _5553 ^ _5574;
    assign _5576 = compare_decoder_trigger_q ^ _5574;
    assign _5577 = _5545[104:104];
    assign _5554 = _5549[104:104];
    assign compare_decoder_trigger = _5554 ^ _5577;
    assign _5579 = compare_decoder_trigger ^ _5577;
    assign _5580 = _5545[103:103];
    assign _5555 = _5549[103:103];
    assign compare_pcpi_valid = _5555 ^ _5580;
    assign _5582 = compare_pcpi_valid ^ _5580;
    assign _5583 = _5545[102:102];
    assign _5556 = _5549[102:102];
    assign compare_mem_do_prefetch = _5556 ^ _5583;
    assign _5585 = compare_mem_do_prefetch ^ _5583;
    assign _5586 = _5545[101:100];
    assign _5557 = _5549[101:100];
    assign compare_mem_wordsize = _5557 ^ _5586;
    assign _5588 = compare_mem_wordsize ^ _5586;
    assign _5589 = _5545[99:99];
    assign _5558 = _5549[99:99];
    assign compare_mem_do_rdata = _5558 ^ _5589;
    assign _5591 = compare_mem_do_rdata ^ _5589;
    assign _5592 = _5545[98:98];
    assign _5559 = _5549[98:98];
    assign compare_mem_do_wdata = _5559 ^ _5592;
    assign _5594 = compare_mem_do_wdata ^ _5592;
    assign _5595 = _5545[97:97];
    assign _5560 = _5549[97:97];
    assign compare_mem_do_rinst = _5560 ^ _5595;
    assign _5597 = compare_mem_do_rinst ^ _5595;
    assign _5598 = _5545[96:96];
    assign _5561 = _5549[96:96];
    assign compare_trap = _5561 ^ _5598;
    assign _5600 = compare_trap ^ _5598;
    assign _5601 = _5545[95:64];
    assign _5562 = _5549[95:64];
    assign compare_reg_op2 = _5562 ^ _5601;
    assign _5603 = compare_reg_op2 ^ _5601;
    assign _5604 = _5545[63:32];
    assign _5563 = _5549[63:32];
    assign compare_reg_op1 = _5563 ^ _5604;
    assign _5606 = compare_reg_op1 ^ _5604;
    picorv32_control
        #( .ENABLE_COUNTERS(1), .ENABLE_REGS_16_31(1), .ENABLE_REGS_DUALPORT(1), .LATCHED_MEM_RDATA(0), .ENABLE_PCPI(0), .ENABLE_MUL(1), .ENABLE_IRQ(1), .ENABLE_IRQ_QREGS(1), .ENABLE_IRQ_TIMER(1), .MASKED_IRQ(0), .LATCHED_IRQ(-1), .PROGADDR_RESET(0), .PROGADDR_IRQ(16), .irqregs_offset(32), .regfile_size(36), .regindex_bits(6) )
        the_picorv32_control
        ( .instr_lui(instr_lui), .instr_auipc(instr_auipc), .instr_jal(instr_jal), .instr_jalr(instr_jalr), .instr_beq(instr_beq), .instr_bne(instr_bne), .instr_blt(instr_blt), .instr_bge(instr_bge), .instr_bltu(instr_bltu), .instr_bgeu(instr_bgeu), .instr_lb(instr_lb), .instr_lh(instr_lh), .instr_lw(instr_lw), .instr_lbu(instr_lbu), .instr_lhu(instr_lhu), .instr_sb(instr_sb), .instr_sh(instr_sh), .instr_sw(instr_sw), .instr_addi(instr_addi), .instr_slti(instr_slti), .instr_sltiu(instr_sltiu), .instr_xori(instr_xori), .instr_ori(instr_ori), .instr_andi(instr_andi), .instr_slli(instr_slli), .instr_srli(instr_srli), .instr_srai(instr_srai), .instr_add(instr_add), .instr_sub(instr_sub), .instr_sll(instr_sll), .instr_slt(instr_slt), .instr_sltu(instr_sltu), .instr_xor(instr_xor), .instr_srl(instr_srl), .instr_sra(instr_sra), .instr_or(instr_or), .instr_and(instr_and), .instr_rdcycle(instr_rdcycle), .instr_rdcycleh(instr_rdcycleh), .instr_rdinstr(instr_rdinstr), .instr_rdinstrh(instr_rdinstrh), .instr_getq(instr_getq), .instr_setq(instr_setq), .instr_retirq(instr_retirq), .instr_maskirq(instr_maskirq), .instr_waitirq(instr_waitirq), .instr_timer(instr_timer), .instr_trap(instr_trap), .is_lui_auipc_jal(is_lui_auipc_jal), .is_lb_lh_lw_lbu_lhu(is_lb_lh_lw_lbu_lhu), .is_slli_srli_srai(is_slli_srli_srai), .is_jalr_addi_slti_sltiu_xori_ori_andi(is_jalr_addi_slti_sltiu_xori_ori_andi), .is_sb_sh_sw(is_sb_sh_sw), .is_sll_srl_sra(is_sll_srl_sra), .is_lui_auipc_jal_jalr_addi_add(is_lui_auipc_jal_jalr_addi_add), .is_slti_blt_slt(is_slti_blt_slt), .is_sltiu_bltu_sltu(is_sltiu_bltu_sltu), .is_beq_bne_blt_bge_bltu_bgeu(is_beq_bne_blt_bge_bltu_bgeu), .is_lbu_lhu_lw(is_lbu_lhu_lw), .is_alu_reg_imm(is_alu_reg_imm), .is_alu_reg_reg(is_alu_reg_reg), .is_compare(is_compare), .is_rdcycle_rdcycleh_rdinstr_rdinstrh(is_rdcycle_rdcycleh_rdinstr_rdinstrh), .clk(clk), .resetn(resetn), .mem_rdata_word(mem_rdata_word), .mem_done(mem_done), .pcpi_int_ready(pcpi_int_ready), .pcpi_int_wait(pcpi_int_wait), .pcpi_int_wr(pcpi_int_wr), .pcpi_int_rd(pcpi_int_rd), .decoded_rd(decoded_rd), .decoded_rs1(decoded_rs1), .decoded_rs2(decoded_rs2), .decoded_imm(decoded_imm), .decoded_imm_uj(decoded_imm_uj), .irq(irq), .ascii_state(_5545[266:139]), .eoi(_5545[138:107]), .decoder_pseudo_trigger(_5545[106:106]), .decoder_trigger_q(_5545[105:105]), .decoder_trigger(_5545[104:104]), .pcpi_valid(_5545[103:103]), .mem_do_prefetch(_5545[102:102]), .mem_wordsize(_5545[101:100]), .mem_do_rdata(_5545[99:99]), .mem_do_wdata(_5545[98:98]), .mem_do_rinst(_5545[97:97]), .trap(_5545[96:96]), .reg_op2(_5545[95:64]), .reg_op1(_5545[63:32]), .next_pc(_5545[31:0]) );
    assign _5607 = _5545[31:0];
    assign _5547 = { is_rdcycle_rdcycleh_rdinstr_rdinstrh, is_compare, is_alu_reg_reg, is_alu_reg_imm, is_lbu_lhu_lw, is_beq_bne_blt_bge_bltu_bgeu, is_sltiu_bltu_sltu, is_slti_blt_slt, is_lui_auipc_jal_jalr_addi_add, is_sll_srl_sra, is_sb_sh_sw, is_jalr_addi_slti_sltiu_xori_ori_andi, is_slli_srli_srai, is_lb_lh_lw_lbu_lhu, is_lui_auipc_jal };
    assign _5546 = { instr_trap, instr_timer, instr_waitirq, instr_maskirq, instr_retirq, instr_setq, instr_getq, instr_rdinstrh, instr_rdinstr, instr_rdcycleh, instr_rdcycle, instr_and, instr_or, instr_sra, instr_srl, instr_xor, instr_sltu, instr_slt, instr_sll, instr_sub, instr_add, instr_srai, instr_srli, instr_slli, instr_andi, instr_ori, instr_xori, instr_sltiu, instr_slti, instr_addi, instr_sw, instr_sh, instr_sb, instr_lhu, instr_lbu, instr_lw, instr_lh, instr_lb, instr_bgeu, instr_bltu, instr_bge, instr_blt, instr_bne, instr_beq, instr_jalr, instr_jal, instr_auipc, instr_lui };
    opicorv32_control
        the_opicorv32_control
        ( .clk(clk), .resetn(resetn), .instr(_5546), .is(_5547), .mem_rdata_word(mem_rdata_word), .mem_done(mem_done), .pcpi_int_ready(pcpi_int_ready), .pcpi_int_wait(pcpi_int_wait), .pcpi_int_wr(pcpi_int_wr), .pcpi_int_rd(pcpi_int_rd), .decoded_rd(decoded_rd), .decoded_rs1(decoded_rs1), .decoded_rs2(decoded_rs2), .decoded_imm(decoded_imm), .decoded_imm_uj(decoded_imm_uj), .irq(irq), .ascii_state(_5549[266:139]), .eoi(_5549[138:107]), .decoder_pseudo_trigger(_5549[106:106]), .decoder_trigger_q(_5549[105:105]), .decoder_trigger(_5549[104:104]), .pcpi_valid(_5549[103:103]), .mem_do_prefetch(_5549[102:102]), .mem_wordsize(_5549[101:100]), .mem_do_rdata(_5549[99:99]), .mem_do_wdata(_5549[98:98]), .mem_do_rinst(_5549[97:97]), .trap(_5549[96:96]), .reg_op2(_5549[95:64]), .reg_op1(_5549[63:32]), .next_pc(_5549[31:0]) );
    assign _5564 = _5549[31:0];
    assign compare_next_pc = _5564 ^ _5607;
    assign _5609 = compare_next_pc ^ _5607;

    /* aliases */

    /* output assignments */
    assign next_pc = _5609;
    assign reg_op1 = _5606;
    assign reg_op2 = _5603;
    assign trap = _5600;
    assign mem_do_rinst = _5597;
    assign mem_do_wdata = _5594;
    assign mem_do_rdata = _5591;
    assign mem_wordsize = _5588;
    assign mem_do_prefetch = _5585;
    assign pcpi_valid = _5582;
    assign decoder_trigger = _5579;
    assign decoder_trigger_q = _5576;
    assign decoder_pseudo_trigger = _5573;
    assign eoi = _5570;
    assign ascii_state = _5567;

endmodule
