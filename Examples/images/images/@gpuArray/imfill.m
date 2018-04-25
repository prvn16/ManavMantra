function [I2,locations] = imfill(varargin)
%IMFILL Fill image regions and holes.
%   BW2 = IMFILL(BW1,LOCATIONS) performs a flood-fill operation on
%   background pixels of the 2-D input binary gpuArray image BW1, starting
%   from the points specified in LOCATIONS.  LOCATIONS can be a P-by-1
%   vector, in which case it contains the linear indices of the starting
%   locations. LOCATIONS can also be a P-by-2 matrix, in which case each
%   row contains the array indices of one of the starting locations.
%
%   BW2 = IMFILL(BW1,'holes') fills holes in the 2-D binary gpuArray image,
%   BW1.  A hole is a set of background pixels that cannot be reached by
%   filling in the background from the edge of the image.
%
%   I2 = IMFILL(I1) fills holes in an 2-D intensity gpuArray image, I1.  In
%   this case a hole is an area of dark pixels surrounded by lighter
%   pixels.
%
%   Specifying Connectivity
%   -----------------------
%   By default, IMFILL uses 4-connected background neighbors for the 2-D
%   inputs. You can override the default connectivity with these syntaxes:
%
%       BW2 = IMFILL(BW1,LOCATIONS,CONN)
%       BW2 = IMFILL(BW1,CONN,'holes')
%       I2  = IMFILL(I1,CONN)
%
%   CONN may have the following scalar values:
%
%       4     two-dimensional four-connected neighborhood
%       8     two-dimensional eight-connected neighborhood
%
%   Performance Note
%   -----------------------
%   With IMFILL computations on the GPU, better performance can be
%   achieved with syntaxes where the LOCATIONS input is used:
%
%       BW2 = IMFILL(BW1,LOCATIONS)
%       BW2 = IMFILL(BW1,LOCATIONS,CONN)
%
%   Interactive Use
%   -----------------------
%   Interactive syntaxes are not supported on the GPU:
%
%       BW2 = IMFILL(BW1)
%       [BW2,LOCATIONS] = IMFILL(BW1)
%       BW2 = IMFILL(BW1,0,CONN)
%
%   Class Support
%   -------------
%   The input gpuArray image can have its underlying class being logical or
%   numeric (excluding uint64 or int64), and it must be real and 2-D.  The
%   output image has the same class as the input image.
%
%   Examples
%   --------
%   Fill in the background of a binary gpuArray image from a specified
%   starting location:
%
%       BW1 = logical([1 0 0 0 0 0 0 0
%                      1 1 1 1 1 0 0 0
%                      1 0 0 0 1 0 1 0
%                      1 0 0 0 1 1 1 0
%                      1 1 1 1 0 1 1 1
%                      1 0 0 1 1 0 1 0
%                      1 0 0 0 1 0 1 0
%                      1 0 0 0 1 1 1 0]);
%       BW1 = gpuArray(BW1);    
%       BW2 = imfill(BW1,[3 3],8)
%
%   Fill in the holes of a binary gpuArray image:
%
%       BW4 = gpuArray(imbinarize(imread('coins.png')));
%       BW5 = imfill(BW4,'holes');
%       figure, imshow(BW4), figure, imshow(BW5)
%
%   Fill in the holes of an intensity gpuArray image:
%
%       I = gpuArray(imread('tire.tif'));
%       I2 = imfill(I);
%       figure, imshow(I), figure, imshow(I2)
%
%   See also BWSELECT, GPUARRAY/IMRECONSTRUCT, REGIONFILL.

%   Copyright 2013-2017 The MathWorks, Inc.
    
% Grandfathered syntaxes:
% IMFILL(I1,'holes') - no longer necessary to use 'holes'
% IMFILL(I1,CONN,'holes') - no longer necessary to use 'holes'

% Testing notes
% =============
% I            - real, full, nonsparse, numeric array, 2-d
%              - Infs OK
%              - NaNs not allowed
%
% CONN         - valid 2-d min and max connectivity specifier
%
% LOCATIONS    - can be either a P-by-1 double vector containing
%                valid linear indices into the input image, or a 
%                P-by-ndims(I) array.  In the second case, each row
%                of LOCATIONS must contain a set of valid array indices
%                into the input image.
%
% 'holes'      - match is case-insensitive; partial match allowed.
%


% CPU dispatch if necessary 
if ~isa(varargin{1}, 'gpuArray')
    args = gatherIfNecessary(varargin{:});
    [I2,locations] = imfill(args{:});
    return;
end

args = matlab.images.internal.stringToChar(varargin);
[I,locations,conn,do_fillholes] = parse_inputs(args{:});

% Return now if no hole to fill
if isempty(I) || (~do_fillholes && isempty(locations))
    I2 = I;
    return
end

