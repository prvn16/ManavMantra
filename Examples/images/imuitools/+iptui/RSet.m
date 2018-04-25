classdef RSet < handle
    
    properties (SetAccess = 'private',GetAccess = 'private')
        
        filename_base
        filename_rset
        tile_size
        base_tiles
        max_level
        image_height
        image_width
        
        cmap
        
    end % properties
    
    
    methods (Access = 'public')

        function obj = RSet(filename)
            
            verifyRSetFile(filename);
            obj.filename_rset = getFullRSetFilename(filename);
            
            obj.filename_base = getBaseFilename(filename);
            
            [obj.image_height, obj.image_width] = loadImageDims(obj.filename_rset);
            obj.tile_size = loadTileSize(obj.filename_rset);
            obj.cmap = loadColormap(obj.filename_rset);

            obj.base_tiles = obj.computeBaseTiles();
            obj.max_level = loadMaxLevel(obj.filename_rset);
    
        end

        
        function [rows cols] = getSpanningTiles(obj, level, xlims, ylims)
        
            units_per_tile = obj.tile_size * (2 ^ level);
            
            % Find the maximum in-bound row and column tile numbers (zero-based).
            max_row_tile_at_level = getMaxTileNum(obj.base_tiles(1), obj.getFullHeight);
            max_col_tile_at_level = getMaxTileNum(obj.base_tiles(2), obj.getFullWidth);
            
            % Compute the spanning tiles, clamping to in-bound values.
            col_min = max(floor(xlims(1) / units_per_tile), 0);
            col_max = min(floor(xlims(2) / units_per_tile), max_col_tile_at_level);
            row_min = max(floor(ylims(1) / units_per_tile), 0);
            row_max = min(floor(ylims(2) / units_per_tile), max_row_tile_at_level);

            cols = col_min:col_max;
            rows = row_min:row_max;
            
            
            function maxTileNum = getMaxTileNum(baseTileSpan, imageDim)
                
                maxTileNum = baseTileSpan / (2 ^ level) - 1;
                maxTileNum = max(maxTileNum, 0);
                maxTileNum = min((floor(imageDim / units_per_tile)), maxTileNum);
                
            end
            
        end
        
        
        function [cdata, xdata, ydata] = getTile(obj, level, row, col)

            units_per_tile = obj.tile_size * (2 ^ level);
            
            dataset = sprintf('/RSetData/L%d/r%d_c%d', level, row, col);
            cdata = obj.readHDF5Tile(dataset);
            cdata = obj.trimTile(cdata, row, col, level, units_per_tile);
            
            cdata = squeezeTile(cdata);
            [xdata, ydata] = obj.getSpatialData(row, col, size(cdata), units_per_tile);
            
        end
        
        
        function cdata = trimTile(obj, cdata, row, col, level, units_per_tile)
            
            if ((((row+1) * units_per_tile - 1) <= obj.image_height) && ...
                (((col+1) * units_per_tile - 1) <= obj.image_width))
                return;
            end
            
            rowLocations = (row * units_per_tile) + ...
                           ((0:(obj.tile_size - 1)) * 2^level);
            colLocations = (col * units_per_tile) + ...
                           ((0:(obj.tile_size - 1)) * 2^level);
            maxRow = find((rowLocations < obj.image_height), 1, 'last');
            maxCol = find((colLocations < obj.image_width), 1, 'last');
            
            cdata = cdata(1:maxRow, 1:maxCol, :);
            
        end
        
        
        function [cdata, xdata, ydata] = getOverview(obj)
            
            level = obj.getMaxLevel();
            xLims = [0, obj.image_width-1];
            yLims = [0, obj.image_height-1];
            [rows, cols] = obj.getSpanningTiles(level, xLims, yLims);
            
            cdata = [];
            xdata = [inf -inf];
            ydata = [inf -inf];
            
            for r = rows
                for c = cols
                    
                    [tmpData, tmpXdata, tmpYdata] = obj.getTile(level, r, c);
                    xdata = [min(tmpXdata(1), xdata(1)), max(tmpXdata(2), xdata(2))];
                    ydata = [min(tmpYdata(1), ydata(1)), max(tmpYdata(2), ydata(2))];
                    
                    if (numel(rows) < numel(cols))
                        cdata = horzcat(cdata, tmpData); %#ok<AGROW>
                    else
                        cdata = vertcat(cdata, tmpData); %#ok<AGROW>
                    end
                end
            end
            
        end
        
        
        function maxLevel = getMaxLevel(obj)
        
            maxLevel = obj.max_level;
        
        end
        
        
        function cmap = getColormap(obj)
        
            cmap = obj.cmap;
        
        end
        
        
        function h = getFullHeight(obj)
        
            h = obj.image_height;
            
        end
        
        
        function w = getFullWidth(obj)
        
            w = obj.image_width;
            
        end
        
        
        function len = getTileSide(obj)
        
            len = obj.tile_size;
            
        end
        
        
        function meta = getRSetDetails(obj)
            
            if (~isempty(obj.filename_base))
                meta.BaseFile = obj.filename_base;
            else
                meta.BaseFile = sprintf('%s [missing]', ...
                                        loadBaseFilename(obj.filename_rset));
            end
            
            meta.ImageHeight    = obj.image_height;
            meta.ImageWidth     = obj.image_width;
            meta.TileSize       = [obj.tile_size obj.tile_size];
            meta.MaximumLevel   = obj.getMaxLevel;
            
        end
        
    end % public methods

    
    methods (Access = 'private')
        
        function [xdata,ydata] = getSpatialData(obj,row,col,cdata_size,units_per_tile)
            
            % TODO: Ask BH and AT whether this logic is correct now that
            % I'm clipping to the image boundary.
            
            
            % compute extent as if image origin is at (0,0)
            xlim = [col col+1] * units_per_tile;
            ylim = [row row+1] * units_per_tile;

            % clamp ydata for trimmed tiles
            if cdata_size(1) < obj.tile_size
                ylim(2) = ylim(1) + cdata_size(1) * units_per_tile / obj.tile_size;
            end
            % clamp xdata for trimmed tiles
            if cdata_size(2) < obj.tile_size
                xlim(2) = xlim(1) + cdata_size(2) * units_per_tile / obj.tile_size;
            end
            
            % translate to default image coords (0.5,0.5 origin)
            xlim = xlim + 0.5;
            ylim = ylim + 0.5;
            
            % compute half of a spatial pixel extent
            half_pixel_extent = 0.5 * units_per_tile / obj.tile_size;
            
            % get final x/y data
            xdata(1) = xlim(1) + half_pixel_extent;
            xdata(2) = xlim(2) - half_pixel_extent;
            ydata(1) = ylim(1) + half_pixel_extent;
            ydata(2) = ylim(2) - half_pixel_extent;
            
        end
        
        
        function h5Sid = createDataspace(obj)
            tileDims = [obj.tile_size, obj.tile_size];
            h5Sid = H5S.create_simple(numel(tileDims), tileDims, tileDims);
        end


        function cdata = readHDF5Tile(obj, dataset)
            
            fid = H5F.open(obj.filename_rset, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
            dsetID = H5D.open(fid, dataset);
            dspaceID = H5D.get_space(dsetID);
            
            if (H5ML.compare_values(H5T.get_class(H5D.get_type(dsetID)), ...
                                    H5ML.get_constant_value('H5T_REFERENCE')))
    
                % Read a "virtual" padding tile that is stored elsewhere in the file.
                ref = H5D.read(dsetID, 'H5ML_DEFAULT', dspaceID, dspaceID, 'H5P_DEFAULT');
                dsetDeref = H5R.dereference(dsetID, 'H5R_OBJECT', ref);
                cdata = H5D.read(dsetDeref, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
                H5D.close(dsetDeref);
                                
            else
                
                cdata = H5D.read(dsetID, 'H5ML_DEFAULT', dspaceID, dspaceID, 'H5P_DEFAULT');
                
            end


            H5S.close(dspaceID);
            H5D.close(dsetID);
            H5F.close(fid);
            
        end

        
        function base_tiles = computeBaseTiles(obj)

            numSpanningRows = 2 ^ ceil(log2(obj.image_height));
            numRows = numSpanningRows / obj.tile_size;
            numRows = max(numRows, 1);
            
            numSpanningCols = 2 ^ ceil(log2(obj.image_width));
            numCols = numSpanningCols / obj.tile_size;
            numCols = max(numCols, 1);

            base_tiles = [numRows numCols];

        end

    end % private methods
    
    
    methods (Static)
        
        function v = maxSupportedRSetVersion
            %maxSupportedRSetVersion   Get max version number of supported R-Set files.
            %   v = maxSupportedRSetVersion returns the maximum .rset file version
            %   level supported by this installation's R-Set tools.
            %
            %   This function provides an answer to the compatibility question: "What
            %   newer versions of .rset files can this installation support?"  The
            %   answer: "Any file with a BackwardVersion number less than or equal to
            %   this function's return value."  (It should always be the case that the
            %   R-Set toolset can handle any file created by earlier versions of
            %   RSETWRITE.)
            
            v = 1.0;
        end
        
        
        function v = backwardRSetVersion
            %backwardRSetVersion   Value of BackwardVersion for new R-Set files.
            %   v = backwardRSetVersion returns the BackwardVersion number to put
            %   into new .rset files.
            
            v = 1.0;
        end

        
        function v = currentRSetVersion
            %currentRSetVersion   Get version of new R-Set files.
            %   v = currentRSetVersion returns the version number of new .rset files
            %   written with RSETWRITE.
            
            v = 1.0;
        end

    end
end % classdef


function tileSize = loadTileSize(hdf5file)

fid = H5F.open(hdf5file, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
gid = H5G.open(fid, '/Metadata');
attrID = H5A.open_name(gid, 'TileSize');
tileSize = H5A.read(attrID, 'H5ML_DEFAULT');

H5A.close(attrID);
H5G.close(gid);
H5F.close(fid);

end


function filename = getBaseFilename(rsetFilename)

filename = loadBaseFilename(rsetFilename);

end


function rsetFilename = getFullRSetFilename(filename)

% Get the full path of the R-Set file.
fid = fopen(filename);
if (fid > 0)
    
    rsetFilename = fopen(fid);
    fclose(fid);
    rsetFilename = qualifyFilename(rsetFilename);
    
else
    
    % Let someone else handle the missing R-Set file.
    rsetFilename = filename;
    
end

rsetFilename = replaceFileSeparators(rsetFilename);

end


function fullFilename = qualifyFilename(filename)

if (~any(find(filename == '/')) && ...
    ~any(find(filename == '\')))

    fullFilename = fullfile(pwd, filename);
    
else
    
    fullFilename = filename;
    
end

end


function [h, w] = loadImageDims(rsetFilename)

fid = H5F.open(rsetFilename, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
gid = H5G.open(fid, '/Metadata');

attrID = H5A.open_name(gid, 'FullImageHeight');
h = H5A.read(attrID, 'H5ML_DEFAULT');
H5A.close(attrID);

attrID = H5A.open_name(gid, 'FullImageWidth');
w = H5A.read(attrID, 'H5ML_DEFAULT');
H5A.close(attrID);

H5G.close(gid);
H5F.close(fid);

end


function cmap = loadColormap(rsetFilename)

fid = H5F.open(rsetFilename, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
gid = H5G.open(fid, '/Colormap');

try
    dsetID = H5D.open(gid, 'map');
    cmap = H5D.read(dsetID, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    H5D.close(dsetID);
catch ME  %#ok<NASGU>
    cmap = [];
end
    
H5G.close(gid);
H5F.close(fid);

end


function level = loadMaxLevel(rsetFilename)

fid = H5F.open(rsetFilename, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
gid = H5G.open(fid, '/Metadata');

attrID = H5A.open_name(gid, 'MaxLevel');
level = H5A.read(attrID, 'H5ML_DEFAULT');
H5A.close(attrID);

H5G.close(gid);
H5F.close(fid);

end


function verifyRSetFile(rsetFilename)

% File is accessible.
[fid, msg] = fopen(rsetFilename, 'r');
if (fid < 0)
    error(message('images:RSet:fileNotFound', rsetFilename, msg));
end
fclose(fid);

% Does the file contain R-Set?
[tf, supported] = isrset(rsetFilename);
if (~tf)
    error(message('images:RSet:notRSetFile'));
end

% Is the R-Set compatible?
if (~supported)
    error(message('images:RSet:unsupportedRSetVersion', sprintf( '%0.2f', iptui.RSet.maxSupportedRSetVersion() )));
end

end


function out = squeezeTile(in)

nDims = size(in, 3);

if ((nDims ~= 1) && (nDims < 3))
    out = in(:,:,1);
elseif (nDims > 3)
    out = in(:,:,1:3);
else
    out = in;
end

end


function filename = loadBaseFilename(rsetFilename)

fid = H5F.open(rsetFilename, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
gid = H5G.open(fid, '/Metadata');
attrID = H5A.open_name(gid, 'OriginalBaseFile');

filename = H5A.read(attrID, 'H5ML_DEFAULT')';

H5A.close(attrID);
H5G.close(gid);
H5F.close(fid);

end


function outPath = replaceFileSeparators(inPath)

if (filesep == '/')
    outPath = strrep(inPath, '\', '/');
elseif (filesep == '\')
    outPath = strrep(inPath, '/', '\');
end

end
