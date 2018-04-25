function addPropertyIfChanged(hCode, propname, defaultValue)
%addPropertyIfChanged Add a property if the user has changed it
%
%  addPropertyIfChanged(hCode, Prop, DefValue) adds the specified property
%  if the user appears to have changed it from the given default value. If
%  the property has not been altered then it is removed from code
%  generation.

%  Copyright 2012-2014 The MathWorks, Inc.

hObj = hCode.MomentoRef.ObjectRef;
ModeProp = [propname 'Mode'];
if isprop(hObj, ModeProp)
    % There is a Mode property that probably indicates if the user has
    % actually altered the property, so use that instead.
    if strcmpi(hObj.(ModeProp),'auto')
        ignoreProperty(hCode, propname);
    else
        addProperty(hCode, propname);
    end
else
    Val = get(hObj, propname);
    if isequal(Val, defaultValue)
        ignoreProperty(hCode, propname);
    else
        addProperty(hCode, propname);
    end
end
