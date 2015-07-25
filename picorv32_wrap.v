`define Lui 0
`define Auipc 1
`define Jal 2
`define Jalr 3
`define Beq 4
`define Bne 5
`define Blt 6
`define Bge 7
`define Bltu 8
`define Bgeu 9
`define Lb 10
`define Lh 11
`define Lw 12
`define Lbu 13
`define Lhu 14
`define Sb 15
`define Sh 16
`define Sw 17
`define Addi 18
`define Slti 19
`define Sltiu 20
`define Xori 21
`define Ori 22
`define Andi 23
`define Slli 24
`define Srli 25
`define Srai 26
`define Add 27
`define Sub 28
`define Sll 29
`define Slt 30
`define Sltu 31
`define Xor 32
`define Srl 33
`define Sra 34
`define Or 35
`define And 36
`define Rdcycle 37
`define Rdcycleh 38
`define Rdinstr 39
`define Rdinstrh 40
`define Getq 41
`define Setq 42
`define Retirq 43
`define Maskirq 44
`define Waitirq 45
`define Timer 46
`define Trap 47

`define Lui_auipc_jal 0
`define Lb_lh_lw_lbu_lhu 1
`define Slli_srli_srai 2
`define Jalr_addi_slti_sltiu_xori_ori_andi 3
`define Sb_sh_sw 4
`define Sll_srl_sra 5
`define Lui_auipc_jal_jalr_addi_add 6
`define Slti_blt_slt 7
`define Sltiu_bltu_sltu 8
`define Beq_bne_blt_bge_bltu_bgeu 9
`define Lbu_lhu_lw 10
`define Alu_reg_imm 11
`define Alu_reg_reg 12
`define Compare 13
`define Rdcycle_rdcycleh_rdinstr_rdinstrh 14

module picorv32_instruction_decoder_wrap #(
	parameter [ 0:0] ENABLE_COUNTERS = 1,
	parameter [ 0:0] ENABLE_REGS_16_31 = 1,
	parameter [ 0:0] ENABLE_PCPI = 0,
	parameter [ 0:0] ENABLE_MUL = 0,
	parameter [ 0:0] ENABLE_IRQ = 0,
	parameter [ 0:0] ENABLE_IRQ_QREGS = 1,
	parameter [ 0:0] ENABLE_IRQ_TIMER = 1,
  parameter integer irqregs_offset = 0,
  parameter integer regindex_bits = 0
) (
  input             clk, resetn,

  input             mem_do_rinst,
  input             mem_done,
  input      [31:0] mem_rdata_latched,
  input      [31:0] mem_rdata_q,
  output     [31:0] pcpi_insn,

	output instr_lui, instr_auipc, instr_jal, instr_jalr,
         instr_beq, instr_bne, instr_blt, instr_bge, instr_bltu, instr_bgeu,
         instr_lb, instr_lh, instr_lw, instr_lbu, instr_lhu, instr_sb, instr_sh, instr_sw,
         instr_addi, instr_slti, instr_sltiu, instr_xori, instr_ori, instr_andi, instr_slli, 
         instr_srli, instr_srai, instr_add, instr_sub, instr_sll, instr_slt, instr_sltu, 
         instr_xor, instr_srl, instr_sra, instr_or, instr_and, instr_rdcycle, instr_rdcycleh, 
         instr_rdinstr, instr_rdinstrh, instr_getq, instr_setq, instr_retirq, instr_maskirq, 
         instr_waitirq, instr_timer,
	output instr_trap,

	output [regindex_bits-1:0] decoded_rd, decoded_rs1, decoded_rs2,
	output              [31:0] decoded_imm, decoded_imm_uj,

	input decoder_trigger, decoder_trigger_q, decoder_pseudo_trigger,

	output is_lui_auipc_jal, is_lb_lh_lw_lbu_lhu, is_slli_srli_srai,
         is_jalr_addi_slti_sltiu_xori_ori_andi, is_sb_sh_sw, is_sll_srl_sra,
         is_lui_auipc_jal_jalr_addi_add, is_slti_blt_slt, is_sltiu_bltu_sltu,
         is_beq_bne_blt_bge_bltu_bgeu, is_lbu_lhu_lw, is_alu_reg_imm,
         is_alu_reg_reg, is_compare,
	output is_rdcycle_rdcycleh_rdinstr_rdinstrh
);

  localparam hardcaml = 0;

  generate if (!hardcaml) begin
    picorv32_instruction_decoder #(
      .ENABLE_COUNTERS  (ENABLE_COUNTERS  ),
      .ENABLE_REGS_16_31(ENABLE_REGS_16_31),
      .ENABLE_PCPI      (ENABLE_PCPI      ),
      .ENABLE_MUL       (ENABLE_MUL       ),
      .ENABLE_IRQ       (ENABLE_IRQ       ),
      .ENABLE_IRQ_QREGS (ENABLE_IRQ_QREGS ),
      .ENABLE_IRQ_TIMER (ENABLE_IRQ_TIMER ),
      .irqregs_offset   (irqregs_offset   ),
      .regindex_bits    (regindex_bits    )
    ) instruction_decoder (
      .clk              (clk              ),
      .resetn           (resetn           ),
      .mem_do_rinst     (mem_do_rinst     ),
      .mem_done         (mem_done         ),
      .mem_rdata_latched(mem_rdata_latched),
      .mem_rdata_q      (mem_rdata_q      ),
      .pcpi_insn        (pcpi_insn        ),

      .instr_lui(instr_lui), .instr_auipc(instr_auipc), .instr_jal(instr_jal),
      .instr_jalr(instr_jalr), .instr_beq(instr_beq), .instr_bne(instr_bne),
      .instr_blt(instr_blt), .instr_bge(instr_bge), .instr_bltu(instr_bltu),
      .instr_bgeu(instr_bgeu), .instr_lb(instr_lb), .instr_lh(instr_lh),
      .instr_lw(instr_lw), .instr_lbu(instr_lbu), .instr_lhu(instr_lhu),
      .instr_sb(instr_sb), .instr_sh(instr_sh), .instr_sw(instr_sw), .instr_addi(instr_addi),
      .instr_slti(instr_slti), .instr_sltiu(instr_sltiu), .instr_xori(instr_xori),
      .instr_ori(instr_ori), .instr_andi(instr_andi), .instr_slli(instr_slli),
      .instr_srli(instr_srli), .instr_srai(instr_srai), .instr_add(instr_add),
      .instr_sub(instr_sub), .instr_sll(instr_sll), .instr_slt(instr_slt),
      .instr_sltu(instr_sltu), .instr_xor(instr_xor), .instr_srl(instr_srl),
      .instr_sra(instr_sra), .instr_or(instr_or), .instr_and(instr_and),
      .instr_rdcycle(instr_rdcycle), .instr_rdcycleh(instr_rdcycleh),
      .instr_rdinstr(instr_rdinstr), .instr_rdinstrh(instr_rdinstrh),
      .instr_getq(instr_getq), .instr_setq(instr_setq), .instr_retirq(instr_retirq),
      .instr_maskirq(instr_maskirq), .instr_waitirq(instr_waitirq),
      .instr_timer(instr_timer), .instr_trap(instr_trap),

      .decoded_rd(decoded_rd), .decoded_rs1(decoded_rs1), .decoded_rs2(decoded_rs2),
      .decoded_imm(decoded_imm), .decoded_imm_uj(decoded_imm_uj),
    
      .decoder_trigger(decoder_trigger),
      .decoder_trigger_q(decoder_trigger_q),
      .decoder_pseudo_trigger(decoder_pseudo_trigger),

      .is_lui_auipc_jal(is_lui_auipc_jal), .is_lb_lh_lw_lbu_lhu(is_lb_lh_lw_lbu_lhu),
      .is_slli_srli_srai(is_slli_srli_srai),
      .is_jalr_addi_slti_sltiu_xori_ori_andi(is_jalr_addi_slti_sltiu_xori_ori_andi),
      .is_sb_sh_sw(is_sb_sh_sw), .is_sll_srl_sra(is_sll_srl_sra),
      .is_lui_auipc_jal_jalr_addi_add(is_lui_auipc_jal_jalr_addi_add),
      .is_slti_blt_slt(is_slti_blt_slt), .is_sltiu_bltu_sltu(is_sltiu_bltu_sltu),
      .is_beq_bne_blt_bge_bltu_bgeu(is_beq_bne_blt_bge_bltu_bgeu),
      .is_lbu_lhu_lw(is_lbu_lhu_lw), .is_alu_reg_imm(is_alu_reg_imm),
      .is_alu_reg_reg(is_alu_reg_reg), .is_compare(is_compare),
      .is_rdcycle_rdcycleh_rdinstr_rdinstrh(is_rdcycle_rdcycleh_rdinstr_rdinstrh)
    );
  end else begin

    wire [47:0] instr;
    wire [14:0] is;

    assign instr_lui      = instr[`Lui     ]; 
    assign instr_auipc    = instr[`Auipc   ]; 
    assign instr_jal      = instr[`Jal     ];
    assign instr_jalr     = instr[`Jalr    ]; 
    assign instr_beq      = instr[`Beq     ]; 
    assign instr_bne      = instr[`Bne     ];
    assign instr_blt      = instr[`Blt     ]; 
    assign instr_bge      = instr[`Bge     ]; 
    assign instr_bltu     = instr[`Bltu    ];
    assign instr_bgeu     = instr[`Bgeu    ]; 
    assign instr_lb       = instr[`Lb      ]; 
    assign instr_lh       = instr[`Lh      ];
    assign instr_lw       = instr[`Lw      ]; 
    assign instr_lbu      = instr[`Lbu     ]; 
    assign instr_lhu      = instr[`Lhu     ];
    assign instr_sb       = instr[`Sb      ]; 
    assign instr_sh       = instr[`Sh      ]; 
    assign instr_sw       = instr[`Sw      ]; 
    assign instr_addi     = instr[`Addi    ];
    assign instr_slti     = instr[`Slti    ]; 
    assign instr_sltiu    = instr[`Sltiu   ]; 
    assign instr_xori     = instr[`Xori    ];
    assign instr_ori      = instr[`Ori     ]; 
    assign instr_andi     = instr[`Andi    ]; 
    assign instr_slli     = instr[`Slli    ];
    assign instr_srli     = instr[`Srli    ]; 
    assign instr_srai     = instr[`Srai    ]; 
    assign instr_add      = instr[`Add     ];
    assign instr_sub      = instr[`Sub     ]; 
    assign instr_sll      = instr[`Sll     ]; 
    assign instr_slt      = instr[`Slt     ];
    assign instr_sltu     = instr[`Sltu    ]; 
    assign instr_xor      = instr[`Xor     ]; 
    assign instr_srl      = instr[`Srl     ];
    assign instr_sra      = instr[`Sra     ]; 
    assign instr_or       = instr[`Or      ]; 
    assign instr_and      = instr[`And     ];
    assign instr_rdcycle  = instr[`Rdcycle ]; 
    assign instr_rdcycleh = instr[`Rdcycleh];
    assign instr_rdinstr  = instr[`Rdinstr ]; 
    assign instr_rdinstrh = instr[`Rdinstrh];
    assign instr_getq     = instr[`Getq    ]; 
    assign instr_setq     = instr[`Setq    ]; 
    assign instr_retirq   = instr[`Retirq  ];
    assign instr_maskirq  = instr[`Maskirq ]; 
    assign instr_waitirq  = instr[`Waitirq ];
    assign instr_timer    = instr[`Timer   ]; 
    assign instr_trap     = instr[`Trap    ];

    assign is_lui_auipc_jal                      = is[`Lui_auipc_jal                     ]; 
    assign is_lb_lh_lw_lbu_lhu                   = is[`Lb_lh_lw_lbu_lhu                  ];
    assign is_slli_srli_srai                     = is[`Slli_srli_srai                    ];
    assign is_jalr_addi_slti_sltiu_xori_ori_andi = is[`Jalr_addi_slti_sltiu_xori_ori_andi];
    assign is_sb_sh_sw                           = is[`Sb_sh_sw                          ]; 
    assign is_sll_srl_sra                        = is[`Sll_srl_sra                       ];
    assign is_lui_auipc_jal_jalr_addi_add        = is[`Lui_auipc_jal_jalr_addi_add       ];
    assign is_slti_blt_slt                       = is[`Slti_blt_slt                      ]; 
    assign is_sltiu_bltu_sltu                    = is[`Sltiu_bltu_sltu                   ];
    assign is_beq_bne_blt_bge_bltu_bgeu          = is[`Beq_bne_blt_bge_bltu_bgeu         ];
    assign is_lbu_lhu_lw                         = is[`Lbu_lhu_lw                        ]; 
    assign is_alu_reg_imm                        = is[`Alu_reg_imm                       ];
    assign is_alu_reg_reg                        = is[`Alu_reg_reg                       ]; 
    assign is_compare                            = is[`Compare                           ];
    assign is_rdcycle_rdcycleh_rdinstr_rdinstrh  = is[`Rdcycle_rdcycleh_rdinstr_rdinstrh ];

    opicorv32_decoder decoder1 (
      .clk              (clk              ),
      .resetn           (resetn           ),
      .mem_do_rinst     (mem_do_rinst     ),
      .mem_done         (mem_done         ),
      .mem_rdata_latched(mem_rdata_latched),
      .mem_rdata_q      (mem_rdata_q      ),
      .pcpi_insn        (pcpi_insn        ),

      .instr(instr), .is(is),

      .decoded_rd(decoded_rd), .decoded_rs1(decoded_rs1), .decoded_rs2(decoded_rs2),
      .decoded_imm(decoded_imm), .decoded_imm_uj(decoded_imm_uj),
    
      .decoder_trigger(decoder_trigger),
      //.decoder_trigger_q(decoder_trigger_q),
      .decoder_pseudo_trigger(decoder_pseudo_trigger)
    );

  end endgenerate

