% This undocumented class may be removed in a future release.

%   Copyright 2009 The MathWorks, Inc.

classdef TileHandle < handle
    % Implements Tile Handle class
    %
    % If read is set to false then tile is written back to the file
    % when the object is destroyed or closed
    
    
    properties (Access = private)
        tifAdapter    %!< TiffAdapter object >
        readOnly      %!< If false, tiles are written to file when closed >
    end % properties
    
    properties (GetAccess = public, SetAccess = private)
        tileId        %!< Tile index associated, used by tileCache >
    end % properties
    
    properties (Access = public)
        tile          %!< Tile data >
    end % properties
    
    methods
        %------------------------------------------------------------------
        function obj = TileHandle(tifAdapter, tileId, readOnly, tileBuf)
            
            % This is needed to ensure proper cleanup in case of an error
            % in this functions later. Do not delete this.
            obj.readOnly = true;

            obj.tifAdapter = tifAdapter;
            obj.tileId = tileId;
            if nargin == 3
                % If this fails then object is cleaned properly
                obj.tile = tifAdapter.readBlock(tileId);
            elseif nargin == 4
                % Set a user supplied tile buffer. 
                obj.tile = tileBuf;
            end
            
            % Set correct readOnly in the end since everything went okay
            obj.readOnly = readOnly;
        end
        
        %------------------------------------------------------------------
        function delete(obj)
            obj.close();
        end
    end % methods
    
    methods (Access = private)
        %------------------------------------------------------------------
        function close(obj)
            % if it is a write cache then write the blocks back to the file
            if ~obj.readOnly
                obj.tifAdapter.writeBlock(obj.tileId, obj.tile);
                obj.readOnly = true;
            end
            obj.tileId = -1;
            obj.tifAdapter = [];
        end
    end % methods
    
end % class
