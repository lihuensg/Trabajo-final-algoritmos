program Archivos;
uses unit_archivos;
var
vector:t_lista;
op:byte;
ruta:string;
  begin
  op := 255;
  ruta:='C:\tmp\pyr.dat';  
  leerArchivo(ruta,vector);
  while op <> 0 do begin
  writeln;
  WriteLn('0. SALIR -- 1. Agregar PR -- 2. Reniciar Base Datos -- 3.Chatterbot -- 4. Mostrar contenido archivo');
  Readln(op);
   case op of
     1: EscribirEnArchivo(ruta);
     2: leerArchivo(ruta,vector);
     3: Chatterbot(vector);
     4: MostrarContenido(ruta);
    end;
  end;
end.