/*
    picorv32_instruction_decoder #(
      .ENABLE_COUNTERS  (ENABLE_COUNTERS  ),
      .ENABLE_REGS_16_31(ENABLE_REGS_16_31),
      .ENABLE_PCPI      (ENABLE_PCPI      ),
      .ENABLE_MUL       (ENABLE_MUL       ),
      .ENABLE_IRQ       (ENABLE_IRQ       ),
      .ENABLE_IRQ_QREGS (ENABLE_IRQ_QREGS ),
      .ENABLE_IRQ_TIMER (ENABLE_IRQ_TIMER ),
      .irqregs_offset   (irqregs_offset   ),
      .regindex_bits    (regindex_bits    )
    ) instruction_decoder (
      .clk              (clk              ),
      .resetn           (resetn           ),
      .mem_do_rinst     (mem_do_rinst     ),
      .mem_done         (mem_done         ),
      .mem_rdata_latched(mem_rdata_latched),
      .mem_rdata_q      (mem_rdata_q      ),
      .pcpi_insn        (pcpi_insn        ),

      .instr_lui(instr_lui), .instr_auipc(instr_auipc), .instr_jal(instr_jal),
      .instr_jalr(instr_jalr), .instr_beq(instr_beq), .instr_bne(instr_bne),
      .instr_blt(instr_blt), .instr_bge(instr_bge), .instr_bltu(instr_bltu),
      .instr_bgeu(instr_bgeu), .instr_lb(instr_lb), .instr_lh(instr_lh),
      .instr_lw(instr_lw), .instr_lbu(instr_lbu), .instr_lhu(instr_lhu),
      .instr_sb(instr_sb), .instr_sh(instr_sh), .instr_sw(instr_sw), .instr_addi(instr_addi),
      .instr_slti(instr_slti), .instr_sltiu(instr_sltiu), .instr_xori(instr_xori),
      .instr_ori(instr_ori), .instr_andi(instr_andi), .instr_slli(instr_slli),
      .instr_srli(instr_srli), .instr_srai(instr_srai), .instr_add(instr_add),
      .instr_sub(instr_sub), .instr_sll(instr_sll), .instr_slt(instr_slt),
      .instr_sltu(instr_sltu), .instr_xor(instr_xor), .instr_srl(instr_srl),
      .instr_sra(instr_sra), .instr_or(instr_or), .instr_and(instr_and),
      .instr_rdcycle(instr_rdcycle), .instr_rdcycleh(instr_rdcycleh),
      .instr_rdinstr(instr_rdinstr), .instr_rdinstrh(instr_rdinstrh),
      .instr_getq(instr_getq), .instr_setq(instr_setq), .instr_retirq(instr_retirq),
      .instr_maskirq(instr_maskirq), .instr_waitirq(instr_waitirq),
      .instr_timer(instr_timer), .instr_trap(instr_trap),

      .decoded_rd(decoded_rd), .decoded_rs1(decoded_rs1), .decoded_rs2(decoded_rs2),
      .decoded_imm(decoded_imm), .decoded_imm_uj(decoded_imm_uj),
    
      .decoder_trigger(decoder_trigger),
      .decoder_trigger_q(decoder_trigger_q),
      .decoder_pseudo_trigger(decoder_pseudo_trigger),

      .is_lui_auipc_jal(is_lui_auipc_jal), .is_lb_lh_lw_lbu_lhu(is_lb_lh_lw_lbu_lhu),
      .is_slli_srli_srai(is_slli_srli_srai),
      .is_jalr_addi_slti_sltiu_xori_ori_andi(is_jalr_addi_slti_sltiu_xori_ori_andi),
      .is_sb_sh_sw(is_sb_sh_sw), .is_sll_srl_sra(is_sll_srl_sra),
      .is_lui_auipc_jal_jalr_addi_add(is_lui_auipc_jal_jalr_addi_add),
      .is_slti_blt_slt(is_slti_blt_slt), .is_sltiu_bltu_sltu(is_sltiu_bltu_sltu),
      .is_beq_bne_blt_bge_bltu_bgeu(is_beq_bne_blt_bge_bltu_bgeu),
      .is_lbu_lhu_lw(is_lbu_lhu_lw), .is_alu_reg_imm(is_alu_reg_imm),
      .is_alu_reg_reg(is_alu_reg_reg), .is_compare(is_compare),
      .is_rdcycle_rdcycleh_rdinstr_rdinstrh(is_rdcycle_rdcycleh_rdinstr_rdinstrh)
    );

    wire [47:0] instr;
    reg [47:0] instrx;
    wire [14:0] is;
    reg [14:0] isx;

    wire [regindex_bits-1:0] decoded_rd_, decoded_rs1_, decoded_rs2_;
    wire              [31:0] decoded_imm_, decoded_imm_uj_;

    reg  [regindex_bits-1:0] decoded_rd_x, decoded_rs1_x, decoded_rs2_x;
    reg               [31:0] decoded_imm_x, decoded_imm_uj_x;
    
    opicorv32_decoder decoder1 (
      .clk              (clk              ),
      .resetn           (resetn           ),
      .mem_do_rinst     (mem_do_rinst     ),
      .mem_done         (mem_done         ),
      .mem_rdata_latched(mem_rdata_latched),
      .mem_rdata_q      (mem_rdata_q      ),
      .pcpi_insn        (),

      .instr(instr), .is(is),

      .decoded_rd(decoded_rd_), .decoded_rs1(decoded_rs1_), .decoded_rs2(decoded_rs2_),
      .decoded_imm(decoded_imm_), .decoded_imm_uj(decoded_imm_uj_),
    
      .decoder_trigger(decoder_trigger),
      //.decoder_trigger_q(decoder_trigger_q),
      .decoder_pseudo_trigger(decoder_pseudo_trigger)
    );

  always @* begin
    instrx[`Lui     ] = instr_lui      ; 
    instrx[`Auipc   ] = instr_auipc    ; 
    instrx[`Jal     ] = instr_jal      ;
    instrx[`Jalr    ] = instr_jalr     ; 
    instrx[`Beq     ] = instr_beq      ; 
    instrx[`Bne     ] = instr_bne      ;
    instrx[`Blt     ] = instr_blt      ; 
    instrx[`Bge     ] = instr_bge      ; 
    instrx[`Bltu    ] = instr_bltu     ;
    instrx[`Bgeu    ] = instr_bgeu     ; 
    instrx[`Lb      ] = instr_lb       ; 
    instrx[`Lh      ] = instr_lh       ;
    instrx[`Lw      ] = instr_lw       ; 
    instrx[`Lbu     ] = instr_lbu      ; 
    instrx[`Lhu     ] = instr_lhu      ;
    instrx[`Sb      ] = instr_sb       ; 
    instrx[`Sh      ] = instr_sh       ; 
    instrx[`Sw      ] = instr_sw       ; 
    instrx[`Addi    ] = instr_addi     ;
    instrx[`Slti    ] = instr_slti     ; 
    instrx[`Sltiu   ] = instr_sltiu    ; 
    instrx[`Xori    ] = instr_xori     ;
    instrx[`Ori     ] = instr_ori      ; 
    instrx[`Andi    ] = instr_andi     ; 
    instrx[`Slli    ] = instr_slli     ;
    instrx[`Srli    ] = instr_srli     ; 
    instrx[`Srai    ] = instr_srai     ; 
    instrx[`Add     ] = instr_add      ;
    instrx[`Sub     ] = instr_sub      ; 
    instrx[`Sll     ] = instr_sll      ; 
    instrx[`Slt     ] = instr_slt      ;
    instrx[`Sltu    ] = instr_sltu     ; 
    instrx[`Xor     ] = instr_xor      ; 
    instrx[`Srl     ] = instr_srl      ;
    instrx[`Sra     ] = instr_sra      ; 
    instrx[`Or      ] = instr_or       ; 
    instrx[`And     ] = instr_and      ;
    instrx[`Rdcycle ] = instr_rdcycle  ; 
    instrx[`Rdcycleh] = instr_rdcycleh ;
    instrx[`Rdinstr ] = instr_rdinstr  ; 
    instrx[`Rdinstrh] = instr_rdinstrh ;
    instrx[`Getq    ] = instr_getq     ; 
    instrx[`Setq    ] = instr_setq     ; 
    instrx[`Retirq  ] = instr_retirq   ;
    instrx[`Maskirq ] = instr_maskirq  ; 
    instrx[`Waitirq ] = instr_waitirq  ;
    instrx[`Timer   ] = instr_timer    ; 
    instrx[`Trap    ] = instr_trap     ;
    instrx = instrx ^ instr;

    isx[`Lui_auipc_jal                     ] = is_lui_auipc_jal                      ; 
    isx[`Lb_lh_lw_lbu_lhu                  ] = is_lb_lh_lw_lbu_lhu                   ;
    isx[`Slli_srli_srai                    ] = is_slli_srli_srai                     ;
    isx[`Jalr_addi_slti_sltiu_xori_ori_andi] = is_jalr_addi_slti_sltiu_xori_ori_andi ;
    isx[`Sb_sh_sw                          ] = is_sb_sh_sw                           ; 
    isx[`Sll_srl_sra                       ] = is_sll_srl_sra                        ;
    isx[`Lui_auipc_jal_jalr_addi_add       ] = is_lui_auipc_jal_jalr_addi_add        ;
    isx[`Slti_blt_slt                      ] = is_slti_blt_slt                       ; 
    isx[`Sltiu_bltu_sltu                   ] = is_sltiu_bltu_sltu                    ;
    isx[`Beq_bne_blt_bge_bltu_bgeu         ] = is_beq_bne_blt_bge_bltu_bgeu          ;
    isx[`Lbu_lhu_lw                        ] = is_lbu_lhu_lw                         ; 
    isx[`Alu_reg_imm                       ] = is_alu_reg_imm                        ;
    isx[`Alu_reg_reg                       ] = is_alu_reg_reg                        ; 
    isx[`Compare                           ] = is_compare                            ;
    isx[`Rdcycle_rdcycleh_rdinstr_rdinstrh ] = is_rdcycle_rdcycleh_rdinstr_rdinstrh  ;
    isx = isx ^ is;

    decoded_rd_x = decoded_rd ^ decoded_rd_;
    decoded_rs1_x = decoded_rs1 ^ decoded_rs1_;
    decoded_rs2_x = decoded_rs2 ^ decoded_rs2_;
    decoded_imm_x =  decoded_imm ^ decoded_imm_;
    decoded_imm_uj_x = decoded_imm_uj ^ decoded_imm_uj_;
  end
*/
endmodule

