function creatui(h)
%CREATUI   Create the Fixed-Point Tool User Interface.

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.

customize(h);
createviewmanager(h);
createactions(h);
createmenu(h);
createtoolbar(h);
updateactions(h);

% [EOF]
