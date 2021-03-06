module ArchCTRL(
	input	clk,
	input	TR,
	input	VL,
	input	END,
	output	FPH,
	output	FPO,
	output	BPH,
	output	BPO,
	output	S_Train,
	output	S_Error
);

reg [5:0] count;
reg [3:0] Signal;
reg [1:0] TV;
reg ST, SE;

assign {FPH, FPO, BPH, BPO} = Signal;
assign S_Train = ST;
assign S_Error = SE;

initial begin
	count <= 6'b000000;
	Signal <= 4'b0000;
	TV <= 2'b00;
	ST <= 1'b0;
	SE <= 1'b0;
end

always @ (negedge clk) begin
	if (TR) begin
		TV <= 2'b10;
		count <= 6'b000000;
		Signal <= 4'b1000;
	end
	
	else if (VL) begin
		TV <= 2'b01;
		count <= 6'b000000;
		Signal <= 4'b1000;
	end

	else if (END) begin
		TV <= 2'b00;
		count <= 6'b000000;
		Signal <= 4'b0000;
	end

	else begin
		count <= count + 6'b000001;
	end
end

always @ (negedge clk) begin
	casex ({TV,count})
	8'b00_xxxxxx: begin			//None
		count <= 6'b000000;
		Signal <= 4'b0000;
	end
	// Training
	8'b10_000001: begin			//Forward: Hidden Start
		Signal <= 4'b1000;
	end
	8'b10_000110: begin			//Forward: Output Start
		Signal <= 4'b0100;
	end
	8'b10_010110: begin			//Backward: Output Start
		Signal <= 4'b0101;
	end
	8'b10_010111: begin			//Backward: Output
		Signal <= 4'b0001;
	end
	8'b10_100110: begin			//Backward: Output + Hidden Start
		Signal <= 4'b1011;
	end
	8'b10_100111: begin			//Backward: Output + Hidden End
		Signal <= 4'b0011;
	end
	8'b10_110000: begin			//Backward: Output Continue
		Signal <= 4'b0001;
	end
	8'b10_111000: begin			//Training Complete
		Signal <= 4'b0000;
		//count <= 6'b000000;
		//TV <= 2'b00;
		ST <= 1'b1;
	end
	8'b10_111001: begin			//Training Complete
		count <= 6'b000000;
		//TV <= 2'b00;
		ST <= 1'b0;
	end
	// Validation
	8'b01_000001: begin			//Forward: Hidden Start
		Signal <= 4'b1000;
	end
	8'b01_000101: begin			//Forward: Output Start + Hidden End
		Signal <= 4'b0100;
	end
	8'b01_010110: begin			//Validation Complete
		Signal <= 4'b0000;
		//count <= 6'b000000;
		//TV <= 2'b00;
		SE <= 1'b1;
	end
	8'b01_010111: begin			//Validation Complete
		count <= 6'b000000;
		//TV <= 2'b00;
		SE <= 1'b0;
	end
	endcase
end

endmodule // ArchCTRL