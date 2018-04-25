function b = padarray(varargin) %#codegen

% Copyright 2012-2017 The MathWorks, Inc.
%#ok<*EMCA>

coder.internal.prefer_const(varargin);
coder.internal.assert(nargin >= 2 && nargin <= 4,...
    ('images:padarray:incorrectInputCount'));

a = varargin{1};
coder.internal.errorIf(numel(size(a)) > 3,...
    'images:padarray:incorrectInputDims');

% Allow constant folding of padSize when inputs are fixed-size
padSize = getPadSize(numel(size(a)), varargin{2});

coder.internal.errorIf(numel(padSize) > numel(size(a)),...
    'images:padarray:incorrectPadDims');

validateattributes(padSize, {'double'}, {'real' 'vector' 'nonnan' 'nonnegative' ...
    'integer'}, 'padarray', 'PADSIZE', 2);

if nargin <= 2
    method = CONSTANT;
    padVal = 0;
    direction = BOTH;
else
    if ~ischar(varargin{3}) && ~isstring(varargin{3})
        % Third input must be pad value.
        padVal = varargin{3};
        validateattributes(padVal, {'numeric' 'logical'}, {'scalar'}, ...
            'padarray', 'PADVAL', 3);
        firstStringToProcess = 4;
    else
        padVal = 0;
        firstStringToProcess = 3;
    end
    
    % Allow constant folding of direction and method strings even when they
    % are unordered and specified multiple times
    [direction, method] = parseMethodDirection(firstStringToProcess, varargin{:});
end

coder.internal.prefer_const(method, direction, padSize, padVal);

if method == CONSTANT
    coder.internal.errorIf(~isnumeric(a) && ~islogical(a),...
        'images:padarray:badTypeForConstantPadding');
end

coder.internal.prefer_const(padVal, padSize, method, direction);

if isempty(a)
    % treat empty matrix similar for any method
    sizeA = size(a);
    if direction == BOTH
        sizeB = sizeA + 2*padSize;
    else
        sizeB = sizeA + padSize;
    end
    
    padValCast = cast(padVal,'like',a);
    if numel(size(a)) == 3
        b = repmat(padValCast, [sizeB(1) sizeB(2) sizeB(3)]);
    else
        b = repmat(padValCast, [sizeB(1) sizeB(2)]);
    end
    
elseif method == CONSTANT
    % constant value padding with padVal
    if coder.isColumnMajor
        b = ConstantPad(a, padSize, padVal, direction);
    else
        b = ConstantPadRowMajor(a, padSize, padVal, direction);
    end
    
else
    % compute indices then index into input image
    sizeA = size(a);
    idxA = getPaddingIndices(sizeA,padSize,method,direction);
    
    if direction == BOTH
        b = coder.nullcopy(eml_expand(eml_scalar_eg(a),size(a) + 2*padSize));
    else % PRE and POST
        b = coder.nullcopy(eml_expand(eml_scalar_eg(a),size(a) + padSize));
    end
    
    if coder.isColumnMajor
        if numel(size(a)) == 3
            for k = 1:size(b,3)
                for j = 1:size(b,2)
                    for i = 1:size(b,1)
                        b(i,j,k) = a(idxA(i,1),idxA(j,2), idxA(k,3));
                    end
                end
            end
        else
            for j = 1:size(b,2)
                for i = 1:size(b,1)
                    b(i,j) = a(idxA(i,1),idxA(j,2));
                end
            end
        end
    else % coder.isRowMajor
        if numel(size(a)) == 3
            for i = 1:size(b,1)
                for j = 1:size(b,2)
                    for k = 1:size(b,3)
                        b(i,j,k) = a(idxA(i,1),idxA(j,2), idxA(k,3));
                    end
                end
            end
        else
            for i = 1:size(b,1)
                for j = 1:size(b,2)
                    b(i,j) = a(idxA(i,1),idxA(j,2));
                end
            end
        end
    end
end

if islogical(a)
    b = logical(b);
end

%%%
%%% ParseInputs
%%%

function padSize = getPadSize(sza, padArg)

coder.inline('always');
coder.internal.prefer_const(sza,padArg);

