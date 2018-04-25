function tf = isPromise(obj)
%isPromise Is a given object a lazyeval.Promise

% Copyright 2016 The MathWorks, Inc.

tf = isa(obj, 'matlab.bigdata.internal.lazyeval.ClosurePromise');
end
