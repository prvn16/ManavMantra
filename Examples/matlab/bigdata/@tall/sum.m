function out = sum(x, varargin)
%SUM Sum of elements.
%
%   See also sum.

% Copyright 2016-2017 The MathWorks, Inc.

% We need a specific overload for SUM to handle duration.
FCN_NAME = upper(mfilename);
x = tall.validateType(x, mfilename, {'numeric', 'logical', 'duration', 'char'}, 1);
tall.checkNotTall(FCN_NAME, 1, varargin{:});

[~, flags] = splitArgsAndFlags(varargin{:});

try
    % We need the precisionFlagCell here for computing the output type.
    [~, precisionFlagCell] = x.Adaptor.interpretReductionFlags(FCN_NAME, flags);
catch E
    throw(E);
end

[out, dimUsed] = reduceInDim(@sum, x, varargin{:});
out.Adaptor = matlab.bigdata.internal.adaptors.getAdaptorForType(...
    computeSumResultType(x.Adaptor.Class, precisionFlagCell));

if ~isempty(dimUsed)
    out.Adaptor = computeReducedSize(out.Adaptor, x.Adaptor, dimUsed, false);
end

end