if (sza > numel(padArg))
    padSize = zeros(1,sza);
    for idx = 1:numel(padArg)
        padSize(idx) = padArg(idx);
    end
else
    if iscolumn(padArg) && ~isscalar(padArg)
        padSize = padArg';
    else
        padSize = padArg;
    end
end

function p = isDirectionStr(str)
% Returns true is str is a valid direction string
% Use strncmpi to allow case-insensitive, partial matches
p = strncmpi(str,'pre',numel(str)) || strncmpi(str,'post',numel(str)) || strncmpi(str, 'both',numel(str));

function p = isMethodStr(str)
% Returns true is str is a valid method string
p = strncmpi(str,'circular',numel(str)) || strncmpi(str,'replicate',numel(str)) || strncmpi(str, 'symmetric',numel(str));

function direction = stringToDirection(dStr)
% Convert direction string to its corresponding enumeration
% Use strncmpi to allow case-insensitive, partial matches
if strncmpi(dStr,'pre',numel(dStr))
    direction = PRE;
elseif strncmpi(dStr,'post',numel(dStr))
    direction = POST;
else % if strncmpi(dStr,'both',numel(dStr))
    direction = BOTH;
end

function method = stringToMethod(mStr)
% Convert method string to its corresponding enumeration
% Use strncmpi to allow case-insensitive, partial matches
if strncmpi(mStr,'circular',numel(mStr))
    method = CIRCULAR;
elseif strncmpi(mStr,'replicate',numel(mStr))
    method = REPLICATE;
else % if strncmpi(mStr,'symmetric',numel(mStr))
    method = SYMMETRIC;
end

function [direction, method] = parseMethodDirection(idx0,varargin)

coder.inline('always');
coder.internal.prefer_const(idx0,varargin);

validStrings = {'circular' 'replicate' 'symmetric' 'pre' ...
    'post' 'both'};

N = numel(varargin);

% Check that all string inputs arguments are constants
for idx = coder.unroll(idx0:N)
    coder.internal.errorIf(~coder.internal.isConst(varargin{idx}),...
        'images:padarray:methodOrDirStringNotConst');
    validatestring(varargin{idx}, validStrings, 'padarray', ...
        'METHOD or DIRECTION', idx);
end

