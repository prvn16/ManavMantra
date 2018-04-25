function f = mldst2(x, varargin)
%MLDST2   Two-dimensional discrete sine transform.
%   FOR INTERNAL USE ONLY -- This is a non-shipping, internal prototype.
%   The behavior of this feature is subject to change or the feature may be
%   removed.
%
%   MLDST2(X) returns the two-dimensional discrete sine transform (DST) of
%   matrix X. If X is a vector, the result will have the same orientation.
%
%   MLDST2(X,MROWS,NCOLS) pads the matrix X with zeros to size
%   MROWS-by-NCOLS before transforming.
%
%   MLDST2(...,'Variant',VARIANT) specifies which variant of the discrete
%   sine transform to compute. VARIANT can be one of the following integer
%   values:
%
%       1 - specifies the DST-I transform. The inverse DST-I transform
%           (computed by mlidst2) is the DST-I transform scaled by
%           1/((2*MROWS+1)*(2*NCOLS+1)).
%
%       2 - (default) specifies the DST-II transform. The inverse DST-II
%           transform (computed by mlidst2) is the DST-III transform
%           scaled by 1/(2*MROWS*NCOLS).
%
%       3 - specifies the DST-III transform. The inverse DST-III transform
%           (computed by mlidst2) is the DST-II transform scaled by
%           1/(2*MROWS*NCOLS).
%
%       4 - specifies the DST-IV transform. The inverse DST-IV transform
%           (computed by mlidst2) is the DST-IV transform scaled by
%           1/(2*MROWS*NCOLS).
%
%   See also MLIDST2, MLDCT2, FFT2
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
        f = matlab.internal.math.transform.mldstn(x, dstArgs{:});
    else
        f = matlab.internal.math.transform.mldst(...
                matlab.internal.math.transform.mldst(x, ...
                    dstArgs{1}(2), 2, dstArgs{2:end}),...
                dstArgs{1}(1), 1, dstArgs{2:end});
    end   

end