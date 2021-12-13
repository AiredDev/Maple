#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

// In case the compiler thinks we're targeting the wrong OS
#if defined (__linux__)
#error "You are not using a cross-compiler. You will run into issues."
#endif

// This currently only works for 32-bit ix86 targets
#if !defined (__i386__)
#error "This kernel needs to be compiled by a compiler targeting the ix86-elf environment."
#endif

// Hardware text mode colour constants
enum vga_colour 
{
	VGA_COLOUR_BLACK         = 0,
	VGA_COLOUR_BLUE          = 1,
	VGA_COLOUR_GREEN         = 2,
	VGA_COLOUR_CYAN          = 3,
	VGA_COLOUR_RED           = 4,
	VGA_COLOUR_MAGENTA       = 5,
	VGA_COLOUR_BROWN         = 6,
	VGA_COLOUR_LIGHT_GREY    = 7,
	VGA_COLOUR_DARK_GREY     = 8,
	VGA_COLOUR_LIGHT_BLUE    = 9,
	VGA_COLOUR_LIGHT_GREEN   = 10,
	VGA_COLOUR_LIGHT_CYAN    = 11,
	VGA_COLOUR_LIGHT_RED     = 12,
	VGA_COLOUR_LIGHT_MAGENTA = 13,
	VGA_COLOUR_LIGHT_BROWN   = 14,
	VGA_COLOUR_WHITE         = 15
};

static inline uint8_t vga_entry_colour(enum vga_colour fg, enum vga_colour bg)
{
	return fg | bg << 4;
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t color)
{
	return (uint16_t) uc | (uint16_t) color << 8;
}

// We have no string.h (or indeed any libraries not provided by the compiler, including stdio.h), so we have to implement strlen ourselves.
size_t strlen(const char *str)
{
	size_t len = 0;
	while (str[len])
	{
		len++;
	}
	return len;
}

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

size_t terminal_row;
size_t terminal_column;
uint8_t terminal_colour;
uint16_t *terminal_buffer;

void terminal_initialise(void)
{
	terminal_row = 0;
	terminal_column = 0;
	terminal_colour = vga_entry_colour(VGA_COLOUR_LIGHT_GREY, VGA_COLOUR_BLACK);
	terminal_buffer = (uint16_t*) 0xB8000;

	for (size_t y = 0; y < VGA_HEIGHT; y++)
	{
		for (size_t x = 0; x < VGA_WIDTH; x++)
		{
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = vga_entry(' ', terminal_colour);
		}
	}
}

void terminal_setcolour(uint8_t colour)
{
	terminal_colour = colour;
}

void terminal_putentryat(char c, uint8_t colour, size_t x, size_t y)
{
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = vga_entry(c, colour);
}

void terminal_putchar(char c)
{
	terminal_putentryat(c, terminal_colour, terminal_column, terminal_row);

	if (++terminal_column == VGA_WIDTH)
	{
		terminal_column = 0;
		if (++terminal_row == VGA_HEIGHT)
		{
			terminal_row = 0;
		}
	}
}

void terminal_write(const char *data, size_t size)
{
	for (size_t i = 0; i < size; i++)
	{
		terminal_putchar(data[i]);
	}
}

void terminal_writestring(const char *data)
{
	terminal_write(data, strlen(data));
}

void kernel_main(void)
{
	// Initialise terminal interface
	terminal_initialise();

	terminal_writestring("Hello, kernel world!\n");
}