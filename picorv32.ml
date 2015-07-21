
open HardCaml
open Signal.Comb
open Signal.Seq

module Options = struct

  let enable_counters = true
  let enable_regs_16_31 = true
  let enable_regs_dualport = true
  let latched_mem_rdata = false
  let enable_pcpi = false
  let enable_mul = true
  let enable_irq = true
  let enable_irq_qregs = true
  let enable_irq_timer = true
  let masked_irq = consti 32 0
  let latched_irq = consti 32 (-1)
  let progaddr_reset = consti 32 0
  let progaddr_irq = consti 32 16
  
  let mul_steps_at_once = 1

end

module Instr = struct

  type t = 
    | Lui | Auipc | Jal | Jalr | Beq | Bne | Blt | Bge | Bltu | Bgeu | Lb
    | Lh | Lw | Lbu | Lhu | Sb | Sh | Sw | Addi | Slti | Sltiu | Xori | Ori
    | Andi | Slli | Srli | Srai | Add | Sub | Sll | Slt | Sltu | Xor | Srl
    | Sra | Or | And | Rdcycle | Rdcycleh | Rdinstr | Rdinstrh | Getq | Setq
    | Retirq | Maskirq | Waitirq | Timer | Trap
    deriving(Enum,Bounded,Show)

  let name = "instr"

  let n = 1 + Enum.from_enum<t> Bounded.max_bound<t>

  let sel x b = let b = Enum.from_enum<t> b in x.[b:b]

  let cname x = "instr_" ^ (String.lowercase (Show_t.show x))

  let list = Enum_t.enum_from_to Bounded_t.min_bound Bounded_t.max_bound

end

module Is = struct

  type t = 
    | Lui_auipc_jal | Lb_lh_lw_lbu_lhu | Slli_srli_srai | Jalr_addi_slti_sltiu_xori_ori_andi
    | Sb_sh_sw | Sll_srl_sra | Lui_auipc_jal_jalr_addi_add | Slti_blt_slt
    | Sltiu_bltu_sltu | Beq_bne_blt_bge_bltu_bgeu | Lbu_lhu_lw | Alu_reg_imm
    | Alu_reg_reg | Compare | Rdcycle_rdcycleh_rdinstr_rdinstrh
    deriving(Enum,Bounded,Show)

  let name = "is"

  let n = 1 + Enum.from_enum<t> Bounded.max_bound<t>

  let sel x b = let b = Enum.from_enum<t> b in x.[b:b]

  let cname x = "is_" ^ (String.lowercase (Show_t.show x))

  let list = Enum_t.enum_from_to Bounded_t.min_bound Bounded_t.max_bound

end

let irq_timer = 0
let irq_sbreak = 1
let irq_buserror = 2

(* one hot control inputs. log depth muxes *)
let pmux1ht x = 
  snd @@ tree 2 
    (function [(c,d)] -> (c,d) 
            | [(a,b);(c,d)] -> (a|:c, mux2 a b d) 
            | _ -> failwith "") x

let cbool x = if x then vdd else gnd

let clock = input "clk" 1
let resetn = input "resetn" 1

let r_spec c = 
  Signal.Types.({ r_async with
    reg_clock = clock;
    reg_reset = resetn;
    reg_reset_level = gnd;
    reg_reset_value = c }) 

let reg ~c ~e ~d = reg (r_spec c) e d
let reg_fb ~c ~e ~w f = reg_fb (r_spec c) e w f
let g_reg ~c ~e ~n = Signal.Guarded.g_reg (r_spec c) e n

open Options

let irqregs_offset = if enable_regs_16_31 then 32 else 16

let regfile_size = (
  if enable_regs_16_31 then 32 else 16) +
  (if enable_irq && enable_irq_qregs then 4 else 0)

let regindex_bits = 
  (if enable_regs_16_31 then 5 else 4) + 
  (if enable_irq && enable_irq_qregs then 1 else 0)

let with_pcpi = enable_pcpi || enable_mul

(* instruction decoder *)

