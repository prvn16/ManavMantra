function out = applyclut(varargin)
%APPLYCLUT Convert color data using ICC CLUT-based transform.
%   OUT = APPLYCLUT(IN, LUTTAG, ISXYZIN, ISXYZOUT) converts data
%   from one space to another -- including the ICC profile connection
%   spaces (XYZ and L*a*b*), various device spaces, or a gamut alarm
%   -- using a CLUT-based transform.  LUTTAG is a field of a profile
%   structure, such as that returned by ICCREAD, corresponding to a 
%   profile lut tag (lut8Type, lut16Type, lutAtoBType, lutBtoAType).
%   OUT will have the same number of rows as IN, the number of data
%   points to be processed.  The number of columns may differ,
%   since it is the number of channels in the respective color
%   spaces (input and output):  A connection space must have 3 channels, 
%   device spaces are limited to 15 channels by the ICC spec, and a 
%   gamut alarm has a single (Boolean) output channel.  IN and OUT
%   are represented in one of the standard ICC encodings for
%   device spaces or device-independent spaces, as uint8 or uint16.
%   ISXYZIN is optional and defaults to 0; it should be set to 1
%   if IN is represented in the XYZ connection space.  ISXYZOUT
%   is also optional and defaults to 0; it should be set to 1 if
%   OUT is represented in the XYZ connection space.
%
%   See also MAKECFORM, APPLYCFORM.

%   Copyright 2002-2010 The MathWorks, Inc.
%   Original author:  Scott Gregory, 10/20/02

% Check input arguments
narginchk(2, 4);

in = varargin{1};
validateattributes(in,{'uint8','uint16'},{'real','2d','nonsparse','finite'},...
           'applyclut','IN',1);

% Check the luttag
luttag = varargin{2};
validateattributes(luttag,{'struct'},{'nonempty'},'applyclut','LUTTAG',1);

checkLutTag(luttag);

% Determine intrinsic data type of luttag
if luttag.MFT == 1
    luttagbytes = 1; % all tables are uint8
    scale = 255;
elseif luttag.MFT <= 4
    luttagbytes = 2; % all tables are uint16, except possibly for
                     % the CLUT in lutAtoBType and lutBtoAType
    scale = 65535;
else
    error(message('images:applyclut:unrecognizedLutType'))
end

% Check the input and output colorspaces
if nargin > 2
    isxyzin = varargin{3};
else
    isxyzin = false;
end
if nargin > 3
    isxyzout = varargin{4};
else
    isxyzout = false;
end

% Check that incoming data type matches that of luttag
if (isa(in, 'uint8') && luttagbytes == 2) || ...
   (isa(in, 'uint16') && luttagbytes == 1)
    error(message('images:applyclut:datatypeMismatch'))
end

% Convert inputs to double, scaled to [0, 1]
out = double(in) / scale;

% Adjust v.2 16-bit Lab encoding to v. 4
if luttag.MFT == 4 && ~isxyzin % lutBtoAType
    out = out * 257 / 256;
end

% Apply 1D pre-shapers, if present
if ~isempty(luttag.PreShaper)
    out = cellinterp(out, luttag.PreShaper);
end

% Apply pre-matrix, if present and if,
% for v. 2, input space is XYZ
if ~isempty(luttag.PreMatrix) && (isxyzin || luttag.MFT > 2)
    out = out * luttag.PreMatrix(1:3, 1:3)' ...
          + ones(size(out, 1), 1) * luttag.PreMatrix(1:3, 4)';
end

% Apply 1D input tables, if present
if ~isempty(luttag.InputTables)
    out = cellinterp(out, luttag.InputTables);
end

% Apply multidimensional grid tables, if present
% Note:  In v. 4, 8-bit CLUT might have to process 16-bit data.
if ~isempty(luttag.CLUT)
    [chan_in, chan_out] = luttagchans(luttag);
    if isa(in, 'uint16') && isa(luttag.CLUT, 'uint8') % v. 4 option
        clut_scale = scale / 257;
    else
        clut_scale = scale;
    end
    
    out = clut_scale * out;  % rescale for clutinterp
    
    switch chan_in
      case 3
        out = clutinterp_tet3(out, luttag.CLUT, chan_in, chan_out);
      case 4
        out = clutinterp_tet4(out, luttag.CLUT, chan_in, chan_out);
      otherwise
        out = clutinterp(out, luttag.CLUT, chan_in, chan_out);
    end

    out = out / clut_scale;  % scale back to [0, 1]
