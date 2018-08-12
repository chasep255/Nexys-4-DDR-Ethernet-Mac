
function [31:0] bswap32;
	input [31:0] x;
	begin
		bswap32 = {x[7:0], x[15:8], x[23:16], x[31:24]};
	end
endfunction