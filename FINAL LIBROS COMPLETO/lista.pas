unit Lista;

interface
  uses Tipos;

  procedure Primero(var l:t_lista_libro); 
  procedure Primero(var l:t_lista_persona);
  
  function ListaLLena(var l:t_lista_libro): boolean;
  function ListaLLena(var l:t_lista_persona): boolean;

  function ListaVacia(var l:t_lista_libro): boolean;
  function ListaVacia(var l:t_lista_persona): boolean;

  function FinLista(var l:t_lista_libro): boolean;
  function FinLista(var l:t_lista_persona): boolean;

  procedure Siguiente(var l:t_lista_libro);
  procedure Siguiente(var l:t_lista_persona);

  procedure Recuperar(l:t_lista_libro; var elemento: t_libro);
  procedure Recuperar(l:t_lista_persona; var elemento: t_persona);

  procedure Buscar(var l:t_lista_libro; isbn: QWord; var exito:boolean);
  procedure Buscar(var l:t_lista_persona; legajo:dword; isbn: QWord; var exito:boolean);

  procedure Agregar(var l:t_lista_libro; libro: t_libro);
  procedure Agregar(var l:t_lista_persona; persona: t_persona);

  procedure Modificar(var l:t_lista_libro; isbn:QWord; libroModificado: t_libro);
  procedure Modificar(var l:t_lista_persona; legajo, isbn:QWord; personaModificada: t_persona);

  procedure Eliminar(var l:t_lista_persona; legajo:dword; var persona:t_persona);
