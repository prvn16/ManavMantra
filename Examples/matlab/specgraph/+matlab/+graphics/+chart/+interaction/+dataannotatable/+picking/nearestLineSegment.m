function [startMin, endMin, tMin] = nearestLineSegment(point, seriesData, sections, usabilityTolerance)
%nearestLineSegment Find the indices of the nearest line segment
%
%  [ind1, ind2, t] = nearestLineSegment(point, data) finds the line segment
%  in the 2D data array that is closest to the provided point. The data
%  array should be of size (2xN).  The function returns the indices of the
%  data points at each end of the closest segment as well as the fraction
%  along the line segment that is closest to the given point. t will always
%  be between 0 and 1.
%
%  [...] = nearestLineSegment(point, data, sections) specifies the start
%  and end indices of multiple sections that the provided data is for.  The
%  data is treated as separate sections with no segment joining between
%  each one.  If the closest point is an isolated point in a length-one
%  section then the returned line segment indices will both contain the
%  same index value. The sections input must be a (2xM) array, specifying M
%  sections.
%
%  [...] = nearestLineSegment(point, data, sections, usabilityTolerance)
%  specifies a usability-imposed limit that the caller to the function
%  wants to impose because they know that ultimately cannot see the
%  difference between two segments closer than this tolerance. It is set to
%  0 by default.

%  Copyright 2013-2014 The MathWorks, Inc.

if nargin<4
    usabilityTolerance = 0;
end

if nargin<3
    if isempty(seriesData)
        sections = zeros(2,0);
    else
        sections = [1;size(seriesData,2)];
    end
end

% Best segment index and metrics
startMin = [];
endMin = [];
tMin = 0;
dMin = inf;
AB2Min = inf;
L2Min = inf; % Projected distance from closest vertex on a segment
L2computedMin = true;
numTolMin = 0;

numSections = size(sections, 2);
if numSections==0
    return
end
sectionLengths = sections(2,:) - sections(1,:);

% Current segment index information.  The segment indices and section end
% are in the data array index system.  The conversion to the segment index
% system is provided by the trueIndexOffset, which alters for each section.
sectionIndex = 1;
segStart = 1;
sectionEnd = 1+sectionLengths(1);
segEnd = min(sectionEnd, segStart+1);
trueIndexOffset = sections(1,1) - segStart;

ptX = point(1);
ptY = point(2);

while sectionIndex<=numSections
    
    % 1. Compute distance metrics for this segment
    xAB = seriesData(1,segEnd) - seriesData(1,segStart);
    yAB = seriesData(2,segEnd) - seriesData(2,segStart);
    xAM = ptX - seriesData(1,segStart);
    yAM = ptY - seriesData(2,segStart);
    
    AB2 = xAB^2 + yAB^2;
    
    % Compute projected distance along AB
    t = xAM.*xAB + yAM.*yAB;
    
    % Defer computation of L2 unless it is needed
    L2 = 0;
    L2computed = false;
    
    % Calculate a numerical tolerance to use for this segment's
    % comparisons
    biggest = max(abs(xAB), abs(yAB));
    biggest = max(biggest, abs(xAM));
    biggest = max(biggest, abs(yAM));
    numTol = 1000*eps(biggest);
    
    if ~isfinite(t)
        % Measure distance to the second point because that might be
        % finite and the last point on the segment.
        xBM = ptX - seriesData(1,segEnd);
        yBM = ptY - seriesData(2,segEnd);
        d = hypot(xBM, yBM);
        AB2 = 1;
        t = 1; % Clamp to AB2
        numTol = 1000*eps(max(abs(xBM), abs(yBM)));
        
    elseif t <= 0
        d = hypot(xAM, yAM);
        % Do not clamp t to 0 otherwise other segments at the same
        % distance will be ignored
    elseif t >= AB2
        d = hypot(xAM-xAB, yAM-yAB);
        % Do not clamp t to AB2 otherwise other segments at
        % the same distance will be ignored
    else
        % Calculate distance to that point on the line
        tNorm = t./AB2; % Normalize t
        d = hypot((xAM - tNorm.*xAB), (yAM - tNorm.*yAB));
    end
    

    % 2. Compare the current segment with the previous best segment.
    
    % Use the smallest numerical tolerance from the best and the new segment
    numericalTolerance = min(numTolMin, numTol);
    
    % Combine numerical tolerance with a usability tolerance that represents
    % the differences we know a user can visually see.
    overlapTolerance = max(usabilityTolerance, numericalTolerance);

    TakeNew = false;
    x = (dMin-d);
    if x>overlapTolerance
        % It is a closer segment, choose it
        TakeNew = true;
    elseif abs(x)<=overlapTolerance
        % Approximately same distance segment
        prev_inside = (tMin>=0 && tMin<AB2Min);
        new_inside = (t>=0 && t<AB2);
        if (prev_inside && new_inside) || (~prev_inside && ~new_inside)
            % Both project inside the segment, or both are outside the
            % segment. Compare the L2 values
            if ~L2computed
                if t/AB2<=0.5 % We are closer to the first point
                    L2 = t^2/AB2;
                else
                    L2 = (AB2-t)^2/AB2;
                end
                L2computed = true;
            end
            if ~L2computedMin
                if tMin/AB2Min<=0.5 % We are closer to the first point
                    L2Min = tMin^2/AB2Min;
                else
                    L2Min = (AB2Min-tMin)^2/AB2Min;
                end
                L2computedMin = true;
            end
            if L2 < (L2Min-numericalTolerance)
                % If L2 is less than L2min not because of a numerical error
                % choose the latest segment
                TakeNew = true;
            end
        elseif new_inside
            % Only the latest one is inside the segment
            % So choose the latest one
            TakeNew = true;
        end
        % Otherwise stick with tmin since this one projects inside the
        % segment.
    end
    
    if TakeNew
        % Switch current best to the new segment
        dMin = d;
        L2Min = L2;
        L2computedMin = L2computed;
        tMin = t;
        AB2Min = AB2;
        numTolMin = numTol;
        startMin = segStart + trueIndexOffset;
        endMin = segEnd + trueIndexOffset;
    end
    
    
    % 3. Move to next segment
    if segEnd<sectionEnd
        % Go to next segment in this section
        segStart = segEnd;
        segEnd = segEnd+1;
        
    else
        % Start next section
        sectionIndex = sectionIndex+1;
        
        if (sectionIndex<=numSections)
            segStart = segEnd+1;
            sectionEnd = sectionEnd + sectionLengths(sectionIndex) + 1;      
            segEnd = min(sectionEnd, segStart+1);
            trueIndexOffset = sections(1,sectionIndex) - segStart;
        end
    end
end

% Normalize t
if tMin <= 0
    tMin = 0;
elseif tMin >= AB2Min
    tMin = 1;
else
    tMin = tMin./AB2Min;
end
