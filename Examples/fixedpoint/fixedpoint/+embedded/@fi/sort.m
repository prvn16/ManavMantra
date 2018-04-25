function [y, idx] = sort(varargin)
%SORT   Sort elements of real-valued fi object in ascending or descending order 
%   Refer to the MATLAB SORT reference page for more information.
%
%   See also SORT

%   Copyright 2004-2017 The MathWorks, Inc.
%     

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

args = parseinputs(varargin{:});

x = args.x;
% xxx Workaround for problem where UDD always attaches a fimath
% xxx for subsasgn (dot notation) calls in MATLAB-file fi methods. 
% This is assuming that varargin{1} is a fi (it must be anyway)
% otherwise this function would have errored out already.
x.fimathislocal = isfimathlocal(varargin{1});

dim = args.dim;

mode = args.mode;

dim = double(dim);
szx = size(x);

% unspecified 'dim'; sort along the first non-singleton dimension
if (dim == 0)
    dim = find(szx>1,1);
end
        
if isempty(x)
    
    y = x;
    idx = coder.internal.indexInt([]);

elseif numel(x) == 1
    
    y = x;
    idx = coder.internal.indexInt(1);
    
elseif (isfloat(x) || isscaleddouble(x))
    
    [yd, idx] = sort(double(x),dim,mode);
    y = embedded.fi(yd,numerictype(x));
    if x.fimathislocal
        y = setfimath(y, x.fimath);
    else
        y = removefimath(y);
    end
    idx = coder.internal.indexInt(idx);
    
elseif dim > ndims(x)
    
    y = x;
    idx = coder.internal.indexInt(ones(size(x)));
    
else
    
    % compute stride - spacing between elements that are 'consecutive'
    % along the sort dimension
    if dim == 1
        stride = 1;
    else
        stride = prod(szx(1:dim-1));
    end
    
    % number of elements along the sort dimension
    nToSort = szx(dim);  

    % increasing order if mode is 'ascend'
    % reverse-ordering required if mode is 'descend'
    isup = strcmpi(mode,'ascend');

    if nargout == 1    
        y = stridesort(x,isup,stride,nToSort);
    else
        [y, idx] = stridesort2(x,isup,stride,nToSort);
        idx = coder.internal.indexInt(idx);
    end

end

%-----------------------------------

function args = parseinputs(varargin)

p = inputParser;

p.addRequired('x',@validate_ip);

if ((nargin == 2)&&(ischar(varargin{2})))
    % accommodate the syntax sort(x, 'mode')
    p.addOptional('mode','ascend',@validate_mode);    
    p.addOptional('dim',0,@validate_dim);
    
else
    % accommodate the syntaxes sort(x), sort(x,'dim'), sort(x,'dim','mode')
    p.addOptional('dim',0,@validate_dim);
    p.addOptional('mode','ascend',@validate_mode);

end

p.parse(varargin{:});

args = p.Results;

%-----------------------------------

function val_ip = validate_ip(u)
val_ip = true;

if ~isreal(u)
    error(message('fixed:fi:unsupportedComplexInput','sort'));
end

%-----------------------------------

function val_dim = validate_dim(v)
val_dim = true;

if isfi(v)
    error(message('fixed:fi:sortInvalidFiDimInput'));
end
isintvalued = ~isempty(v)&&(isinteger(v)||(v == floor(v)));
if (~isintvalued)||(v < 1)||(~isreal(v))
    error(message('fixed:fi:invalidDimInput'));
end

%-----------------------------------

function val_mode = validate_mode(w)
val_mode = true;

if isfi(w)
    error(message('fixed:fi:sortInvalidFiDimInput'));
end
if ~strcmpi(w,'ascend')&&~strcmpi(w,'descend')
    error(message('MATLAB:sort:sortDirection'));
end
