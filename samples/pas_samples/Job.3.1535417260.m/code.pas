
program Hello ;

var
  valor: INTEGER;
  a : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  b : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  c : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  d : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  e : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  f : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  g : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  h : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  i : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  j : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  k : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  l : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  m : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  n : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  o : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  p : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  q : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  r : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  s : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  t : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  u : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  v : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  w : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  x : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  y : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  z : array[ 1..2, 1..1024 , 1..1024] of LONGINT; (* ~8 MB *)
  
  (* 26 x 8MB ~= 208 MB *)

begin
  readln ( valor );
  writeln ( valor * 2 );
end.

