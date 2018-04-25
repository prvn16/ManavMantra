% This undocumented class may be removed in a future release.

% IMREADADAPTER IMREAD ImageAdapter class.
%   ADPT = ImreadAdapter(filename) creates an ImreadAdapter object, ADPT,
%   associated with the image file FILENAME.  The ImreadAdapter uses IMREAD
%   and IMFINFO to return data and information about the image via the
%   ImageAdapter interface.
%
%   The ImreadAdapter class is read-only.
%
%   See also BLOCKPROC, IMAGEADAPTER.

%   Copyright 2009 The MathWorks, Inc.

classdef ImreadAdapter < ImageAdapter
    
    properties (Access = private)
        
        Filename;   %  filename
        Info;       %  imfinfo struct 
        
    end  % private properties
    
    methods
        
        %-------------------------------------------
        function obj = ImreadAdapter(input_filename)
            
            obj.Filename = input_filename;
            obj.Info = imfinfo(input_filename);
            
            if ~strcmpi(obj.Info.Format, 'jp2') && ...
                    ~strcmpi(obj.Info.Format, 'jpf') && ...
                    ~strcmpi(obj.Info.Format, 'jpx') && ...
                    ~strcmpi(obj.Info.Format, 'j2c') && ...
                    ~strcmpi(obj.Info.Format, 'j2k') && ...
                    ~strcmpi(obj.Info.Format, 'tif') && ...
                    ~strcmpi(obj.Info.Format, 'tiff')
                error(message('images:ImreadAdapter:invalidFormat'));
            end
            
            % get size
            channels = numel(obj.Info.BitsPerSample);
            if (channels == 1)
                obj.ImageSize = [obj.Info.Height, obj.Info.Width];
            else
                obj.ImageSize = [obj.Info.Height, obj.Info.Width, channels];
            end            
            
        end % ImreadAdapter
        
        
        %----------------------------------------------
        function result = readRegion(obj, start, count)
            
            result = imread(obj.Filename, 'PixelRegion', ...
                {[start(1), start(1) + count(1) - 1], ...
                [ start(2), start(2) + count(2) - 1]});
            
        end % readRegion
        
        
        %------------------
        function close(obj)
            
            obj.Filename = [];
            obj.Info = [];
            obj.ImageSize = [];
            
        end % close
        
    end % public methods
    
end % ImreadAdapter