end

% Apply 1D output tables, if present
if ~isempty(luttag.OutputTables)
    out = cellinterp(out, luttag.OutputTables);
end

% Apply post-matrix, if present
if ~isempty(luttag.PostMatrix)
   out = out * luttag.PostMatrix(1:3, 1:3)' ...
          + ones(size(out, 1), 1) * luttag.PostMatrix(1:3, 4)';       
end

% Apply 1D post-shapers, if present
if ~isempty(luttag.PostShaper)
    out = cellinterp(out, luttag.PostShaper);
end

% Adjust v. 4 16-bit lab encoding values to v. 2
if luttag.MFT == 3 && ~isxyzout % lutAtoBType
    out = out * 256 / 257;
end

% Re-encode according to luttag data type
if luttagbytes == 1
    out = uint8(scale * out);    
else
    out = uint16(scale * out);    
end

%==========================================================================
function checkLutTag(luttag)

if  ~isfield(luttag, 'MFT') || ...
    ~isfield(luttag, 'PreShaper') || ...
    ~isfield(luttag, 'PreMatrix') || ...
    ~isfield(luttag, 'InputTables') || ...
    ~isfield(luttag, 'CLUT') || ...
    ~isfield(luttag, 'OutputTables') || ...
    ~isfield(luttag, 'PostMatrix') || ...
    ~isfield(luttag, 'PostShaper')
    
    error(message('images:applyclut:invalidLuttag'));
end
%--------------------------------------------------------------------------

%==========================================================================
function out = cellinterp(in, shapers)
% Process data through cell array of 1D shapers

% Check number of channels
chan_in = size(shapers, 2);

if size(in, 2) ~= chan_in
    error(message('images:applyclut:numberOfChannels'))
end

% Evaluate shapers, channel by channel
out = zeros(size(in));
for chan = 1 : chan_in
    out(:, chan) = applycurve(in(:, chan), shapers{chan});
end
%--------------------------------------------------------------------------

%==========================================================================
function out = clutinterp(in, clut, chan_in, chan_out)
% Interpolate in multi-dimensional grid tables

% Note:  order of arguments must be reversed, since
%        ICC format requires row-major order, while
%        Matlab uses column-major.  Thus, a function
%        f(R, G, B) is treated as f(B, G, R).

if size(in, 2) ~= chan_in
    error(message('images:applyclut:dataMismatch'));
end

% Clip grid_index values before calling interpn to make sure it doesn't
% return NaNs.
if isa(clut, 'uint8')
    scale = 255;
else
    scale = 65535;
end
in = min(in, scale);
in = max(in, 0);

% Construct sampling grids for interpn
csiz = size(clut); % clut dimensions, including output channels
siz = csiz(1 : chan_in); % grid dimensions
samples = cell(size(siz));
for k = 1 : chan_in
    samples{k} = linspace(0, scale, size(clut, k));
end

% Put arguments for interpn into cell array
interpargs = cell(1, 2 * chan_in + 1);
[interpargs{1 : chan_in}] = ndgrid(samples{:}); % Xi arguments
for i = 1 : chan_in % Yi arguments, in reverse order (see help text)
    interpargs{chan_in + 1 + i} = in(:, chan_in + 1 - i);
end

% Allocate and initialize output array
out = zeros(size(in, 1), chan_out);

% Interpolate for each output channel
clut2 = reshape(clut, prod(siz), chan_out);
for i = 1 : chan_out
    clut3 = reshape(clut2(:, i), siz); % Select by output channel
    interpargs{chan_in + 1} = double(clut3); % V argument for interpn
    out(:, i) = interpn(interpargs{:});
end
%--------------------------------------------------------------------------

%==========================================================================
function res = clutinterp_tet3(in, clut, chan_in, chan_out)
% Interpolate in multi-dimensional grid tables using tetrahedral method
% of Sakamoto

% Note:  order of arguments must be reversed, since
%        ICC format requires row-major order, while
%        Matlab uses column-major.  Thus, a function
%        f(R, G, B) is treated as f(B, G, R).

% Preconditions
if size(in, 2) ~= chan_in
    error(message('images:applyclut:dataMismatch'))
end

% Compute possible cube corner offsets from base vertex
csiz = size(clut); % clut dimensions, including output channels
siz = csiz(1 : chan_in); % grid dimensions
% Recall that last channel varies most rapidly in table
offs = [siz(2)*siz(1), siz(1), 1];
%tmp = { 1, 2, 3, [1 2], [1 3], [2 3], [1 2 3]};
tmp = { 1, 3, 2, [1 2], [1 3], [2 3], [1 2 3]};
offs_list = zeros(1,8);
for i = 1 : 7
    offs_list(i+1) = sum(offs(tmp{i}));
