function out = encode_color(in, cspace, encode_in, encode_out)
%ENCODE_COLOR Convert encoding of color data.
%   OUT = ENCODE_COLOR(IN, CSPACE, ENCODE_IN, ENCODE_OUT) changes
%   the encoding of the data in IN from ENCODE_IN to ENCODE_OUT,
%   returning the results in OUT.  ENCODE_IN and ENCODE_OUT
%   can be 'double', 'uint8', or 'uint16'.  The encoding also
%   is dependent on CSPACE, which specifies the color space.
%   Supported device-independent color spaces include
%   'lab', 'xyz', 'xyl', 'uvl', 'upvpl', and 'lch'.  Supported
%   device-dependent spaces include 'gray', 'rgb', 'cmyk', and 
%   'color_n', where n can range from 2 to 15.
%
%   See also APPLYCFORM.

%   Copyright 2002-2010 The MathWorks, Inc.
%   Original Authors:  Scott Gregory, Toshia McCabe 12/04/02

cspace = lower(cspace);
if strncmp(cspace, 'color_', 6)
    cspace = 'color_n';
end
[cspace, encode_in] = check_input(cspace,encode_in);
encode_out = lower(encode_out);

if strcmp(encode_in,encode_out)
    out = in;
else
    enc = getEncodingTable();
    
    % Choose the encoding conversion function
    func = enc.(cspace).(encode_in).(encode_out);
    
    % Do the encoding conversion
    out = func(in);
end

%-----------------------------------------
function out = labdouble_to_labuint8(in)

% Do the scale and offset and cast to uint8
out = round([(255 * (in(:,1)/100)) in(:,2)+128 in(:,3)+128]);
out = max(0, min(255, out));
out = uint8(out);

%-----------------------------------------
function out = labuint8_to_labdouble(in)

out = double(in);
out(:,1) = 100 * (out(:,1) / 255);
out(:,2) = out(:,2) - 128;
out(:,3) = out(:,3) - 128;

%-----------------------------------------
function out = labdouble_to_labuint16(in)

% Do the scale and offset and cast to uint16
out = in;
out(:,1) = round(65535 * out(:,1) / (100 + (25500/65280)));
out(:,2) = round(65535 * ((128 + out(:,2)) / (255 + (255/256))));
out(:,3) = round(65535 * ((128 + out(:,3)) / (255 + (255/256))));
out = max(0, min(65535, out));
out = uint16(out);

%-----------------------------------------
function out = labuint16_to_labdouble(in)

out = double(in);
out(:,1) = (out(:,1) * (100 + (25500/65280))) / 65535;
out(:,2) = ((out(:,2) * (255 + (255/256))) / 65535) - 128;
out(:,3) = ((out(:,3) * (255 + (255/256))) / 65535) - 128;

%-----------------------------------------
function out = xyzdouble_to_xyzuint16(in)

out = round(65535 * (in / (1 + (32767/32768))));
out = max(0, min(65535, out));
out = uint16(out);

%-----------------------------------------
function out = xyzuint16_to_xyzdouble(in)

out = (double(in)/65535) * (1 + (32767/32768));

%-----------------------------------------
function out = double_to_uint8(in)

out = round((in) * 255);
out = max(0, min(255, out));
out = uint8(out);

%-----------------------------------------
function out = uint8_to_double(in)

out = double(in) / 255;

%------------------------------------------
function out = double_to_uint16(in)

out = round((in) * 65535);
out = max(0, min(65535, out));
out = uint16(out);

%-----------------------------------------
function out = uint16_to_double(in)

out = double(in) / 65535;

%-----------------------------------------
function out = labuint8_to_labuint16(in)

out = uint16(round(double(in)*256));

%-----------------------------------------
function out = labuint16_to_labuint8(in)

out = round(double(in)/256);
out = max(0, min(255, out));
out = uint8(out);

%-----------------------------------------
function out = uint8_to_uint16(in)

out = uint16(round((double(in) / 255) * 65535));

%-----------------------------------------
function out = uint16_to_uint8(in)

out = uint8(round((double(in) / 65535) * 255));

%-----------------------------------------
function out = output_encoding_ignored(in)

% This is just a fix for the situation such as one
% goes in as uint8, and comes out as XYZ. Since there
% is no defined encoding for 8 bit XYZ, the output must
% be uint16!

out = in;
warning(message('images:encode_color:outputEncodingIgnored'))

%--------------------------------------------------------------------------
function [cspace,encoding] = check_input(cspace,encode_in)

