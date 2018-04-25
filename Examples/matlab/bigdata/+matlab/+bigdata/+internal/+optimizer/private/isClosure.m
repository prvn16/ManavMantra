function tf = isClosure(obj)
%isClosure Is a given object a lazyeval.Closure

% Copyright 2016 The MathWorks, Inc.

tf = isa(obj, 'matlab.bigdata.internal.lazyeval.Closure');
end