end

% Scaling of clut is either [0,255] or [0,65535]
if isa(clut, 'uint8')
    scale = 255;
else
    scale = 65535;
end

% Setup 8x4 tables indexing into wgts and offsets for each simplex
% in order to allow vectorized computation
wgt_ids = ones(8, 4);  off_ids = zeros(8, 4);

off_ids(8, :) = offs_list([1 2 5 8]);
off_ids(4, :) = offs_list([1 2 6 8]);
off_ids(2, :) = offs_list([1 3 6 8]);
off_ids(1, :) = offs_list([1 3 7 8]);
off_ids(5, :) = offs_list([1 4 7 8]);
off_ids(7, :) = offs_list([1 4 5 8]);

wgt_ids(8, :) = [1 4 6 9];
wgt_ids(4, :) = [1 5 6 8];
wgt_ids(2, :) = [3 5 4 8];
wgt_ids(1, :) = [3 6 4 7];
wgt_ids(5, :) = [2 6 5 7];
wgt_ids(7, :) = [2 4 5 9];
wgt_ids = wgt_ids - 1;

% Separate input values into integer and fractional components
integ = zeros(size(in, 1), 3);
frac  = zeros(size(in, 1), 3);
for i = 1 : 3
    tmp = double(in(:, i)) * (siz(i) - 1) / scale;
    integ(:, i) = min(siz(i) - 2, floor(tmp));  % 0-based
    frac(:, i) = tmp - integ(:, i);
end
tmp = []; %#ok<NASGU>

% Compute indices of base of cubes
base_inds = integ * offs' + 1;
integ = []; %#ok<NASGU>

% Compute an id in [1,8] indicating which part of the cube the point is in
ids = ( frac(:, [1 1 2]) > frac(:, [2 3 3])) * [1 2 4]' + 1;

% Compute possible weighting factors
wgts = [ 1 - frac, abs(frac(:, [1 1 2]) - frac(:, [2 3 3])), frac];

% Accumulate result
n = size(ids,1);
clut2 = reshape(double(clut), prod(siz), chan_out);
wgt_inds = (1 : n)' + wgt_ids(ids, 1) * n;
res = bsxfun(@times, wgts(wgt_inds), clut2(base_inds,:));
for i = 2 : 4
    inds = base_inds + off_ids(ids, i);
    wgt_inds = (1 : n)' + wgt_ids(ids, i) * n;
    res = res + bsxfun(@times, wgts(wgt_inds), clut2(inds,:));
end
%--------------------------------------------------------------------------

%==========================================================================
function res = clutinterp_tet4(in, clut, chan_in, chan_out)
% Interpolate in multi-dimensional grid tables using 4d tetrahedral equivalent
% method of Sakamoto

% Note:  order of arguments must be reversed, since
%        ICC format requires row-major order, while
%        Matlab uses column-major.  Thus, a function
%        f(R, G, B) is treated as f(B, G, R).

% Preconditions
if size(in, 2) ~= chan_in
    error(message('images:applyclut:dataMismatch'))
end

% Compute possible hypercube corner offsets from base vertex
csiz = size(clut); % clut dimensions, including output channels
siz = csiz(1 : chan_in); % grid dimensions
% Recall that last channel varies most rapidly in table
offs = [siz(3)*siz(2)*siz(1), siz(2)*siz(1), siz(1), 1];
tmp = { 1, 2, 3, 4, [ 1 2], [1 3], [1 4], [2 3], [2 4], [3 4],  ...
        [1 2 3], [1 2 4], [1 3 4], [2 3 4], [1 2 3 4]};
offs_list = zeros(1,16);
for i = 1 : 15
    offs_list(i+1) = sum(offs(tmp{i}));
end

% Scaling of clut is either [0,255] or [0,65535]
if isa(clut, 'uint8')
    scale = 255;
else
    scale = 65535;
end

% Setup 64x5 tables indexing into wgts and offsets for each simplex
% in order to allow vectorized computation
wgt_ids = ones(64, 5);  off_ids = zeros(64, 5);

