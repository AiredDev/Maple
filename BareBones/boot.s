/* Constants for the multiboot header */
.set ALIGN,    1 << 0           /* Align modules on page boundaries */
.set MEMINFO,  1 << 1           /* Memory map */
.set FLAGS,    ALIGN | MEMINFO  /* The multiboot "flag" field */
.set MAGIC,    0x1BADB002       /* Magic number allows the bootloader to find the header */
.set CHECKSUM, -(MAGIC + FLAGS) /* checksum to prove we are multiboot

/* The multiboot header. This header marks the program as a kernel.
   These are magic values described in the multiboot standard.
   The bootloader (GRUB in our case) searches for this header within
   the first 8 KiB of the kernel file, aligned at a 32-bit boundary.
   It is in its own section so the header is forced to be within
   the first 8 KiB of the kernel file. */

.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

/* Because multiboot does not define the value of the stack pointer register,
   it's up to us to implement a stack. Here we allocate 16 KiB for a stack
   which, on x86, grows downwards (as evidenced here by defining stack_bottom
   before stack_top). 
   The stack is in its own section so it can be marked nobits,
   making the kernel file smaller because it does not contain an uninitialised
   stack.
   According to the System V ABI standard, the stack on x86 must be 16-byte
   aligned - the compiler assumes a properly aligned stack, so failure to
   align it manually will result in undefined behaviour. */

.section .bss
.align 16
stack_bottom:
	.skip 16384
stack_top:

/* The linker script specifies _start as the entry point to the kernel. The
   bootloader jumps to this location once the kernel is loaded.
   We don't return from this function because at this point the bootloader
   is already gone. */

.section .text
.global _start
.type _start, @function
_start:
	/* At this point, the bootloader has loaded us into 32-bit protected
	   mode. Interrupts and paging are disabled. The processor state is
	   as defined in the multiboot standard. The kernel has full control
	   of the CPU, but can only make use of hardware features and any code
	   it provides as part of itself. There are no security restrictions,
	   safeguards, or debugging mechanisms, only what the kernel provides
	   itself. */

	/* Here we set up a stack. Since it grows downwards on x86, we
	   set the esp to the top of the stack. This must be done in
	   assembly - C cannot function without a stack. */

	mov $stack_top, %esp

	/* This is a good place to initialise processor state, before the
	   high-level kernel is entered. It's best to minimise the early
	   environment, where crucial features are offline.
	   Note that some features of the processor like floating-point
	   instructions and instruction set extensions are not initialised
	   yet.
	   The Global Descriptor Table should be loaded and paging should be
	   enabled here. C++ features like global constructors and exceptions
	   require runtime support to work as well. */
	
	/* Enter the high-level kernel. As mentioned, the ABI requires the stack
	   to be 16-byte aligned. We originally aligned it in the .bss section,
	   and since we've pushed 0 bytes to it so far, a multiple of 16,
	   alignment has been preserved. */

	call kernel_main

	/* If the system has nothing more to do, put it into an infinite loop.
	   cli disables interrupts. The bootloader does this automatically so
	   this isn't technically necessary.
	   hlt waits for the next interrupt to arrive. However, since they are now
	   disabled, this locks up the system.
	   jmp 1b jumps back to the hlt instruction if the computer ever wakes
	   up due to a non-maskable interrupt or system management mode. */
	
	cli
	1: 
		hlt
	jmp 1b

/* Set the size of the _start symbol to the current location (.) minus its start.
   Useful when debugging or when we implement call tracing. */
.size _start, . - _start