% Parse each input argument to ensure direction and method are compile-time
% constants
% Parse Direction string
idx0p1 = idx0 + 1;
if idx0 <= N && isDirectionStr(varargin{idx0})
    if idx0p1 <= N && isDirectionStr(varargin{idx0p1})
        % Deal with two direction string inputs by honoring the final value
        % e.g. out = padarray(in,[1 2]', 'pre','post'); will set the
        % direction to 'post'
        direction = stringToDirection(varargin{idx0p1});
    else
        direction = stringToDirection(varargin{idx0});
    end
elseif idx0p1 <= N && isDirectionStr(varargin{idx0p1})
    direction = stringToDirection(varargin{idx0p1});
else
    direction = BOTH;
end

% Parse Method string
if idx0 <= N && isMethodStr(varargin{idx0})
    if idx0p1 <= N && isMethodStr(varargin{idx0p1})
        % Deal with two method string inputs by honoring the final value
        % e.g. out = padarray(in,[1 2]', 'symmetric', 'replicate'); will 
        % set the method to 'replicate'
        method = stringToMethod(varargin{idx0p1});
    else
        method = stringToMethod(varargin{idx0});
    end
elseif idx0p1 <= N && isMethodStr(varargin{idx0p1})
    method = stringToMethod(varargin{idx0p1});
else
    method = CONSTANT;
end


%%%
%%% ConstantPad
%%%
function b = ConstantPad(a, padSize, padVal, direction)

coder.inline('always');
coder.internal.prefer_const(padVal,padSize,direction);

padValCast = cast(padVal,'like',a);
if isreal(a)
    padValInit = padValCast;
else
    padValInit = complex(padValCast);
end

if direction == BOTH
    if islogical(padValInit)
        b = coder.nullcopy(false((size(a) + 2*padSize)));
    else
        b = coder.nullcopy(zeros((size(a) + 2*padSize),'like',padValInit));
    end
    
else % PRE and POST
    if islogical(padValInit)
        b = coder.nullcopy(false((size(a) + padSize)));
    else
        b = coder.nullcopy(zeros((size(a) + padSize),'like',padValInit));
    end
end

if numel(size(a)) == 3
    % Initialize output with pad values only in those locations where the
    % input will not be copied over in the subsequent operation.
    if direction == PRE
        % Initialize 'pre' locations to pad value
        for k = 1:padSize(3)
            for j = 1:size(b,2)
                for i = 1: size(b,1)
                    b(i,j,k) = padValInit;
                end
            end
        end
        % Initialize the remaining locations
        for k = coder.internal.indexPlus(padSize(3),1):size(b,3)
            % Left columns
            for j = 1:padSize(2)
                for i = 1:size(b,1)
                    b(i,j,k) = padValInit;
                end
            end
            % Top middle rows
            for j = coder.internal.indexPlus(padSize(2),1):size(b,2)
                for i = 1:padSize(1)
                    b(i,j,k) = padValInit;
                end
            end
        end
    elseif direction == BOTH
        % Initialize 'pre' and 'post' locations to pad value
        for k = 1:padSize(3)
            for j = 1:size(b,2)
                for i = 1: size(b,1)
                    b(i,j,k) = padValInit;
                end
            end
        end
        
        for k = coder.internal.indexPlus(coder.internal.indexPlus(padSize(3),size(a,3)),1):size(b,3)
            for j = 1:size(b,2)
                for i = 1: size(b,1)
                    b(i,j,k) = padValInit;
                end
            end
        end
        % Initialize the remaining locations
        for k = 1:size(a,3)
            % Left columns
            for j = 1:padSize(2)
                for i = 1:size(b,1)
                    b(i,j,coder.internal.indexPlus(k,padSize(3))) = padValInit;
                end
            end
            % Right columns
            for j = coder.internal.indexPlus(coder.internal.indexPlus(size(a,2),padSize(2)),1):size(b,2)
                for i = 1:size(b,1)
                    b(i,j,coder.internal.indexPlus(k,padSize(3))) = padValInit;
                end
            end
            % Top middle rows
            for j = 1:size(a,2)
                for i = 1:padSize(1)
                    b(i,coder.internal.indexPlus(j,padSize(2)),coder.internal.indexPlus(k,padSize(3))) = padValInit;
                end
            end
            % Bottom middle rows
            for j = 1:size(a,2)
                for i = coder.internal.indexPlus(coder.internal.indexPlus(padSize(1),size(a,1)),1):size(b,1)
                    b(i,coder.internal.indexPlus(j,padSize(2)),coder.internal.indexPlus(k,padSize(3))) = padValInit;
                end
            end
        end
    else %POST
        % Initialise 'post' locations to pad value
        for k = coder.internal.indexPlus(size(a,3),1):size(b,3)
            for j = 1:size(b,2)
                for i = 1: size(b,1)
                    b(i,j,k) = padValInit;
                end
            end
        end
        % Initialize the remaining locations
        for k = 1:size(a,3)
            % Right columns
            for j = coder.internal.indexPlus(size(a,2),1):size(b,2)
                for i = 1:size(b,1)
                    b(i,j,k) = padValInit;
                end
            end
            % Bottom middle rows
            for j = 1:size(a,2)
                for i = coder.internal.indexPlus(size(a,1),1):size(b,1)
                    b(i,j,k) = padValInit;
                end
            end
        end
    end
    
    % Copy input to output array
    if direction == PRE || direction == BOTH
        for k = 1:size(a,3)
            for j = 1:size(a,2)
                for i = 1:size(a,1)
                    b(coder.internal.indexPlus(i,padSize(1)),coder.internal.indexPlus(j,padSize(2)),coder.internal.indexPlus(k,padSize(3))) = a(i,j,k);
                end
            end
        end
    else %POST
        for k = 1:size(a,3)
            for j = 1:size(a,2)
                for i = 1:size(a,1)
                    b(i,j,k) = a(i,j,k);
                end
            end
        end
    end
    
else % 2-D
    % Initialize output with pad values only in those locations where the
    % input will not be copied over in the subsequent operation.
    if direction == PRE
        % Left columns
        for j = 1:padSize(2)
            for i = 1:size(b,1)
                b(i,j) = padValInit;
            end
        end
        % Top middle rows
        for j = coder.internal.indexPlus(padSize(2),1):size(b,2)
            for i = 1:padSize(1)
                b(i,j) = padValInit;
            end
        end
    elseif direction == BOTH
        % Left columns
        for j = 1:padSize(2)
            for i = 1:size(b,1)
                b(i,j) = padValInit;
            end
        end
        
        % Right columns
        for j = coder.internal.indexPlus(coder.internal.indexPlus(size(a,2),padSize(2)),1):size(b,2)
            for i = 1:size(b,1)
                b(i,j) = padValInit;
            end
        end
        
        % Top middle rows
        for j = 1:size(a,2)
            for i = 1:padSize(1)
                b(i,coder.internal.indexPlus(j,padSize(2))) = padValInit;
            end
        end
        
        % Bottom middle rows
        for j = 1:size(a,2)
            for i = coder.internal.indexPlus(coder.internal.indexPlus(padSize(1),size(a,1)),1):size(b,1)
                b(i,coder.internal.indexPlus(j,padSize(2))) = padValInit;
            end
        end
        
    else %POST
        % Right columns
        for j = coder.internal.indexPlus(size(a,2),1):size(b,2)
            for i = 1:size(b,1)
                b(i,j) = padValInit;
            end
        end
        % Bottom middle rows
        for j = 1:size(a,2)
            for i = coder.internal.indexPlus(size(a,1),1):size(b,1)
                b(i,j) = padValInit;
            end
        end
    end
    
    % Copy input to output array
    if direction == PRE || direction == BOTH
        for j = 1:size(a,2)
            for i = 1:size(a,1)
                b(coder.internal.indexPlus(i,padSize(1)),coder.internal.indexPlus(j,padSize(2))) = a(i,j);
            end
        end
    else %POST
        for j = 1:size(a,2)
            for i = 1:size(a,1)
                b(i,j) = a(i,j);
            end
        end
    end
end

function b = ConstantPadRowMajor(a, padSize, padVal, direction)

coder.inline('always');
coder.internal.prefer_const(padVal,padSize,direction);

padValCast = cast(padVal,'like',a);
if isreal(a)
    padValInit = padValCast;
else
    padValInit = complex(padValCast);
end

if direction == BOTH
    if islogical(padValInit)
        b = coder.nullcopy(false((size(a) + 2*padSize)));
    else
        b = coder.nullcopy(zeros((size(a) + 2*padSize),'like',padValInit));
    end
    
else % PRE and POST
    if islogical(padValInit)
        b = coder.nullcopy(false((size(a) + padSize)));
    else
        b = coder.nullcopy(zeros((size(a) + padSize),'like',padValInit));
    end
end

if numel(size(a)) == 3
    % Initialize output with pad values only in those locations where the
    % input will not be copied over in the subsequent operation.
    if direction == PRE
        % Initialize 'pre' locations to pad value
        for i = 1:size(b,1)
            for j = 1:size(b,2)
                for k = 1: padSize(3)
                    b(i,j,k) = padValInit;
                end
            end
        end
        % Initialize the remaining locations
        for i = 1:size(b,1)
            % Left columns
            for j = 1:padSize(2)
                for k = coder.internal.indexPlus(padSize(3),1):size(b,3)
                    b(i,j,k) = padValInit;
                end
            end
        end
        
        for i = 1:padSize(1)
            % Top middle rows
            for j = coder.internal.indexPlus(padSize(2),1):size(b,2)
                for k = coder.internal.indexPlus(padSize(3),1):size(b,3)
                    b(i,j,k) = padValInit;
                end
            end
        end
    elseif direction == BOTH
        % Initialize 'pre' and 'post' locations to pad value
        for i = 1: size(b,1)
            for j = 1:size(b,2)
                for k = 1:padSize(3)
                    b(i,j,k) = padValInit;
                end
            end
        end
        
        for i = 1: size(b,1)
            for j = 1:size(b,2)
                for k = coder.internal.indexPlus(coder.internal.indexPlus(padSize(3),size(a,3)),1):size(b,3)
                    b(i,j,k) = padValInit;
                end
            end
        end
        % Initialize the remaining locations
        for i = 1:size(b,1)
            % Left columns
            for j = 1:padSize(2)
                for k = 1:size(a,3)
                    b(i,j,coder.internal.indexPlus(k,padSize(3))) = padValInit;
                end
            end
            
            % Right columns
            for j = coder.internal.indexPlus(coder.internal.indexPlus(size(a,2),padSize(2)),1):size(b,2)
                for k = 1:size(a,3)
                    b(i,j,coder.internal.indexPlus(k,padSize(3))) = padValInit;
                end
            end
        end
        
        for i = 1:padSize(1)
            % Top middle rows
            for j = 1:size(a,2)
                for k = 1:size(a,3)
                    b(i,coder.internal.indexPlus(j,padSize(2)),coder.internal.indexPlus(k,padSize(3))) = padValInit;
                end
            end
        end
        
        for i = coder.internal.indexPlus(coder.internal.indexPlus(padSize(1),size(a,1)),1):size(b,1)
            % Bottom middle rows
            for j = 1:size(a,2)
                for k = 1:size(a,3)
                    b(i,coder.internal.indexPlus(j,padSize(2)),coder.internal.indexPlus(k,padSize(3))) = padValInit;
                end
            end
        end
    else %POST
        % Initialise 'post' locations to pad value
        for i = 1: size(b,1)
            for j = 1:size(b,2)
                for k = coder.internal.indexPlus(size(a,3),1):size(b,3)
                    b(i,j,k) = padValInit;
                end
            end
        end
        % Initialize the remaining locations
        for i = 1:size(b,1)
            % Right columns
            for j = coder.internal.indexPlus(size(a,2),1):size(b,2)
                for k = 1:size(a,3)
                    b(i,j,k) = padValInit;
                end
            end
        end
        
        for i = coder.internal.indexPlus(size(a,1),1):size(b,1)
            % Bottom middle rows
            for j = 1:size(a,2)
                for k = 1:size(a,3)
                    b(i,j,k) = padValInit;
                end
            end
        end
    end
    
    % Copy input to output array
    if direction == PRE || direction == BOTH
        for i = 1:size(a,1)
            for j = 1:size(a,2)
                for k = 1:size(a,3)
                    b(coder.internal.indexPlus(i,padSize(1)),coder.internal.indexPlus(j,padSize(2)),coder.internal.indexPlus(k,padSize(3))) = a(i,j,k);
                end
            end
        end
    else %POST
        for i = 1:size(a,1)
            for j = 1:size(a,2)
                for k = 1:size(a,3)
                    b(i,j,k) = a(i,j,k);
                end
            end
        end
    end
    
else % 2-D
    % Initialize output with pad values only in those locations where the
    % input will not be copied over in the subsequent operation.
    if direction == PRE
        % Left columns
        for i = 1:size(b,1)
            for j = 1:padSize(2)
                b(i,j) = padValInit;
            end
        end
        % Top middle rows
        for i = 1:padSize(1)
            for j = coder.internal.indexPlus(padSize(2),1):size(b,2)
                b(i,j) = padValInit;
            end
        end
    elseif direction == BOTH
        % Left columns
        for i = 1:size(b,1)
            for j = 1:padSize(2)
                b(i,j) = padValInit;
            end
        end
        
        % Right columns
        for i = 1:size(b,1)
            for j = coder.internal.indexPlus(coder.internal.indexPlus(size(a,2),padSize(2)),1):size(b,2)
                b(i,j) = padValInit;
            end
        end
        
        % Top middle rows
        for i = 1:padSize(1)
            for j = 1:size(a,2)
                b(i,coder.internal.indexPlus(j,padSize(2))) = padValInit;
            end
        end
        
        % Bottom middle rows
        for i = coder.internal.indexPlus(coder.internal.indexPlus(padSize(1),size(a,1)),1):size(b,1)
            for j = 1:size(a,2)
                b(i,coder.internal.indexPlus(j,padSize(2))) = padValInit;
            end
        end
        
    else %POST
        % Right columns
        for i = 1:size(b,1)
            for j = coder.internal.indexPlus(size(a,2),1):size(b,2)
                b(i,j) = padValInit;
            end
        end
        % Bottom middle rows
        for i = coder.internal.indexPlus(size(a,1),1):size(b,1)
            for j = 1:size(a,2)
                b(i,j) = padValInit;
            end
        end
    end
    
    % Copy input to output array
    if direction == PRE || direction == BOTH
        for i = 1:size(a,1)
            for j = 1:size(a,2)
                b(coder.internal.indexPlus(i,padSize(1)),coder.internal.indexPlus(j,padSize(2))) = a(i,j);
            end
        end
    else %POST
        for i = 1:size(a,1)
            for j = 1:size(a,2)
                b(i,j) = a(i,j);
            end
        end
    end
end

function methodFlag = CONSTANT()
coder.inline('always');
methodFlag = int8(1);

function methodFlag = SYMMETRIC()
coder.inline('always');
methodFlag = int8(2);

function methodFlag = REPLICATE()
coder.inline('always');
methodFlag = int8(3);

function methodFlag = CIRCULAR()
coder.inline('always');
methodFlag = int8(4);

function directionFlag = PRE()
coder.inline('always');
directionFlag = int8(5);

function directionFlag = POST()
coder.inline('always');
directionFlag = int8(6);

function directionFlag = BOTH()
coder.inline('always');
directionFlag = int8(7);

function idxA = getPaddingIndices(sizeA,padSize,method,direction)
%getPaddingIndices Computes padding indices of input image.
%   This is function is used to handle padding of in-memory images
%
%   sizeA     : result of size(I) where I is the image to be padded
%   padSize   : padding amount in each dimension.
%               numel(padSize) can be greater than numel(aSize)
%   method    : a 'string' padding method
%   direction : pre, post, or both.
%
%   idxA      : indices of input array, A

coder.inline('always');
coder.internal.prefer_const(sizeA, padSize,method,direction);

if method == CIRCULAR
    idxA = CircularPad(sizeA, padSize, direction);
elseif method == SYMMETRIC
    idxA = SymmetricPad(sizeA, padSize, direction);
else %REPLICATE
    idxA = ReplicatePad(sizeA, padSize, direction);
end

coder.internal.prefer_const(idxA);

%%%
%%% CircularPad
%%%
function idxA = CircularPad(sizeA, padSize, direction)

coder.inline('always');
coder.internal.prefer_const(sizeA, padSize, direction);

numDims = numel(padSize);

% Form index vectors to copy input array into output array.
if numel(sizeA) == 3
    idxA = coder.nullcopy(zeros(max(2*[padSize(1) padSize(2) padSize(3)] + [sizeA(1) sizeA(2) sizeA(3)]),...
        size(2*[padSize(1) padSize(2) padSize(3)] + [sizeA(1) sizeA(2) sizeA(3)],2), 'like', coder.internal.indexInt(0)));
else
    idxA = coder.nullcopy(zeros(max(2*[padSize(1) padSize(2) ] + [sizeA(1) sizeA(2)]),...
        size(2*[padSize(1) padSize(2)] + [sizeA(1) sizeA(2)],2), 'like', coder.internal.indexInt(0)));
end

% When variable-size is turned off, numDims must be a constant
for k = coder.unroll(1:numDims, eml_is_const(numDims))
    dimNums = uint32(1:sizeA(k));
    
    if direction == PRE
        idxDir = dimNums(mod(-padSize(k):sizeA(k)-1, sizeA(k)) + 1);
        idxA(1:size(idxDir,2),k) = cast(idxDir, 'like', coder.internal.indexInt(0));
    elseif direction == POST
        idxDir = dimNums(mod(0:sizeA(k)+padSize(k)-1, sizeA(k)) + 1);
        idxA(1:size(idxDir,2),k) = cast(idxDir, 'like', coder.internal.indexInt(0));
    else %BOTH
        idxDir = dimNums(mod(-padSize(k):sizeA(k)+padSize(k)-1, sizeA(k)) + 1);
        idxA(1:size(idxDir,2),k) = cast(idxDir, 'like', coder.internal.indexInt(0));
    end
end
    
coder.internal.prefer_const(idxA);

%%%
%%% SymmetricPad
%%%
function idxA = SymmetricPad(sizeA, padSize, direction)

coder.inline('always');
coder.internal.prefer_const(sizeA, padSize, direction);

numDims = numel(padSize);

% Form index vectors to copy input array into output array.
if numel(sizeA) == 3
    idxA = coder.nullcopy(zeros(max(2*[padSize(1) padSize(2) padSize(3)] + [sizeA(1) sizeA(2) sizeA(3)]),...
        size(2*[padSize(1) padSize(2) padSize(3)] + [sizeA(1) sizeA(2) sizeA(3)],2), 'like', coder.internal.indexInt(0)));
else
    idxA = coder.nullcopy(zeros(max(2*[padSize(1) padSize(2) ] + [sizeA(1) sizeA(2)]),...
        size(2*[padSize(1) padSize(2)] + [sizeA(1) sizeA(2)],2), 'like', coder.internal.indexInt(0)));
end

% When variable-size is turned off, numDims must be a constant
for k = coder.unroll(1:numDims,eml_is_const(numDims))
    dimNums = uint32([1:sizeA(k) sizeA(k):-1:1]);
    
    if direction == PRE
        idxDir = dimNums(mod(-padSize(k):sizeA(k)-1, 2*sizeA(k)) + 1);
        idxA(1:size(idxDir,2),k) = cast(idxDir, 'like', coder.internal.indexInt(0));
    elseif direction == POST
        idxDir = dimNums(mod(0:sizeA(k)+padSize(k)-1, 2*sizeA(k)) + 1);
        idxA(1:size(idxDir,2),k) = cast(idxDir, 'like', coder.internal.indexInt(0));
    else %BOTH
        idxDir = dimNums(mod(-padSize(k):sizeA(k)+padSize(k)-1, 2*sizeA(k)) + 1);
        idxA(1:size(idxDir,2),k) = cast(idxDir, 'like', coder.internal.indexInt(0));
    end
end

coder.internal.prefer_const(idxA);

%%%
%%% ReplicatePad
%%%
function idxA = ReplicatePad(sizeA, padSize, direction)

coder.inline('always');
coder.internal.prefer_const(sizeA, padSize, direction);

numDims = numel(padSize);

% Form index vectors to copy input array into output array.
if numel(sizeA) == 3
    idxA = coder.nullcopy(zeros(max(2*[padSize(1) padSize(2) padSize(3)] + [sizeA(1) sizeA(2) sizeA(3)]),...
        size(2*[padSize(1) padSize(2) padSize(3)] + [sizeA(1) sizeA(2) sizeA(3)],2), 'like', coder.internal.indexInt(0)));
else
    idxA = coder.nullcopy(zeros(max(2*[padSize(1) padSize(2) ] + [sizeA(1) sizeA(2)]),...
        size(2*[padSize(1) padSize(2)] + [sizeA(1) sizeA(2)],2), 'like', coder.internal.indexInt(0)));
end

% When variable-size is turned off, numDims must be a constant
for k = coder.unroll(1:numDims,eml_is_const(numDims))
    onesVector = uint32(ones(1,padSize(k)));
    
    if direction == PRE
        idxDir = [onesVector 1:sizeA(k)];
        idxA(1:size(idxDir,2),k) = cast(idxDir, 'like', coder.internal.indexInt(0));
    elseif direction == POST
        idxDir = [1:sizeA(k) sizeA(k)*onesVector];
        idxA(1:size(idxDir,2),k) = cast(idxDir, 'like', coder.internal.indexInt(0));
    else %BOTH
        idxDir = [onesVector 1:sizeA(k) sizeA(k)*onesVector];
        idxA(1:size(idxDir,2),k) = cast(idxDir, 'like', coder.internal.indexInt(0));
    end
end

coder.internal.prefer_const(idxA);

 