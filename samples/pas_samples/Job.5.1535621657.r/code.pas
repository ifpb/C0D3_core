
program Hello ;

var
  valor: INTEGER;
  description: ^string;
  
begin
  readln ( valor );
  writeln ( valor * 2 );
  
  description^ := 'It is a proposital error!';
end.

