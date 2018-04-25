function createtoolbar(h)
%CREATETOOLBAR   

%   Copyright 2006-2013 MathWorks, Inc.

% tb = createtoolbar_file(h);
% tb.addSeparator;

tb = createtoolbar_launchfpa(h);
tb.addSeparator;

tb = createtoolbar_collectdata(h, tb);
tb.addSeparator;

tb = createtoolbar_scale(h, tb);
tb.addSeparator;

tb = createtoolbar_result(h, tb);
tb.addSeparator;

createtoolbar_search(h);




% [EOF]
