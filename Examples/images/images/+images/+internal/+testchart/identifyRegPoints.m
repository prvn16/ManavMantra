function regPoints = identifyRegPoints(corners)
% Identify unique registration points for an esfrChart

% Numbering convention for registration points
%  1  2
%  4  3

points = corners.Location;
regPoints = zeros(4,2);

[center_pts] = mean(points);

% Top left corner
regPt_1 = (points(:,1)<=center_pts(1)) & (points(:,2)<=center_pts(2));
if(sum(regPt_1)==0)
    error(message('images:esfrChart:NotFoundRegistrationPointOne'));
elseif (sum(regPt_1)==1)
    regPoints(1,:) = round(points(regPt_1,:));
else
    regPoints(1,:) = round(median(points(regPt_1,:)));
end

% Top right corner
regPt_2 = (points(:,1)>center_pts(1)) & (points(:,2)<=center_pts(2));
if(sum(regPt_2)==0)
    error(message('images:esfrChart:NotFoundRegistrationPointTwo'));
elseif (sum(regPt_2)==1)
    regPoints(2,:) = round(points(regPt_2,:));
else
    regPoints(2,:) = round(median(points(regPt_2,:)));
end

% Bottom right corner
regPt_3 = (points(:,1)>center_pts(1)) & (points(:,2)>center_pts(2));
if(sum(regPt_3)==0)
    error(message('images:esfrChart:NotFoundRegistrationPointThree'));
elseif (sum(regPt_3)==1)
    regPoints(3,:) = round(points(regPt_3,:));
else
    regPoints(3,:) = round(median(points(regPt_3,:)));
end

% Bottom left corner
regPt_4 = (points(:,1)<=center_pts(1)) & (points(:,2)>center_pts(2));
if(sum(regPt_4)==0)
    error(message('images:esfrChart:NotFoundRegistrationPointFour'));
elseif (sum(regPt_4)==1)
    regPoints(4,:) = round(points(regPt_4,:));
else
    regPoints(4,:) = round(median(points(regPt_4,:)));
end

end
