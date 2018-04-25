classdef Tiff < handle
%MATLAB Gateway to LibTIFF library routines.
%   obj = Tiff(filename,mode) creates a Tiff object associated with the
%   TIFF filename in the specified mode:
%
%          'r'     open TIFF file for reading.
%          'w'     open TIFF file for writing; discard existing contents.
%          'w8'    open TIFF file for writing a BigTIFF file; discard 
%                  existing contents.
%          'a'     open or create TIFF file for writing; created files will 
%                  be in 32-bit TIFF format; any existing file format will
%                  be preserved; append image data to end of file
%          'r+'    open (do not create) TIFF file for reading and writing.
%
%   If the mode is not given, the default is 'r'.
%
%   When a TIFF file is opened for reading, the first image becomes
%   current.
%
%   If you open a file for writing or appending, Tiff automatically creates 
%   a default image file directory (IFD)  for writing subsequent data.  
%   This IFD has default values as specified in Tiff Revision 6.0.
%
%   When creating a new image, you must supply values for certain required 
%   fields before writing any image data.  Use the setTag method to set 
%   these fields, including ImageWidth, ImageLength, BitsPerSample, 
%   SamplesPerPixel, Compression, PlanarConfiguration, and Photometric. If 
%   the image layout is stripped, you must also specify RowsPerStrip. If 
%   the image layout is tiled, you must specify both TileWidth and 
%   TileHeight.  Omission of these tags or specifying improper combinations 
%   may result in an invalid file. To verify compliance with the TIFF 
%   specification, use IMFINFO or IMREAD on the newly created file. 
%
%   The Tiff object provides access to many of the capabilities of the
%   LibTIFF library via methods.  In most cases, the syntax of the Tiff
%   method is similar to the syntax of the corresponding LibTIFF library
%   function.
%
%   Tiff methods:
%     Image File Directory (IFD) Methods
%       close             - Close Tiff object
%       currentDirectory  - Return index of current directory.
%       lastDirectory     - Return true if current directory is last in file.
%       nextDirectory     - Make next directory current directory.
%       setDirectory      - Make specified directory current directory.
%       setSubDirectory   - Set current directory by byte offset.
%       writeDirectory    - Write current directory to file.
%       rewriteDirectory  - Write modified metadata to existing directory.
%
%     Image I/O Methods 
%       readEncodedStrip  - Read data from specified strip.
%       readEncodedTile   - Read data from specified tile.
%       readRGBAStrip     - Read RGBA data from specified strip.
%       readRGBATile      - Read RGBA data from specified tile.
%       readRGBAImage     - Read RGBA image.
%       writeEncodedStrip - Write data to specified strip.
%       writeEncodedTile  - Write data to specified tile.
%       read              - Read entire image.
%       write             - Write entire image.
%
%     Layout Inquiry Methods
%       isTiled           - Return true if image is tiled.
%       numberOfStrips    - Return number of strips in image.
%       numberOfTiles     - Return number of tiles in image.
%       computeStrip      - Return number of strip containing specified coordinate.
%       computeTile       - Return number of tile containing specified coordinates.
%
%     Tag Methods 
%       getTag            - Retrieve tag from image.
%       setTag            - Write tag to image.
%
%     Miscellaneous Methods 
%       getVersion        - Returns LibTIFF library version.
%       getTagNames       - Retrieve list of known tags.
%
%   Tiff properties:
%     TagID               - Supported tags
%     Compression         - Compression schemes
%     Photometric         - Colorspace of the image
%     PlanarConfiguration - Image layer layout
%     SampleFormat        - Pixel datatype
%     JPEGColorMode       - YCbCr/JPEG conversion
%     Thresholding        - Conversion method from gray to bilevel
%     ExtraSamples        - Extra layer description
%     SubFileType         - Type of image within the file
%     Orientation         - Intended visual orientation of image
%     Group3Options       - Options for Group 3 Fax Compression
%     ResolutionUnit      - The unit of measurement
%     InkSet              - Set of inks used in a separated image
%     YCbCrPositioning    - Relative position of chrominance samples
%     SGILogDataFmt       - Specify control of SGILog codec
%
%   To use the Tiff object, you should be familiar with the TIFF 
%   Specification and technical notes which may be found by visiting the 
%   LibTIFF web site at <http://www.remotesensing.org/libtiff/>.
%
%   Please read the file libtiffcopyright.txt for more information.
%
%   See also IMREAD, IMFINFO, IMWRITE

