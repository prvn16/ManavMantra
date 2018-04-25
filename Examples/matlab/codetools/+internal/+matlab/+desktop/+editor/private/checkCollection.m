function checkCollection(collection)
%checkCollection checks that the given variable is a java.util.Collection. 

% Copyright 2009-2011 The MathWorks, Inc.

    if (~isa(collection, 'java.util.Collection'))
        error(message('MATLAB:Editor:NotACollection'));
    end
end