valid_cspaces = {'lab', 'xyz', 'lch', 'upvpl', 'uvl', 'xyl', ...
                 'gray', 'rgb', 'cmyk', 'color_n'};
cspace = validatestring(cspace, valid_cspaces, 'encode_color', ...
                   'COLORSPACE', 2);
switch cspace
  case 'lab'
    valid_encodings = {'double', 'uint8', 'uint16'};
  case 'xyz'
    valid_encodings = {'double', 'uint16'};
  case 'lch'
    valid_encodings = {'double'};
  case 'upvpl'
    valid_encodings = {'double'};
  case 'uvl'
    valid_encodings = {'double'};
  case 'xyl'
    valid_encodings = {'double'};
  case 'gray'
    valid_encodings = {'double', 'uint8', 'uint16'};
  case 'rgb'
    valid_encodings = {'double', 'uint8', 'uint16'};
  case 'cmyk'
    valid_encodings = {'double', 'uint8', 'uint16'};
  case 'color_n'
    valid_encodings = {'double', 'uint8', 'uint16'};
end

encoding = validatestring(encode_in, valid_encodings, ...
                        'encode_color', 'ENCODING_IN', 3);
                    
%--------------------------------------------------------------------------
function table = getEncodingTable()
% Populate a struct that maps the encoding function by indexing
% colorspace, input encoding, and output encoding

persistent enctab;
if isempty(enctab)    
    enctab.lab.double.uint8      = @labdouble_to_labuint8;
    enctab.lab.uint8.double      = @labuint8_to_labdouble;
    enctab.lab.double.uint16     = @labdouble_to_labuint16;
    enctab.lab.uint16.double     = @labuint16_to_labdouble;
    enctab.lab.uint8.uint16      = @labuint8_to_labuint16;
    enctab.lab.uint16.uint8      = @labuint16_to_labuint8;
    enctab.xyz.double.uint16     = @xyzdouble_to_xyzuint16;
    enctab.xyz.double.uint8      = @output_encoding_ignored;
    enctab.xyz.uint16.double     = @xyzuint16_to_xyzdouble;
    enctab.xyz.uint16.uint8      = @output_encoding_ignored;
    enctab.gray.double.uint8     = @double_to_uint8;
    enctab.gray.uint8.double     = @uint8_to_double;
    enctab.gray.uint16.double    = @uint16_to_double;
    enctab.gray.double.uint16    = @double_to_uint16;
    enctab.gray.uint8.uint16     = @uint8_to_uint16;
    enctab.gray.uint16.uint8     = @uint16_to_uint8;
    enctab.rgb.double.uint8      = @double_to_uint8;
    enctab.rgb.uint8.double      = @uint8_to_double;
    enctab.rgb.uint16.double     = @uint16_to_double;
    enctab.rgb.double.uint16     = @double_to_uint16;
    enctab.rgb.uint8.uint16      = @uint8_to_uint16;
    enctab.rgb.uint16.uint8      = @uint16_to_uint8;
    enctab.cmyk.double.uint8     = @double_to_uint8;
    enctab.cmyk.uint8.double     = @uint8_to_double;
    enctab.cmyk.uint16.double    = @uint16_to_double;
    enctab.cmyk.double.uint16    = @double_to_uint16;
    enctab.cmyk.uint8.uint16     = @uint8_to_uint16;
    enctab.cmyk.uint16.uint8     = @uint16_to_uint8;
    enctab.color_n.double.uint8  = @double_to_uint8;
    enctab.color_n.uint8.double  = @uint8_to_double;
    enctab.color_n.uint16.double = @uint16_to_double;
    enctab.color_n.double.uint16 = @double_to_uint16;
    enctab.color_n.uint8.uint16  = @uint8_to_uint16;
    enctab.color_n.uint16.uint8  = @uint16_to_uint8;
    enctab.lch.double.uint8      = @output_encoding_ignored;
    enctab.lch.double.uint16     = @output_encoding_ignored;
    enctab.upvpl.double.uint8    = @output_encoding_ignored;
    enctab.upvpl.double.uint16   = @output_encoding_ignored;
    enctab.uvl.double.uint8      = @output_encoding_ignored;
    enctab.uvl.double.uint16     = @output_encoding_ignored;
    enctab.xyl.double.uint8      = @output_encoding_ignored;
    enctab.xyl.double.uint16     = @output_encoding_ignored;
end
table = enctab;
