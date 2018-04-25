classdef (Hidden) OutputColorFormat
   %OUTPUTCOLORFORMAT Define the desired output format for VideoWriter profiles.
   %
   %   The OutputColorFormat class contains enumerations that allow a
   %   VideoWriter profile to specify what the desired colorspace is for
   %   data to be written.  This allows VideoWriter to convert the data
   %   into the correct colorspace before passing it to the profile for
   %   writing.
   
   % Copyright 2010-2013 The MathWorks, Inc.
      
    enumeration
        ANY % The profile will accept any color space.  No conversion is necessary.
        RGB % The profile requires RGB data.
        MONOCHROME % The profile requires single banded data.
        YCBCR % The profile requires YCbCr data.
        INDEXED % This profile requires indexed data.
        GRAYSCALE % This profile requires grayscale data.
    end
end