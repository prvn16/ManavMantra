classdef FileFormatInfo < hgsetget
    %FILEFORMATINFO A description of an audiovideo file format
    %   
    %   FORMAT = FILEFORMATINFO(EXTENSION, DESCRIPTION, CONTAINSVIDEO, CONTAINSAUDIO)
    %   returns a FileFormatInfo object.  EXTENSION is the file extension
    %   for the file format.  DESCRIPTION is a description of the file
    %   format. CONTAINSAUDIO is a boolean which specifies if the file
    %   format can hold audio daa.  CONTAINSVIDEO is a boolean which
    %   specifies if the file format can hold VIDEO data.
    %
    %   See also VIDEOREADER.GETFILEFORMATS
    %
    %   Authors: NH
    %   Copyright 2009-2013 The MathWorks, Inc.
    
    properties(GetAccess='public', SetAccess='private')
        Extension      % The file extension for this file format
        Description    % A text description of the file format
        ContainsAudio  % The File Format can hold video data
        ContainsVideo  % The File Format can hold audio data
    end
    
    %------------------------------------------------------------------
    % Documented methods
    %------------------------------------------------------------------
    methods(Access='public')
        
        %------------------------------------------------------------------
        % Lifetime
        %------------------------------------------------------------------
        function obj = FileFormatInfo(Extension, Description, ContainsVideo, ContainsAudio)
            if (~ContainsVideo && ~ContainsAudio)
                error(message('MATLAB:audiovideo:audiovideo:invalidArguments'));
            end
            
            obj.Extension = Extension;
            obj.Description = Description;
            obj.ContainsVideo = ContainsVideo;
            obj.ContainsAudio = ContainsAudio;
        end
 
        %------------------------------------------------------------------
        % Operations
        %------------------------------------------------------------------
      
        function filterSpec = getFilterSpec( obj, varargin )
            %GETFILTERSPEC Return a cell array for use in file dialogs
            %
            %   FILTERSPEC = GETFILTERSPEC( OBJ ) returns a cell array of
            %   fileformats from an AUDIOVIDEO.FILEFORMATINFO object, formatted in 
            %   a FILTERSPEC for use in the uigetfile and uiputfile functions.
            %
            %   FILTERSPEC = GETFILTERSPEC( OBJ, MEDIATYPE ) returns a FILTERSPEC
            %   containing only the specified MEDIATYPE.  MEDIATYPE is a
            %   string with the following possible values
            %      'video' - Return video file formats
            %      'audio' - Return audio file formats
            %      'all'   - Return all file formats
            %
            %   See also AUDIOVIDEO.FILEFORMATINFO, UIGETFILE, UIPUTFILE
            
            narginchk(1,2);
            
            mediaType = 'all';
            if nargin == 2
                mediaType = varargin{1};
            end
            
            videoSpec = {};
            if (strcmpi(mediaType, 'video') || strcmpi(mediaType, 'all'))
                videoSpec = getFilterSpecWithLabel(getVideoFormats(obj), getString(message('MATLAB:audiovideo:audiovideo:AllVideoFiles')));
            end
            
            audioSpec = {};
            if (strcmpi(mediaType, 'audio') || strcmpi(mediaType, 'all'))
                audioSpec = getFilterSpecWithLabel(getAudioFormats(obj),  getString(message('MATLAB:audiovideo:audiovideo:AllAudioFiles')));
            end
            
            allTypesSpec = {};
            if ~isempty(videoSpec) && ~isempty(audioSpec)
                allTypesSpec = getFilterSpecWithLabel(obj, getString(message('MATLAB:audiovideo:audiovideo:AllVideoAudioFiles')));
            end
                
            switch lower(mediaType)
                case 'video'
                    formats = getVideoFormats(obj);
                case 'audio'
                    formats = getAudioFormats(obj);
                case 'all'
                    formats = obj;
                otherwise
                    error(message('MATLAB:audiovideo:audiovideo:invalidMediaType')); 
            end
            
            
            filterSpec = cell(length(formats), 2);
            for ii = 1:length(formats)
                filterSpec{ii, 1} = sprintf('*.%s', formats(ii).Extension);
                filterSpec{ii, 2} = sprintf('%s (*.%s)',formats(ii).Description, formats(ii).Extension);
            end
            
            allFilesSpec = {'*.*', 'All Files (*.*)'};
            
            filterSpec = [allTypesSpec; videoSpec; audioSpec; filterSpec; allFilesSpec];
        end
        
        
        function disp(obj)
            display(obj);
        end
        
        function display(obj)
            printFormatsWithLabel(getVideoFormats(obj), getString(message('MATLAB:audiovideo:audiovideo:VideoFileFormats')));
            printFormatsWithLabel(getAudioFormats(obj), ...
                                  getString(message('MATLAB:audiovideo:audiovideo:AudioFileFormats')));
        end
    end
    
    methods(Access='private', Hidden)
        
        function printFormats(obj)
            % PRINTFORMATS print a list of file formats for display
            for ii = 1:length(obj)
                fprintf('%8s - %s\n', ...
                    sprintf('%s%s','.',obj(ii).Extension), ...
                    obj(ii).Description);
            end
        end
        
        function printFormatsWithLabel(obj, formatLabel)
            %PRINTFORMATSWITHLABEL print a labeled list of file formats
            %
            %  PRINTFORMATSWITHLABEL(FORMATS, FORMATLABEL) prints a
            %  formatted list file FORMATS with the FORMATLABEL at the top.
            
            if ~isempty(obj)
                fprintf('%s:\n', formatLabel);
                printFormats(obj);
            end
        end
        
        function filterSpec = getFilterSpecWithLabel( obj, formatLabel )
            %GETFILTERSPECWITHLABEL create a single labeled filterspec
            %   
            %   FILTERSPEC = GETFILTERSPECWITHLABEL( FORMATS, FORMATLABEL) 
            %   Given a list of FORMATS and a FORMATLABEL, this function
            %   creates a single FILTERSPEC entry with a discription of
            %   FORMATLABEL.
            
            if isempty(obj)
                filterSpec = {};
                return;
            end
            
            % Build up a filterspec for each file format provided
            % see uigetfile/uiputfile help for more info on filterspec
            % formatting.
            filterSpec = cell(1, 2);
            for ii = 1:length(obj)
                filterSpec{1, 1} = [filterSpec{1, 1} '*.' obj(ii).Extension ';'];
            end
            filterSpec{1, 2} = formatLabel;
        end
        
        function formats = getVideoFormats(obj)
            % GETVIDEOFORMATS return only formats that have video
            
            formats = obj([obj.ContainsVideo]);
        end
        
        function formats = getAudioFormats(obj)
            % GETAUDIOFORMATS return only fileformats that have audio and
            % no video
            formats = obj([obj.ContainsAudio] & ~[obj.ContainsVideo]);
        end
    end
    
end

