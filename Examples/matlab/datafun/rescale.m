function R = rescale(A, varargin)
%RESCALE   Rescales the range of data.
%   R = RESCALE(A) rescales all entries of an array A to [0,1].
% 
%   RESCALE(A,b,c) rescales all entries of A to the interval [b,c].
%
%   RESCALE(...,'InputMin',IMIN) sets the lower bound IMIN for the input 
%   range. Input values less than IMIN will be replaced with IMIN. The  
%   default is min(A(:)).
%
%   RESCALE(...,'InputMax',IMAX) sets the upper bound IMAX for the input 
%   range. Input values greater than IMAX will be replaced with IMAX. The 
%   default is max(A(:)).
%
%   Examples: 
%
%       % Rescale all entries of a vector to [0,1]
%       a = [1 2 3 4 5];
%       r = rescale(a)
%
%       % Clip all entries to [2,4] and then rescale all entries to [-1,1]
%       a = [1 2 3 4 5];
%       r = rescale(a,-1,1,'InputMin',2,'InputMax',4)
%
%       % Rescale each column of a matrix to the interval [0,1]
%       A = magic(3);
%       R = rescale(A,'InputMin',min(A),'InputMax',max(A))
%
%   See also MIN, MAX.
 
%   Copyright 2017 The MathWorks, Inc.

narginchk(1,inf);

% Process inputs
[A, a, b, inputMin, inputMax] = preprocessInputs(A, varargin{:});

% Quick return for empty inputs
if isempty(A)
    if ~isfloat(A)
        R = double(A);
    else
        R = A;
    end
    return;
end

% Regularize constant values to return lowerbound of output range
constReg = (inputMin == inputMax);

% Determine where to center the problem based on the input range 
sigma = max(min(0,inputMax),inputMin);
inputMin = inputMin - sigma;
inputMax = inputMax - sigma;

% Scale to prevent overflow/underflow
e1 = nextpow2(max(abs(inputMax), abs(inputMin)));
r1 = 2.^(e1-1);
e2 = nextpow2(max(abs(a),abs(b)));
r2 = 2.^(e2-1);
r3 = 2.^(fix((e1+e2)/2)-1);

z = ((inputMax./r1).*(a./r3) - (inputMin./r1).*(b./r3) + (a./r3).*(constReg./r1)) ...
    ./ ((inputMax./r1)-(inputMin./r1) + (constReg./r1));
slope = ((b./r2)-(a./r2))./((inputMax./r3)-(inputMin./r3) + (constReg./r3));
if ~isfloat(A)
    R = r2 .* (slope./r3 .* (double(A) - sigma) + (r3./r2).*z);
else
    R = r2 .* (slope./r3 .* (A - sigma) + (r3./r2).*z);
end

% Check to make sure the output is within the output range
R = max(R, a, 'includenan');
R = min(R, b, 'includenan');

end
%--------------------------------------------------------------------------
function [A, a, b, inputMin, inputMax] = preprocessInputs(A, varargin)
% Parse RESCALE inputs

% Process A
if ~(isnumeric(A) || islogical(A)) || ~isreal(A)
    error(message('MATLAB:rescale:InvalidA'));
end

% Set defaults
a = 0;
b = 1;
minFlag = false;
maxFlag = false;

ndimsA = ndims(A);
sizA = size(A);

if ~isempty(varargin)
    indStart = 1;
    
    % Parse output range
    if isnumeric(varargin{1}) || islogical(varargin{1})
        if 2 > length(varargin)
            error(message('MATLAB:rescale:RequiredThirdInput'));
        end
        a = varargin{1};
        b = varargin{2};
        if ~isnumeric(a) || ~isreal(a)
            error(message('MATLAB:rescale:InvalidOutputRange'));
        end
        if ~isnumeric(b) || ~isreal(b)
            if rem(length(varargin),2) ~= 0
                error(message('MATLAB:rescale:RequiredThirdInput'));
            else
                error(message('MATLAB:rescale:InvalidOutputRange'));
            end
        end
        if nnz(a > b) > 0
            error(message('MATLAB:rescale:OutMinGreaterThanOutMax'));
        end
        if (ndims(a) > ndimsA) || (isvector(A) && any(size(a) ~= sizA) && ~isscalar(a)) 
            error(message('MATLAB:rescale:NumberDimsOut'));
        end
        if (ndims(b) > ndimsA) || (isvector(A) && any(size(b) ~= sizA) && ~isscalar(b))
            error(message('MATLAB:rescale:NumberDimsOut'));
        end        
        if ~isfloat(a)
            a = double(a);
        end
        if ~isfloat(b)
            b = double(b);
        end
        indStart = 3;
    end
    
    % Parse name-value pairs
    nvNames = ["InputMin", "InputMax"];
    opts = struct;
    for j = indStart:2:length(varargin)
        name = varargin{j};
        if j+1 > length(varargin)
            error(message('MATLAB:rescale:KeyWithoutValue'));
        elseif (~(ischar(name) && isrow(name)) && ~(isstring(name) && isscalar(name))) ...
                || (isstring(name) && strlength(name) == 0)
            error(message('MATLAB:rescale:ParseFlags'));
        end
        ind = startsWith(nvNames, name, 'IgnoreCase', true);
        if nnz(ind) ~= 1
            error(message('MATLAB:rescale:ParseFlags'));
        end
        opts.(nvNames{ind}) = varargin{j+1};
    end
    if isfield(opts, 'InputMin')
        inputMin = opts.InputMin;
        if ~isnumeric(inputMin) || ~isreal(inputMin)
            error(message('MATLAB:rescale:InvalidInputMin'));
        end
        if (ndims(inputMin) > ndimsA) || (isvector(A) && any(size(inputMin) ~= sizA) && ~isscalar(inputMin))
            error(message('MATLAB:rescale:NumberDimsInLower'));
        end
        minFlag = true;
    end
    if isfield(opts, 'InputMax')
        inputMax = opts.InputMax;
        if ~isnumeric(inputMax) || ~isreal(inputMax)
            error(message('MATLAB:rescale:InvalidInputMax'));
        end
        if (ndims(inputMax) > ndimsA) || (isvector(A) && any(size(inputMax) ~= sizA) && ~isscalar(inputMax))
            error(message('MATLAB:rescale:NumberDimsInUpper'));
        end
        maxFlag = true;
    end
end

% Set input range if not set above
if ~minFlag
    inputMin = min(A(:));
end
if ~maxFlag
    inputMax = max(A(:));
end
% Cast inputMin/inputMax to double is not double or single
if ~isfloat(inputMin)
    inputMin = double(inputMin);
end
if ~isfloat(inputMax)
    inputMax = double(inputMax);
end

% Check to make sure min < max
if nnz(inputMin > inputMax) > 0
    error(message('MATLAB:rescale:MinGreaterThanMax'));
end

% Preprocess input range if needed
if minFlag
    A = max(A, inputMin, 'includenan');
end
if maxFlag
    A = min(A, inputMax, 'includenan');
end

end