module picorv32_memif_wrap #(
	parameter [ 0:0] LATCHED_MEM_RDATA = 0
) (
	input             clk, resetn,

	input [31:0]      reg_op1, reg_op2, 
  input [31:0]      next_pc,

  output            mem_done,
  input             mem_ready,
  input             mem_do_rinst,
	output            mem_valid,
	output            mem_instr,
	output     [31:0] mem_addr,
	output     [31:0] mem_wdata,
	output     [ 3:0] mem_wstrb,
  input      [31:0] mem_rdata,
	output     [31:0] mem_rdata_latched,
  output     [31:0] mem_rdata_q,
  output     [31:0] mem_rdata_word,
  input      [1:0]  mem_wordsize,
  input             mem_do_prefetch,
  input             mem_do_rdata,
  input             mem_do_wdata,

	// Look-Ahead Interface
	output            mem_la_read,
	output            mem_la_write,
	output     [31:0] mem_la_addr,
	output     [31:0] mem_la_wdata,
	output     [ 3:0] mem_la_wstrb
);

  localparam hardcaml = 1;

  generate if (!hardcaml) begin
    picorv32_memif #( 
      .LATCHED_MEM_RDATA(LATCHED_MEM_RDATA) 
    ) memif (
      .clk              (clk              ), 
      .resetn           (resetn           ),
      .reg_op1          (reg_op1          ),
      .reg_op2          (reg_op2          ),
      .next_pc          (next_pc          ),
      .mem_done         (mem_done         ),
      .mem_ready        (mem_ready        ),
      .mem_do_rinst     (mem_do_rinst     ),
      .mem_valid        (mem_valid        ),
      .mem_instr        (mem_instr        ),
      .mem_addr         (mem_addr         ),
      .mem_wdata        (mem_wdata        ),
      .mem_wstrb        (mem_wstrb        ),
      .mem_rdata        (mem_rdata        ),
      .mem_rdata_latched(mem_rdata_latched),
      .mem_rdata_q      (mem_rdata_q      ),
      .mem_rdata_word   (mem_rdata_word   ),
      .mem_wordsize     (mem_wordsize     ),
      .mem_do_prefetch  (mem_do_prefetch  ),
      .mem_do_rdata     (mem_do_rdata     ),
      .mem_do_wdata     (mem_do_wdata     ),
      .mem_la_read      (mem_la_read      ),
      .mem_la_write     (mem_la_write     ),
      .mem_la_addr      (mem_la_addr      ),
      .mem_la_wdata     (mem_la_wdata     ),
      .mem_la_wstrb     (mem_la_wstrb     )
    );
  end else begin
    opicorv32_memif memif (
      .clk              (clk              ), 
      .resetn           (resetn           ),
      .reg_op1          (reg_op1          ),
      .reg_op2          (reg_op2          ),
      .next_pc          (next_pc          ),
      .mem_done         (mem_done         ),
      .mem_ready        (mem_ready        ),
      .mem_do_rinst     (mem_do_rinst     ),
      .mem_valid        (mem_valid        ),
      .mem_instr        (mem_instr        ),
      .mem_addr         (mem_addr         ),
      .mem_wdata        (mem_wdata        ),
      .mem_wstrb        (mem_wstrb        ),
      .mem_rdata        (mem_rdata        ),
      .mem_rdata_latched(mem_rdata_latched),
      .mem_rdata_q      (mem_rdata_q      ),
      .mem_rdata_word   (mem_rdata_word   ),
      .mem_wordsize     (mem_wordsize     ),
      .mem_do_prefetch  (mem_do_prefetch  ),
      .mem_do_rdata     (mem_do_rdata     ),
      .mem_do_wdata     (mem_do_wdata     ),
      .mem_la_read      (mem_la_read      ),
      .mem_la_write     (mem_la_write     ),
      .mem_la_addr      (mem_la_addr      ),
      .mem_la_wdata     (mem_la_wdata     ),
      .mem_la_wstrb     (mem_la_wstrb     )
    );
  end endgenerate

