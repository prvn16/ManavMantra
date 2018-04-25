classdef VideoWriter < hgsetget & dynamicprops
    %VideoWriter Create a video writer object.
    %   
    %   OBJ = VideoWriter(FILENAME) constructs a VideoWriter object to
    %   write video data to an AVI file that uses Motion JPEG compression.  
    %   FILENAME is a string enclosed in single quotation marks that specifies 
    %   the name of the file to create. If filename does not include the 
    %   extension '.avi', the VideoWriter constructor appends the extension.
    %
    %   OBJ = VideoWriter( FILENAME, PROFILE ) applies a set of properties
    %   tailored to a specific file format (such as 'Uncompressed AVI') to 
    %   a VideoWriter object. PROFILE is a string enclosed in single 
    %   quotation marks that describes the type of file to create. 
    %   Specifying a profile sets default values for video properties such 
    %   as VideoCompressionMethod. Possible values:
    %     'Archival'         - Motion JPEG 2000 file with lossless compression
    %     'Motion JPEG AVI'  - Compressed AVI file using Motion JPEG codec.
    %                          (default)
    %     'Motion JPEG 2000' - Compressed Motion JPEG 2000 file
    %     'MPEG-4'           - Compressed MPEG-4 file with H.264 encoding 
    %                          (Windows 7 and Mac OS X 10.7 only)
    %     'Uncompressed AVI' - Uncompressed AVI file with RGB24 video.
    %     'Indexed AVI'      - Uncompressed AVI file with Indexed video.
    %     'Grayscale AVI'    - Uncompressed AVI file with Grayscale video.
    %
    % Methods:
    %   open        - Open file for writing video data. 
    %   close       - Close file after writing video data.
    %   writeVideo  - Write video data to file.
    %   getProfiles - List profiles and file format supported by VideoWriter. 
    %
    % Properties:
    %   ColorChannels          - Number of color channels in each output 
    %                            video frame.
    %   Colormap               - Numeric matrix having dimensions Px3 that
    %                            contains color information about the video
    %                            file. The colormap can have a maximum of
    %                            256 entries of type 'uint8' or 'double'.
    %                            The entries of the colormap must integers.
    %                            Each row of Colormap specifies the red,
    %                            green and blue components of a single
    %                            color. The colormap can be set: 
    %                               - Explicitly before the call to open OR
    %                               - Using the colormap field of the FRAME
    %                                 struct at the time of writing the
    %                                 first frame.
    %                            Only applies to objects associated with
    %                            Indexed AVI files. After you call open,
    %                            you cannot change the Colormap value.
    %   CompressionRatio       - Number greater than 1 indicating the
    %                            target ratio between the number of bytes
    %                            in the input image and compressed image.
    %                            Only applies to objects associated with
    %                            Motion JPEG 2000 files. After you call
    %                            open, you cannot change the  
    %                            CompressionRatio value.  
    %   Duration               - Scalar value specifying the duration of the 
    %                            file in seconds.
    %   FileFormat             - String specifying the type of file to write.
    %   Filename               - String specifying the name of the file.
    %   FrameCount             - Number of frames written to the video file.
    %   FrameRate              - Rate of playback for the video in frames per
    %                            second. After you call open, you cannot 
    %                            change the FrameRate value.
    %   Height                 - Height of each video frame in pixels. 
    %                            The writeVideo method sets values for Height
    %                            and Width based on the dimensions of the 
    %                            first frame.
    %   LosslessCompression    - Boolean value indicating whether lossy or
    %                            lossless compression is to be used. If
    %                            true, any specified value for the
    %                            CompressionRatio property is ignored. Only
    %                            applies to objects associated with Motion
    %                            JPEG 2000 files. After you call open, you
    %                            cannot change the LosslessCompression value.
    %   MJ2BitDepth            - Number of least significant bits in the
    %                            input image data, from 1 to 16. Only
    %                            applies to objects associated with Motion
    %                            JPEG 2000 files. 
    %   Path                   - String specifying the fully qualified file
    %                            path.
    %   Quality                - Integer from 0 through 100. Only applies to
    %                            objects associated with the Motion JPEG
    %                            AVI and MPEG-4 profiles. Higher quality
    %                            numbers result in higher video quality and
    %                            larger file sizes. Lower quality numbers
    %                            result in lower video quality and smaller
    %                            file sizes. After you call open, you cannot 
    %                            change the Quality value.
    %   VideoBitsPerPixel      - Number of bits per pixel in each output 
    %                            video frame.
    %   VideoCompressionMethod - String indicating the type of video 
    %                            compression.
    %   VideoFormat            - String indicating the MATLAB representation 
    %                            of the video format.    
    %   Width                  - Width of each video frame in pixels. 
    %                            The writeVideo method sets values for Height
    %                            and Width based on the dimensions of the 
    %                            first frame.
    %
    % Example:
    % 
    %   % Prepare the new file.
    %   vidObj = VideoWriter('peaks.avi');
    %   open(vidObj);
    %
    %   % Create an animation.
    %   Z = peaks; surf(Z);
    %   axis tight manual
    %   set(gca,'nextplot','replacechildren');
    %
    %   for k = 1:20
    %      surf(sin(2*pi*k/20)*Z,Z)
    %
    %      % Write each frame to the file.
    %      currFrame = getframe(gcf);
    %      writeVideo(vidObj,currFrame);
    %   end
    % 
    %   % Close the file.
    %   close(vidObj);
    % 
    % See also VideoWriter/open, VideoWriter/close, 
    %          VideoWriter/writeVideo, VideoWriter/getProfiles.
    
    %   Authors: NH, DT
    %   Copyright 2009-2017 The MathWorks, Inc.
    
    properties (Dependent, Transient, SetAccess=private)
        Duration = 0; %The total duration of the file, in seconds.
    end
    properties(SetAccess=private)
        Filename      %The name of the file to be written.
        Path          %The path to the file to be written.
    end
    
    properties(Dependent, SetAccess=private)
        FileFormat    %The format of the file to be written.
     end
    
    properties(SetAccess=private, Hidden, Transient)
        IsOpen = false; %Indicates if the file is open for writing.
        IsFilenameValidated = false; % Indicates if the file name was validated. This is done for performance reasons.
        IsWriteVideoCalled = false;
        
        % Used to determine if we should warn on close since FrameCount is
        % updated via a callback AND to track that all the frames have been
        % written before computing the Duration property of the object
        InternalFramesWritten = 0;
    end
    
    properties(Access=private)
        Profile % The internal profile object.        
        AllowedDataTypes % Not used.  Keep for backwards compatibility.
    end
    
    properties(Access=private, Constant)
        FrameIntervalToCheckError = 10;
    end
    
    methods
        function obj = VideoWriter(filename, profile)
            
            import audiovideo.internal.writer.profile.ProfileFactory;

            if nargin < 1
                error(message('MATLAB:audiovideo:VideoWriter:noFile'));
            elseif nargin < 2
                profile = 'Default';
            elseif nargin == 2
                if ~ischar(profile)
                    error(message('MATLAB:audiovideo:VideoWriter:invalidProfile'));
                end
            else
                narginchk(1,2);
            end
            
            try
                fullFileName = VideoWriter.generateFullOutputFileName(filename, profile);
            catch err
                throwAsCaller(err);
            end
            
            try
                obj.Profile = ProfileFactory.createProfile(profile, fullFileName);
            catch err
                throw(err);
            end
            
            % init file properties
            [pathstr, file, ext] = fileparts(fullFileName);
            obj.Filename = [file ext];
            obj.Path = pathstr;
            
            obj.IsFilenameValidated = true;
            
            obj.initDynamicProperties();
        end
        
        function delete(obj)
            %DELETE Delete a VideoWriter object.
            %   DELETE does not need to called directly, as it is called when
            %   the VideoWriter object is cleared.  When DELETE is called, the
            %    object is closed and the file is no longer writable.
            close(obj)
        end
        
        function open(obj)
            %OPEN Open a VideoWriter object for writing.
            %   OPEN(OBJ) must be called before calling the writeVideo
            %   method.  After you call OPEN, all properties of the 
            %   VideoWriter object become read only.
            %
            %   See also VideoWriter/writeVideo, VideoWriter/close.
            
            if length(obj) > 1
                error(message('MATLAB:audiovideo:VideoWriter:nonScalar'));
            end
            
            if obj.IsOpen
                % If open is called multiple times, there should be no
                % effect.
                return;
            end
            
            % If the output file location was modified on the system after
            % the object was saved, the loaded object will no longer point
            % to a valid location. The check is being added in open() as
            % well to guard against this.
            try
                % If the file name validation has already been performed,
                % no need to carry it out again.
                if ~obj.IsFilenameValidated
                    fileName = fullfile(obj.Path, obj.Filename);
                    VideoWriter.generateFullOutputFileName(fileName, obj.Profile.Name);
                    obj.IsFilenameValidated = true;
                end
                
                obj.Profile.open();
            catch err
                throwAsCaller(err);
            end

            obj.InternalFramesWritten = 0;
            obj.IsOpen = true;
        end
        
        function close(obj)
            % CLOSE Finish writing and close video file.
            %
            %   CLOSE(OBJ) closes the file associated with video
            %   writer object OBJ.
            % 
            %   See also VideoWriter/open, VideoWriter/writeVideo.
            
            for ii = 1:length(obj)                
                if ~obj(ii).IsOpen
                    continue;
                end                
                
                try
                    obj(ii).Profile.close();
                catch err
                    % Don't want to error on close, but don't just swallow
                    % the message.
                    warning(err.identifier, err.message);
                end
                
                if obj(ii).InternalFramesWritten == 0
                    warning(message('MATLAB:audiovideo:VideoWriter:noFramesWritten'));
                end

                obj(ii).IsOpen = false;
                obj(ii).IsFilenameValidated = false;
                obj(ii).IsWriteVideoCalled = false;
                
                while obj(ii).InternalFramesWritten ~= ...
                            obj(ii).Profile.VideoProperties.FrameCount
                    drawnow('limitrate');
                end
            end
        end
        
        function writeVideo(obj,inputFrames)
            % writeVideo write video data to a file
            %
            %   writeVideo(OBJ,FRAME) writes a FRAME to the video file
            %   associated with OBJ.  FRAME is a structure typically 
            %   returned by the GETFRAME function that contains two fields: 
            %   cdata and colormap. The height and width must be consistent
            %   for all frames within a file. The profile determines how
            %   the writeVideo method uses the FRAME as described below:
            %   Two-Dimensional cdata (height-by-width)
            %   Profile Name                    Action
            %   Indexed AVI, Grayscale AVI      Use frame as provided.
            %   All other profiles              Construct RGB image frames
            %                                   using the colormap field
            %
            %   Three-Dimensional cdata (height-by-width-by-3)
            %   Profile Name                    Action
            %   Indexed AVI, Grayscale AVI      Error
            %   All other profiles              Colormap field ignored.
            %                                   Construct RGB image frames
            %                                   using the cdata field 
            %
            %   writeVideo(OBJ,MOV) writes a MATLAB movie MOV to a
            %   video file. MOV is an array of FRAME structures, each of
            %   which contains fields cdata and colormap.
            % 
            %   writeVideo(OBJ,IMAGE) writes data from IMAGE to a
            %   video file.  IMAGE is an array of single, double, or uint8 
            %   values representing grayscale or RGB color images. The
            %   height and width must be  consistent for all frames within
            %   a file. The profile determines how the writeVideo method
            %   use the IMAGE as described below:
            %   Two-Dimensional image (height-by-width)
            %   Profile Name                    Action
            %   Indexed AVI, Grayscale AVI      Use image as provided
            %   Motion JPEG 2000 (1-channel)    Use image as provided
            %   All other profiles              Construct RGB image frame
            %
            %   Three-Dimensional image (height-by-width-by-3)
            %   Profile Name                    Action
            %   Indexed AVI, Grayscale AVI      Error
            %   Motion JPEG 2000 (1-channel)    Error
            %   All other profiles              Use image as provided
            %
            %   Data of type single or double must be in the range [0,1]
            %   except when writing Indexed AVI files.
            %
            %   writeVideo(OBJ,IMAGES) writes a sequence of color images to
            %   a video file.  IMAGES is a four-dimensional array of 
            %   grayscale (height-by-width-by-1-by-frames) or RGB 
            %   (height-by-width-by-3-by-frames) images.
            %
            %   You must call OPEN(OBJ) before calling writeVideo.            
            %
            %   See also VideoWriter/open, VideoWriter/close.
            
            narginchk(2,2)
            
            if length(obj) > 1
                error(message('MATLAB:audiovideo:VideoWriter:nonScalar'));
            end

            if ~obj.IsOpen
                error(message('MATLAB:audiovideo:VideoWriter:notOpen'));
            end
            
            if obj.IsWriteVideoCalled
                while obj.Profile.VideoProperties.FrameCount == 0
                    drawnow('limitrate')
                end
                [frameHeight, frameWidth] = VideoWriter.getFrameSize(inputFrames);
                if (~obj.Profile.validateFrameSize(frameWidth, frameHeight))
                    error(message('MATLAB:audiovideo:VideoWriter:invalidDimensions', obj.Width, obj.Height));
                end
            end
            
            try
                % Write image frames to the file.
                numFramesWrittenUntilNow = obj.InternalFramesWritten;
                
                % Convert the input frames into a format that is required
                % for writing to the file. This involves both colorspace
                % and datatype conversion
                outputFrames = VideoWriter.convertToOutput(inputFrames, ...
                                                           obj.Profile.getPreferredColorSpace(), ...
                                                           obj.Profile.PreferredDataType);

                numFrames = VideoWriter.computeNumFrames(outputFrames);
                for ii = 1:numFrames
                    if isstruct(outputFrames)
                        obj.Profile.writeVideoFrame(outputFrames(ii));
                    else
                        obj.Profile.writeVideoFrame(outputFrames(:,:,:,ii))
                    end
                    obj.InternalFramesWritten = obj.InternalFramesWritten + 1;
                    % The DataPipe buffers 10 frames. So check if an error
                    % occurred during writing every 10 frames because there
                    % is a good chance that atleast one of the frames
                    % buffered would have been tried to be written to the
                    % file. 
                    if mod(obj.InternalFramesWritten, obj.FrameIntervalToCheckError) == 0
                        obj.Profile.throwErrorIfWriteFailed();
                    end
                end
                % The notification of the frame being successfully written
                % and/or an error occurring during writing is done using a
                % callback. So even if we did not detect an error while
                % writing the frames, it could be because the events were
                % not processed. So, once we are done writing all the
                % frames, we have to wait atleast until one frame has been
                % written to confirm that there was no error was received.
                % This assumes that any issues with writing will be
                % detected when writing the first frame which is
                % reasonable.
                obj.Profile.waitAndCheckForError();
            catch err
                % If an error was generated
                obj.InternalFramesWritten = numFramesWrittenUntilNow;
                throw(err)
            end
            
            obj.IsWriteVideoCalled = true;
        end
        
        function value = get.Duration(obj)
            value = obj.FrameCount * 1/obj.FrameRate;
        end
        
        function set.Duration(~, ~)
            error(message('MATLAB:audiovideo:VideoWriter:setDuration'));
        end
        
        function value = get.FileFormat(obj)
            value = obj.Profile.FileFormat;
        end
        
        function set.FileFormat(~, ~)
            error(message('MATLAB:audiovideo:VideoWriter:setFileFormat'));
        end
        
        function obj = saveobj(obj)
            warnState = warning('off', 'MATLAB:audiovideo:VideoWriter:noFramesWritten');
            wOc = onCleanup( @() warning(warnState) );
            
            close(obj);
        end
    end
    
    methods (Hidden)
        
        function setBufferSize(obj, size)
            % Sets the buffer size on the plugin.  This method can not be
            % called while the VideoWriter object is open and should not be
            % called by users.
            obj.Profile.setBufferSize(size)
        end
        
        function [pluginPath] = getProfilePluginPath(obj)
            % Return the base path of the profile's underlying asyncio
            % plugin, converter, and filter.  Used for clients 
            % (like system objects or Simulink blocks) who wish to 
            % create an asyncio channel themselves. 
            pluginPath = obj.Profile.getPluginPath();
        end
        
        function [pluginName, converterName, options] = getProfilePluginInitOptions(obj)
            % Get the Profiles underlying asyncio plugin, converter, and
            % initialization options.  Used for clients 
            % (like system objects or Simulink blocks) who wish to 
            % create an asyncio channel themselves.
            [pluginName, converterName, ~, options] = obj.Profile.getPluginInitOptions();
        end
        
        function [filterName, options] = getProfileFilterInitOptions(obj)
            % Get the Profile's underlying asyncio filter and initialization
            % options. Used for clients (like system objects or Simulink 
            % blocks) who wish to create an asyncio channel themselves.
           [filterName, options] = obj.Profile.getPluginFilterInitOptions();
        end
        
        function [options] = getProfileOpenOptions(obj)
            % Get the Profile's underlying asyncio filter and initialization
            % options. Used for clients (like system objects or Simulink 
            % blocks) who wish to create an asyncio channel themselves.
            options = obj.Profile.getPluginOpenOptions();
        end
        
        function disp(obj)
            if (length(obj) > 1 || isempty(obj))
                % defer to built in disp() for arrays or emptys
                disp@hgsetget(obj);
            else
                % Handles a Scalar VideoWriter object
                
                % Prints package name hyperlink
                fprintf(internal.DisplayFormatter.getDisplayHeader(obj));
                
                % Prints properties in categories
                printProperties(obj);
                
                % Prints Methods hyperlink line
                fprintf(internal.DisplayFormatter.getDisplayFooter(obj));
            end
        end
        
        function getdisp(obj)
            if (length(obj) > 1)
                % Defer to built in
                getdisp@hgsetget(obj);
                return;
            end
            
            % One line break after the command on the command line
            fprintf('\n');
            
            % Prints properties in categories
            printProperties(obj);
        end
        
        function c = horzcat(varargin)
            %HORZCAT Horizontal concatenation of VideoWriter objects.
            %   Horizontal concatenation of VideoWriter objects is not
            %   allowed.
            %
            %    See also VideoWriter/vertcat, VideoWriter/cat.
            
            if (nargin == 1)
                c = varargin{1};
            else
                error(message('MATLAB:audiovideo:VideoWriter:noconcatenation'));
            end
        end
        function c = vertcat(varargin)
            %VERTCAT Vertical concatenation of VideoWriter objects.
            %
            %   Vertical concatenation of VideoWriter objects is not
            %   allowed.
            %
            %    See also VideoWriter/horzcat, VideoWriter/cat.
            
            if (nargin == 1)
                c = varargin{1};
            else
                error(message('MATLAB:audiovideo:VideoWriter:noconcatenation'));
            end
        end
        function c = cat(varargin)
            %CAT Concatenation of VideoWriter objects.
            %
            %   Concatenation of VideoWriter objects is not allowed.
            %
            %    See also VideoWriter/horzcat, VideoWriter/vertcat.
            if (nargin > 2)
                error(message('MATLAB:audiovideo:VideoWriter:noconcatenation'));
            else
                c = varargin{2};
            end
        end

        % Hidden methods from the hgsetget super class.
        function res = eq(obj, varargin)
            res = eq@hgsetget(obj, varargin{:});
        end
        function res =  fieldnames(obj, varargin)
            res = fieldnames@hgsetget(obj,varargin{:});
        end
        function res = ge(obj, varargin)
            res = ge@hgsetget(obj, varargin{:});
        end
        function res = gt(obj, varargin)
            res = gt@hgsetget(obj, varargin{:});
        end
        function res = le(obj, varargin)
            res = le@hgsetget(obj, varargin{:});
        end
        function res = lt(obj, varargin)
            res = lt@hgsetget(obj, varargin{:});
        end
        function res = ne(obj, varargin)
            res = ne@hgsetget(obj, varargin{:});
        end
        function res = findobj(obj, varargin)
            res = findobj@hgsetget(obj, varargin{:});
        end
        function res = findprop(obj, varargin)
            res = findprop@hgsetget(obj, varargin{:});
        end
        function res = addlistener(obj, varargin)
            res = addlistener@hgsetget(obj, varargin{:});
        end
        function res = notify(obj, varargin)
            res = notify@hgsetget(obj, varargin{:});
        end
        
        % Hidden methods from the dynamic proper superclass
        function res = addprop(obj, varargin)
            res = addprop@dynamicprops(obj, varargin{:});
        end
        
    end
    methods (Access=private)
        function initDynamicProperties( obj )
            % Create dynamic properties from our Profile.VideoProperties
            % object
            vidPropsMeta = metaclass(obj.Profile.VideoProperties);        
            cellfun(@obj.addDynamicProp, vidPropsMeta.Properties); 
        end
        
        function addDynamicProp(obj, metaprop)
           % Add given a meta-property, expose the property as a dependent
           % property in this class with custom get/set methods where 
           % appropriate. 

           if ~strcmpi(metaprop.GetAccess,'public')
               return;
           end
           
           prop = addprop(obj, metaprop.Name);
           prop.Dependent = true;
           prop.Transient = true;
           prop.GetMethod = @(obj) obj.getDynamicProp(metaprop.Name);
           
           if strcmpi(metaprop.SetAccess,'public')
                prop.SetMethod = @(obj, value) obj.setDynamicProp(metaprop.Name, value);
           else
                prop.SetAccess = 'private';
           end
        end
        
        function value = getDynamicProp(obj, propertyName)
            
            if strcmp(propertyName, 'FrameCount')
                while obj.InternalFramesWritten ~= obj.Profile.VideoProperties.FrameCount
                    drawnow('limitrate');
                end
            else
                if obj.IsWriteVideoCalled
                    while obj.Profile.VideoProperties.FrameCount == 0
                        drawnow('limitrate')
                    end
                end
            end
            value = obj.Profile.VideoProperties.(propertyName);
        end
        
        function setDynamicProp(obj, propertyName, value)
           obj.Profile.VideoProperties.(propertyName) = value;
        end
                                
        function printProperties(obj)
            % Prints VideoWriter properties
            fprintf(...
               internal.DisplayFormatter.getDisplayCategories(obj,...
                getString(message('MATLAB:audiovideo:VideoWriter:GeneralProperties')), ... 
                {'Filename', 'Path', 'FileFormat', 'Duration'}, ...
                getString(message('MATLAB:audiovideo:VideoWriter:VideoProperties')), ...
                obj.Profile.VideoProperties.getPropertyNamesForDisp...
                ));
        end
    end
    
    methods(Static)
        function profiles = getProfiles()
            %getProfiles List profiles supported by VideoWriter.
            %
            %  PROFILES = VideoWriter.getProfiles() returns an array of 
            %  audiovideo.writer.ProfileInfo objects that indicate the 
            %  types of files VideoWriter can create.
            % 
            %  audiovideo.writer.ProfileInfo objects contain the following
            %  read-only properties:
            %    Name                   - Name of the profile 
            %    Description            - Description of the intent of 
            %                             the profile.
            %    FileExtensions         - Cell array of strings containing
            %                             file extensions supported by the
            %                             file format.
            %    VideoCompressionMethod - String indicating the type of
            %                             video compression.
            %    VideoFormat            - String indicating the MATLAB
            %                             representation of the video 
            %                             format.
            %    VideoBitsPerPixel      - Number of bits per pixel in each
            %                             output video frame.
            %    Quality                - Number from 0 through 100. Higher
            %                             values correspond to higher 
            %                             quality video and larger files. 
            %                             Only applies to objects 
            %                             associated with the Motion 
            %                             JPEG AVI profile.
            %    FrameRate              - Rate of playback for the video in
            %                             frames per second. 
            %    ColorChannels          - Number of color channels in each 
            %                             output video frame.
            %
            % See also VideoWriter
            
            import audiovideo.internal.writer.profile.ProfileFactory;
            
            profiles = ProfileFactory.getKnownProfileInfos();
        end
        
    end
    
    methods(Static, Hidden)
        %------------------------------------------------------------------
        % Persistence
        %------------------------------------------------------------------        
        function obj = loadobj(obj)
            % Object is already created, initialize any dynamic properties.
            % All of VideoWriter's Dynamic properties are transient and
            % need to be initialized during construction and load.
            
            obj.IsFilenameValidated = false;
            obj.initDynamicProperties();
        end
        
        function outFrames = convertFrameDataType(outType, inType, frames)
            outFrames = double(frames);
            largerRange = double(intmax(outType)) - double(intmin(outType)) + 1;
            smallerRange = double(intmax(inType)) - double(intmin(inType)) + 1;
            mult = largerRange / smallerRange;
            b = double(intmin(outType)) - double(intmin(inType)) * mult;
            outFrames = outFrames * mult + b;
            outFrames = cast(outFrames, outType);
        end
    end
    
    methods(Static, Access=private)
                
        function verifyNumBands(frames)
            % Verify that an image has either 1 or 3 bands.
            if isa(frames, 'struct')
                return;
            end

            % Need to get all four dimensions so that they're not all
            % collapsed into the last dimension.
            [~, ~, bands, ~] = size(frames);
            
            if (bands ~= 1) && (bands ~= 3)
                error(message('MATLAB:audiovideo:VideoWriter:badBands'));
            end
        end
        
        function validateAllowableFrameDataTypes(frames, prefOutputDataType)
            if isa(frames, 'struct')
                return;
            end
            
            dataTypeOfInputData = class(frames);
            
            allowedDataTypes = union(prefOutputDataType, {'single', 'double'});

            if any(ismember({'uint16', 'int16'}, prefOutputDataType))
                allowedDataTypes = [allowedDataTypes {'uint8', 'int8'}];
            end

            if ~any(strcmp(dataTypeOfInputData, allowedDataTypes))
                allTypes = sprintf('%s, ',allowedDataTypes{:});
                allTypes = allTypes(1:end-2);
                error(message('MATLAB:audiovideo:VideoWriter:dataType', allTypes));
            end
        end
        
        function frames = convertToOutput(frames, outputColorSpace, prefOutputDataType)    
            % Performs colorspace and datatype conversion on the input data
            % so that the data is suitable for output.
            
            import audiovideo.internal.writer.profile.OutputColorFormat;
            
            switch (outputColorSpace)
                case OutputColorFormat.ANY
                    if isstruct(frames)
                        % Frames must always be RGB images or convertible
                        % to RGB images.
                        frames = VideoWriter.convertFramesToRGB(frames);
                    end
                    
                case OutputColorFormat.RGB
                    frames = VideoWriter.convertFramesToRGB(frames);
                    
                case OutputColorFormat.MONOCHROME
                    frames = VideoWriter.convertFramesToMono(frames);
                    
                case OutputColorFormat.INDEXED
                    frames = VideoWriter.convertFramesToIndexed(frames);
                    
                    frames = VideoWriter.convertToPrefDataTypeForIndexed(frames, prefOutputDataType);
                    
                case OutputColorFormat.GRAYSCALE
                    % No colormap must be specified when writing Grayscale
                    % AVI files
                    frames = VideoWriter.convertFramesToIndexed(frames);
                    
                    if isstruct(frames) && ~all( arrayfun( @(x) isempty(x.colormap), frames) )
                        error(message('MATLAB:audiovideo:VideoWriter:noColormapForGrayscale'));
                    end
                    
                otherwise
                    assert(false, 'Unknown ColorFormat for this profile.');
            end
            
            % Verify that a valid frame has been provided.
            VideoWriter.verifyNumBands(frames);
                                
            % Convert the data type to the profile's preferred data type.
            % The datatype conversion is to be performed on the image data
            % and not on the colormap.
            if isstruct(frames)
                for cnt = 1:numel(frames)
                    frames(cnt).cdata = VideoWriter.convertDataType(frames(cnt).cdata, prefOutputDataType);
                end
            else
                frames = VideoWriter.convertDataType(frames, prefOutputDataType);
            end
        end
        
        function outFrames = convertFramesToRGB(frames)
            % Convert frames into an HxWx3xF representation assumed to be
            % the RGB color space.
            
            % Are the frames an array?            
            if ~isstruct(frames)
                
                if (ndims(frames) > 4)
                    error(message('MATLAB:audiovideo:VideoWriter:badBands'));
                end
            
                VideoWriter.verifyNumBands(frames);
                
                % Need to get all four dimensions so that they're not all
                % collapsed into the last dimension.
                [~, ~, bands, ~] = size(frames);
                
                % If the data is an array, it must be either three banded
                % or single banded.  Three banded data is assumed to be
                % RGB.  Single banded data is converted to RGB by
                % replicating the data for each band.
                if (bands == 3)
                    outFrames = frames;
                    return;
                elseif (bands == 1)
                    outFrames = repmat(frames, [1 1 3 1]);
                    return
                end
            else
                % Data passed in was a struct.
                VideoWriter.validateFrameStruct(frames);
                
                sizes = arrayfun(@(x) size(x.cdata), frames, 'UniformOutput', false);
                
                hasColormap = arrayfun(@(x) ~isempty(x.colormap), frames);
                
                if any(hasColormap) && ~all(hasColormap)
                    error(message('MATLAB:audiovideo:VideoWriter:allColormap'));
                end
                    
                if all(hasColormap)
                    
                    % Data here should be HxW or HxWx1 only 
                    if ((length(sizes{1}) ~= 2) && sizes{1}(3) ~= 1)
                        error(message('MATLAB:audiovideo:VideoWriter:badCData'));
                    end
                                        
                    outFrames = zeros([sizes{1}, 3, length(frames)]);
                    for ii = 1:length(frames)
                        try
                            outFrames(:,:,:,ii) = ind2rgb(frames(ii).cdata, frames(ii).colormap);
                        catch err
                            error(message('MATLAB:audiovideo:VideoWriter:invalidind2rgb'));
                        end
                    end
                else
                    % Make sure that all of the cdata elements have the
                    % same data type.
                    dataTypes = arrayfun(@(x) class(x.cdata), frames, 'UniformOutput', false);
                    if ~all(strcmp(dataTypes{1}, dataTypes))
                        error(message('MATLAB:audiovideo:VideoWriter:inconsistentDataTypes'));
                    end
                    
                    % Make sure that all of the cdata fields are three
                    % banded.
                    if (numel(sizes{1}) ~= 3)
                        error(message('MATLAB:audiovideo:VideoWriter:RGBImageInFrame'))
                    end
                    outFrames = zeros([sizes{1} length(frames)], class(frames(1).cdata));
                    for ii = 1:length(frames)
                        outFrames(:,:,:,ii) = frames(ii).cdata;
                    end
                end
            end
        end
        
        function frames = convertFramesToMono(frames)
            % Convert frames to monochrome.  Currently no colorspace
            % conversion is done, so this function just validates, and if
            % necessary converts, the frames to a HxWx1xF array.
            if ~isstruct(frames)
                if(ndims(frames) > 4)
                    error(message('MATLAB:audiovideo:VideoWriter:badBands'));
                end
                
                [m, n, bands, numFrames] = size(frames);
                
                if ( (numFrames ~= 1) && (bands ~= 1) )
                    error(message('MATLAB:audiovideo:VideoWriter:badBands'));
                end
                
                frames = reshape(frames, [m n 1 max(bands, numFrames)]);
                return;
            else
                error(message('MATLAB:audiovideo:VideoWriter:framesUnsupported'));
            end
        end
        
        function frames = convertFramesToIndexed(frames)
            % Convert frames to indexed. 
            if ~isstruct(frames)
                [~, ~, bands, ~] = size(frames);
                if bands == 3
                    error(message('MATLAB:audiovideo:VideoWriter:invalidDataDimsGrayscaleIndexed'));
                end
                frames = VideoWriter.convertFramesToMono(frames);
            else
                VideoWriter.validateFrameStruct(frames);
                
                sizes = arrayfun(@(x) size(x.cdata), frames, 'UniformOutput', false);
                
                % Data here should be HxW or HxWx1 only 
                if ((length(sizes{1}) ~= 2) && sizes{1}(3) ~= 1)
                    error(message('MATLAB:audiovideo:VideoWriter:badCData'));
                end
                
                % Make sure that all of the cdata elements have the
                % same data type.
                dataTypes = arrayfun(@(x) class(x.cdata), frames, 'UniformOutput', false);
                if ~all(strcmp(dataTypes{1}, dataTypes))
                    error(message('MATLAB:audiovideo:VideoWriter:inconsistentDataTypes'));
                end
            end
        end
            
        function outputFrames = convertDataType(inputFrames, prefDataType)
            % Convert the frames to the correct data type.  Frames that are
            % doubles or singles must be in the range [0, 1].  Frames that
            % are of an integer type smaller than that requested by the
            % profile are upconverted.
            
            % Figure out the allowed data types for the profile and
            % determine if the supplied image is of an allowable type.
            VideoWriter.validateAllowableFrameDataTypes(inputFrames, prefDataType);

            curDataType = class(inputFrames);
                                    
            % No conversion case.
            if ismember(curDataType, prefDataType)
                outputFrames = inputFrames;
                return;
            end
            
            % Validate range for floating point data.
            if any(strcmp(curDataType, {'single', 'double'}))
                if (min(inputFrames(:)) < 0) || (max(inputFrames(:)) > 1)
                    error(message('MATLAB:audiovideo:VideoWriter:invalidRange', curDataType));
                end
            end
            
            if length(prefDataType) ~= 1
                error(message('MATLAB:audiovideo:VideoWriter:invalidConversion', curDataType));
            end
            
            if any(strcmp(curDataType, {'single', 'double'}))
                % Convert single and double frames into the appropriate data
                % type.
                minval = double(intmin(prefDataType{1}));
                maxval = double(intmax(prefDataType{1}));
                outputFrames = cast(inputFrames .* (maxval - minval) - minval, prefDataType{1});
                return
            end

            % Otherwise we need to convert from a smaller data type to a
            % larger data type.
            try
                outputFrames = VideoWriter.convertFrameDataType(prefDataType{1}, curDataType, inputFrames);
            catch err
                error(message('MATLAB:audiovideo:VideoWriter:invalidUpConversion', curDataType, prefDataType{1}));
            end
        end
        
        function frames = convertToPrefDataTypeForIndexed(frames, prefDataType)
            dataTypeConvFcn = str2func(prefDataType{1});
            % If the 'cdata' is of type 'double' or 'single', then the
            % value 1 points to the first row of the colormap. For uint8,
            % the value 0 points to the first row of the colormap.
            if isstruct(frames)
                arrayfun(@(x) validateattributes(x.cdata, {'uint8', 'single', 'double'}, ...
                                                          {'integer', ...
                                                          '>=', 0, ...
                                                          '<=', 255}), ...
                                                          frames);
                if ~isa(frames(1).cdata, prefDataType{1})
                    dataTypeConvFcn = str2func(prefDataType{1});
                    for cnt = 1:numel(frames)
                        frames(cnt).cdata = dataTypeConvFcn(frames(cnt).cdata-1);
                    end
                end
            else
                validateattributes(frames, {'uint8', 'single', 'double'}, ...
                                           {'integer', '>=', 0, '<=', 255});
                if ~isa(frames, prefDataType{1})
                    frames = dataTypeConvFcn(frames-1);
                end
            end
        end
        
        function numFrames = computeNumFrames(frames)
            if isstruct(frames)
                numFrames = length(frames);
            else
                numFrames = size(frames, 4);
            end
        end
        
        function validateFrameStruct(frames)
            if ~isa(frames, 'struct')
                return;
            end
            
            fields = fieldnames(frames);
                
            % Structs must have only cdata and colormap fields.
            if ~isequal({'cdata'; 'colormap'}, sort(fields(:)))
                error(message('MATLAB:audiovideo:VideoWriter:badStruct'));
            end

            % Verify that the cdata is actually provided.
            dataPresent = arrayfun(@(x) ~isempty(x.cdata), frames);

            if ~all(dataPresent) 
                error(message('MATLAB:audiovideo:VideoWriter:noCData'));
            end

            % Verify that the sizes of the images are all the same.
            sizes = arrayfun(@(x) size(x.cdata), frames, 'UniformOutput', false);

            if (length(sizes) > 1) && ~isequal(sizes{:})
                error(message('MATLAB:audiovideo:VideoWriter:cdataSize'));
            end
        end
        
        function [height, width] = getFrameSize(frame)
            % Determine the height and width of a frame independent of the
            % input format.
            
            if isstruct(frame)
                [height, width, ~] = size(frame(1).cdata);
            else
                [height, width, ~] = size(frame);
            end
        end
        
        function fullFileName = generateFullOutputFileName(fileName, profile)
            % Helper function that validates the output file specified and
            % also generates the fully qualified file path
            
            import audiovideo.internal.writer.profile.ProfileFactory;
            
            % The output file name can only be a row of characters.
            validateattributes(fileName, {'char'}, {'row', 'nonempty'}, 'VideoWriter');
            
            % Validate that the filename has the correct extension.
            try
                validExtensions = ProfileFactory.getFileExtensions(profile);
            catch err
                throw(err);
            end
            
            % Verify if the extension specified for the file is valid for
            % the profile chosen. If the extension does not match or if no
            % extension is provded, append the default extension for the
            % profile to the file name.
            [~, ~, fileExt] = fileparts(fileName);
            
            newFileName = fileName;
            if ~ismember(lower(fileExt), validExtensions)
                newFileName = [fileName validExtensions{1}];
            end
            
            fileObj = multimedia.internal.io.FilePath(newFileName);
            
            % Check if the path specified is valid
            if isempty(fileObj.Absolute)
                pathStr = fileparts(fileObj.Path);
                error(message('MATLAB:audiovideo:VideoWriter:folderNotFound', pathStr));
            end
            
            if ~fileObj.Writeable
                error(message('MATLAB:audiovideo:VideoWriter:fileNotWritable', fileName));
            end
            
            fullFileName = fileObj.Absolute;
        end
    end
end
