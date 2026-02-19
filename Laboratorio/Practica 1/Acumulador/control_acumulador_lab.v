module control_acumulador_lab(
	clk, 
	rst,
	init,
	z,
	out_rst,
	acc,
	add,
	done
);

	input clk;
	input rst;
	input init;
	input z;

	output reg out_rst;
	output reg acc;
	output reg add;
	output reg done;

	
	parameter START = 3'b000;
	parameter LOAD = 3'b101;
	parameter ADD = 3'b001;
	parameter ACC = 3'b010;
	parameter CHECK = 3'b011;
	parameter DONE = 3'b100;

	reg [2:0] state;

	always @(negedge clk) begin
		if (rst) begin
			state = START;
		end else begin
			case (state) 
				START : begin
					state = init ? LOAD : START; 
				end
				LOAD : begin
					state = ADD;
				end
				ADD : begin
					state = ACC;
				end
				ACC : begin
					state = CHECK;
				end
				CHECK : begin
					state = z ? DONE : ADD;
				end
				DONE : begin
					state = START;
				end

				default : begin
					state = START;
				end
			endcase
		end

	end

	always @(*) begin
		case (state)
			START : begin
				out_rst = 0;
				acc = 0;
				add = 0;
				done = 0;
			end
			LOAD : begin
				out_rst = 1;
				acc = 0;
				add = 0;
				done = 0;
			end
			ADD : begin
				out_rst = 0;
				acc = 0;
				add = 1;
				done = 0;
			end
			ACC : begin
				out_rst = 0;
				acc = 1;
				add = 0;
				done = 0;
			end
			CHECK : begin
				out_rst = 0;
				acc = 0;
				add = 0;
				done = 0;
			end
			DONE : begin
				out_rst = 0;
				acc = 0;
				add = 0;
				done = 1;
			end
			default : begin
				out_rst = 1;
				acc = 0;
				add = 0;
				done = 0;
			end
		endcase
	end

	



endmodule
