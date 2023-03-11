unit Utiles;
{$codepage UTF-8}
interface

  uses
    Classes, SysUtils, Tipos, Dos, Lista,
    UnicodeCRT { Unidad de CRT Que soporta Unicode };

  procedure MostrarFecha(fecha: t_fecha; lineaSiguiente:boolean = false; mostrarHora: boolean = true);
  procedure LeerFecha(var fecha: t_fecha);
  procedure ObtenerFechaActual(var fecha:t_fecha);
  function  CompararFechas(fecha1, fecha2: t_fecha; compararHora: boolean = false):boolean;
  function  EstaEntreFechas(f1, f2, co: t_fecha; compararHora: boolean = false):boolean;
  function  EsFechaMasReciente(f1, f2: t_fecha; compararHora: boolean = false):boolean;
  procedure ConsultarFecha(var fecha: t_fecha);

  procedure MostrarGrilla(cabecera: t_cabecera);  
  procedure ListarPersonasGrilla(l: t_lista_persona; cabecera: t_cabecera);
  procedure ListarPersonaGrilla(persona: t_persona; cabecera: t_cabecera);
  procedure ListarLibrosGrilla(l: t_lista_libro; cabecera: t_cabecera);
  procedure ListarLibroGrilla(libro: t_libro; cabecera: t_cabecera; sinDev:boolean = false);
  function MostrarGrillaOpciones(opciones: t_grilla_opciones):word;
  
