function h = dataChangeEvent(hSrc,Action,Ind)
%DataChangeEvent  Subclass of EVENTDATA to handle tree structure changes

%   Copyright 2005 The MathWorks, Inc.


% Create class instance
h = tsdata.dataChangeEvent(hSrc,'datachange');
set(h,'Action',Action,'Index',Ind);
