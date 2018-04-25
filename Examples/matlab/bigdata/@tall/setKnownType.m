function varargout = setKnownType(varargin)
%setKnownType Apply known type to tall array, preserving size information
%   [TA...] = setKnownType(TA..., TYPENAME) updates the adaptors in TA to
%   correspond to type TYPENAME.
%
%   This method should be used when a tall array has an adaptor with correct
%   size information, but incorrect type information.
%
%   Example:
%   tallLogical = elementfun(@isnan, tallDouble);
%   % At this point, tallLogical has a correctly-sized, but incorrectly
%   % typed adaptor. Fix this like so:
%   tallLogical = setKnownType(tallLogical, 'logical');

% Copyright 2016 The MathWorks, Inc.

nargoutchk(nargin-1, nargin-1);

typeName = varargin{end};
unsizedAdaptor = matlab.bigdata.internal.adaptors.getAdaptorForType(typeName);
varargout = varargin(1:end-1);
for idx = 1:numel(varargout)
    sizedAdaptor     = copySizeInformation(unsizedAdaptor, varargout{idx}.Adaptor);
    varargout{idx}.Adaptor = sizedAdaptor;
end
end
