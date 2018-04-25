function [extractedArgs,remainingArgs] = extractParameterArguments(input,varargin)
% This function is undocumented and may change in a future release

%  Copyright 2017 The MathWorks, Inc.

parser = inputParser();
parser.KeepUnmatched = true;
parser.StructExpand = false;
parser.PartialMatching = false;
parameterNames = cellstr(input);
cellfun(@(paramName) parser.addParameter(paramName,[]),parameterNames);

parser.parse(varargin{:});
extractedArgs = structToArguments(rmfield(parser.Results,parser.UsingDefaults));
remainingArgs = structToArguments(parser.Unmatched);
end


function args = structToArguments(s)
args = reshape([fieldnames(s), struct2cell(s)].', 1, []);
end