implementation

  // Primero
  procedure Primero(var l:t_lista_libro);
  begin
    l.act := l.cab;
  end;

  procedure Primero(var l:t_lista_persona); 
  begin
    l.act := l.cab;
  end;

  // Lista LLena
  function ListaLLena(var l:t_lista_libro): boolean;
  begin
    ListaLLena := GetHeapStatus.totalFree < (Sizeof(t_nodo_libro));
  end;
  
  function ListaLLena(var l:t_lista_persona): boolean;
  begin
    ListaLLena := GetHeapStatus.totalFree < (Sizeof(t_nodo_persona));
  end;

  // Lista Vacia
  function ListaVacia(var l:t_lista_libro): boolean;
  begin
    ListaVacia := l.tam = 0;
  end;

  function ListaVacia(var l:t_lista_persona): boolean;
  begin
    ListaVacia := l.tam = 0;
  end;

  // Fin de lista
  function FinLista(var l:t_lista_libro): boolean;
  begin
    FinLista := l.act = nil;
  end;

  function FinLista(var l:t_lista_persona): boolean;
  begin
    FinLista := l.act = nil;
  end;

  // Siguiente
  procedure Siguiente(var l:t_lista_libro);
  begin
    l.act := l.act^.sig;
  end;

  procedure Siguiente(var l:t_lista_persona);
  begin
    l.act := l.act^.sig;
  end;

  // Recuperar
  procedure Recuperar(l:t_lista_libro; var elemento: t_libro);
  begin
    elemento := l.act^.info;
  end;

  procedure Recuperar(l:t_lista_persona; var elemento: t_persona);
  begin
    elemento := l.act^.info;
  end;

  // Buscar
  procedure Buscar(var l:t_lista_libro; isbn: QWord; var exito:boolean);
  var libro: t_libro;
  begin
    Primero(l);
    exito := false;

    while(not FinLista(l)) AND (not exito) do
      begin
        Recuperar(l, libro);
        if(libro.isbn = isbn) then
          exito := true
        else
          Siguiente(l);
      end;
  end;

  procedure Buscar(var l:t_lista_persona; legajo:dword; isbn: QWord; var exito:boolean);
  var persona: t_persona;
  begin
    Primero(l);
    exito := false;

    while(not FinLista(l)) AND (not exito) do
      begin
        Recuperar(l, persona);
        if(persona.legajo = legajo) AND (persona.isbn = isbn) then
          exito := true
        else
          Siguiente(l);
      end;
  end;

  // Agregar
  procedure Agregar(var l:t_lista_libro; libro: t_libro);
  var ant, dir: t_punt_libro;
  begin
    new(dir);
    dir^.info := libro;
    if(l.cab = nil) OR (l.cab^.info.isbn > libro.isbn) then
      begin
        dir^.sig := l.cab;
        l.cab := dir;
      end
    else
      begin
        ant := l.cab;
        l.act := l.cab^.sig;
        while (l.act <> nil) AND (l.act^.info.isbn < libro.isbn) do
        begin
          ant := l.act;
          l.act := l.act^.sig;
        end;
        ant^.sig := dir;
        dir^.sig := l.act;
      end;
      
      l.tam := l.tam + 1;
  end;


  function EsFechaMasReciente(f1, f2: t_fecha; compararHora: boolean = false):boolean;
  {
    ** FUNCION ES PARTE DE UTILES.ps Copiada por razones de refencias cirulares.
    *
      Esta funcion compara dos fechas, solo devolviendo TRUE si la primera es mas reciente que la segunda fecha.
  }
  var verifica:boolean;
  begin
    verifica := true;
    
    if (f1.year > f2.year) then verifica := false;
    
    // Si verifica miramos el caso en que los años sean iguales y los meses diferentes.
    if verifica AND (f1.year = f2.year) AND (f1.month > f2.month) then verifica := false;
    
    if verifica AND (f1.month = f2.month) AND (f1.day > f2.day) then verifica := false;

    // if (verifica AND compararHora) AND ((f1.hour > co.hour) OR (co.hour > f2.hour)) then verifica := false;
    
    EsFechaMasReciente := verifica;
  end;  

  procedure Agregar(var l:t_lista_persona; persona: t_persona);
  var ant, dir: t_punt_persona;
  begin
    new(dir);
    dir^.info := persona;

    if(l.cab = nil) OR EsFechaMasReciente(persona.fechaRetiro, l.cab^.info.fechaRetiro, true) then
      begin
        dir^.sig := l.cab;
        l.cab := dir;
      end
    else
      begin
        ant := l.cab;
        l.act := l.cab^.sig;

        while (l.act <> nil) AND (not EsFechaMasReciente(persona.fechaRetiro, l.act^.info.fechaRetiro, true)) do
        begin
          ant := l.act;
          l.act := l.act^.sig;
        end;

        ant^.sig := dir;
        dir^.sig := l.act;
      end;

      l.tam := l.tam + 1;
  end;
   
  // Modificar
  
  procedure Modificar(var l:t_lista_libro; isbn:QWord; libroModificado: t_libro);
  var exito: boolean; libro: t_libro;
  begin
    Primero(l);
    Recuperar(l, libro);
    while (not FinLista(l)) AND (libro.isbn <> isbn) do
    begin
      Siguiente(l);
      Recuperar(l, libro);          
    end;

    if libro.isbn = isbn then
      l.act^.info := libroModificado;
  end;

  procedure Modificar(var l:t_lista_persona; legajo,isbn:QWord; personaModificada: t_persona);
  var exito: boolean; persona: t_persona;
  begin
    Primero(l);
    Recuperar(l, persona);
    while (not FinLista(l)) AND ((persona.legajo <> legajo) AND (persona.isbn <> isbn)) do
    begin
      Siguiente(l);
      Recuperar(l, persona);          
    end;

    if (persona.legajo = legajo) AND (persona.isbn = isbn) then
      l.act^.info := personaModificada;
  end;  

  // Eliminar
  procedure Eliminar(var l:t_lista_persona; legajo:dword; var persona:t_persona);
  var ant: t_punt_persona;
  begin
    if (l.cab^.info.legajo = legajo) then
      begin
        persona := l.cab^.info;
        l.act := l.cab;
        l.cab := l.cab^.sig;
      end
    else
      begin
        ant := l.cab;
        l.cab := l.cab^.sig;
        while (not FinLista(l)) AND (l.act^.info.legajo < legajo) do
          begin
            ant := l.act;
            l.act := l.act^.sig;
          end;
        
        persona := l.act^.info;
        ant^.sig := l.act^.sig;
      end;
    
    dispose(l.act);
    l.tam := l.tam - 1;
  end;
end.

