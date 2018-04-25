function out = applyblackpoint(in, cspace, upconvert_blackpoint)
%APPLYBLACKPOINT Adjust black point for profile version mismatch
%   OUT = APPLYBLACKPOINT(IN, CSPACE, UPCONVERT_BLACKPOINT) processes an
%   array of PCS colors IN through a black-point adjustment, returning an
%   array OUT of the same size.  CSPACE defines the connection space and
%   must be either 'lab' or 'xyz'.  UPCONVERT_BLACKPOINT selects the
%   nature of the adjustment:  a value of +1 results in a conversion from
%   the reference-medium black point of v. 2 of the ICC profile spec to
%   that of v. 4; a value of -1 results in a conversion from v. 4 to v. 2.
%
%   See also MAKECFORM, APPLYCFORM.

%   Copyright 1993-2010 The MathWorks, Inc.
%      Poe
%   Original authors: Scott Gregory, Toshia McCabe, Robert Poe 12/15/03

% Check input arguments
if size(in, 2) ~= 3
    error(message('images:applyblackpoint:invalidColorData'))
end

% Convert input data to doubles for these calculations
data_class = class(in);
is_not_double = ~strcmp(data_class, 'double');
if is_not_double
    in = encode_color(in, cspace, data_class, 'double');
end

% The black-point adjustment is simply defined in XYZ, but if the data
% are in Lab, we need to do lab2xyz then xyz2lab.
if strcmp(cspace, 'xyz')
    
    % Define v. 4 black point XYZ
    blackpoint4 = 0.0034731 * whitepoint;

    if upconvert_blackpoint == 1
        out = bsxfun(@plus, blackpoint4, 0.9965269 * in);
    elseif upconvert_blackpoint == -1
        out = bsxfun(@minus, in, blackpoint4) / 0.9965269;
    elseif upconvert_blackpoint == 0
        out = in;
    else
        error(message('images:applyblackpoint:invalidConversion'))
    end
    
elseif strcmp(cspace, 'lab')
    in = lab2xyz(in);    
    out = applyblackpoint(in, 'xyz', upconvert_blackpoint);
    out = xyz2lab(out);
else
    error(message('images:applyblackpoint:invalidColorSpaceData'))
end

% Encode the data back to what it was
if is_not_double
    out = encode_color(out, cspace, 'double', data_class);
end
