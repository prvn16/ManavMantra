function obj = hSetAdaptor(obj, adaptor)
%hSetAdaptor Set the adaptor.

% Copyright 2016 The MathWorks, Inc.

% Output argument must be captured - modifying the input.
nargoutchk(1,1);
assert(isa(adaptor, 'matlab.bigdata.internal.adaptors.AbstractAdaptor') && ...
       isscalar(adaptor));
obj.Adaptor = adaptor;
end
