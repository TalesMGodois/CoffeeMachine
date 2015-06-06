module source(clock,reset,selec_produto,dinheiro);
	input clock;
	output reg reset;
	output reg[1:0] selec_produto;
	output reg[2:0] dinheiro;
	reg[7:0] MONEY [7:0];
	reg[3:0] COFFEES [3:0];

	parameter CAFE = 2'b00, CAPUCCINO = 2'b01, CAFE_LONGO = 2'b10, ACHOCOLATADO = 2'b11;

	initial begin
		MONEY[0] = 3'b000;// 5 centavos
		MONEY[1] = 3'b001;// 10 centavos
		MONEY[2] = 3'b010;// 25 centavos
		MONEY[3] = 3'b011;// 50 centavos 
		MONEY[4] = 3'b100;// 1 real
		MONEY[5] = 3'b101;// 2 reais
		MONEY[6] = 3'b110;// 5 reais
		MONEY[7] = 3'b111;// 10 reais

		COFFEES[0] = CAFE;
		COFFEES[1] = CAPUCCINO;
		COFFEES[2] = CAFE_LONGO;
		COFFEES[3] = ACHOCOLATADO;


		dinheiro = MONEY[7];
		//Escolhendo a Opção de Café
		selec_produto = COFFEES[0];


	end
	
	always @(posedge clock ) begin
		#10
		reset =1;	
	end

endmodule