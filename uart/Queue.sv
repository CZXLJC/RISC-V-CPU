// module Queue (
//     input  logic        clk_16x, rst_n,
//     input  logic [7:0]  data_in,
//     input  logic        data_ready,
//     output logic        inst_valid,
//     output logic [31:0] inst
// );

//     reg [31:0] data_queue = 0;
//     reg [2:0] cnt = 0;
//     reg [4:0] clk_cnt = 0;
//     wire full;

//     assign inst = data_queue;
//     assign full = (cnt == 4);
//     assign inst_valid = full && (clk_cnt == 15);

//     always_ff @(posedge clk_16x or negedge rst_n) begin : cnt_for_mem
//         if (!rst_n) begin
//             clk_cnt <= 0;
//         end else if (clk_cnt == 15) begin
//             clk_cnt <= 0;
//         end else if (full) begin
//             clk_cnt <= clk_cnt + 1;
//         end else begin
//             clk_cnt <= clk_cnt;
//         end
//     end

//     always_ff @(posedge clk_16x or negedge rst_n) begin : write
//         if (!rst_n || (full && clk_cnt == 15)) begin
//             cnt <= 0;
//             data_queue <= 0;
//         end else if (data_ready) begin
//             cnt <= cnt + 1;
//             data_queue <= {data_queue[23:0], data_in};
//         end else begin
//             cnt <= cnt;
//             data_queue <= data_queue;
//         end
//     end
    
// endmodule