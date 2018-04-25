function b = padarray(varargin)
%PADARRAY Pad array.
%   B = PADARRAY(A,PADSIZE) pads array A with PADSIZE(k) number of zeros
%   along the k-th dimension of A.  PADSIZE should be a vector of
%   nonnegative integers.
%
%   B = PADARRAY(A,PADSIZE,PADVAL) pads array A with PADVAL (a scalar)
%   instead of with zeros.
%
%   B = PADARRAY(A,PADSIZE,PADVAL,DIRECTION) pads A in the direction
%   specified by DIRECTION. DIRECTION can be one of the following:
%
%       String or character vector values for DIRECTION
%       'pre'         Pads before the first array element along each
%                     dimension .
%       'post'        Pads after the last array element along each
%                     dimension.
%       'both'        Pads before the first array element and after the
%                     last array element along each dimension.
%
%   By default, DIRECTION is 'both'.
%
%   B = PADARRAY(A,PADSIZE,METHOD,DIRECTION) pads array A using the
%   specified METHOD.  METHOD can be one of the following:
%
%       String or character vector values for METHOD
%       'circular'    Pads with circular repetition of elements.
%       'replicate'   Repeats border elements of A.
%       'symmetric'   Pads array with mirror reflections of itself.
%
%   Class Support
%   -------------
%   When padding with a constant value, A can be numeric or logical.
%   When padding using the 'circular', 'replicate', or 'symmetric'
%   methods, A can be of any class.  B is of the same class as A.
%
%   Example
%   -------
%   Add three elements of padding to the beginning of a vector.  The
%   padding elements contain mirror copies of the array.
%
%       b = padarray([1 2 3 4],3,'symmetric','pre')
%
%   Add three elements of padding to the end of the first dimension of
%   the array and two elements of padding to the end of the second
%   dimension.  Use the value of the last array element as the padding
%   value.
%
%       B = padarray([1 2; 3 4],[3 2],'replicate','post')
%
%   Add three elements of padding to each dimension of a
%   three-dimensional array.  Each pad element contains the value 0.
%
%       A = [1 2; 3 4];
%       B = [5 6; 7 8];
%       C = cat(3,A,B)
%       D = padarray(C,[3 3],0,'both')
%
%   See also CIRCSHIFT, IMFILTER.

%   Copyright 1993-2017 The MathWorks, Inc.

args = matlab.images.internal.stringToChar(varargin);
[a, method, padSize, padVal, direction] = ParseInputs(args{:});

b = padarray_algo(a, padSize, method, padVal, direction);

%%%
%%% ParseInputs
%%%
function [a, method, padSize, padVal, direction] = ParseInputs(varargin)

narginchk(2,4);

% fixed syntax args
a         = varargin{1};
padSize   = varargin{2};

% default values
method    = 'constant';
padVal    = 0;
direction = 'both';

validateattributes(padSize, {'double'}, {'real' 'vector' 'nonnan' 'nonnegative' ...
    'integer'}, mfilename, 'PADSIZE', 2);

% Preprocess the padding size
if (numel(padSize) < ndims(a))
    padSize           = padSize(:);
    padSize(ndims(a)) = 0;
end

if nargin > 2
    
    firstStringToProcess = 3;
    
    if ~ischar(varargin{3})
        % Third input must be pad value.
        padVal = varargin{3};
        validateattributes(padVal, {'numeric' 'logical'}, {'scalar'}, ...
            mfilename, 'PADVAL', 3);
        
        firstStringToProcess = 4;
        
    end
    
    for k = firstStringToProcess:nargin
        validStrings = {'circular' 'replicate' 'symmetric' 'pre' ...
            'post' 'both'};
        string = validatestring(varargin{k}, validStrings, mfilename, ...
            'METHOD or DIRECTION', k);
        switch string
            case {'circular' 'replicate' 'symmetric'}
                method = string;
                
            case {'pre' 'post' 'both'}
                direction = string;
                
            otherwise
                error(message('images:padarray:unexpectedError'))
        end
    end
end

% Check the input array type
if strcmp(method,'constant') && ~(isnumeric(a) || islogical(a))
    error(message('images:padarray:badTypeForConstantPadding'))
end
