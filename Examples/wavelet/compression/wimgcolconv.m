function varargout = wimgcolconv(option,X,T)
%WIMGCOLCONV Color Conversion.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-Nov-2007.
%   Last Revision: 28-Apr-2008.
%   Copyright 1995-2008 The MathWorks, Inc.

if nargin==1    
    % Return the Color Conversion IDX or NAME
    switch option
        case 0 , varargout{1} = 'rgb';
        case 1 , varargout{1} = 'yuv';
        case 2 , varargout{1} = 'klt';
        case 3 , varargout{1} = 'yiq';
        case 4 , varargout{1} = 'xyz';
        case 'rgb' , varargout{1} = 0;
        case 'yuv' , varargout{1} = 1;
        case 'klt' , varargout{1} = 2;
        case 'yiq' , varargout{1} = 3;
        case 'xyz' , varargout{1} = 4;
    end
    return
end


if isempty(X) , X = zeros(1,1,3); end  % dummy to get matrix transform
if (ndims(X)<3) || isequal(option,'rgb') || isequal(option,'invrgb')
    varargout = {X,[]}; return;
end

switch option
    case 'yuv' ,    option = 'rgb2yuv';
    case 'klt' ,    option = 'rgb2klt';
    case 'yiq' ,    option = 'rgb2yiq';
    case 'xyz' ,    option = 'rgb2xyz';
    case 'invyuv' , option = 'yuv2rgb';
    case 'invklt' , option = 'klt2rgb';
    case 'invyiq' , option = 'yiq2rgb';
    case 'invxyz' , option = 'xyz2rgb';
end

switch option
    case 'rgb2yuv_old'
        T = [...
            0.2500    0.5000    0.2500
            1.0000   -1.0000    0
            0         1.0000   -1.0000
            ];

    case 'yuv2rgb_old'
        T = [...
            1.0000    0.7500    0.2500
            1.0000   -0.2500    0.2500
            1.0000   -0.2500   -0.7500
            ];
        
    case 'rgb2yuv'
        T = [ ...
            0.2989    0.5870    0.1140
           -0.14713  -0.28886   0.4360
            0.6150   -0.51499  -0.10001
            ];
        
    case 'yuv2rgb'
        T = [ ...
            1.0001   -0.0000    1.1399
            1.0001   -0.3946   -0.5805
            1.0001    2.0321    0.0001
            ];               
        
    case 'rgb2klt'
        X = double(X);
        R = X(:,:,1); G = X(:,:,2); B = X(:,:,3);
        V  = [R(:) G(:) B(:)];
        M = mean(V);
        T = zeros(3,3);
        for i=1:3
            for j = 1:3
                T(i,j) = sum(V(:,i).*V(:,j)) -M(i)*M(j);
            end
        end
        [T,D] = eig(T); %#ok<NASGU>

    case 'klt2rgb'
        T = inv(T);

    case 'rgb2yiq'
        T = [ ...
            0.2989    0.5870    0.1140
            0.5959   -0.2744   -0.3216
            0.2115   -0.5229    0.3114
            ];

    case 'yiq2rgb'
        T = [ ...
            1   0.956   0.621  ; ...
            1  -0.272  -0.647  ; ...
            1  -1.106   1.703    ...
            ];

    case 'rgb2xyz'
        % T = [ ...
        %         0.166 0.125 0.093 ; ...
        %         0.060 0.327 0.005 ; ...
        %         0.000 0.004 0.460   ...
        %     ];
        T = [ ...
            0.412453  0.357580  0.180423 ;  ...
            0.212671  0.715160  0.072169 ;  ...
            0.019334  0.119193  0.950227    ...
            ];

    case 'xyz2rgb'
        % T = [ ...
        %         1.876 -0.533 -0.343 ; ...
        %        -0.967  1.998 -0.031 ; ...
        %         0.057 -0.118  1.061   ...
        %     ];
        T = [ ...
            3.240479 -1.537150 -0.498535 ; ...
            -0.969256  1.875992  0.041556 ; ...
            0.055648 -0.204043  1.057311   ...
            ];
end

switch option
    case {'rgb2yuv','yuv2rgb','rgb2klt','klt2rgb','rgb2yiq','yiq2rgb',...
          'rgb2xyz','xyz2rgb'} 
        Y = double(X);
        for k = 1:3
            X(:,:,k) = T(k,1)*Y(:,:,1)+T(k,2)*Y(:,:,2)+T(k,3)*Y(:,:,3);
        end
        
    case {'rgb2hsv'} , X = rgb_and_hsv('rgb2hsv',double(X));
    case {'hsv2rgb'} , X = rgb_and_hsv('hsv2rgb',X);
end
varargout = {X,T};


function X = rgb_and_hsv(option,X)

X = double(X);
I1 = X(:,:,1);
I2 = X(:,:,2);
I3 = X(:,:,3);
switch option
    case 'rgb2hsv' , OUT = rgb2hsv([I1(:),I2(:),I3(:)]);
    case 'hsv2rgb' , OUT = hsv2rgb([I1(:),I2(:),I3(:)]);
end
sZ = size(X);
for j=1:3
    X(:,:,j) = reshape( OUT(:,j),sZ(1),sZ(2));
end
