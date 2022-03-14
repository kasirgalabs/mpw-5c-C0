// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

`timescale 1 ns / 1 ps

module test_c0_tb;
	reg clock;
	reg RSTB;
	reg CSB;
	reg power1, power2;
	reg power3, power4;

	wire gpio;
	wire [37:0] mprj_io;

	wire 		c0_rx, c0_tx;
    wire        io_gecerli;
    wire [31:0] io_ps;

	assign mprj_io[3] = (CSB == 1'b1) ? 1'b1 : 1'bz;

	assign mprj_io[0] = c0_rx;
	assign c0_tx = mprj_io[1];
	assign io_gecerli = mprj_io[2];
	assign io_ps = mprj_io[34:3];

	`ifndef GL
	wire 		internal_gecerli;
	wire [31:0] internal_ps;
	assign internal_gecerli = uut.mprj.mprj.c0.yy.yoy_uis_g[146];
	assign internal_ps = uut.mprj.mprj.c0.yy.yoy_uis_g[31:0];
	`endif

	always #10 clock <= (clock === 1'b0);
	
	integer ps_dump_internal, ps_dump_io;
	initial begin
		$dumpfile("test_c0.vcd");
		$dumpvars(0, test_c0_tb);
		clock = 0;

        ps_dump_io = $fopen("ps_dump_io.txt","w");
		
		`ifndef GL
		ps_dump_internal = $fopen("ps_dump_internal.txt","w");
		`endif

		wait(io_ps == 32'h10680);	// Update this with test_prog ps_dump
		#200;
		$fclose(ps_dump_io);
		`ifndef GL
		$fclose(ps_dump_internal);
		`endif
		$display("TEST FINISHED.");
		$finish();
	end

	`ifndef GL
    // Dump PS with internal signals
	always @(posedge clock) begin
        #1;
		if(internal_gecerli)
			$fwrite(ps_dump_internal, "%d_%h\n", $time, internal_ps);
	end
	`endif
	
    // Dump PS with io signals
	always @(posedge clock) begin
        #1;
		if(io_gecerli)
			$fwrite(ps_dump_io, "%d_%h\n", $time, io_ps);
	end

	// Caravel
	// ----------------------------------------------
	initial begin
		RSTB <= 1'b0;
		CSB  <= 1'b1;		// Force CSB high
		#1600;
		RSTB <= 1'b1;	    	// Release reset
		#240000;
		CSB = 1'b0;		// CSB can be released
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		power3 <= 1'b0;
		power4 <= 1'b0;
		#80;
		power1 <= 1'b1;
		#80;
		power2 <= 1'b1;
		#80;
		power3 <= 1'b1;
		#80;
		power4 <= 1'b1;
	end
	// Caravel Ends
	// ----------------------------------------------

	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD3V3;
	wire VDD1V8;
	wire VSS;
	
	assign VDD3V3 = power1;
	assign VDD1V8 = power2;
	assign VSS = 1'b0;

	caravel uut (
		.vddio	  (VDD3V3),
		.vddio_2  (VDD3V3),
		.vssio	  (VSS),
		.vssio_2  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (VDD3V3),
		.vdda1_2  (VDD3V3),
		.vdda2    (VDD3V3),
		.vssa1	  (VSS),
		.vssa1_2  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (VDD1V8),
		.vccd2	  (VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock    (clock),
		.gpio     (gpio),
		.mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("test_c0.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);
	
	c0_uart_prog c0_prog
	(
		.c0_rx(c0_rx),
		.c0_tx(c0_tx)
	);

endmodule
`default_nettype wire