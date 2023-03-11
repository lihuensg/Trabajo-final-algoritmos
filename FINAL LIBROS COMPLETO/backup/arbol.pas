unit Arbol;
interface

  uses crt;
  type
    t_dato_arbol =  record
                id: word; // id = isbn
                posArch: cardinal;
              end;

    t_punt_arbol =  ^t_nodo;

    t_nodo =  record
                info: t_dato_arbol;
                sai, sad: t_punt_arbol;
              end;

  // Arbol
    procedure CrearArbol(var raiz: t_punt_arbol);
    procedure AgregarNodo(var raiz: t_punt_arbol; x: t_dato_arbol);
    function BuscarEnArbol(raiz: t_punt_arbol; buscado: dword): t_punt_arbol;

  // Control
    function ArbolVacio(raiz: t_punt_arbol): boolean;
    function ArbolLleno(): boolean;

  // Listado
    procedure Inorden(raiz: t_punt_arbol);
    function Preorden(raiz: t_punt_arbol; buscado: dword): t_punt_arbol;

implementation
  procedure CrearArbol(var raiz: t_punt_arbol);
  begin
    raiz := nil;
  end;

  procedure AgregarNodo(var raiz: t_punt_arbol; x: t_dato_arbol);
  begin
    // Si no hay raiz la creamos
    if (raiz = nil) then
      begin
        new(raiz);
        raiz^.info := x;
        raiz^.sai := nil;
        raiz^.sad := nil;
      end
    else if (raiz^.info.isbn > x.isbn) then
      AgregarNodo(raiz^.sai, x)
    else
      AgregarNodo(raiz^.sad, x)
  end;

  function ArbolVacio (raiz: t_punt_arbol): boolean;
  begin
    ArbolVacio:= raiz = nil;
  end;

  function ArbolLleno(): boolean;
  begin
    ArbolLleno := getheapstatus.totalfree < sizeof (t_nodo);
  end;

  function BuscarEnArbol(raiz: t_punt_arbol; buscado: dword): t_punt_arbol;
  var elem:t_punt_arbol;
  begin
    BuscarEnArbol := Preorden(raiz, buscado);
  end;

  function Preorden(raiz: t_punt_arbol; buscado: dword): t_punt_arbol;
  begin
    if (raiz = nil) then
      Preorden := nil
    else
    if (raiz^.info.isbn = buscado) then
      Preorden := raiz
    else if (raiz^.info.isbn > buscado) then
      Preorden := Preorden(raiz^.sai,buscado)
    else
      Preorden := Preorden(raiz^.sad,buscado);
  end;

  procedure Inorden(raiz:t_punt_arbol);
  begin
    if raiz <> nil then
    begin
      Inorden(raiz^.sai);
      //writeln(raiz^.info);
      Inorden(raiz^.sad);
    end;
  end;
end.

