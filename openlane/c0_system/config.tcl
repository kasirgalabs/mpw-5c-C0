# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) c0_system

set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/sabitler.vh \
	$script_dir/../../verilog/rtl/mikroislem.vh \
	$script_dir/../../verilog/rtl/c0_system.v \
	$script_dir/../../verilog/rtl/getir_coz.v \
	$script_dir/../../verilog/rtl/adres_tekleyici.v \
	$script_dir/../../verilog/rtl/aritmetik_mantik_birimi.v \
	$script_dir/../../verilog/rtl/baslangic_bellegi.v \
	$script_dir/../../verilog/rtl/bellek_islem_birimi.v \
	$script_dir/../../verilog/rtl/buyruk_bellegi_sram.v \
	$script_dir/../../verilog/rtl/cekirdek.v \ 
	$script_dir/../../verilog/rtl/dallanma_birimi.v \
	$script_dir/../../verilog/rtl/denetim_durum_birimi.v \
	$script_dir/../../verilog/rtl/on_taraf.v \
	$script_dir/../../verilog/rtl/veri_bellegi_sram.v \
	$script_dir/../../verilog/rtl/yazmac_obegi.v \
	$script_dir/../../verilog/rtl/yazmac_oku_yurut.v \
	$script_dir/../../verilog/rtl/yazmac_yaz.v \
	$script_dir/../../verilog/rtl/UART_GFA.v \
	$script_dir/../../verilog/rtl/UART_alici.v \
	$script_dir/../../verilog/rtl/UART_verici.v \
	$script_dir/../../verilog/rtl/iki_bit_adimli_bolucu.v \
	$script_dir/../../verilog/rtl/axil_interconnect.v \
	$script_dir/../../verilog/rtl/iki_bit_adimli_carpici.v \
	$script_dir/../../verilog/rtl/tamsayi_carpma_birimi.v \
	$script_dir/../../verilog/rtl/tamsayi_bolme_birimi.v \
	$script_dir/../../verilog/rtl/axil_slave_gfa.v"

set ::env(DESIGN_IS_CORE) 0

set ::env(CLOCK_PORT) "clk_g"
set ::env(CLOCK_NET) "clk_g"
set ::env(CLOCK_PERIOD) "20"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 1600 1600"

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

#set ::env(PL_BASIC_PLACEMENT) 1
set ::env(PL_TARGET_DENSITY) 0.19

# Maximum layer used for routing is metal 4.
# This is because this macro will be inserted in a top level (user_project_wrapper) 
# where the PDN is planned on metal 5. So, to avoid having shorts between routes
# in this macro and the top level metal 5 stripes, we have to restrict routes to metal4.  
set ::env(RT_MAX_LAYER) {met4}

# You can draw more power domains if you need to 
set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

set ::env(DIODE_INSERTION_STRATEGY) 4 
# If you're going to use multiple power domains, then disable cvc run.
set ::env(RUN_CVC) 1
#set ::env(FP_PDN_CHECK_NODES) 0


set ::env(PL_RESIZER_ALLOW_SETUP_VIOS) 1
set ::env(GLB_RESIZER_ALLOW_SETUP_VIOS) 1
