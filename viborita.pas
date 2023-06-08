program vibo2;
Uses Crt,sysutils,dateutils;
Const 
    min = 1;
    maxC = 80;
    maxF = 23;
    comidas = 10; //la cantidad de comida que hay en pantalla.
	color_titulo = 0;
    color_suelo = 6;
    color_comida = 4;
    color_cuerpo = 2;
    color_borde = 3;
	sim_titulo = '@';
    sim_cuerpo = '+';
    cabeza = 'O';
    borde_lateral = '#';
    borde_horiz = '#';
    sim_comida = '*';
    color_letras = 15;
    {
    Black        =   0;
	Blue         =   1;
	Green        =   2;
	Cyan         =   3;
	Red          =   4;
	Magenta      =   5;
	Brown        =   6;
	LightGray    =   7;
	DarkGray     =   8;
	LightBlue    =   9;
	LightGreen   =  10;
	LightCyan    =  11;
	LightRed     =  12;
	LightMagenta =  13;
	Yellow       =  14;
	White        =  15;
	Blink        = 128;
    }

Type 
	vibora = ^cuerpo;
	cuerpo = Record
		x: integer;
		y: integer;
		sig: vibora;
	End;

	filas = array [min..maxF] Of char; // altura
	tablero = array [min..maxC] Of filas; // ancho
	// primero columnas (eje X) y luego filas (eje Y) --> t[x][y]

	regPuntos = Record
		nombre: string[20];
		puntos:integer;
		sig:integer; // enlace en archivo para orden logico de ganadores
	end;
	archivo_puntaje = file of regPuntos;

//VARIABLE GLOBAL DEL PUNTAJE.
var puntaje:integer = 0;
	dificultad:integer = 1; // 1 facil (no muere por chocar con las paredes), 0 normal
	millisEntreFrames:integer = 100; // aumentar para ir mas lento, disminuir para ir mas rapido

//segunda version de la sobrecarga, que ahora le agrega un offset a x, 
//asi escribe en centrado segun la posicion especificada.
procedure writexyCent(x,y:integer;s:string);
begin
	x:= x - (Length(s) div 2);
	gotoxy(x,y);
	write(s);
end;

procedure writexy2(x,y:integer;s:string);
var
	st:string;
	cAct:char;
	i:integer = 1;
begin
	while (i<=Length(s)) do begin
		cAct:= s[i];
		SetLength(st,0);
		case cAct of
			sim_titulo: begin
				TextBackground(color_titulo);
				TextColor(color_titulo);
			end;
			' ': begin
				TextBackground(color_suelo);
				TextColor(color_letras);
			end;
			borde_horiz: begin
				TextBackground(color_borde); // comentar esta linea para ver el simbolo
                TextColor(color_borde)
			end;
			sim_comida: begin
				TextBackground(color_comida); // comentar esta linea para ver el simbolo
                TextColor(color_comida)
			end;
		end;
		while(i<=Length(s))AND(s[i]=cAct)do begin
			st:=st+s[i];
			i:=i+1;
		end;
		gotoxy(x,y);
		write(st);
		//readKey;
		x:=x+Length(st);
	end;
	TextBackground(color_suelo);
	TextColor(color_letras);
end;

procedure writexy(x,y:integer;s:string);
var i:integer;
begin
    TextBackground(color_suelo);
	TextColor(color_letras);
    gotoxy(x,y);
    if((LastDelimiter(sim_titulo,s)+LastDelimiter(sim_cuerpo,s)+LastDelimiter(cabeza,s)+LastDelimiter(sim_comida,s)+LastDelimiter(borde_horiz,s)+LastDelimiter(borde_lateral,s))<=0)then
        write(s)
    else begin
        for i := 0 to Length(s)-1 do begin
            // establecemos color correspondiente al simbolo
            if(s[i+1]=sim_comida)then begin
                TextBackground(color_comida); // comentar esta linea para ver el simbolo
                TextColor(color_comida)
            end else if(s[i+1]=sim_cuerpo) or (s[i+1]=cabeza)then begin
                TextBackground(color_cuerpo); // comentar esta linea para ver el simbolo
                TextColor(color_cuerpo)
            end else if(s[i+1]=borde_lateral) or (s[i+1]=borde_horiz)then begin
                TextBackground(color_borde); // comentar esta linea para ver el simbolo
                TextColor(color_borde)
            end else if(s[i+1]=sim_titulo) then begin
				TextBackground(color_titulo);
				TextColor(color_titulo);
			end else begin
                TextBackground(color_suelo);
                TextColor(color_letras);
            end;
            //gotoxy(x+i,y);
            write(s[i+1]);
        end;
    end;
	TextBackground(color_suelo);
	TextColor(color_letras);
