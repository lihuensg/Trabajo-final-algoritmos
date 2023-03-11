program inicio;

uses Menu, Tipos, Arbol;

var listaLibros: t_lista_libro; listaPersonas: t_lista_persona; 
    arbolLibros: t_punt_arbol; arbolPersona: t_punt_arbol;
    cabeceraPersonas: t_cabecera; cabeceraLibros: t_cabecera; opPPALGrilla, opABMGrilla, opEstadisticasGrilla: t_grilla_opciones;

begin
  InicializarGrilla(cabeceraPersonas, cabeceraLibros, opPPALGrilla, opABMGrilla, opEstadisticasGrilla);
  InicializarListasArbol(listaLibros, listaPersonas, arbolLibros, arbolPersona);
  MenuPPAL(listaLibros, listaPersonas, arbolLibros, arbolPersona, cabeceraPersonas, cabeceraLibros, opPPALGrilla, opABMGrilla, opEstadisticasGrilla);
end.

