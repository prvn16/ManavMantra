function propVal = getBehaviorObjectProperty(h,behavior,propName)

% This static method is called from java to obtain behavior object
% property values. This code may be modified in future releases.

%  Copyright 2015 The MathWorks, Inc.

bh = hggetbehavior(h,behavior,'-peek');
if isempty(bh)
    propVal = [];
    return
end
propVal = bh.(propName);