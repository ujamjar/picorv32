
TEST_OBJS = $(addsuffix .o,$(basename $(wildcard tests/*.S)))
FIRMWARE_OBJS = firmware/start.o firmware/irq.o firmware/print.o firmware/sieve.o firmware/multest.o firmware/stats.o

#VVP=vvp -N
VVP=vvp -n

test: testbench.exe firmware/firmware.hex
	$(VVP) testbench.exe

test_sp: testbench_sp.exe firmware/firmware.hex
	$(VVP) testbench_sp.exe

test_axi: testbench_axi.exe firmware/firmware.hex
	$(VVP) testbench_axi.exe

OPICORV32=opicorv32_alu.v opicorv32_instruction_decoder.v opicorv32_memif.v opicorv32_pcpi_if.v opicorv32_control.v opicorv32_rv32.v
OPICORV32_WRAP=opicorv32_alu_wrap.v opicorv32_instruction_decoder_wrap.v opicorv32_memif_wrap.v opicorv32_pcpi_if_wrap.v opicorv32_control_wrap.v
PICORV32=$(OPICORV32) $(OPICORV32_WRAP) picorv32_2.v

testbench.exe: testbench.v $(PICORV32)
	iverilog -Wall -o testbench.exe testbench.v $(PICORV32)
	chmod -x testbench.exe

testbench_sp.exe: testbench.v $(PICORV32)
	iverilog -o testbench_sp.exe -DSP_TEST testbench.v $(PICORV32)
	chmod -x testbench_sp.exe

testbench_axi.exe: testbench.v $(PICORV32)
	iverilog -o testbench_axi.exe -DAXI_TEST testbench.v $(PICORV32)
	chmod -x testbench_axi.exe

firmware/firmware.hex: firmware/firmware.bin firmware/makehex.py
	python3 firmware/makehex.py $< > $@

RV=riscv64-unknown-elf-
RVGCC=$(RV)gcc -m32
#RV=riscv32-unknown-elf-
#RVGCC=$(RV)gcc
RVOBJCOPY=$(RV)objcopy

firmware/firmware.bin: firmware/firmware.elf
	$(RVOBJCOPY) -O binary $< $@
	chmod -x $@

firmware/firmware.elf: $(FIRMWARE_OBJS) $(TEST_OBJS) firmware/sections.lds
	$(RVGCC) -Os -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,firmware/sections.lds,-Map,firmware/firmware.map,--strip-debug \
		$(FIRMWARE_OBJS) $(TEST_OBJS) -lgcc
	chmod -x $@

firmware/start.o: firmware/start.S
	$(RVGCC) -c -o $@ $<

firmware/%.o: firmware/%.c
	$(RVGCC) -c -march=RV32I -Os -ffreestanding -nostdlib -o $@ $<

tests/%.o: tests/%.S tests/riscv_test.h tests/test_macros.h
	$(RVGCC) -c -o $@ -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $<

clean:
	rm -vrf $(FIRMWARE_OBJS) $(TEST_OBJS) \
		firmware/firmware.{elf,bin,hex,map} \
		testbench{,_sp,_axi}.exe testbench.exe testbench.vcd

.PHONY: test test_sp test_axi clean

