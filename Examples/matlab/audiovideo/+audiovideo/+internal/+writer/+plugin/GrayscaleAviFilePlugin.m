classdef (Hidden) GrayscaleAviFilePlugin < audiovideo.internal.writer.plugin.AviFilePlugin
    %GrayscaleAviFilePlugin Extension of the IndexedAviFilePlugin class to write
    %Grayscale AVI Files. These are Indexed AVI files with a Grayscale
    %Colormap.
    
    % Copyright 2012-2013 The MathWorks, Inc.
                
    methods
        function obj = GrayscaleAviFilePlugin(fileName)
            %GrayscaleAviFilePlugin Construct a GrayscaleAviFilePlugin object.
            %
            %   OBJ = GrayscaleAviFilePlugin(FILENAME) constructs a
            %   GrayscaleAviFilePlugin object pointing to the file specified
            %   by FILENAME.  The file is not created until
            %   GrayscaleAviFilePlugin.open() is called. 
            %
            %   See also GrayscaleAviFilePlugin/open, GrayscaleAviFilePlugin/close.
            
            obj = obj@audiovideo.internal.writer.plugin.AviFilePlugin(fileName);            

            obj.ColorFormat = 'Grayscale';
            obj.ColorChannels = 1;
            obj.BitsPerPixel = 8;
            
            % Handle the zero argument constructor.  This is needed, for
            % example, when constructing empty profile objects.
            if isempty(fileName)
                obj.Channel = [];
                return;
            end
            
            obj.FileName = fileName;
        end
        
        function open(obj, options)
            options.Colormap = audiovideo.internal.writer.convertColormapToUint8(options.Colormap);
            open@audiovideo.internal.writer.plugin.AviFilePlugin(obj, options)
        end
        
        function [pluginName, mlConverterName, slConverterName, options] = ...
                                                getChannelInitOptions(obj)
            [pluginName, mlConverterName, slConverterName, options] = ...
                    getChannelInitOptions@audiovideo.internal.writer.plugin.AviFilePlugin(obj);
            options.FileFormat = obj.ColorFormat;
        end
        
        function [filterName, options] = getFilterInitOptions(obj)
            filterName = 'videotransformfilter';
            options.InputFrameType = 'RawPlanarColumn';
            if ~isempty(obj.Channel)
                options.OutputFrameType = obj.Channel.ExpectedFrameType;
            else
                options.OutputFrameType = '';
            end
        end
                
    end
end