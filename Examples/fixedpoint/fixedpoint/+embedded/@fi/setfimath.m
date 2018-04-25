function y = setfimath(x,F)
%SETFIMATH Set FIMATH object on output for fixed-point and integer input.
%
%   See also REMOVEFIMATH, SETFIMATH.

%   Copyright 2011-2012 The MathWorks, Inc.
    nargoutchk(1,1);
    if isempty(F)
        y = removefimath(x);
    else
        if isscaledtype(x)
            % Only set fimath on fixed-point and scaled-double types
            if ~isfimath(F)
                error(message('fixed:fimath:parameterNotFimath'));
            end
            y = x;
            y.fimath = F;
            y.fimathislocal = true;
        else
            % Do not set fimath on fi with data type double, single, boolean.
            y = x;
        end
    end
end
