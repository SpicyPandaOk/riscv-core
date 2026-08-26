module branch_predict(
    input [31:0] pc,
    input ID_EX_branch,
    input [31:0] ID_EX_pc,
    input [31:0] ID_EX_real_branch_target,
    input ID_EX_real_branch_taken,
    input clk,
    output reg branch_taken,
    output reg [31:0] branch_target

);



    reg [1:0] sat_counters [0:255];
    reg [31:0] b_targets [0:255];

    initial begin
        for(int i = 0; i < 256; i= i + 1) begin
            sat_counters[i] = 2'b01;
            b_targets[i] = 32'd0;
        end
    end



    always @(*) begin
        case(sat_counters[pc[9:2]]) 
            2'b00, 2'b01: begin
                branch_taken = 1'b0;
                branch_target = 32'd0;
            end
            2'b10, 2'b11: begin
                branch_taken = 1'b1;
                branch_target = b_targets[pc[9:2]];
            end
            default: begin
                branch_taken = 1'b0;
                branch_target = 32'd0;
            end
            
        endcase
        
        
    end

    always@(posedge clk) begin
        if(ID_EX_branch) begin
            if(ID_EX_real_branch_taken) begin
                if(sat_counters[ID_EX_pc[9:2]] != 2'b11) begin
                    sat_counters[ID_EX_pc[9:2]] <= sat_counters[ID_EX_pc[9:2]] +  1'b1;
                end
                b_targets[ID_EX_pc[9:2]] <= ID_EX_real_branch_target;


            end
            else begin
                if(sat_counters[ID_EX_pc[9:2]] != 2'b00) begin
                sat_counters[ID_EX_pc[9:2]] <= sat_counters[ID_EX_pc[9:2]] - 1'b1;
                end
                b_targets[ID_EX_pc[9:2]] <= ID_EX_pc + 4;
            end

        end
        
    end

endmodule