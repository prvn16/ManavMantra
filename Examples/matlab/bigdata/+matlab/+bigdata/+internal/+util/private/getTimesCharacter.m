function c = getTimesCharacter()
%getTimesCharacter get appropriate "times" character.
%   For use when formatting sizes - returns char(215) normally, and
%   'x' in deployed mode.

% Copyright 2017 The MathWorks, Inc.

if matlab.internal.display.isDesktopInUse
    c = char(215);
else
    c = 'x';
end
end

