#include "VUART_RX.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

const int PERIOD = (1000 / 25); // 1000 / MHz, ns for one clock cycle
VerilatedVcdC* tfp;
unsigned int tickcount = 0;

VUART_RX* tb;
char old_o_DV = 0;

const int CLKS_PER_BIT = 217; // BAUD

void tick() {
	++tickcount;
	tb->eval();
	tb->i_Clock = 1;
	tb->eval();
	tfp->dump(tickcount * PERIOD - PERIOD / 2);
	tb->i_Clock = 0;
	tb->eval();
	tfp->dump(tickcount * PERIOD);
	tfp->flush();

	if (tb->o_DV == 1 && old_o_DV == 0) {
		printf("Byte received: %x\n", tb->o_RX_Byte);
	}
	old_o_DV = tb->o_DV;
}

void send_byte(char data) {
	// start bit
	for (int i = 0; i < CLKS_PER_BIT; i++) {
		tb->i_RX_Serial = 0;
		tick();
	}

	// data bits
	int bit_num = 0;
	for (int i = 0; i < 8 * CLKS_PER_BIT; i++) {
		if (i == bit_num * CLKS_PER_BIT) {
			tb->i_RX_Serial = (data >> bit_num) & 1;
			bit_num++;
		}
		tick();
	}
	// stop bit
	for (int i = 0; i < CLKS_PER_BIT; i++) {
		tb->i_RX_Serial = 1;
		tick();
	}
}

int main(int argc, char** argv, char** env) {
	Verilated::commandArgs(argc, argv);
	tb = new VUART_RX();
	Verilated::traceEverOn(true);
	tfp = new VerilatedVcdC();
	tb->trace(tfp, 99);
	tfp->open("trace.vcd");

	send_byte(0x37);
	send_byte(0x64);
	send_byte(0x11);
	send_byte(0x00);
	send_byte(0xff);

	tfp->close();
	tb->final();
	delete tb;
	exit(0);
}