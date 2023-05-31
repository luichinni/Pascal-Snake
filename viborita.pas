program viborita;
uses Crt,sysutils;


const
	min=1;
	maxC=80;
	maxF=23;
	comidas=1;//la cantidad de comida que hay en pantalla.
	color_suelo=6;
	color_comida=4;
	color_cuerpo=2;
	color_borde=3;
	sim_cuerpo='@';
	cabeza='O';
	borde_lateral='#';
	borde_horiz='#';
	sim_comida='*';
	{Black        =   0;
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
	Blink        = 128;}
type
vibora= ^cuerpo;
cuerpo = record
	x:integer;
	y:integer;
	sig:vibora;
end;

columna = array [min..maxC] of char;
tablero = array [min..maxF] of columna; // primero fila luego columnas --> t[fila][columna]


//VARIABLE GLOBAL DEL PUNTAJE.
var puntaje:integer = 0;


{procedure writexy(x,y:integer;c:char);
begin
	gotoxy(x,y);
	write(c);
end;}

//sobrecarga de writexy, para que funcione con strings.
procedure writexy(x,y:integer;s:string);
var i:integer;
begin
	if(s=sim_comida)then begin
		TextBackground(color_comida); // comentar esta linea para ver el simbolo
		TextColor(color_comida)
	end else if(s=sim_cuerpo) or (s=cabeza)then begin
		TextBackground(color_cuerpo); // comentar esta linea para ver el simbolo
		TextColor(color_cuerpo)
	end else if(s=borde_lateral) or (s=borde_horiz)then begin
		TextColor(color_borde);
		TextBackground(color_borde); // comentar esta linea para ver el simbolo
	end;
	for i := 0 to Length(s)-1 do begin
		gotoxy(x+i,y);
		write(s[i+1]);
	end;
	TextBackground(color_suelo);
	TextColor(15);
end;


//segunda version de la sobrecarga, que ahora le agrega un offset a x, 
//asi escribe en centrado segun la posicion especificada.
procedure writexyCent(x,y:integer;s:string);
var i:integer;
begin

	x:= x - (Length(s) div 2);

	for i := 0 to Length(s)-1 do begin
		gotoxy(x+i,y);
		write(s[i+1]);
	end;
end;



procedure dibujar(t:tablero);
var f,c:integer;
begin
	TextBackground(color_suelo);
	for f:=min to maxF do begin
		for c:=min to maxC do
			writexy(c,f,t[f][c]);
	end;
end;

procedure agregarAdelante(var v:vibora;x,y:integer;var t:tablero);
var nue:vibora;
begin
	if(v=nil)then begin
		new(v); v^.x:=x; v^.y:=y; v^.sig:=nil;
		t[y][x]:=sim_cuerpo;
	end else begin
		new(nue); nue^.x:=x; nue^.y:=y; nue^.sig:=v;
		v:=nue;
	end;
end;

procedure initVibora(var v:vibora;var t:tablero);
var i:integer;
begin
    v:=nil;
	for i:=10 to 15 do begin
		agregarAdelante(v,i,20,t);
		//writeln('Cuerpo: x: ',i,' | y: 20');
	end;
end;


procedure pantallaPerdiste();
var posCX:integer = maxC div 2;//posicion central de la pantalla en X
	posCY:integer = maxF div 2;//posicion central de la pantalla en Y

begin
	writexyCent(posCX,posCY,'PERDISTE!');
	writexyCent(posCX,posCY+1,'puntaje: ' + IntToStr(puntaje));
	writexyCent(posCX,posCY+4,'presiona cualquier tecla para continuar.');
end;


procedure leerTeclado(var dir:integer);
var c:char;
begin
	c:=readkey();
	case c of
		'w': begin
		        if(dir<>3)then
		            dir:=1;
		     end;
		'd': begin
		        if(dir<>4)then
		            dir:=2;
		     end;
		's': begin
		        if(dir<>1)then
		            dir:=3;
		     end;
		'a': begin
		        if(dir<>2)then
		            dir:=4;
		     end;
	end;
end;


//crea varias comidas. La uso al incio
procedure crearComidas(var tbl:tablero);
var x,y,i:integer;
begin
	for i:=1 to comidas do begin
	    x:=random(maxF); y:=random(maxC);
	    if((tbl[x][y]<>sim_comida) and (tbl[x][y]<>cabeza) and (tbl[x][y]<>sim_cuerpo) and (tbl[x][y]<>borde_lateral) and (tbl[x][y]<>borde_horiz))then
		    tbl[x][y]:=sim_comida;
	end;