if do_fillholes
    if islogical(I)
        mask = uint8(I);
    else
        mask = I;
    end
    mask = padarray(mask, ones(1,ndims(mask)), -Inf, 'both');
    mask = imcomplement(mask);
    marker = mask;
    
    idx = cell(1,ndims(I));
    for k = 1:ndims(I)
        idx{k} = 2:(size(marker,k) - 1);
    end
    
    sIdx.type = '()';
    sIdx.subs = idx;
    marker = subsasgn(marker,sIdx,cast(-Inf, 'like', marker));

    I2 = imreconstruct(marker, mask, conn);
    I2 = imcomplement(I2);
    I2 = subsref(I2,sIdx);

    if islogical(I)
        I2 = logical(I2);
    end

else    
    mask = imcomplement(I);
    marker = gpuArray.false(size(mask));
    sIdx.type = '()';
    sIdx.subs = {locations};
    marker = subsasgn(marker, sIdx, subsref(mask, sIdx));
    marker = imreconstruct(marker, mask, conn);
    I2 = I | marker;
end

%%%
%%% Subfunction ParseInputs
%%%
function [IM,locations,conn,do_fillholes] = parse_inputs(varargin)
    
narginchk(1,3);

IM = varargin{1};
    
do_interactive = false;
do_fillholes = false;

conn = 4; % default to minimal 2-D connectivity
do_conn_check = false;

locations = [];
do_location_check = false;


hValidateAttributes(IM,...
    {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'},...
    {'real', '2d', 'nonnan','nonsparse'},mfilename,'I1 or BW1',1);

switch nargin
  case 1
    if islogical(IM)
        % IMFILL(BW1)
        do_interactive = true;        
    else
        % IMFILL(I1)
        do_fillholes = true;
    end
    
  case 2
    if islogical(IM)
        if ischar(varargin{2})
            % IMFILL(BW1, 'holes')
            validatestring(varargin{2}, {'holes'}, mfilename, 'OPTION', 2);
            do_fillholes = true;
            
        else
            % IMFILL(BW1, LOCATIONS)
            locations = varargin{2};
            do_location_check = true;
        end
        
    else
        if ischar(varargin{2})
            % IMFILL(I1, 'holes')
            validatestring(varargin{2}, {'holes'}, mfilename, 'OPTION', 2);
            do_fillholes = true;
            
        else
            % IMFILL(I1, CONN)
            conn = varargin{2};
            do_conn_check = true;
            do_fillholes = true;
        end
        
    end
    
  case 3
    if islogical(IM)
        if ischar(varargin{3})
            % IMFILL(BW1,CONN,'holes')
            validatestring(varargin{3}, {'holes'}, mfilename, 'OPTION', 3);
            do_fillholes = true;
            conn = varargin{2};
            do_conn_check = true;
            
        else
            if isequal(varargin{2}, 0)
                % IMFILL(BW1,0,CONN)
                do_interactive = true;               
            else
                % IMFILL(BW1,LOCATIONS,CONN)
                locations = varargin{2};
                do_location_check = true;
                conn = varargin{3};
                do_conn_check = true;
            end
            
        end
        
    else
        % IMFILL(I1,CONN,'holes')
        validatestring(varargin{3}, {'holes'}, mfilename, 'OPTION', 3);
        do_fillholes = true;
        conn = varargin{2};
        do_conn_check = true;
    end
end

if do_conn_check
    % Preprocess conn
    conn  = gather(conn);
    
    if isscalar(conn)
        if (conn~=4 && conn~=8)
            error(message('images:imfill:unsupportedConnForGPU'));
        end
    else 
        if isequal(conn,conndef(2,'min'))
            conn = 4;
        elseif isequal(conn,conndef(2,'max'))
            conn = 8;
        else
            error(message('images:imfill:unsupportedConnForGPU'));
        end
    end
    
else
    % Default to maximal 2D connectivity
    conn  = 4;
end

if do_location_check
    % locations are checked on the CPU
    locations = gather(locations);
    locations = check_locations(locations, size(IM));    
elseif do_interactive
    error(message('images:imfill:noInteractiveOnGPU'));
end

% Convert to linear indices if necessary.
if ~do_fillholes && (size(locations,2) ~= 1)
    idx = cell(1,ndims(IM));
    for k = 1:ndims(IM)
        idx{k} = locations(:,k);
    end
    locations = sub2ind(size(IM), idx{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locations = check_locations(locations, image_size)
%   Checks validity of LOCATIONS.  Converts LOCATIONS to linear index
%   form.  Warns if any locations are out of range.

validateattributes(locations, {'double'}, {'real' 'positive' 'integer' '2d'}, ...
              mfilename, 'LOCATIONS', 2);

num_dims = length(image_size);
if (size(locations,2) ~= 1) && (size(locations,2) ~= num_dims)
    error(message('images:imfill:badLocationSize'));
end

if size(locations,2) == 1
    bad_pix = (locations < 1) | (locations > prod(image_size));
else
    bad_pix = zeros(size(locations,1),1);
    for k = 1:num_dims
        bad_pix = bad_pix | ((locations(:,k) < 1) | ...
                             (locations(:,k) > image_size(k)));
    end
end
    
if any(bad_pix)
    warning(message('images:imfill:outOfRange'));
    locations(bad_pix,:) = [];
end