endmodule

module picorv32_alu_wrap (
  input [31:0] reg_op1, reg_op2,
  input instr_beq, instr_bne, instr_bge, instr_bgeu, instr_sub,
        instr_xori, instr_xor, instr_ori, instr_or, instr_andi,
        instr_and, is_compare, is_slti_blt_slt, is_sltiu_bltu_sltu,
        is_lui_auipc_jal_jalr_addi_add,
  output [31:0] alu_out,
  output alu_out_0
);

  localparam hardcaml = 0;

	generate if (!hardcaml) begin

    picorv32_alu alu_0 (
      .reg_op1(reg_op1), .reg_op2(reg_op2),
      .instr_beq(instr_beq), .instr_bne(instr_bne), .instr_bge(instr_bge),
      .instr_bgeu(instr_bgeu), .instr_sub(instr_sub), .instr_xori(instr_xori),
      .instr_xor(instr_xor), .instr_ori(instr_ori), .instr_or(instr_or),
      .instr_andi(instr_andi), .instr_and(instr_and), .is_compare(is_compare),
      .is_slti_blt_slt(is_slti_blt_slt), .is_sltiu_bltu_sltu(is_sltiu_bltu_sltu),
      .is_lui_auipc_jal_jalr_addi_add(is_lui_auipc_jal_jalr_addi_add),
      .alu_out(alu_out), .alu_out_0(alu_out_0)
    );

  end else begin

    reg [47:0] instr;
    reg [14:0] is;

    always @* begin
      instr = 0;
      is = 0;
      instr[`Beq] = instr_beq; 
      instr[`Bne] = instr_bne; 
      instr[`Bge] = instr_bge; 
      instr[`Bgeu] = instr_bgeu; 
      instr[`Sub] = instr_sub;
      instr[`Xori] = instr_xori; 
      instr[`Xor] = instr_xor; 
      instr[`Ori] = instr_ori; 
      instr[`Or] = instr_or; 
      instr[`Andi] = instr_andi;
      instr[`And] = instr_and; 
      is[`Compare] = is_compare; 
      is[`Slti_blt_slt] = is_slti_blt_slt; 
      is[`Sltiu_bltu_sltu] = is_sltiu_bltu_sltu;
      is[`Lui_auipc_jal_jalr_addi_add] = is_lui_auipc_jal_jalr_addi_add;
    end

    opicorv32_alu alu1 (
      .reg_op1(reg_op1), .reg_op2(reg_op2),
      .instr(instr), .is(is),
      .alu_out(alu_out), .alu_out_0(alu_out_0)
    );

  end endgenerate

endmodule


