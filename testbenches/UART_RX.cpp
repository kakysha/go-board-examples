#include "VUART_RX.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

const int PERIOD = (1000 / 25); // 1000 / MHz, ns for one clock cycle
VerilatedVcdC* tfp;
unsigned int tickcount = 0;

VUART_RX* tb;

const int CLKS_PER_BIT = 217; // BAUD

void write_byte(const char input) {
	char bits_sent = 0;
	while (bits_sent < 8) {

	}
}

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
}

int main(int argc, char** argv, char** env) {
	Verilated::commandArgs(argc, argv);
	tb = new VUART_RX();
	Verilated::traceEverOn(true);
	tfp = new VerilatedVcdC();
	tb->trace(tfp, 99);
	tfp->open("trace.vcd");

	// send byte
	int data = 0x37;
	int bit_num = 1;
	char old_o_DV = 0;

	for (int i = 0; i < (1 << 15); i++)	{
		tick();

		if (tickcount == 1) {
			tb->i_RX_Serial = 0;
			bit_num = 1;
		}
		if (bit_num <= 8 && tickcount == bit_num * CLKS_PER_BIT) {
			tb->i_RX_Serial = (data >> (bit_num - 1)) & 1;
			bit_num++;
		}
		if (bit_num == 9 && tickcount == bit_num * CLKS_PER_BIT) {
			tb->i_RX_Serial = 1;
			bit_num++;
		}

		if (tb->o_DV == 1 && old_o_DV != tb->o_DV) {
			printf("Byte received: %x\n", tb->o_RX_Byte);
		}
		old_o_DV = tb->o_DV;
	}
	tfp->close();
	tb->final();
	delete tb;
	exit(0);
}