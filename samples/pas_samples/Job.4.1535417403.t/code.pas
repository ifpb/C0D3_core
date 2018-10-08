
program Hello ;

var
  valor: INTEGER;
  v: INTEGER;

begin
  readln ( valor );
  writeln ( valor * 2 );
  
  v := 0;
  
  while (valor > 0) do
  begin
    v := valor + v;
  end;
  
end.