%   Copyright 2009-2017 The MathWorks, Inc.

    properties (GetAccess = public,SetAccess=protected)
        %FileName - Name of the TIFF file
        %    This property identifies the path to the TIFF file.
        FileName
    end 
    properties (Access = protected)
        % The FileID is the file handle that is passed to LibTIFF.
        FileID 
    end 
    properties (Access = protected)
        % The mode is how the file was opened.
        Mode 
    end 
    properties (Access = protected)
        % We need to enforce a certain order as to how tags are written.
        % Order matters.
        CriticalTags = {'Photometric', ...
            'BitsPerSample',  ...
            'SamplesPerPixel',  ...
            'Compression',      ...
            'SampleFormat',     ...
            'ExtraSamples',     ...
            'ImageLength',      ...
            'ImageWidth',       ...
            'TileLength',       ...
            'TileWidth',        ...
            'RowsPerStrip',     ...
            'PlanarConfiguration', ...
            'ColorMap'           };
    end 
    properties (GetAccess = public, Constant = true)
        % TagID - List of recognized tags
        %    This property identifies a tag that may be set using 
        %    the setTag method.  The list of all such tags may be 
        %    retrieved with the getTagNames method.  For detailed 
        %    information for each tag, one may reference the TIFF 
        %    specification and technical notes at 
        %    <http://www.remotesensing.org/libtiff/>.
        %
        %    See also setTag, getTag
        %
        TagID = struct('SubFileType',               254,...
                       'ImageWidth',                256, ...
                       'ImageLength',               257, ...
                       'BitsPerSample',             258, ...
                       'Compression',               259, ...
                       'Photometric',               262, ...
                       'Thresholding',              263, ...
                       'FillOrder',                 266, ...
                       'DocumentName',              269, ...
                       'ImageDescription',          270, ...
                       'Make',                      271, ...
                       'Model',                     272, ...
                       'StripOffsets',              273, ...
                       'Orientation',               274, ...
                       'SamplesPerPixel',           277, ...
                       'RowsPerStrip',              278, ...
                       'StripByteCounts',           279, ...
                       'MinSampleValue',            280, ...
                       'MaxSampleValue',            281, ...
                       'XResolution',               282, ...
                       'YResolution',               283, ...
                       'PlanarConfiguration',       284, ...
                       'PageName',                  285, ...
                       'XPosition',                 286, ...
                       'YPosition',                 287, ...
                       'Group3Options',             292, ...
                       'Group4Options',             293, ...
                       'ResolutionUnit',            296, ...
                       'PageNumber',                297, ...
                       'TransferFunction',          301, ...
                       'Software',                  305, ...
                       'DateTime',                  306, ...
                       'Artist',                    315, ...
                       'HostComputer',              316, ...
                       'WhitePoint',                318, ...
                       'PrimaryChromaticities',     319, ...
                       'ColorMap',                  320, ...
                       'HalfToneHints',             321, ...
                       'TileWidth',                 322, ...
                       'TileLength',                323, ...
                       'TileOffsets',               324, ...
                       'TileByteCounts',            325, ...
                       'SubIFD',                    330, ...
                       'InkSet',                    332, ...
                       'InkNames',                  333, ...
                       'NumberOfInks',              334, ...
                       'DotRange',                  336, ...
                       'TargetPrinter',             337, ...
                       'ExtraSamples',              338, ...
                       'SampleFormat',              339, ...
                       'SMinSampleValue',           340, ...
                       'SMaxSampleValue',           341, ...
                       'YCbCrCoefficients',         529, ...
                       'YCbCrSubSampling',          530, ...
                       'YCbCrPositioning',          531, ...
                       'ReferenceBlackWhite',       532, ...
                       'XMP',                       700, ...
                       'ImageDepth',              32997, ...
                       'Copyright',               33432, ...
                       'ModelPixelScaleTag',      33550, ...
                       'RichTIFFIPTC',            33723, ...
                       'ModelTiepointTag',        33922, ...
                       'ModelTransformationTag',  34264, ...
                       'Photoshop',               34377, ...
                       'ICCProfile',              34675, ...
                       'GeoKeyDirectoryTag',      34735, ...
                       'GeoDoubleParamsTag',      34736, ...
                       'GeoASCIIParamsTag',       34737, ...
                       'SToNits',                 37439, ...
                       'JPEGQuality',             65537, ...
                       'JPEGColorMode',           65538, ...
                       'ZipQuality',              65557, ...
                       'SGILogDataFmt',           65560);
    end % properties
    properties (GetAccess = public, Constant = true)
        % SubFileType - indicates the type of image
        %    SubFileType is a bitmask that indicates the type of the image.  
        %    It should only be used when setting the 'SubFileType' tag.  It 
        %    need not be specified if the file has only one image or for 
        %    the first file.
        %
        %    Available enumerated SubFileType values include
        %
        %        Default      - Default value for single image file or 
        %                       first image.
        %        ReducedImage - The current image is a thumbnail or 
        %                       reduced-resolution image that typically 
        %                       would be found in a sub IFD.
        %        Page         - The image is a single image of a multi-
        %                       image (or multipage) file.
        %        Mask         - The image is a transparency mask for 
        %                       another image in the file.  The 
        %                       photometric interpretation value must be 
        %                       Photometric.Mask.
        %
        %    Example:  
        %       tiffobj.setTag('SubFileType',Tiff.SubFileType.ReducedImage);
        %
        %    See also:  Tiff.Photometric
        SubFileType = struct('Default',                 0,...
                             'ReducedImage',            1,...
                             'Page',                    2,...
                             'Mask',                    4);
    end % properties
    properties (GetAccess = public, Constant = true)
        % Compression - specifies a scheme to compress the image data
        %    These enumerated values should only be used when setting the 
        %    'Compression' tag.  Available compression schemes include 
        % 
        %       None
        %       CCITTRLE     - read-only
        %       CCITTFax3
        %       CCITTFax4
        %       LZW
        %       JPEG
        %       CCITTRLEW    - read-only
        %       PackBits
        %       SGILog
        %       SGILog24
        %       Deflate
        %       AdobeDeflate - same as Deflate
        %
        %    Example:  
        %       tiffobj.setTag('Compression',Tiff.Compression.None);
        %
        Compression = struct('None',                  1,...
                             'CCITTRLE',              2,...
                             'CCITTFax3',             3,...
                             'CCITTFax4',             4,...
                             'LZW',                   5,...
                             'OJPEG',                 6,...
                             'JPEG',                  7,...
                             'AdobeDeflate',          8, ...
                             'Next',              32766, ...
                             'CCITTRLEW',         32771,...
                             'PackBits',          32773,...
                             'Thunderscan',       32809, ...
                             'IT8CTPad',          32895, ...
                             'IT8LW',             32896, ...
                             'IT8MP',             32897, ...
                             'IT8BL',             32898, ...
                             'PixarFilm',         32908, ...
                             'PixarLog',          32909, ...
                             'Deflate',           32946, ...
                             'DCS',               32947, ...
                             'JBIG',              34661, ...
                             'SGILog',            34676, ...
                             'SGILog24',          34677, ...
                             'JPEG2000',          34712);
    end % properties
    properties (GetAccess = public, Constant = true)
        % Photometric - specifies the color space of the image data
        %    This property should only be used when setting the 
        %    'Photometric' tag.  Supported photometric 
        %    interpretation schemes include
        %
        %       MinIsWhite
        %       MinIsBlack
        %       RGB
        %       Palette
        %       Mask
        %       Separated (CMYK)
        %       YCbCr
        %       CIELab
        %       ICCLab
        %       ITULab
        %       LogL
        %       LogLuv
        %       CFA
        %       LinearRaw
        %
        %    Example:  
        %       tiffobj.setTag('Photometric', Tiff.Photometric.RGB);
        Photometric = struct('MinIsWhite',            0,...
                             'MinIsBlack',            1, ...
                             'RGB',                   2, ...
                             'Palette',               3, ...
                             'Mask',                  4, ...
                             'Separated',             5, ...
                             'YCbCr',                 6, ...
                             'CIELab',                8, ...
                             'ICCLab',                9, ...
                             'ITULab',               10, ...
                             'CFA',               32803, ...
                             'LogL',              32844, ...
                             'LogLuv',            32845, ...
                             'LinearRaw',         34892);
    end % properties
    properties (GetAccess = public, Constant = true)
        % Thresholding - conversion method from gray to black and white
        %    Thresholding specifies the technique used to convert from
        %    gray to black and white pixels.  This property should only be
        %    used when setting the 'Thresholding' tag.  Supported 
        %    enumerated values include
        %
        %        BiLevel
        %        HalfTone
        %        ErrorDiffuse
        %
        %    The default value is BiLevel 
        %
        %    Example:  
        %        tiffobj.setTag('Thresholding', Tiff.Thresholding.HalfTone);
        Thresholding = struct('BiLevel',      1,...
                               'HalfTone',     2, ...
                               'ErrorDiffuse', 3 );
    end % properties
    properties (GetAccess = public, Constant = true)
        % Orientation - specifies visual orientation of the image data.
        %    This property should only be used when setting the 
        %    'Orientation' tag.  Support for this tag is for informational 
        %    purposes only, and it does not affect how MATLAB reads or 
        %    writes the image data.  Supported enumerated values include
        %
        %        TopLeft - The first row represents the visual top of the 
        %                  image, and the first column represents the 
        %                  visual left-hand side.
        %        TopRight
        %        BottomRight
        %        BottomLeft
        %        LeftTop
        %        RightTop
        %        RightBottom
        %        LeftBottom
        %     
        %    Example:  
        %       tiffobj.setTag('Orientation', Tiff.Orientation.TopRight);
        Orientation = struct('TopLeft',            1,...
                             'TopRight',           2, ...
                             'BottomRight',        3, ...
                             'BottomLeft',         4, ...
                             'LeftTop',            5, ...
                             'RightTop',           6, ...
                             'RightBottom',        7, ...
                             'LeftBottom',         8 );
    end % properties
    properties (GetAccess = public, Constant = true)
        % PlanarConfiguration - how the components are stored on disk.
        %    This property should only be used when setting the 
        %    'PlanarConfiguration' tag.  Supported configurations include
        %
        %        Chunky   - The component values for each pixel are 
        %                   stored contiguously.  For example, in the case 
        %                   of RGB data, the first three pixels would be 
        %                   stored on file as RGBRGBRGB etc.
        %        Separate - Each component is stored separately.  For 
        %                   example, in the case of RGB data, the red 
        %                   component would be stored separately on file 
        %                   from the green and blue components.
        %
        %    Almost all TIFF images have contiguous planar configurations.
        %
        %    Example:  
        %       tiffobj.setTag('PlanarConfiguration', Tiff.PlanarConfiguration.Chunky);
        PlanarConfiguration = struct('Chunky',   1,...
                                     'Separate', 2 );
    end % properties
    properties (GetAccess = public, Constant = true)
        % ExtraSamples - a description of extra components.  
        %    This property should only be used when setting the 
        %    'ExtraSamples' tag.  Supported enumerated values include:
        %
        %       Unspecified       - unspecified data
        %       AssociatedAlpha   - associated alpha (pre-multiplied)
        %       UnassociatedAlpha - unassociated alpha data
        %
        %    This field is required if there are extra channels in addition
        %    to the usual colormetric channels.
        %
        %    To use this property, you must be familiar with LibTIFF
        %    version 4.0.0 as well as the TIFF specification and technical
        %    notes.  This documentation may be referenced at
        %    <http://www.remotesensing.org/libtiff/>.
        %
        %    Example:  
        %        rgb = imread('example.tif');
        %        numrows = size(rgb,1);
        %        numcols = size(rgb,2);
        %        alpha = 255*ones([numrows numcols], 'uint8');
        %        data = cat(3,rgb,alpha);
        %        t = Tiff('myfile.tif','w');
        %        t.setTag('Photometric',Tiff.Photometric.RGB);
        %        t.setTag('Compression',Tiff.Compression.None);
        %        t.setTag('BitsPerSample',8);
        %        t.setTag('SamplesPerPixel',4);
        %        t.setTag('SampleFormat',Tiff.SampleFormat.UInt);
        %        t.setTag('ExtraSamples',Tiff.ExtraSamples.Unspecified);
        %        t.setTag('ImageLength',numrows);
        %        t.setTag('ImageWidth',numcols);
        %        t.setTag('TileLength',32);
        %        t.setTag('TileWidth',32);
        %        t.setTag('PlanarConfiguration',Tiff.PlanarConfiguration.Chunky);
        %        t.write(data);
        %        t.close();
        %          
        ExtraSamples = struct('Unspecified',       0, ...
                              'AssociatedAlpha',   1, ...
                              'UnassociatedAlpha', 2 );
    end % properties
    properties (GetAccess = public, Constant = true)
        % Group3Options - options for Group 3 Fax Compression
        %    This property is also referred to as Fax3 and T4Options, and
        %    it should only be used when setting the 'Group3Options' tag.
        %    This value is a bit mask controlled by the first three bits.
        %
        %    Enumerated values include:
        %       Encoding2D   - Bit 0 is 1.  This is for two-dimensional 
        %                      coding.  If more than one strip is 
        %                      specified, each strip must begin with a 1-
        %                      dimensionally coded line. That is, 
        %                      RowsPerStrip should be a multiple of 
        %                      Parameter K, as documented in the CCITT 
        %                      specification.
        %       Uncompressed - Bit 1 is 1.  This specifies that an 
        %                      uncompressed mode is used.  
        %       FillBits     - Bit 2 is 1.  Fill bits have been added as 
        %                      necessary before EOL codes such that EOL 
        %                      always ends on a byte boundary, thus 
        %                      ensuring an EOL-sequence of 1 byte preceded 
        %                       by a zero nibble, i.e. xxxx-0000 0000-0001.
        %
        %    Example:  
        %       tiffobj.setTag('Group3Options', Tiff.Group3Options.Uncompressed);
        %
        %    See also:  Tiff.Compression
        Group3Options = struct('Encoding2D',       1, ...
                               'Uncompressed',     2, ...
                               'FillBits',         4 );
    end % properties
    properties (GetAccess = public, Constant = true)
        % ResolutionUnit - the unit of measurement
        %    This property is associated with the tags XResolution and
        %    YResolution.  It should only be used when setting the 
        %    'ResolutionUnit' tag.  Supported values include
        %
        %       None       - This is the default value.
        %       Inch
        %       Centimeter
        %
        %    Example:  
        %       tiffobj.setTag('ResolutionUnit', Tiff.ResolutionUnit.Inch);
        ResolutionUnit = struct('None',        1, ...
                                'Inch',        2, ...
                                'Centimeter',  3 );
    end % properties
    properties (GetAccess = public, Constant = true)
        % InkSet - specifies the set of inks used in a separated image
        %    In this context, separated refers to photometric 
        %    interpretation, not the planar configuration.  This property 
        %    should only be used when setting the 'InkSet' tag.  Supported 
        %    enumerated values include
        %
        %       CMYK     - The order of the components is cyan, magenta, 
        %                  yellow, black. Usually, a value of 0 
        %                  represents 0% ink coverage and a value of 255 
        %                  represents 100% ink coverage for that 
        %                  component, but please consult the TIFF 
        %                  specification for DotRange. The InkNames field 
        %                  should not exist when InkSet=1.
        %       MultiInk - not CMYK.  Consult the TIFF specification for 
        %                  InkNames field for a description of the inks to
        %                  be used.    
        %
        %    Example:  
        %       tiffobj.setTag('InkSet', Tiff.InkSet.CMYK);
        %
        InkSet = struct('CMYK',        1, ...
                        'MultiInk',    2 );
    end % properties
    properties (GetAccess = public, Constant = true)
        % SampleFormat - specifies how to interpret each pixel sample
        %    This property should only be used when setting the 
        %    'SampleFormat' tag.  Supported enumerated values include
        %
        %       UInt          - default, unsigned integer data
        %       Int           - two's complement signed integer data
        %       IEEEFP        - IEEE floating point data
        %       Void          - unsupported
        %       ComplexInt    - unsupported
        %       ComplexIEEEFP - unsupported
        %
        %    Example:  
        %       tiffobj.setTag('BitsPerSample', 32);
        %       tiffobj.setTag('SampleFormat', Tiff.SampleFormat.IEEEFP);
        SampleFormat = struct('UInt',         1, ...
                              'Int',          2, ...
                              'IEEEFP',       3, ...
                              'Void',         4, ...
                              'ComplexInt',   5, ...
                              'ComplexIEEEFP',6 );
    end % properties
    properties (GetAccess = public, Constant = true)
        % YCbCrPositioning - relative positioning of chrominance samples
        %    This property specifies the positioning of chrominance 
        %    components relative to luminance samples.  It should only be
        %    used when setting the 'YCbCrPositioning' tag.  Supported 
        %    enumerated values include
        %
        %        Centered - compatible with industry standards such as 
        %                   PostScript Level 2.
        %        Cosited  - must be specified for compatibility with most 
        %                   digital video standards such as CCIR 
        %                   Recommendation 601-1.
        %
        %    Example:  
        %       tiffobj.setTag('YCbCrPositioning', Tiff.YCbCrPositioning.Centered);
        YCbCrPositioning = struct('Centered',    1, ...
                                  'Cosited',     2 );
    end % properties
    properties (GetAccess = public, Constant = true)
        % SGILogDataFmt - specify control of client data for SGILog codec
        %    These enumerated values should only be used when the
        %    photometric interpretation is LogL or LogLuv.  Possible values
        %    include:
        %       
        %         Float     - single precision samples
        %         Bits8     - uint8 samples (read only)
        %
        %    The BitsPerSample, SamplesPerPixel, and SampleFormat tags
        %    should not be set if the image type is LogL or LogLuv.  The
        %    choice of SGILogDataFmt will set these tags automatically.
        %
        %    The Float, and Bits8 settings imply a SamplesPerPixel value 
        %    of 3 for LogLuv images, but only 1 for LogL images.  
        %    
        %    This tag can be set only once per instance of a LogL/LogLuv 
        %    Tiff image object instance.     
        %
        %    Example:  
        %       tiffobj = Tiff('example.tif','r');
        %       tiffobj.setDirectory(3); % image three is a LogLuv image
        %       tiffobj.setTag('SGILogDataFmt', Tiff.SGILogDataFmt.Float);
        %       imdata = tiffobj.read();
        %      
        SGILogDataFmt = struct('Float',    0, ...
                               'Bits8',    3 );
    end % properties
    properties (GetAccess = public, Constant = true)
        % JPEGColorMode - specify control of YCbCr/RGB conversion
        %    These enumerated values should only be used when the
        %    photometric interpretation is YCbCr.  Possible values include:
        %
        %        'RGB'      - convert from RGB to YCbCr
        %        'Raw'      - keep in YCbCr
        %
        %    This property should not be used for the purpose of reading
        %    YCbCr imagery as RGB.  In this case, you should use the RGBA
        %    interface instead.
        %
        %    Example:
        %        rgb = imread('example.tif');
        %        t = Tiff('myfile.tif','w');
        %        t.setTag('Photometric',Tiff.Photometric.YCbCr);
        %        t.setTag('Compression',Tiff.Compression.JPEG);
        %        t.setTag('YCbCrSubSampling',[2 2]);
        %        t.setTag('BitsPerSample',8);
        %        t.setTag('SamplesPerPixel',3);
        %        t.setTag('SampleFormat',Tiff.SampleFormat.UInt);
        %        t.setTag('ImageLength',size(rgb,1));
        %        t.setTag('ImageWidth',size(rgb,2));
        %        t.setTag('TileLength',32);
        %        t.setTag('TileWidth',32);
        %        t.setTag('PlanarConfiguration',Tiff.PlanarConfiguration.Chunky);
        %        t.setTag('JPEGColorMode',Tiff.JPEGColorMode.RGB);
        %        t.setTag('JPEGQuality',75);
        %        t.write(rgb);
        %        t.close();
        %      
        JPEGColorMode = struct('RGB',    1, ...
                               'Raw',    0 );
    end % properties


    methods

        %------------------------------------------------------------------
        function obj = Tiff(filename,mode)

            if ( nargin == 0 )
                % Default constructor.
                obj.FileName = '';
                obj.FileID = uint64(0);
                obj.Mode = '';
                return
            end


            if ( nargin == 1 )
                mode = 'r';
            end
            
            validateattributes(mode,{'char'},{'nonempty'},'','MODE');
            mode = validatestring(mode,{'r','r+','a','w','w8'});
            
            % For read modes, get the full path.  For write/append modes,
            % we assume the file may not exist.
            if strcmp(mode,'r') || strcmp(mode,'r+')
                fid = fopen(filename,'r','ieee-le');
                % Ensure file exists.
                if fid == -1
                    error(message('MATLAB:imagesci:validate:fileOpen',filename));
                end
                % Get the full path name.
                filename = fopen(fid);
                fclose(fid);
            end
            
            obj.FileID = tifflib('open',filename,mode);
            obj.FileName = filename;
            obj.Mode = mode;

        end % Tiff constructor


        %------------------------------------------------------------------
        function sobj = saveobj(obj) 
            % We only save the filename.  We do not allow the object to
            % be loaded in a valid state.
            sobj.FileName = obj.FileName;
        end


        %------------------------------------------------------------------
        function delete(obj) 
            obj.close();
        end

        %------------------------------------------------------------------
        function disp(obj) 
            for j = 1:numel(obj)
                disp_single_obj(obj(j));
                fprintf('\n');
            end
        end
            
        %------------------------------------------------------------------
        function close(obj)
        % close  Close Tiff object.
        %   tiffobj.close() closes a Tiff object.
        %
        %   This method corresponds to the TIFFClose function in the 
        %   LibTIFF C API.  To use this method, you must be familiar with 
        %   LibTIFF version 4.0.0 as well as the TIFF specification and 
        %   technical notes.  This documentation may be referenced at 
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       t.close();
        
            if ( obj.FileID ~= 0 )
                
                tifflib('close',obj.FileID);

                % This should be enough to invalidate it.
                obj.FileID = uint64(0);
            end
        end

        %------------------------------------------------------------------
        function stripNumber = computeStrip(obj,row,plane)
        % computeStrip  Return number of strip containing specified coordinate.
        %   stripNumber = tiffobj.computeStrip(row) returns the number of 
        %   the strip containing the given row number.  The value of row
        %   must be one-based.
        %
        %   stripNumber = tiffobj.computeStrip(row, plane) returns the 
        %   number of the strip containing the given row in the specified 
        %   plane if the planar configuration is separated.  The value of
        %   row and plane must be one-based.
        %
        %   Out-of-range coordinate values are clamped to the bounds of the 
        %   image.
        %
        %   This method corresponds to the TIFFComputeStrip function in the 
        %   LibTIFF C API.  To use this method, you must be familiar with 
        %   LibTIFF version 4.0.0 as well as the TIFF specification and 
        %   technical notes.  This documentation may be referenced at 
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       t.setDirectory(2);
        %       numRows = t.getTag('ImageLength');
        %       stripNum = t.computeStrip(numRows/2);
        %       t.close();
        %
        %   See also Tiff.computeTile.
        
            if ( obj.isTiled() )
                error(message('MATLAB:imagesci:Tiff:strippedOperationOnTiledImage'));
            end
            validateattributes(row,{'double'},{'scalar','positive'},'','ROW');
            if nargin == 2
                stripNumber = tifflib('computeStrip',obj.FileID,row-1);
            else
                validateattributes(plane,{'double'},{'scalar','positive','<=',65536},'','PLANE');
                stripNumber = tifflib('computeStrip',obj.FileID,row-1,plane-1);
            end
        end

        %------------------------------------------------------------------
        function tile = computeTile(obj,pixel,plane)
        % computeTile  Return number of tile containing specified coordinates.
        %   tileNumber = tiffobj.computeTile([row col]) returns the number
        %   of the tile containing the row and column pixel coordinates.  
        %   The row and column numbers are one-based.
        %
        %   tileNumber = tiffobj.computeTile([row col], plane) returns the 
        %   number of the tile containing the row and column numbers in the 
        %   specified plane if the planar configuration is separated.
        %   The row, column, and plane numbers are one-based.
        %
        %   Out-of-range coordinate values are clamped to the bounds of the 
        %   image.
        %
        %   This method corresponds to the TIFFComputeTile function in the 
        %   LibTIFF C API.  To use this method, you must be familiar with 
        %   LibTIFF version 4.0.0 as well as the TIFF specification and 
        %   technical notes.  This documentation may be referenced at 
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       numRows = t.getTag('ImageLength');
        %       numCols = t.getTag('ImageWidth');
        %       tileNum = t.computeTile([numRows numCols]);
        %       t.close();
        %
        %   See also Tiff.computeStrip.
        
            if ( ~obj.isTiled() )
                error(message('MATLAB:imagesci:Tiff:tiledOperationOnStrippedImage'));
            end
            validateattributes(pixel,{'double'},{'numel',2,'positive'},'','PIXEL');
            if nargin == 2
                tile = tifflib('computeTile',obj.FileID,pixel-1);
            else
                validateattributes(plane,{'double'},{'scalar','positive','<=',65536},'','PLANE');
                tile = tifflib('computeTile',obj.FileID,pixel-1,plane-1);
            end
        end

        %------------------------------------------------------------------
        function dirNum = currentDirectory(obj)
        % currentDirectory  Return index of current directory.
        %   dirNum = tiffobj.currentDirectory() returns the index of the 
        %   current image file directory.  Index values are one-based. 
        %   You can use this index value with the setDirectory member 
        %   function.
        %
        %   This method corresponds to the TIFFCurrentDirectory function in
        %   the LibTIFF C API.  To use this method, you must be familiar
        %   with LibTIFF version 4.0.0 as well as the TIFF specification
        %   and technical notes.  This documentation may be referenced at
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:  
        %       t = Tiff('example.tif','r');
        %       dnum = t.currentDirectory();
        %       t.close();
        %
        %   See also Tiff.setDirectory.
        
            dirNum = tifflib('currentDirectory',obj.FileID);
        end

        %------------------------------------------------------------------
        function tagValue = getTag(obj,tagId)
        % getTag  Retrieve tag from image.
        %   tagValue = tiffobj.getTag(tagId) retrieves the value of the tag
        %   tagId from the current directory.  tagId may be specified
        %   either via the Tiff.TagID property or as a char string. 
        %
        %   This method corresponds to the TIFFGetField function in the 
        %   LibTIFF C API.  To use this method, you must be familiar with 
        %   LibTIFF version 4.0.0 as well as the TIFF specification and 
        %   technical notes.  This documentation may be referenced at 
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       % Specify tag by tag number.
        %       width = t.getTag(Tiff.TagID.ImageWidth);
        %
        %       % Specify tag by tag name.
        %       width = t.getTag('ImageWidth');
        %       t.close();
        %
        %   See also Tiff.setTag.
        
            switch(class(tagId))
                case 'char' 
                    % The user gave a char id for the tag.
                    tagValue = tifflib('getField',obj.FileID,Tiff.TagID.(tagId));

                otherwise
                    validateattributes(tagId,{'double'},{'scalar'},'','TAGID');
                    tagValue = tifflib('getField',obj.FileID,tagId);
            end
        end


        %------------------------------------------------------------------
        function yn = isTiled(obj)
        % isTiled  Return true if image is tiled.
        %   bool = tiffobj.isTiled() returns true if the image has 
        %   a tiled organization and false if the image has a stripped 
        %   organization.
        %
        %   This method corresponds to the TIFFIsTiled function in the 
        %   LibTIFF C API.  To use this method, you must be familiar with 
        %   LibTIFF version 4.0.0 as well as the TIFF specification and 
        %   technical notes.  This documentation may be referenced at 
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       tf = t.isTiled();
        %       t.close();
        
            yn = tifflib('isTiled',obj.FileID);
        end


        %------------------------------------------------------------------
        function yn = lastDirectory(obj)
        % lastDirectory  Return true if current directory is last in file.
        %   bool = tiffobj.lastDirectory() returns true if the current 
        %   image file directory is the last directory in the file.  
        %   Otherwise false is returned.
        %
        %   This method corresponds to the TIFFLastDirectory function in
        %   the LibTIFF C API.  To use this method, you must be familiar
        %   with LibTIFF version 4.0.0 as well as the TIFF specification
        %   and technical notes.  This documentation may be referenced at
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       tf = t.lastDirectory();
        %       t.close();
        % 
        %   See also Tiff.setDirectory.
        
            yn = tifflib('lastDirectory',obj.FileID);
        end

        %------------------------------------------------------------------
        function nextDirectory(obj)
        % nextDirectory  Make next directory current directory.
        %   tiffobj.nextDirectory() makes the next directory the current
        %   directory in the file.  It is only necessary to call this 
        %   method when reading a file with multiple images.  
        %
        %   This method corresponds to the TIFFReadDirectory function in
        %   the LibTIFF C API.  To use this method, you must be familiar
        %   with LibTIFF version 4.0.0 as well as the TIFF specification
        %   and technical notes.  This documentation may be referenced at
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       t.nextDirectory()
        %       t.close();
        %
        %   See also Tiff.setDirectory.
        
            tifflib('readDirectory',obj.FileID);
        end

        %------------------------------------------------------------------
        function numStrips = numberOfStrips(obj)
        % numberOfStrips  Return number of strips in image.
        %   numStrips = tiffobj.numberOfStrips() returns the number of 
        %   strips in the image.
        %
        %   This method corresponds to the TIFFNumberOfStrips function in
        %   the LibTIFF C API.  To use this method, you must be familiar
        %   with LibTIFF version 4.0.0 as well as the TIFF specification
        %   and technical notes.  This documentation may be referenced at
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       t.nextDirectory(); % image two is stripped
        %       nStrips = t.numberOfStrips();
        %       t.close();
        %
        %   See also Tiff.numberOfTiles, Tiff.isTiled.
        
            if obj.isTiled()
                error(message('MATLAB:imagesci:Tiff:strippedOperationOnTiledImage'));
            end
            numStrips = tifflib('numberOfStrips',obj.FileID);
        end

        %------------------------------------------------------------------
        function numTiles = numberOfTiles(obj)
        % numberOfTiles  Return number of tiles in image.
        %   numTiles = tiffobj.numberOfTiles() returns the number of tiles 
        %   in the image.
        %
        %   This method corresponds to the TIFFNumberOfTiles function in
        %   the LibTIFF C API.  To use this method, you must be familiar
        %   with LibTIFF version 4.0.0 as well as the TIFF specification
        %   and technical notes.  This documentation may be referenced at
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       nTiles = t.numberOfTiles();
        %       t.close();
        %
        %   See also Tiff.numberOfStrips, Tiff.isTiled.
        
            if ~obj.isTiled()
                error(message('MATLAB:imagesci:Tiff:tiledOperationOnStrippedImage'));
            end
            numTiles = tifflib('numberOfTiles',obj.FileID);
        end

        %------------------------------------------------------------------
        function varargout = readEncodedStrip(obj,stripNumber)
        % readEncodedStrip  Read data from specified strip.
        %   stripData = tiffobj.readEncodedStrip(stripNumber) reads the 
        %   data from the specified strip.  Strips numbers are one-based.
        %
        %   [Y,Cb,Cr] = tiffobj.readEncodedStrip(stripNumber) reads the
        %   YCbCr component data from the specified strip.  The size of the 
        %   chrominance components Cb and Cr may differ from the size of 
        %   the luminance component Y depending on the value of the 
        %   'YCbCrSubSampling' tag.
        %
        %   The last strip will be clipped if the strip extends past the
        %   ImageLength boundary.
        %
        %   This method corresponds to the TIFFReadEncodedStrip function in
        %   the LibTIFF C API.  To use this method, you must be familiar
        %   with LibTIFF version 4.0.0 as well as the TIFF specification
        %   and technical notes.  This documentation may be referenced at
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       t.setDirectory(2); % image two is stripped
        %       data = t.readEncodedStrip(1);
        %       t.close();
        %
        %   See also Tiff.readEncodedTile, Tiff.read.        
            meta = tifflib('retrieveMetadata', obj.FileID);
            photo = meta.PhotometricInterpretation;
            if photo == Tiff.Photometric.YCbCr
                nargoutchk(0,3);
                varargout = cell(1,3);
            else
                if (nargout == 2) || (nargout == 3)
                    error(message('MATLAB:imagesci:Tiff:notYCbCrImage'));
                end
                nargoutchk(0,1) 
                varargout = cell(1,1);
            end
            validateattributes(stripNumber,{'double'},{'scalar','positive'},'','STRIPNUMBER');
            [varargout{:}] = tifflib('readEncodedStrip',obj.FileID,stripNumber-1);
        end

        %------------------------------------------------------------------
        function varargout = readEncodedTile(obj,tileNumber)
        % readEncodedTile  Read data from specified tile.
        %   tileData = tiffobj.readEncodedTile(tileNumber) reads the data
        %   from the specified tile.  Tile numbers are one-based.
        %
        %   [Y,Cb,Cr] = tiffobj.readEncodedTile(tileNumber) reads the YCbCr 
        %   component data from the specified tile.  The size of the 
        %   chrominance components Cb and Cr may differ from the size of 
        %   the luminance component Y depending on the value of the 
        %   'YCbCrSubSampling' tag.
        %
        %   Tiles on the last row or rightmost column of an image will be 
        %   clipped if the tile extends past the ImageLength and 
        %   ImageWidth boundaries.
        %
        %   This method corresponds to the TIFFReadEncodedTile function in
        %   the LibTIFF C API.  To use this method, you must be familiar
        %   with LibTIFF version 4.0.0 as well as the TIFF specification
        %   and technical notes.  This documentation may be referenced at
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       data = t.readEncodedTile(1);
        %       t.close();
        %
        %   See also:  Tiff.readEncodedStrip, Tiff.read.       

            meta = tifflib('retrieveMetadata', obj.FileID);
            photo = meta.PhotometricInterpretation;
            if photo == Tiff.Photometric.YCbCr
                nargoutchk(0,3) ;
                varargout = cell(1,3);
            else
                if (nargout == 2) || (nargout == 3)
                    error(message('MATLAB:imagesci:Tiff:notYCbCrImage'));
                end
                nargoutchk(0,1) 
                varargout = cell(1,1);
            end
            validateattributes(tileNumber,{'double'},{'scalar','positive'},'','TILENUMBER');
            [varargout{:}] = tifflib('readEncodedTile',obj.FileID,tileNumber-1);
        end
        %------------------------------------------------------------------
        function rewriteDirectory(obj)
        % rewriteDirectory  Write modified metadata to existing directory.
        %   tiffobj.rewriteDirectory() writes modified metadata to an 
        %   existing directory.  
        %
        %   This method corresponds to the TIFFRewriteDirectory function in
        %   the LibTIFF C API.  To use this method, you must be familiar
        %   with LibTIFF version 4.0.0 as well as the TIFF specification
        %   and technical notes.  This documentation may be referenced at
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       imdata = peaks(256);
        %       imwrite(imdata,'mytif.tif');
        %       t = Tiff('mytif.tif','r+');
        %       % Add the Software tag.
        %       t.setTag('Software','MATLAB');
        %       t.rewriteDirectory();
        %       t.close();
        %
        %   See also:  Tiff.writeDirectory.
        
            if ( strcmp(obj.Mode,'r') )
                error(message('MATLAB:imagesci:Tiff:cannotWriteInReadMode'));
            end
            tifflib('rewriteDirectory',obj.FileID);
        end


        %------------------------------------------------------------------
        function [RGB,A] = readRGBAStrip(obj,row)
        % readRGBAStrip  Read strip data using RGBA interface.
        %   [RGB,ALPHA] = tiffobj.readRGBAStrip(ROW) reads the requested
        %   strip using the RGBA interface.  RGB will consist of an mxnx3 
        %   colormetric image where m and n are the height and width of the 
        %   strip.  ALPHA will be the associated alpha matting.  If the 
        %   image does not have associated alpha matting, ALPHA will be a 
        %   matrix of 255.  ROW is a one-based number of any row contained 
        %   by the strip.  
        %
        %   The strip will be clipped if the strip boundary extends past 
        %   the end of the image.
        %
        %   The pixel values may be transformed depending upon the values
        %   of the following tags:
        %  
        %       PhotometricInterpretation
        %       BitsPerSample
        %       SamplesPerPixel
        %       Orientation
        %       ExtraSamples
        %       ColorMap
        %
        %   This method corresponds to the TIFFReadRGBAStrip function in the
        %   LibTIFF C API.  To use this method, you must be familiar with 
        %   LibTIFF version 4.0.0 as well as the TIFF specification and 
        %   technical notes.  This documentation may be referenced at 
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       t.setDirectory(2); 
        %       [RGB,A] = t.readRGBAStrip(1);
        %       t.close();
        %
        %   See also Tiff.readRGBATile, Tiff.readRGBAImage.

            meta = tifflib('retrieveMetadata', obj.FileID);
            validateattributes(row,{'double'},{'>=',1,'<=',meta.ImageLength},'','ROW');

            x = tifflib('readRGBAStrip',obj.FileID,row-1);

            % The image data comes back upside down and in C-major order.
            x = permute(x,[3 2 1]);
            RGB = x(:,:,1:3);
            RGB = flip(RGB,1);
            A = x(:,:,4);
            A = flip(A,1);

            % If it is that last strip, look to see if we clip it.
            rps = meta.RowsPerStrip;
            image_height = meta.ImageLength;
            rps = min(rps,image_height);
            numstrips = ceil(image_height / rps);
            if ((row - 1) / rps + 1) == numstrips
                first_valid_row = rps*numstrips - image_height + 1;
                RGB = RGB(first_valid_row:rps,:,:);
                A = A(first_valid_row:rps,:);
            end
        end

        %------------------------------------------------------------------
        function [RGB,A] = readRGBATile(obj,row,col)
        % readRGBATile  Read tile data using RGBA interface.
        %   [RGB,A] = tiffobj.readRGBATile(ROW,COL) reads the requested
        %   tile using the RGBA interface.  RGB will consist of an mxnx3
        %   colormetric image where m and n are the height and width of the
        %   tile. ALPHA will be the associated alpha matting.  If the image
        %   does not have associated alpha matting, ALPHA will be a matrix
        %   of 255.  ROW and COL are the one-based row and column numbers
        %   of any pixel in the requested tile. 
        %
        %   The tile will be clipped if the tile boundaries extend past
        %   the edges of the image.
        %
        %   The pixel values may be transformed depending upon the values
        %   of the following tags:
        %  
        %       PhotometricInterpretation
        %       BitsPerSample
        %       SamplesPerPixel
        %       Orientation
        %       ExtraSamples
        %       ColorMap
        %
        %   This method corresponds to the TIFFReadRGBATile function in the 
        %   LibTIFF C API.  To use this method, you must be familiar with 
        %   LibTIFF version 4.0.0 as well as the TIFF specification and 
        %   technical notes.  This documentation may be referenced at 
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       t.setDirectory(1); 
        %       [RGB,A] = t.readRGBATile(1,1);
        %       t.close();
        %
        %   See also Tiff.readRGBAStrip, Tiff.readRGBAImage.        

            meta = tifflib('retrieveMetadata', obj.FileID);
            validateattributes(row,{'double'},{'>=',1,'<=',meta.ImageLength},'','ROW');
            validateattributes(col,{'double'},{'>=',1,'<=',meta.ImageWidth},'','COL');

            x = tifflib('readRGBATile',obj.FileID,col-1,row-1);

            x = permute(x,[3 2 1]);
            x = flip(x,1);
            
            % If the tile is on the right or bottom, we may need to clip it.
            tw = meta.TileWidth;
            th = meta.TileLength;
            w = meta.ImageWidth;
            h = meta.ImageLength;
            num_tiles_down = ceil(h / th);
            num_tiles_across = ceil(w / tw);
            if (((row - 1) / th + 1) == num_tiles_down)
                lastrow = h - th*(num_tiles_down-1);
                x = x(1:lastrow,:,:);
            end
            if (((col - 1) / tw + 1) == num_tiles_across)
                lastcol = w - tw*(num_tiles_across-1);
                x = x(:,1:lastcol,:);
            end

            RGB = x(:,:,1:3);
            A = x(:,:,4);
        end

        %------------------------------------------------------------------
        function [RGB,A] = readRGBAImage(obj)
        % readRGBAImage  Read entire image using RGBA interface.
        %   [RGB,ALPHA] = tiffobj.readRGBAImage() reads an entire image
        %   using the RGBA interface.  RGB will consist of an mxnx3
        %   colormetric image where m and n are the height and width of the
        %   tile.  ALPHA will be the associated alpha matting.  If the
        %   image does not have associated alpha matting, ALPHA will be a
        %   matrix of 255. 
        %
        %   The pixel values may be transformed depending upon the values
        %   of the following tags:
        %  
        %       PhotometricInterpretation
        %       BitsPerSample
        %       SamplesPerPixel
        %       Orientation
        %       ExtraSamples
        %       ColorMap
        %
        %   This method corresponds to the TIFFReadRGBAImage function in 
        %   the LibTIFF C API.  To use this method, you must be familiar 
        %   with LibTIFF version 4.0.0 as well as the TIFF specification 
        %   and technical notes.  This documentation may be referenced at 
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       t.setDirectory(2); 
        %       [RGB,A] = t.readRGBAImage();
        %       t.close();
        %
        %   See also Tiff.read, Tiff.readRGBAStrip, Tiff.readRGBATile.        

            x = tifflib('readRGBAImage',obj.FileID);

            % The image data comes back upside down and in C-major order.
            x = permute(x,[3 2 1]);
            RGB = x(:,:,1:3);
            RGB = flip(RGB,1);
            A = x(:,:,4);
            A = flip(A,1);
        end

        %------------------------------------------------------------------
        function setDirectory(obj,dirNum)
        % setDirectory  Make specified directory current directory.
        %   tiffobj.setDirectory(dirNum) sets the current image file  
        %   directory.  dirNum specifies the directory number.  dirNum is
        %   one-based.
        %
        %   This method corresponds to the TIFFSetDirectory function in the 
        %   LibTIFF C API.  To use this method, you must be familiar with 
        %   LibTIFF version 4.0.0 as well as the TIFF specification and 
        %   technical notes.  This documentation may be referenced at 
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       t.setDirectory(2);
        %       t.close();
        %
        %   See also Tiff.currentDirectory, Tiff.nextDirectory.
        
            validateattributes(dirNum,{'double'},{'scalar','positive'},'','DIRNUM');
            tifflib('setDirectory',obj.FileID,dirNum-1);
        end

        %------------------------------------------------------------------
        function setSubDirectory(obj,dirOff)
        % setSubDirectory  Set current directory by byte offset.
        %   tiffobj.setSubDirectory(offset) sets the subdirectory, 
        %   specified by offset, to the current directory.  The offset 
        %   value is given in bytes.  This method is necessary for 
        %   accessing subdirectories linked through the SubIFD tag.
        %
        %   This method corresponds to the TIFFSetSubDirectory function in
        %   the LibTIFF C API.  To use this method, you must be familiar
        %   with LibTIFF version 4.0.0 as well as the TIFF specification
        %   and technical notes.  This documentation may be referenced at
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       offset = t.getTag('SubIFD');
        %       t.setSubDirectory(offset(1));
        %       t.close();
        %
        %   See also Tiff.setDirectory.
        
            validateattributes(dirOff,{'double','uint32','uint64'},{'scalar','nonnegative'},'','OFFSET');
            tifflib('setSubDirectory',obj.FileID,dirOff);
        end

        %------------------------------------------------------------------
        function setTag(obj,varargin)
        % setTag  Set value of tag.
        %   tiffobj.setTag(tagId,tagValue) sets the value of the tag, 
        %   specified by tagId, to value specified by tagValue.  tagId can 
        %   be specified via the tagID property as a numerical value or as 
        %   a string.
        %
        %   tiffobj.setTag(tagStruct) sets all tags specified with 
        %   name/value fields in tagStruct.
        %
        %   If you are modifying a tag rather than creating it, you must  
        %   use the rewriteDirectory method after using the setTag method.
        %
        %   This method corresponds to the TIFFSetField function in the 
        %   LibTIFF C API.  To use this method, you must be familiar with 
        %   LibTIFF version 4.0.0 as well as the TIFF specification and 
        %   technical notes.  This documentation may be referenced at 
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       imdata = imread('example.tif');
        %       t = Tiff('myfile.tif','w');
        %
        %       % Use TagID property to get tag number.
        %       t.setTag(Tiff.TagID.ImageLength, size(imdata,1));
        %       t.setTag(Tiff.TagID.ImageWidth,  size(imdata,2));
        %
        %       % Use tag name.
        %       t.setTag('Photometric', Tiff.Photometric.RGB);
        %       t.setTag('PlanarConfiguration', Tiff.PlanarConfiguration.Chunky);
        %
        %       % Specify multiple tags in a struct.
        %       tagStruct.BitsPerSample = 8;
        %       tagStruct.SamplesPerPixel = 3;
        %       tagStruct.TileWidth = 128;
        %       tagStruct.TileLength = 128;
        %       tagStruct.Compression = Tiff.Compression.JPEG;
        %       tagStruct.Software = 'MATLAB';
        %       t.setTag(tagStruct);
        %       t.write(imdata);
        %       t.close();
        %
        %   For more information about setting tags,  see "Setting TIFF Tags" 
        %   in the MATLAB documentation.
        %
        %   See also Tiff.TagID, Tiff.getTag, Tiff.rewriteDirectory.
        
            switch(class(varargin{1}))
                case 'struct' 
                    tagstruct = varargin{1};
                    
                    % The user packed up a structure.  First try to apply
                    % any critical tags in the correct order.
                    for j = 1:numel(obj.CriticalTags)
                        if isfield(tagstruct, obj.CriticalTags{j})
                            tifflib('setField',obj.FileID, ...
                                Tiff.TagID.(obj.CriticalTags{j}), ...
                                tagstruct.(obj.CriticalTags{j}));
                            tagstruct = rmfield(tagstruct,obj.CriticalTags{j});
                        end
                    end
                    
                    % Now write out any remaining non-critical tags.
                    remainingTagnames = fieldnames(tagstruct); 
                    for j = 1:numel(remainingTagnames) 
                        if isfield(Tiff.TagID,remainingTagnames{j})
                            tifflib('setField',obj.FileID,...
                                Tiff.TagID.(remainingTagnames{j}),...
                                tagstruct.(remainingTagnames{j}));
                        else
                            error(message('MATLAB:imagesci:Tiff:unrecognizedTagName', remainingTagnames{ j }));
                        end
                    end

                case 'char' 
                    % The user gave a char id for the tag.
                    try
                        tifflib('setField',obj.FileID, ...
                                Tiff.TagID.(varargin{1}), ...
                                varargin{2:end});
                    catch ME
                        if strcmp(ME.identifier,'MATLAB:nonExistentField')
                            error(message('MATLAB:imagesci:Tiff:unrecognizedTagName', varargin{ 1 }));
                        else
                            rethrow(ME);
                        end
                    end

                otherwise
                    % Assume numeric.
                    tifflib('setField',obj.FileID,varargin{:});
            end
        end



        %------------------------------------------------------------------
        function writeDirectory(obj)
        % writeDirectory  Write current directory to file.
        %   tiffobj.writeDirectory() writes the current directory into a 
        %   TIFF file and sets up to create a new directory.  This method 
        %   is unnecessary in single-image files.
        %
        %   This method corresponds to the TIFFWriteDirectory function in
        %   the LibTIFF C API.  To use this method, you must be familiar
        %   with LibTIFF version 4.0.0 as well as the TIFF specification
        %   and technical notes.  This documentation may be referenced at
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   See also Tiff.close.

            if ( strcmp(obj.Mode,'r') )
                error(message('MATLAB:imagesci:Tiff:cannotWriteInReadMode'));
            end
            tifflib('writeDirectory',obj.FileID);
        end



        %------------------------------------------------------------------
        function write(obj,varargin)
        % write  Write entire image.  
        %   tiffobj.write(imageData) writes the imageData to the current
        %   image.  If the 'RowsPerStrip' tag is set, write breaks 
        %   imageData into strips.  If the 'TileLength' and 'TileWidth'
        %   tags are set, write breaks imageData into tiles.
        %
        %   tiffobj.write(Y,Cb,Cr) writes the YCbCr component data to the
        %   current image.  This syntax may only be used with images with a
        %   YCbCr photometric interpretation.
        %
        %   Example:
        %       imdata = imread('example.tif');
        %       t = Tiff('myfile.tif','w');
        %       t.setTag('ImageLength',size(imdata,1));
        %       t.setTag('ImageWidth', size(imdata,2));
        %       t.setTag('Photometric', Tiff.Photometric.RGB);
        %       t.setTag('BitsPerSample', 8);
        %       t.setTag('SamplesPerPixel', size(imdata,3));
        %       t.setTag('TileWidth', 128);
        %       t.setTag('TileLength', 128);
        %       t.setTag('Compression', Tiff.Compression.JPEG);
        %       t.setTag('PlanarConfiguration', Tiff.PlanarConfiguration.Chunky);
        %       t.setTag('Software', 'MATLAB');
        %       t.write(imdata);
        %       t.close();
        %      
        %   See also IMWRITE, Tiff.read.
        
            if obj.isTiled()
                obj.writeAllTiles(varargin{:});
            else
                obj.writeAllStrips(varargin{:});
            end

        end

        %------------------------------------------------------------------
        function varargout = read(obj)
        % read  Read entire image.
        %   imageData = tiffobj.read() reads all of the strips or tiles
        %   associated with the current image file directory and assembles
        %   them into a complete image.
        %
        %   [Y,Cb,Cr] = tiffobj.read() reads all of the strips or tiles
        %   associated with a YCbCr image and assembles them into the
        %   complete luminence component Y and the complete chrominance
        %   components Cb and Cr. The size of the chrominance components Cb
        %   and Cr may differ from the size of the luminance component Y
        %   depending on the value of the 'YCbCrSubSampling' tag.  This
        %   syntax may only be used with images with a YCbCr photometric
        %   interpretation.
        %
        %   Example:
        %       t = Tiff('example.tif','r');
        %       data = t.read();
        %       t.close();
        %
        %   See also IMREAD, Tiff.write.
        
            photo = obj.getTag('Photometric');
            if photo == Tiff.Photometric.YCbCr
                nargoutchk(0,3) ;
                varargout = cell(1,3);
            else
                if (nargout == 2) || (nargout == 3)
                    error(message('MATLAB:imagesci:Tiff:notYCbCrImage'));
                end
                nargoutchk(0,1) 
                varargout = cell(1,1);
            end

            imageDepth = obj.getTag('ImageDepth');
            if (imageDepth > 1) && ~obj.isTiled()
                warning(message('MATLAB:imagesci:Tiff:strippedImageDepthRead', imageDepth));
            end

            if obj.isTiled()
                [varargout{:}] = obj.readAllTiles();
            else
                [varargout{:}] = obj.readAllStrips();
            end

        end

        %------------------------------------------------------------------
        function writeEncodedStrip(obj,stripNumber,varargin)
        % writeEncodedStrip  Write data to specified strip.
        %   tiffobj.writeEncodedStrip(stripNumber,imageData) writes data to 
        %   the specified strip.  Strip numbers are one-based.  If 
        %   imageData has fewer bytes than expected, the strip in the file 
        %   will be silently padded.  If imageData has more bytes than 
        %   fit in the strip, writeEncodedStrip warns and truncates the 
        %   data.
        % 
        %   tiffobj.writeEncodedStrip(stripNumber,Y,Cb,Cr) writes the 
        %   YCbCr component data to the specified strip.
        % 
        %   This method corresponds to the TIFFWriteEncodedStrip function
        %   in the LibTIFF C API.  To use this method, you must be familiar
        %   with LibTIFF version 4.0.0 as well as the TIFF specification
        %   and technical notes.  This documentation may be referenced at
        %   <http://www.remotesensing.org/libtiff/>.
        %
        %   Example:
        %       t = Tiff('myfile.tif','w');
        %       t.setTag('ImageLength',32);
        %       t.setTag('ImageWidth', 32);
        %       t.setTag('Photometric', Tiff.Photometric.MinIsBlack);
        %       t.setTag('BitsPerSample', 8);
        %       t.setTag('SamplesPerPixel', 1);
        %       t.setTag('RowsPerStrip',  16);
        %       t.setTag('PlanarConfiguration', Tiff.PlanarConfiguration.Chunky);
        %       t.writeEncodedStrip(1,ones(16,32,'uint8'));
        %       t.writeEncodedStrip(2,2*ones(16,32,'uint8'));   
        %       t.close();
        %
        %   See also Tiff.writeEncodedTile, Tiff.write.
        
            comp = obj.getTag('Compression');
            if ( comp ~= Tiff.Compression.None ) && ( strcmp(obj.Mode,'r+') )
                error(message('MATLAB:imagesci:Tiff:cannotUpdateWhenCompressed'));
            end
            if ( strcmp(obj.Mode,'r') )
                error(message('MATLAB:imagesci:Tiff:cannotWriteInReadMode'));
            end
            validateattributes(stripNumber,{'double'},{'scalar','positive'},'','STRIPNUMBER');
            
            % Add the RowsPerStrip tag prior to writing the first strip if
            % the user has not explicitly set it. 
            if stripNumber == 1
                obj.addRowsPerStripTagIfMissing();
            end
            tifflib('writeEncodedStrip',obj.FileID,stripNumber-1,varargin{:});
        end

        %------------------------------------------------------------------
        function writeEncodedTile(obj,tileNumber,varargin)
        % writeEncodedTile  Write data to specified tile.
        %   tiffobj.writeEncodedTile(tileNumber,imageData) writes data to 
        %   the specified tile.  Tile numbers are one-based.  If 
        %   imageData has fewer bytes than expected, the tile in the file 
        %   will be silently padded.  If imageData has more bytes than 
        %   fit in the tile, writeEncodedTile warns and truncates the 
        %   data.
        %
        %   tiffobj.writeEncodedTile(tileNumber,Y,Cb,Cr) writes the 
        %   YCbCr component data to the specified tile.
        % 
        %   This method corresponds to the TIFFWriteEncodedTile function in
        %   the LibTIFF C API.  To use this method, you must be familiar
        %   with LibTIFF version 4.0.0 as well as the TIFF specification
        %   and technical notes.  This documentation may be referenced at
        %   <http://www.remotesensing.org/libtiff/>.
        % 
        %   Example:
        %       t = Tiff('myfile.tif','w');
        %       t.setTag('ImageLength',32);
        %       t.setTag('ImageWidth', 32);
        %       t.setTag('Photometric', Tiff.Photometric.MinIsBlack);
        %       t.setTag('BitsPerSample', 8);
        %       t.setTag('SamplesPerPixel', 1);
        %       t.setTag('TileWidth',  16);
        %       t.setTag('TileLength', 16);
        %       t.setTag('PlanarConfiguration', Tiff.PlanarConfiguration.Chunky);
        %       t.writeEncodedTile(1,ones(16,16,'uint8'));
        %       t.writeEncodedTile(2,2*ones(16,16,'uint8'));
        %       t.writeEncodedTile(3,3*ones(16,16,'uint8'));
        %       t.writeEncodedTile(4,4*ones(16,16,'uint8'));     
        %       t.close();
        %
        %   See also Tiff.writeEncodedStrip, Tiff.write.
        
            comp = obj.getTag('Compression');
            if ( comp ~= Tiff.Compression.None ) && ( strcmp(obj.Mode,'r+') )
                error(message('MATLAB:imagesci:Tiff:cannotUpdateWhenCompressed'));
            end
            if ( strcmp(obj.Mode,'r') )
                error(message('MATLAB:imagesci:Tiff:cannotWriteInReadMode'));
            end
            validateattributes(tileNumber,{'double'},{'scalar','positive'},'','TILENUMBER');
            tifflib('writeEncodedTile',obj.FileID,tileNumber-1,varargin{:});
        end

    end % methods

    methods (Access = protected)
        %------------------------------------------------------------------
        function disp_single_obj(obj) 

            if ( obj.FileID == uint64(0) )
                fprintf('\t%s\n', getString(message('MATLAB:imagesci:Tiff:invalidObject')));
                return
            end
            
            
            header =          {'TIFF File', sprintf('''%s''', obj.FileName)};
            header(end+1,:) = {'Mode';      sprintf('''%s''', obj.Mode)};
            
            try
                header = obj.getLayoutDisplay(header);
            catch ME
                if strcmp(ME.identifier, 'MATLAB:imagesci:Tiff:noPhotometricYet')
                    displayHeader(header);
                    return
                else
                    rethrow(ME);
                end
            end
            
            header(end+1,:) = obj.getPropertyDisplay('SubFileType');
            header(end+1,:) = obj.getPropertyDisplay('Photometric');         
            header(end+1,:) = obj.getTagDisplay('ImageLength');
            header(end+1,:) = obj.getTagDisplay('ImageWidth');

            if obj.isTiled()
                header(end+1,:) = obj.getTagDisplay('TileWidth');
                header(end+1,:) = obj.getTagDisplay('TileLength');
            else
                header(end+1,:) = obj.getTagDisplay('RowsPerStrip');
            end

            header(end+1,:) = obj.getTagDisplay('BitsPerSample');
            header(end+1,:) = obj.getPropertyDisplay('Compression');
            
            photo = obj.getTag('Photometric');
            switch ( photo )
                case obj.Photometric.Palette
                    header(end+1,:) = obj.getTagDisplay('ColorMap');

                case obj.Photometric.YCbCr
                    header(end+1,:) = obj.getPropertyDisplay('YCbCrPositioning');
                    header(end+1,:) = obj.getTagDisplay('YCbCrCoefficients');
                    header(end+1,:) = obj.getTagDisplay('YCbCrSubSampling');

            end

            header(end+1,:) = obj.getPropertyDisplay('SampleFormat');

            header(end+1,:) = obj.getTagDisplay('SamplesPerPixel');
            header(end+1,:) = obj.getPropertyDisplay('PlanarConfiguration');
            header(end+1,:) = obj.getPropertyDisplay('ExtraSamples');
            header(end+1,:) = obj.getTagDisplay('ImageDescription');
            header(end+1,:) = obj.getTagDisplay('SubIFD');
            header(end+1,:) = obj.getPropertyDisplay('Orientation');
            header(end+1,:) = obj.getPropertyDisplay('Group3Options');

            switch obj.getTag('Compression')
                case Tiff.Compression.JPEG
                    if strcmp(obj.Mode,'w')
                        % Don't print this tag unless we are writing data.
                        % It's too confusing otherwise.
                        header(end+1,:) = obj.getPseudoTagDisplay('JPEGQuality');
                    end

                case {Tiff.Compression.Deflate, Tiff.Compression.AdobeDeflate }
                    header(end+1,:) = obj.getPseudoTagDisplay('ZipQuality');

                case {Tiff.Compression.SGILog, Tiff.Compression.SGILog24 }
                    header(end+1,:) = obj.getPropertyDisplay('SGILogDataFmt');

            end
            
            displayHeader(header);


            %------------------------------------------------------------------
            function displayHeader(header)
            % This function prints all the displayable metadata that has been
            % gathered.
                n = size(header,1);
                for j = 1:n
                    if ~isempty(header{j,2})
                        fprintf('%27s: %s\n', header{j,1}, header{j,2});
                    end
                end
            end

        end


        
        %------------------------------------------------------------------
        function value = getPseudoTagDisplay(obj,pseudoTagName) 
            % If a pseudo tag has not been set yet, it will return an 
            % unusable value such as 2^32-1.  We don't want to print that.
            val = obj.getTag(pseudoTagName);
            if (val == (2^32-1))
                displayValue = '';
            else
                displayValue = num2str(val);
            end
            
            value = { pseudoTagName, displayValue };
        end
                
        %------------------------------------------------------------------
        function value = getPropertyDisplay(obj,propertyName) 
            % Go through the property names and print out the string value
            % that corresponds to the property value.
            
            displayValue = '';
            
            try
                propVal = obj.getTag(propertyName);
                fnames = fieldnames(Tiff.(propertyName));
                
                if ( numel(propVal) == 1 )
                    
                    for j = 1:numel(fnames)
                        if ( propVal == Tiff.(propertyName).(fnames{j}) )
                            displayValue = sprintf('Tiff.%s.%s', propertyName, fnames{j}); 
                        end
                    end
                    
                else
                    
                    displayValue = '[';
                    for k = 1:numel(propVal)
                        for j = 1:numel(fnames)
                            if ( propVal(k) == Tiff.(propertyName).(fnames{j}) )
                                displayValue = sprintf('%s %s ', ...
                                    displayValue, fnames{j});
                            end
                        end
                    end
                    displayValue = sprintf('%s]', displayValue);
                    
                end

            catch %#ok<CTCH>
                displayValue = '';
            end
            
            value = {propertyName, displayValue};


        end


        
        %------------------------------------------------------------------
        function value = getTagDisplay(obj,tagName) 
            
            try
                tagValue = obj.getTag(tagName);
                if ischar(tagValue)
                    displayValue = tagValue;
                elseif isnumeric(tagValue)
                    if ( numel(tagValue) == 1 )
                        displayValue = num2str(double(tagValue)); 
                    elseif ( numel(tagValue) < 7 )
                        displayValue = ['[' sprintf(' %d ', double(tagValue)) ']'];
                    else
                        displayValue = sprintf('[ %s ... ] (%d) values', ...
                            sprintf(' %d ', double(tagValue(1:3))), ...
                            numel(tagValue));
                    end
                end % If not char or numeric, do not print it.
    
            catch %#ok<CTCH>
                displayValue = '';
            end
            
            value = {tagName, displayValue};
        end        


        %------------------------------------------------------------------
        function header = getLayoutDisplay(obj,header)
        % This function gathers header information for the purpose of disp.
        


            % If we cannot retrieve any of these three required non-
            % defaulted tags, then we can't print anything else either.
            try
                obj.getTag('Photometric');
                obj.getTag('ImageWidth'); 
                obj.getTag('ImageLength'); 
            catch ME
                % If we cannot get the photometric interpretation, then do
                % not print anything more.  Most likely the TIFF file has
                % just been created.
                if strcmp(ME.identifier,'MATLAB:imagesci:Tiff:tagRetrievalFailed')
                    error(message('MATLAB:imagesci:Tiff:noPhotometricYet'));
                else
                    rethrow(ME);
                end
            end
            
            try
				key = getString(message('MATLAB:imagesci:Tiff:currentImageDirectory'));
                value = num2str(obj.currentDirectory());
                header(end+1,:) = {key, value};
                if obj.isTiled()
					key = getString(message('MATLAB:imagesci:Tiff:numberOfTiles'));
                    value = num2str(obj.numberOfTiles());
                else
				    key = getString(message('MATLAB:imagesci:Tiff:numberOfStrips'));
                    value = num2str(obj.numberOfStrips());
                end
                header(end+1,:) = {key,value};
                
            catch %#ok<CTCH>
            end            
            
        end

        %------------------------------------------------------------------------
        function writeAllYCbCrStrips(obj,Y,Cb,Cr)
        % writeAllYCbCrStrips writes an entire strip-oriented YCbCr image.
        % 
        %   See also writeAllYCbCrTiles
        

            sz = size(Y);

            meta = tifflib('retrieveMetadata',obj.FileID);
            h = meta.ImageLength;
            w = meta.ImageWidth;
            config = meta.PlanarConfiguration;
            if config == Tiff.PlanarConfiguration.Separate
                error(message('MATLAB:imagesci:Tiff:unsupportedYCbCrConfiguration'));
            end



            subsampling = meta.YCbCrSubsampling;
            h_subsampling = subsampling(1);
            v_subsampling = subsampling(2);

            rps = meta.RowsPerStrip;
            rps = min(rps,h);

            % The Cb and Cr array dimensions are decimated by the vertical
            % subsampling.
            cbcr_h = ceil(h / v_subsampling);
            cbcr_w = ceil(w / h_subsampling);
            cbcr_rps = ceil(rps / v_subsampling);

            if ( any(size(Y) ~= [h w]) )
                error(message('MATLAB:imagesci:Tiff:badYChannelDimensions', h, w));
            end
            if (any(size(Cb) ~= size(Cr)) || any(size(Cr) ~= [cbcr_h cbcr_w]))
                error(message('MATLAB:imagesci:Tiff:badCbCrChannelDimensions', cbcr_h, cbcr_w));
            end

            for yrow = 1:rps:sz(1)
                yrow_idx = (yrow:min(yrow+rps-1,h));

                cbcr_row = ceil(yrow / v_subsampling);
                cbcr_row_idx = cbcr_row : min(cbcr_row+cbcr_rps-1,cbcr_h);

                stripNum = tifflib('computeStrip',obj.FileID,yrow-1);
                
                % Add the RowsPerStrip tag prior to writing the first strip
                % if the user has not explicitly set it. 
                if stripNum == 1
                    obj.addRowsPerStripTagIfMissing();
                end
                
                tifflib('writeEncodedStrip', obj.FileID, stripNum-1, ...
                                      Y(yrow_idx,:),...
                                      Cb(cbcr_row_idx,:),...
                                      Cr(cbcr_row_idx,:));

            end


        end


        %------------------------------------------------------------------------

        function writeAllStrips(obj,imageData,varargin)
        % writeAllStrips writes an entire strip-oriented image.
        % 
        %   See also writeAllTiles
        

            meta = tifflib('retrieveMetadata', obj.FileID);

            h = meta.ImageLength;

            photo = meta.PhotometricInterpretation;
            if (photo == Tiff.Photometric.YCbCr) && (meta.JPEGColorMode == Tiff.JPEGColorMode.Raw)
                obj.writeAllYCbCrStrips(imageData,varargin{:});
                return
            end

            [imageLength, ~, numImagePlanes] = size(imageData);

            config = meta.PlanarConfiguration;
            spp = meta.SamplesPerPixel;

            if ( spp ~= numImagePlanes )
                error(message('MATLAB:imagesci:Tiff:wrongNumberOfDimensions', spp, numImagePlanes));
            end

            % Go through each strip of data.
            rps = meta.RowsPerStrip;
            rps = min(rps,h);

            switch config
            case Tiff.PlanarConfiguration.Chunky

                for r = 1:rps:imageLength
                    stripNum = tifflib('computeStrip', obj.FileID, r-1);
                    
                    % Add the RowsPerStrip tag prior to writing the first
                    % strip if the user has not explicitly set it.
                    if stripNum == 1
                        obj.addRowsPerStripTagIfMissing();
                    end

                    % The row indices extend from the current row.  The 
                    % final index is either the logical end of the strip,
                    % the image height (in the TIFF file, or the length
                    % of the input image, which ever is smaller.
                    row_inds = (r:min([(r+rps-1);h;imageLength]));
                    if (spp>1)
                        tifflib('writeEncodedStrip',obj.FileID,stripNum-1,imageData(row_inds,:,:));
                    else
                        tifflib('writeEncodedStrip',obj.FileID, stripNum-1,imageData(row_inds,:));
                    end
                end

            case Tiff.PlanarConfiguration.Separate

                for r = 1:rps:imageLength

                    % The row indices extent from the current row.  The 
                    % final index is either the logical end of the strip,
                    % the image height (in the TIFF file, or the length
                    % of the input image, which ever is smaller.
                    row_inds = (r:min([(r+rps-1);h;imageLength]));
                    for k = 1:spp
                        % This step is probably costlier than we need 
                        % it to be.
                        stripNum = tifflib('computeStrip',obj.FileID, r-1,k-1);
                        
                        % Add the RowsPerStrip tag prior to writing the
                        % first strip if the user has not explicitly set
                        % it. 
                        if stripNum == 1
                            obj.addRowsPerStripTagIfMissing();
                        end
                        
                        tifflib('writeEncodedStrip',obj.FileID,stripNum-1,squeeze(imageData(row_inds,:,k)));
                    end
                end

            end


        end



        %------------------------------------------------------------------
        function [Y,Cb,Cr] = readAllYCbCrStrips(obj)
        % readAllYCbCrStrips reads an entire strip-oriented YCbCr image.
        % 
        %   See also readAllYCbCrTiles
        

            meta = tifflib('retrieveMetadata', obj.FileID);
            h = meta.ImageLength;
            w = meta.ImageWidth;
            config = meta.PlanarConfiguration;
            if config == Tiff.PlanarConfiguration.Separate
                error(message('MATLAB:imagesci:Tiff:unsupportedYCbCrConfiguration'));
            end

            ySize = [h w];

            % YCbCr data must be 8-bit.
            Y = zeros(ySize,'uint8');

            subSampling = meta.YCbCrSubsampling;
            sizeCbCr = ceil(ySize ./ fliplr(subSampling));
            Cb = zeros(sizeCbCr,'uint8');
            Cr = zeros(sizeCbCr,'uint8');

            % RowsPerStrip may only be valid for Y data.  For Cb and Cr
            % data, it is decimated by the vertical subsampling.
            rps = meta.RowsPerStrip;
            rps = min(rps,h);
            c_rps = ceil(rps/subSampling(2));
            c_h = ceil(h/subSampling(2));
            

            for r = 1:rps:h
                yrow_inds = r:min(h,r+rps-1);
                   
                c_row = ceil(r/subSampling(2));
                c_row_inds = c_row : min(c_h,c_row + c_rps-1);

                stripNum = tifflib('computeStrip', obj.FileID, r-1);

                [yStrip,cbStrip,crStrip] = tifflib('readEncodedStrip', obj.FileID, stripNum-1);
                Y(yrow_inds,:,:) = yStrip;
                Cb(c_row_inds,:) = cbStrip;
                Cr(c_row_inds,:) = crStrip;

            end


        end



        %------------------------------------------------------------------
        function varargout = readAllStrips(obj)
        % readAllStrips reads an entire strip-oriented image.
        % 
        %   See also writeAllTiles
        

            varargout = cell(1,nargout);

            meta = tifflib('retrieveMetadata', obj.FileID);
            h = meta.ImageLength;
            w = meta.ImageWidth;
            photo = meta.PhotometricInterpretation;

            if (photo == Tiff.Photometric.YCbCr)
                [varargout{:}] = obj.readAllYCbCrStrips();
                return
            end


            config = meta.PlanarConfiguration;

            spp = meta.SamplesPerPixel;
            if spp == 1
                imageSize = [h w];
            else
                imageSize = [h w spp];
            end

            bps = meta.BitsPerSample;
            sampleFormat = meta.SampleFormat;

            imageData = obj.constructBlankOutputImage(imageSize,bps,sampleFormat);
            
            % Go through each strip of data.
            rps = meta.RowsPerStrip;
            rps = min(rps,h);

            if config == Tiff.PlanarConfiguration.Chunky

                % Chunky case
                for r = 1:rps:h
                    row_inds = r:min(h,r+rps-1);
                    stripNum = tifflib('computeStrip',obj.FileID,r-1);

                    if (spp>1) 
                        imageData(row_inds,:,:) = tifflib('readEncodedStrip',obj.FileID,stripNum-1);
                    else
                        imageData(row_inds,:) = tifflib('readEncodedStrip',obj.FileID,stripNum-1);
                    end
                end
            else

                % Planar case
                for r = 1:rps:h
                    row_inds = r:min(h,r+rps-1);
                    for k = 1:spp
                        % This step is probably costlier than we need 
                        % it to be.
                        stripNum = tifflib('computeStrip',obj.FileID,r-1,k-1);
                        imageData(row_inds,:,k) = tifflib('readEncodedStrip',obj.FileID,stripNum-1);
                    end
                end
            end

            varargout{1} = imageData;


        end



       %------------------------------------------------------------------
        function writeAllYCbCrTiles(obj,Y,Cb,Cr)
        % writeAllYCbCrTiles writes an entire tile-oriented YCbCr image.
        % 
        %   See also writeAllYCbCrStrips
        

            sz = size(Y);

            meta = tifflib('retrieveMetadata', obj.FileID);
            h = meta.ImageLength;
            w = meta.ImageWidth;
            config = meta.PlanarConfiguration;
            if config == Tiff.PlanarConfiguration.Separate
                error(message('MATLAB:imagesci:Tiff:unsupportedYCbCrConfiguration'));
            end

            subsampling = meta.YCbCrSubsampling;
            h_subsampling = subsampling(1);
            v_subsampling = subsampling(2);

            tWidth = meta.TileWidth;
            tHeight = meta.TileLength;
            tWidth = min(tWidth,w);
            tHeight = min(tHeight,h);

            % The Cb and Cr array dimensions are decimated by the vertical
            % subsampling.
            cbcr_h = ceil(h / v_subsampling);
            cbcr_w = ceil(w / h_subsampling);
            cbcr_tWidth = ceil(tWidth / h_subsampling);
            cbcr_tHeight = ceil(tHeight / v_subsampling);

            if ( any(size(Y) ~= [h w]) )
                error(message('MATLAB:imagesci:Tiff:badYChannelDimensions', h, w));
            end
            if (any(size(Cb) ~= size(Cr)) || any(size(Cr) ~= [cbcr_h cbcr_w]))
                error(message('MATLAB:imagesci:Tiff:badCbCrChannelDimensions', cbcr_h, cbcr_w));
            end

            % Go through the entire image, tile by tile
            for yrow = 1:tHeight:sz(1)
                yrow_idx = (yrow:min(yrow+tHeight-1,h));

                cbcr_row = ceil(yrow / v_subsampling);
                cbcr_row_idx = cbcr_row : min(cbcr_row+cbcr_tHeight-1,cbcr_h);
                for ycol = 1:tWidth:sz(2)

                    ycol_idx = ycol:min(sz(2),ycol+tWidth-1);

                    cbcr_col = ceil(ycol / h_subsampling);
                    cbcr_col_idx = cbcr_col : min(cbcr_col+cbcr_tWidth-1,cbcr_w);

                    tileNumber = tifflib('computeTile', obj.FileID, [yrow ycol]-1);
                    tifflib('writeEncodedTile', obj.FileID, tileNumber-1,...
                                         Y(yrow_idx,ycol_idx), ...
                                         Cb(cbcr_row_idx,cbcr_col_idx), ...
                                         Cr(cbcr_row_idx,cbcr_col_idx) );

                end
            end


        end

        %------------------------------------------------------------------
        function writeAllTiles(obj,imageData,varargin)
        % writeAllTiles writes an entire tile-oriented image.
        %   writeAllTiles(obj,imageData) breaks imageData down into all
        %   individual tiles and writes each to the current image.
        % 
        %   writeAllTiles(obj,Y,Cb,Cr) breaks the Y, Cb, and Cr components
        %   of a YCbCr image down into all individual tiles and writes each 
        %   to the current image.
        % 
        %   See also writeAllStrips
        

            meta = tifflib('retrieveMetadata',obj.FileID);
            h = meta.ImageLength;
            w = meta.ImageWidth;

            photo = meta.PhotometricInterpretation;
            if (photo == Tiff.Photometric.YCbCr) && (meta.JPEGColorMode == Tiff.JPEGColorMode.Raw)
                obj.writeAllYCbCrTiles(imageData,varargin{:});
                return
            end

            [imageHeight, imageWidth, numImagePlanes] = size(imageData);

            config = meta.PlanarConfiguration;
            spp = meta.SamplesPerPixel;

            tWidth = meta.TileWidth;
            tHeight = meta.TileLength;
            tWidth = min(tWidth,w);
            tHeight = min(tHeight,h);

            if ( spp ~= numImagePlanes )
                error(message('MATLAB:imagesci:Tiff:wrongNumberOfDimensions', spp, numImagePlanes));
            end

            % Go through the entire image, tile by tile
            for r = 1:tHeight:imageHeight

                % The row indices extend from the current row.  The 
                % final index is either the logical end of the tile,
                % the image height (in the TIFF file, or the length
                % of the input image, which ever is smaller.
                row_inds = r:min([r+tHeight-1;imageHeight;h]);
                for c = 1:tWidth:imageWidth

                    col_inds = c:min([c+tWidth-1,imageWidth,w]);
                    switch config
                    case Tiff.PlanarConfiguration.Chunky

                        tileNumber = obj.computeTile([r c]);

                        if ( spp > 1 )
                            tifflib('writeEncodedTile',obj.FileID,tileNumber-1,imageData(row_inds,col_inds,:));
                        else
                            tifflib('writeEncodedTile',obj.FileID,tileNumber-1,imageData(row_inds,col_inds));
                        end

                    case Tiff.PlanarConfiguration.Separate

                        for k = 1:spp
                            tileNumber = tifflib('computeTile',obj.FileID, [r c]-1,k-1);
                            tifflib('writeEncodedTile',obj.FileID,tileNumber-1,imageData(row_inds,col_inds,k));
                        end

                    end
                end
            end


        end

        %------------------------------------------------------------------
        function varargout = readAllTiles(obj)
        % readAllTiles writes an entire tile-oriented image.
        % 
        %   See also readAllStrips
        

            varargout = cell(1,nargout);

            meta = tifflib('retrieveMetadata', obj.FileID);
            h = meta.ImageLength;
            w = meta.ImageWidth;
            depth = meta.ImageDepth;

            % YCbCr data is a special case. 
            photo = meta.PhotometricInterpretation;
            if (photo == Tiff.Photometric.YCbCr)
                [varargout{:}] = obj.readAllYCbCrTiles();
                return
            end

            spp = meta.SamplesPerPixel;

            imageSize = [h w spp depth];

            bps = meta.BitsPerSample;
            sampleFormat = meta.SampleFormat;

            imageData = obj.constructBlankOutputImage(imageSize,bps,sampleFormat);

            config = meta.PlanarConfiguration;

            tWidth = meta.TileWidth;
            tHeight = meta.TileLength;
            tWidth = min(tWidth,w);
            tHeight = min(tHeight,h);

			numTilesInRow = ceil(w/tWidth);
			numTilesInCol = ceil(h/tHeight);
			numTilesInSample = numTilesInRow*numTilesInCol;

			numTiles = obj.numberOfTiles();
            
            % Compute the tile rows and columns before looping through
            % them.  If necessary, do the same for the sample and depth.
			tileNum = 1:numTiles;
			tileRow = fix(mod(tileNum-1,numTilesInSample)/numTilesInRow)+1;
			tileCol = mod(tileNum-1,numTilesInRow)+1;
			if config == Tiff.PlanarConfiguration.Chunky
				% Retrieving a chunky tile gets us all of the samples.
				sample = 1:spp;
                numTilesInSlice = numTilesInRow*numTilesInCol;
			else
				% Retrieving a separate tile gets us one sample.
				sample =  mod(fix((tileNum-1)/numTilesInSample),spp)+1;
                numTilesInSlice = numTilesInRow*numTilesInCol*spp;
			end
			z = fix((tileNum-1)/numTilesInSlice)+1;

			for j = 1:numTiles
                tileImage = tifflib('readEncodedTile',obj.FileID,j-1);
                
                % From the tile rows and columns, compute the image indices
                % that control where this particular tile will go.
				row_inds = ((tileRow(j)-1)*tHeight+1):min(tileRow(j)*tHeight,h);
				col_inds = ((tileCol(j)-1)*tWidth+1):min(tileCol(j)*tWidth,w);
                
                if config == Tiff.PlanarConfiguration.Chunky
                    % All samples get written at once in the case of
                    % chunky.
                    imageData(row_inds,col_inds,:,z(j)) = tileImage;
                else
                    imageData(row_inds,col_inds,sample(j),z(j)) = tileImage;
                end
			end


            varargout{1} = imageData;


        end
        %------------------------------------------------------------------
        function [Y,Cb,Cr] = readAllYCbCrTiles(obj)
        % readAllYCbCrTiles reads an entire tile-oriented YCbCr image.
        % 
        %   See also readAllYCbCrStrips
        

            meta = tifflib('retrieveMetadata', obj.FileID);
            h = meta.ImageLength;
            w = meta.ImageWidth;
            config = meta.PlanarConfiguration;
            if config == Tiff.PlanarConfiguration.Separate
                error(message('MATLAB:imagesci:Tiff:unsupportedYCbCrConfiguration'));
            end

            imageSize = [h w];

            Y = zeros(imageSize,'uint8');

            subSampling = meta.YCbCrSubsampling;
            % subsampling factors are given [horizontal, vertical]
            sizeCbCr = ceil(imageSize ./ fliplr(subSampling));
            Cb = zeros(sizeCbCr,'uint8');
            Cr = zeros(sizeCbCr,'uint8');

            tWidth = meta.TileWidth;
            tHeight = meta.TileLength;
            tWidth = min(tWidth,w);
            tHeight = min(tHeight,h);

            cbcr_h = ceil(h/subSampling(2));
            cbcr_w = ceil(w/subSampling(1));

            % tile width and height are decimated by the
            % YCbCr sub sampling.
            c_tWidth = ceil(tWidth/subSampling(1));
            c_tHeight = ceil(tHeight/subSampling(2));

            % Go through the entire image, tile by tile
            for r = 1:tHeight:h
                y_row_idx = r:min(h,r+tHeight-1);

                % The indices for the Cb and Cr arrays are decimated
                % by the vertical subsampling factor.
                cbcr_row = ceil(r/subSampling(2));
                cbcr_row_idx = cbcr_row : min(cbcr_h,cbcr_row + c_tHeight-1);

                for c = 1:tWidth:w
                    y_col_idx = c:min(w,c+tWidth-1);

                    % The indices for the Cb and Cr arrays are decimated
                    % by the horizontal subsampling factor.
                    cbcr_col = ceil(c/subSampling(1));
                    cbcr_col_idx = cbcr_col : min(cbcr_w,cbcr_col + c_tWidth-1);

                    tileNumber = tifflib('computeTile', obj.FileID, [r c]-1);

                    [ystrip,cbStrip,crStrip] = tifflib('readEncodedTile', obj.FileID, tileNumber-1);
                    Y(y_row_idx,y_col_idx) = ystrip;
                    Cb(cbcr_row_idx,cbcr_col_idx) = cbStrip;
                    Cr(cbcr_row_idx,cbcr_col_idx) = crStrip;

                end
            end


        end

    end % methods

    %----------------------------------------------------------------------

    methods(Static)
        function obj = loadobj(a)

            % We do not allow a Tiff object to be reloaded.  We call the 
            % default constructor, which creates an invalid object, and 
            % then just load the filename.
            obj = Tiff;
            obj.FileName = a.FileName;
            warning(message('MATLAB:imagesci:Tiff:loadingInvalidObject', obj.FileName));
        end

        function imageData = constructBlankOutputImage(imageSize,bitsPerSample,sampleFormat)

            if ( (sampleFormat == Tiff.SampleFormat.ComplexInt) || ...
                (sampleFormat == Tiff.SampleFormat.ComplexIEEEFP) ) 
                error(message('MATLAB:imagesci:Tiff:complexSampleFormat'));
            end
          
            if ( bitsPerSample == 1 ) 
                imageData = false(imageSize);

            elseif ( bitsPerSample == 8 )

                switch sampleFormat
                    case Tiff.SampleFormat.Int
                        imageData = zeros(imageSize,'int8');
                    case {Tiff.SampleFormat.UInt, Tiff.SampleFormat.Void}
                        imageData = zeros(imageSize,'uint8');
                    otherwise 
                        error(message('MATLAB:imagesci:Tiff:badSampleFormatBitsPerSampleCombination',...
                            sampleFormat,bitsPerSample));

                end


            elseif ( bitsPerSample == 16 )

                switch sampleFormat
                    case Tiff.SampleFormat.Int
                        imageData = zeros(imageSize,'int16');
                    case {Tiff.SampleFormat.UInt, Tiff.SampleFormat.Void}
                        imageData = zeros(imageSize,'uint16');
                    otherwise 
                        error(message('MATLAB:imagesci:Tiff:badSampleFormatBitsPerSampleCombination',...
                            sampleFormat,bitsPerSample));

                end


            elseif ( bitsPerSample == 32 )

                switch sampleFormat
                    case Tiff.SampleFormat.IEEEFP
                        imageData = zeros(imageSize,'single');
                    case Tiff.SampleFormat.Int
                        imageData = zeros(imageSize,'int32');
                    case {Tiff.SampleFormat.UInt,Tiff.SampleFormat.Void}
                        imageData = zeros(imageSize,'uint32');
                    otherwise 
                        error(message('MATLAB:imagesci:Tiff:unknownSampleFormat',sampleFormat));

                end


            elseif ( bitsPerSample == 64 )
                if (sampleFormat ~= Tiff.SampleFormat.IEEEFP)
                    error(message('MATLAB:imagesci:Tiff:badBpsSampleFormatCombinationFor64bps'));
                end
                imageData = zeros(imageSize,'double');

            else
                error(message('MATLAB:imagesci:Tiff:badBitsPerSample', bitsPerSample));
            end


        end
 
        function fieldNames = getTagNames() 
        % getTagNames  Retrieve list of known tags.
        %   tagNames = Tiff.getTagNames() returns a cell array of supported 
        %   tag names.
        %
        %   See also Tiff.TagID

            fieldNames = fieldnames(Tiff.TagID);
        end

        %------------------------------------------------------------------
        function tiffVersion = getVersion()
        % getVersion  Return LibTIFF library version.
        %   versionString = Tiff.getVersion() returns information about
        %   current version of the LibTIFF library.    
        %
        %   This method corresponds to the TIFFGetVersion function in the 
        %   LibTIFF C API.  To use this method, you must be familiar with 
        %   LibTIFF version 4.0.0 as well as the TIFF specification and 
        %   technical notes.  This documentation may be referenced at 
        %   <http://www.remotesensing.org/libtiff/>.
        %
        
            tiffVersion = tifflib('getVersion');
        end

    end % methods
    
    methods(Access='private')
        function addRowsPerStripTagIfMissing(obj)
            rowsPerStrip = obj.getTag('RowsPerStrip');
            if rowsPerStrip == intmax('uint32')
                tifflib('setField', obj.FileID, Tiff.TagID.RowsPerStrip, obj.getTag('ImageLength'));
            end
        end
    end



end % class
