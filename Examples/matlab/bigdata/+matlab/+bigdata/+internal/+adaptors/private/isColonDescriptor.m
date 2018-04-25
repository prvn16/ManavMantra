function tf = isColonDescriptor(sub)
%isColonDescriptor Return true if the input is a ColonDescriptor object.

% Copyright 2017 The MathWorks, Inc.

tf = isa(sub, 'matlab.internal.ColonDescriptor');
end
