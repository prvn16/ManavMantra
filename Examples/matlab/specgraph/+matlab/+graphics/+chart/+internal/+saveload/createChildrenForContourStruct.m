function [patches,text] = createChildrenForContourStruct(hContour)
% convert x/y/ values into the line data
% needed by the older graphics system lines. This is required to be able
% to create a .FIG file that is compatible with older versions of MATLAB.

%   Copyright 2013-2017 The MathWorks, Inc.

    text = [];

    if strcmp(hContour.Fill,'on')
        patches = LdrawFilled(hContour);
    else
        patches = LdrawUnfilled(hContour);
    end
    
end

function h = LdrawUnfilled(hContour)

    c = hContour.ContourMatrix;
    limit = size(c,2);
    h = [];
    i = 1;

    % Make sure we have a valid value for 'EdgeColor' on a Patch.
    edgeColor = hContour.EdgeColor;
    if strcmpi(edgeColor,'auto')
        edgeColor = 'flat';
    end

    while(i < limit)
        z_level = c(1,i);
        npoints = c(2,i);
        nexti = i+npoints+1;
        
        xdata = c(1,i+1:i+npoints);
        ydata = c(2,i+1:i+npoints);
        cdata = z_level + 0*xdata;  % Make cdata the same size as xdata
        zdata = [];
        if (hContour.Is3D)
            zdata = [cdata, NaN];
        end
        
        cu = matlab.graphics.primitive.Patch('XData',[xdata NaN],'YData',[ydata NaN], ...
                                             'ZData', zdata, 'CData',[cdata NaN], ...
                                             'FaceColor','none','EdgeColor',edgeColor,...
                                             'LineWidth',hContour.LineWidth,'LineStyle',hContour.LineStyle,...
                                             'UserData',z_level,'HitTest','off',...
                                             'Selected',hContour.Selected,'Visible',hContour.Visible);
        
        ncdata = size(cu.FaceVertexCData,1);
        if size(cu.Vertices,1) ~= ncdata
            verts = cu.Vertices;
            cu.Vertices=verts(1:ncdata,:);
        end
        h = [h; cu(:)];
        i = nexti;
    end
end

function H = LdrawFilled(hContour)
    
    levels = hContour.LevelList;
    zdata = hContour.ZData;
    minz = min(zdata(:));
    
    % Don't fill contours below the lowest level specified in nv.
    % To fill all contours, specify a value of nv lower than the
    % minimum of the surface.
    draw_min=0;
    if any(levels <= minz)
        draw_min=1;
    end
    
    % Get the unique levels
    levels = [minz levels];
    zi = [1, find(diff(levels))+1];
    nv = levels(zi);
    
    %CS = hContour.ContourMatrix;
    CS = computePatchContourMatrix(hContour);
    % Find the indices of the curves in the c matrix, and get the
    % area of closed curves in order to draw patches correctly.
    ii = 1;
    ncurves = 0;
    I = [];
    Area=[];
    while (ii < size(CS,2))
        nl=CS(2,ii);
        ncurves = ncurves + 1;
        I(ncurves) = ii;
        xp=CS(1,ii+(1:nl));  % First patch
        yp=CS(2,ii+(1:nl));
        if nl > 2
            Area(ncurves)=sum( diff(xp).*(yp(1:nl-1)+yp(2:nl))/2 );
        else
            Area(ncurves)=0;
        end
        ii = ii + nl + 1;
    end
    
    % Plot patches in order of decreasing size. This makes sure that
    % all the levels get drawn, not matter if we are going up a hill or
    % down into a hole. When going down we shift levels though, you can
    % tell whether we are going up or down by checking the sign of the
    % area (since curves are oriented so that the high side is always
    % the same side). Lowest curve is largest and encloses higher data
    % always.
    
    [FA,IA]=sort(-abs(Area)); %#ok
    
    H=[];

    bg = get(ancestor(hContour,'axes'),'Color');
    
    % Make sure we have a valid value for 'EdgeColor' on a Patch.
    edgeColor = hContour.EdgeColor;
    if strcmpi(edgeColor,'auto')
        edgeColor = 'flat';
    end

    % get some properties as local variables for speed
    edgecolorflat = strcmp(edgeColor,'flat');
    patchpairs = {'EdgeColor',edgeColor, 'LineWidth',hContour.LineWidth,...
        'LineStyle',hContour.LineStyle,...
        'Selected',hContour.Selected,'Visible',hContour.Visible};
    for jj=IA
        nl=CS(2,I(jj));
        lev=CS(1,I(jj));
        if (lev ~= minz || draw_min )
            xp=CS(1,I(jj)+(1:nl));
            yp=CS(2,I(jj)+(1:nl));
            clev = lev;           % color for filled region above this level
            if (sign(Area(jj)) ~=sign(Area(IA(1))) )
                kk=find(nv==lev);
                kk0 = 1 + sum(nv<=minz) * (~draw_min);
                if (kk > kk0)
                    clev=nv(kk-1);    % in valley, use color for lower level
                elseif (kk == kk0)
                    clev=NaN;
                else
                    clev=NaN;         % missing data section
                    lev=NaN;
                end
                
            end
            if edgecolorflat
                clev = clev  + 0*xp;
            end
            if (isfinite(clev))
                cu=matlab.graphics.primitive.Patch('XData',xp,'YData',yp,'CData',clev,'FaceColor','flat','UserData',lev,patchpairs{:});
            else
                cu=matlab.graphics.primitive.Patch('XData', xp,'YData', yp,'CData',clev,'FaceColor',bg,'UserData',CS(1,I(jj)),patchpairs{:});
            end
            H=[H;cu];
        end
    end
    
    numPatches = length(H);
    if numPatches>1
        for i=1:numPatches
            set(H(i), 'faceoffsetfactor', 0, 'faceoffsetbias', (1e-3)+(numPatches-i)/(numPatches-1)/30);
        end
    end
