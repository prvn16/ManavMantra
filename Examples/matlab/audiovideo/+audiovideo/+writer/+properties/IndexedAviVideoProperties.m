classdef IndexedAviVideoProperties < audiovideo.writer.properties.VideoProperties
    %IndexedAviVideoProperties Properties for an Indexed AVI based profile
    %   IndexedAviVideoProperties contains all the properties of a 
    %   VideoProperties object as well as the colormap required for Indexed
    %   AVI files
   
    % Copyright 2012-2013 The MathWorks, Inc.

    properties (Access=public)
        % Colormap required for writing Indexed AVI files
        Colormap = [];
    end
        
    methods(Access=public)
        function obj = IndexedAviVideoProperties(colorFormat, colorChannels, bitsPerPixel, cmap)
            obj@audiovideo.writer.properties.VideoProperties(colorFormat, colorChannels, bitsPerPixel);
            obj.Colormap = cmap;
        end
    end
    
    methods(Access=public, Hidden)
        function forceSetColormap(obj, value)
            % If the ForceColormap flag is made a property of the class,
            % then the Colormap property should be marked as 'Dependent' to
            % prevent possible issues during save/load.
            % Hence, the value to be set is passed as struct.
            valueToSet = struct('ActualValue', value, 'ForceColormap', true);
            obj.Colormap = valueToSet;
        end
    end
    
    % Property getters/setters
    methods
        function set.Colormap(obj, value)
            % The ColorMap must be set to a valid non-empty value before
            % writing the first frame.
            
            if isstruct(value)
                fnames = fieldnames(value);
                assert( any(ismember({'ActualValue', 'ForceColormap'}, fnames)), 'Invalid struct');
                
                canForceColormapValue = value.ForceColormap;
                value = value.ActualValue;
            else
                canForceColormapValue = false;
            end
            
            if (obj.IsOpen && ~canForceColormapValue)
                obj.errorIfOpen('Colormap');
            end
            
            if isempty(value)
                obj.Colormap = value;
                return;
            end
            
            validateattributes(value, {'uint8', 'double'}, ...
                                      {'2d', 'nonnegative', 'nonempty', 'size', [NaN 3]});
            
            if isa(value, 'double')
                validateattributes(value, {'double'}, {'>=', 0, '<=', 1});
            end
            
            if size(value, 1) > 256 
                error(message('MATLAB:audiovideo:VideoWriter:invalidColormap'));
            end
                       
            obj.Colormap = value;
        end
    end
end
    