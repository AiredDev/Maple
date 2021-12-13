/* The bootloader will look at this image and start execution
   at the symbol designated as the entry point. */

ENTRY(_start)

/* Tell the linker where the various sections of the
   object files will be placed in the final image */

SECTIONS
{
	/* Begin placing sections at 1MiB. A human convention. */
	
	. = 1M;

	/* First, put the multiboot header, because it is required
	   to be put very early in the image, else GRUB won't recognise
	   the file format. Afterwards, put the .text section. */

	.text BLOCK(4K) : ALIGN(4K)
	{
		*(.multiboot)
		*(.text)
	}

	/* Read-only data */

	.rodata BLOCK(4K) : ALIGN(4K)
	{
		*(.rodata)
	}

	/* Read-write data (initialised). */

	.data BLOCK(4K) : ALIGN(4K)
	{
		*(.data)
	}

	/* Read-write data (uninitialised) and stack. */

	.bss BLOCK(4K) : ALIGN(4K)
	{
		*(COMMON)
		*(.bss)
	}
}