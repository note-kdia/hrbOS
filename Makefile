# Makefile
os.iso: os.img
	mkisofs -b os.img -o os.iso -input-charset utf8 os.img

nasmhead.bin: nasmhead.asm
	nasm nasmhead.asm -o nasmhead.bin

nasmfunc.o: nasmfunc.asm
	nasm -f elf32 nasmfunc.asm -o nasmfunc.o

bootpack.o: bootpack.c
	gcc -c -m32 -fno-pic bootpack.c -o bootpack.o

bootpack.bin: bootpack.o nasmfunc.o
	ld -m elf_i386 -e HariMain -o bootpack.bin -Tos.ls bootpack.o nasmfunc.o

os.sys: nasmhead.bin bootpack.bin
	cat nasmhead.bin bootpack.bin > os.sys

ipl.bin: ipl.asm
	nasm ipl.asm -o ipl.bin

os.img: ipl.bin os.sys
	mformat -f 1440 -C -B ipl.bin -i os.img ::
	mcopy -i os.img os.sys ::

qemu: os.iso
	qemu-system-i386 -boot d -cdrom os.iso -m 512

clean:
	rm -f *.bin
	rm -f *.o
	rm -f *.sys
	rm -f *.img
	rm -f *.iso
