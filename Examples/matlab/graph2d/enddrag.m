function enddrag(HG)
%ENDDRAG  Plot Editor helper function

%   Copyright 1984-2002 The MathWorks, Inc. 

ud = getscribeobjectdata(HG);
enddrag(ud.HandleStore);
