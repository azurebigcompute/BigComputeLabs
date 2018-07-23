`celldefine
module s6 ( in1, out1 );
  input in1; output out1; reg out1;
  always @(in1) #(4+($random % 4)) out1 = in1;
endmodule
`endcelldefine

module s5 ( in1, out1 );
  input in1; output out1;
  wire a,b,c,d,e,f,g,h,i;
  s6 g1 ( in1, a );
  s6 g2 ( a, b );
  s6 g3 ( b, c );
  s6 g4 ( c, d );
  s6 g5 ( d, e );
  s6 g6 ( e, f );
  s6 g7 ( f, g );
  s6 g8 ( g, h );
  s6 g9 ( h, i );
  s6 g10( i, out1);
endmodule

module s4 ( in1, out1 );
  input in1; output out1;
  wire a,b,c,d,e,f,g,h,i;
  s5 g1 ( in1, a );
  s5 g2 ( a, b );
  s5 g3 ( b, c );
  s5 g4 ( c, d );
  s5 g5 ( d, e );
  s5 g6 ( e, f );
  s5 g7 ( f, g );
  s5 g8 ( g, h );
  s5 g9 ( h, i );
  s5 g10( i, out1);
endmodule

module s3 ( in1, out1 );
  input in1; output out1;
  wire a,b,c,d,e,f,g,h,i;
  s4 g1 ( in1, a );
  s4 g2 ( a, b );
  s4 g3 ( b, c );
  s4 g4 ( c, d );
  s4 g5 ( d, e );
  s4 g6 ( e, f );
  s4 g7 ( f, g );
  s4 g8 ( g, h );
  s4 g9 ( h, i );
  s4 g10( i, out1);
endmodule

module s2 ( in1, out1 );
  input in1; output out1;
  wire a,b,c,d,e,f,g,h,i;
  s3 g1 ( in1, a );
  s3 g2 ( a, b );
  s3 g3 ( b, c );
  s3 g4 ( c, d );
  s3 g5 ( d, e );
  s3 g6 ( e, f );
  s3 g7 ( f, g );
  s3 g8 ( g, h );
  s3 g9 ( h, i );
  s3 g10( i, out1);
endmodule

module s1 ( in1, out1 );
  input in1; output out1;
  wire a,b,c,d,e,f,g,h,i;
  s2 g1 ( in1, a );
  s2 g2 ( a, b );
  s2 g3 ( b, c );
  s2 g4 ( c, d );
  s2 g5 ( d, e );
  s2 g6 ( e, f );
  s2 g7 ( f, g );
  s2 g8 ( g, h );
  s2 g9 ( h, i );
  s2 g10( a, out1);
endmodule

module test;

  reg a; wire b;
  
  s1 dut ( a, b );
  
  initial a = 0;
  always #(10+($random % 4)) a = ~ a;
  
  `ifdef long 
	initial #8_100_000 $finish;
  `else initial #8000 $finish;
`endif
	
  always   #1_000 $display("Got to time ",$time);
  
  initial 
  begin
    $shm_open("bigtrnfile");
    $shm_probe("AC");
  end
endmodule
