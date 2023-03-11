unit LibFile;

interface
	procedure CreaFile(var F: FILE; FName: String; RecLen: word);
	procedure AbreFile(var F: File; FName: String; RecLen : word);
	procedure CierraFile(var F: File);

	// +++ Registros +++
    function LeeReg(var F:File; Pos:Cardinal; var Buffer) : Boolean;
    procedure GuardarReg(var F:File; Pos:Cardinal; var Buffer);
implementation
	procedure CreaFile(var F: FILE; FName: String; RecLen: word);
	begin
		FillChar(F, SizeOf(F), 0);//Rellena la variable con carecteres vacios
		Assign(F, FName);//Asigna la ruta ej: 'articulos.dat'
		Rewrite(F,RecLen);
		Close(F);
	end;
	procedure AbreFile(var F: File; FName: String; RecLen : word);
	begin
		Assign(F,FName);//Para cargar el archivo que esta en la direccion que le pasamos a la variable F
		Reset(F,RecLen);//Poner el puntero al principio
	end;
	procedure CierraFile(var F: File);
	begin
		Close(F);
	end;

    // +++ Leer Registro de un Archivo +++
    function LeeReg(var F:File; pos:Cardinal; var Buffer) : Boolean; //Lee un registro del archivo F
    var
        BlocksRead:Word;
    begin
    	if(Pos < FileSize(F)) then
    	begin
            Seek(F, Pos);
            BlockRead(F, Buffer, 1, BlocksRead);
            LeeReg := True;
    	end
    	else
    		LeeReg := False;
    end;

    // +++ Guardar Registro en un Archivo +++
    procedure GuardarReg(var F:File; Pos:Cardinal; var Buffer); //Guarda un registro en archivo
    var
        BlocksWrite:Word;
    begin
        Seek(F, Pos);
        BlockWrite(F, Buffer, 1 , BlocksWrite);
    end;
end.