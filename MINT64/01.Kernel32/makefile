all: Kernel32.bin

Kernel32.bin: Source/EntryPoint.s
	nasm -o Kernel32.bin $<

clean:
	del Kernel32.bin -Force