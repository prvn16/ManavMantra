function [ax,args,nargs] = axesCheck(varargin)
%AXESCHECK Process Axes objects from input list
%   This version just wraps the standard version but avoids problems with
%   tall array inputs.

%    Copyright 1984-2016 The MathWorks, Inc.

% Find all tall array inputs and replace them with place-holders
[args,map] = iReplaceTallArgs(varargin);

% Call standard axescheck
[ax,args,nargs] = axescheck(args{:});

% put the tall arrays back
args = iReintroduceTallArgs(args, map, varargin);

end % axescheck


function [args,map] = iReplaceTallArgs(args)
% replace tall inputs with placeholders and return both the modified
% argument list and the map for putting them back again.
tallIdxs = find(cellfun(@istall, args));
map = cell(numel(tallIdxs),2);
for ii=1:numel(tallIdxs)
    placeholder = string('TallArray_Placeholder_')+ii;
    map(ii,:) = {placeholder, tallIdxs(ii)};
    args{tallIdxs(ii)} = placeholder;
end     
end


function finalArgs = iReintroduceTallArgs(args, map, origArgs)
% Replace placeholders with the original inputs
finalArgs = args;
for ii=1:size(map,1)
    placeholder = map{ii,1};
    origIdx = map{ii,2};
    newIdx = find(cellfun(@(x) isequal(x, placeholder), args), 1, 'first');
    finalArgs{newIdx} = origArgs{origIdx};
end
end
