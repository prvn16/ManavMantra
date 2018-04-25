function tf = isFuture(obj)
%isFuture Is a given object a lazyeval.Future

% Copyright 2016 The MathWorks, Inc.

tf = isa(obj, 'matlab.bigdata.internal.lazyeval.ClosureFuture');
end
