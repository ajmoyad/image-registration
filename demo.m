%% Copyright 2013 Antonio Moya (ajmoyad@gmail.com)
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details. 
%
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.


%% PROYECTO: COLOREANDO IMÁGENES DEL IMPERIO RUSO
%
%   Script de demostración y generación de estadísticas del proyecto de
%   registrado de imágenes de la asignatura Laboratorio Multimedia.
%
%   Antonio J. Moya Díaz
%   5 de Junio de 2013


%% INFO
% Este fichero está organizado en 3 celdas de ejecución. 
%   - La primera de ellas carga los nombres de las imágenes en una variable.
% Es importante para la correcta ejecución que el directorio sea el que se
% indica.
%   - La segunda celda es para la ejecución de 1 única imagen y así poder
% observar su resultado. Debe seleccionar la imagen a procesar.
%   - La tercera celda automatiza una batería de operaciones con el fin de
% evaluar los tiempos de ejecución. Se ha pensado para tratar las imágenes
% pequeñas y las imágenes por separado. Se puede activar o desactivar la
% ecualización, así como seleccionar el número de iteraciones. AVISO, con
% imagenes grandes y muchas iteraciones, la ejecución tardará varios
% minutos.

%% Preliminar

% Limpiamos el workspace y las posibles ventanas abiertas
clear, close all, clc

% Añadimos la ruta donde se encuentran las funciones
addpath('./src');

% Lista de ficheros de imagen, para sencillez en la carga posterior.
f=cell(1,16);

f{1}='images/00125v.jpg';
f{2}='images/00149v.jpg';
f{3}='images/00153v.jpg';
f{4}='images/00154v.jpg';
f{5}='images/00163v.jpg';
f{6}='images/00270v.jpg';
f{7}='images/00398v.jpg';
f{8}='images/00564v.jpg';
f{9}='images/01167v.jpg';
f{10}='images/31421v.jpg';
f{11}='images/00458u.tif';
f{12}='images/00911u.tif';
f{13}='images/01043u.tif';
f{14}='images/01047u.tif';
f{15}='images/01657u.tif';
f{16}='images/01861a.tif';


%% Ejecución singular

% SELECCIONE una imagen de entre la lista anterior
imagen=1;
% ------------------------------------------------


% Selección automática de la ventana
if imagen<11
    vent_ini=8; % Ventana para imagenes pequeñas
else
    vent_ini=20; % Ventana para imagenes grandes
end

% Cargamos la imagen seleccionada
I=imread(f{imagen});
I=im2double(I);
    
% Seccionado de la imagen en sus tres canales
h=floor(size(I,1)/3);
B=I(1:h,:);
G=I(h+1:h*2,:);
R=I(h*2+1:h*3,:);

% Limpiamos de memoria las variables que no vamos a usar.
clear I h

% Cálculo de los desplazamientos
desp_Rojo=registraImagen(G,R,vent_ini);
desp_Azul=registraImagen(G,B,vent_ini);

% Reserva de espacio
Ifinal=ones(size(R,1),size(R,2),3);
Rr=zeros(size(R,1),size(R,2));
Br=zeros(size(B,1),size(B,2));

% Montado del canal Rojo
dy=desp_Rojo(1);
dx=desp_Rojo(2);
Rr(max(1,1+dy):min(end,end+dy),max(1,1+dx):min(end,end+dx))=R(max(1,1-dy):min(end,end-dy),max(1,1-dx):min(end,end-dx));

% Montado del canal azul
dy=desp_Azul(1);
dx=desp_Azul(2);
Br(max(1,1+dy):min(end,end+dy),max(1,1+dx):min(end,end+dx))=B(max(1,1-dy):min(end,end-dy),max(1,1-dx):min(end,end-dx));
    
% Montado de la imagen final
Ifinal(:,:,1)=Rr;
Ifinal(:,:,2)=G;
Ifinal(:,:,3)=Br;

% Recorte de los bordes
[corteY,corteX]=recortarBordes(Ifinal);
Irecortada=Ifinal(corteY(1):end-corteY(2),corteX(1):end-corteX(2),:);

% Ecualización
Irecortada=imadjust(Irecortada,stretchlim(Irecortada),[]);

% Muestra la imagen
figure(31),imshow(Irecortada)





%% Estadísticas de tiempos por grupo de imágenes

