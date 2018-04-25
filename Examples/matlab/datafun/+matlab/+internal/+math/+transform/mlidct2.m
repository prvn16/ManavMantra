function f = mlidct2(x, varargin)
%MLIDCT2   Two-dimensional inverse discrete cosine transform.
%   FOR INTERNAL USE ONLY -- This is a non-shipping, internal prototype.
%   The behavior of this feature is subject to change or the feature may be
%   removed.
%
%   MLIDCT2(X) returns the two-dimensional inverse discrete cosine
%   transform (DCT) of matrix X. If X is a vector, the result will have the
%   same orientation.
%
%   MLIDCT2(X,MROWS,NCOLS) pads the matrix X with zeros to size
%   MROWS-by-NCOLS before transforming.
%
%   MLIDCT2(...,'Variant',VARIANT) specifies which variant of the inverse
%   discrete cosine transform to compute. VARIANT can be one of the
%   following integer values:
%
%       1 - specifies the inverse DCT-I transform, which is the DCT-I
%           transform scaled by 1/((2*MROWS-1)*(2*NCOLS-1)).
%
%           The inverse DCT-I transform is not mathematically defined when 
%           either MROWS or NCOLS is equal to 1.
%
%       2 - (default) specifies the inverse DCT-II transform, which is the
%           DCT-III transform scaled by 1/(2*MROWS*NCOLS).
%
%       3 - specifies the inverse DCT-III transform, which is the DCT-II
%           transform scaled by 1/(2*MROWS*NCOLS).
%
%       4 - specifies the inverse DCT-IV transform, which is the DCT-IV
%           transform scaled by 1/(2*MROWS*NCOLS).
%
%   See also MLDCT2, MLIDST2, FFT2
%   

% Copyright 2016 The MathWorks, Inc.

    if nargin > 1
        if nargin == 2
            error(message('MATLAB:dcstfcn:invalidSyntax'));
        elseif (nargin == 4)
            error(message('MATLAB:dcstfcn:InvalidVariantValue'));
        elseif (nargin > 5)
            error(message('MATLAB:maxrhs'));
        end
        if nargin == 5
            dctArgs = [ { [varargin{1:2}] }, varargin(3:end) ];
        elseif ischar(varargin{1})
            dctArgs = [ { [size(x,1), size(x,2)] }, varargin ];
        else
            if ~(isnumeric(varargin{2}) || islogical(varargin{2}))
                error(message('MATLAB:dcstfcn:invalidSyntax'));
            end
            dctArgs = { [varargin{:}] };
        end
    else
        dctArgs = { [size(x,1), size(x,2)], 'Variant', 2 };
    end
  
    if ismatrix(x)
        f = matlab.internal.math.transform.mlidctn(x, dctArgs{:});
    else
        f = matlab.internal.math.transform.mlidct(...
                matlab.internal.math.transform.mlidct(x, ...
                    dctArgs{1}(2), 2, dctArgs{2:end}),...
                dctArgs{1}(1), 1, dctArgs{2:end});
    end   

end