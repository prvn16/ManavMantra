function scriberestoresavefcns
%SCRIBERESTORESAVEFCNS Plot Editor helper function

%   Copyright 1984-2002 The MathWorks, Inc. 

if isappdata(gcbo,'ScribeSaveFcns')
   saveFcns = getappdata(gcbo,'ScribeSaveFcns');
   set(gcbo,'ButtonDownFcn',saveFcns);
end