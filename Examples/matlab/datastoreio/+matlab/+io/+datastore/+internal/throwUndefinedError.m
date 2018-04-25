function throwUndefinedError(className)
%throwUndeinedError Undefined error for handle methods for datastores.
%   This is a helper function which is used to error for methods which are
%   inherited from handle class.

%   Copyright 2014 The MathWorks, Inc.

st = dbstack;
name = regexp(st(2).name,'\.','split');
me = MException('MATLAB:datastoreio:datastore:undefinedFunction', ...
                 getString(message('MATLAB:datastoreio:datastore:undefinedFunction',name{2}, className)));
throwAsCaller(me);
end