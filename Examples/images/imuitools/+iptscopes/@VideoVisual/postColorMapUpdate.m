function postColorMapUpdate(this,~)
%POSTCOLORMAPUPDATE   Update the display after a change in color map

%   Copyright 2009-2015 The MathWorks, Inc.

% Get the current data and update
source= this.Application.DataSource;
if ~isempty(source)
    update(this);
    postUpdate(this);
end

% [EOF]