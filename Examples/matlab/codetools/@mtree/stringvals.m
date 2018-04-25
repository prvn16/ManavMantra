function c = stringvals( o )
%STRINGVALS c = STRINGVALS( obj ) return the string values for obj

% Copyright 2006-2014 The MathWorks, Inc.

    c = strings(o);
    for i=1:length(c)
        c{i} = dequote( c{i} );
    end
end
