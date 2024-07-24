all: BootLoader Disk.img


BootLoader:
	@echo ""
	@echo =================== Build Boot Loader ==========
	@echo ""

	make -C 00.BootLoader
	make -C 01.Kernel32

	@echo ""
	@echo =================== Build Complete =============
	@echo ""

Disk.img: 00.BootLoader/BootLoader.bin 01.Kernel32/Kernel32.bin
	@echo ""
	@echo =================== Disk image Build Start =====
	@echo ""
	
	powershell -ExecutionPolicy Bypass -File merge2.ps1 $@ $^

	@echo ""
	@echo =================== All Build Complete =========
	@echo ""

clean:
	make -C 00.BootLoader clean
	make -C 01.Kernel32 clean
	del Disk.img -Force