end

function contourMatrix = computePatchContourMatrix(hContour)
    %compute the raw contour matrix including boundary vertices for
    %rendering HG1-style patches. This code was adapted from 
    %Perforce revision 4 of @contour/getContourMatrixImpl.m

    z = hContour.ZData;
    x = hContour.XData;
    y = hContour.YData;

    levelList = hContour.LevelList;
    zdata = hContour.ZData;
    zmin = min(zdata(:));
    zmax = max(zdata(:));

    contourMatrix = [];
    
    [mz, nz] = size(z);

    % Check the relative sizes and lengths of X, Y, and Z
    msg = xyzchk(x, y, z);
    if ~isempty(msg)
        error(msg);
    end

    
        % Note: The following 6 variables are assigned way before they are used
    % (and for some inputs they are not used at all).
    xmin = min(x(:));
    xmax = max(x(:));
    ymin = min(y(:));
    ymax = max(y(:));
    
    cMatCom = [];
    cMatComLen = 0;
        
    % Since it is possible for x and y to both be vectors, arrange them in
    % standard form for xyz operations.
    if (size(y, 1) == 1)
        y = y.';
    end
    if (size(x, 2) == 1)
        x = x.';
    end
    
    % Consider the following examples:
    %   z=peaks(5);
    %   [x1,y1]=meshgrid(1:5,1:5);
    %   [x2,y2]=meshgrid(5:-1:1,1:5);
    %   [x3,y3]=meshgrid(1:5,5:-1:1);
    %   [x4,y4]=meshgrid(5:-1:1,5:-1:1);
    %   [rc1,rh1]=contour(x1,y1,z);
    %   [rc2,rh2]=contour(x2,y2,z);
    %   [rc3,rh3]=contour(x3,y3,z);
    %   [rc4,rh4]=contour(x4,y4,z);
    % In all four cases, we wish to ensure that as we travel along closed
    % curves, higher values are to our right and lower values are to our
    % left.  In order to ensure this, we transform our inputs if we need
    % to reverse our orientation.  This need exists both for filled and
    % unfilled contours.
    
    % Transform if we need to reverse the orientation.
    isTransformed = false;
    areBothVectors = isvector(x) && isvector(y);
    if areBothVectors
        % x and y are both vectors.
        % check if we have to flip the data to get the correct orientation
        % the orientation should match the output of [x, y] = meshgrid(...)
        dx = x(2) - x(1);
        dy = y(2) - y(1);
        % Flip when x and y have different directions.
        sdx = sign(dx);
        sdy = sign(dy);
        if (sdx ~= sdy)
            if sdx < 0
                x = fliplr(x);
                z = fliplr(z);
            end
            if sdy < 0
                y = flipud(y);
                z = flipud(z);
            end
            isTransformed = true;
        end
    else
        % x and y are both matrices.
        % check if we have to transpose the data to get the correct orientation
        % the orientation should match the output of [x, y] = meshgrid(...)
        d1 = angle(x(1 : 2, 1 : 2), y(1 : 2, 1 : 2));
        d2 = angle(x(end - 1 : end, 1 : 2), y(end - 1 : end, 1 : 2));
        d3 = angle(x(1 : 2, end - 1 : end), y(1 : 2, end - 1 : end));
        d4 = angle(x(end - 1 : end, end - 1 : end), y(end - 1 : end, end - 1 : end));
        % Transpose when the four corner mesh quads all indicate that the
        % orientation must be reversed.
        if d1 < 0 && d2 < 0 && d3 < 0 && d4 < 0
            x = x.';
            y = y.';
            z = z.';
            [mz, nz] = size(z);
            isTransformed = true;
        end
        
        nanmask = isnan(x) | isnan(y);
        if any(nanmask(:))
            z(nanmask) = nan;
        end
    end
    
    % Surround the z matrix by a very low region to get closed contours, and
    % replace any NaN with low numbers as well.
    z = [NaN(1, nz + 2); NaN(mz, 1), z, NaN(mz, 1); NaN(1, nz + 2)];
    kk = find(isnan(z(:)));
    z(kk) = zmin - 1e4 * (zmax - zmin) + zeros(size(kk));

    % Expand the x and y matrices as necessary.
    if areBothVectors
        x = [2 * x(1) - x(2), x, 2 * x(nz) - x(nz - 1)];
        y = [2 * y(1) - y(2); y; 2 * y(mz) - y(mz - 1)];
    else
        if isTransformed
            x = [2 * x(1, :) - x(2, :); x; 2 * x(mz, :) - x(mz - 1, :)];
            y = [2 * y(:, 1) - y(:, 2), y, 2 * y(:, nz) - y(:, nz - 1)];
            x = x(:, [1, 1 : nz, nz]);
            y = y([1, 1 : mz, mz], :);
        else
            x = [2 * x(:, 1) - x(:, 2), x, 2 * x(:, nz) - x(:, nz - 1)];
            y = [2 * y(1, :) - y(2, :); y; 2 * y(mz, :) - y(mz - 1, :)];
            x = x([1, 1 : mz, mz], :);
            y = y(:, [1, 1 : nz, nz]);
        end
    end
    
    % Prune levels outside of the [zmin, zmax] range.
    v = levelList;
    v(v < zmin) = [];
    v(v > zmax) = [];
    
    % Since levelList is known to be sorted and unique, and since v
    % has pruned levels outside of the [zmin, zmax] range, if zmin is
    % an element of v, it must appear only once and be the first element.
    % We now must arrange for CONTOURS to be called with zmin as the first
    % element of v when computing a filled contour.
    if isempty(v) || v(1) ~= zmin
        v = [zmin, v];
    end
    
    % We need to distinguish CONTOURS(Z, V) and CONTOURS(Z, N), and we wish
    % to save the list v for later.
    if numel(v) == 1
        lev = [v, v];
    else
        lev = v;
    end
    
    % Initialize Contour Data variables
    zLevels = [];
    segIndicesRaw = [];
    segLengthsRaw = [];
    
    % Get the raw contour matrix.
    cMatRaw = contours(x, y, z, lev);
    cMatRawLen = size(cMatRaw, 2);
        
    if cMatRawLen == 0
        return
    end
        
    % Now we must parse the raw Contour Matrix.  At this stage, we do not know
    % how many segments are contained in the raw Contour Matrix.  Start
    % with a guess based on the size of the levelList.
    i = 1;
    k = 1;
    nGuess = 2 + 2 * numel(levelList);
    segIndicesRaw(nGuess) = 0;
    while (i < cMatRawLen)
        nPoints = cMatRaw(2, i);
        if k > numel(segIndicesRaw)
            segIndicesRaw(2 * (k + 1)) = 0;
        end
        segIndicesRaw(k) = i;
        k = k + 1;
        i = i + 1 + nPoints;
    end
    segIndicesRaw(k : end) = [];
    segIndicesRawLen = k - 1;
    segOrderLen = segIndicesRawLen;
    segOrder = 1 : segOrderLen;
    segLengthsRaw(segOrder) = cMatRaw(2, segIndicesRaw(segOrder));
    zLevels(segOrder) = cMatRaw(1, segIndicesRaw(segOrder));
    


    % Compute the area of the contour segments.
    areaVals(segIndicesRawLen) = 0;
    for i = segOrder
        indexVal = segIndicesRaw(i);
        nPoints = segLengthsRaw(i);
        iBegin = indexVal + 1;
        iEnd = indexVal + nPoints;
        xp = cMatRaw(1, iBegin : iEnd);
        yp = cMatRaw(2, iBegin : iEnd);
        
        % Triangle primitives require more than 2 points.
        if nPoints > 2
            areaVals(i) = sum(diff(xp) .* (yp(1 : nPoints - 1) + yp(2 : nPoints)) / 2);
        end
    end
    
    % Plot polygons in order of decreasing size. This makes sure that
    % all the levels get drawn, not matter if we are going up a hill or
    % down into a hole. When going down we shift levels though, you can
    % tell whether we are going up or down by checking the sign of the
    % area (since curves are oriented so that the high side is always
    % the same side). Lowest curve is largest and encloses higher data
    % always.
    
    % Compute the new segOrder for filled contours.
    [~, segOrder] = sort(-abs(areaVals));
    
    % Don't fill contours below the lowest level specified in levelList.
    % To fill all contours, specify a value in levelList at or below the
    % minimum of the surface.
    drawMin = false;
    if any(levelList <= zmin)
        drawMin = true;
    end
    
    % Eliminate indices from segOrder if necessary.
    if ~drawMin
        segOrder(zLevels(segOrder) == zmin) = [];
        segOrderLen = numel(segOrder); %#ok<NASGU>
    end
    
    % After this point, segOrderLen <= segIndicesRawLen
   
  
    
    contourMatrix = cMatRaw;
    return;
end


function a = angle(x, y)
    x1 = x(1, 2) - x(1, 1);
    x2 = x(2, 1) - x(1, 1);
    y1 = y(1, 2) - y(1, 1);
    y2 = y(2, 1) - y(1, 1);
    a = x1 * y2 - x2 * y1;
end
    
