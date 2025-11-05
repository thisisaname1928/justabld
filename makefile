STAGE1_BIN=stage1/stage1.bin
STAGE1_SRC=stage1/main.asm
ASM=nasm
ASM_FLAGS=

test: $(STAGE1_BIN)
	@qemu-system-x86_64 $< -m 1G -enable-kvm

$(STAGE1_BIN): $(STAGE1_SRC)
	@echo "[ASM] $< -> $@"
	@$(ASM) -f bin $< -o $@ 