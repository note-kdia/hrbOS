// 8-bit Colors
#define COL8_BLACK 0
#define COL8_RED 1
#define COL8_GREEN 2
#define COL8_YELLOW 3
#define COL8_BLUE 4
#define COL8_PURPLE 5
#define COL8_SKYBLUE 6
#define COL8_WHITE 7
#define COL8_GRAY 8
#define COL8_DARKRED 9
#define COL8_DARKGREEN 10
#define COL8_DARKYELLOW 11
#define COL8_DARKBLUE 12
#define COL8_DARKPURPLE 13
#define COL8_DARKSKYBLUE 14
#define COL8_DARKGLAY 15

// nasmfunc.asm
void _io_hlt(void);
void _io_hlt();
void _io_cli();
void _io_sti();
void _io_stihlt();
void _io_in8(int port);
void _io_in16(int port);
void _io_in32(int port);
int _io_out8(int port, int data);
int _io_out16(int port, int data);
int _io_out32(int port, int data);
int _io_load_eflags();
void _io_store_eflags(int eflags);

void init_palette();
void set_palette(int start, int end, unsigned char *rgb);
void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0,
              int x1, int y1);

void HariMain(void) {
    char *p;

    init_palette();  // Initialize palette

    p = (char *)0xa0000;  // Address for VRAM

    boxfill8(p, 320, COL8_YELLOW, 20, 20, 180, 120);

    for (;;) _io_hlt();
}

/**
 * @brief Initialize color palette with RGB table difined as table_rgb.
 */
void init_palette() {
    static unsigned char table_rgb[16 * 3] = {
        0x00, 0x00, 0x00,  // 0 : black
        0xff, 0x00, 0x00,  // 1 : bright red
        0x00, 0xff, 0x00,  // 2 : bright green
        0xff, 0xff, 0x00,  // 3 : bright yellow
        0x00, 0x00, 0xff,  // 4 : bright blue
        0xff, 0x00, 0xff,  // 5 : bright purple
        0x00, 0xff, 0xff,  // 6 : bright skyblue
        0xff, 0xff, 0xff,  // 7 : white
        0xc6, 0xc6, 0xc6,  // 8 : bright gray
        0x84, 0x00, 0x00,  // 9 : dark red
        0x00, 0x84, 0x00,  // 10 : dark green
        0x84, 0x84, 0x00,  // 11 : dark yellow
        0x00, 0x00, 0x84,  // 12 : dark blue
        0x84, 0x00, 0x84,  // 13 : dark purple
        0x00, 0x84, 0x84,  // 14 : dark skyblue
        0x84, 0x84, 0x84,  // 15 : dark gray
    };
    set_palette(0, 15, table_rgb);
    return;
}

/**
 * @brief Write color-palette data on specified address
 */
void set_palette(int start, int end, unsigned char *rgb) {
    int i, eflags;
    eflags = _io_load_eflags();  // Store load_eflags data
    _io_cli();                   // Prohibit interrupt
    _io_out8(0x03c8, start);
    for (i = start; i <= end; i++) {
        _io_out8(0x03c9, rgb[0] / 4);
        _io_out8(0x03c9, rgb[1] / 4);
        _io_out8(0x03c9, rgb[2] / 4);
        rgb += 3;
    }
    _io_store_eflags(eflags);  // Restore eflags
    return;
}

/**
 * @brief Fill box with specified color
 *
 * @param[out] vram Start address of VRAM
 * @param[in] xsize Display width in pixel
 * @param[in] c Color index
 * @param[in] x0 X coordinate of top-left point of the box
 * @param[in] y0 Y coordinate of top-left point of the box
 * @param[in] x1 X coordinate of bottom-right point of the box
 * @param[in] y1 Y coordinate of bottom-right point of the box
 * @return None
 */
void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0,
              int x1, int y1) {
    int x, y;
    for (y = y0; y <= y1; y++) {
        for (x = x0; x <= x1; x++) vram[y * xsize + x] = c;
    }
    return;
}
