function parser = strictInputParser()
% This function is undocumented and may change in a future release.

% strictInputParser is an inputParser with:
%  * partial matching off
%  * struct expanding off
%  * case sensitivity off (since we do not see a need to be case sensitive)

% Copyright 2016 The MathWorks, Inc.

parser = inputParser();
parser.PartialMatching = false;
parser.StructExpand = false;
end