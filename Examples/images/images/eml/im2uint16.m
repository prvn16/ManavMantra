function J = im2uint16(img, varargin) %#codegen

% Copyright 2013-2014 The MathWorks, Inc.

%#ok<*EMCA>

narginchk(1,2);
validateattributes(img,{'double','logical','uint8','uint16','int16','single'}, ...
              {'nonsparse'}, mfilename,'IMG', 1);
          
if(~isreal(img))
    eml_warning('images:im2uint16:ignoringImaginaryPartOfInput');
    I = real(img);
else
    I = img;
end

if nargin == 2
    validatestring(varargin{1}, {'indexed'}, mfilename, 'type', 2);
end

if isa(I, 'uint16')
    J = I;
elseif islogical(I)
    J = uint16(I.*65535);
elseif isa(I,'int16')
    eml_invariant(~((nargin > 1)), ...
        eml_message('images:im2uint16:invalidIndexedImage'));
    J = int16touint16(I);
else %double, single, or uint8
    if (nargin == 1)
        % intensity image 
        J = grayto16(I);
    else
        % indexed image
        if isempty(I)
            J = uint16(I);
        elseif isa(img, 'uint8')
            J = uint16(I);
        else
            % I is double or single
            maxVal = max(I(:));
            eml_invariant(~((maxVal >= 65537)), ...
                eml_message('images:im2uint16:tooManyColors'));
            minVal = min(I(:));
            eml_invariant(~((minVal < 1)), ...
                eml_message('images:im2uint16:invalidIndex'));
            J = uint16(I-1);
        end
    end
end
