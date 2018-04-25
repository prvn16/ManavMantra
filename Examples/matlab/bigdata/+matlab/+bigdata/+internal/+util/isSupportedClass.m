function ok = isSupportedClass(clz, supportedClasses)
% Check if an input class is one of the supported classes, with correct
% expansion of compound types like 'numeric', 'float', etc.
%
%  OK = ISSUPPORTEDCLASS(CLZ, SUPPORTEDCLASSES) returns true is the class
%  name CLZ is one of the entries in SUPPORTEDCLASSES, false otherwise. If
%  SUPPORTEDCLASSES is empty, all classes are assumed to be supported.
%
%
%  Examples:
%  >> ok = isSupportedClass('int32', {'numeric', 'datetime'}) % = true
%  >> ok = isSupportedClass('logical', {'numeric', 'datetime'}) % = false

% Copyright 2016-2017 The MathWorks, Inc.

if isempty(supportedClasses)
    ok = true;
    return
end

integerTypes = {'int8', 'int16', 'int32', 'int64', ...
                'uint8', 'uint16', 'uint32', 'uint64'};
floatTypes   = {'single', 'double'};
if ismember('numeric', supportedClasses)
    supportedClasses = [ supportedClasses, integerTypes, floatTypes ];
end
if ismember('integer', supportedClasses)
    supportedClasses = [ supportedClasses, integerTypes ];
end
if ismember('float', supportedClasses)
    supportedClasses = [ supportedClasses, floatTypes ];
end
if ismember('cellstr', supportedClasses)
    supportedClasses = [ supportedClasses, { 'cell' } ];
end
ok = ismember(clz, supportedClasses);
end
