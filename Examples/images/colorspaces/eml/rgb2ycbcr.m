function ycbcr = rgb2ycbcr(X) %#codegen

% Copyright 2013-2016 The MathWorks, Inc.

%#ok<*EMCA>

if (numel(size(X))==2)
    % For backward compatibility, this function handles uint8 and uint16
    % colormaps. This usage will be removed in a future release.

    validateattributes(X, ...
        {'uint8','uint16','single','double'}, ...
        {'nonempty'}, ...
        mfilename, 'MAP', 1); 
    coder.internal.errorIf((size(X,2) ~= 3 || size(X,1) < 1), ...
        'images:rgb2ycbcr:invalidSizeForColormap');
    
    if ~isfloat(X)
        eml_warning('images:rgb2ycbcr:notAValidColormap');
        rgb = im2double(X);
    else
        rgb = X;
    end
    
elseif (numel(size(X)) == 3)
    validateattributes(X, ...
        {'uint8','uint16','single','double'}, ...
        {}, mfilename, 'RGB', 1);
    coder.internal.errorIf((size(X,3) ~= 3), ...
        'images:rgb2ycbcr:invalidTruecolorImage');
    rgb = X;
else
    coder.internal.errorIf(true, 'images:rgb2ycbcr:invalidInputSize');
end

origT      = [65.481 128.553 24.966;...
             -37.797 -74.203 112; ...
             112 -93.786 -18.214];
origOffset = [16; 128; 128];

scaleFactor.float.T       = 1/255;      % scale output so in range [0 1].
scaleFactor.float.offset  = 1/255;      % scale output so in range [0 1].
scaleFactor.uint8.T       = 1/255;      % scale input so in range [0 1].
scaleFactor.uint8.offset  = 1;          % output is already in range [0 255].
scaleFactor.uint16.T      = 257/65535;  % scale input so it is in range [0 1]
% and scale output so it is in range
% [0 65535] (255*257 = 65535).
scaleFactor.uint16.offset = 257;        % scale output so it is in range [0 65535].

if isfloat(rgb)
    classIn = 'float';
else
    classIn = class(rgb);
end
T      = scaleFactor.(classIn).T * origT;
offset = scaleFactor.(classIn).offset * origOffset;
ycbcr  = coder.nullcopy(zeros(size(rgb), 'like', rgb));

if (numel(size(rgb)) == 2)
    % Colormap
    R = rgb(:,1);
    G = rgb(:,2);
    B = rgb(:,3);
    for p = 1:3
        ycbcr(:,p) = imlincomb(T(p,1),R,T(p,2),G,T(p,3),B,offset(p));
    end
else
    R = rgb(:,:,1);
    G = rgb(:,:,2);
    B = rgb(:,:,3);
    for p = 1:3
        ycbcr(:,:,p) = imlincomb(T(p,1),R,T(p,2),G,T(p,3),B,offset(p));
    end
end