end;

procedure writeTitulo(x,y:integer;s:string);
var i:integer;
begin
	gotoxy(x,y);
	for i:=0 to Length(s) do begin
		case s[i] of
			'A': begin 
				writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				writexy2(WhereX-7,WhereY+1,'@@@ @@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'B': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@    @@');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				gotoxy(WhereX,WhereY-7);

			end;
			'C': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@  @@@@');
				writexy2(WhereX-7,WhereY+1,'@  @@@@');
				writexy2(WhereX-7,WhereY+1,'@  @@@@');
				writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'D': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@@@ '); 
			   	writexy2(WhereX-7,WhereY+1,'@    @@');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@    @@');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				writexy2(WhereX-7,WhereY+1,'@@@@@@ ');
				gotoxy(WhereX,WhereY-7);
			end;
			'E': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@  @@@@');
				writexy2(WhereX-7,WhereY+1,'@    @ ');
				writexy2(WhereX-7,WhereY+1,'@  @@@@');
				writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'F': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@  @@@@');
				writexy2(WhereX-7,WhereY+1,'@    @@');
				writexy2(WhereX-7,WhereY+1,'@  @@@ ');
				writexy2(WhereX-7,WhereY+1,'@  @@@ ');
				writexy2(WhereX-7,WhereY+1,'@@@@@  ');
				writexy2(WhereX-7,WhereY+1,'@@@@@  ');
				gotoxy(WhereX,WhereY-7);
			end;
			'G': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@  @@@@');
				writexy2(WhereX-7,WhereY+1,'@  @@@@');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'H': begin
				writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				writexy2(WhereX-7,WhereY+1,'@@@ @@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'I': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@'); 
			   	writexy2(WhereX-4,WhereY+1,'@  @');
				writexy2(WhereX-4,WhereY+1,'@  @');
				writexy2(WhereX-4,WhereY+1,'@  @');
				writexy2(WhereX-4,WhereY+1,'@  @');
				writexy2(WhereX-4,WhereY+1,'@  @');
				writexy2(WhereX-4,WhereY+1,'@@@@');
				writexy2(WhereX-4,WhereY+1,'@@@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'J': begin
				if(WhereX<>x) or (s[i-1]=' ')then begin
					writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
					writexy2(WhereX-7,WhereY+1,'@@@@  @');
					writexy2(WhereX-7,WhereY+1,'@@@@  @');
					writexy2(WhereX-7,WhereY+1,'@@@@  @');
					writexy2(WhereX-7,WhereY+1,'@  @  @');
					writexy2(WhereX-7,WhereY+1,'@     @');
					writexy2(WhereX-7,WhereY+1,'@@@@@@@');
					writexy2(WhereX-7,WhereY+1,'@@@@@@@')
				end else begin
				  	writexy2(WhereX-1,WhereY,  '   @@@@'); 
					writexy2(WhereX-7,WhereY+1,'   @  @');
					writexy2(WhereX-7,WhereY+1,'   @  @');
					writexy2(WhereX-7,WhereY+1,'@@@@  @');
					writexy2(WhereX-7,WhereY+1,'@  @  @');
					writexy2(WhereX-7,WhereY+1,'@     @');
					writexy2(WhereX-7,WhereY+1,'@@@@@@@');
					writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				end;
				gotoxy(WhereX,WhereY-7);
			end;
			'K': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@    @@');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				writexy2(WhereX-7,WhereY+1,'@@@ @@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'L': begin
				if(i=Length(s)) or (s[i+1]=' ')then begin
					writexy2(WhereX-1,WhereY,  '@@@@   '); 
					writexy2(WhereX-7,WhereY+1,'@  @   ');
					writexy2(WhereX-7,WhereY+1,'@  @   ');
					writexy2(WhereX-7,WhereY+1,'@  @   ');
					writexy2(WhereX-7,WhereY+1,'@  @@@@');
					writexy2(WhereX-7,WhereY+1,'@     @');
					writexy2(WhereX-7,WhereY+1,'@@@@@@@');
					writexy2(WhereX-7,WhereY+1,'@@@@@@@')
				end else begin
				  	writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
					writexy2(WhereX-7,WhereY+1,'@  @@@@');
					writexy2(WhereX-7,WhereY+1,'@  @@@@');
					writexy2(WhereX-7,WhereY+1,'@  @@@@');
					writexy2(WhereX-7,WhereY+1,'@  @@@@');
					writexy2(WhereX-7,WhereY+1,'@     @');
					writexy2(WhereX-7,WhereY+1,'@@@@@@@');
					writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				end;
				gotoxy(WhereX,WhereY-7);
			end;
			'M': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@ @@@@'); 
			   	writexy2(WhereX-9,WhereY+1,'@  @@@  @');
				writexy2(WhereX-9,WhereY+1,'@   @   @');
				writexy2(WhereX-9,WhereY+1,'@       @');
				writexy2(WhereX-9,WhereY+1,'@  @ @  @');
				writexy2(WhereX-9,WhereY+1,'@  @@@  @');
				writexy2(WhereX-9,WhereY+1,'@@@@@@@@@');
				writexy2(WhereX-9,WhereY+1,'@@@@ @@@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'N': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@@@@@'); 
				writexy2(WhereX-8,WhereY+1,'@  @@  @');
				writexy2(WhereX-8,WhereY+1,'@   @  @');
				writexy2(WhereX-8,WhereY+1,'@      @');
				writexy2(WhereX-8,WhereY+1,'@  @   @');
				writexy2(WhereX-8,WhereY+1,'@  @@  @');
				writexy2(WhereX-8,WhereY+1,'@@@@@@@@');
				writexy2(WhereX-8,WhereY+1,'@@@@@@@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'O': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'P': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@  @@@@');
				writexy2(WhereX-7,WhereY+1,'@  @@@@');
				writexy2(WhereX-7,WhereY+1,'@@@@   ');
				writexy2(WhereX-7,WhereY+1,'@@@@   ');
				gotoxy(WhereX,WhereY-7);
			end;
			'Q': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@@@@ '); 
			   	writexy2(WhereX-8,WhereY+1,'@     @ ');
				writexy2(WhereX-8,WhereY+1,'@  @  @ ');
				writexy2(WhereX-8,WhereY+1,'@  @  @ ');
				writexy2(WhereX-8,WhereY+1,'@  @  @@');
				writexy2(WhereX-8,WhereY+1,'@      @');
				writexy2(WhereX-8,WhereY+1,'@@@@@@@@');
				writexy2(WhereX-8,WhereY+1,'@@@@@@@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'R': begin
				writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@    @@');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				writexy2(WhereX-7,WhereY+1,'@@@ @@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'S': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@  @@@@');
				writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@@@@  @');
				writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'T': begin
			  	writexy2(WhereX,WhereY,  '@@@@@@@@'); 
			   	writexy2(WhereX-8,WhereY+1,'@      @');
				writexy2(WhereX-8,WhereY+1,'@@@  @@@');
				writexy2(WhereX-8,WhereY+1,'@@@  @@@');
				writexy2(WhereX-8,WhereY+1,'  @  @  ');
				writexy2(WhereX-8,WhereY+1,'  @  @  ');
				writexy2(WhereX-8,WhereY+1,'  @@@@  ');
				writexy2(WhereX-8,WhereY+1,'  @@@@  ');
				gotoxy(WhereX,WhereY-7);
			end;
			'U': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'V': begin
			  	writexy2(WhereX,WhereY,    '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@@@ @@@');
				writexy2(WhereX-7,WhereY+1,' @@@@@ ');
				writexy2(WhereX-7,WhereY+1,'  @@@  ');
				gotoxy(WhereX,WhereY-7);
			end;
			'W': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@ @@@@'); 
			   	writexy2(WhereX-9,WhereY+1,'@  @@@  @');
				writexy2(WhereX-9,WhereY+1,'@  @ @  @');
				writexy2(WhereX-9,WhereY+1,'@       @');
				writexy2(WhereX-9,WhereY+1,'@   @   @');
				writexy2(WhereX-9,WhereY+1,'@  @@@  @');
				writexy2(WhereX-9,WhereY+1,'@@@@@@@@@');
				writexy2(WhereX-9,WhereY+1,'@@@@ @@@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'X': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@@   @@');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@  @  @');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				writexy2(WhereX-7,WhereY+1,'@@@ @@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'Y': begin
			  	writexy2(WhereX,WhereY,  '@@@@@@@@'); 
			   	writexy2(WhereX-8,WhereY+1,'@  @@  @');
				writexy2(WhereX-8,WhereY+1,'@  @@  @');
				writexy2(WhereX-8,WhereY+1,'@@    @@');
				writexy2(WhereX-8,WhereY+1,'@@@  @@@');
				writexy2(WhereX-8,WhereY+1,' @@  @@ ');
				writexy2(WhereX-8,WhereY+1,'  @  @  ');
				writexy2(WhereX-8,WhereY+1,'  @@@@  ');
				gotoxy(WhereX,WhereY-7);
			end;
			'Z': begin
			  	writexy2(WhereX-1,WhereY,  '@@@@@@@'); 
			   	writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@@@@  @');
				writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@  @@@@');
				writexy2(WhereX-7,WhereY+1,'@     @');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				writexy2(WhereX-7,WhereY+1,'@@@@@@@');
				gotoxy(WhereX,WhereY-7);
			end;
			'!': begin
			  	writexy2(WhereX  ,WhereY,  '@@@@'); 
			   	writexy2(WhereX-4,WhereY+1,'@  @');
				writexy2(WhereX-4,WhereY+1,'@  @');
				writexy2(WhereX-4,WhereY+1,'@  @');
				writexy2(WhereX-4,WhereY+1,'@@@@');
				writexy2(WhereX-4,WhereY+1,'@  @');
				writexy2(WhereX-4,WhereY+1,'@@@@');
				writexy2(WhereX-4,WhereY+1,'@@@@');
				gotoxy(WhereX,WhereY-7);
			end;
			' ': begin
			  	writexy2(WhereX,WhereY,    '    '); 
			   	writexy2(WhereX-4,WhereY+1,'    ');
				writexy2(WhereX-4,WhereY+1,'    ');
				writexy2(WhereX-4,WhereY+1,'    ');
				writexy2(WhereX-4,WhereY+1,'    ');
				writexy2(WhereX-4,WhereY+1,'    ');
				writexy2(WhereX-4,WhereY+1,'    ');
				writexy2(WhereX-4,WhereY+1,'    ');
				gotoxy(WhereX,WhereY-7);
			end;
		end;
	end;
end;

procedure pantallaPerdiste(var a:archivo_puntaje);
var posCX:integer = maxC div 2;//posicion central de la pantalla en X
	posCY:integer = maxF div 2;//posicion central de la pantalla en Y
	pj:regPuntos;
begin
	writeTitulo(posCX-30,1,'PERDISTE!!');
	writexyCent(posCX,posCY+1,'puntaje: ' + IntToStr(puntaje));
	writexyCent(posCX,posCY+3,'========== TOP PUNTAJES ==========');
	posCY := posCY+4;
	reset(a);
	read(a,pj);
	while pj.sig<>(-1) do begin
		seek(a,pj.sig);
		read(a,pj);
		writexyCent(posCX,posCY,pj.nombre+': '+IntToStr(pj.puntos));
		posCY:=posCY+1;
	end;
	close(a);
	writexyCent(posCX,posCY,'==================================');
	writexyCent(posCX,posCY+2,'presiona cualquier tecla para volver al menu');
	readkey;
end;

procedure leerTeclado(var dir{,dirAnt}:integer);
var c:char;
begin
	if(KeyPressed)then begin
		c:=readkey();
		case c of
			'w': begin
					if(dir<>3)then begin
						//dirAnt:=dir;
						dir:=1;
					end;
				end;
			'd': begin
					if(dir<>4)then begin
						//dirAnt:=dir;
						dir:=2;
					end;
				end;
			's': begin
					if(dir<>1)then begin
						//dirAnt:=dir;
						dir:=3;
					end;
				end;
			'a': begin
					if(dir<>2)then begin
						//dirAnt:=dir;
						dir:=4;
					end;
				end;
		end;
	end;
end;

procedure dibujar(t:tablero;fx,fy,tx,ty:integer);
var x,y:integer; l:string;
begin
    for y:=fy to ty do begin
        l:='';
        for x:=fx to tx do begin
            l:=l+t[x][y];
        end;
        writexy2(fx,y,l);
    end;
end;

//crea varias comidas. La uso al incio
procedure crearComidas(var tbl:tablero);
var x,y,i:integer;
begin
	for i:=1 to comidas do begin
	    x:=random(maxC); y:=random(maxF);
	    if((tbl[x][y]<>sim_comida) and (tbl[x][y]<>cabeza) and (tbl[x][y]<>sim_cuerpo) and (tbl[x][y]<>borde_lateral) and (tbl[x][y]<>borde_horiz))then
		    tbl[x][y]:=sim_comida;
            dibujar(tbl,x,y,x,y);
	end;
end;

//Crea una comida, la uso al recoger una comida.
procedure crearComida(var tbl:tablero);
var x,y:integer;
begin
	x:=random(maxC)+1; y:=random(maxF)+1;
	if((tbl[x][y]<>sim_comida) and (tbl[x][y]<>cabeza) and (tbl[x][y]<>sim_cuerpo) and (tbl[x][y]<>borde_lateral) and (tbl[x][y]<>borde_horiz))then begin
		tbl[x][y]:=sim_comida;
        dibujar(tbl,x,y,x,y)
	end else 
		crearComida(tbl);//si no se puede generar una comida en esa posicion, se genera en otra.
end;

procedure initTablero(var t:tablero);
var x,y:integer;
begin
	for y:=min to maxF do begin
		for x:=min to maxC do begin
			t[x][y]:=' ';
		end;
	end;
    dibujar(t,min,min,maxC,maxF);
	for x:=min to maxC do begin
		t[x][min]:=borde_horiz;
		t[x][maxF]:=borde_horiz;
	end;
    dibujar(t,min,min,maxC,min);
    dibujar(t,min,maxF,maxC,maxF);
	for y:=min to maxF do begin
		t[min][y]:=borde_lateral;
		t[maxC][y]:=borde_lateral;
        dibujar(t,min,y,min,y);
        dibujar(t,maxC,y,maxC,y);
	end;
end;

procedure agregarAdelante(var v:vibora;x,y:integer;var t:tablero);
var nue:vibora;
begin
	if(v=nil)then begin
		new(v); v^.x:=x; v^.y:=y; v^.sig:=nil;
		t[x][y]:=cabeza;
	end else begin
		new(nue); nue^.x:=x; nue^.y:=y; nue^.sig:=v;
		v:=nue;
        t[x][y] := sim_cuerpo;
	end;
end;

procedure initVibora(var v:vibora;var t:tablero);
var i,r:integer;
begin
    v:=nil; r:=(random(maxF)+1)*2;
	for i:=r to r+5 do begin
		agregarAdelante(v,i,15,t);
		//writeln('Cuerpo: x: ',i,' | y: 20');
	end;
end;

procedure borrarVibora(var v:vibora);
begin
    if(v<>nil)then begin
        borrarVibora(v^.sig);
        dispose(v);
    end;
end;

procedure topPuntaje(var a:archivo_puntaje;var jugador:regPuntos);
var ant,act,nPos,i:integer; rAct,rAux:regPuntos; Ok:boolean = false;
begin
	reset(a);
	if(filesize(a)=1)then begin
		jugador.sig:=filesize(a);
		write(a,jugador);
		seek(a,filesize(a));
		jugador.sig:=-1;
		write(a,jugador);
	end else begin
		ant:=filepos(a);
		read(a,rAct);
		act:=rAct.sig;
		while (act<>-1) and (not Ok) do begin // compara si superó algun puntaje
			seek(a,act);
			read(a,rAct);
			if(jugador.puntos > rAct.puntos)then begin // si lo supera guarda la dir en sig y Ok=true
				Ok:=true;
				jugador.sig:=act; // al superar, el siguiente puntaje es el superado
			end else begin // sino sigue iterando
				ant:=act;
				act:=rAct.sig;
			end;
		end;

		if Ok and (filesize(a)<6)then begin // si superó y el archivo aun tiene espacio
			{seek(ant)	
			read(rAct);
			rAct.sig = filesize // al anterior del superado le ponemos la dir del final
			write(rAct) // lo actualizamos 
			seek(filesize) // vamos al fin del archivo para escribir el nuevo puntaje
			write(rNue) // lo escribimos}
			seek(a,ant); // vamos a su pos
			read(a,rAct);
			rAct.sig := filesize(a);
			seek(a,ant);
			write(a,rAct);
			seek(a,filesize(a));
			write(a,jugador)
		end else if Ok then begin // si supero y no hay espacio
			{mientras rAct.sig<>-1:	// busca el menor puntaje
				read(rAct)
			nPos = filepos // guarda su pos
			write(rNue) // escribe el nuevo puntaje
			seek(ant) // va al anterior en la lista (anterior al puntaje que sobrepasó)
			read(rAct) // lo lee
			rAct.sig = nPos // actualiza su puntero ya que antes apuntaba a act
			seek(ant) // volvemos en la pos para escribirlo
			write(rAct) // lo escribimos para actualizar}
			seek(a,0);
			read(a,rAct);
			while(rAct.sig<>-1) do begin
				read(a,rAct);
			end;
			seek(a,filepos(a)-1);
			nPos := filepos(a);
			write(a,jugador);
			seek(a,ant);
			read(a,rAct);
			rAct.sig:=nPos;
			seek(a,ant);
			write(a,rAct);
			// buscar minimo y ponerle enlace -1
			seek(a,1);
			i:=2;
			Ok:=false;
			while not Ok do begin
				nPos:=filepos(a);
				read(a,rAct);
				seek(a,rAct.sig);
				read(a,rAux);
				if(rAct.puntos<rAux.puntos)then begin
					Ok:=true;
					rAct.sig:=-1;
					seek(a,nPos);
					write(a,rAct);
				end;
				seek(a,i);
				i:=i+1;
			end
		end else if not Ok and (filesize(a)<6)then begin
			{seek(ant)	// va al ultimo de la lista
			read(rAct)	// lo lee
			rAct.sig = filesize // le pone el enlace al fin del archivo
			seek(ant) // vuelve una pos
			write(rAct) // lo actualiza
			rNue.sig := -1 // no tiene siguiente
			seek(filesize) // va al final del archivo
			write(rNue) // lo escribo}
			seek(a,ant);
			read(a,rAct);
			rAct.sig := filesize(a);
			seek(a,ant);
			write(a,rAct);
			jugador.sig:=-1;
			seek(a,filesize(a));
			write(a,jugador);
		end;
	end;
	close(a);
	{
		si archivo = 1:
			seek(filesize)
			write(rNue)
		sino:
			ant = filepos
			act = rAct.sig
			mientras act <> -1 y no Ok: // compara si superó algun puntaje
				seek(act)
				read(rAct)
				si rNue.puntaje > rAct.puntos: // si lo supera guarda la dir en sig y Ok=true
					Ok = true
					rNue.sig = act		// al superar, el siguiente puntaje es el superado
				sino:					// sino sigue iterando
					ant = act
					act = rAct.sig
			
			si Ok and archivo < 6: // si superó y el archivo aun tiene espacio
				seek(ant)	
				read(rAct);
				rAct.sig = filesize // al anterior del superado le ponemos la dir del final
				write(rAct) // lo actualizamos 
				seek(filesize) // vamos al fin del archivo para escribir el nuevo puntaje
				write(rNue) // lo escribimos
			sino si Ok: // si superó y el archivo no tiene espacio
				mientras rAct.sig<>-1:	// busca el menor puntaje
					read(rAct)
				nPos = filepos // guarda su pos
				write(rNue) // escribe el nuevo puntaje
				seek(ant) // va al anterior en la lista (anterior al puntaje que sobrepasó)
				read(rAct) // lo lee
				rAct.sig = nPos // actualiza su puntero ya que antes apuntaba a act
				seek(ant) // volvemos en la pos para escribirlo
				write(rAct) // lo escribimos para actualizar
			sino si not Ok and archivo < 6: // si no superó pero hay espacio en el archivo
				seek(ant)	// va al ultimo de la lista
				read(rAct)	// lo lee
				rAct.sig = filesize // le pone el enlace al fin del archivo
				seek(ant) // vuelve una pos
				write(rAct) // lo actualiza
				rNue.sig := -1 // no tiene siguiente
				seek(filesize) // va al final del archivo
				write(rNue) // lo escribo	
	}
end;

procedure pantallaPuntaje(var jugador:regPuntos);
var
	posCX:integer = maxC div 2;//posicion central de la pantalla en X
	posCY:integer = maxF div 2;//posicion central de la pantalla en Y
begin
	writexyCent(posCX,posCY,'Puntaje: ' + IntToStr(puntaje));
	writexyCent(posCX,posCY+1,'Nombre: ');
	readln(jugador.nombre);
	jugador.puntos:=puntaje;
end;

procedure animacion(v:vibora;d:integer;t:tablero;var a:archivo_puntaje);
	procedure aumentar(var v:vibora;d:integer;var p:boolean;var t:tablero);
	var sigue,act:vibora;
	begin
		sigue:=v^.sig; act:=v;
		t[act^.x][act^.y]:=' ';
        writexy(act^.x,act^.y,t[act^.x][act^.y]);
		while(sigue<>nil)do begin
			act^.x:=sigue^.x;
			act^.y:=sigue^.y;
			t[act^.x][act^.y]:=sim_cuerpo;
            writexy(act^.x,act^.y,t[act^.x][act^.y]);
			act:=sigue; sigue:=sigue^.sig;
		end;
		case d of
			1: act^.y:=act^.y-1;
			2: act^.x:=act^.x+1;
			3: act^.y:=act^.y+1;
			4: act^.x:=act^.x-1;
		end;
		if(t[act^.x][act^.y]=sim_comida)then begin//si consigo la comida:
			agregarAdelante(v,act^.x,act^.y,t);//la serpiente crece en 1
			puntaje:=puntaje+1;	//sumo 1 al puntaje.
			crearComida(t);
			end
		else if(t[act^.x][act^.y]=sim_cuerpo)then
			p:=TRUE;
		if((act^.y<=min) or (act^.y>=maxF) or (act^.x<=min) or (act^.x>=maxC)) and (dificultad = 0)then
			p:=TRUE
		else if (dificultad = 1) then begin
			if (act^.y<=min) then
				act^.y:=maxF-1
			else if (act^.y>=maxF) then
				act^.y:=min+1
			else if (act^.x<=min) then
				act^.x:=maxC-1
			else if (act^.x>=maxC) then
				act^.x:=min+1;
		t[act^.x][act^.y]:=cabeza;
        writexy(act^.x,act^.y,t[act^.x][act^.y]);
		end;
	end;
var lose:boolean; antes,despu: TDateTime;{dAnt:integer;}
begin
	lose:=FALSE;
    antes := Now;
    {dAnt:=d;}
	repeat
		despu:=Now;
		if(MilliSecondsBetween(antes,despu)>millisEntreFrames)then begin
			aumentar(v,d,lose,t);
			writexy(1,maxF+2,'puntaje: ' + IntToStr(puntaje));
			leerTeclado(d);
			antes:=Now;
		end;
	until(lose=TRUE); // previo
	
end;

function menu():char;
var 
	posCX:integer = maxC div 3;//posicion central de la pantalla en X
	posCY:integer = maxF div 6;//posicion central de la pantalla en Y
begin
	writeTitulo(7,2,'PASCAL SNAKE!');
	writexy(posCX,posCY+10,'1. Jugar');
	writexy(posCX,posCY+12,'2. Seleccionar Velocidad');
	writexy(posCX,posCY+14,'3. Seleccionar Dificultad');
	writexy(posCX,posCY+16,'4. Top 5 puntajes (segun velocidad y dificultad)');
	writexy(posCX,posCY+18,'Presiona otra tecla para cerrar');
	if(dificultad = 0)then
		writexy(posCX,posCY+20,'Dificultad actual: Normal')
	else
		writexy(posCX,posCY+20,'Dificultad actual: Facil');
	
	if(millisEntreFrames=80)then
		writexy(posCX,posCY+21,'Velocidad actual: Rapida')
	else if (millisEntreFrames=100) then
		writexy(posCX,posCY+21,'Velocidad actual: Normal')
	else
		writexy(posCX,posCY+21,'Velocidad actual: Lenta');

	menu:=readKey();
end;

procedure elegirVelocidad();
var 
	posCX:integer = maxC div 3;//posicion central de la pantalla en X
	posCY:integer = maxF div 6;//posicion central de la pantalla en Y
	c: char;
begin
	ClrScr;
	writeTitulo(7,2,'VELOCIDAD!');
	writexy(posCX,posCY+10,'1. Rapida');
	writexy(posCX,posCY+12,'2. Normal');
	writexy(posCX,posCY+14,'3. Lenta');
	c:=readKey();
	case c of
		'1': millisEntreFrames:=80;
		'2': millisEntreFrames:=100;
		'3': millisEntreFrames:=120;
	end;
end;

procedure elegirDificultad();
var 
	posCX:integer = maxC div 3;//posicion central de la pantalla en X
	posCY:integer = maxF div 6;//posicion central de la pantalla en Y
	c: char;
begin
	ClrScr;
	writeTitulo(7,2,'DIFICULTAD!');
	writexy(posCX,posCY+10,'1. Facil');
	writexy(posCX,posCY+12,'2. Normal');
	c:=readKey();
	case c of
		'1': dificultad:=1;
		'2': dificultad:=0;
	end;
end;

procedure mostrarTop(var a:archivo_puntaje);
var 
	posCX:integer = maxC div 3;//posicion central de la pantalla en X
	posCY:integer = maxF div 6;//posicion central de la pantalla en Y
	pj:regPuntos;
begin
	ClrScr;
	writeTitulo(3,2,'TOP CINCO!');
	reset(a);
	read(a,pj);
	posCY:=posCY+10;
	while pj.sig<>(-1) do begin
		seek(a,pj.sig);
		read(a,pj);
		writexyCent(posCX,posCY,pj.nombre+': '+IntToStr(pj.puntos));
		posCY:=posCY+1;
	end;
	close(a);
	writexyCent(posCX,posCY+1,'Presiona cualquier tecla para volver al menu');
	readkey;
end;

procedure jugar(var a:archivo_puntaje;r:regPuntos);
var t:tablero; v:vibora;
begin
	ClrScr;
	randomize;
	puntaje := 0;
	initTablero(t);
	initVibora(v,t);
	crearComidas(t);
	//dibujar(t,min+1,min+1,maxC-1,maxF-1);
	animacion(v,1,t,a);
	ClrScr;
	pantallaPuntaje(r);
	topPuntaje(a,r);
	ClrScr;
	pantallaPerdiste(a);//solo pone el mensaje de perdiste si lose es true.
end;

var c:char; a:archivo_puntaje; r:regPuntos; nom:string;
begin
	cursoroff;
	writexy(0,0,' ');
	repeat
		ClrScr;
		c:=menu();
		case c of
			'1': begin
				nom:='puntos'+IntToStr(millisEntreFrames)+IntToStr(dificultad)+'.dat';
				Assign(a,nom);
				if(not FileExists(nom))then begin
					rewrite(a);
					r.sig:=-1;
					write(a,r);
					close(a);
				end;
				jugar(a,r);
			end;
			'2': elegirVelocidad();
			'3': elegirDificultad();
			'4': begin
				nom:='puntos'+IntToStr(millisEntreFrames)+IntToStr(dificultad)+'.dat';
				Assign(a,nom);
				if(not FileExists(nom))then begin
					rewrite(a);
					r.sig:=-1;
					write(a,r);
					close(a);
				end;
				mostrarTop(a);
			end;
			else
				c:='q';
		end;
	until(c='q');
end.
