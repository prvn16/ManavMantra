function f = mldct2(x, varargin)
%MLDCT2   Two-dimensional discrete cosine transform.
%   FOR INTERNAL USE ONLY -- This is a non-shipping, internal prototype.
%   The behavior of this feature is subject to change or the feature may be
%   removed.
%
%   MLDCT2(X) returns the two-dimensional discrete cosine transform (DCT)
%   of matrix X. If X is a vector, the result will have the same
%   orientation.
%
%   MLDCT2(X,MROWS,NCOLS) pads the matrix X with zeros to size
%   MROWS-by-NCOLS before transforming.
%
%   MLDCT2(...,'Variant',VARIANT) specifies which variant of the discrete
%   cosine transform to compute. VARIANT can be one of the following
%   integer values:
%
%       1 - specifies the DCT-I transform. The inverse DCT-I transform
%           (computed by mlidct2) is the DCT-I transform scaled by
%           1/((2*MROWS-1)*(2*NCOLS-1)).
%
%           The DCT-I transform is not mathematically defined when either 
%           MROWS or NCOLS is equal to 1.
%
%       2 - (default) specifies the DCT-II transform. The inverse DCT-II
%           transform (computed by mlidct2) is the DCT-III transform
%           scaled by 1/(2*MROWS*NCOLS).
%
%       3 - specifies the DCT-III transform. The inverse DCT-III transform
%           (computed by mlidct2) is the DCT-II transform scaled by
%           1/(2*MROWS*NCOLS).
%
%       4 - specifies the DCT-IV transform. The inverse DCT-IV transform
%           (computed by mlidct2) is the DCT-IV transform scaled by
%           1/(2*MROWS*NCOLS).
%
%   See also MLIDCT2, MLDST2, FFT2
%   

% Copyright 2016 The MathWorks, Inc.

    if nargin > 1
        if nargin == 2
            % TODO: Switch to dcst2 message
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
        f = matlab.internal.math.transform.mldctn(x, dctArgs{:});
    else
        f = matlab.internal.math.transform.mldct(...
                matlab.internal.math.transform.mldct(x, ...
                    dctArgs{1}(2), 2, dctArgs{2:end}),...
                dctArgs{1}(1), 1, dctArgs{2:end});
    end   

end