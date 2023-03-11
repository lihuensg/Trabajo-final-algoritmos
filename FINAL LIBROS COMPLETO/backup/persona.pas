unit Persona;

interface
  uses Archivos, Arbol, Tipos, Lista, Utiles;

    procedure Retiro(var l:t_lista_persona; var arbolRetiros: t_punt_arbol; arbolLibros: t_punt_arbol; var libros: t_lista_libro);
    procedure Devolucion(var l:t_lista_persona; var arbolRetiros: t_punt_arbol);
    procedure ConsultarPorFecha(var l:t_lista_persona);
    procedure ListadoOrdenadoFechaRetiro(var l:t_lista_persona; cabecera: t_cabecera);
    procedure ConsultaRetirosPorFecha(lp: t_lista_persona; cabecera: t_cabecera);
    procedure CantidadLibrosConsultadosDosFechas(lp: t_lista_persona; cabecera: t_cabecera);
    procedure CantidadLibrosSinDevolucionEnFecha(lp: t_lista_persona; cabecera: t_cabecera);
    procedure AreaMasConsultada(lp: t_lista_persona; libros: t_lista_libro);
    procedure PorcentajeRetiroSalaEntreDosFechas(lp: t_lista_persona);
    procedure PorcentajeRetiroDomicilioEntreDosFechas(lp: t_lista_persona);
