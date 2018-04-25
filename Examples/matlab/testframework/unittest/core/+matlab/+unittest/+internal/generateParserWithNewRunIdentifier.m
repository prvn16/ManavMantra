function parser = generateParserWithNewRunIdentifier()
% This function is undocumented and may change in a future release.

% Copyright 2016-2017 The MathWorks, Inc.
import matlab.unittest.internal.generateUUID;
parser = matlab.unittest.internal.strictInputParser;
parser.addParameter('RunIdentifier',generateUUID(),@isUUID);
end


function bool = isUUID(value)
bool = isa(value,'string') && isscalar(value) && ~isempty(regexp(value,...
    '^[a-f\d]{8}\-(?:[a-f\d]{4}\-){3}[a-f\d]{12}$', 'once'));
end