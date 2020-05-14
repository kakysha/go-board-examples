#include "Vtop.h"
#include "verilated.h"
#include "TESTBENCH.h"
#ifdef USEVGASIM
	#include "vga/vgasim.h"
#endif

int main(int argc, char** argv, char** env) {
#ifdef USEVGASIM
	Gtk::Main main_instance(argc, argv);
	VGAWIN m_vga;
#endif

	Verilated::commandArgs(argc, argv);
	auto tb = new TESTBENCH<Vtop>();
	auto m = tb->m;
	m->i_Switch_4 = 1;
	m->i_Switch_2 = 1;
#ifdef USEVGASIM
	Glib::signal_idle().connect([&m_vga, &m, &tb] {
		for (int i = 0; i < 350; i++) {
			int red = 4 * m->o_VGA_Red_2 + 2 * m->o_VGA_Red_1 + m->o_VGA_Red_0;
			int grn = 4 * m->o_VGA_Grn_2 + 2 * m->o_VGA_Grn_1 + m->o_VGA_Grn_0;
			int blu = 4 * m->o_VGA_Blu_2 + 2 * m->o_VGA_Blu_1 + m->o_VGA_Blu_0;
			m_vga(m->o_VGA_VSync, m->o_VGA_HSync, red, grn, blu);
			tb->tick();
		}
		return true;
	});

	Gtk::Main::run(m_vga);
#else
	for (int n = 0; n < 60; n++) {
		for (int row = 0; row < 30; row++) {
			for (int col = 0; col < 40; col++) {
				for (int clock = 0; clock < 350; clock++) {
					tb->tick();
				}
			}
		}
	}
#endif
	delete tb;
}