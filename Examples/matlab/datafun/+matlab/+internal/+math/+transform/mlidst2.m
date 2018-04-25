function f = mlidst2(x, varargin)
%MLIDST2   Two-dimensional inverse discrete sine transform.
%   FOR INTERNAL USE ONLY -- This is a non-shipping, internal prototype.
%   The behavior of this feature is subject to change or the feature may be
%   removed.
%
%   MLIDST2(X) returns the two-dimensional inverse discrete sine transform
%   (DST) of matrix X. If X is a vector, the result will have the same
%   orientation.
%
%   MLIDST2(X,MROWS,NCOLS) pads the matrix X with zeros to size
%   MROWS-by-NCOLS before transforming.
%
%   MLIDST2(...,'Variant',VARIANT) specifies which variant of the inverse
%   discrete sine transform to compute. VARIANT can be one of the following
%   integer values:
%
%       1 - specifies the inverse DST-I transform, which is the DST-I
%           transform scaled by 1/((2*MROWS+1)*(2*NCOLS+1)).
%
%       2 - (default) specifies the inverse DST-II transform, which is the
%           DST-III transform scaled by 1/(2*MROWS*NCOLS).
%
%       3 - specifies the inverse DST-III transform, which is the DST-II
%           transform scaled by 1/(2*MROWS*NCOLS).
%
%       4 - specifies the inverse DST-IV transform, which is the DST-IV
%           transform scaled by 1/(2*MROWS*NCOLS).
%
%   See also MLDST2, MLIDCT2, FFT2
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
            dstArgs = [ { [varargin{1:2}] }, varargin(3:end) ];
        elseif ischar(varargin{1})
            dstArgs = [ { [size(x,1), size(x,2)] }, varargin ];
        else
            if ~(isnumeric(varargin{2}) || islogical(varargin{2}))
                error(message('MATLAB:dcstfcn:invalidSyntax'));
            end
            dstArgs = { [varargin{:}] };
        end
    else
        dstArgs = { [size(x,1), size(x,2)], 'Variant', 2 };
    end
  
    if ismatrix(x)
        f = matlab.internal.math.transform.mlidstn(x, dstArgs{:});
    else
        f = matlab.internal.math.transform.mlidst(...
                matlab.internal.math.transform.mlidst(x,...
                    dstArgs{1}(2), 2, dstArgs{2:end}),...
                dstArgs{1}(1), 1, dstArgs{2:end});
    end   

end