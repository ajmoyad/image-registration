function [corteY,corteX]=recortarBordes(Iin)
% RECORTARBORDES Calcula los �ndices para el recorte de los bordes negros
% de una imagen.
%    [corteY,corteX]=recortarBordes(Iin) toma la imagen Iin y le calcula,
%    de forma eficiente, los �ndices para el recorte de sus bordes tanto en
%    el eje y, corteY, como en el eje x, corteX
%
%   Antonio J. Moya D�az
%   4 de Junio de 2013
%   Laboratorio Multimedia, Universidad de Granada


% La idea general ser� usar histogramas laterales (es decir, suma de los
% valores de filas y columnas) para detectar d�nde est�n los bordes. Con el
% fin de hacer el proceso eficiente, adem�s de redimensionar la imagen,
% tomaremos solo un trozo de �sta. Dicho trozo debe ser lo suficientemente
% grande como para que el histograma sea significativo, por lo que vamos a
% tener hacer una diferencia en las dimensiones de ese recorte. 
%   Veamos mejor con un ejemplo. Supongamos que quiero hacer un corte
%   vertical, por lo que calcular� su histograma vertical. Dicho histograma
%   deber�a coger una porci�n cercana al borde, para los elementos de la
%   imagen nos afecten lo m�nimo al histograma. En cambio, en la direcci�n
%   horizontal debemos coger un conjunto significativo para el histograma.
% Por ello diferenciamos estas dos dimensiones como se ve m�s adelante en
% este c�digo.


    % Redimensionamos la imagen de entrada a un cuarto de su tama�o.
    I=imresize(Iin,1/4);
    
    % Factor de correcci�n. Los �ndices calculados ser�n 1/4 de los �ndices
    % reales, no obstante se usa un factor mayor que 4 ya que el c�lculo de
    % los bordes es una medida, en gran medida, aproximada y ser� mejor
    % cortar un poco m�s si queremos olvidarnos de esos bordes molestos.
    cc=5.5;
    
    % Vectores que contendran los �ndices de salida. 
    corteY=[1 1];
    corteX=[1 1];

    % Creamos los valores para las ventanas
    [f,c]=size(I(:,:,1));
    
    % Ventana de corte en eje X
    ventX0=round(c/4);
    ventXf=round(c*3/4);
    
    % Ventana de corte en eje Y
    ventY0=round(f/4);
    ventYf=round(f*3/4);
    
    % Margen para el histograma
    corte_f=round(f*0.05);
    corte_c=round(c*0.05);
    
    % Ventanas de recorte  
    v_arriba    =1-I(1:corte_f,ventX0:ventXf,:);
    v_abajo     =1-I(end-corte_f:end,ventX0:ventXf,:);
    v_derecha   =1-I(ventY0:ventYf,end-corte_c:end,:);
    v_izquierda =1-I(ventY0:ventYf,1:corte_c,:); 
    
    
    for i=1:1:3 % Iteramos una vez por banda de color
                
        % Histogramas
        h_arriba    =sum(v_arriba(:,:,i)');
        h_abajo     =sum(v_abajo(:,:,i)');
        h_derecha   =sum(v_derecha(:,:,i));
        h_izquierda =sum(v_izquierda(:,:,i));
        
        % Umbrales / Los definimos para ver qu� valores del histograma
        % consideraremos como nuestros �ndices de corte
        umbral_h=(3/4)*max(max(h_derecha),max(h_izquierda));
        umbral_v=(3/4)*max(max(h_abajo),max(h_arriba));
        
        % Candidatos a corte, en orden [arriba abajo izquierda derecha]
        cortes=[0 0 0 0];
        
        % Buscamos los �ndices que superan el umbral
        ind=find(h_arriba>umbral_v);
        if ~isempty(ind)
            % Si hemos encontrado valores por encima del umbral, los
            % asignamos.
            cortes(1)=ind(end);
        end
        
        % Los siguientes son iguales
        ind=find(h_abajo>umbral_v);
        if ~isempty(ind)
            cortes(2)=length(h_abajo)-ind(1);
        end
        
        ind=find(h_izquierda>umbral_h);
        if ~isempty(ind)
            cortes(3)=ind(end);
        end
        
        ind=find(h_derecha>umbral_h);
        if ~isempty(ind)
            cortes(4)=length(h_derecha)-ind(1);
        end
 
% Notar que en cada caso buscamos un �ndice que, en realidad, lo que
% marcar� ser� la separaci�n de �ste con el borde 'fisico' de la imagen,
% por tanto en los histogramas arriba e izquierda nos bastar� con tomar el
% �ndice sin m�s. Sin embargo en los histogramas derecha y abajo, deberemos
% tener en cuenta que find nos devolver� la posici�n dentro de la ventana,
% pero nosostros queremos en realidad su separaci�n con el l�mite, por lo
% que hay que invertirlos.

        % En cada iteraci�n nos quedaremos con los valores m�s grandes.
        corteY(1)=max(corteY(1),cortes(1));
        corteY(2)=max(corteY(2),cortes(2));
        corteX(1)=max(corteX(1),cortes(3));
        corteX(2)=max(corteX(2),cortes(4));
            
    end
       
    % Finalmente preparamos la salida multiplicando por el factor de
    % correcci�n que definimos al principio.
    corteY=ceil(cc.*corteY);
    corteX=ceil(cc.*corteX);
    
    
end