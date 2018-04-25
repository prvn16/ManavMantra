function w = cacheWhich(name, pth)
% cacheWhich caches results of WHICH for reuse (higher performance)
%
% Three valid signatures:
%
%   w = cacheWhich(name) 
%       Look up name in the cache. If name isn't found, call WHICH and store
%       the result in the cache.
%
%   cacheWhich(name, pth)
%       Preload the cache, binding name to path.
%
%   cacheWhich()
%       Clear the cache (by creating a new, empty one).

persistent whichCache symCheckList

    function preload(cache, key, value)
        cache(key) = value; %#ok
    end

    if nargin == 1
        if isKey(whichCache, name)
            import matlab.depfun.internal.requirementsConstants            
            
            w = whichCache(name);

            if ~isKey(symCheckList, name) && ~isempty(strfind(w, ...
                    requirementsConstants.BuiltInStrAndATrailingSpace))
                % Try to find the first non-builtin user file before the
                % pre-cached built-in on the MATLAB path.
                w_nonBuiltIn = whichNonBuiltin(name, w);
                if ~isempty(w_nonBuiltIn)
                    % update the lookup table with the correct builtin info
                    whichCache(name) = w_nonBuiltIn;
                    w = w_nonBuiltIn;
                end
                % make a note so that we don't spend time on the same
                % built-in again for performance.
                symCheckList(name) = true;
            end
        else
            % WHICH may error when the symbol is not a MATLAB file.
            % WHICH does not always return empty string if it fails to 
            % find the given symbol. (G1155267)
            try
                % G1133654: WHICH looks for variables in the workspace and   
                % private functions prior to functions, classes, etc
                w = matlab.depfun.internal.which.callWhich(name);
            catch
                w = '';
            end
            whichCache(name) = w;
            symCheckList(name) = true;
        end
    elseif nargin == 2
        % Preload the cache. Make sure name and pth are cell arrays.
        if ~iscell(name), name = { name }; end
        if ~iscell(pth), pth = { pth }; end
        cellfun(@(key,value)preload(whichCache, key, value), name, pth);            
    elseif nargin == 0
        if isempty(whichCache) || nargout == 0
            whichCache = containers.Map('KeyType', 'char', 'ValueType', 'any');
            symCheckList = containers.Map('KeyType', 'char', 'ValueType', 'logical');
        end
        if nargout == 1
            w = length(whichCache);
        end
    end
end
