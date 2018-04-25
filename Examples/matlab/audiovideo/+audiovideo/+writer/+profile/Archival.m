classdef Archival < audiovideo.writer.profile.MJ2000
    % Archival - Write lossless compression video files.
    %    The Arvhival profile is similar to the Motion JPEG 2000 profile
    %    except that lossless compression is enabled by default.
    %
    %    See also VideoWriter audiovideo.writer.profile.MJ2000.
    
    % Copyright 2010-2013 The MathWorks, Inc.

    methods
        function obj = Archival(filename)
            if nargin == 0
                filename = '';
            end
            
            obj = obj@audiovideo.writer.profile.MJ2000(filename, true);
            obj.Name = 'Archival';
            obj.Description = getString(message('MATLAB:audiovideo:VideoWriter:CompressionWithJPEG2000CodecLosslessMode'));
        end
    end

end