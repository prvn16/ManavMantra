function out = stringCellstr(fcn, fcnArgs, in, outClass, emptyIsAnyDim)
%stringCellstr shared implementation for tall/string and tall/cellstr
%   OUT = stringCellstr(FCN, FCNARGS, IN, OUTCLASS, EMPTYISANYDIM)
%   applies FCN(IN,FCNARGS{:}), producing output of class OUTCLASS.
%
%   This function handles the 'special' behaviour of CHAR data in functions like
%   CELLSTR and STRING. Empty CHAR array inputs to both CELLSTR and STRING
%   return scalar outputs. Therefore, special measures must be taken to ensure
%   that empty CHAR chunks and inputs are handled correctly. Unfortunately, this
%   means that tall/string and tall/cellstr involve reduction for CHAR inputs.
%
%   Input argument EMPTYISANYDIM must be a logical scalar specifying
%   whether to treat empty char arrays in general as special. If false,
%   only the 0 x 0 '' char is treated as special.

% Copyright 2016-2017 The MathWorks, Inc.

assert(istall(in));
inAdaptor  = in.Adaptor;

if isempty(inAdaptor.Class) || strcmp(inAdaptor.Class, 'char')
    % Unknown type or definitely CHAR data. Switch behaviour based on whether we
    % know the tall size.
    
    if emptyIsAnyDim
        % For cellstr, special care needs to be taken when size in any
        % dimension is zero.
        knownNotSpecial = isKnownNotEmpty(inAdaptor);
        isSpecialFcn = @isempty;
    else
        % For string, special care needs to be taken only when we can't be
        % certain the input tall array isn't 0 x 0.
        knownNotSpecial = isKnownNotMatrix(inAdaptor) ...
            || isTallSizeGuaranteedNonZero(inAdaptor) ...
            || any(inAdaptor.SmallSizes > 0);
        isSpecialFcn = @(x) ismatrix(x) && all(size(x) == [0,0]);
    end
    
    if knownNotSpecial
        % Here we need to apply the correctly-slicefun-compatible version of FCN, and
        % then fix up the output size.
        out = slicefun(@(x) iSliceFun(fcn, x, fcnArgs{:}), in);
    else
        % Here we need to do something special. Call 'head' to work out if the data is
        % empty - broadcast that to a partitionfun call which can emit the
        % correct result if the data is truly empty.
        inHead = matlab.bigdata.internal.broadcast(head(in, 1));
        out = partitionfun(@(info, x, xh) iPartitionFun(info, x, xh, fcn, fcnArgs, isSpecialFcn), in, inHead);
        % The framework will assume out is partition dependent because it is
        % derived from partitionfun. It is not, so we must correct this.
        out = copyPartitionIndependence(out, in);
    end    
else
    % Non-CHAR cases preserve the full size of the input.
    out = elementfun(@(x) fcn(x, fcnArgs{:}), in);
end
out = setKnownType(out, outClass);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hasFinished, out] = iPartitionFun(info, in, inHead, fcn, fcnArgs, isSpecialFcn)
if ischar(inHead) && isSpecialFcn(inHead)
    % We handle special empty cases by emitting all output in partition 1.
    out = fcn(inHead, fcnArgs{:});
    % All other partitions are left empty of a compatible size.
    if info.PartitionId ~= 1
        out = matlab.bigdata.internal.util.indexSlices(out, []);
    end
    hasFinished = true;
else
    out = iSliceFun(fcn, in, fcnArgs{:});
    hasFinished = info.IsLastChunk;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outSlice = iSliceFun(fcn, in, varargin)
outSlice = fcn(in, varargin{:});
if size(in, 1) == 0 && size(outSlice, 1) ~= 0
    % Fix up the slice
    outSlice = matlab.bigdata.internal.util.indexSlices(outSlice, []);
end
end
