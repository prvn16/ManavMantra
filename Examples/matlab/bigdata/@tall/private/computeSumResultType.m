function outType = computeSumResultType(inType, precisionFlagCell)
%computeSumResultType compute the class of the result of SUM
%   outType = computeSumResultType(inType, precisionFlagCell)
%   inType is a class name, or '' if not known
%   precisionFlagCell is {'default'} or {} or similar
%   outType is a class name, or '' if not known.

% Copyright 2016 The MathWorks, Inc.

if strcmp(inType, 'duration') || isequal(precisionFlagCell, {'native'})
    % durations are always the same as 'native'
    outType = inType;
elseif isequal(precisionFlagCell, {'double'})
    outType = 'double';
elseif isequal(precisionFlagCell, {'default'})
    % 'default' generally means 'double', unless the input is 'single'. However, if
    % inType isn't known, it *might* be single, so we can't specify the output
    % in that case.
    if strcmp(inType, 'single')
        outType = inType;
    elseif ~isempty(inType)
        % The type is known not to be single - so 'default' means 'double'
        outType = 'double';
    else
        % Fall-back - inType might be single
        outType = '';
    end
else
    % Not known what the type is going to be
    outType = '';
end
end
