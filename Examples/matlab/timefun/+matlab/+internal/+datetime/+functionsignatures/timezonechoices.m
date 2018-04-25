function choices = timezonechoices()
% TIMEZONECHOICES List timezones for use in DATETIME function signatures

%   Copyright 2017 The MathWorks, Inc.

t = timezones();
choices = [{'local'}, t.Name(:)'];
