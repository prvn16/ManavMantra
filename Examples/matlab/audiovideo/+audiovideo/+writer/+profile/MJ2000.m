classdef MJ2000 < audiovideo.writer.profile.IProfile
    %MJ2000 Write Motion JPEG 2000 files.
    %    This profile compresses video with the Motion JPEG 2000 codec.
    %    It provides the following additional properties:
    %
    %       * CompressionRatio - The target ratio of input data size to output data size.
    %       * MJ2BitDepth - The number of significant bits in the image.
    %       * LosslessCompression - Boolean indicating if reversible compression should be used.
    %
    %    The CompressionRatio property sets the target compression ratio.
    %    For example, the default value of 10 indicates that the compressed
    %    data should be about 10% of the size of the uncompressed data.
    %
    %    The MJ2BitDepth property indicates the number of significant bits
    %    in the input image.  For example, setting this value to 10 and
    %    providing data of type UINT16 would indicate that the data is in
    %    the range [0 1023] or 2^10.  If this property is not set, then it
    %    is assumed that the full range of the supplied data type should be
    %    used.
    %
    %    The LosslessCompression property is a boolean value indicating if
    %    lossless or reversible compression should be used.  Normally the
    %    JPEG 2000 compression, like most video compression techniques,
    %    discards information that is not typically visible to the human
    %    eye.  If this property is set to true, no information will be
    %    discarded when compressing the image.  This leads to larger file
    %    sizes.  If this property is set to true, the CompressionRatio
    %    property is ignored.
    %
    %    The Motion JPEG 2000 profile can accept monochrome or RGB data of
    %    the type UINT8, UINT16, INT8, or INT16.
    %
    %    See also VideoWriter.
    
    % Copyright 2010-2013 The MathWorks, Inc.
    
    properties (SetAccess=protected)
        % Properties inherited from IProfile
        
        Name = 'Motion JPEG 2000';
        Description = getString(message('MATLAB:audiovideo:VideoWriter:CompressionWithJPEG2000Codec'));
    end
    
    properties (Constant)
        % Properties inherited from IProfile
        
        FileExtensions = {'.mj2'};
    end
    
    properties (Constant, Hidden)
        % Properties inherited from IProfile
        
        FileFormat = 'mj2';
    end

    properties (SetAccess=protected)
        % Properties inherited from IProfile
        
        VideoProperties
    end
    
    methods
        
        function prof = MJ2000(fileName, lossless)
            if nargin == 0
                fileName = '';
            end
            
            if nargin < 2
                lossless = false;
            end
            
            prof = prof@audiovideo.writer.profile.IProfile();
            prof.PreferredDataType = {'int8', 'int16', 'uint8', 'uint16'};
            prof.createPlugin('MJ2000Plugin', fileName);
            prof.VideoProperties = audiovideo.writer.properties.MJ2000VideoProperties(...
                prof.Plugin.ColorFormat, ...
                prof.Plugin.ColorChannels, ...
                prof.Plugin.BitsPerPixel, ...
                lossless);
        end
        
        function open(obj)
            % OPEN Open the object for writing.
            obj.open@audiovideo.writer.profile.IProfile();
            
            % Need to reset the allowed data types since no data has been
            % written yet.
            obj.PreferredDataType = {'int8', 'int16', 'uint8', 'uint16'};
            obj.VideoProperties.open();
            
            obj.Plugin.open(obj.getPluginOpenOptions);
        end
        
        function close(obj)
            % CLOSE Close the object and finalize the file.
            
            obj.Plugin.close();
            obj.VideoProperties.close();
        end
        
        function writeVideoFrame(obj, data)
            writeVideoFrame@audiovideo.writer.profile.IProfile(obj, data);
            
            % Now that data has been written, we know what kind of data to
            % convert to.
            while obj.VideoProperties.FrameCount == 0
                drawnow('limitrate');
            end
            
            if obj.VideoProperties.FrameCount == 1
                obj.PreferredDataType = {class(data)};
            end
        end
        
        function options = getPluginOpenOptions(obj)
            % Create an asyncio Channel options structure
            % with format specific properties to be used during
            % open@asyncio.Channel
   
            options.FrameRate = obj.VideoProperties.FrameRate;
            options.Lossy = ~obj.VideoProperties.LosslessCompression;
            options.CompressionRatio = obj.VideoProperties.CompressionRatio;
            
            if ~isempty(obj.VideoProperties.MJ2BitDepth)
                options.BitDepth = uint8(obj.VideoProperties.MJ2BitDepth);
            end
        end
        
    end
    
    methods (Hidden)
        % Public methods that are not generally useful to the end user of a
        % profile object.
        
        function colorspace = getPreferredColorSpace(obj)
            % Returns the color space that the profile requires in order to
            % write out the data correctly.
            
            if isempty(obj.VideoProperties.ColorChannels)
                colorspace = audiovideo.internal.writer.profile.OutputColorFormat.ANY;
            elseif obj.VideoProperties.ColorChannels == 1
                colorspace = audiovideo.internal.writer.profile.OutputColorFormat.MONOCHROME;
            elseif obj.VideoProperties.ColorChannels == 3
                colorspace = audiovideo.internal.writer.profile.OutputColorFormat.RGB;
            end
        end
    end

end
