unit Tipos;

interface

type

  // En ingles por falta de ñ en Pascal.
  t_fecha = record
    year: word;
    month: word;
    day: word;
    hour: word;
  end;

  // TIPOS PARA LOS LIBROS.
    t_libro = record
      isbn: QWord;
      titulo: string[90];
      autor: string[70];
      area: string[60];
      cantidad: byte;
    end;

    t_punt_libro = ^t_nodo_libro;

    t_nodo_libro = record
      info: t_libro;
      sig: t_punt_libro;
    end;

    t_lista_libro = record
      act, cab: t_punt_libro;
      tam: word;
    end;

  // TIPOS PARA LAS PERSONAS
    t_persona = record
      isbn: QWord;
      legajo: dword;              //Numero legajo alumno
      nombre: string[70];              //Nombre del alumno
      fechaRetiro: t_fecha;
      fechaDevolucion: t_fecha;
      tipoRetiro: string[20];   //(en sala, domiciliaria)
    end;

    t_punt_persona = ^t_nodo_persona;

    t_nodo_persona = record
      info: t_persona;
      sig: t_punt_persona;
    end;

    t_lista_persona = record
      act, cab: t_punt_persona;
      tam: word;
    end;

    t_dato_cabecera = record
      titulo: string;
      longitud: byte;
    end;

    t_cabecera = record
      elem: Array[1..50] of t_dato_cabecera;
      tam: byte;
    end;

    t_lista_isbn = record 
      elem: Array[1..100] of QWord;
      tam: byte;
    end;
    
    t_dato_area = record
      titulo: string;
      contador: word;
    end;

    t_lista_areas = record 
      elem: Array[1..50] of t_dato_area;
      tam: byte;
    end;

    t_dato_masconsultada = record
      titulo: string;
      porcentaje: byte;
    end;

    t_grilla_listaTitulos = record
      elem: Array[1..20] of string;
      tam: byte;
    end;

    t_grilla_opciones = record
      titulos: t_grilla_listaTitulos;
      longitudMax: byte;
    end;

implementation

end.

