unit unit_archivos;

interface
  
uses
  // Es necesario agregar el paquete requerido LazUtils en el proyecto para que 
  // se pueda importar la unit fileutil.
  Classes, crt, SysUtils, fileutil ;
type
  t_dato=record
      usuario:string[150];
      respuesta:string[150];
      coincidencias:integer;
      end;
  t_archivo= file of t_dato;
 t_vector=array[1..100]of t_dato;
 t_lista = record
                 elem: t_vector;
                 tam: integer;
 end;

  procedure EscribirEnArchivo(ruta:string; posicion:int64 = -1);
  procedure comparar_palabra(t1:string;var lista:t_lista);
  procedure obtenerlamayorcoincidencia(lista:t_lista;var elem_max:t_dato);
  procedure Chatterbot(lista:t_lista);
  procedure leerArchivo(ruta:string;var vector:t_lista);
  procedure MostrarContenido(ruta:string);

implementation

  procedure EscribirEnArchivo(ruta:string; posicion:int64 = -1);
  var elem:t_dato; archivo:t_archivo; ultimaPos:int64;
  begin
    // A 'archivo' le pone el archivo que esta en ruta
    Assign(archivo, ruta);

    // Si no se ingreso una posicion...
    if(posicion < 0) then
      ultimaPos := FileSize(ruta) div Sizeof(t_dato) // calcular la ultima posicion del archivo.
    else
      ultimaPos := posicion;

    // Abre el archivo q esta en ruta
    Reset(archivo, Sizeof(t_dato));

    // Mueve el curso a ultimaPos
    Seek(archivo, ultimaPos);

    // Mostrar mensaje para que escriba texto
    Write('usuario:');
    Readln(elem.usuario);
    Write('respuesta:');
    Readln(elem.respuesta);
    if (elem.usuario[length(elem.usuario)]) = ' ' then
      elem.usuario:=elem.usuario+' ' ;
    // Escribir en el archivo el texto ingresado
    Write(archivo, elem);

    // Cerrar el archivo.
    Close(archivo);
  end;
  procedure agregar_vector(var vector:t_lista;elem:t_dato);
  begin
    vector.tam := vector.tam +1;
    elem.coincidencias := 0;
    vector.elem[vector.tam]:=elem;

  end;
        
  procedure comparar_palabra(t1:string; var lista:t_lista);
  var
    elem_max:t_dato;
    inicio,coin,pos,i,k,j:integer;
    t2,palabrasClave, palabra:string;
    respuesta:t_dato;
    tieneMasDeUnaPalabra,tieneMasDeUnaPalabra2: boolean;
    letra: char;
  begin
      tieneMasDeUnaPalabra := false;
      tieneMasDeUnaPalabra2 := false;
      { $$ esto  $4}

      // SI NO TIENE UN ESPACIO AL FINAL SE LO AGREGAMOS, ASI DETECTA LA ULTIMA PALABRA.
      if(t1[Length(t1)] <> ' ') then
         t1 := t1 + ' ';

      { $ aca $ }

    // RECORREMOS TODOS LOS ITEMS DE LA LISTA DE P/R
    for i:= 1 to lista.tam  do begin
      inicio:=1;
      pos:=1;
      respuesta := lista.elem[i];
      palabrasClave := respuesta.usuario;
      palabrasClave := lowerCase(palabrasClave);
      palabra := '';

{ $$    $$ $ $$$ $ $  CAMBIE ESTO $ $ $$  $$  $}

      for j := 1 to length(palabrasClave) do begin
        if (palabrasClave[j] = ' ') then tieneMasDeUnaPalabra2 := true;
      end;

      // SI NO TIENE UN ESPACIO AL FINAL SE LO AGREGAMOS, ASI DETECTA LA ULTIMA PALABRA.
      if(palabrasClave[Length(palabrasClave)] <> ' ') then
         palabrasClave := palabrasClave + ' ';

      // RECORREMOS CADA CARACTER DE T1
      for k := 1 to length(palabrasClave) do begin
        letra := palabrasClave[k];

        // COMPARAMOS SI ES DISTINTO AL DELIMITADOR (espacio)
        if (letra <> ' ') then
            // SI ES DISTINTO, GUARDAMOS LA "PALABRA" (CARACTER X CARACTER HASTA LLEGAR AL PROX DELIM.)
            palabra := palabra + letra
        else begin
          // SI LA PALABRA ARMADA HASTA LLEGAR AL DELIMITADOR NO ES CADENA VACIA.
          if (Length(palabra) <> 0) then
              begin
                // SI NO TIENE OTRA PALABRA -> QUITAMOS EL ESPACIO Q AGREGAMOS ANTES
                if (not tieneMasDeUnaPalabra2) then t1 := copy(t1, 1, Length(t1)-1);

                // SI LA PALABRA ARMADA ES IGUAL A LA DADA, ES UNA COINCIDENCIA.
                if(palabra = t1) then Inc(lista.elem[i].coincidencias);
              end;

          palabra := '';
        end;
      end;

