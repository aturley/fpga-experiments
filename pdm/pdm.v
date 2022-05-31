module top (
            input  clk,
            input  resetq,
            output buzz
            );
   
   parameter      BIN_THRESHOLD = 16'h07FFF;
   parameter      PDM = 1;
   
   reg signed [20:0]     shaper;
   reg [6:0]             sine_idx;
   reg signed [16:0]     sine [127:0];
   reg [7:0]             counter;
   reg                    buzzer;
   
   assign buzz = buzzer;

   always @ (posedge clk)
     begin
        if (~resetq)
          begin
             counter <= 0;
             sine_idx <= 0;
             shaper <= 0;
             buzzer <= 0;
             sine[0] = 'h08083;
             sine[1] = 'h08689;
             sine[2] = 'h08c8f;
             sine[3] = 'h09295;
             sine[4] = 'h0989b;
             sine[5] = 'h09ea1;
             sine[6] = 'h0a4a7;
             sine[7] = 'h0aaad;
             sine[8] = 'h0b0b3;
             sine[9] = 'h0b6b9;
             sine[10] = 'h0bbbe;
             sine[11] = 'h0c1c3;
             sine[12] = 'h0c6c9;
             sine[13] = 'h0cbce;
             sine[14] = 'h0d0d2;
             sine[15] = 'h0d5d7;
             sine[16] = 'h0d9db;
             sine[17] = 'h0dee0;
             sine[18] = 'h0e2e4;
             sine[19] = 'h0e6e7;
             sine[20] = 'h0e9eb;
             sine[21] = 'h0ecee;
             sine[22] = 'h0f0f1;
             sine[23] = 'h0f2f4;
             sine[24] = 'h0f5f6;
             sine[25] = 'h0f7f8;
             sine[26] = 'h0f9fa;
             sine[27] = 'h0fbfb;
             sine[28] = 'h0fcfd;
             sine[29] = 'h0fdfe;
             sine[30] = 'h0fefe;
             sine[31] = 'h0fefe;
             sine[32] = 'h0fffe;
             sine[33] = 'h0fefe;
             sine[34] = 'h0fefe;
             sine[35] = 'h0fdfd;
             sine[36] = 'h0fcfb;
             sine[37] = 'h0fbfa;
             sine[38] = 'h0f9f8;
             sine[39] = 'h0f7f6;
             sine[40] = 'h0f5f4;
             sine[41] = 'h0f2f1;
             sine[42] = 'h0f0ee;
             sine[43] = 'h0eceb;
             sine[44] = 'h0e9e7;
             sine[45] = 'h0e6e4;
             sine[46] = 'h0e2e0;
             sine[47] = 'h0dedb;
             sine[48] = 'h0d9d7;
             sine[49] = 'h0d5d2;
             sine[50] = 'h0d0ce;
             sine[51] = 'h0cbc9;
             sine[52] = 'h0c6c3;
             sine[53] = 'h0c1be;
             sine[54] = 'h0bbb9;
             sine[55] = 'h0b6b3;
             sine[56] = 'h0b0ad;
             sine[57] = 'h0aaa7;
             sine[58] = 'h0a4a1;
             sine[59] = 'h09e9b;
             sine[60] = 'h09895;
             sine[61] = 'h0928f;
             sine[62] = 'h08c89;
             sine[63] = 'h08683;
             sine[64] = 'h0807d;
             sine[65] = 'h07a77;
             sine[66] = 'h07471;
             sine[67] = 'h06e6b;
             sine[68] = 'h06865;
             sine[69] = 'h0625f;
             sine[70] = 'h05c59;
             sine[71] = 'h05653;
             sine[72] = 'h0504d;
             sine[73] = 'h04a47;
             sine[74] = 'h04542;
             sine[75] = 'h03f3d;
             sine[76] = 'h03a37;
             sine[77] = 'h03532;
             sine[78] = 'h0302e;
             sine[79] = 'h02b29;
             sine[80] = 'h02725;
             sine[81] = 'h02220;
             sine[82] = 'h01e1c;
             sine[83] = 'h01a19;
             sine[84] = 'h01715;
             sine[85] = 'h01412;
             sine[86] = 'h0100f;
             sine[87] = 'h00e0c;
             sine[88] = 'h00b0a;
             sine[89] = 'h00908;
             sine[90] = 'h00706;
             sine[91] = 'h00505;
             sine[92] = 'h00403;
             sine[93] = 'h00302;
             sine[94] = 'h00202;
             sine[95] = 'h00202;
             sine[96] = 'h00102;
             sine[97] = 'h00202;
             sine[98] = 'h00202;
             sine[99] = 'h00303;
             sine[100] = 'h00405;
             sine[101] = 'h00506;
             sine[102] = 'h00708;
             sine[103] = 'h0090a;
             sine[104] = 'h00b0c;
             sine[105] = 'h00e0f;
             sine[106] = 'h01012;
             sine[107] = 'h01415;
             sine[108] = 'h01719;
             sine[109] = 'h01a1c;
             sine[110] = 'h01e20;
             sine[111] = 'h02225;
             sine[112] = 'h02729;
             sine[113] = 'h02b2e;
             sine[114] = 'h03032;
             sine[115] = 'h03537;
             sine[116] = 'h03a3d;
             sine[117] = 'h03f42;
             sine[118] = 'h04547;
             sine[119] = 'h04a4d;
             sine[120] = 'h05053;
             sine[121] = 'h05659;
             sine[122] = 'h05c5f;
             sine[123] = 'h06265;
             sine[124] = 'h0686b;
             sine[125] = 'h06e71;
             sine[126] = 'h07477;
             sine[127] = 'h07a7d;
          end
        else
          begin
             if (PDM)
               begin
                  if ((shaper + sine[sine_idx]) > BIN_THRESHOLD)
                    begin
                       shaper <= (shaper + sine[sine_idx]) - 17'h0FFFF;
                       buzzer <= 1;
                    end
                  else
                    begin
                       shaper <= shaper + sine[sine_idx];
                       buzzer <= 0;
                    end
                  counter <= counter + 1;

                  if (counter == 0)
                    begin
                       sine_idx <= sine_idx + 1;
                    end
               end // if (PDM)
             else
               begin
                  counter <= counter + 1;

                  if (counter == 0)
                    begin
                       sine_idx <= sine_idx + 1;
                       if (sine_idx < 64)
                         begin
                            buzzer <= 1;
                         end
                       else
                         begin
                            buzzer <= 0;
                         end
                    end
               end
          end // else: !if(resetq)
     end
   
endmodule
