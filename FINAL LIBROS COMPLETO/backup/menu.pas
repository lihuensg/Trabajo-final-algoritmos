unit Menu;

interface

  uses
    Archivos, Arbol, Tipos, Libro, Persona, Utiles, crt { Unidad de CRT Que soporta Unicode };

  procedure InicializarListasArbol(var listaLibros: t_lista_libro; var listaPersonas: t_lista_persona; var arbolLibros: t_punt_arbol; var arbolPersona: t_punt_arbol);
  procedure InicializarGrilla(var cabeceraPersona, cabeceraLibros: t_cabecera; var opPPALGrilla, opABMGrilla, opEstadisticasGrilla: t_grilla_opciones);
  procedure MenuPPAL(var listaLibros: t_lista_libro; var listaPersonas: t_lista_persona; var arbolLibros: t_punt_arbol; var arbolPersona: t_punt_arbol; cabeceraPersonas, cabeceraLibros: t_cabecera; opPPALGrilla, opABMGrilla, opEstadisticasGrilla: t_grilla_opciones);
    
implementation
  
  procedure InicializarListasArbol(var listaLibros: t_lista_libro; var listaPersonas: t_lista_persona; var arbolLibros: t_punt_arbol; var arbolPersona: t_punt_arbol);
  begin
    CrearArbol(arbolLibros);
    CrearArbol(arbolPersona);

    listaLibros.tam := 0; listaPersonas.tam := 0;
    LeerArchivo(RUTALIBROS, listaLibros, arbolLibros);
    LeerArchivo(RUTARETIROS, listaPersonas, arbolPersona);
  end;  

  procedure FormatoCabecera(var cabecera: t_cabecera);
  var i,long: byte; diff, espacio: integer; hold:string; cab: t_dato_cabecera;
  begin
    for i := 1 to cabecera.tam do
      begin
        cab := cabecera.elem[i];
        long := Length(cab.titulo);
        hold := '';
        espacio := 0;
        if(long > 0) then
          begin
            if(long < cab.longitud) then
              begin
                diff := cab.longitud - long;
//                espacio := cab.longitud DIV long;
                espacio := diff DIV 2;
                if odd(diff) then begin
                 Inc(espacio);
                 Inc(cabecera.elem[i].longitud);
                end;
                while espacio > 0 do begin
                  hold := hold + ' ';// 　
                  Dec(espacio);
                end;

                cabecera.elem[i].titulo := hold + cab.titulo + hold;
              end
            else
              cabecera.elem[i].longitud := long;
          end;        
      end;
  end;

  procedure FormatoOpcionGrilla(var opciones: t_grilla_opciones);
  var i,long: byte; diff, espacio: integer; hold:string; opc: string;
  begin
    for i := 1 to opciones.titulos.tam do
      begin
        opc := opciones.titulos.elem[i];
        long := Length(opc);
        hold := '';
        espacio := 0;
        if(long > 0) then
          begin
            if(long < opciones.longitudMax) then
              begin
                diff := opciones.longitudMax - long;