module Decoder = struct

  module I = interface
    mem_do_rinst[1] mem_done[1] 
    mem_rdata_latched[32] mem_rdata_q[32]
    decoder_trigger[1] decoder_trigger_q[1] decoder_pseudo_trigger[1]
  end

  module O = interface
    instr[Instr.n] is[Is.n]
    pcpi_insn[32] 
    decoded_rd[32] decoded_rs1[32] decoded_rs2[32]
    decoded_imm[32] decoded_imm_uj[32]
  end

  let decoder
    mem_rdata_q mem_rdata_latched 
    mem_do_rinst mem_done
    decoder_trigger decoder_pseudo_trigger
    = 
    let open Instr in
    let open Is in

    let enable_irq = cbool Options.enable_irq in
    let enable_irq_qregs = cbool Options.enable_irq_qregs in
    let enable_irq_timer = cbool Options.enable_irq_timer in
    let enable_counters = cbool Options.enable_counters in

    let reg e d = reg ~c:gnd ~e ~d in
    let r0 = reg vdd in
    let r1 = reg (mem_do_rinst &: mem_done) in
    let r2 = reg (decoder_trigger &: ~: (decoder_pseudo_trigger)) in

    let instr_lui   = r1 (mem_rdata_latched.[6:0] ==:. 0b0110111) in
    let instr_auipc = r1 (mem_rdata_latched.[6:0] ==:. 0b0010111) in
    let instr_jal   = r1 (mem_rdata_latched.[6:0] ==:. 0b1101111) in
    let instr_jalr  = r1 (mem_rdata_latched.[6:0] ==:. 0b1100111) in

    let is_beq_bne_blt_bge_bltu_bgeu = r1 (mem_rdata_latched.[6:0] ==:. 0b1100011) in
    let is_lb_lh_lw_lbu_lhu          = r1 (mem_rdata_latched.[6:0] ==:. 0b0000011) in
    let is_sb_sh_sw                  = r1 (mem_rdata_latched.[6:0] ==:. 0b0100011) in
    let is_alu_reg_imm               = r1 (mem_rdata_latched.[6:0] ==:. 0b0010011) in
    let is_alu_reg_reg               = r1 (mem_rdata_latched.[6:0] ==:. 0b0110011) in

    let instr = [
      Lui,     instr_lui;
      Auipc,   instr_auipc;
      Jal,     instr_jal;
      Jalr,    instr_jalr;
      Retirq,  r1 ((mem_rdata_latched.[6:0] ==:. 0b0001011) &: 
                  (mem_rdata_latched.[31:25] ==:. 0b0000010) &: enable_irq);
      Waitirq, r1 ((mem_rdata_latched.[6:0] ==:. 0b0001011) &: 
                  (mem_rdata_latched.[31:25] ==:. 0b0000100) &: enable_irq);

      Beq,   r2 (is_beq_bne_blt_bge_bltu_bgeu &: (mem_rdata_q.[14:12] ==:. 0b000));
      Bne,   r2 (is_beq_bne_blt_bge_bltu_bgeu &: (mem_rdata_q.[14:12] ==:. 0b001));
      Blt,   r2 (is_beq_bne_blt_bge_bltu_bgeu &: (mem_rdata_q.[14:12] ==:. 0b100));
      Bge,   r2 (is_beq_bne_blt_bge_bltu_bgeu &: (mem_rdata_q.[14:12] ==:. 0b101));
      Bltu,  r2 (is_beq_bne_blt_bge_bltu_bgeu &: (mem_rdata_q.[14:12] ==:. 0b110));
      Bgeu,  r2 (is_beq_bne_blt_bge_bltu_bgeu &: (mem_rdata_q.[14:12] ==:. 0b111));

      Lb,    r2 (is_lb_lh_lw_lbu_lhu &: (mem_rdata_q.[14:12] ==:. 0b000));
      Lh,    r2 (is_lb_lh_lw_lbu_lhu &: (mem_rdata_q.[14:12] ==:. 0b001));
      Lw,    r2 (is_lb_lh_lw_lbu_lhu &: (mem_rdata_q.[14:12] ==:. 0b010));
      Lbu,   r2 (is_lb_lh_lw_lbu_lhu &: (mem_rdata_q.[14:12] ==:. 0b100));
      Lhu,   r2 (is_lb_lh_lw_lbu_lhu &: (mem_rdata_q.[14:12] ==:. 0b101));

      Sb,    r2 (is_sb_sh_sw &: (mem_rdata_q.[14:12] ==:. 0b000));
      Sh,    r2 (is_sb_sh_sw &: (mem_rdata_q.[14:12] ==:. 0b001));
      Sw,    r2 (is_sb_sh_sw &: (mem_rdata_q.[14:12] ==:. 0b010));

      Addi,  r2 (is_alu_reg_imm &: (mem_rdata_q.[14:12] ==:. 0b000));
      Slti,  r2 (is_alu_reg_imm &: (mem_rdata_q.[14:12] ==:. 0b010));
      Sltiu, r2 (is_alu_reg_imm &: (mem_rdata_q.[14:12] ==:. 0b011));
      Xori,  r2 (is_alu_reg_imm &: (mem_rdata_q.[14:12] ==:. 0b100));
      Ori,   r2 (is_alu_reg_imm &: (mem_rdata_q.[14:12] ==:. 0b110));
      Andi,  r2 (is_alu_reg_imm &: (mem_rdata_q.[14:12] ==:. 0b111));

      Slli,  r2 (is_alu_reg_imm &: (mem_rdata_q.[14:12] ==:. 0b001) &: 
                                  (mem_rdata_q.[31:25] ==:. 0b0000000));
      Srli,  r2 (is_alu_reg_imm &: (mem_rdata_q.[14:12] ==:. 0b101) &: 
                                  (mem_rdata_q.[31:25] ==:. 0b0000000));
      Srai,  r2 (is_alu_reg_imm &: (mem_rdata_q.[14:12] ==:. 0b101) &: 
                                  (mem_rdata_q.[31:25] ==:. 0b0100000));

      Add,   r2 (is_alu_reg_reg &: (mem_rdata_q.[14:12] ==:. 0b000) &: 
                                  (mem_rdata_q.[31:25] ==:. 0b0000000));
      Sub,   r2 (is_alu_reg_reg &: (mem_rdata_q.[14:12] ==:. 0b000) &: 
                                  (mem_rdata_q.[31:25] ==:. 0b0100000));
      Sll,   r2 (is_alu_reg_reg &: (mem_rdata_q.[14:12] ==:. 0b001) &: 
                                  (mem_rdata_q.[31:25] ==:. 0b0000000));
      Slt,   r2 (is_alu_reg_reg &: (mem_rdata_q.[14:12] ==:. 0b010) &: 
                                  (mem_rdata_q.[31:25] ==:. 0b0000000));
      Sltu,  r2 (is_alu_reg_reg &: (mem_rdata_q.[14:12] ==:. 0b011) &: 
                                  (mem_rdata_q.[31:25] ==:. 0b0000000));
      Xor,   r2 (is_alu_reg_reg &: (mem_rdata_q.[14:12] ==:. 0b100) &: 
                                  (mem_rdata_q.[31:25] ==:. 0b0000000));
      Srl,   r2 (is_alu_reg_reg &: (mem_rdata_q.[14:12] ==:. 0b101) &: 
                                  (mem_rdata_q.[31:25] ==:. 0b0000000));
      Sra,   r2 (is_alu_reg_reg &: (mem_rdata_q.[14:12] ==:. 0b101) &: 
                                  (mem_rdata_q.[31:25] ==:. 0b0100000));
      Or,    r2 (is_alu_reg_reg &: (mem_rdata_q.[14:12] ==:. 0b110) &: 
                                  (mem_rdata_q.[31:25] ==:. 0b0000000));
      And,   r2 (is_alu_reg_reg &: (mem_rdata_q.[14:12] ==:. 0b111) &: 
                                  (mem_rdata_q.[31:25] ==:. 0b0000000));

      Rdcycle,  r2 ((((mem_rdata_q.[6:0] ==:. 0b1110011) &: 
                      (mem_rdata_q.[31:12] ==:. 0b11000000000000000010)) |:
                    ((mem_rdata_q.[6:0] ==:. 0b1110011) &: 
                      (mem_rdata_q.[31:12] ==:. 0b11000000000100000010))) &:
                    enable_counters);
      Rdcycleh, r2 ((((mem_rdata_q.[6:0] ==:. 0b1110011) &: 
                      (mem_rdata_q.[31:12] ==:. 0b11001000000000000010)) |:
                    ((mem_rdata_q.[6:0] ==:. 0b1110011) &: 
                      (mem_rdata_q.[31:12] ==:. 0b11001000000100000010))) &: 
                    enable_counters);
      Rdinstr,  r2 (((mem_rdata_q.[6:0] ==:. 0b1110011) &: 
                    (mem_rdata_q.[31:12] ==:. 0b11000000001000000010)) &: 
                    enable_counters);
      Rdinstrh, r2 (((mem_rdata_q.[6:0] ==:. 0b1110011) &: 
                    (mem_rdata_q.[31:12] ==:. 0b11001000001000000010)) &: 
                    enable_counters);

      Getq,    r2 ((mem_rdata_q.[6:0] ==:. 0b0001011) &: 
                  (mem_rdata_q.[31:25] ==:. 0b0000000) &: 
                  enable_irq &: enable_irq_qregs);
      Setq,    r2 ((mem_rdata_q.[6:0] ==:. 0b0001011) &: 
                  (mem_rdata_q.[31:25] ==:. 0b0000001) &: 
                  enable_irq &: enable_irq_qregs);
      Maskirq, r2 ((mem_rdata_q.[6:0] ==:. 0b0001011) &: 
                  (mem_rdata_q.[31:25] ==:. 0b0000011) &: 
                  enable_irq);
      Timer,   r2 ((mem_rdata_q.[6:0] ==:. 0b0001011) &: 
                  (mem_rdata_q.[31:25] ==:. 0b0000101) &: 
                  enable_irq &: enable_irq_timer);
    ] 
    in
    let instr = (Trap, ~: (reduce (|:) (List.map snd instr))) :: instr in
    let instr = 
      let name i = "instr_" ^ String.lowercase (Show.show<Instr.t> i) in
      List.map (fun (i,v) -> Enum.from_enum<Instr.t> i, v -- (name i)) instr
      |> List.sort (fun (a,_) (b,_) -> - (compare a b)) 
      |> List.map snd
      |> concat
    in

    let f l = reduce (|:) (List.map (Instr.sel instr) l) in
    let is = [
      Lui_auipc_jal,   r0 (f [Lui; Auipc; Jal]);
      Lui_auipc_jal_jalr_addi_add, 
                      r0 (f [Lui; Auipc; Jal; Jalr; Addi; Add]);
      Slti_blt_slt,    r0 (f [Slti; Blt; Slt]);
      Sltiu_bltu_sltu, r0 (f [Sltiu; Bltu; Sltu]);
      Lbu_lhu_lw,      r0 (f [Lbu; Lhu; Lw]);
      Compare,         r0 (f [Slti; Slt; Sltiu; Sltu] |: is_beq_bne_blt_bge_bltu_bgeu);
      Beq_bne_blt_bge_bltu_bgeu, is_beq_bne_blt_bge_bltu_bgeu;
      Lb_lh_lw_lbu_lhu,          is_lb_lh_lw_lbu_lhu;
      Sb_sh_sw,                  is_sb_sh_sw;
      Alu_reg_imm,               is_alu_reg_imm;
      Alu_reg_reg,               is_alu_reg_reg;
      Slli_srli_srai, r2 (is_alu_reg_imm &: (reduce (|:) [
        (mem_rdata_q.[14:12] ==:. 0b001) &: (mem_rdata_q.[31:25] ==:. 0b0000000);
        (mem_rdata_q.[14:12] ==:. 0b101) &: (mem_rdata_q.[31:25] ==:. 0b0000000);
        (mem_rdata_q.[14:12] ==:. 0b101) &: (mem_rdata_q.[31:25] ==:. 0b0100000)
      ]));
      Jalr_addi_slti_sltiu_xori_ori_andi, r2 (instr_jalr |: (is_alu_reg_imm &: (reduce (|:) [
        mem_rdata_q.[14:12] ==:. 0b000;
        mem_rdata_q.[14:12] ==:. 0b010;
        mem_rdata_q.[14:12] ==:. 0b011;
        mem_rdata_q.[14:12] ==:. 0b100;
        mem_rdata_q.[14:12] ==:. 0b110;
        mem_rdata_q.[14:12] ==:. 0b111
      ])));
      Sll_srl_sra, r2 (is_alu_reg_reg &: (reduce (|:) [
        (mem_rdata_q.[14:12] ==:. 0b001) &: (mem_rdata_q.[31:25] ==:. 0b0000000);
        (mem_rdata_q.[14:12] ==:. 0b101) &: (mem_rdata_q.[31:25] ==:. 0b0000000);
        (mem_rdata_q.[14:12] ==:. 0b101) &: (mem_rdata_q.[31:25] ==:. 0b0100000)
      ]));
      Rdcycle_rdcycleh_rdinstr_rdinstrh, f [Rdcycle; Rdcycleh; Rdinstr; Rdinstrh];
    ] in
    let is = 
      let name i = "is_" ^ String.lowercase (Show.show<Is.t> i) in
      List.map (fun (i,v) -> Enum.from_enum<Is.t> i, v -- name i) is
      |> List.sort (fun (a,_) (b,_) -> - (compare a b)) 
      |> List.map snd
      |> concat
    in

    instr, is

  let f i = 

    let open I in
      
    let enable_irq = cbool Options.enable_irq in
    let enable_irq_qregs = cbool Options.enable_irq_qregs in

    let reg e d = reg ~c:(zero (width d)) ~e ~d in
    let r1 = reg (i.mem_do_rinst &: i.mem_done) in
    let r2 = reg (i.decoder_trigger &: ~: (i.decoder_pseudo_trigger)) in

    let instr, is = decoder 
      i.mem_rdata_q i.mem_rdata_latched 
      i.mem_do_rinst i.mem_done
      i.decoder_trigger i.decoder_pseudo_trigger
    in

    let rs1 = 
      let c0 = ( 
        (i.mem_rdata_latched.[6:0] ==:. 0b0001011) &: 
        (i.mem_rdata_latched.[31:25] ==:. 0b0000000) &: 
        enable_irq &: enable_irq_qregs
      ) -- "c0" in
      let c1 = (
        (i.mem_rdata_latched.[6:0] ==:. 0b0001011) &:
        (i.mem_rdata_latched.[31:25] ==:. 0b0000010) &: 
        enable_irq
      ) -- "c1" in
      let rs1 = uresize i.mem_rdata_latched.[19:15] regindex_bits -- "cx" in
      mux2 c1 
        (consti regindex_bits (if Options.enable_irq_qregs then irqregs_offset else 3))
        (mux2 c0 (vdd @: lsbs rs1) rs1)
    in

    let decoded_imm_uj = 
      let d = sresize (i.mem_rdata_latched.[31:12] @: gnd) 32 in
      let rec f off = function
        | [] -> []
        | (h,l) :: tl -> 
          let w = h-l+1 in
          (l, select d (off+w-1) off) :: f (off + w) tl
      in
      r1 @@ concat @@ List.map snd @@  List.sort (fun a b -> compare (fst b) (fst a)) @@ 
        f 0 [0,0; 19,12; 11,11; 10,1; 31,20]
    in

    let decoded_imm = 
      let instr l = reduce (|:) (List.map (Instr.sel instr) l) in
      let is l = reduce (|:) (List.map (Is.sel is) l) in
      let open Instr in
      let open Is in
      let smap x l = List.map (fun (h,l) -> x.[h:l]) l in
      r2 (pmux [
        instr [Jal], 
          decoded_imm_uj;
        instr [Lui; Auipc], 
          i.mem_rdata_q.[31:12] @: zero 12;
        instr [Jalr] |: is [Lb_lh_lw_lbu_lhu; Alu_reg_imm], 
          sresize i.mem_rdata_q.[31:20] 32;
        is [Beq_bne_blt_bge_bltu_bgeu], 
          sresize (concat ((smap i.mem_rdata_q [(31,31); (7,7); (30,25); (11,8)]) @ [gnd])) 32;
        is [Sb_sh_sw], 
          sresize (concat (smap i.mem_rdata_q [(31,25); (11,7)])) 32;
      ] (zero 32))
    in

    O.({
      instr; is;
      decoded_rd = uresize (r1 i.mem_rdata_latched.[11:7]) regindex_bits;
      decoded_rs1 = r1 rs1;
      decoded_rs2 = uresize (r1 i.mem_rdata_latched.[24:20]) regindex_bits;
      pcpi_insn = if with_pcpi then r2 i.mem_rdata_q else zero 32;
      decoded_imm; decoded_imm_uj;
    })

  module I' = I
  module O' = interface
    instr_lui[1] instr_auipc[1] instr_jal[1] instr_jalr[1]
    instr_beq[1] instr_bne[1] instr_blt[1] instr_bge[1] instr_bltu[1] instr_bgeu[1]
    instr_lb[1] instr_lh[1] instr_lw[1] instr_lbu[1] instr_lhu[1] 
    instr_sb[1] instr_sh[1] instr_sw[1]
    instr_addi[1] instr_slti[1] instr_sltiu[1] instr_xori[1] 
    instr_ori[1] instr_andi[1] instr_slli[1] 
    instr_srli[1] instr_srai[1] instr_add[1] 
    instr_sub[1] instr_sll[1] instr_slt[1] instr_sltu[1] 
    instr_xor[1] instr_srl[1] instr_sra[1] instr_or[1] 
    instr_and[1] instr_rdcycle[1] instr_rdcycleh[1] 
    instr_rdinstr[1] instr_rdinstrh[1] instr_getq[1] 
    instr_setq[1] instr_retirq[1] instr_maskirq[1] 
    instr_waitirq[1] instr_timer[1] instr_trap[1]

    is_lui_auipc_jal[1] is_lb_lh_lw_lbu_lhu[1] is_slli_srli_srai[1]
    is_jalr_addi_slti_sltiu_xori_ori_andi[1] is_sb_sh_sw[1] is_sll_srl_sra[1]
    is_lui_auipc_jal_jalr_addi_add[1] is_slti_blt_slt[1] is_sltiu_bltu_sltu[1]
    is_beq_bne_blt_bge_bltu_bgeu[1] is_lbu_lhu_lw[1] is_alu_reg_imm[1]
    is_alu_reg_reg[1] is_compare[1]
    is_rdcycle_rdcycleh_rdinstr_rdinstrh[1]

    pcpi_insn[32] 
    decoded_rd[32] decoded_rs1[32] decoded_rs2[32]
    decoded_imm[32] decoded_imm_uj[32]
  end

  (* convert O -> O' so the verilog/ml interfaces are the same *)
  let conv_o o = 
    let instr_a = List.map (fun x -> Instr.cname x, Instr.sel o.O.instr x) Instr.list in
    let is_a = List.map (fun x -> Is.cname x, Is.sel o.O.is x) Is.list in
    let other_a = O.(to_list @@ map2 (fun (n,_) s -> n,s) t o) in
    O'.(map (fun (n,b) ->
      try List.assoc n instr_a with _ ->
      try List.assoc n is_a with _ ->
      List.assoc n other_a) t)

  let generics = 
    [
      "ENABLE_COUNTERS", Signal.Types.ParamInt(1);
      "ENABLE_REGS_16_31", Signal.Types.ParamInt(1);
      "ENABLE_PCPI", Signal.Types.ParamInt(0);
      "ENABLE_MUL", Signal.Types.ParamInt(0);
      "ENABLE_IRQ", Signal.Types.ParamInt(0);
      "ENABLE_IRQ_QREGS", Signal.Types.ParamInt(1);
      "ENABLE_IRQ_TIMER", Signal.Types.ParamInt(1);
      "irqregs_offset", Signal.Types.ParamInt(0);
      "regindex_bits", Signal.Types.ParamInt(0);
    ]

  let wrap i = 

    let o = Signal.Instantiation.inst "picorv32_instruction_decoder"
      generics
      I.(to_list @@ map2 (fun (n,_) s -> n, s) t i)
      O'.(to_list t)
    in

    let module X = Interface.Inst(I)(O) in
    let x = conv_o @@ X.make "opicorv32_decoder" i in

    let compare x y = 
      let c = (x ^: o#o y) -- ("compare_" ^ y) in
      c ^: x 
    in
    O'.(map2 (fun (n,b) c -> compare c n) t x)

end

module Alu = struct

  module I = interface
    reg_op1[32] reg_op2[32]
    instr[Instr.n] is[Is.n]
  end

  module O = interface
    alu_out[32]
    alu_out_0[1]
  end

  let f i = 
    let open I in
    let instr x = Instr.sel i.instr x in
    let is x = Is.sel i.is x in

    let alu_out_0 = pmux1ht [
      instr Instr.Beq, i.reg_op1 ==: i.reg_op2;
      instr Instr.Bne, i.reg_op1 <>: i.reg_op2;
      instr Instr.Bge, i.reg_op1 >=+ i.reg_op2;
      instr Instr.Bgeu, i.reg_op1 >=: i.reg_op2;
      is Is.Slti_blt_slt, i.reg_op1 <+ i.reg_op2;
      is Is.Sltiu_bltu_sltu, i.reg_op1 <: i.reg_op2;
    ] in
    
    let alu_out = pmux1ht [
      is Is.Lui_auipc_jal_jalr_addi_add, i.reg_op1 +: i.reg_op2;
      instr Instr.Sub, i.reg_op1 -: i.reg_op2;
      is Is.Compare, uresize alu_out_0 32;
      instr Instr.Xori |: instr Instr.Xor, i.reg_op1 ^: i.reg_op2;
      instr Instr.Ori |: instr Instr.Or, i.reg_op1 |: i.reg_op2;
      instr Instr.Andi |: instr Instr.And, i.reg_op1 &: i.reg_op2;
    ] in

    O.({
      alu_out;
      alu_out_0;
    })

  module I' = interface
    reg_op1[32] reg_op2[32]
    instr_beq[1] instr_bne[1] instr_bge[1] instr_bgeu[1]
    instr_sub[1] instr_xori[1] instr_xor[1] instr_ori[1]
    instr_or[1] instr_andi[1] instr_and[1] is_compare[1]
    is_slti_blt_slt[1] is_sltiu_bltu_sltu[1]
    is_lui_auipc_jal_jalr_addi_add[1]
  end
  module O' = O

  let conv_i' i' = 
    let i'a = I'.(to_list @@ map2 (fun (n,b) s -> n,s) t i') in
    let instr = concat @@ List.rev @@ Array.to_list @@ Array.init Instr.n 
      (fun i -> try List.assoc Instr.(cname (Enum_t.to_enum i)) i'a with _ -> gnd) 
    in
    let is = concat @@ List.rev @@ Array.to_list @@ Array.init Is.n 
      (fun i -> try List.assoc Is.(cname (Enum_t.to_enum i)) i'a with _ -> gnd) 
    in
    I.({ instr; is; reg_op1 = i'.reg_op1; reg_op2 = i'.reg_op2 })

  let wrap i' = 

    let o = Signal.Instantiation.inst "picorv32_alu" [] 
      I'.(to_list @@ map2 (fun (n,b) s -> n,s) t i')
      O.(to_list t)
    in

    let module X = Interface.Inst(I)(O) in
    let x = X.make "opicorv32_alu" (conv_i' i') in
    let compare x y = 
      let c = (x ^: o#o y) -- ("compare_" ^ y) in
      c ^: x 
    in
    O.(map2 (fun (n,b) c -> compare c n) t x)

end

module Memif = struct

  module I = interface
    reg_op1[32] reg_op2[32] next_pc[32]
    mem_ready[1] mem_do_rinst[1] mem_rdata[32]
    mem_wordsize[2] mem_do_prefetch[1] mem_do_rdata[1] mem_do_wdata[1]
  end

  module O = interface
    mem_done[1] mem_valid[1] mem_instr[1] mem_addr[32] mem_wdata[32]
    mem_wstrb[4] mem_rdata_latched[32] mem_rdata_q[32] mem_rdata_word[32]
    mem_la_read[1] mem_la_write[1] mem_la_addr[32] mem_la_wdata[32] mem_la_wstrb[4]
  end

  module I' = I
  module O' = O

  let f i = 
    let open I in

    let latched_mem_rdata = cbool Options.latched_mem_rdata in
    let is, sm, next = 
      Signal.Statemachine.statemachine (r_spec (zero 2)) vdd [0;1;2;3] 
    in
    let mem_state_n0, mem_state_3, mem_state_0 = ~: (is 0), is 3, is 0 in
    let mem_valid = g_reg ~c:gnd ~e:vdd ~n:1 in

    let mem_busy = 
      reduce (|:) [i.mem_do_prefetch; i.mem_do_rinst; i.mem_do_rdata; i.mem_do_wdata] 
    in
    let mem_done = 
      (i.mem_ready &: mem_state_n0 &: (i.mem_do_rinst |: i.mem_do_rdata |: i.mem_do_wdata)) |: 
      (mem_state_3 &: i.mem_do_rinst)
    in

    let mem_la_write = resetn &: mem_state_0 &: i.mem_do_wdata in
    let mem_la_read = 
      resetn &: mem_state_0 &: 
      (i.mem_do_rinst |: i.mem_do_prefetch |: i.mem_do_rdata)
    in
    let mem_la_addr = 
      mux2 (i.mem_do_prefetch |: i.mem_do_rinst) i.next_pc (i.reg_op1.[31:2] @: zero 2)
    in

    let mem_rdata_latched = wire 32 in
    let mem_rdata_q = reg ~c:(zero 32) ~e:(mem_valid#q &: i.mem_ready) ~d:mem_rdata_latched in
    let () = mem_rdata_latched <== 
      mux2 ((mem_valid#q &: i.mem_ready) |: latched_mem_rdata) i.mem_rdata mem_rdata_q 
    in

    let mem_la_wdata = mux i.mem_wordsize 
      (List.map (fun n -> repeat i.reg_op2.[(32/n)-1:0] n) [1;2;4])
    in
    let mem_la_wstrb = mux i.mem_wordsize
      [
        constb "1111";
        mux2 i.reg_op1.[1:1] (constb "1100") (constb "0011");
        mux i.reg_op1.[1:0] (List.map (consti 4) [1;2;4;8]);
      ]
    in
    let mem_rdata_word = mux i.mem_wordsize
      [
        i.mem_rdata;
        mux i.reg_op1.[1:1] [uresize i.mem_rdata.[15:0] 32; uresize i.mem_rdata.[31:16] 32];
        mux i.reg_op1.[1:0] (List.map (fun n -> uresize i.mem_rdata.[n+7:n] 32) [0;8;16;23]);
      ]
    in

    let mem_addr = g_reg ~c:(zero 32) ~e:vdd ~n:32 in
    let mem_wdata = g_reg ~c:(zero 32) ~e:vdd ~n:32 in
    let mem_wstrb = g_reg ~c:(zero 4) ~e:vdd ~n:4 in
    let mem_instr = g_reg ~c:gnd ~e:vdd ~n:1 in
    let () = 
      let open Signal.Guarded in
      compile [
        sm [
          0, [
            mem_addr $== mem_la_addr;
            mem_wdata $== mem_la_wdata;
            mem_wstrb $== mem_la_wstrb;
            g_when (i.mem_do_prefetch |: i.mem_do_rinst |: i.mem_do_rdata) [
              mem_valid $== vdd;
              mem_instr $== (i.mem_do_prefetch |: i.mem_do_rinst);
              mem_wstrb $== (zero 4);
              next 1;
            ];
            g_when (i.mem_do_wdata) [
              mem_valid $== vdd;
              mem_instr $== gnd;
              next 2;
            ];
          ];
          1, [
            g_when i.mem_ready [
              mem_valid $== gnd;
              g_if (i.mem_do_rinst |: i.mem_do_rdata) [ next 0 ] [ next 3 ]
            ];
          ];
          2, [
            g_when i.mem_ready [ mem_valid $== gnd; next 0; ];
          ];
          3, [
            g_when i.mem_do_rinst [ next 0; ];
          ];
        ]
      ] 
    in

    let mem_valid, mem_instr, mem_addr, mem_wdata, mem_wstrb = 
      mem_valid#q, mem_instr#q, mem_addr#q, mem_wdata#q, mem_wstrb#q
    in
    O.({
      mem_done; mem_valid; mem_instr; mem_addr; mem_wdata;
      mem_wstrb; mem_rdata_latched; mem_rdata_q; mem_rdata_word;
      mem_la_read; mem_la_write; mem_la_addr; mem_la_wdata; mem_la_wstrb;
    })

  let wrap i = 

    let o = Signal.Instantiation.inst "picorv32_memif" [] 
      I.(to_list @@ map2 (fun (n,b) s -> n,s) t i)
      O.(to_list t)
    in

    let module X = Interface.Inst(I)(O) in
    let x = X.make "opicorv32_memif" i in
    let compare x y = 
      let c = (x ^: o#o y) -- ("compare_" ^ y) in
      c ^: x 
    in
    O.(map2 (fun (n,b) c -> compare c n) t x)

end

module Pcpi = struct

  module I = interface
    valid[1] insn[32] rs1[32] rs2[32]
  end

  module O = interface
    wr[1] rd[32] wait_[1] ready[1]
  end

end

module Mul = struct
  
  module I = Pcpi.I
  module O = Pcpi.O
  
  let f i = 
    let open I in

    let sel = 
      resetn &: i.valid &: (i.insn.[6:0] ==:. 0b0110011) &: (i.insn.[31:25] ==:. 0b0000001)
    in
    let mul    = reg ~c:gnd ~e:vdd ~d:(sel &: (i.insn.[14:12] ==:. 0)) in
    let mulh   = reg ~c:gnd ~e:vdd ~d:(sel &: (i.insn.[14:12] ==:. 1)) in
    let mulhsu = reg ~c:gnd ~e:vdd ~d:(sel &: (i.insn.[14:12] ==:. 2)) in
    let mulhu  = reg ~c:gnd ~e:vdd ~d:(sel &: (i.insn.[14:12] ==:. 3)) in

    let any_mul = reduce (|:) [ mul; mulh; mulhsu; mulhu ] in
    let any_mulh = reduce (|:) [ mulh; mulhsu; mulhu ] in
    let rs1_signed = reduce (|:) [ mulh; mulhsu ] in
    let rs2_signed = mulh in

    let wait_ = reg ~c:gnd ~e:vdd ~d:any_mul in
    let wait_q = reg ~c:gnd ~e:vdd ~d:wait_ in

    let start = wait_ &: (~: wait_q) in

    let rec csa i ((rd, rdx, rs1, rs2) as x) = 
      if i >= Options.mul_steps_at_once then x
      else
        let rdt' = rd ^: rdx in
        let rdt = mux2 rs1.[0:0] (rdt' ^: rs2) rdt' in
        let rdx' = rd &: rdx in
        let rdx = sll (mux2 rs1.[0:0] (rdx' |: (rd &: rs2) |: (rdx &: rs2)) rdx') 1 in
        let rd = rdt in
        let rs1 = srl rs1 1 in
        let rs2 = sll rs2 1 in
        csa (i+1) (rd, rdx, rs1, rs2) 
    in

    let rd, rdx, rs1, rs2 = 
      let r () = g_reg ~c:(zero 64) ~e:vdd ~n:64 in
      r (), r (), r (), r () 
    in
    let next_rd, next_rdx, next_rs1, next_rs2 = csa 0 (rd#q, rdx#q, rs1#q, rs2#q) in

    let counter = g_reg ~c:(zero 7) ~e:vdd ~n:7 in
    let waiting = g_reg ~c:vdd ~e:vdd ~n:1 in
    let finish = g_reg ~c:gnd ~e:vdd ~n:1 in

    let () = 
      let open Signal.Guarded in
      compile [
        finish $== gnd;
        g_if waiting#q [
          rs1 $== (mux2 rs1_signed (sresize i.rs1 64) (uresize i.rs1 64));
          rs2 $== (mux2 rs2_signed (sresize i.rs2 64) (uresize i.rs2 64));
          rd $==. 0;
          rdx $==. 0;
          counter $== (mux2 any_mulh 
            (consti 7 (63 - Options.mul_steps_at_once)) 
            (consti 7 (31 - Options.mul_steps_at_once)));
          waiting $== (~: start);
        ] [
          rd $== next_rd;
          rdx $== next_rdx;
          rs1 $== next_rs1;
          rs2 $== next_rs2;
          counter $== counter#q -:. Options.mul_steps_at_once;
          g_when counter#q.[6:6] [
            finish $== vdd;
            waiting $== vdd;
          ];
        ];
      ]
    in

    let wr = reg ~c:gnd ~e:vdd ~d:finish#q in
    let ready = reg ~c:gnd ~e:vdd ~d:finish#q in
    let rd = reg ~c:(zero 32) ~e:finish#q ~d:(mux2 any_mulh rd#q.[63:32] rd#q.[31:0]) in

    O.({
      wr;
      rd;
      wait_;
      ready;
    })

  module I' = I
  module O' = O

  let wrap i = 

    let o = Signal.Instantiation.inst "picorv32_mul" [] 
      I.(to_list @@ map2 (fun (n,b) s -> n,s) t i)
      O.(to_list t)
    in

    let module X = Interface.Inst(I)(O) in
    let x = X.make "opicorv32_mul" i in
    let compare x y = 
      let c = (x ^: o#o y) -- ("compare_" ^ y) in
      c ^: x 
    in
    O.(map2 (fun (n,b) c -> compare c n) t x)

end

module Pcpi_if = struct

  module I = interface
    (i : Pcpi.I)
    (o : Pcpi.O)
  end

  module O = Pcpi.O

  let f i = 
    let open I in
    let open Pcpi.O in

    let z = Pcpi.O.(map (fun (_,b) -> zero b) t) in 
    let mul = if Options.enable_mul then Mul.f i.i else z in

    let en_pcpi = cbool Options.enable_pcpi in
    let en_mul = cbool Options.enable_mul in

    let wait_ = (en_pcpi &: i.o.wait_) |: (en_mul &: mul.wait_) in
    let pcpi_ready, mul_ready = en_pcpi &: i.o.ready, en_mul &: mul.ready in
    let ready = pcpi_ready |: mul_ready in
    let wr = pmux [ pcpi_ready, i.o.wr; mul_ready, mul.wr ] gnd in
    let rd = pmux [ pcpi_ready, i.o.rd; mul_ready, mul.rd ] (zero 32) in

    O.({ wr; rd; wait_; ready })

  module I' = I
  module O' = O

  let wrap = f (* XXX *)

end

module Rf = struct

  module I = interface
    wr[1] wa[regindex_bits] d[32]
    ra1[regindex_bits] ra2[regindex_bits]
  end

  module O = interface
    q1[32] q2[32]
  end

  let f i = 
    let open I in
    let wen = binary_to_onehot i.wa in
    let regs = 
      Array.to_list @@
      Array.init regfile_size (fun j -> reg ~c:(zero 32) ~e:(i.wr &: wen.[j:j]) ~d:i.d) 
    in
    O.({
      q1 = mux i.ra1 regs;
      q2 = mux i.ra2 regs;
    })

  module I' = I
  module O' = O

  let wrap i = 

    let o = Signal.Instantiation.inst "picorv32_rf" [] 
      I.(to_list @@ map2 (fun (n,b) s -> n,s) t i)
      O.(to_list t)
    in

    let module X = Interface.Inst(I)(O) in
    let x = X.make "opicorv32_rf" i in
    let compare x y = 
      let c = (x ^: o#o y) -- ("compare_" ^ y) in
      c ^: x 
    in
    O.(map2 (fun (n,b) c -> compare c n) t x)

end

module Control = struct

  module I = interface
    instr[Instr.n] is[Is.n]
    mem_rdata_word[32] mem_done[1]
    pcpi_int_ready[1] pcpi_int_wait[1]
    pcpi_int_wr[1] pcpi_int_rd[32]
    decoded_rd[regindex_bits] decoded_rs1[regindex_bits] decoded_rs2[regindex_bits]
    decoded_imm[32] decoded_imm_uj[32]
    irq[32]
  end

  module O = interface
    next_pc[32] reg_op1[32] reg_op2[32]
    trap[1]
    mem_do_rinst[1] mem_do_wdata[1] mem_do_rdata[1]
    mem_wordsize[2] mem_do_prefetch[1]
    pcpi_valid[1]
    decoder_trigger[1] decoder_trigger_q[1] decoder_pseudo_trigger[1]
    eoi[32]
  end

  let f i = 
    let open I in
    let open O in

    let enable_pcpi = cbool Options.enable_pcpi in
    let enable_mul = cbool Options.enable_mul in
    let enable_irq = cbool Options.enable_irq in
    let enable_irq_timer = cbool Options.enable_irq_timer in
    let enable_irq_qregs = cbool Options.enable_irq_qregs in
    let enable_counters = cbool Options.enable_counters in
    let enable_regs_dualport = cbool Options.enable_regs_dualport in
    
    let is_cpu, sm_cpu, next_cpu = 
      Signal.Statemachine.statemachine (r_spec gnd) vdd 
        [ `trap; `fetch; `ld_rs1; `ld_rs2; `exec; `shift; `stmem; `ldmem ]
    in

    let regn n = g_reg ~c:(zero n) ~e:vdd ~n in
    let reg1 () = regn 1 in
    let reg5 () = regn 5 in
    let reg32 () = regn 32 in
    let reg64 () = regn 64 in

    let ro = O.(map (fun (_,b) -> g_reg ~c:(zero b) ~e:vdd ~n:b) t) in

    let pcpi_timeout = 
      if with_pcpi then 
        let timeout = g_reg ~c:gnd ~e:vdd ~n:1 in
        let counter = g_reg ~c:(ones 4) ~e:vdd ~n:4 in
        let () = 
          Signal.Guarded.(compile [
            g_if (ro.pcpi_valid#q &: (~: (i.pcpi_int_wait))) [
              g_when (counter#q <>:. 0) 
                [ counter $== counter#q -:. 1 ] 
            ] [ 
              counter $==. (-1) 
            ];
            timeout $== (counter#q ==:. 0)
          ])
        in timeout#q
      else gnd
    in

    let count_cycle = 
      if not Options.enable_counters then zero 64
      else reg_fb ~c:(zero 64) ~e:vdd ~w:64 (fun d -> d +:. 1)
    in
 
    (* register file *)
    let latched_rd = g_reg ~c:(zero regindex_bits) ~e:vdd ~n:regindex_bits in
    let rf_wr, rf_d = Signal.Guarded.(g_wire gnd, g_wire (zero 32)) in
    let rfi = Rf.I.({
      wa = latched_rd#q;
      wr = rf_wr#q;
      d = rf_d#q;
      ra1 = i.decoded_rs1;
      ra2 = i.decoded_rs2;
    }) in
    let write_rf d = 
      Signal.Guarded.(g_proc [
        rf_wr $== vdd;
        rf_d $== d;
      ])
    in
    let rfo = Rf.f rfi in

    (* alu *)
    let alu = Alu.f Alu.I.({ reg_op1=ro.reg_op1#q; reg_op2=ro.reg_op2#q; 
                             instr=i.instr; is=i.is }) in

    (* statemachine *)
    let opt b f = Signal.Guarded.(if b then g_proc f else g_proc []) in

    let do_waitirq = reg1 () in

    let count_instr = reg64() in
    let latched_store, latched_stalu, latched_branch = reg1(), reg1(), reg1() in
    let latched_is_lu, latched_is_lh, latched_is_lb = reg1(), reg1(), reg1() in
    let reg_pc, reg_next_pc, reg_out, reg_alu_out = reg32(), reg32(), reg32(), reg32() in
    let reg_sh = reg5 () in

    let irq_state = g_reg ~c:(zero 2) ~e:vdd ~n:2 in
    let irq_active = reg1 () in
    let irq_pending = reg32 () in
    let irq_mask = Array.init 32 (fun _ -> reg1 ()) in
    let irq_mask_vec = concat @@ List.rev @@ List.map (fun x -> x#q) @@ Array.to_list irq_mask in

    let timer = reg32 () in

    (* XXX TODO XXX *)
    let current_pc = zero 32 in
    (* XXXXXXXXXXXXXXXXXXXXXX *)

    let instr x = Instr.sel i.instr x in
    let is x = Is.sel i.is x in

    (* states *)
    let trap = `trap, Signal.Guarded.([ ro.trap $== vdd ]) in

    let fetch = `fetch, Signal.Guarded.([
      ro.mem_do_rinst $== ((~: (ro.decoder_trigger#q)) &: (~: (do_waitirq#q)));
      ro.mem_wordsize $==. 0;

      (*current_pc $== reg_next_pc;*)

      g_if latched_branch#q [
        (*current_pc = latched_store ? (latched_stalu ? reg_alu_out : reg_out) : reg_next_pc;*)
        write_rf (reg_pc#q +:. 4);
      ] @@ g_elif latched_store#q [
        write_rf (mux2 latched_stalu#q reg_alu_out#q reg_out#q);
      ] @@ g_elif (enable_irq &: irq_state#q.[0:0]) [
        write_rf current_pc;
        (*current_pc = PROGADDR_IRQ;*)
        irq_active $==. 1;
        ro.mem_do_rinst $==. 1;
      ] @@ g_elif (enable_irq &: irq_state#q.[1:1]) [
        ro.eoi $== (irq_pending#q &: (~: irq_mask_vec));
        write_rf (irq_pending#q &: (~: irq_mask_vec));
        (*next_irq_pending = next_irq_pending & irq_mask;*)
      ] [];

      reg_pc $== current_pc;
      reg_next_pc $== current_pc;

      latched_store $==. 0;
      latched_stalu $==. 0;
      latched_branch $==. 0;
      latched_is_lu $==. 0;
      latched_is_lh $==. 0;
      latched_is_lb $==. 0;
      latched_rd $== i.decoded_rd;

      g_if (enable_irq &: 
            ((ro.decoder_trigger#q &: (~: (irq_active#q)) &: 
             reduce (|:) (bits (irq_pending#q &: (~: irq_mask_vec)))) |: 
             irq_state#q)) [
          irq_state $==
            mux2 (irq_state#q ==:. 0b00) (consti 2 0b01) @@
            mux2 (irq_state#q ==:. 0b01) (consti 2 0b10) (consti 2 0b00);
          g_if (enable_irq_qregs) [
            latched_rd $== ((consti regindex_bits irqregs_offset) |: irq_state#q.[0:0]);
          ] [ 
            g_if irq_state#q.[0:0] [ latched_rd $==. 4 ] [ latched_rd $==. 3 ]
          ]
      ] @@ g_elif (enable_irq &: (ro.decoder_trigger#q |: do_waitirq#q) &: instr Instr.Waitirq) [
        g_if irq_pending#q [
          latched_store $==. 1;
          reg_out $== irq_pending#q;
          reg_next_pc $== current_pc +:. 4;
          ro.mem_do_rinst $==. 1;
        ] [
          do_waitirq $==. 1;
        ]
      ] @@ g_elif ro.decoder_trigger#q [
          reg_next_pc $== current_pc +:. 4;
          g_when (enable_counters) [ count_instr $== count_instr#q +:. 1; ];
          g_if (instr Instr.Jal) [
            ro.mem_do_rinst $==. 1;
            reg_next_pc $== current_pc +: i.decoded_imm_uj;
            latched_branch $==. 1;
          ] [
            ro.mem_do_rinst $==. 0;
            ro.mem_do_prefetch $== ((~: (instr Instr.Jalr)) &: (~: (instr Instr.Retirq)));
            next_cpu `ld_rs1;
          ]
      ] []
    ]) in

    let z_rs1 = mux2 i.decoded_rs1 rfo.Rf.O.q1 (zero 32) in
    let z_rs2 = mux2 i.decoded_rs2 rfo.Rf.O.q2 (zero 32) in

    let ld_rs1 = `ld_rs1, Signal.Guarded.([

      ro.reg_op1 $== zero 32;
      ro.reg_op2 $== zero 32;

      g_if (instr Instr.Trap) [
        g_if (cbool with_pcpi) [
          ro.reg_op1 $== z_rs1;
          g_if (enable_regs_dualport) [
            ro.pcpi_valid $==. 1;
            reg_sh $== z_rs2;
            ro.reg_op2 $== z_rs2;
            g_if (i.pcpi_int_ready) [
              ro.mem_do_rinst $==. 1;
              ro.pcpi_valid $==. 0;
              reg_out $== i.pcpi_int_rd;
              latched_store $== i.pcpi_int_wr;
              next_cpu `fetch;
            ] @@ g_elif (pcpi_timeout) [
              g_if (enable_irq &: (~: (irq_mask.(irq_sbreak)#q)) &: (~: (irq_active#q))) [
                (*next_irq_pending[irq_sbreak] = 1;*)
                next_cpu `fetch;
              ] [
                next_cpu `trap;
              ]
            ] []
          ] [
            next_cpu `ld_rs2;
          ]
        ] [
          g_if (enable_irq &: (~: (irq_mask.(irq_sbreak)#q)) &: (~: (irq_active#q))) [
            (*next_irq_pending[irq_sbreak] = 1;*)
            next_cpu `fetch;
          ] [
            next_cpu `trap;
          ]
        ]
      ] @@ g_elif (is Is.Rdcycle_rdcycleh_rdinstr_rdinstrh) [
        reg_out $== (pmux1ht [
          instr Instr.Rdcycle, count_cycle.[31:0];
          instr Instr.Rdcycleh, count_cycle.[63:32];
          instr Instr.Rdinstr, count_instr#q.[31:0];
          instr Instr.Rdinstrh, count_instr#q.[63:32];
        ]);
        latched_store $==. 1;
        next_cpu `fetch;
      ] @@ g_elif (is Is.Lui_auipc_jal) [
        ro.reg_op1 $== mux2 (instr Instr.Lui) (zero 32) reg_pc#q;
        ro.reg_op2 $== i.decoded_imm;
        ro.mem_do_rinst $== ro.mem_do_prefetch#q;
        next_cpu `exec;
      ] @@ g_elif (enable_irq &: enable_irq_qregs &: instr Instr.Getq) [
        reg_out $== rfo.Rf.O.q1;
        latched_store $==. 1;
        next_cpu `fetch;
      ] @@ g_elif (enable_irq &: enable_irq_qregs &: instr Instr.Setq) [
        reg_out $== rfo.Rf.O.q1;
        latched_rd $== (latched_rd#q |: consti regindex_bits irqregs_offset);
        latched_store $==. 1;
        next_cpu `fetch;
      ] @@ g_elif (enable_irq &: instr Instr.Retirq) [
        ro.eoi $==. 0;
        irq_active $==. 0;
        latched_branch $==. 1;
        latched_store $==. 1;
        reg_out $== rfo.Rf.O.q1;
        next_cpu `fetch;
      ] @@ g_elif (enable_irq &: instr Instr.Maskirq) [
        latched_store $==. 1;
        reg_out $== irq_mask_vec;
        (*irq_mask $== (mux2 decoded_rs1 rfo.Rf.O.q1 (zero 32)) |: Options.masked_irq;*)
        (let irq_mask' = z_rs1 |: Options.masked_irq in
        g_proc @@ Array.to_list @@ Array.init 32 (fun i -> irq_mask.(i) $== irq_mask'.[i:i]));
        next_cpu `fetch;
      ] @@ g_elif (enable_irq &: enable_irq_timer &: instr Instr.Timer) [
        latched_store $==. 1;
        reg_out $== timer#q;
        timer $== z_rs1;
        next_cpu `fetch;
      ] [
        ro.reg_op1 $== z_rs1;
        g_if (is Is.Lb_lh_lw_lbu_lhu) [
          next_cpu `ldmem;
          ro.mem_do_rinst $==. 1;
        ] @@ g_elif (is Is.Slli_srli_srai) [
          reg_sh $== i.decoded_rs2;
          next_cpu `shift;
        ] @@ g_elif (is Is.Jalr_addi_slti_sltiu_xori_ori_andi) [
          ro.reg_op2 $== i.decoded_imm;
          ro.mem_do_rinst $== ro.mem_do_prefetch#q;
          next_cpu `exec;
        ] @@ g_elif (enable_regs_dualport) [
          reg_sh $== z_rs2;
          ro.reg_op2 $== z_rs1;
          g_if (is Is.Sb_sh_sw) [
            next_cpu `stmem;
            ro.mem_do_rinst $==. 1;
          ] @@ g_elif (is Is.Sll_srl_sra) [
            next_cpu `shift;
          ] [
            ro.mem_do_rinst $== ro.mem_do_prefetch#q;
            next_cpu `exec;
          ]
        ] [
          next_cpu `ld_rs2;
        ]
      ]
      
    ]) in

    let ld_rs2 = `ld_rs2, Signal.Guarded.([
    
      reg_sh $== z_rs2;
      ro.reg_op2 $== z_rs2;

      g_if (cbool with_pcpi &: instr Instr.Trap) [
        ro.pcpi_valid $==. 1;
        g_if (i.pcpi_int_ready) [
          ro.mem_do_rinst $==. 1;
          ro.pcpi_valid $==. 0;
          reg_out $== i.pcpi_int_rd;
          latched_store $== i.pcpi_int_wr;
          next_cpu `fetch;
        ] @@ g_elif (pcpi_timeout) [
          g_if (enable_irq &: (~: (irq_mask.(irq_sbreak)#q)) &: (~: (irq_active#q))) [
            (*next_irq_pending[irq_sbreak] = 1;*)
            next_cpu `fetch;
          ] [
            next_cpu `trap;
          ]
        ] []
      ] @@ g_elif (is Is.Sb_sh_sw) [
        next_cpu `stmem;
        ro.mem_do_rinst $==. 1;
      ] @@ g_elif (is Is.Sll_srl_sra) [
        next_cpu `shift;
      ] [
        ro.mem_do_rinst $== ro.mem_do_prefetch#q;
        next_cpu `exec;
      ]

    ]) in

    let exec = `exec, Signal.Guarded.([
      latched_store $== alu.Alu.O.alu_out_0;
      latched_branch $== alu.Alu.O.alu_out_0;
      reg_out $== reg_pc#q +: i.decoded_imm;
      g_if (is Is.Beq_bne_blt_bge_bltu_bgeu) [
        latched_rd $==. 0;
        g_when (i.mem_done) [
          next_cpu `fetch;
        ];
        g_when (alu.Alu.O.alu_out_0) [
          ro.decoder_trigger $==. 0;
          (*set_mem_do_rinst = 1;*)
        ]
      ] [
        latched_branch $== instr Instr.Jalr;
        latched_store $==. 1;
        latched_stalu $==. 1;
        next_cpu `fetch;
      ]
    ]) in

    let shift = `shift, Signal.Guarded.([
      latched_store $==. 1;
      g_if (reg_sh#q ==:. 0) [
        reg_out $== ro.reg_op1#q;
        ro.mem_do_rinst $== ro.mem_do_prefetch#q;
        next_cpu `fetch;
      ] @@ g_elif (reg_sh#q >=:. 4) [
        ro.reg_op1 $== pmux1ht [
          instr Instr.Slli |: instr Instr.Sll, sll ro.reg_op1#q 4;
          instr Instr.Srli |: instr Instr.Srl, srl ro.reg_op1#q 4;
          instr Instr.Srai |: instr Instr.Sra, sra ro.reg_op1#q 4;
        ];
        reg_sh $== reg_sh#q -:. 4;
      ] [
        ro.reg_op1 $== pmux1ht [
          instr Instr.Slli |: instr Instr.Sll, sll ro.reg_op1#q 1;
          instr Instr.Srli |: instr Instr.Srl, srl ro.reg_op1#q 1;
          instr Instr.Srai |: instr Instr.Sra, sra ro.reg_op1#q 1;
        ];
        reg_sh $== reg_sh#q -:. 1;
      ]
    ]) in

    let stmem = `stmem, Signal.Guarded.([
      g_when ((~: (ro.mem_do_prefetch#q)) |: i.mem_done) [
        g_when (~: (ro.mem_do_wdata#q)) [
          ro.mem_wordsize $== pmux1ht [
            instr Instr.Sb, consti 2 2;
            instr Instr.Sh, consti 2 1;
            instr Instr.Sw, consti 2 0;
          ];
          ro.reg_op1 $== ro.reg_op1#q +: i.decoded_imm;
          (*set_mem_do_wdata = 1;*)
        ];
        g_when ((~: (ro.mem_do_prefetch#q)) &: i.mem_done) [
          next_cpu `fetch;
          ro.decoder_trigger $==. 1;
          ro.decoder_pseudo_trigger $==. 1;
        ]
      ]
    ]) in

    let ldmem = `ldmem, Signal.Guarded.([
      latched_store $==. 1;
      g_when ((~: (ro.mem_do_prefetch#q)) |: i.mem_done) [
        g_when (~: (ro.mem_do_rdata#q)) [
          ro.mem_wordsize $== pmux1ht [
            instr Instr.Lb |: instr Instr.Lbu, consti 2 2;
            instr Instr.Lh |: instr Instr.Lhu, consti 2 1;
            instr Instr.Lw,                    consti 2 0;
          ];
          latched_is_lu $== is Is.Lbu_lhu_lw;
          latched_is_lh $== instr Instr.Lh;
          latched_is_lb $== instr Instr.Lb;
          ro.reg_op1 $== ro.reg_op1#q +: i.decoded_imm;
          (*set_mem_do_rdata = 1;*)
        ];
        g_when ((~: (ro.mem_do_prefetch#q)) &: i.mem_done) [
          reg_out $== pmux1ht [
            latched_is_lu#q, i.mem_rdata_word;
            latched_is_lh#q, sresize (i.mem_rdata_word.[15:0]) 32;
            latched_is_lb#q, sresize (i.mem_rdata_word.[7:0]) 32;
          ];
          ro.decoder_trigger $==. 1;
          ro.decoder_pseudo_trigger $==. 1;
          next_cpu `fetch;
        ]
      ]
    ]) in

    ()

end

module Test = struct

  module Gen(X : sig
    module I : Interface.S
    module O : Interface.S
    module I' : Interface.S
    module O' : Interface.S
    val f : Signal.Comb.t I.t -> Signal.Comb.t O.t
    val wrap : Signal.Comb.t I'.t -> Signal.Comb.t O'.t
  end) = struct

    module Y = Interface.Circ(X.I)(X.O)
    module Y' = Interface.Circ(X.I')(X.O')

    let write name = 
      let name = "opicorv32_" ^ name in
      let f = open_out (name ^ ".v") in
      let circ = Y.make name X.f in
      Rtl.Verilog.write (output_string f) circ;
      close_out f;

      let name = "opicorv32_" ^ name ^ "_wrap" in
      let f = open_out (name ^ ".v") in
      let circ = Y'.make name X.wrap in
      Rtl.Verilog.write (output_string f) circ;
      close_out f;

      ()

  end

  module Decoder = Gen(Decoder)
  module Alu = Gen(Alu)
  module Memif = Gen(Memif)
  module Mul = Gen(Mul)
  module Pcpi_if = Gen(Pcpi_if)
  module Rf = Gen(Rf)
  (*module Control = Gen(Control)*)

  let write_vlog() = 
    Decoder.write "decoder";
    Alu.write "alu";
    Memif.write "memif";
    Mul.write "mul";
    Rf.write "rf";
    (*let () = Pcpi_if.write "pcpi_if"*)
    ()

  (* defines *)

  let instr_defines () = 
    List.iter (fun x ->
      Printf.printf "`define %s %i\n" 
        (Show.show<Instr.t> x)
        (Enum.from_enum<Instr.t> x)) Instr.list

  let is_defines () = 
    List.iter (fun x ->
      Printf.printf "`define %s %i\n" 
        (Show.show<Is.t> x)
        (Enum.from_enum<Is.t> x)) Is.list

  (* Instr and Is Modules to/from bit vectors *)

  module Vec(X : sig
    type t 
    val name : string
    val n : int
    module Enum_t : sig val to_enum : int -> t end
    module Show_t : sig val show : t -> string end
  end) = struct

    let vec_of_t () = 
      let l = Array.init X.n 
        (fun idx -> 
          let e = X.Enum_t.to_enum idx in
          let n = X.name ^ "_" ^ String.lowercase (X.Show_t.show e) in
          input n 1)
      in
      let o = output "q" (concat @@ List.rev @@ Array.to_list l) in
      let circ = Circuit.make ("vec_of_" ^ X.name) [o] in
      circ

    let t_of_vec () = 
      let i = input "d" X.n in
      let o = Array.init X.n 
        (fun j -> 
          let e = X.Enum_t.to_enum j in
          output 
            (X.name ^ "_" ^ String.lowercase (X.Show_t.show e)) 
            (bit i j)) 
      in
      let circ = Circuit.make (X.name ^ "_of_vec") (Array.to_list o) in
      circ

  end

  module Instr_vec = Vec(Instr)
  module Is_vec = Vec(Is)


end

