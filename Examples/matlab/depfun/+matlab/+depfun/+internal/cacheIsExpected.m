function [e, w] = cacheIsExpected(Schema, Target, file)
% cacheIsExpected caches results of ISEXPECTED for reuse (higher performance)
%
% ie = cacheIsExpected(file)
%
%   cacheIsExpected
%     Clear the cache (by creating a new, empty one).

persistent isExpectedCache

if nargin == 0
    isExpectedCache = containers.Map('KeyType', 'char', ...
                                     'ValueType','any');
else
    if ischar(file)
        file = {file};
    end
    
    num_files = numel(file);
    e = false(1,num_files);
    w = struct([]);
        
    for i = 1:numel(file)
        if isKey(isExpectedCache, file{i})
            ie = isExpectedCache(file{i});
            e(i) = ie.expeto;
            w(i).identifier = ie.why.identifier;
            w(i).message = ie.why.message;
            w(i).rule = ie.why.rule;
        else
            [e(i), tmp] = isExpected(Schema, Target, file{i});
            
            if isempty(tmp)
                w(i).identifier = '';
                w(i).message = '';
                w(i).rule = '';
            else
                w(i).identifier = tmp.identifier;
                w(i).message = tmp.message;
                w(i).rule = tmp.rule;
            end
            
            ie = struct('expeto',e(i),'why',w(i));
            isExpectedCache(file{i}) = ie;
        end
    end
end