{ $$ $  $ HAST ACA $ $ $ }

    end;
  end;

  procedure obtenerlamayorcoincidencia(lista:t_lista; var elem_max:t_dato);
  var
  max,i:integer;
  begin
    max:=0;
    for i:= 1 to lista.tam do begin
      if lista.elem[i].coincidencias>max then begin
        max := lista.elem[i].coincidencias;
        elem_max :=lista.elem[i];
      end;
    end;
  end;

  procedure reiniciarLista(var lista:t_lista);
  var i:integer;
  begin
    for i := 1 to lista.tam do
      lista.elem[i].coincidencias := 0;
  end;
      
  procedure Chatterbot(lista:t_lista);
  var
    elem_max:t_dato;
    usuario, palabra:string;
    letra: char;
    inicio,coin,pos,k:integer; t1:string;

  begin
    usuario := ' ';
    Writeln('Hola! Bienvenid@ al Chatterbot ¿Con qué te puedo ayudar?');
    
    while usuario <> 'Salir' do begin
      writeln;
      
      writeln('ingrese ["Salir" para abandonar]: ');
      write('- ');
      readln(usuario);
      usuario := lowerCase(usuario); // Convertimos usuario a minusculas.
      
      if usuario <> 'salir' then begin
        inicio:=0;
        coin:=0;
        pos:=1;
        palabra := '';

{ $$    $$ $ $$$ $ $  CAMBIE ESTO $ $ $$  $$  $}

      // SI NO TIENE UN ESPACIO AL FINAL SE LO AGREGAMOS, ASI DETECTA LA ULTIMA PALABRA.
      if(usuario[Length(usuario)] <> ' ') then
         usuario := usuario + ' ';

      // RECORREMOS CADA CARACTER DE T1
      for k := 1 to length(usuario) do begin
        letra := usuario[k];

        // COMPARAMOS SI ES DISTINTO AL DELIMITADOR
        if (letra <> ' ') then
            // SI ES DISTINTO, GUARDAMOS LA "PALABRA" (CARACTER X CARACTER HASTA LLEGAR AL PROX DELIM.)
            palabra := palabra + letra
        else begin
          // SI LA PALABRA ARMADA HASTA LLEGAR AL DELIMITADOR NO ES CADENA VACIA.
          if (Length(palabra) <> 0) then
              begin
                comparar_palabra(palabra, lista);
              end;

          palabra := '';
        end;
      end;

{ $$ $  $ HAST ACA $ $ $ }

        obtenerlamayorcoincidencia(lista,elem_max);
        
        if(elem_max.coincidencias = 0) then
          Writeln('No se pudo encontrar una respuesta.')
        else
          writeln('- ', elem_max.respuesta);

        reiniciarLista(lista);
      end;
    end;
  end;


  procedure leerArchivo(ruta:string;var vector:t_lista);
  var linea:t_dato; archivo:t_archivo;
  begin
    // A archivo le pone el archivo que esta en ruta
    Assign(archivo, ruta);
    
    // 'Reset(x)' - significa que abrimos el archivo x y ponemos el cursor al inicio de este.
    Reset(archivo); 
    
    while (not EOF(archivo)) do
    begin

      // Leemos la linea donde se encuentra el puntero y la guardamos en linea
      Read(archivo, linea);
      agregar_vector(vector,linea);

    end;
    Close(archivo);
  end;

  procedure MostrarContenido(ruta:string);
  var linea:t_dato; archivo:t_archivo;
  begin
     // A archivo le pone el archivo que esta en ruta
    Assign(archivo, ruta);

    // 'Reset(x)' - significa que abrimos el archivo x y ponemos el cursor al inicio de este.
    Reset(archivo);

    while (not EOF(archivo)) do
    begin
      // Leemos la linea donde se encuentra el puntero y la guardamos en linea
      Read(archivo, linea);
      Writeln('USUARIO: ', linea.usuario, ' ---- RTA.: ', linea.respuesta);
    end;
    Close(archivo);
  end;

end.