//                espacio := opciones.longitudMax DIV long;
                espacio := diff DIV 2;

                if odd(diff) then begin
                 Inc(espacio);
                end;

                while espacio > 0 do begin
                  hold := hold + ' ';// 　
                  Dec(espacio);
                end;

                opciones.titulos.elem[i] := hold + opciones.titulos.elem[i] + hold;

                // eliminamos el ultimo espacio si es impar.
                if odd(diff) then
                  opciones.titulos.elem[i] := copy(opciones.titulos.elem[i], 0, Length(opciones.titulos.elem[i]) - 1);
              end
            else
              //
          end;        
      end;
  end;


  procedure AgregarOpcion(var titulosGrilla:t_grilla_listaTitulos; titulo: string);
  var pos: byte;
  begin
    if(titulosGrilla.tam < 100) then begin
      pos := titulosGrilla.tam + 1;
      titulosGrilla.elem[pos] := titulo;
      Inc(titulosGrilla.tam);
    end;
  end;

  Procedure FormatoOpciones(var opciones: t_grilla_opciones);
  var max,i: byte; 
  begin
    // Obtenemos el titulo con mas caracteres.
    max := 0;
    for i := 1 to opciones.titulos.tam do
      if(Length(opciones.titulos.elem[i]) > max) then max := Length(opciones.titulos.elem[i]);
    
    opciones.longitudMax := max;

    FormatoOpcionGrilla(opciones);
  end;

  procedure InicializarGrilla(var cabeceraPersona, cabeceraLibros: t_cabecera; var opPPALGrilla, opABMGrilla, opEstadisticasGrilla: t_grilla_opciones);
  var cab, cIsbn, cLegajo, cNombre, cRetiro, cDevolucion, cTipoR: t_dato_cabecera;
  begin

    // CABECERAS
      // PERSONA
      with cIsbn do begin titulo := 'ISBN'; longitud := 16; end;
      with cLegajo do begin titulo := 'Numero de legajo'; longitud := 12; end;
      with cNombre do begin titulo := 'Nombre del alumno'; longitud := 26; end;
      with cRetiro do begin titulo := 'Fecha de retiro'; longitud := 15; end;
      with cDevolucion do begin titulo := 'Fecha de devolucion'; longitud := 15; end;
      with cTipoR do begin titulo := 'Tipo de retiro'; longitud := 8; end;
      cabeceraPersona.elem[1] := cIsbn;    cabeceraPersona.elem[2] := cLegajo;      cabeceraPersona.elem[3] := cNombre;
      cabeceraPersona.elem[4] := cRetiro;  cabeceraPersona.elem[5] := cDevolucion;  cabeceraPersona.elem[6] := cTipoR;
      cabeceraPersona.tam := 6;

      // TODO: Cambiar de nombre a los registros...
      // LIBRO
      with cIsbn do begin titulo := 'ISBN'; longitud := 16; end;
      with cLegajo do begin titulo := 'Titulo'; longitud := 50; end;
      with cNombre do begin titulo := 'Autor/es'; longitud := 26; end;
      with cRetiro do begin titulo := 'Area'; longitud := 10; end;
      with cDevolucion do begin titulo := 'Cantidad'; longitud := 3; end;    
      cabeceraLibros.elem[1] := cIsbn;    cabeceraLibros.elem[2] := cLegajo;      cabeceraLibros.elem[3] := cNombre;
      cabeceraLibros.elem[4] := cRetiro;  cabeceraLibros.elem[5] := cDevolucion;
      cabeceraLibros.tam := 5;

      FormatoCabecera(cabeceraPersona);
      FormatoCabecera(cabeceraLibros);

    // OPCIONES      
      // MENU PRINCIPAL
      opPPALGrilla.titulos.tam := 0;
      opPPALGrilla.longitudMax := 0;
      AgregarOpcion(opPPALGrilla.titulos, 'Salir');
      AgregarOpcion(opPPALGrilla.titulos, 'ALTA/BAJA/MODIFICACION de libros');
      AgregarOpcion(opPPALGrilla.titulos, 'Retiro del libro');
      AgregarOpcion(opPPALGrilla.titulos, 'Devolucion de libro');
      AgregarOpcion(opPPALGrilla.titulos, 'Listado ordenado por fecha de retiro de los libros prestados');
      AgregarOpcion(opPPALGrilla.titulos, 'Listado de libros sin devolucion con ISBN,nombre y autor de los libros');
      AgregarOpcion(opPPALGrilla.titulos, 'Consulta por fecha');
      AgregarOpcion(opPPALGrilla.titulos, 'Estadisticas');
      FormatoOpciones(opPPALGrilla);

      // MENU ABM LIBROS
      opABMGrilla.titulos.tam := 0;
      opABMGrilla.longitudMax := 0;
      AgregarOpcion(opABMGrilla.titulos, 'Volver');
      AgregarOpcion(opABMGrilla.titulos, 'Agregar');
      AgregarOpcion(opABMGrilla.titulos, 'Baja');
      AgregarOpcion(opABMGrilla.titulos, 'Modificar');
      FormatoOpciones(opABMGrilla);

      // MENU ESTADISTICAS
      opEstadisticasGrilla.titulos.tam := 0;
      opEstadisticasGrilla.longitudMax := 0;
      AgregarOpcion(opEstadisticasGrilla.titulos, 'Volver');
      AgregarOpcion(opEstadisticasGrilla.titulos, 'Cantidad de libros consultados entre dos fechas');
      AgregarOpcion(opEstadisticasGrilla.titulos, 'Cantidad de libros sin devolucion en fecha');
      AgregarOpcion(opEstadisticasGrilla.titulos, 'Cual fue el area mas consultada');
      AgregarOpcion(opEstadisticasGrilla.titulos, 'Porcentaje de retiros en sala entre dos fechas');
      AgregarOpcion(opEstadisticasGrilla.titulos, 'Porcentaje de retiros domiciliarios entre dos fechas');
      FormatoOpciones(opEstadisticasGrilla);

  end;

  procedure MenuPPAL(var listaLibros: t_lista_libro; var listaPersonas: t_lista_persona; var arbolLibros: t_punt_arbol; var arbolPersona: t_punt_arbol; cabeceraPersonas, cabeceraLibros: t_cabecera; opPPALGrilla, opABMGrilla, opEstadisticasGrilla: t_grilla_opciones);
  var op, op1: word;
  begin

    { 
      ┌────────────────────────────────────────────────┐
      │                 MENU PRINCIPAL                 │
      └────────────────────────────────────────────────┘
    }   
    gotoxy(ScreenWidth DIV 2, 1);
    writeln('┌────────────────────────────────────────────────┐');
    gotoxy(ScreenWidth DIV 2, 2);
    writeln('│                                                │');
    gotoxy(ScreenWidth DIV 2, 3);
    write  ('│                 '); TextColor(118); Write('MENU PRINCIPAL'); TextColor(111);Writeln('                 │');
    gotoxy(ScreenWidth DIV 2, 4);
    writeln('│                                                │');
    gotoxy(ScreenWidth DIV 2, 5);
    writeln('└────────────────────────────────────────────────┘');
    repeat
      writeln;
      op := MostrarGrillaOpciones(opPPALGrilla);

      clrscr;
      case op of
      1:  begin
            repeat
               writeln;
               op1 := MostrarGrillaOpciones(opABMGrilla);


               case op1 of
                  1: begin clrscr; AgegarLibro(listaLibros, arbolLibros); end;
                  2: begin clrscr; EliminarLibro(listaLibros, arbolLibros); readln; end;
                  3: begin clrscr; ModificarLibro(listaLibros, arbolLibros); readln; end;
               end;
            until op1 = 0;
            clrscr;
         end;
      2: begin Retiro(listaPersonas, arbolPersona, arbolLibros, listaLibros); readln; clrscr; end;
      3: begin Devolucion(listaPersonas, arbolPersona); readln; clrscr; end;
      4: begin ListadoOrdenadoFechaRetiro(listaPersonas, cabeceraPersonas); readln; clrscr; end;
      5: begin ListarLibroSinDevolucion(listaPersonas, listaLibros, cabeceraLibros); readln; clrscr; end;
      6: begin ConsultaRetirosPorFecha(listaPersonas, cabeceraPersonas); readln; clrscr; end;
      7: begin
            repeat
               writeln;
               op1 := MostrarGrillaOpciones(opEstadisticasGrilla);
               clrscr;
               case op1 of
                  1: begin CantidadLibrosConsultadosDosFechas(listaPersonas, cabeceraPersonas); readln; clrscr; end;
                  2: begin CantidadLibrosSinDevolucionEnFecha(listaPersonas, cabeceraPersonas); {Ver} readln; clrscr; end;
                  3: begin AreaMasConsultada(listaPersonas, listaLibros); readln; clrscr; end;
                  4: begin PorcentajeRetiroSalaEntreDosFechas(listaPersonas); readln; clrscr; end;
                  5: begin PorcentajeRetiroDomicilioEntreDosFechas(listaPersonas); readln; clrscr; end;
               end;   
            until op1=0;
         end;
         418: begin clrscr; ListarLibros(listaLibros, cabeceraLibros); readln; clrscr; end;
       end;

   until op = 0;
  end;

end.

