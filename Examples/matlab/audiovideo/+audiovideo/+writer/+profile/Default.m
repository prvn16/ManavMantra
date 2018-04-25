classdef (Hidden) Default < audiovideo.writer.profile.MotionJpegAVI
    %DEFAULT The default profile for VideoWriter objects.
    %   The Default profile for  VideoWriter objects is the profile that is
    %   used if no profile is specified in the VideoWriter constructor.  This
    %   class has not methods or data of its own, it is simply a subclass
    %   of the profile that should be used in the default case.
    %
    %   See also VideoWriter.
    
    % Copyright 2009-2013 The MathWorks, Inc.

    
    methods
        function obj = Default(varargin)            
            obj = obj@audiovideo.writer.profile.MotionJpegAVI(varargin{:});
        end
    end    
end

