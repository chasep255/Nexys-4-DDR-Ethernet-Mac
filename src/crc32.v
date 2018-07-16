`timescale 1 ns / 1 ps

module crc32
(
	input         clk,
	input         rst,
	input         vld,
	input  [7:0]  data,
	output [31:0] crc
);

	`include "util.vh"

	reg [31:0] crc_lookup[255:0];
	initial begin
		crc_lookup[0]   = 32'h00000000;
		crc_lookup[1]   = 32'h77073096;
		crc_lookup[2]   = 32'hee0e612c;
		crc_lookup[3]   = 32'h990951ba;
		crc_lookup[4]   = 32'h076dc419;
		crc_lookup[5]   = 32'h706af48f;
		crc_lookup[6]   = 32'he963a535;
		crc_lookup[7]   = 32'h9e6495a3;
		crc_lookup[8]   = 32'h0edb8832;
		crc_lookup[9]   = 32'h79dcb8a4;
		crc_lookup[10]  = 32'he0d5e91e;
		crc_lookup[11]  = 32'h97d2d988;
		crc_lookup[12]  = 32'h09b64c2b;
		crc_lookup[13]  = 32'h7eb17cbd;
		crc_lookup[14]  = 32'he7b82d07;
		crc_lookup[15]  = 32'h90bf1d91;
		crc_lookup[16]  = 32'h1db71064;
		crc_lookup[17]  = 32'h6ab020f2;
		crc_lookup[18]  = 32'hf3b97148;
		crc_lookup[19]  = 32'h84be41de;
		crc_lookup[20]  = 32'h1adad47d;
		crc_lookup[21]  = 32'h6ddde4eb;
		crc_lookup[22]  = 32'hf4d4b551;
		crc_lookup[23]  = 32'h83d385c7;
		crc_lookup[24]  = 32'h136c9856;
		crc_lookup[25]  = 32'h646ba8c0;
		crc_lookup[26]  = 32'hfd62f97a;
		crc_lookup[27]  = 32'h8a65c9ec;
		crc_lookup[28]  = 32'h14015c4f;
		crc_lookup[29]  = 32'h63066cd9;
		crc_lookup[30]  = 32'hfa0f3d63;
		crc_lookup[31]  = 32'h8d080df5;
		crc_lookup[32]  = 32'h3b6e20c8;
		crc_lookup[33]  = 32'h4c69105e;
		crc_lookup[34]  = 32'hd56041e4;
		crc_lookup[35]  = 32'ha2677172;
		crc_lookup[36]  = 32'h3c03e4d1;
		crc_lookup[37]  = 32'h4b04d447;
		crc_lookup[38]  = 32'hd20d85fd;
		crc_lookup[39]  = 32'ha50ab56b;
		crc_lookup[40]  = 32'h35b5a8fa;
		crc_lookup[41]  = 32'h42b2986c;
		crc_lookup[42]  = 32'hdbbbc9d6;
		crc_lookup[43]  = 32'hacbcf940;
		crc_lookup[44]  = 32'h32d86ce3;
		crc_lookup[45]  = 32'h45df5c75;
		crc_lookup[46]  = 32'hdcd60dcf;
		crc_lookup[47]  = 32'habd13d59;
		crc_lookup[48]  = 32'h26d930ac;
		crc_lookup[49]  = 32'h51de003a;
		crc_lookup[50]  = 32'hc8d75180;
		crc_lookup[51]  = 32'hbfd06116;
		crc_lookup[52]  = 32'h21b4f4b5;
		crc_lookup[53]  = 32'h56b3c423;
		crc_lookup[54]  = 32'hcfba9599;
		crc_lookup[55]  = 32'hb8bda50f;
		crc_lookup[56]  = 32'h2802b89e;
		crc_lookup[57]  = 32'h5f058808;
		crc_lookup[58]  = 32'hc60cd9b2;
		crc_lookup[59]  = 32'hb10be924;
		crc_lookup[60]  = 32'h2f6f7c87;
		crc_lookup[61]  = 32'h58684c11;
		crc_lookup[62]  = 32'hc1611dab;
		crc_lookup[63]  = 32'hb6662d3d;
		crc_lookup[64]  = 32'h76dc4190;
		crc_lookup[65]  = 32'h01db7106;
		crc_lookup[66]  = 32'h98d220bc;
		crc_lookup[67]  = 32'hefd5102a;
		crc_lookup[68]  = 32'h71b18589;
		crc_lookup[69]  = 32'h06b6b51f;
		crc_lookup[70]  = 32'h9fbfe4a5;
		crc_lookup[71]  = 32'he8b8d433;
		crc_lookup[72]  = 32'h7807c9a2;
		crc_lookup[73]  = 32'h0f00f934;
		crc_lookup[74]  = 32'h9609a88e;
		crc_lookup[75]  = 32'he10e9818;
		crc_lookup[76]  = 32'h7f6a0dbb;
		crc_lookup[77]  = 32'h086d3d2d;
		crc_lookup[78]  = 32'h91646c97;
		crc_lookup[79]  = 32'he6635c01;
		crc_lookup[80]  = 32'h6b6b51f4;
		crc_lookup[81]  = 32'h1c6c6162;
		crc_lookup[82]  = 32'h856530d8;
		crc_lookup[83]  = 32'hf262004e;
		crc_lookup[84]  = 32'h6c0695ed;
		crc_lookup[85]  = 32'h1b01a57b;
		crc_lookup[86]  = 32'h8208f4c1;
		crc_lookup[87]  = 32'hf50fc457;
		crc_lookup[88]  = 32'h65b0d9c6;
		crc_lookup[89]  = 32'h12b7e950;
		crc_lookup[90]  = 32'h8bbeb8ea;
		crc_lookup[91]  = 32'hfcb9887c;
		crc_lookup[92]  = 32'h62dd1ddf;
		crc_lookup[93]  = 32'h15da2d49;
		crc_lookup[94]  = 32'h8cd37cf3;
		crc_lookup[95]  = 32'hfbd44c65;
		crc_lookup[96]  = 32'h4db26158;
		crc_lookup[97]  = 32'h3ab551ce;
		crc_lookup[98]  = 32'ha3bc0074;
		crc_lookup[99]  = 32'hd4bb30e2;
		crc_lookup[100] = 32'h4adfa541;
		crc_lookup[101] = 32'h3dd895d7;
		crc_lookup[102] = 32'ha4d1c46d;
		crc_lookup[103] = 32'hd3d6f4fb;
		crc_lookup[104] = 32'h4369e96a;
		crc_lookup[105] = 32'h346ed9fc;
		crc_lookup[106] = 32'had678846;
		crc_lookup[107] = 32'hda60b8d0;
		crc_lookup[108] = 32'h44042d73;
		crc_lookup[109] = 32'h33031de5;
		crc_lookup[110] = 32'haa0a4c5f;
		crc_lookup[111] = 32'hdd0d7cc9;
		crc_lookup[112] = 32'h5005713c;
		crc_lookup[113] = 32'h270241aa;
		crc_lookup[114] = 32'hbe0b1010;
		crc_lookup[115] = 32'hc90c2086;
		crc_lookup[116] = 32'h5768b525;
		crc_lookup[117] = 32'h206f85b3;
		crc_lookup[118] = 32'hb966d409;
		crc_lookup[119] = 32'hce61e49f;
		crc_lookup[120] = 32'h5edef90e;
		crc_lookup[121] = 32'h29d9c998;
		crc_lookup[122] = 32'hb0d09822;
		crc_lookup[123] = 32'hc7d7a8b4;
		crc_lookup[124] = 32'h59b33d17;
		crc_lookup[125] = 32'h2eb40d81;
		crc_lookup[126] = 32'hb7bd5c3b;
		crc_lookup[127] = 32'hc0ba6cad;
		crc_lookup[128] = 32'hedb88320;
		crc_lookup[129] = 32'h9abfb3b6;
		crc_lookup[130] = 32'h03b6e20c;
		crc_lookup[131] = 32'h74b1d29a;
		crc_lookup[132] = 32'head54739;
		crc_lookup[133] = 32'h9dd277af;
		crc_lookup[134] = 32'h04db2615;
		crc_lookup[135] = 32'h73dc1683;
		crc_lookup[136] = 32'he3630b12;
		crc_lookup[137] = 32'h94643b84;
		crc_lookup[138] = 32'h0d6d6a3e;
		crc_lookup[139] = 32'h7a6a5aa8;
		crc_lookup[140] = 32'he40ecf0b;
		crc_lookup[141] = 32'h9309ff9d;
		crc_lookup[142] = 32'h0a00ae27;
		crc_lookup[143] = 32'h7d079eb1;
		crc_lookup[144] = 32'hf00f9344;
		crc_lookup[145] = 32'h8708a3d2;
		crc_lookup[146] = 32'h1e01f268;
		crc_lookup[147] = 32'h6906c2fe;
		crc_lookup[148] = 32'hf762575d;
		crc_lookup[149] = 32'h806567cb;
		crc_lookup[150] = 32'h196c3671;
		crc_lookup[151] = 32'h6e6b06e7;
		crc_lookup[152] = 32'hfed41b76;
		crc_lookup[153] = 32'h89d32be0;
		crc_lookup[154] = 32'h10da7a5a;
		crc_lookup[155] = 32'h67dd4acc;
		crc_lookup[156] = 32'hf9b9df6f;
		crc_lookup[157] = 32'h8ebeeff9;
		crc_lookup[158] = 32'h17b7be43;
		crc_lookup[159] = 32'h60b08ed5;
		crc_lookup[160] = 32'hd6d6a3e8;
		crc_lookup[161] = 32'ha1d1937e;
		crc_lookup[162] = 32'h38d8c2c4;
		crc_lookup[163] = 32'h4fdff252;
		crc_lookup[164] = 32'hd1bb67f1;
		crc_lookup[165] = 32'ha6bc5767;
		crc_lookup[166] = 32'h3fb506dd;
		crc_lookup[167] = 32'h48b2364b;
		crc_lookup[168] = 32'hd80d2bda;
		crc_lookup[169] = 32'haf0a1b4c;
		crc_lookup[170] = 32'h36034af6;
		crc_lookup[171] = 32'h41047a60;
		crc_lookup[172] = 32'hdf60efc3;
		crc_lookup[173] = 32'ha867df55;
		crc_lookup[174] = 32'h316e8eef;
		crc_lookup[175] = 32'h4669be79;
		crc_lookup[176] = 32'hcb61b38c;
		crc_lookup[177] = 32'hbc66831a;
		crc_lookup[178] = 32'h256fd2a0;
		crc_lookup[179] = 32'h5268e236;
		crc_lookup[180] = 32'hcc0c7795;
		crc_lookup[181] = 32'hbb0b4703;
		crc_lookup[182] = 32'h220216b9;
		crc_lookup[183] = 32'h5505262f;
		crc_lookup[184] = 32'hc5ba3bbe;
		crc_lookup[185] = 32'hb2bd0b28;
		crc_lookup[186] = 32'h2bb45a92;
		crc_lookup[187] = 32'h5cb36a04;
		crc_lookup[188] = 32'hc2d7ffa7;
		crc_lookup[189] = 32'hb5d0cf31;
		crc_lookup[190] = 32'h2cd99e8b;
		crc_lookup[191] = 32'h5bdeae1d;
		crc_lookup[192] = 32'h9b64c2b0;
		crc_lookup[193] = 32'hec63f226;
		crc_lookup[194] = 32'h756aa39c;
		crc_lookup[195] = 32'h026d930a;
		crc_lookup[196] = 32'h9c0906a9;
		crc_lookup[197] = 32'heb0e363f;
		crc_lookup[198] = 32'h72076785;
		crc_lookup[199] = 32'h05005713;
		crc_lookup[200] = 32'h95bf4a82;
		crc_lookup[201] = 32'he2b87a14;
		crc_lookup[202] = 32'h7bb12bae;
		crc_lookup[203] = 32'h0cb61b38;
		crc_lookup[204] = 32'h92d28e9b;
		crc_lookup[205] = 32'he5d5be0d;
		crc_lookup[206] = 32'h7cdcefb7;
		crc_lookup[207] = 32'h0bdbdf21;
		crc_lookup[208] = 32'h86d3d2d4;
		crc_lookup[209] = 32'hf1d4e242;
		crc_lookup[210] = 32'h68ddb3f8;
		crc_lookup[211] = 32'h1fda836e;
		crc_lookup[212] = 32'h81be16cd;
		crc_lookup[213] = 32'hf6b9265b;
		crc_lookup[214] = 32'h6fb077e1;
		crc_lookup[215] = 32'h18b74777;
		crc_lookup[216] = 32'h88085ae6;
		crc_lookup[217] = 32'hff0f6a70;
		crc_lookup[218] = 32'h66063bca;
		crc_lookup[219] = 32'h11010b5c;
		crc_lookup[220] = 32'h8f659eff;
		crc_lookup[221] = 32'hf862ae69;
		crc_lookup[222] = 32'h616bffd3;
		crc_lookup[223] = 32'h166ccf45;
		crc_lookup[224] = 32'ha00ae278;
		crc_lookup[225] = 32'hd70dd2ee;
		crc_lookup[226] = 32'h4e048354;
		crc_lookup[227] = 32'h3903b3c2;
		crc_lookup[228] = 32'ha7672661;
		crc_lookup[229] = 32'hd06016f7;
		crc_lookup[230] = 32'h4969474d;
		crc_lookup[231] = 32'h3e6e77db;
		crc_lookup[232] = 32'haed16a4a;
		crc_lookup[233] = 32'hd9d65adc;
		crc_lookup[234] = 32'h40df0b66;
		crc_lookup[235] = 32'h37d83bf0;
		crc_lookup[236] = 32'ha9bcae53;
		crc_lookup[237] = 32'hdebb9ec5;
		crc_lookup[238] = 32'h47b2cf7f;
		crc_lookup[239] = 32'h30b5ffe9;
		crc_lookup[240] = 32'hbdbdf21c;
		crc_lookup[241] = 32'hcabac28a;
		crc_lookup[242] = 32'h53b39330;
		crc_lookup[243] = 32'h24b4a3a6;
		crc_lookup[244] = 32'hbad03605;
		crc_lookup[245] = 32'hcdd70693;
		crc_lookup[246] = 32'h54de5729;
		crc_lookup[247] = 32'h23d967bf;
		crc_lookup[248] = 32'hb3667a2e;
		crc_lookup[249] = 32'hc4614ab8;
		crc_lookup[250] = 32'h5d681b02;
		crc_lookup[251] = 32'h2a6f2b94;
		crc_lookup[252] = 32'hb40bbe37;
		crc_lookup[253] = 32'hc30c8ea1;
		crc_lookup[254] = 32'h5a05df1b;
		crc_lookup[255] = 32'h2d02ef8d;
	end
	
//	 *	uint32_t
// *	crc32(const void *buf, size_t size)
// *	{
// *		const uint8_t *p = buf;
// *		uint32_t crc;
// *
// *		crc = ~0U;
// *		while (size--)
// *			crc = crc32_tab[(crc ^ *p++) & 0xFF] ^ (crc >> 8);
// *		return crc ^ ~0U;
// *	}
	
	
	wire [31:0] eff_crc = rst ? 32'hffffffff : ~bswap32(crc);
	wire [7:0]  lookup_index = data ^ eff_crc;
	
	
	reg  [31:0] lookup_value_b;
	reg         vld_b;
	reg  [31:0] eff_crc_b;
	always @(posedge clk) begin
		lookup_value_b <= crc_lookup[lookup_index];
		vld_b          <= vld;
		eff_crc_b      <= eff_crc;
	end
	
	assign crc = ~bswap32(vld_b ? lookup_value_b ^ (eff_crc_b >> 8) : eff_crc_b);
	

endmodule