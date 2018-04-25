function rgb = ycbcr2rgb(X) %#codegen

% Copyright 2013-2016 The MathWorks, Inc.

%#ok<*EMCA>

if (numel(size(X)) == 2)
    validateattributes(X, ...
        {'uint8','uint16','single','double'}, ...
        {'real','nonempty'}, ...
        mfilename, 'MAP', 1); 
    coder.internal.errorIf((size(X,2) ~= 3 || size(X,1) < 1), ...
        'images:ycbcr2rgb:invalidSizeForColormap');
    ycbcr = X;
elseif (numel(size(X)) == 3)
    validateattributes(X, ...
        {'uint8','uint16','single','double'}, ...
        {'real'}, mfilename, 'YCBCR', 1);
    coder.internal.errorIf((size(X,3) ~= 3), ...
        'images:ycbcr2rgb:invalidTruecolorImage');
    ycbcr = X;
else
    coder.internal.errorIf(true, 'images:ycbcr2rgb:invalidInputSize');
end

T = [65.481 128.553 24.966;...
    -37.797 -74.203 112; ...
    112 -93.786 -18.214];

Tinv = T^-1;
offset = [16;128;128];

scaleFactor.float.T = 255;        % scale input so it is in range [0 255].
scaleFactor.float.offset = 1;     % output already in range [0 1].
scaleFactor.uint8.T = 255;        % scale output so it is in range [0 255].
scaleFactor.uint8.offset = 255;   % scale output so it is in range [0 255].
scaleFactor.uint16.T = 65535/257; % scale input so it is in range [0 255]
% (65535/257 = 255),
% and scale output so it is in range
% [0 65535].
scaleFactor.uint16.offset = 65535; % scale output so it is in range [0 65535].

if isfloat(ycbcr)
    classIn = 'float';
else
    classIn = class(ycbcr);
end
T      = scaleFactor.(classIn).T * Tinv;
offset = scaleFactor.(classIn).offset * Tinv * offset;
rgb    = coder.nullcopy(zeros(size(ycbcr), 'like', ycbcr));

if (numel(size(ycbcr)) == 2)
    % Colormap
    Y  = ycbcr(:,1);
    Cb = ycbcr(:,2);
    Cr = ycbcr(:,3);
    for p = 1:3
        rgb(:,p) = imlincomb(T(p,1),Y,T(p,2),Cb,T(p,3),Cr,-offset(p));
    end
else
    Y  = ycbcr(:,:,1);
    Cb = ycbcr(:,:,2);
    Cr = ycbcr(:,:,3);
    for p = 1:3
        rgb(:,:,p) = imlincomb(T(p,1),Y,T(p,2),Cb,T(p,3),Cr,-offset(p));
    end
end

if isfloat(rgb)
    rgb = min(max(rgb,0),1);
end