implementation
  
  procedure MostrarFecha(fecha: t_fecha; lineaSiguiente:boolean = false; mostrarHora: boolean = true);
  var mostrar:string; y,m,d,h: string;
  begin
    str(fecha.year, y); str(fecha.month, m);str(fecha.day, d);str(fecha.hour, h);
    mostrar := y + '/' + m + '/' + d;
    if(mostrarHora) then mostrar := mostrar + ' ' + h + 'hs';
    if(lineaSiguiente) then
      Writeln(mostrar)
    else
      Write(mostrar);
  end;

  function FormatFecha(fecha: t_fecha): string;
  var cadena:string; y,m,d,h: string;
  begin
    cadena := '';
    str(fecha.year, y); str(fecha.month, m);str(fecha.day, d);str(fecha.hour, h);
    cadena := y + '/' + m + '/' + d + ' ' + h + 'hs';
    FormatFecha := cadena;
  end;

  procedure LeerFecha(var fecha: t_fecha);
  begin
    Write(Utf8ToAnsi('Año: ')); Readln(fecha.year);
    if (fecha.year <> 0) then
      begin
        Write('Mes: '); Readln(fecha.month);
        Write(Utf8ToAnsi('Día: ')); Readln(fecha.day);
        Write('Hora: '); Readln(fecha.hour);
      end
    else
      fecha.month := 0;
      fecha.day := 0;
      fecha.hour := 0;
  end;

  procedure ObtenerFechaActual(var fecha:t_fecha);
  var wday,m,s,s100: word;
  begin
    GetDate(fecha.year,  fecha.month, fecha.day, wday);
    GetTime(fecha.hour,m,s,s100);
  end;

  function CompararFechas(fecha1, fecha2: t_fecha; compararHora: boolean = false):boolean;
  var iguales:boolean;
  begin
    iguales := true;
    if(fecha1.year <> fecha2.year) then iguales := false
    else if (fecha1.month <> fecha2.month) then iguales := false
          else if (fecha1.day <> fecha2.day) then iguales := false;

    if (iguales AND compararHora) AND (fecha1.hour <> fecha2.hour) then iguales := false;
    
    CompararFechas := iguales;
  end;

  function EstaEntreFechas(f1, f2, co: t_fecha; compararHora: boolean = false):boolean;
  begin
    EstaEntreFechas := EsFechaMasReciente(f1, co) AND EsFechaMasReciente(co, f2);
  end;

  { **
     Esta funcion compara dos fechas, solo devolviendo TRUE si la primera es mas reciente que la segunda fecha.
    ** }
  function EsFechaMasReciente(f1, f2: t_fecha; compararHora: boolean = false):boolean;
  var verifica:boolean;
  begin
    verifica := true;
    
    if (f1.year > f2.year) then verifica := false;
    
    // Si verifica miramos el caso en que los años sean iguales y los meses diferentes.
    if verifica AND (f1.year = f2.year) AND (f1.month > f2.month) then verifica := false;
    
    if verifica AND (f1.year = f2.year) AND (f1.month = f2.month) AND (f1.day > f2.day) then verifica := false;

    if (verifica AND compararHora) AND (f1.year = f2.year) AND (f1.month = f2.month) AND (f1.day = f2.day) AND (f1.hour > f2.hour) then verifica := false;
    
    EsFechaMasReciente := verifica;
  end;  

  procedure ConsultarFecha(var fecha: t_fecha);
  begin    
    Write('A continuacion ingrese la fecha que desea consultar: ');   writeln;
    Write(Utf8ToAnsi(' Año: ')); Readln(fecha.year); Write(' Mes: '); Readln(fecha.month); Write(Utf8ToAnsi(' Día: ')); Readln(fecha.day);
  end;

  procedure MostrarGrilla(cabecera: t_cabecera);
  var i: byte; cab: t_dato_cabecera; espacioTotal, eTotAhora, elocal: byte; 
  begin
    espacioTotal := 0;
    eTotAhora := 0;
    // Obtener espacio total ocupado
    for i := 1 to cabecera.tam do
      espacioTotal := espacioTotal + cabecera.elem[i].longitud + 1;
    espacioTotal := espacioTotal;
    i := 0;

    // Mostrar techo
    Write('┌');
    while i < espacioTotal-1 do begin
      Write('─');
      Inc(i);
    end;
    Writeln('┐');

    i := 1;
    While i <= cabecera.tam do
      begin
        cab := cabecera.elem[i];
        if(Length(cab.titulo) > 0) then
          begin
            gotoxy(eTotAhora+1, 2); // se mueve en la consola
            Write('│'+ cab.titulo + '│'); // muestra el titulo

            // contadores
            eTotAhora := eTotAhora + cab.longitud + 1;
            elocal := cab.longitud;

            // Baja uno en Y para escribir todos las lineas
            // del piso del titulo.
            gotoxy(eTotAhora - elocal, 3);

            if (i = 1) then
              Write('│')
            else
              Write('┼');
            while elocal > 0 do begin
              Write('─');
              Dec(elocal);
            end;

            if(i = cabecera.tam) then
              Write('┤')
            else
              Write('┼');
          end;

        Inc(i);
      end;
    
    Writeln;
  end;

  function FormatoGrilla(cadena: string; indice:byte; cabecera: t_cabecera): string;
  var long, diff: integer; hold: string;
  begin
    long := cabecera.elem[indice].longitud;
    if long < Length(cadena) then
      begin
        cadena := copy(cadena, 1, long);
      end
      else
      begin
        diff := long - Length(cadena);
        while diff > 0 do begin
          hold := hold + ' ';
          Dec(diff);
        end;
        cadena := cadena + hold;
      end;

      FormatoGrilla := cadena + '│';
  end;

  procedure ListarPersonaGrilla(persona: t_persona; cabecera: t_cabecera);
  var isbn, legajo: string;
  begin
      Str(persona.isbn, isbn);
      Str(persona.legajo, legajo);

      Write('│',FormatoGrilla(isbn,1, cabecera));
      Write(FormatoGrilla(legajo,2, cabecera));
      Write(FormatoGrilla(persona.nombre,3, cabecera));
      Write(FormatoGrilla(FormatFecha(persona.fechaRetiro), 4, cabecera));

      if persona.fechaDevolucion.year = 0 then begin
        Write(FormatoGrilla('        -', 5, cabecera));
      end
      else
        Write(FormatoGrilla(FormatFecha(persona.fechaDevolucion), 5, cabecera));

      Write(FormatoGrilla(persona.tipoRetiro, 6, cabecera));
      Writeln;
  end;  

  procedure ListarPersonasGrilla(l: t_lista_persona; cabecera: t_cabecera);
  var persona: t_persona;
  begin
    Primero(l);
    while (not Finlista(l)) do
    begin
      Recuperar(l, persona);
      ListarPersonaGrilla(persona, cabecera);
      Siguiente(l);
    end;
  end;  

  procedure ListarLibroGrilla(libro: t_libro; cabecera: t_cabecera; sinDev:boolean = false);
  var isbn, cantidad: string;
  begin
      Str(libro.isbn, isbn);
      Str(libro.cantidad, cantidad);

      if(sinDev) then begin
        Write('│',FormatoGrilla(isbn, 1, cabecera));
        Write(FormatoGrilla(libro.autor, 2, cabecera));
      end
      else begin
        Write('│',FormatoGrilla(isbn, 1, cabecera));
        Write(FormatoGrilla(libro.titulo, 2, cabecera));
        Write(FormatoGrilla(libro.autor, 3, cabecera));
        Write(FormatoGrilla(libro.area, 4, cabecera));
        Write(FormatoGrilla(cantidad, 5, cabecera));
      end;
      Writeln;
  end;  

  procedure ListarLibrosGrilla(l: t_lista_libro; cabecera: t_cabecera);
  var libro: t_libro;
  begin
    Primero(l);
    while (not Finlista(l)) do
    begin
      Recuperar(l, libro);
      ListarlibroGrilla(libro, cabecera);
      Siguiente(l);
    end;
  end; 

  function MostrarGrillaOpciones(opciones: t_grilla_opciones): word;
  var i,x,y:byte; el,lineaLarga: string; rta: word;
  begin
    { ┌──────┬─────────────────────────────────────────┐ ┌ ────── ┬ ──────────────────────────────────────── ┐ # TECHO
      │  #1  │            OPCION 1                     │  
      │──────┼─────────────────────────────────────────│ 
      │  #2  │ OPCION2 OPCION2 OPCION2 OPCION2 OPCION2 │ │        │                                          │ # OPCION
      │──────┼─────────────────────────────────────────│ 
      │  #3  │       OPCION3 OPCION3 OPCION3           │ │ ────── ┼ ──────────────────────────────────────── │ # SEPARADOR
      │──────┼─────────────────────────────────────────│
      │  ... │                ...                      │ │        │                                          │ # OPCION
      │──────┼─────────────────────────────────────────│
      │  #N  │            OPCION N                     │
      └──────┴─────────────────────────────────────────┘ └ ────── ┴ ──────────────────────────────────────── ┘ # PISO
    }
    lineaLarga := '';
    for i:=1 to opciones.longitudMax do
        lineaLarga := lineaLarga + ('─');

    // TECHO ┌ ────── ┬ ──────────────────────────────────────── ┐
      WriteLn('┌──────┬', lineaLarga, '┐');

    // OPCIONES │  #N    │            OPCION N                      │
    // MEDIO    │ ────── ┼ ──────────────────────────────────────── │ O
    // PISO     └ ────── ┴ ──────────────────────────────────────── ┘
      for i:=1 to opciones.titulos.tam do begin
        el := opciones.titulos.elem[i];
        Write('│  '); TextColor(124); Write('#',i-1);
        //if(el[Length(el)] = ' ') then
          // el := copy(el, 0, Length(el) - 1);
        TextColor(111); WriteLn('  │', el, '│');
        
        if(i <> opciones.titulos.tam) then
          WriteLn('├──────┼', lineaLarga, '│')
        else
          WriteLn('└──────┴', lineaLarga, '┘');
      end;

      WriteLn('┌──────┬', lineaLarga, '┐');
      Write('│  '); TextColor(122); Write('#OP'); TextColor(111); Write(' │');  x := WhereX; y := WhereY; writeln;
      WriteLn('└──────┴', lineaLarga, '┘');
      gotoXY(x+ (opciones.longitudMax DIV 2),y); Readln(rta);
      MostrarGrillaOpciones := rta;
  end;

end.

