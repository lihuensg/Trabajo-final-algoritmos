unit lista_libro;

interface
  uses tipos;

  procedure Primero(var l:t_lista_libro);
  procedure Primero(var l:t_lista_personas);

  procedure FinLista(var l:t_lista_libro);
  procedure FinLista(var l:t_lista_personas);

  procedure Siguiente(var l:t_lista_libro);
  procedure Siguiente(var l:t_lista_personas);

  procedure Recuperar(var l:t_lista_libro);
  procedure Recuperar(var l:t_lista_personas);

  procedure Buscar(var l:t_lista_libro);
  procedure Buscar(var l:t_lista_personas);
implementation

end.

