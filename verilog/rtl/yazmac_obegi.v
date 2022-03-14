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
`timescale 1ns / 1ps

module yazmac_obegi(
    `ifdef BASYS3
    output        [15:0]            fpga_demo_signal            ,
    `endif

    input                           clk_g                       ,
    input                           rst_g                       ,
    input         [`HY_BIT-1:0]     ky1_adres_g                 ,
    input         [`HY_BIT-1:0]     ky2_adres_g                 ,
    input         [`HY_BIT-1:0]     hy_adres_g                  ,
    input         [31:0]            hy_deger_g                  ,
    input                           yaz_g                       ,
    output reg    [31:0]            ky1_deger_c                 ,
    output reg    [31:0]            ky2_deger_c
    );
    
    reg           [31:0]    y_obek[31:0]                        ;
    
    `ifdef BASYS3
    // FPGA DEMO for RISCV tests
    assign fpga_demo_signal = {y_obek[10][7:0], y_obek[17][7:0]};
    `endif

    always@* begin
        ky1_deger_c            = y_obek[ky1_adres_g]            ;
        ky2_deger_c            = y_obek[ky2_adres_g]            ;
    end
    integer i = 0;
    always@(posedge clk_g) begin
        if (rst_g) begin
            for(i = 0; i < 32; i = i + 1)
                y_obek[i]           <=  0                           ;
        end
        else if(yaz_g) begin
            y_obek[hy_adres_g]  <=  hy_deger_g                  ;
        end
    end
endmodule
