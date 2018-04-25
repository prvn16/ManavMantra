% This undocumented class may be removed in a future release.

% Implements tile based caching

%   Copyright 2009 The MathWorks, Inc.

classdef TileCache < handle
    
    properties (Access = private)
        numTiles  %!< Number of tiles cached >
        tiles     %!< Array of tileHandle objects of length numTiles >
        
        indexes   %!< Stores offsets within tiles with most recently used first >
        next      %!< index where next Tile will be placed >
    end % properties
    
    methods
        %------------------------------------------------------------------
        function obj = TileCache()
            obj.numTiles = 4;
            obj.indexes = 1:obj.numTiles;
            obj.tiles = struct('tileHandle', []);
            obj.tiles(2:obj.numTiles) = obj.tiles(1);
            obj.next = 1;
        end
        
        %------------------------------------------------------------------
        function result = getTile(obj, tileId)
            if (nargin ~= 2)
                error(message('images:TileCache:getRegion'));
            end
            
            for i = 1 : obj.numTiles
                if isempty(obj.tiles(obj.indexes(i)).tileHandle)
                    % reached end
                    break
                elseif obj.tiles(obj.indexes(i)).tileHandle.tileId == tileId
                    % found a match
                    result = obj.tiles(obj.indexes(i)).tileHandle;
                    
                    % update the most recently used
                    tmp = obj.indexes(i);
                    obj.indexes(2:i) = obj.indexes(1:i - 1);
                    obj.indexes(1) = tmp;
                    return
                end
            end
            result = [];
        end
        
        %------------------------------------------------------------------
        function [] = setTile(obj, tileHandle)
            
            % Note setTile should only be called if getTile returns an
            % empty array. This is needed to prevent any duplicate keys.
            % Since no check is done here it is more efficient than testing
            % the presence of a region in both get and set.
            if (nargin ~= 2)
                error(message('images:TileCache:setRegion'));
            end
            if (obj.numTiles == 0)
                return;
            end
            
            % Make a place for new tile at the head of the list
            ind = obj.indexes(obj.next);
            obj.indexes(2:obj.next) = obj.indexes(1:obj.next - 1);
            obj.next = min(obj.next + 1, obj.numTiles);
            % Store new tileHandle and index
            obj.indexes(1) = ind;
            obj.tiles(ind).tileHandle = tileHandle;
        end
        
        %------------------------------------------------------------------
        function close(obj)
            % This also will flush any tiles to the file
            obj.tiles = [];
        end
    end % methods
    
end % class
