bbones:
	~/opt/cross/bin/i686-elf-as boot.s -o boot.o
	~/opt/cross/bin/i686-elf-gcc -c kernel.c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
	~/opt/cross/bin/i686-elf-gcc -T linker.ld -o xOS.bin -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc
	cp xOS.bin isodir/boot/xOS.bin
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o xOS.iso isodir
