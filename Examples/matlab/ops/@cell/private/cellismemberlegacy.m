function [lia,locb] = cellismemberlegacy(a,b,flag1,flag2)
% CELLISMEMBERLEGACY Legacy implementation for cellismember.
%   Acceptable input combinations with optional inputs denoted in []:
%   ISMEMBER(A,B, {['rows'], ['legacy'/'R2012a']})

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin == 2
    [lia,locb] = cellismemberlegacy_local(a,b);
else
    nflagvals = 3;
    flagvals = ["rows" "legacy" "R2012a"];
    % When a flag is found, note the index into varargin where it was found
    flaginds = zeros(1,nflagvals);
    for i = 3:nargin
        if i == 3
            flag = flag1;
        else
            flag = flag2;
        end
        foundflag = matlab.internal.math.partialMatchString(flag, flagvals);
        if ~any(foundflag)
            if ischar(flag) || isstring(flag)
                error(message('MATLAB:ISMEMBER:UnknownFlag',flag));
            else
                error(message('MATLAB:ISMEMBER:UnknownInput'));
            end
        end
        % Only 1 occurrence of each allowed flag value
        if flaginds(foundflag)
            error(message('MATLAB:ISMEMBER:RepeatedFlag',flag));
        end
        flaginds(foundflag) = i;
    end
    % Only 1 of each of the paired flags
    if flaginds(2) && flaginds(3)
        error(message('MATLAB:ISMEMBER:BehaviorConflict'))
    end
    % 'legacy' and 'R2012a' flags must be trailing
    if flaginds(3) && flaginds(3) ~= nargin
        error(message('MATLAB:ISMEMBER:R2012aTrailing'))
    end
    if flaginds(2) && flaginds(2) ~= nargin
        error(message('MATLAB:ISMEMBER:LegacyTrailing'))
    end
    if flaginds(1)
        warning(message('MATLAB:ISMEMBER:RowsFlagIgnored')); 
    end
    
    if flaginds(2) % trailing 'legacy' specified
        [lia,locb] = cellismemberlegacy_helper(a,b);
    else % 'R2012a' (default behavior)
        [lia,locb] = ismember(a,b);
    end
end

end

function [tf,loc] = cellismemberlegacy_helper(a,s)
% 'legacy' flag implementation

if ~((ischar(a) || iscellstr(a)) && (ischar(s) || iscellstr(s)))
   error(message('MATLAB:ISMEMBER:InputClass',class(a),class(s)))
end

% convert input to cell arrays of strings
if ischar(a)
    a = cellstr(a);
end
if ischar(s)
    s = cellstr(s);
end

% handle special empty cases
if isempty(a) && isempty(s)
   tf = logical([]); % indefinite result. 
   loc = []; % indefinite result. 
   return
elseif length(s) == 1 && cellfun('isempty',s)
	tempTF = cellfun('isempty',a);
	if any(tempTF(:))
		tf = tempTF;				%in case where s is empty, a is found
								   %in s when a is empty      
		loc = double(tf);           %location = 1 since s has only one member
		return
	end
end

lS = cellfun('length',s);
lengthS = length(lS(:));
memS = max(lS(:)) * lengthS;

% work in chunks of at most 16Mb
maxMem = 8e6;
stepsS = ceil(memS/maxMem);
if memS 
   offset = ceil(lengthS/stepsS);
else
   offset = lengthS;
end

lengthA = numel(a);
tf = false(lengthA,1);
loc = zeros(lengthA,1);
chunkEnd  = lengthS;

while chunkEnd >0
    chunkStart = max(chunkEnd - offset,1);
    chunk = chunkStart:chunkEnd; 
    chunkEnd = chunkStart -1;
    % Only return required arguments from ISMEMBER.
    if nargout > 1
        [tfstep,locstep] = ismember(char(a),char(s(chunk)),'rows','legacy');
        loc = max(loc,(locstep + chunkStart - 1).*(locstep > 0));
    else
        tfstep = ismember(char(a),char(s(chunk)),'rows','legacy');
    end
    tf = tf | tfstep;
    if (all(tf))
        break;
    end
end

tf = reshape(tf,size(a));

if nargout > 1
    loc = reshape(loc,size(a));
end
end