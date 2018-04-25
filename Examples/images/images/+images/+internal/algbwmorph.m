function [bwout, lut] = algbwmorph(bw,opStr,n)  
% Main algorithm used by the bwmorph function. See bwmorph for more
% details.

%
% No input validation is done in this function.
% bw     - A nonempty logical 2D matrix
% fcnStr - One of the ~20 documented strings
% n      - A positive number greater than 1 whos integer value indicates 
%          the number of times a certain operations needs to be performed.
%

% Copyright 2012-2013 The MathWorks, Inc.

%#codegen
coder.internal.prefer_const(opStr);
coder.internal.prefer_const(n);

if(n<1)
    bwout = bw;
    lut   = [];
    
elseif(n==1)
    [bwout,lut] = bwmorphApplyOnce(bw,opStr);    
    
else    
    iter  = 0;
    bwout = bw;
    lut   = [];
    while(iter<n)
        
        last_aout   = bwout;
        [bwout,lut] = bwmorphApplyOnce(bwout,opStr);
        iter        = iter+1;
        
        if(isequal(last_aout, bwout))
            %> the output is not changing anymore
            break
        end
    end
end



function [bw, lut] = bwmorphApplyOnce(bw, opStr)

switch opStr
        %
        % Function BOTHAT
        %   
    case 'bothat'

        lut = [];
        bwc = bwlookup(bw, images.internal.lutdilate());
        bwc = bwlookup(bwc, images.internal.luterode());
        bw  = bwc & ~bw;
        
        %
        % Function BRANCHPOINTS
        %
    case 'branchpoints'
        
        lut = [];
        
        % Initial branch point candidates
        C = bwlookup(bw, images.internal.lutbranchpoints());
        
        % Background 4-Connected Object Count (Vp)
        B = bwlookup(bw, images.internal.lutbackcount4());
        
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
        D = bwlookup(Vq, images.internal.lutdilate());
        
        % Intersection between dilated Vq and final candidates w/ Vp = 2
        M = (FC & Vp) & D;
        
        % Final Branch Points
        bw =  FC & ~M;
        
        %
        % Function BRIDGE
        %
    case 'bridge'
        
        lut = images.internal.lutbridge();
        bw  = bwlookup(bw, lut);
        
        %
        % Function CLEAN
        %
    case 'clean'
        
        lut = images.internal.lutclean();
        bw = bwlookup(bw, lut);
        
        %
        % Function CLOSE
        %
    case 'close'
        
        lut = [];
        bwd = bwlookup(bw,images.internal.lutdilate());
        bw  = bwlookup(bwd, images.internal.luterode());
        
        %
        % Function DIAG
        %
    case 'diag'
        
        lut = images.internal.lutdiag();
        bw  = bwlookup(bw, lut);
        
        
        %
        % Function DILATE
        %
    case 'dilate'
        
        lut = images.internal.lutdilate();
        bw  = bwlookup(bw, lut);
        
        %
        % Function ENDPOINTS
        %
    case 'endpoints'
        
        lut = images.internal.lutendpoints();
        bw  = bwlookup(bw, lut);
        
        %
        % Function ERODE
        %
    case 'erode'
        
        lut = images.internal.luterode();
        bw  = bwlookup(bw, lut);
        
        
        %
        % Function FATTEN
        %
    case 'fatten'
        
        lut = images.internal.lutfatten();
        bw  = bwlookup(bw, lut);
        
        
        %
        % Function FILL
        %
    case 'fill'
        
        lut = images.internal.lutfill();
        bw  = bwlookup(bw, lut);
        
        %
        % Function HBREAK
        %
    case 'hbreak'
        
        lut = images.internal.luthbreak();
        bw  = bwlookup(bw, lut);
        
        %
        % Function MAJORITY
        %
    case 'majority'
        
        lut = images.internal.lutmajority();
        bw  = bwlookup(bw, lut);
        
        %
        % Function OPEN
        %
    case 'open'
        
        lut = [];        
        bw  = bwlookup(bw,images.internal.luterode());
        bw  = bwlookup(bw,images.internal.lutdilate());
        
        
        %
        % Function PERIM4
        %
    case 'perim4'
        
        lut = images.internal.lutper4();
        bw  = bwlookup(bw, lut);
        
        %
        % Function PERIM8
        %
    case 'perim8'
        
        lut = images.internal.lutper8();
        bw  = bwlookup(bw, lut);
        
        %
        % Function REMOVE
        %
    case 'remove'
        
        lut = images.internal.lutremove();
        bw  = bwlookup(bw, lut);
        
        %
        % Function SHRINK
        %
    case 'shrink'
        
        lut   = [];
        table = images.internal.lutshrink();
        
        % First subiteration
        m   = bwlookup(bw, table);
        sub = bw & ~m;
        bw(1:2:end,1:2:end) = sub(1:2:end,1:2:end);
        
        % Second subiteration
        m   = bwlookup(bw, table);
        sub = bw & ~m;
        bw(2:2:end,2:2:end) = sub(2:2:end,2:2:end);
        
        % Third subiteration
        m   = bwlookup(bw, table);
        sub = bw & ~m;
        bw(1:2:end,2:2:end) = sub(1:2:end,2:2:end);
        
        % Fourth subiteration
        m   = bwlookup(bw, table);
        sub = bw & ~m;
        bw(2:2:end,1:2:end) = sub(2:2:end,1:2:end);
        
        %
        % Function SKEL
        %
    case 'skeleton'
        
        lut = [];
        for i = 1:8
            bw = bwlookup(bw, images.internal.lutskel(i));
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
        endPoints = bwlookup(bw, images.internal.lutspur());
        
        % Remove end points in the first field.
        bw(1:2:end, 1:2:end) = xor(bw(1:2:end, 1:2:end), ...
            endPoints(1:2:end, 1:2:end));
        
        % In the second field, remove any of the original end points
        % that are still end points.
        newEndPoints = endPoints & bwlookup(bw, lut);
        bw(1:2:end, 2:2:end) = xor(bw(1:2:end, 2:2:end), ...
            newEndPoints(1:2:end, 2:2:end));
        
        % In the third field, remove any of the original end points
        % that are still end points.
        newEndPoints = endPoints & bwlookup(bw, lut);
        bw(2:2:end, 1:2:end) = xor(bw(2:2:end, 1:2:end), ...
            newEndPoints(2:2:end, 1:2:end));
        
        % In the fourth field, remove any of the original end points
        % that are still end points.
        newEndPoints = endPoints & bwlookup(bw, lut);
        bw(2:2:end, 2:2:end) = xor(bw(2:2:end, 2:2:end), ...
            newEndPoints(2:2:end, 2:2:end));
        
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
        
        lut = [];

        lut1        = images.internal.lutthin1();
        image_iter1 = bwlookup(bw, lut1);
        
        lut2 = images.internal.lutthin2();
        bw   = bwlookup(image_iter1, lut2);
        
        %
        % Function TOPHAT
        %
    case 'tophat'
        
        lut = [];                
        bwe = bwlookup(bw,images.internal.luterode());
        bwd = bwlookup(bwe,images.internal.lutdilate());
        bw  = bw&~bwd;
        
        
        %
        % Function THICKEN
        %
    case 'thicken'

        lut = [];
        
        % Isolated pixels are going to need a "jump-start" to get
        % them going; otherwise, they won't "thicken".
        % First, identify the isolated pixels.        
        iso = bwlookup(bw, images.internal.lutiso());
        if (any(iso(:)))
            % Identify possible pixels to maybe change to one.
            growMaybe = bwlookup(iso,images.internal.lutdilate());
            % Identify pixel locations in the original image
            % with only one on pixel in the 3-by-3 neighborhood.            
            oneNeighbor = bwlookup(bw, images.internal.lutsingle());
            % If a pixel is adjacent to an isolated pixel, *and* it
            % doesn't also have another neighbor, set it to one.
            bw = bw | (oneNeighbor & growMaybe);
        end
        
        % Create a padded logical array
        [m,n] = size(bw);
        m     = m+4;
        n     = n+4;
        
        if(isempty(coder.target()))
            % CPU or GPU inputs
            c = true([m,n], 'like', bw);
        else
            c = true([m,n]);
        end
                
        c(3:(m-2),3:(n-2)) = ~bw;
        
        % thin
        lut1        = images.internal.lutthin1();
        image_iter1 = bwlookup(c, lut1);        
        lut2        = images.internal.lutthin2();
        cc          = bwlookup(image_iter1, lut2);
        
        % diag
        lutd = images.internal.lutdiag();
        d    = bwlookup(cc, lutd);
        
        c  = (c & ~cc & d) | cc;
        
        c(1:m,     1:2)     = true;
        c(1:m,     (n-1):n) = true;
        c(1:2,     1:n)     = true;
        c((m-1):m, 1:n)     = true;
        
        c  = ~c(3:(m-2),3:(n-2));
        bw = c;
        
    otherwise
        error(message('images:bwmorph:unknownOperation',opStr));
        
end
