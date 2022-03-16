"""
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
"""
import argparse
import os

parser = argparse.ArgumentParser(description='Takes an instruction name and generates c0_uart_prog_tb.v.')

parser.add_argument('inst', help='Name of the instruction')

args = parser.parse_args()
inst_name = args.inst

pwd = os.getcwd() + "/verilog/dv/test_c0"

imem_f = open(pwd + "/coe/" + inst_name + "/imem.coe")
dmem_f = open(pwd + "/coe/" + inst_name + "/dmem.coe")
ps_dump = open(pwd + "/coe/" + inst_name + "/cekirdek_ps_hex.txt")
out_f  = open(pwd + "/c0_uart_prog_tb.v", "w")

os.system("cp " + pwd + "/coe/" + inst_name + "/cekirdek_ps_hex.txt " + pwd + "/sim_ps.txt")

imem_arr = imem_f.readlines()
dmem_arr = dmem_f.readlines()
ps = ps_dump.readlines()

imem_f.close()
dmem_f.close()
ps_dump.close()

last_ps = hex(int(ps[-1].strip(), 16) + 4)[2:]

imem_bytes = (len(imem_arr) - 2) * 4
dmem_bytes = (len(dmem_arr) - 2) * 4

hex_data = imem_bytes.to_bytes(4, 'little')

byte_ctr = 0

out_f.write("`timescale 1ns / 1ps\n\nmodule c0_uart_prog(\n\t\tinput c0_tx,\n\t\toutput reg c0_rx\n\t);")

out_f.write("\n\n\t// Program len       : " + str(imem_bytes + dmem_bytes + 8))
out_f.write("\n\t// # of instructions : " + str(int(imem_bytes/4)))
out_f.write("\n\t// # of data         : " + str(int(dmem_bytes/4)) + "\n")
out_f.write("\n\t// Last PC           : 32'h" + last_ps + "\n")


out_f.write("\n\twire [7:0] program [" + str(imem_bytes + dmem_bytes + 50) + ":0];\n\n")


for i in range(4):
    out_f.write("\tassign program[" + str(byte_ctr) + "] = 8'd" + str(hex_data[i]) + ";\n")
    byte_ctr += 1

for line in imem_arr:
    if line.startswith('memory_'):
        continue
    else:
        hex_str = line[:8]
        hex_data = bytearray.fromhex(hex_str)
        for i in range(3,-1,-1):
            out_f.write("\tassign program[" + str(byte_ctr) + "] = 8'd" + str(hex_data[i]) + ";\n")
            byte_ctr += 1

hex_data = dmem_bytes.to_bytes(4, 'little')

for i in range(4):
    out_f.write("\tassign program[" + str(byte_ctr) + "] = 8'd" + str(hex_data[i]) + ";\n")
    byte_ctr += 1

for line in dmem_arr:
    if line.startswith('memory_'):
        continue
    else:
        hex_str = line[:8]
        hex_data = bytearray.fromhex(hex_str)
        for i in range(3,-1,-1):
            out_f.write("\tassign program[" + str(byte_ctr) + "] = 8'd" + str(hex_data[i]) + ";\n")
            byte_ctr += 1

out_f.write("\n\n\tparameter BAUD_PERIOD = 340;\n\tparameter CLK_PERIOD = 20;\n\n\tparameter UART_DELAY = BAUD_PERIOD / CLK_PERIOD;")
out_f.write("\n\n\n\tinteger i, j;\n\tinitial begin\n\t\tc0_rx = 1'b1;\n\t\t#270000;\n\t\tfor (i = 0 ; i < " + str(byte_ctr) + " ; i = i+1) begin")
out_f.write("\n\t\t\tc0_rx = 1'b0;\n\t\t\t#BAUD_PERIOD;\n\t\t\tfor (j = 0 ; j < 8 ; j = j+1) begin\n\t\t\t\tc0_rx = program[i][j];\n\t\t\t\t#BAUD_PERIOD;\n\t\t\tend")
out_f.write("\n\t\t\tc0_rx = 1'b1;\n\t\t\t#BAUD_PERIOD;\n\t\t\tc0_rx = 1'b1;\n\t\t\t#(BAUD_PERIOD*5);\n\t\tend\n\tend\n\nendmodule\n")

out_f.close()

old_tb = open(pwd + "/test_c0_tb.v", "r")
new_tb = open(pwd + "/temp.v", "w")

for line in old_tb.readlines():
    if("// Update this with test_prog ps_dump" in line):
        new_tb.write("\t\twait(io_ps == 32'h" + last_ps + ");\t// Update this with test_prog ps_dump\n")
    else:
        new_tb.write(line)
old_tb.close()
new_tb.close()

os.system("cp " + pwd + "/temp.v " + pwd + "/test_c0_tb.v")
os.system("rm " + pwd + "/temp.v")

old_c = open(pwd + "/test_c0.c", "r")
new_c = open(pwd + "/temp.c", "w")

for line in old_c.readlines():
    if("reg_mprj_datal == (0x" in line):
        new_c.write("\t\tif (reg_mprj_datal == (0x" + last_ps + " << 3)) {\n")
    else:
        new_c.write(line)
old_c.close()
new_c.close()

os.system("cp " + pwd + "/temp.c " + pwd + "/test_c0.c")
os.system("rm " + pwd + "/temp.c")
