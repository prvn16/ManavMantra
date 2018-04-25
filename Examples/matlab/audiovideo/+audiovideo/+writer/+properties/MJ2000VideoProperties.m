classdef MJ2000VideoProperties < audiovideo.writer.properties.VideoProperties
   %MJ2000VideoProperties Properties for the Motion JPEG 2000 profiles
   %
   %   The MJ2000VideoProperties class extends VideoWriter property support
   %   to the profiles supporting the Motion JPEG 2000 standard.  It
   %   introduces new properties and new behaviors specific to these
   %   profiles.
   %
   %   MJ2000VideoProperties properties:
   %      CompressionRatio - The target compression ratio for the images
   %      Mode - The compression mode, either 'lossy', or 'lossless'
   %
   %   See also VideoWriter, audiovideo.writer.properties.VideoProperties, audiovideo.writer.profile.MJ2000.
   
   %   Copyright 2010-2013 The MathWorks, Inc.
    
    properties (Access=public, Dependent, Transient)
        CompressionRatio;
        LosslessCompression;
        MJ2BitDepth;
    end
    
    properties (Access=private)
        % Since CompressionRatio and LosslessCompression interact, they
        % must be derived properties backed by these private properties.
        
        PrivateCompressionRatio = 10;        
        PrivateLosslessCompression = false;
        PrivateMJ2BitDepth = [];
        
        % Indicate if the user has set the CompressionRatio property so
        % that we can warn/error appropriately.
        PrivateCompressionRatioSet = false;
        
        % Indicate if the user has set the MJ2BitDepth property so that it
        % can be maintained.
        PrivateMJ2BitDepthSet = false;
    end
    
    methods(Access=public)
        function obj = MJ2000VideoProperties(colorFormat, colorChannels, bitsPerPixel, losslessCompression, compressionRatio)
            obj@audiovideo.writer.properties.VideoProperties(colorFormat, colorChannels, bitsPerPixel);
            if (nargin >= 4)
                obj.LosslessCompression = losslessCompression;
            end
            
            if (nargin >= 5)
                obj.CompressionRatio = compressionRatio;
            end
            
            obj.VideoCompressionMethod = 'Motion JPEG 2000';
        end
    end
    
     % Property getters and setters
    methods
        function set.CompressionRatio(obj,value)
            obj.errorIfOpen('CompressionRatio');
            
            if (obj.LosslessCompression)
                error(message('MATLAB:audiovideo:VideoWriter:mj2compressionwhenlosses'));
            end
                
            validateattributes(value, {'numeric'}, ...
                {'integer', 'finite', 'scalar' ...
                 '>', 1}, ...
                'set', 'CompressionRatio');
            
            obj.PrivateCompressionRatio = value;
            obj.PrivateCompressionRatioSet = true;
        end
        
        function value = get.CompressionRatio(obj)
            value = obj.PrivateCompressionRatio;
        end
        
        function set.LosslessCompression(obj, value)
            obj.errorIfOpen('LosslessCompression');
            
            validateattributes(value, {'logical'}, ...
                {'scalar'}, ...
                'set', 'LosslessCompression');
            if obj.PrivateCompressionRatioSet
                warning(message('MATLAB:audiovideo:VideoWriter:mj2losslesswithcompression'));
            end
            obj.PrivateLosslessCompression = value;
        end
        
        function value = get.LosslessCompression(obj)
            value = obj.PrivateLosslessCompression;
        end
        
        function set.MJ2BitDepth(obj, value)
            obj.errorIfOpen('MJ2BitDepth');
            validateattributes(value, {'numeric'}, ...
                {'integer', 'finite', 'scalar', ...
                '>=', 1, '<=', 16}, ...
                'set', 'MJ2BitDepth');
            obj.PrivateMJ2BitDepthSet = true;
            obj.PrivateMJ2BitDepth = value;
        end
        
        function value = get.MJ2BitDepth(obj)
            value = obj.PrivateMJ2BitDepth;
        end
            
    end

    methods(Static)
        function out = loadobj(in)
            % Reset the volatile properties.
            in.VideoBitsPerPixel = [];
            in.VideoFormat = [];
            in.ColorChannels = [];
            if ~in.PrivateMJ2BitDepthSet
                in.PrivateMJ2BitDepth = [];
            end
            out = in;
        end
    end
    
    methods (Hidden)
        
        function open(obj)
            open@audiovideo.writer.properties.VideoProperties(obj);
            obj.VideoBitsPerPixel = [];
            obj.VideoFormat = [];
            obj.ColorChannels = [];
            if ~obj.PrivateMJ2BitDepthSet
                obj.PrivateMJ2BitDepth = [];
            end
        end
        
        function frameWritten(obj, frameData)
            frameWritten@audiovideo.writer.properties.VideoProperties(obj,frameData);
            
            if ~isempty(obj.VideoBitsPerPixel)
                return;
            end
            
            if isempty(obj.MJ2BitDepth)
                obj.PrivateMJ2BitDepth = frameData.BitsPerPixel / frameData.ColorChannels;
            end
            
            obj.VideoBitsPerPixel = frameData.BitsPerPixel;
            obj.ColorChannels = frameData.ColorChannels;
            
            if (obj.ColorChannels == 1) 
                format = 'Mono';
            else
                format = 'RGB';
            end
            
            format = [format num2str(obj.VideoBitsPerPixel)];
                
            if frameData.IsSigned
                format = [format ' Signed'];
            end
            obj.VideoFormat = format;
        end
    end
    
end

