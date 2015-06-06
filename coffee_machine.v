
module coffee_machine(selec_produto,dinheiro,clock,reset,hasProduto,hasTroco);
	
	// Entradas e Saidas que movem a maquna de estado.
	input clock,reset;
	input[1:0]  selec_produto;
	input[2:0]  dinheiro;
	output reg hasProduto,hasTroco;

	//Usado para calcular o troco
	reg TOTAL =0;
	integer outOfLoop =1;
	reg[4:0] using;
	reg[4:0] moedas [8:0];
	reg[4:0] moedas_troco [5:0];
	reg[2:0] notas;
	reg[3:0] COFFEES [3:0];
	reg[3:0] PRICES [3:0];
	reg[7:0] MONEY[7:0];

	//ESTADO da Maquina
	reg[1:0] STATE;

	// Usados para a parte combinacional da maquina de estados
	reg inicio =0,escolhido=0,entregue=0;
	reg[1:0] pago =0;

	//Parametros Default a serem utilizados
	//Estados
	parameter ESPERA =2'b00, ESCOLHER_PRODUTO =2'b01, PAGAMENTO =2'b10, ENTREGA_PRODUTO =2'b11;
	//Produtos
	parameter CAFE = 2'b00, CAPUCCINO = 2'b01, CAFE_LONGO = 2'b10, ACHOCOLATADO = 2'b11;


	//Variaveis de inicializacao
	reg[0:4] i =0;
	integer valor_final;
	initial valor_final =2'd00;


	integer num_moedas;
	initial num_moedas =0;

	integer aux_troco;
	initial aux_troco =2'd00;

	integer VALOR_INSERIDO;
	integer VALOR_PRODUTO;

	initial VALOR_INSERIDO = 2'd00;
	initial VALOR_PRODUTO = 2'd00;

	initial begin

		MONEY[0] = 3'b000;// 5 centavos
		MONEY[1] = 3'b001;// 10 centavos
		MONEY[2] = 3'b010;// 25 centavos
		MONEY[3] = 3'b011;// 50 centavos 
		MONEY[4] = 3'b100;// 1 real
		MONEY[5] = 3'b101;// 2 reais
		MONEY[6] = 3'b110;// 5 reais
		MONEY[7] = 3'b111;// 10 Reais

		
		for(i=0;i<=4;i = i+1) begin
			moedas[i] = 10;
			moedas_troco[i] = 0;
			num_moedas = num_moedas + moedas[i];
		end

		for(i=0;i<=4;i = i+1) begin
			using[i] = 1;
		end

		for(i=0;i<=2;i = i+1) begin
			notas[i] = 0;
		end


		$display("===========+====================+==================");
		$display("XXX Moedas XXX ");
		$display("Moedas de 5 centavos: %d Moedas",moedas[0]);
		$display("Moedas de 10 centavos: %d Moedas",moedas[1]);
		$display("Moedas de 25 centavos: %d Moedas",moedas[2]);
		$display("Moedas de 50 centavos: %d Moedas",moedas[3]);
		$display("Moedas de 1 Real: %d Moedas",moedas[4]);
		$display("===========+====================+==================");

		PRICES[0] = 3'b011;// 50 centavos 	- 50
		PRICES[1] = 3'b100;// 1 real 		- 100	
		PRICES[2] = 3'b101;// 2 reais		- 200
		PRICES[3] = 3'b101;// 2 reais		- 200


		COFFEES[0] = CAFE;
		COFFEES[1] = CAPUCCINO;
		COFFEES[2] = CAFE_LONGO;
		COFFEES[3] = ACHOCOLATADO;

	end

	always @(posedge clock) begin


		if(~reset)
			STATE <= ESPERA;
		else begin
			case (STATE)
				ESPERA:				if(inicio == 1)
										STATE<= ESCOLHER_PRODUTO;

				ESCOLHER_PRODUTO:	if(escolhido==1)
										STATE<= PAGAMENTO;

				PAGAMENTO:			if(pago == 1) begin
										STATE<= ESPERA;
									end
									else if(pago == 2) begin
										STATE<= ENTREGA_PRODUTO;
									end
				ENTREGA_PRODUTO:	if(entregue==1)
										STATE<= ESPERA;

				default:			STATE<= ESPERA;
			endcase

		end


		case(selec_produto)
			COFFEES[0]: begin
				$display("Produto: CAFÉ");

				VALOR_PRODUTO = 1;
			end
			COFFEES[1]: begin
				$display("Produto: CAFÉ_LONGO");
				VALOR_PRODUTO = 2;
			end
			COFFEES[2]: begin
				$display("Produto: ACHOCOLATADO");
				VALOR_PRODUTO = 5;
			end
			COFFEES[3]: begin
				$display("Produto: CAPUCCINO");
				VALOR_PRODUTO = 5;
			end
		endcase



		case(dinheiro)
			MONEY[0]: begin
				VALOR_INSERIDO = 0.05;
				moedas[0] = moedas[0] +1;
			end
			MONEY[1]: begin
				VALOR_INSERIDO = 0.10;
				moedas[1] = moedas[1] +1;

			end
			MONEY[2]: begin
				VALOR_INSERIDO = 0.25;
				moedas[2] = moedas[2] +1;
			end
			MONEY[3]: begin
				VALOR_INSERIDO = 0.50;
				moedas[3] = moedas[3] +1;
			end
			MONEY[4]: begin
				VALOR_INSERIDO = 1;
				moedas[4] = moedas[4] +1;
			end
			MONEY[5]: begin
				VALOR_INSERIDO = 2;
				notas[0] = notas[0] + 1;

			end
			MONEY[6]: begin
				VALOR_INSERIDO = 5;
				notas[1] = notas[1] + 1;
			end
			MONEY[7]: begin
				VALOR_INSERIDO = 10;
				notas[2] = notas[2] + 1;
			end
		endcase


		case(STATE)
			ESPERA: begin
				$display("Estado: ESPERA");
				hasProduto = 0;
				hasTroco =0;
				inicio =1;
				entregue =0;
				escolhido =0;
			end

			ESCOLHER_PRODUTO: begin
				$display("Estado: ESCOLHER_PRODUTO");
				hasProduto =1;
				hasTroco =0;
				escolhido =1;

			end

			PAGAMENTO: begin
				outOfLoop = 0;
				$display("Estado: PAGAMENTO");
				if(VALOR_INSERIDO >=VALOR_PRODUTO) begin
					valor_final = VALOR_INSERIDO - VALOR_PRODUTO;
					$display("O valor a ser retornado como troco é: R$ %f ",valor_final );
					hasTroco = 1;

					while ((aux_troco != valor_final) && (num_moedas > 0) && (outOfLoop<=250))begin
						// $display("Este é o troco até então %f",aux_troco);
						if(moedas[4] > 0 && using[4] != 0 )begin
							aux_troco = aux_troco + 1;
							if(aux_troco < valor_final) begin
								moedas_troco[4] = moedas_troco[4] +1;
								moedas[4] = moedas[4] -1;
								num_moedas = num_moedas -1;

							end else if(aux_troco == valor_final) begin
								moedas_troco[4] = moedas_troco[4] +1;
								moedas[4] = moedas[4] -1;
								num_moedas = num_moedas -1;

								if(aux_troco == valor_final) begin
									$display("Troco: %f, Com a seguinte distribuição:",aux_troco);
									$display("R$1,00: %d || R$0,50: %d || R$0,25: %d || R$0,10: %d || R$0,05: %d ",moedas_troco[4],moedas_troco[3],moedas_troco[2],moedas_troco[1],moedas_troco[0]);
									hasTroco =1;
								end else begin
									hasTroco =0;
									$display("Não é possível realizar troco");
								end
							
							using[4] =0;
							end else begin
								moedas_troco[4] = moedas_troco[4] -1;
								aux_troco = aux_troco - 1;
								using[4] =0;
							end
						end else begin
							hasTroco =0;
							// $display(1);
							$display("Não foi possivel realizar o PAGAMENTO");
						end
						outOfLoop = outOfLoop +1;
					end
				end else begin
					// $display(2);
					hasTroco = 0;

					$display("Não foi possivel realizar o PAGAMENTO");
				end
				if(hasTroco ==0) begin
					pago = 1;
				end else begin
					pago =2;
				end
				$display("outOfLoop");
				$display(outOfLoop);
			end 
							
			ENTREGA_PRODUTO: begin
				$display("Estado: ENTREGA_PRODUTO");
				entregue =1;
				$display("Produto Está pronto");
				$display("--------------------------------------------------------");
			end
			default:begin
				$display("Estado: ESPERA");
				hasProduto = 0;
				hasTroco =0;
				entregue =0;
				inicio =0;
				escolhido =0;
			end
		endcase

	end
		

endmodule
