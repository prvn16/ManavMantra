%CacheEntryKey
% A key that corresponds with one set of cached entries resulting from a
% single execution task. Future executions that want to reuse the cache
% must hold onto this key and provide it in future tasks.
%
% Marking this key as invalid will delete all cache entries associated with
% this key. In addition, this will happen automatically once the key falls
% out of scope.

%   Copyright 2015-2017 The MathWorks, Inc.

classdef CacheEntryKey < handle
    properties (SetAccess = immutable)
        % The ID that represents this cache entry.
        Id;
    end
    
    properties (SetAccess = private, Transient)
        % Whether this key is still valid. This will be true at
        % construction and then set to false once cache entries are no
        % longer required or valid.
        IsValid (1,1) logical = false;
    end
    
    properties (SetAccess = private)
        % The ID string of the CacheEntryKey made obsolete by this
        % CacheEntryKey. This can be empty, which indicate no such key exists.
        OldId;
    end
    
    properties (Access = private, Constant)
        % The means by which this class receives unique IDs.
        IdFactory = matlab.bigdata.internal.util.UniqueIdFactory('CacheKey');
    end
    
    events
        % An event that is fired once this key becomes invalid.
        InvalidateEvent;
    end
    
    methods
        function obj = CacheEntryKey()
            % Construct a new CacheEntryKey with it's own new unique ID.
            obj.Id = obj.IdFactory.nextId();
            obj.IsValid = true;
        end
        
        function delete(obj)
            % Override of delete to ensure all cache entries are cleared on
            % delete.
            obj.markInvalid();
        end
        
        function addInvalidateListener(obj, fh)
            % Add a event listener for the InvalidateEvent event.
            obj.addlistener('InvalidateEvent', fh);
        end
        
        function markInvalid(obj)
            % Mark this CacheEntryKey as invalid. This will clear all
            % associated cache entries and prevent future cache entries
            % being stored.
            if obj.IsValid
                obj.IsValid = false;
                notify(obj, 'InvalidateEvent');
            end
        end
        
        function setOldKey(obj, oldKey)
            % Mark that all cache entries of the given CacheEntryKey should
            % be replaced by cache entries from this key.
            assert(isempty(obj.OldId), ...
                'Assertion failed: Attempted to set oldKey when already set.');
            obj.OldId = oldKey.Id;
        end
    end
end