end;

//Crea una comida, la uso al recoger una comida.
procedure crearComida(var tbl:tablero);
var x,y:integer;
begin
	x:=random(maxF)+1; y:=random(maxC)+1;
	if((tbl[x][y]<>sim_comida) and (tbl[x][y]<>cabeza) and (tbl[x][y]<>sim_cuerpo) and (tbl[x][y]<>borde_lateral) and (tbl[x][y]<>borde_horiz))then
		tbl[x][y]:=sim_comida
	else 
		crearComida(tbl);//si no se puede generar una comida en esa posicion, se genera en otra.
end;




procedure animacion(v:vibora;d:integer;t:tablero);
	procedure aumentar(var v:vibora;d:integer;var p:boolean;var t:tablero);
	var sigue,rem:vibora;
	begin
		sigue:=v^.sig; rem:=v;
		t[rem^.y][rem^.x]:=' ';
		while(sigue<>nil)do begin
			rem^.x:=sigue^.x;
			rem^.y:=sigue^.y;
			t[rem^.y][rem^.x]:=sim_cuerpo;
			rem:=sigue; sigue:=sigue^.sig;
		end;
		case d of
			1: rem^.y:=rem^.y-1;
			2: rem^.x:=rem^.x+1;
			3: rem^.y:=rem^.y+1;
			4: rem^.x:=rem^.x-1;
		end;
		if(t[rem^.y][rem^.x]=sim_comida)then begin//si consigo la comida:
			agregarAdelante(v,rem^.x,rem^.y,t);//la serpiente crece en 1
			puntaje:=puntaje+1;	//sumo 1 al puntaje.
			crearComida(t);
			end
		else if(t[rem^.y][rem^.x]=sim_cuerpo)then
			p:=TRUE;
		t[rem^.y][rem^.x]:=cabeza;
		if((rem^.y<=min) or (rem^.y>=maxF) or (rem^.x<=min) or (rem^.x>=maxC))then
			p:=TRUE;
	end;
	{procedure impVibora(v:vibora);
	begin
		while(v<>nil)do begin
			if(v^.sig=nil)then
				writexy(v^.x,v^.y,'#')
			else
				writexy(v^.x,v^.y,'@');
			v:=v^.sig;
		end;
	end;}
	{procedure impBordes();
	var i:integer;
	begin
		for i:=min to maxC do begin
			writexy(i,1,'-');
			writexy(i,23,'-');
		end;
		for i:=min to maxF do begin
			writexy(1,i,'|');
			writexy(80,i,'|');
		end;
	end;}
var lose:boolean;
begin
	lose:=FALSE;
	repeat
		repeat
			//dibuja
			//impBordes();
			dibujar(t);
			//impVibora(v);
			//aumenta
			aumentar(v,d,lose,t);
			writexyCent(1,maxF+2,'puntaje: ' + IntToStr(puntaje));
			if(d = 1) or (d = 3) then //si la direccion es vertical:
				delay(160) //va mas lento
			else//si no
				delay(80);//va normal
			//ClrScr;		//NOTA: lo saque pq estaba al pepe
			if lose then begin
				ClrScr;
				pantallaPerdiste();//solo pone el mensaje de perdiste si lose es true.
				puntaje := 0;
				end;
		until(KeyPressed or lose=TRUE); // previo
		leerTeclado(d);
	until(lose);
end;
//----------------------------------------------------------------------




procedure initTablero(var t:tablero);
var i,j:integer;
begin
	for i:=min to maxF do begin
		for j:=min to maxC do begin
			t[i][j]:=' ';
		end;
	end;
	for i:=min to maxC do begin
		t[min][i]:=borde_horiz;
		t[maxF][i]:=borde_horiz;
	end;
	for i:=min to maxF do begin
		t[i][min]:=borde_lateral;
		t[i][maxC]:=borde_lateral;
	end;
end;

procedure borrarVibora(var v:vibora);
begin
    if(v<>nil)then begin
        borrarVibora(v^.sig);
        dispose(v);
    end;
end;

//----------------------------------------------------------------------
// PP
var v:vibora; 
	t:tablero;
begin

	randomize;

	{randomize;
	v:=nil;
	initTablero(t);
	dibujar(t);
	initVibora(v,t);}
	while TRUE do begin
	    randomize;
	    v:=nil;
	    initTablero(t);
    	dibujar(t);
	    initVibora(v,t);
	    crearComidas(t);
	    animacion(v,1,t);
	    borrarVibora(v);
	end;
end.
