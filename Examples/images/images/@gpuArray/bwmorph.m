function bwout = bwmorph(bwin,opStr,n)
%BWMORPH Morphological operations on binary image.
%   BW2 = BWMORPH(BW1,OPERATION) applies a specific
%   morphological operation to the binary gpuArray image BW1.
%
%   BW2 = BWMORPH(BW1,OPERATION,N) applies the operation N
%   times.  N can be Inf, in which case the operation is repeated
%   until the image no longer changes.
%
%   OPERATION is a string or char vector that can have one of these values:
%      'bothat'       Subtract the input image from its closing
%      'branchpoints' Find branch points of skeleton
%      'bridge'       Bridge previously unconnected pixels
%      'clean'        Remove isolated pixels (1's surrounded by 0's)
%      'close'        Perform binary closure (dilation followed by
%                       erosion)
%      'diag'         Diagonal fill to eliminate 8-connectivity of
%                       background
%      'endpoints'    Find end points of skeleton
%      'fill'         Fill isolated interior pixels (0's surrounded by
%                       1's)
%      'hbreak'       Remove H-connected pixels
%      'majority'     Set a pixel to 1 if five or more pixels in its
%                       3-by-3 neighborhood are 1's
%      'open'         Perform binary opening (erosion followed by
%                       dilation)
%      'remove'       Set a pixel to 0 if its 4-connected neighbors
%                       are all 1's, thus leaving only boundary
%                       pixels
%      'shrink'       With N = Inf, shrink objects to points; shrink
%                       objects with holes to connected rings
%      'skel'         With N = Inf, remove pixels on the boundaries
%                       of objects without allowing objects to break
%                       apart
%      'spur'         Remove end points of lines without removing
%                       small objects completely
%      'thicken'      With N = Inf, thicken objects by adding pixels
%                       to the exterior of objects without connected
%                       previously unconnected objects
%      'thin'         With N = Inf, remove pixels so that an object
%                       without holes shrinks to a minimally
%                       connected stroke, and an object with holes
%                       shrinks to a ring halfway between the hole
%                       and outer boundary
%      'tophat'       Subtract the opening from the input image
%
%   Class Support
%   -------------
%   The input gpuArray image BW1 can be numeric or logical.
%   It must be 2-D, real and non-sparse.  The output gpuArray image
%   BW2 is logical.
%
%   Remarks
%   -------
%   To perform erosion or dilation using the structuring element ones(3),
%   use IMERODE or IMDILATE.
%
%   Examples
%   --------
%       BW1 = gpuArray(imread('circles.png'));
%       figure, imshow(BW1)
%       BW2 = bwmorph(BW1,'remove');
%       BW3 = bwmorph(BW1,'skel',Inf);
%       figure, imshow(BW2)
%       figure, imshow(BW3)
%
%   See also GPUARRAY/IMERODE, GPUARRAY/IMDILATE, GPUARRAY, BWEULER,
%            BWPERIM.

%   Copyright 2012-2016 The MathWorks, Inc.



%% Input argument parsing
if (nargin < 3)
    n = 1;
end

hValidateAttributes(bwin,...
    {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'},...
    {'real','2d','nonsparse'},mfilename,'BW',1);

if ~islogical(bwin)
    bwin = (bwin ~= 0);
end

validOperations = {'bothat',...
    'branchpoints',...
    'bridge',...
    'clean',...
    'close',...
    'diag',...
    'dilate',...
    'endpoints',...
    'erode',...
    'fatten',...
    'fill',...
    'hbreak',...
    'majority',...
    'perim4',...
    'perim8',...
    'open',...
    'remove',...
    'shrink',...
    'skeleton',...
    'spur',...
    'thicken',...
    'thin',...
    'tophat'};

opStr = validatestring(opStr,validOperations, 'bwmorph');

%% Call the core function


if(isempty(bwin))
    bwout = bwin;
    return;
end


if(n<1)
    % nothing to do
    bwout = bwin;
    
elseif(n==1)
    bwout = bwmorphApplyOnce(bwin,opStr);
    
else
    % Repeat N times or till output stops changing
    iter  = 0;
    bwout = bwin;
    while(iter<n)
        
        last_aout   = bwout;
        bwout       = bwmorphApplyOnce(bwout,opStr);
        iter        = iter+1;
        
        if(isequal(last_aout, bwout))
            % the output is not changing anymore
            break
        end
    end
end

if (nargout == 0)
    imshow(bwout);
end

end

function bw = bwmorphApplyOnce(bw, opStr)

switch opStr
    %
    % Function BOTHAT
    %
    case 'bothat'
        
        bwc = images.internal.gpu.bwlookup(bw, gpuArray(images.internal.lutdilate()));
        bwc = images.internal.gpu.bwlookup(bwc, gpuArray(images.internal.luterode()));
        bw  = bwc & ~bw;
        
        %
        % Function BRANCHPOINTS
        %
    case 'branchpoints'
        % Initial branch point candidates
        C = images.internal.gpu.bwlookup(bw, gpuArray(images.internal.lutbranchpoints()));
        
        % Background 4-Connected Object Count (Vp)
        B = images.internal.gpu.bwlookup(bw, gpuArray(uint8(images.internal.lutbackcount4())));
        
        % End Points (Vp = 1)
        E = (B == 1);
        
        % Final branch point candidates
        FC = ~E .* C;
        
        % Generate mask that defines pixels for which Vp = 2 and no
        % foreground neighbor q for which Vq > 2
        
        % Vp = 2 Mask
        Vp = ((B == 2) & ~E);
        
        % Vq > 2 Mask
        Vq = ((B > 2) & ~E);
        
        % Dilate Vq
        D = images.internal.gpu.bwlookup(Vq, gpuArray(images.internal.lutdilate()));
        
        % Intersection between dilated Vq and final candidates w/ Vp = 2
        M = (FC & Vp) & D;
        
        % Final Branch Points
        bw =  FC & ~M;
        
        %
        % Function BRIDGE
        %
    case 'bridge'
        
        lut = images.internal.lutbridge();
        bw  = images.internal.gpu.bwlookup(bw, gpuArray(lut));
        
        %
        % Function CLEAN
        %
    case 'clean'
        
        lut = images.internal.lutclean();
        bw = images.internal.gpu.bwlookup(bw, gpuArray(lut));
        
        %
        % Function CLOSE
        %
    case 'close'
        
        bwd = images.internal.gpu.bwlookup(bw, gpuArray(images.internal.lutdilate()));
        bw  = images.internal.gpu.bwlookup(bwd, gpuArray(images.internal.luterode()));
        
        %
        % Function DIAG
        %
    case 'diag'
        
        lut = images.internal.lutdiag();
        bw  = images.internal.gpu.bwlookup(bw, gpuArray(lut));
        
        
        %
        % Function DILATE
        %
    case 'dilate'
        
        lut = images.internal.lutdilate();
        bw  = images.internal.gpu.bwlookup(bw, gpuArray(lut));
        
        %
        % Function ENDPOINTS
        %
    case 'endpoints'
        
        lut = images.internal.lutendpoints();
        bw  = images.internal.gpu.bwlookup(bw, gpuArray(lut));
        
        %
        % Function ERODE
        %
    case 'erode'
        
        lut = images.internal.luterode();
        bw  = images.internal.gpu.bwlookup(bw, gpuArray(lut));
        
        
        %
        % Function FATTEN
        %
    case 'fatten'
        
        lut = images.internal.lutfatten();
        bw  = images.internal.gpu.bwlookup(bw, gpuArray(lut));
        
        
        %
        % Function FILL
        %
    case 'fill'
        
        lut = images.internal.lutfill();
        bw  = images.internal.gpu.bwlookup(bw, gpuArray(lut));
        
        %
        % Function HBREAK
        %
    case 'hbreak'
        
        lut = images.internal.luthbreak();
        bw  = images.internal.gpu.bwlookup(bw, gpuArray(lut));
        
        %
        % Function MAJORITY
        %
    case 'majority'
        
        lut = images.internal.lutmajority();
        bw  = images.internal.gpu.bwlookup(bw, gpuArray(lut));
        
        %
        % Function OPEN
        %
    case 'open'
        
        bw  = images.internal.gpu.bwlookup(bw,gpuArray(images.internal.luterode()));
        bw  = images.internal.gpu.bwlookup(bw,gpuArray(images.internal.lutdilate()));
        
        
        %
        % Function PERIM4
        %
    case 'perim4'
        
        lut = images.internal.lutper4();
        bw  = images.internal.gpu.bwlookup(bw, gpuArray(lut));
        
        %
        % Function PERIM8
        %
    case 'perim8'
        
        lut = images.internal.lutper8();
        bw  = images.internal.gpu.bwlookup(bw, gpuArray(lut));
        
        %
        % Function REMOVE
        %
    case 'remove'
        
        lut = images.internal.lutremove();
        bw  = images.internal.gpu.bwlookup(bw, gpuArray(lut));
        
        %
        % Function SHRINK
        %
    case 'shrink'
        
        table = images.internal.lutshrink();
        
        % First subiteration
        m   = images.internal.gpu.bwlookup(bw, gpuArray(table));
        sub = bw & ~m;
        %bw(1:2:end,1:2:end) = sub(1:2:end,1:2:end);
        subStruct.type = '()';
        subStruct.subs = {1:2:size(bw,1), 1:2:size(bw,2)};
        bw  = subsasgn(bw, subStruct, subsref(sub, subStruct));
        
        % Second subiteration
        m   = images.internal.gpu.bwlookup(bw, gpuArray(table));
        sub = bw & ~m;
        %bw(2:2:end,2:2:end) = sub(2:2:end,2:2:end);
        subStruct.type = '()';
        subStruct.subs = {2:2:size(bw,1), 2:2:size(bw,2)};
        bw  = subsasgn(bw, subStruct, subsref(sub, subStruct));
        
        % Third subiteration
        m   = images.internal.gpu.bwlookup(bw, gpuArray(table));
        sub = bw & ~m;
        %bw(1:2:end,2:2:end) = sub(1:2:end,2:2:end);
        subStruct.type = '()';
        subStruct.subs = {1:2:size(bw,1), 2:2:size(bw,2)};
        bw  = subsasgn(bw, subStruct, subsref(sub, subStruct));
        
        
        % Fourth subiteration
        m   = images.internal.gpu.bwlookup(bw, gpuArray(table));
        sub = bw & ~m;
        %bw(2:2:end,1:2:end) = sub(2:2:end,1:2:end);
        subStruct.type = '()';
        subStruct.subs = {2:2:size(bw,1), 1:2:size(bw,2)};
        bw  = subsasgn(bw, subStruct, subsref(sub, subStruct));
        
        
        %
        % Function SKEL
        %
    case 'skeleton'
        
        for i = 1:8
            bw = images.internal.gpu.bwlookup(bw, gpuArray(images.internal.lutskel(i)));
        end
        
        %
        % Function SPUR
        %
    case 'spur'
        %SPUR Remove parasitic spurs.
        %   [C,LUT] = spur(A, numIterations) removes parasitic spurs from
        %   the binary image A that are shorter than numIterations.
        
        lut = images.internal.lutspur();
        
        % Start by complementing the image.  The lookup table is designed
        % to remove endpoints in a complemented image, where 0-valued
        % pixels are considered to be foreground pixels.  That way,
        % because bwlookup assumes that pixels outside the image are 0,
        % spur removal takes place as if the image were completely
        % surrounded by foreground pixels.  That way, lines that
        % intersect the edge of the image aren't pruned at the edge.
        bw = ~bw;
        
        % Identify all end points.  These form the entire set of
        % pixels that can be removed in this iteration.  However,
        % some of these points may not be removed.
        endPoints = images.internal.gpu.bwlookup(bw, gpuArray(images.internal.lutspur()));
        
        % Remove end points in the first field.
        %bw(1:2:end, 1:2:end) = xor(bw(1:2:end, 1:2:end), ...
        %    endPoints(1:2:end, 1:2:end));
        subStruct.type = '()';
        subStruct.subs = {1:2:size(bw,1), 1:2:size(bw,2)};
        ff  = xor(subsref(bw, subStruct), subsref(endPoints, subStruct));
        bw  = subsasgn(bw, subStruct, ff);
        
        
        % In the second field, remove any of the original end points
        % that are still end points.
        newEndPoints = endPoints & images.internal.gpu.bwlookup(bw, gpuArray(lut));
        %bw(1:2:end, 2:2:end) = xor(bw(1:2:end, 2:2:end), ...
        %    newEndPoints(1:2:end, 2:2:end));
        subStruct.type = '()';
        subStruct.subs = {1:2:size(bw,1), 2:2:size(bw,2)};
        ff  = xor(subsref(bw, subStruct), subsref(newEndPoints, subStruct));
        bw  = subsasgn(bw, subStruct, ff);
        
        % In the third field, remove any of the original end points
        % that are still end points.
        newEndPoints = endPoints & images.internal.gpu.bwlookup(bw, gpuArray(lut));
        %bw(2:2:end, 1:2:end) = xor(bw(2:2:end, 1:2:end), ...
        %    newEndPoints(2:2:end, 1:2:end));
        subStruct.type = '()';
        subStruct.subs = {2:2:size(bw,1), 1:2:size(bw,2)};
        ff  = xor(subsref(bw, subStruct), subsref(newEndPoints, subStruct));
        bw  = subsasgn(bw, subStruct, ff);
        
        % In the fourth field, remove any of the original end points
        % that are still end points.
        newEndPoints = endPoints & images.internal.gpu.bwlookup(bw, gpuArray(lut));
        %bw(2:2:end, 2:2:end) = xor(bw(2:2:end, 2:2:end), ...
        %    newEndPoints(2:2:end, 2:2:end));
        subStruct.type = '()';
        subStruct.subs = {2:2:size(bw,1), 2:2:size(bw,2)};
        ff  = xor(subsref(bw, subStruct), subsref(newEndPoints, subStruct));
        bw  = subsasgn(bw, subStruct, ff);
        
        
        % Now that we're finished, we need to complement the image once
        % more.
        bw = ~bw;
        
        %
        % Function THIN
        %
    case 'thin'
        
        % Louisa Lam, Seong-Whan Lee, and Ching Y. Wuen, "Thinning Methodologies-A
        % Comprehensive Survey," IEEE TrPAMI, vol. 14, no. 9, pp. 869-885, 1992.  The
        % algorithm is described at the bottom of the first column and the top of the
        % second column on page 879.
        
        lut1        = images.internal.lutthin1();
        image_iter1 = images.internal.gpu.bwlookup(bw, gpuArray(lut1));
        
        lut2 = images.internal.lutthin2();
        bw   = images.internal.gpu.bwlookup(image_iter1, gpuArray(lut2));
        
        %
        % Function TOPHAT
        %
    case 'tophat'
        
        bwe = images.internal.gpu.bwlookup(bw,gpuArray(images.internal.luterode()));
        bwd = images.internal.gpu.bwlookup(bwe,gpuArray(images.internal.lutdilate()));
        bw  = bw&~bwd;
        
        
        %
        % Function THICKEN
        %
    case 'thicken'
        
        % Isolated pixels are going to need a "jump-start" to get
        % them going; otherwise, they won't "thicken".
        % First, identify the isolated pixels.
        iso = images.internal.gpu.bwlookup(bw, gpuArray(images.internal.lutiso()));
        if (any(any(iso(:))))
            % Identify possible pixels to maybe change to one.
            growMaybe = images.internal.gpu.bwlookup(iso, gpuArray(images.internal.lutdilate()));
            % Identify pixel locations in the original image
            % with only one on pixel in the 3-by-3 neighborhood.
            oneNeighbor = images.internal.gpu.bwlookup(bw, gpuArray(images.internal.lutsingle()));
            % If a pixel is adjacent to an isolated pixel, *and* it
            % doesn't also have another neighbor, set it to one.
            bw = bw | (oneNeighbor & growMaybe);
        end
        
        % Create a padded logical array
        [m,n] = size(bw);
        m     = m+4;
        n     = n+4;
        
        c = true([m,n], 'like', bw);
        
        %c(3:(m-2),3:(n-2)) = ~bw;
        subStruct.type = '()';
        subStruct.subs = {3:(m-2), 3:(n-2)};
        c = subsasgn(c, subStruct, ~bw);
        
        % thin
        lut1        = images.internal.lutthin1();
        image_iter1 = images.internal.gpu.bwlookup(c, gpuArray(lut1));
        lut2        = images.internal.lutthin2();
        cc          = images.internal.gpu.bwlookup(image_iter1, gpuArray(lut2));
        
        % diag
        lutd = images.internal.lutdiag();
        d    = images.internal.gpu.bwlookup(cc, gpuArray(lutd));
        
        c  = (c & ~cc & d) | cc;
        
        %c(1:m,     1:2)     = true;
        subStruct.type = '()';
        subStruct.subs = {1:m, 1:2};
        c = subsasgn(c, subStruct, true);
        %c(1:m,     (n-1):n) = true;
        subStruct.type = '()';
        subStruct.subs = {1:m, (n-1):n};
        c = subsasgn(c, subStruct, true);
        %c(1:2,     1:n)     = true;
        subStruct.type = '()';
        subStruct.subs = {1:2, 1:n};
        c = subsasgn(c, subStruct, true);
        %c((m-1):m, 1:n)     = true;
        subStruct.type = '()';
        subStruct.subs = {(m-1):m, 1:n};
        c = subsasgn(c, subStruct, true);
        
        
        %c  = ~c(3:(m-2),3:(n-2));
        subStruct.type = '()';
        subStruct.subs = {3:(m-2), 3:(n-2)};
        c = subsref(c, subStruct);
        c = ~c;
        
        bw = c;
        
    otherwise
        error(message('images:bwmorph:unknownOperation',opStr));
        
end

end