% SELECCIONE los siguientes parámetros
seleccion=0; % 0=>imágenes pequeñas, 1=>imágenes grandes
ecualizacion=1; % 0=> desactivada, 1=> activada
iteraciones=20; % Número de iteraciones
% -------------------------------------


% Seleccionaos los parámetros correctos para cada simulación.
%   n: es el numero  de imágenes de cada conjunto
%   vent_ini: es el tamaño de ventana inicial
%   offset: ya que en la variabla f listamos las imágenes de manera
%           ordenada, offset es para ajustar ese índice a fin de escoger
%           las imágenes y calcular las medias de los tiempos de ejecución
%           correctamente.
if seleccion==0
    n=10;
    vent_ini=8;
    offset=1;
elseif seleccion==1
    n=6;
    vent_ini=20;
    offset=11;
else
    error('No ha seleccionado un grupo de imagen correcto')
end


% Tiempos de ejecución por canal y proceso, e imagen  
tiempo_rojo=zeros(iteraciones,n);
tiempo_azul=zeros(iteraciones,n);
tiempo_corte=zeros(iteraciones,n);
tiempo_ecu=zeros(iteraciones,n);
tiempo_total=zeros(iteraciones,n);

for j=1:1:iteraciones

    for i=offset:1:offset+n-1;
    
        total=tic;
    
        % Cargamos la imagen
        I=imread(f{i});
        I=im2double(I);
    
        % Seccionado de la imagen en sus tres canales
        h=floor(size(I,1)/3);
        B=I(1:h,:);
        G=I(h+1:h*2,:);
        R=I(h*2+1:h*3,:);

        clear I h
    
        % Registro canal rojo
        red=tic;
            desp_Rojo=registraImagen(G,R,vent_ini);
        tiempo_rojo(j,i-offset+1)=toc(red);
    
        % Registro canal azul
        blue=tic;
            desp_Azul=registraImagen(G,B,vent_ini);
        tiempo_azul(j,i-offset+1)=toc(blue);
    
        % Montado de la imagen final
        Ifinal=ones(size(R,1),size(R,2),3);
        Rr=zeros(size(R,1),size(R,2));
        Br=zeros(size(B,1),size(B,2));
    
        dy=desp_Rojo(1);
        dx=desp_Rojo(2);
        Rr(max(1,1+dy):min(end,end+dy),max(1,1+dx):min(end,end+dx))=R(max(1,1-dy):min(end,end-dy),max(1,1-dx):min(end,end-dx));

        dy=desp_Azul(1);
        dx=desp_Azul(2);
        Br(max(1,1+dy):min(end,end+dy),max(1,1+dx):min(end,end+dx))=B(max(1,1-dy):min(end,end-dy),max(1,1-dx):min(end,end-dx));
    
        Ifinal(:,:,1)=Rr;
        Ifinal(:,:,2)=G;
        Ifinal(:,:,3)=Br;
    
        % Recorte de los bordes
        cut=tic;
            [corteY,corteX]=recortarBordes(Ifinal);
        tiempo_corte(j,i-offset+1)=toc(cut);
    
        Irecortada=Ifinal(corteY(1):end-corteY(2),corteX(1):end-corteX(2),:);
    
        clear Ifinal
    
    % Ecualización
    if ecualizacion==1
        ecu=tic;
            Irecortada=imadjust(Irecortada,stretchlim(Irecortada),[]);
        tiempo_ecu(j,i-offset+1)=toc(ecu);
    end
    
    
        tiempo_total(j,i-offset+1)=toc(total);
    
        %disp(['Procesada la imagen ' f{i}]);
    end

    disp(['Completada iteración ' num2str(j)])

end

% Muestra de resultados
if seleccion==0
    texto='pequeñas';
elseif seleccion==1
    texto='grandes';
end

% Tiempos medios
trojo_medio=mean(mean(tiempo_rojo));
tazul_medio=mean(mean(tiempo_azul));
tcut_medio=mean(mean(tiempo_corte));
tecu_medio=mean(mean(tiempo_ecu));
ttotal_medio=mean(mean(tiempo_total));

% Muestra de los resultados finales
disp(' ')
disp(['Se han procesado las imágenes ' texto])
disp('Tiempos medios:')
disp(['Alineado canal rojo: ' num2str(trojo_medio)])
disp(['Alineado canal azul: ' num2str(tazul_medio)])
disp(['Cortado de bordes  : ' num2str(tcut_medio)])
disp(['Ecualización       : ' num2str(tecu_medio)])
disp(['Tiempo total       : ' num2str(ttotal_medio)])





