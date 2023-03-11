unit Archivos;

interface

  uses
    // Es necesario agregar el paquete requerido LazUtils en el proyecto para que
    // se pueda importar la unit fileutil.
    Arbol, Classes, SysUtils, fileutil, Tipos, Lista;

  const
    RUTALIBROS = 'C:\tmp\Libros.dat';
    RUTARETIROS = 'C:\tmp\Retiros.dat';

  type
    t_archivo_libro = file of t_libro;
    t_archivo_persona = file of t_persona;

  procedure EscribirEnArchivo(ruta:string; libro:t_libro; var arbolLibros: t_punt_arbol; posicion:int64 = -1);
  procedure EscribirEnArchivo(ruta:string; persona:t_persona; var arbolPersona: t_punt_arbol; posicion:int64 = -1);
  
  procedure LeerArchivo(ruta:string; var lista:t_lista_libro; var arbolLibros: t_punt_arbol);
  procedure LeerArchivo(ruta:string; var lista:t_lista_persona; var arbolPersona: t_punt_arbol);

implementation

  procedure EscribirEnArchivo(ruta:string; libro:t_libro; var arbolLibros: t_punt_arbol; posicion:int64 = -1);
  var archivo:t_archivo_libro; ultimaPos:int64; dato: t_dato_arbol;
  begin
    // A 'archivo' le pone el archivo que esta en ruta
    Assign(archivo, ruta);

    // Si no se ingreso una posicion...
    if(posicion < 0) then
      ultimaPos := FileSize(ruta) div Sizeof(t_libro) // calcular la ultima posicion del archivo.
    else
      ultimaPos := posicion;

    // Abre el archivo q esta en ruta
    Reset(archivo, Sizeof(t_libro));

    // Mueve el curso a ultimaPos
    Seek(archivo, ultimaPos);

    // Escribir en el archivo el libro dado
    Write(archivo, libro);

    // Agregar Nodo al Arbol
    if (posicion = -1) then 
      begin
        dato.id := libro.isbn; dato.posArch := ultimaPos;
        AgregarNodo(arbolLibros, dato);
      end;

    // Cerrar el archivo.
    Close(archivo);
  end;

  procedure EscribirEnArchivo(ruta:string; persona:t_persona; var arbolPersona: t_punt_arbol; posicion:int64 = -1);
  var archivo:t_archivo_persona; ultimaPos:int64; dato: t_dato_arbol;
  begin
    // A 'archivo' le pone el archivo que esta en ruta
    Assign(archivo, ruta);

    // Si no se ingreso una posicion...
    if(posicion < 0) then
      ultimaPos := FileSize(ruta) div Sizeof(t_persona) // calcular la ultima posicion del archivo.
    else
      ultimaPos := posicion;

    // Abre el archivo q esta en ruta
    Reset(archivo, Sizeof(t_persona));

    // Mueve el curso a ultimaPos
    Seek(archivo, ultimaPos);

    // Escribir en el archivo.
    Write(archivo, persona);

    // Agregar Nodo al Arbol
    if (posicion = -1) then 
      begin
        dato.id := persona.isbn + persona.legajo; dato.posArch := ultimaPos;
        AgregarNodo(arbolPersona, dato);
      end;

    // Cerrar el archivo.
    Close(archivo);
  end;

  procedure LeerArchivo(ruta:string; var lista:t_lista_libro; var arbolLibros: t_punt_arbol);
  var linea:t_libro; archivo:t_archivo_libro; dato: t_dato_arbol; contador: byte;
  begin
    contador := 0;

    // A archivo le pone el archivo que esta en ruta
    Assign(archivo, ruta);

    // 'Reset(x)' - significa que abrimos el archivo x y ponemos el cursor al inicio de este.
    Reset(archivo);

    while (not EOF(archivo)) do
    begin      
      // Leemos la linea donde se encuentra el puntero y la guardamos en linea
      Read(archivo, linea);

      Agregar(lista, linea); // Agregar a la lista
      
      // Agregar al arbol
      dato.id := linea.isbn;
      dato.posArch := contador;
      AgregarNodo(arbolLibros, dato);

      Inc(contador);
    end;

    Close(archivo);
  end;

  procedure LeerArchivo(ruta:string; var lista:t_lista_persona; var arbolPersona: t_punt_arbol);
  var linea:t_persona; archivo:t_archivo_persona;contador: byte;
  begin
    contador := 0;

    // A archivo le pone el archivo que esta en ruta
    Assign(archivo, ruta);

    // 'Reset(x)' - significa que abrimos el archivo x y ponemos el cursor al inicio de este.
    Reset(archivo);

    while (not EOF(archivo)) do
    begin
      // Leemos la linea donde se encuentra el puntero y la guardamos en linea
      Read(archivo, linea);

      Agregar(lista, linea);

      // Agregar al arbol
      dato.id := linea.isbn + linea.legajo;
      dato.posArch := contador;
      AgregarNodo(arbolPersona, dato);

      Inc(contador);
    end;

    Close(archivo);
  end;
end.



