function [out,dim] = reduceInDim(fcn, obj, varargin)
%REDUCEINDIM Reduction along a dimension
%
% Result OUT is a new tall array. The caller must update the Adaptor.
% Result DIMUSED indicates the reduction dimension, empty if unknown.

%   Copyright 2015-2017 The MathWorks, Inc.

FCN_NAME = upper(func2str(fcn));
tall.checkNotTall(FCN_NAME, 1, varargin{:});
% Need to handle flags for SUM and PROD.
[args, flags] = splitArgsAndFlags(varargin{:});

% Only allowed arg is the dimension, so error if got more than that.
if numel(args) > 1
    error(message('MATLAB:bigdata:array:ReductionOptionString', FCN_NAME));
end

% Interpret flags
adaptor = obj.Adaptor;
[nanFlagCell, precisionFlagCell] = adaptor.interpretReductionFlags(FCN_NAME, flags);
flags = [nanFlagCell, precisionFlagCell];

% if no dimension specified, try to deduce it.
if isempty(args)
    dim = matlab.bigdata.internal.util.deduceReductionDimension(obj.Adaptor);
    if ~isempty(dim)
        args = {dim};
    end
else
    dim = args{1};
end

        
if isempty(args)
    % Reduction in default dimension.
    out = tall(reduceInDefaultDim(fcn, obj, flags{:}));
    
else
    if ~isnumeric(dim) || ~isscalar(dim) || ~isreal(dim) ...
            || ~isfinite(dim) || dim<1 || dim~=round(dim)
        error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
    end
    % Reduction in specified dimension
    functor = iFunctor(fcn, dim, flags{:});
    if isequal(dim, 1) % TallDimension
        out = reducefun(functor, obj);
    else
        out = slicefun(functor, obj);
    end
end
end

function functor = iFunctor(fcn, dim, varargin)
    functor = @innerFcn;
    function out = innerFcn(data)
        out = fcn(data, dim, varargin{:});
    end
end
