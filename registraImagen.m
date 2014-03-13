function vector_despl=registraImagen(IB,IR,varargin)
% REGISTRAIMAGEN Calcula el vector de desplazamiento entre 2 imágenes.
%   vector_despl=registraImagen(IB,IR,VI) Calcula el vector de
%   desplazamiento entre una imagen tomada como base, IB, y una imagen 'a
%   registrar' IR, usado una ventana inicial de tamaño 2xVI. VI puede ser 
%   un valor entero, en cuyo caso la ventana inicial será cuadrada, o un
%   vector que defina una ventana por alto y ancho.
%
%   Antonio J. Moya Díaz
%   5 de Junio de 2013
%   Laboratorio Multimedia, Universidad de Granada


    % Control de parámetros de entrada y ventana inicial
    if isempty(varargin)
        error('Error: No se ha especificado tamaño de ventana inicial');
    % dy=8;%Imagenes pequeñas
    % dx=8;%Imagenes pequeñas
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
        
       
    % Niveles de profundidad de la pirámide
    nivel=[4 2 1];
    n_niveles=length(nivel);


    for i=1:1:n_niveles
       
        % Ventana del nivel. Imponemos un tamaño mínimo de 10.
        venty=max(10,2*abs(dy));
        ventx=max(10,2*abs(dx));
        
        % Redimensionado de las imágenes dependiente del nivel.
        Bn=imresize(IB,1/nivel(i));
        Rn=imresize(IR,1/nivel(i));
        
        % Centro de la imagen redimensionada
        cy=floor(size(Bn,1)/2);
        cx=floor(size(Bn,2)/2);
        
        % Recorte. Conviene que A sea mayor que temp, por eso el x2. Notar
        % que el recorte final es 2 veces el tamaño de la variable definida
        % como 'ventana'.
        temp=Rn(cy-venty:cy+venty,cx-ventx:cx+ventx);
        A=Bn(cy-2*venty:cy+2*venty,cx-2*ventx:cx+2*ventx);
        
        
        % Correlación normalizada.
        %   La correlación será una imagen de tamaño size(temp)+size(A).
        %   Vamos a calcular el vector de desplazamiento como la diferencia
        %   entre el máximo obtenido y el centro de la imagen de
        %   correlación. Esto supone un par de problemas o limitaciones:
        %   a) Conviente que la imagen de correlación sea impar en sus 2
        %       dimensiones para poder determinar un centro de forma
        %       unívoca. Esto se consigue cuando las imágenes de entrada,
        %       sus dimensiones tienen la misma paridad dos a dos.
        %   b) Esta dimensión de la correlación podría darnos
        %       desplazamientos mayores de los que, sobre el papel (que no
        %       numéricamente) limitaría el tamaño de nuestra ventana. Es
        %       por ello que si no controlamos ese defecto podemos tener
        %       errores en el cálculo. Así pues acotamos la correlación a
        %       un tamaño que permita como máximo, el máximo desplazamiento
        %       que admite la ventana.
        correlacion=normxcorr2(temp,A);
        
        % Centro de la correlación
        ky=round(size(correlacion,1)/2);
        kx=round(size(correlacion,2)/2);
        
        % NCC de Normalized CrossCorrelation será la variable que contendrá
        % nuestra correlación ya acotada.
        ncc=zeros(size(correlacion));
        % Acotamos
        ncc(ky-venty:ky+venty,kx-ventx:kx+ventx)=correlacion(ky-venty:ky+venty,kx-ventx:kx+ventx);

        
        % Extracción del máximo de la correlación
        [mx,posmx]=max(ncc);
        [~,i2]=max(mx);
        % mx será el máximo de cada fila, por tanto el máximo de éste será
        % el máximo de toda la matriz. Por tanto la posición posmax del
        % máximo de cada fila, será la fila donde esté ese máximo, es decir
        % su valor Y. La posición del máximo de mx en el vector mx será el
        % valor de la columna.
        % Resumiento, el máximo estará localizado en la 
        % posición [posmax(i2), i2]
        
        % Extracción del centro de la correlación
        offsety=round(size(ncc,1)/2);
        offsetx=round(size(ncc,2)/2);
    
        % Vector de desplazamiento [dy dx]
        dy=posmx(i2)-offsety;
        dx=i2-offsetx;
        
    end

    % Vector de desplazamiento final
    vector_despl=[dy dx]; 


end