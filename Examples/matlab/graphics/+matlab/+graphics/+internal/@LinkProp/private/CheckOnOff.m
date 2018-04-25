% Local functions called from processRemoveHandle()
%
function val = CheckOnOff(val)

%   Copyright 2014-2015 The MathWorks, Inc.

switch (val)
    case 'o'
        error( message( 'MATLAB:datatypes:onoffboolean:UnknownOnOffBooleanValue' ) );
    case 'on'
    case 'of'
        val = 'off';
    case 'off'
    otherwise
        error( message( 'MATLAB:datatypes:onoffboolean:UnknownOnOffBooleanValue' ) );
end

end