implementation

  procedure CargarRegistroPersona(var persona:t_persona; p_isbn:QWord = 0; esModificacion:boolean = false);
  var op: char; op2: char; fechaCero: t_fecha;
  begin
    op  := 'n';
    if (not esModificacion) then 
      begin
        persona.legajo := 0;
        persona.nombre := '';
        persona.tipoRetiro := '';
        
        with fechaCero do 
          begin
            year := 0; month := 0; day := 0; hour := 0;
          end;

        persona.fechaRetiro := fechaCero;
        persona.fechaDevolucion := fechaCero;
      end;

    Writeln(' A continuacion ingrese los siguientes datos ');
    while op = 'n' do
      begin
        with persona do
          begin
            if (not esModificacion) AND (p_isbn = 0) then
            begin
              Write('ISBN: ');
              READLN (isbn);
            end
            else
                if p_isbn <> 0 then isbn := p_isbn;

            Write('Numero de legajo');
            if legajo <> 0 then Write(' [', legajo, ']');
            Write(': ');
            ReadLn(legajo);

            Write('Nombre del alumno');
            if Length(nombre) <> 0 then Write(' [', nombre, ']');
            Write(': ');
            ReadLn(nombre);

            Write('Fecha de retiro');
            if (fechaRetiro.year <> 0) then begin
              Write(' ['); MostrarFecha(fechaRetiro); Write(']');
            end;
            Write(' (Utilizar fecha del Sistema? [s/n]): ');

            ReadLn(op2);
            if op2 = 's' then
              ObtenerFechaActual(fechaRetiro)
            else
              LeerFecha(fechaRetiro);

            Write('Fecha de devolucion'); 
            if (fechaDevolucion.year <> 0) then begin
              Write(' ['); MostrarFecha(fechaDevolucion); Write(']');
            end;

            Write(' (Ingrese 0 si no ha devuelto): ');
            LeerFecha(fechaDevolucion);

            Write('Tipo de retiro');
            if Length(tipoRetiro) <> 0 then Write(' [', tipoRetiro, ']');
            Write(': ');
            ReadLn(tipoRetiro);

          end;

          Write('Se cargara con los siguientes datos: ');
          WRITE('[ISBN]: ', persona.ISBN, ' [Legajo]: ', persona.legajo,' [Nombre]: ', persona.nombre,' [F. Retiro]: ');
          MostrarFecha(persona.fechaRetiro); Write(' [F. Dev.]: '); MostrarFecha(persona.fechaDevolucion);
          Writeln(' Continuar? [s/n]: '); readln(op);
      end;
  end;

  Procedure MostrarPersona(persona: t_persona);
  begin
    with (persona) do
    begin
      Write('ISBN: ', isbn);
      Write('Numero de legajo: ', legajo);
      Write('Nombre del alumno: ', nombre);
      Write('Fecha de retiro: '); MostrarFecha(fechaRetiro);
      Write('Fecha de devolucion: '); MostrarFecha(fechaDevolucion);
      Write('Tipo de retiro: ', tipoRetiro);
    end;
  end;
  
  function HayLibrosDisponibles(l: t_lista_libro; isbn: QWord; var libro:t_libro): boolean;
  var exito: boolean;
  begin
    Buscar(l, isbn, exito);
    if exito then
      begin
        Recuperar(l, libro);
        if(libro.cantidad = 0) then exito := false;
      end;
    HayLibrosDisponibles := exito;
  end;

  procedure Retiro(var l:t_lista_persona; var arbolRetiros: t_punt_arbol; arbolLibros: t_punt_arbol; var libros: t_lista_libro);
  var continuar:boolean; persona: t_persona; isbn: QWord; libro: t_libro; nodo: t_punt_arbol;
  begin
    if(not ListaLLena(l)) then
      begin
        Write('Ingrese el ISBN del libro a retirar: ');
        Readln(isbn);
        continuar := HayLibrosDisponibles(libros, isbn, libro);

        if continuar then
          begin
            CargarRegistroPersona(persona, isbn);

            // Agregar a la lista.
            Agregar(l, persona);

            // Agregar al Archivo y al Arbol.
            EscribirEnArchivo(RUTARETIROS, persona, arbolRetiros);
            
            // Quitar 1 de la cantidad de libros disponibles
            Dec(libro.cantidad);
            Modificar(libros, libro.isbn, libro); // en lista

            // en Arbol y Archivo
            nodo := BuscarEnArbol(arbolLibros, libro.isbn);
            EscribirEnArchivo(RUTALIBROS, libro, arbolLibros, nodo^.info.posArch);

            Writeln('Retiro registrado en el sistema correctamente.');
          end
        else
          Writeln(' No hay  mas libros con el ISBN ', isbn,' disponibles');
    end
    else
      Writeln('   [ERROR] Lista llena.');
  end;

  procedure Devolucion(var l:t_lista_persona; var arbolRetiros: t_punt_arbol);
  var persona: t_persona; isbn:QWord; legajo: dword; fechaDevolucion: t_fecha; existe:boolean; nodo: t_punt_arbol; dato: t_dato_arbol;
  begin
    if (not ListaVacia(l)) then
      begin
        Writeln('Cual es el legajo?');
        ReadLn(legajo);

        Writeln('Cual es el isb del libro que devuelve?');
        Readln(isbn);

        Buscar(l, legajo, isbn, existe);

        if existe then
          begin
            Recuperar(l, persona);
            
            ObtenerFechaActual(fechaDevolucion);

            persona.fechaDevolucion := fechaDevolucion;
            
            // Modificar en lista
            Modificar(l, legajo, isbn, persona); 
            
            // Modificar en Arbol y en Archivo.
            nodo := BuscarEnArbol(arbolRetiros, persona.isbn + persona.legajo);
            EscribirEnArchivo(RUTARETIROS, persona, arbolRetiros, nodo^.info.posArch);

            Writeln('Devolucion registrada en el sistema correctamente.');
          end
        else
          Writeln('No se encontro un libro con isbn ',isbn, ' que haya sido retirado por ', legajo);
      end
    else
      Writeln('Lista de retiros y devoluciones vacia.');
  end;

  procedure ConsultarPorFecha(var l:t_lista_persona);
  var op:byte;
  begin
    if (not ListaVacia(l)) then
      begin
        Writeln('Desea consultar por:');
        Writeln(Utf8ToAnsi(' 1. Año'));
        Writeln(Utf8ToAnsi(' 1. Año y Mes'));
        Writeln(Utf8ToAnsi(' 1. Año, Mes y Día'));
      end
    else
      Writeln('Lista vacia.');
  end;

  procedure ListadoOrdenadoFechaRetiro(var l: t_lista_persona; cabecera: t_cabecera);
  var persona: t_persona;
  begin    
    if (not ListaVacia(l)) then begin
        MostrarGrilla(cabecera);
        ListarPersonasGrilla(l, cabecera);
    end
    else 
      Writeln('Lista Vacia.');

  end;
  
  procedure ConsultaRetirosPorFecha(lp: t_lista_persona; cabecera: t_cabecera);
  var fecha: t_fecha; persona: t_persona; grillaLista: boolean;
  begin
    if(not ListaVacia(lp)) then begin
      grillaLista := false;

      ConsultarFecha(fecha);

      Primero(lp);    
      while (not FinLista(lp)) do begin
        Recuperar(lp, persona);
        if (CompararFechas(fecha, persona.fechaRetiro)) then begin
          if (not grillaLista) then begin 
            MostrarGrilla(cabecera); 
            grillaLista := true;  
          end;

          ListarPersonaGrilla(persona, cabecera);
        end;
        Siguiente(lp);
      end; // While
    end
    else
      Writeln('Lista vacia.');
  end;

  procedure CantidadLibrosConsultadosDosFechas(lp: t_lista_persona; cabecera: t_cabecera);
  var contador: word; grillaLista: boolean; fecha1, fecha2: t_fecha; persona: t_persona;
  begin
    if(not ListaVacia(lp)) then begin
      grillaLista := false;
      contador := 0;

      ConsultarFecha(fecha1);
      ConsultarFecha(fecha2);

      // verificamos que las fechas sean validas.
      if (EsFechaMasReciente(fecha1, fecha2)) then begin
        Primero(lp);
        while (not FinLista(lp)) do begin
          Recuperar(lp, persona);
          if (EstaEntreFechas(fecha1, fecha2, persona.fechaRetiro)) then begin
            if (not grillaLista) then begin 
              MostrarGrilla(cabecera); 
              grillaLista := true;  
            end;

            ListarPersonaGrilla(persona, cabecera);
            Inc(contador);
          end;
          Siguiente(lp);
        end; // While

        Writeln;
        Writeln('Se han consultado ', contador, ' libro/s entre las fechas.');
      end
      else
        Writeln('Las fechas ingresadas son invalidas. Intentelo nuevamente.')
    end
    else
      Writeln('Lista vacia.');
  end;

  {
    Muestra la cantidad de libros se han devuelto antes de X fecha. Es decir que no han devuelto hasta esa fecha.
  }
  procedure CantidadLibrosSinDevolucionEnFecha(lp: t_lista_persona; cabecera: t_cabecera);
  var contador: word; grillaLista: boolean; fecha: t_fecha; persona: t_persona;
  begin
    if(not ListaVacia(lp)) then begin
      grillaLista := false;
      contador := 0;

      ConsultarFecha(fecha);

      Primero(lp);
      while (not FinLista(lp)) do begin
        Recuperar(lp, persona);
        if (not persona.fechaDevolucion.year = 0) AND (EsFechaMasReciente(persona.fechaDevolucion, fecha)) then begin
          if (not grillaLista) then begin 
            MostrarGrilla(cabecera); 
            grillaLista := true;  
          end;

          ListarPersonaGrilla(persona, cabecera);
          Inc(contador);
        end;
        Siguiente(lp);
      end; // While

      Writeln;
      Writeln('No se han devuelto ', contador, ' libros en la fecha.');
    end
    else
      Writeln('Lista vacia.');
  end;

  // AREA MAS CONSULTADA

  function ObtenerAreaMasConsultada(var listaAreas: t_lista_areas): t_dato_masconsultada;
  var i: byte; masConsultada: string; max, total: word; res: t_dato_masconsultada; 
  begin
    i := 0;
    max := 0;
    total := 0;
    masConsultada := listaAreas.elem[1].titulo;
    while i <= listaAreas.tam do begin
      if(listaAreas.elem[i].contador > max) then begin
        max := listaAreas.elem[i].contador;
        masConsultada := listaAreas.elem[i].titulo;
      end;
      total := total + listaAreas.elem[i].contador;
      Inc(i);
    end;
    res.titulo := masConsultada;
    res.porcentaje := max * 100 DIV total;
    ObtenerAreaMasConsultada := res;
  end;
  
  procedure AgregarArea(var listaAreas: t_lista_areas; titulo: string);
  var i,pos: byte; exito: boolean;
  begin
    i := 1;
    exito := false;
    while (i <= listaAreas.tam) AND (not exito) do begin
      if (listaAreas.elem[i].titulo = titulo) then begin
        exito := true;
        Inc(listaAreas.elem[i].contador);
      end;
      Inc(i);
    end;

    if (not exito) then begin
      pos := listaAreas.tam + 1;

      if (listaAreas.tam < 50) then begin
        listaAreas.elem[pos].titulo := titulo;
        listaAreas.elem[pos].contador := 1;
      end;
      
      Inc(listaAreas.tam);
    end;
  end;

  procedure AreaMasConsultada(lp: t_lista_persona; libros: t_lista_libro);
  var persona: t_persona; listaAreas: t_lista_areas; res: t_dato_masconsultada; libro: t_libro; exito: boolean;
  begin
    if(not ListaVacia(lp)) then begin
      listaAreas.tam := 0;
      Primero(lp);
      while (not FinLista(lp)) do begin
        Recuperar(lp, persona);
        Buscar(libros, persona.isbn, exito);
        if exito then begin
          Recuperar(libros, libro);
          AgregarArea(listaAreas, libro.area);      
        end;
        Siguiente(lp);
      end; // While

      res := ObtenerAreaMasConsultada(listaAreas);

      Writeln('El area mas consultada fue ', res.titulo, ' con un ', res.porcentaje, '% de las consultas.');
    end
    else
      Writeln('Lista vacia.');
  end;

  procedure PorcentajeRetiroSalaEntreDosFechas(lp: t_lista_persona);
  var contadorSala, contadorTotal: word; persona: t_persona; porcentaje: byte; fecha1,fecha2: t_fecha;
  begin
    if(not ListaVacia(lp)) then begin
      contadorTotal := 0;
      contadorSala := 0;
      
      ConsultarFecha(fecha1);
      ConsultarFecha(fecha2);
      
       // verificamos que las fechas sean validas.
      if (EsFechaMasReciente(fecha1, fecha2)) then begin
        Primero(lp);
        while (not FinLista(lp)) do begin
          Recuperar(lp, persona);
          if EstaEntreFechas(fecha1, fecha2, persona.fechaRetiro) AND ((persona.tipoRetiro = 'sala') or (persona.tipoRetiro = 'en sala')) then Inc(contadorSala);
          Inc(contadorTotal);
          Siguiente(lp);
        end; // While

        porcentaje := contadorSala * 100 DIV contadorTotal;
        Writeln;
        Write('El porcentaje de retiros en sala entre '); MostrarFecha(fecha1, false, false); Write(' y '); MostrarFecha(fecha2, false, false);
        Write(' es ', porcentaje, '%.');
      end
      else
        Write('Fechas invalidas.')
    end
    else
      Writeln('Lista vacia.');
  end;

  procedure PorcentajeRetiroDomicilioEntreDosFechas(lp: t_lista_persona);
  var contadorDomicilio, contadorTotal: word; persona: t_persona; porcentaje: byte; fecha1,fecha2: t_fecha;
  begin
    if(not ListaVacia(lp)) then begin
      contadorTotal := 0;
      contadorDomicilio := 0;
      
      ConsultarFecha(fecha1);
      ConsultarFecha(fecha2);
      
       // verificamos que las fechas sean validas.
      if (EsFechaMasReciente(fecha1, fecha2)) then begin
        Primero(lp);
        while (not FinLista(lp)) do begin
          Recuperar(lp, persona);
          if EstaEntreFechas(fecha1, fecha2, persona.fechaRetiro) AND ((persona.tipoRetiro = 'domicilio') or (persona.tipoRetiro = 'domiciliario')) then Inc(contadorDomicilio);
          Inc(contadorTotal);
          Siguiente(lp);
        end; // While

        porcentaje := contadorDomicilio * 100 DIV contadorTotal;
        Writeln;
        Write('El porcentaje de retiros en Domicilio entre '); MostrarFecha(fecha1, false, false); Write(' y '); MostrarFecha(fecha2, false, false);
        Write(' es ', porcentaje, '%.');
      end
      else
        Write('Fechas invalidas.')
    end
    else
      Writeln('Lista vacia.');
  end;
end.
