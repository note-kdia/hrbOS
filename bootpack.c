//bootpack.c
void io_hlt(void);
void write_mem8(int addr, int data);

void HariMain(void) {
    for(;;) {
        io_hlt();
    }
}
