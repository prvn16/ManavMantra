function ex = cacheExist(name, type)
% cacheExist caches results of EXIST for reuse (higher performance)
% Since the answer may vary depending on the input TYPE, cache both the
% type and value. Recompute the answer every time the type changes.
%
% Name may be a cell array of names, in which case simply iterate over the
% cell array.
%
% ex = cacheExist(name, [type])
%
%   cacheExist()
%     Clear the cache (by creating a new, empty one).
%
% Cache a structure with fields 'type' and 'value'. 

persistent existCache

if nargin == 0
    existCache = containers.Map('KeyType', 'char', 'ValueType', 'any');
else

    if iscell(name)
        % By default, not found.
        ex = zeros(1,numel(name));
        
        % Determine which input names have a key in the cache.
        hasKey = isKey(existCache, name);
        cachedIdx = find(hasKey);
        cached = name(hasKey);
        search = ~hasKey;

        % Look in the cache for files known to match an existing key.
        for n=1:numel(cached)
            cache = existCache(cached{n});
            if strcmp(type, cache.type) == 1
                ex(cachedIdx(n)) = cache.value;  
            else
                % Cache type didn't match, must check file system
                search(cachedIdx(n)) = true;
            end
        end
        
        % If we're looking for files or directories, we can optimize by
        % calling existFile, which is at least 100 times faster than exist.
        searchIdx = find(search);
        fullPath = false(1,numel(search));
        unknown = name(search);
        if type(1) == 'f' || type(1) == 'd'
            for n=1:numel(unknown)
                pth = unknown{n};
                if  ~isempty(pth) && ...
                    (pth(1) == '\' || pth(1) == '/' || ...
                    (numel(pth) > 3 && pth(2) == ':' && ...
                    (pth(3) == '\' || pth(3) == '/')))
                    fullPath(searchIdx(n)) = true;
                    search(searchIdx(n)) = false;
                end
            end
            cv = existFile(name(fullPath), type(1) == 'd');
            ex(fullPath) = cv;
            cache = struct('value',num2cell(cv),'type',type);
            fullPathIdx = find(fullPath);
            for n=1:numel(cache)
                existCache(name{fullPathIdx(n)}) = cache(n);
            end
        end
        
        unknown = name(search);
        cache = [];
        % For all the rest, we must call exist.
        for n = 1:numel(unknown)
            cache.type = type;
            cache.value = exist(unknown{n}, type);
            existCache(unknown{n}) = cache;
            ex(searchIdx(n)) = cache.value;
        end
    else
        % Presume there is no cached structure for the input name.
        cache = [];
        if isKey(existCache, name)
            cache = existCache(name);
        end
        
        % If we found a cached structure and the type matches, return the value.
        % Otherwise, compute a new value and update the cache.
        if ~isempty(cache) && strcmp(type, cache.type) == 1
            ex = cache.value;
        else
            cache.type = type;
            % existFile only works on full paths. Check for UNIX and Windows
            % absolute path prefixes. Returns 2 for files, 7 if the full path
            % points to a directory.
            if (type(1) == 'f' || type(1) == 'd') && (~isempty(name) && ...
                    (name(1) == '\' || name(1) == '/' || ...
                    (numel(name) > 3 && name(2) == ':' && ...
                    (name(3) == '\' || name(3) == '/'))))
                cache.value = existFile(name, type(1) == 'd');
            else
                cache.value = exist(name, type);
            end
            
            existCache(name) = cache;
            ex = cache.value;
        end
    end
end
