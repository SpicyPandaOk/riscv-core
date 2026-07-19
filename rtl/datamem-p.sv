module data_mem(
    input clk, mem_write, mem_read,
    input [2:0] funct3,
    input [31:0] addr, write_data, 
    output reg [31:0] read_data
);

    reg [31:0] data [0:255];
    wire [31:0] word;
    assign word = data[addr[9:2]];

    always@(*) begin
        read_data = 32'b0;
        if(mem_read) begin
            case (funct3)
                3'h0: begin 
                    case (addr[1:0])
                        2'b00: read_data = {{24{word[7]}}, word[7:0]};
                        2'b01: read_data = {{24{word[15]}}, word[15:8]};
                        2'b10: read_data = {{24{word[23]}}, word[23:16]};
                        2'b11: read_data = {{24{word[31]}}, word[31:24]};
                        default: read_data = 32'b0;
                    endcase
                end

                3'h1: begin
                    case (addr[0])
                        1'b0: read_data = {{16{word[15]}}, word[15:0]};
                        1'b1: read_data = {{16{word[31]}}, word[31:16]}; 
                        default: read_data = 32'b0;
                    endcase
                end

                3'h2: read_data = word;

                3'h4: begin
                    case (addr[1:0])
                        2'b00: read_data = {{24{1'b0}}, word[7:0]};
                        2'b01: read_data = {{24{1'b0}}, word[15:8]};
                        2'b10: read_data = {{24{1'b0}}, word[23:16]};
                        2'b11: read_data = {{24{1'b0}}, word[31:24]}; 
                        default: read_data = 32'b0;
                    endcase
                end

                3'h5: begin
                    case (addr[0])
                        1'b0: read_data = {{16{1'b0}}, word[15:0]};
                        1'b1: read_data = {{16{1'b0}}, word[31:16]}; 
                        default: read_data = 32'b0;
                    endcase
                end

                default: read_data = 32'b0;
            endcase
        end
        
    end

    always@(posedge clk) begin
        if(mem_write)begin
            case (funct3)
                3'h0: begin
                    case (addr[1:0])
                        2'b00: data[addr[9:2]][7:0] <= write_data[7:0]; 
                        2'b01: data[addr[9:2]][15:8] <= write_data[7:0];
                        2'b10: data[addr[9:2]][23:16] <= write_data[7:0];
                        2'b11: data[addr[9:2]][31:24] <= write_data[7:0];
                    endcase
                end 

                3'h1: begin
                    case (addr[0])
                        1'b0: data[addr[9:2]][15:0] <= write_data[15:0];
                        1'b1: data[addr[9:2]][31:16] <= write_data[15:0];
                    endcase
                end

                3'h2: data[addr[9:2]] <= write_data;
            endcase
        end
    end
    
    
endmodule