off_ids(64, :) = offs_list([1 2 6 12 16]);
off_ids(32, :) = offs_list([1 2 6 13 16]);
off_ids(56, :) = offs_list([1 2 7 12 16]);
off_ids(40, :) = offs_list([1 2 7 14 16]);
off_ids(16, :) = offs_list([1 2 8 13 16]);
off_ids( 8, :) = offs_list([1 2 8 14 16]);

off_ids(63, :) = offs_list([1 3 6 12 16]);
off_ids(31, :) = offs_list([1 3 6 13 16]);
off_ids(61, :) = offs_list([1 3 9 12 16]);
off_ids(57, :) = offs_list([1 3 9 15 16]);
off_ids(27, :) = offs_list([1 3 10 13 16]);
off_ids(25, :) = offs_list([1 3 10 15 16]);

off_ids(54, :) = offs_list([1 4 7 12 16]);
off_ids(38, :) = offs_list([1 4 7 14 16]);
off_ids(53, :) = offs_list([1 4 9 12 16]);
off_ids(49, :) = offs_list([1 4 9 15 16]);
off_ids(33, :) = offs_list([1 4 11 15 16]);
off_ids(34, :) = offs_list([1 4 11 14 16]);

off_ids(12, :) = offs_list([1 5 8 13 16]);
off_ids( 4, :) = offs_list([1 5 8 14 16]);
off_ids(11, :) = offs_list([1 5 10 13 16]);
off_ids( 9, :) = offs_list([1 5 10 15 16]);
off_ids( 2, :) = offs_list([1 5 11 14 16]);
off_ids( 1, :) = offs_list([1 5 11 15 16]);

wgt_ids(64, :) = [1 5 8 10 14];
wgt_ids(32, :) = [1 5 9 10 13];
wgt_ids(56, :) = [1 6 8  9 14];
wgt_ids(40, :) = [1 6 10 9 12];
wgt_ids(16, :) = [1 7 9  8 13];
wgt_ids( 8, :) = [1 7 10 8 12];

wgt_ids(63, :) = [2 5 6  10 14];
wgt_ids(31, :) = [2 5 7  10 13];
wgt_ids(61, :) = [2 8 6  7 14];
wgt_ids(57, :) = [2 8 10 7 11];
wgt_ids(27, :) = [2 9 7  6 13];
wgt_ids(25, :) = [2 9 10 6 11];

wgt_ids(54, :) = [3 6 5  9 14];
wgt_ids(38, :) = [3 6 7  9 12];
wgt_ids(53, :) = [3 8 5  7 14];
wgt_ids(49, :) = [3 8 9  7 11];
wgt_ids(33, :) = [3 10 9 5 11];
wgt_ids(34, :) = [3 10 7 5 12];

wgt_ids(12, :) = [4 7 5  8 13];
wgt_ids( 4, :) = [4 7 6  8 12];
wgt_ids(11, :) = [4 9 5  6 13];
wgt_ids( 9, :) = [4 9 8  6 11];
wgt_ids( 2, :) = [4 10 6 5 12];
wgt_ids( 1, :) = [4 10 8 5 11];
wgt_ids = wgt_ids - 1;

% Separate input values into integer and fractional components
integ = zeros(size(in, 1), 4);
frac  = zeros(size(in, 1), 4);
for i = 1 : 4
    tmp = double(in(:, i)) * (siz(i) - 1) / scale;
    integ(:, i) = min(siz(i) - 2, floor(tmp));  % 0-based
    frac(:, i) = tmp - integ(:, i);
end
tmp = []; %#ok<NASGU>

% Compute indices of base of hypercubes
base_inds = integ * offs' + 1;
integ = []; %#ok<NASGU>

% Compute an id in [1,64] indicating which part of the hypercube the point is in
ids = ( frac(:, [1 1 1 2 2 3]) > frac(:, [2 3 4 3 4 4]))  *  ...
        [1 2 4 8 16 32]' + 1;

% Compute possible weighting factors
wgts = [ 1 - frac, abs(frac(:, [1 1 1 2 2 3]) - frac(:, [2 3 4 3 4 4])), frac];

% Accumulate result
n = size(ids,1);
clut2 = reshape(double(clut), prod(siz), chan_out);
wgt_inds = (1 : n)' + wgt_ids(ids, 1) * n;
res = bsxfun(@times, wgts(wgt_inds), clut2(base_inds,:));
for i = 2 : 5
    inds = base_inds + off_ids(ids, i);
    wgt_inds = (1 : n)' + wgt_ids(ids, i) * n;
    res = res + bsxfun(@times, wgts(wgt_inds), clut2(inds,:));
end
%--------------------------------------------------------------------------
