`include "source.v"
`include "coffee_machine.v"

module coffee_machine_TB;
	reg clock;
	wire reset;
	wire[1:0] selec_produto;
	wire[2:0] dinheiro;
	// wire [1:0] ;

	source source(
		.reset(reset),
		.clock(clock),
		.dinheiro(dinheiro), 
		.selec_produto(selec_produto)
	);

	coffee_machine coffee_machine(

		.reset(reset),
		.clock(clock),
		.dinheiro(dinheiro), 
		.selec_produto(selec_produto)
	);


	initial begin
		clock = 0;
		#5;
		clock = 1;
		#100$finish;
	 end

	initial begin
		$display("Rodando TB");
		
		$dumpfile("coffee_machine.vcd");  
		$dumpvars; 
	end

	always
		#5 clock = ~clock;


endmodule