unit Libro;

interface
  uses Arbol, Archivos, Tipos, Lista, crt, Utiles;

  // ABM LIBROS
    procedure AgegarLibro(var l:t_lista_libro; var arbolLibros:t_punt_arbol);
    procedure EliminarLibro(var l:t_lista_libro; var arbolLibros:t_punt_arbol);
    procedure ModificarLibro(var l:t_lista_libro; var arbolLibros:t_punt_arbol);

  // Consultas
    procedure ConsultarLibro(l: t_lista_libro);
    procedure ListarLibroSinDevolucion(retiros: t_lista_persona; libros: t_lista_libro; cabecera: t_cabecera);
    procedure ListarLibros(l: t_lista_libro; cabecera: t_cabecera);

implementation

  procedure CargarRegistroLibro(var libro:t_libro; esModificacion:boolean = false);
  var op: char; libroTemp: t_libro; mostrarDatos: boolean;
  begin
    op  := '1';
    mostrarDatos := false;
    if (not esModificacion) then libro.cantidad := 0
    else begin
      libroTemp := libro;
      mostrarDatos := true;
    end;

    Writeln(' A continuacion ingrese los siguientes datos ');
    
    while op <> 's' do
      begin
        with libroTemp do
          begin
            if(not esModificacion) then
            begin
              Write('  ISBN');
              if (mostrarDatos) then Write(' [', isbn, ']');
              Write(': ');
              READLN (isbn);
            end;

            Write('  Titulo');
              if(mostrarDatos)then Write(' [', titulo, ']');
              Write(': ');
            READLN (titulo);
            
            Write('  Autor');
              if(mostrarDatos)then Write(' [', autor, ']');
              Write(': ');
            READLN (autor);
            
            Write('  Area');
              if(mostrarDatos)then Write(' [', area, ']');
              Write(': ');
            READLN (area);

            Write('  Cantidad');
              if(mostrarDatos) then Write(' [', cantidad, ']');
              Write(': ');
            READLN (cantidad);
          end;

          libro.isbn := libroTemp.isbn;
          if Length(libroTemp.titulo) <> 0 then libro.titulo := libroTemp.titulo;
          if Length(libroTemp.autor) <> 0 then libro.autor := libroTemp.autor;
          if Length(libroTemp.area) <> 0 then libro.area := libroTemp.area;
          libro.cantidad := libroTemp.cantidad;

          Write(' El libro se cargara con los siguientes datos: ');
          WRITE('  [ISBN]: ', libro.ISBN, ' [Titulo]: ', libro.titulo,' [Autor]: ' , libro.autor,' [Area]: ' , libro.area,' [Cantidad]: ', libro.cantidad);
          Writeln(' Continuar? [s/n]: '); readln(op);
          
          mostrarDatos := true;
      end;
  end;

  Procedure MostrarLibro(libro: t_libro);
  begin
    with (libro) do
    begin
      WRITELN(' ISBN: ', ISBN);
      WRITELN(' Titulo: ', titulo);
      WRITELN(' Autor: ' , autor);
      WRITELN(' Area: ' , area);
      WRITELN(' Cantidad: ', cantidad);
    end;
  end;

  procedure AgegarLibro(var l:t_lista_libro; var arbolLibros:t_punt_arbol);
  var libro: t_libro; existe: boolean; nodo: t_punt_arbol; dato: t_dato_arbol;
  begin
    if(not ListaLLena(l)) then
      begin
        CargarRegistroLibro(libro);
        Buscar(l, libro.isbn, existe);

        if (existe) then
          begin
            Modificar(l, libro.isbn, libro);
            nodo := BuscarEnArbol(arbolLibros, libro.isbn);          
            EscribirEnArchivo(RUTALIBROS, libro, arbolLibros, nodo^.info.posArch);
          end
        else
          begin
            Agregar(l, libro); // Agregamos el nuevo libro a la lista.
            EscribirEnArchivo(RUTALIBROS, libro, arbolLibros);
          end;
      end
    else
      Writeln('   [ERROR] No se pueden agregar mas libros. Lista llena.');
  end;

  procedure EliminarLibro(var l:t_lista_libro; var arbolLibros:t_punt_arbol);
  var modificado, libro: t_libro; existe:boolean; nodo: t_punt_arbol; dato: t_dato_arbol; op:char;
  begin
    if(not ListaVacia(l)) then
      begin
        Writeln('Cual es el isbn del libro que desea eliminar?');
        readln(libro.isbn);

        Buscar(l, libro.isbn, existe);
        if(existe) then
          begin
            Recuperar(l, libro);
            MostrarLibro(libro);
            Writeln(' Dar de baja? [s/n]');
            readln(op);

            if (op = 's') OR (op = 'S') then
              begin
                modificado := libro;
                modificado.cantidad := 0;

                Modificar(l, libro.isbn, modificado);

                nodo := BuscarEnArbol(arbolLibros, libro.isbn);
                EscribirEnArchivo(RUTALIBROS, modificado, arbolLibros, nodo^.info.posArch);

                Writeln(' Libro dado de baja corretamente.');
              end;
          end
        else
          WriteLn('No se encontro un libro con el ISBN ingresado.')
      end
    else
        Writeln('Error! No hay libros disponibles.');
  end;

  procedure ModificarLibro(var l:t_lista_libro; var arbolLibros:t_punt_arbol);
  var libro: t_libro; existe: boolean; nodo: t_punt_arbol; dato: t_dato_arbol;
  begin
    Writeln('Cual es el isbn del libro que desea modificar?');
    readln(libro.isbn);
    Buscar(l, libro.isbn, existe);
    
    if (existe) then
    begin
      Recuperar(l, libro);
      CargarRegistroLibro(libro, true);
      Modificar(l, libro.isbn, libro);
      
      nodo := BuscarEnArbol(arbolLibros, libro.isbn);          
      EscribirEnArchivo(RUTALIBROS, libro, arbolLibros, nodo^.info.posArch);
      Writeln(' Libro modificado corretamente.');
    end
    else
      Writeln(' No se ha encontrado un libro con el ISBN ingresado.');
  end;

  procedure ConsultarLibro(l:t_lista_libro);
  var op: byte; isbn:QWord; existe:boolean; libro:t_libro;
  begin
    if(not ListaVacia(l)) then
      begin
        WriteLn('Ingresa el ISBN del libro a buscar');
        readln(isbn);
        Buscar(l, isbn, existe);

        if(existe) then
          begin
            Recuperar(l, libro);
            MostrarLibro(libro);
          end;      
      end;
  end;

  // ListarLibroSinDevolucion

  function Mostrado(mostrados: t_lista_isbn; isbn: QWord): boolean;
  var i: byte; exito: boolean;
  begin
    exito := false;
    while (i <= mostrados.tam) AND (NOT exito) do 
      begin
        if(mostrados.elem[i] = isbn) then exito := true;
        Inc(i);
      end;
    Mostrado := exito;
  end;
  
  procedure AgregarMostrado(var mostrados: t_lista_isbn; isbn: QWord);
  begin
    if (mostrados.tam < 100) then begin
      mostrados.elem[mostrados.tam + 1] := isbn;
    end;
    Inc(mostrados.tam);
  end;

  procedure ListarLibroSinDevolucion(retiros: t_lista_persona; libros: t_lista_libro; cabecera: t_cabecera);
  var libro: t_libro; persona: t_persona; grillaLista, existe: boolean; cabeceraMod: t_cabecera; mostrados: t_lista_isbn;
  begin
    if(not ListaVacia(retiros)) AND (not ListaVacia(libros)) then begin
      grillaLista := false;
      mostrados.tam := 0;

      cabeceraMod.elem[1] := cabecera.elem[1]; // ISBN
      cabeceraMod.elem[2] := cabecera.elem[3]; // AUTOR
      cabeceraMod.tam := 2;

      Primero(retiros);    
      while (not FinLista(retiros)) do begin
        Recuperar(retiros, persona);
        if (persona.fechaDevolucion.year = 0) then begin
          if (not grillaLista) then begin 
            MostrarGrilla(cabeceraMod); 
            grillaLista := true;  
          end;
          Buscar(libros, persona.isbn, existe);

          if (existe) AND (NOT Mostrado(mostrados, persona.isbn)) then begin
            Recuperar(libros, libro);
            AgregarMostrado(mostrados, libro.isbn);
            ListarLibroGrilla(libro, cabeceraMod, true);
          end;
        end;
        Siguiente(retiros);
      end; // While
      Writeln;
        Writeln('Ingrese una tecla para salir');
    end
    else
      Writeln('Lista vacia.');
  end;

  // END ListarLibroSinDevolucion

  procedure ListarLibros(l: t_lista_libro; cabecera: t_cabecera);
  var libro: t_libro; grillaLista: boolean;
  begin
    if(not ListaVacia(l)) then begin
      grillaLista:= false;
      Primero(l);
      while(not FinLista(l)) do begin
        Recuperar(l, libro);
        if (not grillaLista) then begin
          MostrarGrilla(cabecera);
          grillaLista := true;
        end;

        ListarLibroGrilla(libro, cabecera);
        Siguiente(l);
      end;
    end;

  end;
end.

