function b = isAccessible(classElement, elementKeyword)
    b = true;
    switch elementKeyword
    case 'methods'
        b = isAccessibleElement(classElement, 'Access');    
    case 'properties'
        b = isAccessibleElement(classElement, 'GetAccess', 'SetAccess');
    case 'events'
        b = isAccessibleElement(classElement, 'ListenAccess', 'NotifyAccess');
    end
end

function b = isAccessibleElement(classElement, accessField1, accessField2)
    if classElement.Hidden
        b = false;
    else
        b = isAccessibleAccess(classElement.(accessField1)) || ...
            nargin > 2 && isAccessibleAccess(classElement.(accessField2));
    end
end

function b = isAccessibleAccess(acc)
    b = ischar(acc) && ~strcmp(acc, 'private') && ~strcmp(acc, 'none');
end

%   Copyright 2012 The MathWorks, Inc.
