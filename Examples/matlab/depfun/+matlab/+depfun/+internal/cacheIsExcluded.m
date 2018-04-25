function [v, w] = cacheIsExcluded(varargin)
% cacheIsExcluded caches results of ISEXCLUDED for reuse (higher performance)
%
% ie = cacheIsExcluded(file)
%
%   cacheIsExcluded()
%     Clear the cache (by creating a new, empty one).
%   cacheIsExcluded(DBName, Target)
%     Cache the exclusion list from dfdatabase
%   cacheIsExcluded(Schema, Target, file, useExclusionListFromDB)
%     check if file(s) should be excluded or not. 

persistent isExcludedCache
persistent cachedExclusionList

if nargin == 0
    isExcludedCache = containers.Map('KeyType', 'char', ...
                                     'ValueType','any');
elseif nargin == 2
    DBName = varargin{1};
    target = varargin{2};
    % connect to the merged database
    dd = matlab.depfun.internal.DependencyDepot(DBName, true); % readonly
    % retrieve the exclusion list from the merged database
    list = dd.getExclusion(target);
    % disconnect the database
    dd.disconnect();
    
    if ~isempty(list)
        % convert relative path to full path
        list = strcat(matlabroot,filesep,regexprep(list,'\/',filesep));
        % cache the exclusion list
        cachedExclusionList = containers.Map(list,true(numel(list),1));
    else
        cachedExclusionList = containers.Map('KeyType', 'char', ...
                                             'ValueType','logical');
    end
else
    schema = varargin{1};
    target = matlab.depfun.internal.Target.int(varargin{2});
    file = varargin{3};
    useExclusionListFromDB = varargin{4};
    
    if ischar(file)
        file = {file};
    end
    
    num_files = numel(file);
    v = false(1,num_files);
    w = struct([]);
    
    for i = 1:num_files
        if isKey(isExcludedCache, file{i})
            ie = isExcludedCache(file{i});
            v(i) = ie.verboten;
            w(i).identifier = ie.why.identifier;
            w(i).message = ie.why.message;
            w(i).rule = ie.why.rule;
        else
            if useExclusionListFromDB
                if isKey(cachedExclusionList, file{i})
                    v(i) = true;
                    % reason for exclusion
                    msg = schema.getExclusionReason(target);
                    msg = msg{1};
                    w(i).identifier = msg.identifier;
                    w(i).message = msg.message;
                    w(i).rule = msg.rule;
                end
            end
            
            if ~v(i)
                [v(i), tmp] = isExcluded(schema, target, file{i});
                if isempty(tmp)
                    w(i).identifier = '';
                    w(i).message = '';
                    w(i).rule = '';
                else
                    w(i).identifier = tmp.identifier;
                    w(i).message = tmp.message;
                    w(i).rule = tmp.rule;
                end
            end
            
            ie = struct('verboten',v(i),'why',w(i));
            isExcludedCache(file{i}) = ie;
        end
    end
end