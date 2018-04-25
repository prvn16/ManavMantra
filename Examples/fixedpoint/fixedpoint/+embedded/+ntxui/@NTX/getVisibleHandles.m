function visibleHandles = getVisibleHandles(ntx)
%GETVISIBLEHANDLES Returns an array of graphical handles that should not be
%visible at launch time. These will be made visible once data is processed.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2013/09/10 10:00:36 $


visibleHandles = [ntx.hHistAxis ntx.hlOver ntx.hlUnder ntx.htOver,...
    ntx.htUnder ntx.hlRadixLine ntx.hlWordSpan ntx.htWordSpan,...
    ntx.htIntSpan ntx.htFracSpan ntx.htXLabel,...
    ntx.htTitle ntx.htSigned]; 
visibleHandles = visibleHandles(isgraphics(visibleHandles)); %ishghandle(visibleHandles)

dialogVisibleHandles = getVisibleHandles(ntx.dp);

visibleHandles = [visibleHandles dialogVisibleHandles];


% [EOF]
