classdef RSetTileManager < handle
    
    % Copyright 2008-2014 The MathWorks, Inc.

    properties (SetAccess = 'public',GetAccess = 'public')

        dataStore
    
        mag
        center
        current_tiles
        
        fig
        ax
        image_array
        sp_api
        
        tiles_on_screen
        
        rows_last
        cols_last
        level_last
        
    end % properties
    
    methods (Access = 'public')
        
        function obj = RSetTileManager(rset,hFig,sp_api)
            %RSetViewer Constructor for RSet.
            
            % object properties
            obj.dataStore = rset;
            obj.fig = hFig;
            obj.ax  = findall(obj.fig,'type','axes');
            obj.sp_api = sp_api;

            obj.image_array = [];
            obj.current_tiles = logical([]);
            
            % initial view, 100% mag @ center
            obj.mag = 1;
            obj.center = [obj.dataStore.getFullWidth obj.dataStore.getFullHeight]/2;
            
            obj.image_array = struct('h_im',{},'row',{},'col',{});
            
        end % constructor
        
        
        function updateView(obj,varargin)
            
            % obj.updateViewWithScrollpanel();
            if isempty(varargin)
                obj.updateViewNewest(false);
            else
                obj.updateViewNewest(varargin{1});
            end
                
             
        end % updateView
        
        
        function updateViewNewest(obj,~)
            
            vis_rect = obj.sp_api.getVisibleImageRect();
            obj.mag  = obj.sp_api.getMagnification();
            
            % Add 20% padding on each side so that almost-in-view tiles are
            % loaded into memory for better panning performance.
            extra_width = 0.2 * vis_rect(3);
            extra_height = 0.2 * vis_rect(4);
            
            xlim = [vis_rect(1)-extra_width vis_rect(1)+vis_rect(3)+extra_width];
            ylim = [vis_rect(2)-extra_height vis_rect(2)+vis_rect(4)+extra_height];
           
            view_level = getRLevel(obj.mag,obj.dataStore.getMaxLevel);
            
            % getSpanningTiles() must ensure the 20% padding doesn't extend
            % beyond the image size.
            [rows, cols] = obj.dataStore.getSpanningTiles(view_level, xlim, ylim);
            
            obj.removeTilesOutOfView(view_level,rows,cols);
            
            if view_level ~= obj.dataStore.getMaxLevel
                obj.createTilesNewToView(view_level,rows,cols);
            end
            
            obj.rows_last  = rows;
            obj.cols_last  = cols;
            obj.level_last = view_level;
            
            % make sure our non-image objects are visible
            other_objs = findall(obj.ax,'type','hggroup');
            for i = 1:numel(other_objs)
                uistack(other_objs(i),'top');
            end
           
        end
        
        function createTilesNewToView(obj,view_level,rows,cols)
           
            for r = rows
                for c = cols
                    tile_on_screen = false;
                    for i = 1:numel(obj.image_array)
                        if (obj.image_array(i).row == r) && ...
                           (obj.image_array(i).col == c)
                            tile_on_screen = true;
                            break
                        end
                    end
                    if ~tile_on_screen
                        %fprintf('creating tile %d %d\n',r,c);
                        obj.image_array(end+1) = obj.createTile(view_level,r,c);
                    end
                end
            end
                               
        end
             
        function updateViewWithScrollpanel(obj)
            
            vis_rect = obj.sp_api.getVisibleImageRect();
            obj.mag  = obj.sp_api.getMagnification();
            
            xlim = [vis_rect(1) vis_rect(1)+vis_rect(3)];
            ylim = [vis_rect(2) vis_rect(2)+vis_rect(4)];
            
           
            view_level = getRLevel(obj.mag,obj.dataStore.getMaxLevel);
            
            [rows, cols] = obj.dataStore.getSpanningTiles(view_level, xlim, ylim);
            
            for i = 1:numel(obj.image_array)
                delete(obj.image_array(i));
            end
            obj.image_array = [];
            
            i = 0;
            for r = rows
                for c = cols
                    i = i+1;
                    obj.image_array(i) = obj.createTile(view_level,r,c);
                end
            end
            
        end % updateViewWithScrollpanel
        
        function removeTilesOutOfView(obj,level_current,rows_current,cols_current)
             
            if isempty(obj.image_array)
                return
            end
            
            if level_current ~= obj.level_last
                for i = 1:numel(obj.image_array)
                    %fprintf('deleting %d %d',obj.image_array(i).row,obj.image_array(i).col);
                    delete(obj.image_array(i).h_im);
                end
                obj.image_array = struct('h_im',{},'row',{},'col',{});

            else
                rows_out_view = setdiff(obj.rows_last,rows_current);
                cols_out_view = setdiff(obj.cols_last,cols_current);
                %same r-level
                tiles_to_delete = false(1,numel(obj.image_array));
                for i = 1:numel(obj.image_array)
                    tile_out_view = any(obj.image_array(i).row == rows_out_view) ||...
                                    any(obj.image_array(i).col == cols_out_view);
                                    
                    if tile_out_view
                        %fprintf('deleting %d %d\n',obj.image_array(i).row,obj.image_array(i).col);
                        tiles_to_delete(i) = true;
                    end
                end
                
                if any(tiles_to_delete)
                    tiles_ind = find(tiles_to_delete);
                    for i = 1:numel(tiles_ind)
                        delete(obj.image_array(tiles_ind(i)).h_im);
                    end
                    obj.image_array(tiles_to_delete) = [];
                end
           
            end
             
        end
        
    end % public methods
    
    
    methods (Access = 'private')
        
        function im_struct = createTile(obj,view_level,r,c)
                  
            [tile_data, xdata, ydata] = obj.dataStore.getTile(view_level, r, c);
            map = obj.dataStore.getColormap();

            h_im = image(...
                'Parent',obj.ax,...
                'CData',tile_data,...
                'XData',xdata,...
                'YData',ydata,...
                'HitTest','off',...
                'PickableParts','none',...
                'Tag','RSetTile',...
                'HandleVisibility','off');
            
            % set cdatamapping
            if ~isempty(map)
                % Indexed
                set(h_im,'CDataMapping','direct');
            elseif ismatrix(tile_data)
                % Grayscale
                set(h_im, 'CDataMapping', 'scaled');
            end
           
            im_struct.h_im = h_im;
            im_struct.row  = r;
            im_struct.col  = c;
            
        end % createTile

    end % private methods
    
end % classdef


function view_level = getRLevel(mag,max_level)

view_level = floor(log2(1/mag));
view_level = max(view_level,0);
view_level = min(view_level,max_level);

end







