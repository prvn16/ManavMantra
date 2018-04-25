function out = applycform(in,c)
%APPLYCFORM Apply device-independent color space transformation.
%   B = APPLYCFORM(A, C) converts the color values in A to the color space
%   specified in the color transformation structure, C.  The color
%   transformation structure specifies various parameters of the
%   transformation.  See MAKECFORM for details.
%
%   If A is two-dimensional, APPLYCFORM interprets each row in A as a color
%   unless the color transformation structure contains a grayscale ICC
%   profile (see Note for this case). A may have 1 or more columns,
%   depending on the input color space.  B has the same number of rows and
%   1 or more columns, depending on the output color space.  (The ICC spec
%   currently supports up to 15-channel device spaces.)
%
%   If A is three-dimensional, APPLYCFORM interprets each row-column
%   location as a color, and SIZE(A, 3) may be 1 or more, depending on the
%   input color space.  B has the same number of rows and columns as A, and
%   SIZE(B, 3) is 1 or more, depending on the output color space.
%
%   Note
%   ----
%   If the color transformation structure C contains a grayscale ICC
%   profile, APPLYCFORM interprets each pixel in A as a color. A can have
%   any number of columns. B has the same size as A.
%
%   Class Support 
%   ------------- 
%   A is a real, nonsparse array of class uint8, uint16, or double or a
%   string. A is only a string if C was created with the following syntax:
%
%       C = makecform('named', profile, space)
%
%   B has the same class as A unless the output color space is XYZ.  Since
%   there is no standard 8-bit representation of XYZ values, B is of class
%   uint16 if the input is of class uint8.
%   
%   Example 
%   ------- 
%   Convert RGB image to L*a*b*, assuming input image is sRGB. 
% 
%       rgb = imread('peppers.png'); 
%       cform = makecform('srgb2lab'); 
%       lab = applycform(rgb, cform); 
%
%   See also MAKECFORM, LAB2DOUBLE, LAB2UINT8, LAB2UINT16, WHITEPOINT,
%            XYZ2DOUBLE, XYZ2UINT16.

%   Copyright 2002-2010 The MathWorks, Inc.
%   Original Authors:  Scott Gregory, Toshia McCabe 10/18/02

% Check color transformation structure
check_cform(c);

% Handle color-name data as special case
if ischar(in) 
    if strcmp(c.encoding, 'name')
        cdata = struct2cell(c.cdata)';
        out = c.c_func(in, cdata{:});
        return;
    else
        error(message('images:applycform:invalidNamedColorCform'));
    end
end

% Check to make sure IN is of correct class and attributes
validateattributes(in,{'double','uint8','uint16'}, ...
    {'real','nonsparse','finite'},'applycform','IN',1);

% Get dimensions of input data, then rearrange data so that columns
% correspond to color channels.  Each row is a color vector.
[num_rows input_color_dim] = check_input_image_dimensions(in, c);
num_input_color_channels = size(in, input_color_dim);
columndata = reshape(in, [], num_input_color_channels);

% Check the encoding of the data against what's expected
% in the atomic functions and convert the data appropriately
% to the right encoding.
input_encoding = class(in);
columndata = encode_color(columndata, c.ColorSpace_in,...
                          input_encoding, c.encoding);

% Get arguments to atomic function from c.cdata
cdata = struct2cell(c.cdata)';

% Call the function with the argument list
state = warning('off', 'images:encode_color:outputEncodingIgnored');
try
    out = c.c_func(columndata, cdata{:});
catch ME
    % We want to restore warning state even if the function errors
    warning(state)
    rethrow(ME); 
end
warning(state);

% Make sure output encoding is the same as input encoding.
% The only exception occurs when uint8 data are processed through
% a cform that results in PCS XYZ. In this case, the result
% will be uint16 XYZ values, since there is no uint8 encoding 
% defined for XYZ.

if ~strcmp(class(out), input_encoding)
    if strcmpi(c.ColorSpace_out, 'xyz') && ...
       ~strcmpi(input_encoding, 'double')
        out = encode_color(out, 'xyz', lower(class(out)), 'uint16');
    else
        out = encode_color(out, lower(c.ColorSpace_out), ...
                           lower(class(out)), input_encoding);
    end
end

% Reshape the output data if needed to restore input geometry
if input_color_dim == 3 && ~strcmpi(c.ColorSpace_in, 'gray')
    out = reshape(out, num_rows, [], size(out,2));
end

%--------------------------------------------------------------------------
function [nrows color_dim] = check_input_image_dimensions(in, c)

nrows = size(in, 1);

if ndims(in) == 2
    color_dim = 2;
    if strcmpi(c.ColorSpace_in, 'gray')
        %special case: only 1 color channel;size(2dImage,3) is 1
        color_dim = 3; 
    end
elseif ndims(in) == 3
    color_dim = 3;
else
    error(message('images:applycform:wrongDataDimensions'));
end

%--------------------------------------------------------------------------
function check_cform(c)

if isstruct(c)
    proper_fields = isfield(c, ...
        {'c_func', 'ColorSpace_in', 'ColorSpace_out', 'encoding', 'cdata'});
    if all(proper_fields)
        bad_c_func = isempty(c.c_func) || ~isa(c.c_func,'function_handle');
        isStringInvalid = @(stringValue) isempty(stringValue) || ~ischar(stringValue);
        bad_ColorSpace_in = isStringInvalid(c.ColorSpace_in);
        bad_ColorSpace_out = isStringInvalid(c.ColorSpace_out);
        bad_encoding = isStringInvalid(c.encoding);
        bad_cdata = isempty(c.cdata) || ~isstruct(c.cdata);
        bad_data = any([bad_c_func, bad_ColorSpace_in, bad_ColorSpace_out, bad_encoding, bad_cdata]);
    else
        bad_data = true;
    end
else
    bad_data = true;
end

if bad_data
    error(message('images:applycform:invalidCform'));
end
