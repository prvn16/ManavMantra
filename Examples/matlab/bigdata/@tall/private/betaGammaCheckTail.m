function betaGammaCheckTail(tail,name,argPos,validTail)
%betaGammaCheckTail  Check the "tail" argument for betainc/gamminc.

%   Copyright 2016-2017 The MathWorks, Inc.

tall.checkNotTall(upper(name), argPos, tail);

if ~isNonTallScalarString(tail) ...
        || ~any(strcmp(tail,validTail))
    errId = ['MATLAB:', name, ':InvalidTailArg'];
    throwAsCaller(MException(message(errId)));
end
end
