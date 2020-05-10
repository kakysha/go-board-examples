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
#ifdef USEVGASIM
	Glib::signal_idle().connect([&m_vga, &m, &tb] {
		for (int i = 0; i < 350; i++) {
			m_vga(m->o_VGA_VSync, m->o_VGA_HSync, m->o_Red_Video_Porch, m->o_Grn_Video_Porch, m->o_Blu_Video_Porch);
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