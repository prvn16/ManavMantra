function itemsToSnap = compareFigures(oldItems, newItems)
%COMPAREFIGURES	Compare figures to baseline.
%   COMPAREFIGURES lists the figures or systems that have changed.

% Copyright 1984-2017 The MathWorks, Inc.

% The publishing tools use this 

% OLDITEMS and NEWITEMS are structures returned by CAPTUREFIGURES or
% SNAPNOW>CAPTURESYSTEMS, which are assumed to have the following
% structure:
%
% x.id is a row vector of numeric handles, or names in a cell array 
% x.data(k) is data that describes x.id(k).
%
% If corresponding data is equal between new and old items, the figure or 
% system is assumed to be unchanged. 

% Set this global variable and PUBLISH displays debugging info.
global PUBLISHING_DEBUGGING_FLAG
if isempty(PUBLISHING_DEBUGGING_FLAG)
    debug = false;
else
    debug = PUBLISHING_DEBUGGING_FLAG;
end

% For compatibility with previous versions
if nargin == 1
    newItems = internal.matlab.publish.captureFigures;
end

% Assume (for now), that old figures have no changes.
oldId = oldItems.id;
newId = newItems.id;
[unchanged, iNewToOld] = ismember(newId, oldId);

if debug
    debugDispNew(newItems, unchanged)
end

% Check old figures in detail.
for iNew = find(unchanged)
    iOld = iNewToOld(iNew);
    
    unchanged(iNew) = isequaln( ...
        oldItems.data(iOld), newItems.data(iNew));
    
    if debug
        debugDispChanges(oldItems, iOld, newItems, iNew, unchanged)
    end
end

% Form list of those that have changed.
itemsToSnap = newItems.id(~unchanged);

% If it is empty, this file probably created it.  Clean it up.
if isempty(PUBLISHING_DEBUGGING_FLAG)
    clear global PUBLISHING_DEBUGGING_FLAG
end

end

%===============================================================================
function structdiff(s1, s2)

n1 = inputname(1);
if isempty(n1)
    n1 = 'x1';
end
n2 = inputname(2);
if isempty(n2)
    n2 = 'x2';
end

dpm('BeginDifferences');
csubstrs = {};
lineCount = 0;
lineCountCutoff = 20;
traverse(s1, s2);
if lineCount >= lineCountCutoff
    dpm('Possibly More');
end
dpm('EndDifferences');

    function traverse(s1, s2)   
        if lineCount >= lineCountCutoff
            return;
        end
        
        substr = [csubstrs{:}];        
      
        if isstruct(s1) && isstruct(s2)
            recurseFlag = true;
            
            if ~isequal(size(s1), size(s2))
                dispSizes(n1, s1);
                dispSizes(n2, s2);
                
                recurseFlag = false;
            end
                        
            f1 = fieldnames(s1);
            f2 = fieldnames(s2);
            fc = intersect(f1, f2);

            if numel(fc) ~= numel(f1) || numel(fc) ~= numel(f2)
                dispExtraFields(n1, f1, fc);
                dispExtraFields(n2, f2, fc);
                
                recurseFlag = false;
            end
            
            if recurseFlag
                for i = 1:numel(s1)
                    for j = 1:numel(f1)
                        csubstrs{end + 1} = sprintf('(%d).%s', i, f1{j}); %#ok<AGROW>
                        traverse(s1(i).(f1{j}), s2(i).(f1{j}));
                        csubstrs(end) = [];
                    end
                end                    
            end
            
        elseif iscell(s1) && iscell(s2)
            if ~isequal(size(s1), size(s2))                
                dispSizes(n1, s1);
                dispSizes(n2, s2);
            else
                for i = 1:numel(s1)
                    csubstrs{end + 1} = sprintf('{%d}', i); %#ok<AGROW>
                    traverse(s1{i}, s2{i});
                    csubstrs(end) = [];
                end                              
            end            
            
        elseif isequaln(s1, s2)
            % Items are equal.  Do nothing.

        else      
            dispValues(n1, s1)
            dispValues(n2, s2)
            
        end
        
            function dispSizes(n, s)
                fprintf('%s%s: %s %s\n', ...
                    n, substr, class(s), mat2str(size(s)));
                lineCount = lineCount + 1;
            end

            function dispExtraFields(n, f, fc)                                
                extra = setdiff(f, fc);
                if numel(extra) > 1
                    extra = extra(:)';
                    extra(2, :) = {', '};
                    extra{end} = '';
                    fprintf('%s%s: ++ %s\n', ...
                        n, substr, [extra{:}]);
                    lineCount = lineCount + 1;
                end
            end    
            
            function dispValues(n, s)
                fprintf('%s%s: ', n, substr);
                str =  '';
                if isnumeric(s) && size(s, 1) == 1
                    str = sprintf(' %0.20g', s);
                    str(1) = '[';
                    str(end + 1) = ']';
                elseif ismatrix(s) && (ischar(s) || isnumeric(s))
                    str = mat2str(s);
                end
                
                if isempty(str) || numel(str) > 100
                    fprintf('%s %s\n', class(s), mat2str(size(s)));
                else
                    fprintf('%s\n', str);                    
                end
                lineCount = lineCount + 1;
            end  
          
    end
end

%===============================================================================
function debugDispNew(newItems, unchanged) 

for iNew = find(~unchanged)
    id = newItems.id(iNew);
    if iscellstr(id)
        dpm('NewSystem',id{1})
    else
        dpm('NewFigure',sprintf('%f',double(id)), get(id,'Name'))
    end
end

end

%===============================================================================
function debugDispChanges(oldItems, iOld, newItems, iNew, unchanged)

id = newItems.id(iNew);
if ~unchanged(iNew)
    if ischar(id)
        dpm('ChangedSystem',id{1})
    else
        dpm('ChangedFigure',sprintf('%f',double(id)), get(id,'Name'))
    end    
    oldData = oldItems.data(iOld);
    newData = newItems.data(iNew);    
    structdiff(oldData, newData);
end

end

%===============================================================================
function m = pm(id,varargin)
m = message(['MATLAB:publish:' id],varargin{:});
end

%===============================================================================
function s = spm(id,varargin)
s = getString(pm(id,varargin{:}));
end

%===============================================================================
function dpm(id,varargin)
disp(spm(id,varargin{:}));
end
