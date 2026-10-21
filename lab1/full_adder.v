module full_adder (
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);

    wire w_xor1;
    wire w_and1;
    wire w_and2;

    // Primitive Gate Instantiations
    xor g1 (w_xor1, a, b);
    xor g2 (sum, w_xor1, cin);

    and g3 (w_and1, a, b);
    and g4 (w_and2, w_xor1, cin);

    or  g5 (cout, w_and1, w_and2);

endmodule
