function vector_despl=registraImagen(IB,IR,varargin)
% REGISTRAIMAGEN Calcula el vector de desplazamiento entre 2 im�genes.
%   vector_despl=registraImagen(IB,IR,VI) Calcula el vector de
%   desplazamiento entre una imagen tomada como base, IB, y una imagen 'a
%   registrar' IR, usado una ventana inicial de tama�o 2xVI. VI puede ser 
%   un valor entero, en cuyo caso la ventana inicial ser� cuadrada, o un
%   vector que defina una ventana por alto y ancho.
%
%   Antonio J. Moya D�az
%   5 de Junio de 2013
%   Laboratorio Multimedia, Universidad de Granada


    % Control de par�metros de entrada y ventana inicial
    if isempty(varargin)
        error('Error: No se ha especificado tama�o de ventana inicial');
    % dy=8;%Imagenes peque�as
    % dx=8;%Imagenes peque�as
    % dy=20;%Imagenes grandes
    % dx=20;%Imagenes grandes       
        
    elseif size(varargin,1)==1
        % Ventana cuadrada
        dy=varargin{1};
        dx=dy;
    elseif size(varargin,1)==2
        % Ventana rectangular
        dy=varargin{1};
        dx=varargin{2};
    end
        
       
    % Niveles de profundidad de la pir�mide
    nivel=[4 2 1];
    n_niveles=length(nivel);


    for i=1:1:n_niveles
       
        % Ventana del nivel. Imponemos un tama�o m�nimo de 10.
        venty=max(10,2*abs(dy));
        ventx=max(10,2*abs(dx));
        
        % Redimensionado de las im�genes dependiente del nivel.
        Bn=imresize(IB,1/nivel(i));
        Rn=imresize(IR,1/nivel(i));
        
        % Centro de la imagen redimensionada
        cy=floor(size(Bn,1)/2);
        cx=floor(size(Bn,2)/2);
        
        % Recorte. Conviene que A sea mayor que temp, por eso el x2. Notar
        % que el recorte final es 2 veces el tama�o de la variable definida
        % como 'ventana'.
        temp=Rn(cy-venty:cy+venty,cx-ventx:cx+ventx);
        A=Bn(cy-2*venty:cy+2*venty,cx-2*ventx:cx+2*ventx);
        
        
        % Correlaci�n normalizada.
        %   La correlaci�n ser� una imagen de tama�o size(temp)+size(A).
        %   Vamos a calcular el vector de desplazamiento como la diferencia
        %   entre el m�ximo obtenido y el centro de la imagen de
        %   correlaci�n. Esto supone un par de problemas o limitaciones:
        %   a) Conviente que la imagen de correlaci�n sea impar en sus 2
        %       dimensiones para poder determinar un centro de forma
        %       un�voca. Esto se consigue cuando las im�genes de entrada,
        %       sus dimensiones tienen la misma paridad dos a dos.
        %   b) Esta dimensi�n de la correlaci�n podr�a darnos
        %       desplazamientos mayores de los que, sobre el papel (que no
        %       num�ricamente) limitar�a el tama�o de nuestra ventana. Es
        %       por ello que si no controlamos ese defecto podemos tener
        %       errores en el c�lculo. As� pues acotamos la correlaci�n a
        %       un tama�o que permita como m�ximo, el m�ximo desplazamiento
        %       que admite la ventana.
        correlacion=normxcorr2(temp,A);
        
        % Centro de la correlaci�n
        ky=round(size(correlacion,1)/2);
        kx=round(size(correlacion,2)/2);
        
        % NCC de Normalized CrossCorrelation ser� la variable que contendr�
        % nuestra correlaci�n ya acotada.
        ncc=zeros(size(correlacion));
        % Acotamos
        ncc(ky-venty:ky+venty,kx-ventx:kx+ventx)=correlacion(ky-venty:ky+venty,kx-ventx:kx+ventx);

        
        % Extracci�n del m�ximo de la correlaci�n
        [mx,posmx]=max(ncc);
        [~,i2]=max(mx);
        % mx ser� el m�ximo de cada fila, por tanto el m�ximo de �ste ser�
        % el m�ximo de toda la matriz. Por tanto la posici�n posmax del
        % m�ximo de cada fila, ser� la fila donde est� ese m�ximo, es decir
        % su valor Y. La posici�n del m�ximo de mx en el vector mx ser� el
        % valor de la columna.
        % Resumiento, el m�ximo estar� localizado en la 
        % posici�n [posmax(i2), i2]
        
        % Extracci�n del centro de la correlaci�n
        offsety=round(size(ncc,1)/2);
        offsetx=round(size(ncc,2)/2);
    
        % Vector de desplazamiento [dy dx]
        dy=posmx(i2)-offsety;
        dx=i2-offsetx;
        
    end

    % Vector de desplazamiento final
    vector_despl=[dy dx]; 


end