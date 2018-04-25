classdef FileSystemCache < handle

    properties (Access=private)
        typeCache
    end

    methods
        function obj = FileSystemCache
            obj.typeCache = containers.Map('KeyType', 'char', ...
                                            'ValueType', 'any');
        end

        function tp = Type(obj, name)
            tp = [];
            if isKey(obj.typeCache, name)
                tp = obj.typeCache(name);
            end
        end
        
        function cacheType(obj, w, tp)
            if iscell(w)
                for k = 1:numel(w)
                    % Don't cache empty WHICH result
                    if ~isKey(obj.typeCache, w{k}) && ~isempty(w{k})
                        obj.typeCache(w{k}) = tp;
                    end
                end
            else
                % Don't cache empty WHICH result
                if ~isKey(obj.typeCache, w) && ~isempty(w)
                    obj.typeCache(w) = tp;
                end
            end
        end
        
    end % Public Methods

end
