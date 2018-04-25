function out = invokeOutputInfo(outType, out, inCell)
%invokeOutputInfo Applies known information to an output

% Copyright 2016 The MathWorks, Inc.

if ~isempty(outType)
    switch outType
      case 'preserve'
        outType = iGetInTypeFromArgs(inCell);
      case 'preserveLogicalCharToDouble'
        outType = iGetInTypeFromArgs(inCell);
        if ismember(outType, {'logical', 'char'})
            outType = 'double';
        end
      case 'binaryArithmeticRule'
        assert(numel(inCell) <= 2);
        inClassNames = cellfun(@tall.getClass, inCell, 'UniformOutput', false);
        if isscalar(inClassNames)
            inClassNames = [inClassNames, inClassNames];
        end
        outType = calculateArithmeticOutputType(inClassNames{:});
    end
    out = setKnownType(out, outType);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function inType = iGetInTypeFromArgs(inCell)

adaptors = cellfun(@matlab.bigdata.internal.adaptors.getAdaptor, ...
                   inCell, 'UniformOutput', false);
inTypes  = unique(cellfun(@(ad) ad.Class, adaptors, 'UniformOutput', false));

% Note that if some of the arguments have unknown types, then we cannot
% deduce the output type, since that type might be superior to one of the
% known types. In particular, imagine combining a tall array containing
% single (but this information is lost) with a host-scalar-double. In that
% case, the output type is single - but we cannot know that.

if isscalar(inTypes)
    inType = inTypes{1};
else
    % Here we are imbuing this function with some knowledge about superiority of
    % types. Specifically, duration is superior to all other types when
    % combined, and double is inferior.
    inTypes = setdiff(inTypes, {'double'});
    if isscalar(inTypes)
        % double + something else, return the something else. This might cause problems
        % later it turned out that the non-double was the scalar, and the double
        % was an array. E.g. tall(rand(3)) + uint8(1)
        inType = inTypes{1};
    elseif ismember(inTypes, {'duration'})
        inType = 'duration';
    else
        % Hm, trouble. uint8+uint16 or similar. Return ''. 
        inType = '';
    end
end
end
