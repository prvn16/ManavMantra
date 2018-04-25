% IMAGEADAPTER Interface for image format I/O.
%   ImageAdapter specifies the Image Processing Toolbox interface for
%   region-based reading and writing of image files.  Classes that inherit
%   from the ImageAdapter interface can be used with the Image Processing
%   Toolbox function BLOCKPROC, enabling file-based processing for their
%   image file format.
%
%   The ImageAdapter class defines the following class properties:
% 
%      Colormap
%      ---------
%         im_map = adapter.Colormap;
% 
%         The Colormap property is a 2-D, real, M-by-3 matrix specifying a
%         colormap.  The Colormap is used when working with indexed images.
%         The default value of Colormap is empty ([]) indicating either a
%         grayscale, logical, or truecolor image. 
%   
%      ImageSize
%      ---------
%         im_size = adapter.ImageSize;
% 
%         The ImageSize property holds the size of the entire image in a 2
%         or 3 element vector specified as [rows cols] ([height width]) or 
%         [rows cols bands].  This property must be set in the class
%         constructor.
%
%   ImageAdapters are required to concretely implement the following
%   methods:
%
%      Class Constructor
%      -----------------
%         adapter = ClassName(...)
%
%         The class constructor can take any number of arguments.  It is
%         responsible for setting the initial values of any class
%         properties along with handling any other object initialization or
%         file opening/creation responsibilities.
%
%      readRegion
%      ----------
%         data = adapter.readRegion(region_start, region_size)
%
%         Reads a region of the image.  REGION_START and REGION_SIZE define
%         a rectangular region in the image.  REGION_START is a 2-element
%         vector specifying the [row col] of the first pixel (minimum-row,
%         minimum-column) of the region.  REGION_SIZE is a 2-element vector
%         specifying the size of the requested region in [rows cols].
%
%      close
%      -----
%         adapter.close()
%
%         Closes the ImageAdapter object and performs any necessary clean
%         up, such as closing file handles.
%
%   ImageAdapters can optionally concretely implement (overload) the
%   following method to enable writing data.  ImageAdapters that do not
%   overload this method will be read-only.
%
%      writeRegion
%      -----------
%         adapter.writeRegion(region_start, region_data)
%
%         Writes a contiguous block of data to a region of the image.  The
%         block of data, specified by the REGION_DATA argument, is written
%         to the target region.  REGION_START is a 2-element vector
%         specifying the [row col] location of the first pixel
%         (minimum-row, minimum-column) of the target region in the image.
%
%   For more information on writing Image Adapter classes, see "Writing an
%   Image Adapter Class" in the Image Processing Toolbox documentation.
%   For more information on using Image Adapter classes for block
%   processing see the documentation for BLOCKPROC.
%
%   See also BLOCKPROC.

%   Copyright 2009-2010 The MathWorks, Inc.

classdef ImageAdapter < handle
    
    % Required Properties
    % -------------------
    % These properties must be set by classes inheriting from ImageAdapter.
    properties(GetAccess = public, SetAccess = protected)
        ImageSize = [];
        Colormap = [];
    end

    
    % Required Methods
    % ----------------
    % These methods must be concretely implemented by classes inheriting
    % from ImageAdapter.
    methods (Abstract)
        
        data = readRegion(obj, region_start, region_size)
        [] = close(obj)
        
    end % required methods
    
    
    % Optional Methods
    % ----------------
    % These methods need not be implemented by inheriting classes.  Classes
    % that do not overload these methods will inherit their default
    % implementations (below) and will subsequently be read-only.
    methods
        
        function [] = writeRegion(obj, region_start, region_data) %#ok<MANU,INUSD>
            error(message('images:ImageAdapter:NoWriteRegionMethod'))
        end
        
    end % optional methods
    
end % ImageAdapter
