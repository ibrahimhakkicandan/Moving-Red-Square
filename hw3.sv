// Atila İlhan Yatağan 150118033
// İbrahim Hakkı Candan 150118061
// Aykut Başyiğit 150115854


module hw3 ( input clk,
 input ps2c,
 input ps2d,
 output logic ground,
 output logic [2:0] rgb,
 output logic hsync,
 output logic vsync
 );
 

logic [15:0] data_all;
logic  [15:0] x;
logic  [15:0] y;
logic ack;
//memory map is defined here
localparam BEGINMEM=12'h000,
ENDMEM=12'h1ff,
XPOSITION=12'hb01,
YPOSITION=12'hb02,
KEYBOARD=12'h900,
VGA=12'hb00;

// memory chip
logic [15:0] memory [0:127];
// cpu's input-output pins
logic [15:0] data_out;
logic [15:0] data_in;
logic [11:0] address;
logic memwt;

// keyboard data out
logic [15:0] o_keyboard_data;

//multiplexer for cpu input

vga_sync vga(
    .clk(clk),
    .hsync(hsync),
    .vsync(vsync),
    .rgb(rgb),
	 .xPixel(x),
	 .yPixel(y)
    ); 

keyboard keyboard(
    .clk(clk),
    .ps2d(ps2d),
    .ps2c(ps2c),
    .ack(ack),
    .dout(o_keyboard_data)
    ); 

bird bird (
    .clk(clk),
    .data_in(data_in),
    .data_out(data_out),
    .address(address),
    .memwt(memwt),
    ); 


always_comb
if ( (BEGINMEM<=address) && (address<=ENDMEM) )
begin
ack=0;
data_in=memory[address];
end

else if (address==VGA)
begin
ack=0;
data_in=memory[address];
end

else if (address==KEYBOARD+1) // status
begin 
data_in= o_keyboard_data;
ack=0; // ?
end 

else if (address==KEYBOARD) // data
begin 
data_in= o_keyboard_data;
ack=1;
end 

else begin
ack=0;
data_in=16'hf345; //default
end



//multiplexer for cpu output
always_ff @(posedge clk) //data output port of the cpu
if (memwt)
begin
if ( (BEGINMEM<=address) && (address<=ENDMEM) )
memory[address]<=data_out;
else if (address==XPOSITION)
x<=data_out;
else if (address==YPOSITION)
y<=data_out;
end
initial begin
    $readmemh("ram.dat", memory);
end
endmodule