// Sample Verilog Code
module and_gate (
    input wire a,
    input wire b,
    output wire y
);
    assign y = a & b; // AND operation
endmodule

module or_gate (
    input wire a,
    input wire b,
    output wire y
);
    assign y = a | b; // OR operation
endmodule

module top_module (
    input wire a,
    input wire b,
    output wire and_out,
    output wire or_out
);
    // Instantiate AND gate
    and_gate u1 (
        .a(a),
        .b(b),
        .y(and_out)
    );

    // Instantiate OR gate
    or_gate u2 (
        .a(a),
        .b(b),
        .y(or_out)
    );
endmodule