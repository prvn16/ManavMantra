function checkFilename(filename)
%checkFilename checks that the given variable is a MATLAB char array.   

% Copyright 2009-2011 The MathWorks, Inc.

    if (~ischar(filename))
        error(message('MATLAB:Editor:NotAFilename'));
    end
end