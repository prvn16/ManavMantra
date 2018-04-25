function u = im2uint8(img, varargin) %#codegen
% Copyright 2013-2015 The MathWorks, Inc.

%#ok<*EMCA>

narginchk(1,2);
coder.internal.prefer_const(img, varargin);

validateattributes(img,{'double','logical','uint8','uint16','single','int16'}, ...
    {'nonsparse'},mfilename,'Image',1);

if(~isreal(img))
    eml_warning('images:im2uint8:ignoringImaginaryPartOfInput');
    I = real(img);
else
    I = img;
end

if nargin == 2
    validateIndexedImages(I, varargin{1});
end

% Number of threads (obtained at compile time)
singleThread = images.internal.coder.useSingleThread();

% Shared library
coder.extrinsic('images.internal.coder.useSharedLibrary');
useSharedLibrary = coder.const(images.internal.coder.isCodegenForHost()) && ...
    coder.const(images.internal.coder.useSharedLibrary()) && ...
    coder.const(~singleThread);

if isa(I, 'uint8')
    u = I;
elseif isa(I, 'logical')
    u = uint8(I.*255);
else %double, single, uint16, or int16
    if nargin == 1
        if (useSharedLibrary)
            u = uint8SharedLibraryAlgo(I);
        else
            u = uint8PortableCodeAlgo(I);
        end        
    else %indexed images
        if (isa(I, 'uint16') )
            u = uint8(I);
        else  %double or empty
            u = uint8(I-1);
        end
    end
end

end

function u = uint8PortableCodeAlgo(I)
%% Portable Code
coder.inline('always');
coder.internal.prefer_const(I);
switch (class(I))
    case 'int16'
        v = uint16(int32(I)+int32(32768));
        u = uint8(double(v)*1/257);
    case 'uint16'
        u = uint8(double(I)*1/257);
    case {'double','single'}
        if(isempty(I))
            u = uint8(I);
        else
            maxVal = cast(intmax('uint8'),'like',I);
            u = coder.nullcopy(uint8(I));
            for index = 1:numel(I)
                val = I(index) * maxVal;
                if val < 0
                    u(index) = uint8(0);
                elseif val > maxVal
                    u(index) = uint8(maxVal);
                else
                    u(index) = eml_cast(val+0.5,'uint8','to zero','spill');
                end
            end
        end
    otherwise
        assert('Unknown class');
end
end


function u = uint8SharedLibraryAlgo(I)
%% Shared Library
coder.inline('always');
coder.internal.prefer_const(I);
if isa(I, 'int16')
    v = int16touint16(I);
    u = grayto8(v);
else
    u = grayto8(I);
end
end

function validateIndexedImages(I, indexOption)
%% Indexed Image Validation
coder.inline('always');
coder.internal.prefer_const(I, indexOption);
validatestring( indexOption,{'indexed'},mfilename,'type',2);
coder.internal.errorIf(isa(I, 'int16'), ...
    'images:im2uint8:invalidIndexedImage');
maxVal = max(I(:));
minVal = min(I(:));
if (isa(I, 'uint16') )
    coder.internal.errorIf((maxVal > 255), ...
        'images:im2uint8:tooManyColorsFor8bitStorage');
end
if (isa(I, 'float') && ~(isempty(I)))
    coder.internal.errorIf((maxVal >= 257), ...
        'images:im2uint8:tooManyColorsFor8bitStorage');
    coder.internal.errorIf((minVal < 1), ...
        'images:im2uint8:invalidIndexValue');
end
end