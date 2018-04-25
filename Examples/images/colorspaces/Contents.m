% Image Processing Toolbox --- colorspaces
%
% Colormap manipulation.
%   brighten       - Brighten or darken colormap (MATLAB Toolbox).
%   cmpermute      - Rearrange colors in colormap (MATLAB Toolbox).
%   cmunique       - Eliminate unneeded colors in colormap of indexed image (MATLAB Toolbox).
%   colormap       - Set or get color lookup table (MATLAB Toolbox).
%   imapprox       - Approximate indexed image by one with fewer colors (MATLAB Toolbox).
%   rgbplot        - Plot RGB colormap components (MATLAB Toolbox).
%
% Color space conversions.
%   applycform     - Apply device-independent color space transformation.
%   hsv2rgb        - Convert HSV color values to RGB color space (MATLAB Toolbox).
%   iccfind        - Search for ICC profiles by description.
%   iccread        - Read ICC color profile.
%   iccroot        - Find system ICC profile repository.
%   iccwrite       - Write ICC color profile.
%   isicc          - True for complete profile structure
%   lab2double     - Convert L*a*b* color values to double.
%   lab2uint16     - Convert L*a*b* color values to uint16.
%   lab2uint8      - Convert L*a*b* color values to uint8.
%   makecform      - Create device-independent color space transformation structure (CFORM).
%   ntsc2rgb       - Convert NTSC color values to RGB color space.
%   rgb2hsv        - Convert RGB color values to HSV color space (MATLAB Toolbox).
%   rgb2ntsc       - Convert RGB color values to NTSC color space.
%   rgb2ycbcr      - Convert RGB color values to YCbCr color space.
%   whitepoint     - XYZ color values of standard illuminants.
%   xyz2double     - Convert XYZ color values to double.
%   xyz2uint16     - Convert XYZ color values to uint16.
%   ycbcr2rgb      - Convert YCbCr color values to RGB color space.
%
% ICC color profiles.
%   lab8.icm       - 8-bit Lab profile.
%   monitor.icm    - Typical monitor profile.
%                    Sequel Imaging, Inc., used with permission.
%   sRGB.icm       - sRGB profile.
%                    Hewlett-Packard, used with permission.
%   swopcmyk.icm   - CMYK input profile.
%                    Eastman Kodak, used with permission.

% See also IMAGES, IMAGESLIB, IMDEMOS, IMUITOOLS, IPTFORMATS, IPTUTILS.

%   Copyright 2008 The MathWorks, Inc.  
%   
