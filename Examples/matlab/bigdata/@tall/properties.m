function p = properties(obj)
%PROPERTIES Return properties of tall array

% Copyright 2016 The MathWorks, Inc.

adaptor = obj.Adaptor;
propNames = getProperties(adaptor);

if nargout == 0
    % Display only
    clz = adaptor.Class;
    if isempty(clz)
        clz = 'tall';
    end
    matlab.bigdata.internal.util.displayProperties(clz, propNames);
else
    % Return the list without displaying anything
    p = reshape(propNames, [], 1);
end
end
