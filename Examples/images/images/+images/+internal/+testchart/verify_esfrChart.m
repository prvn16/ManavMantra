function verify_esfrChart(chart)
% Verify that the detected chart is a valid esfrChart chart image and error out if
% conditions are not met

im = im2double(imgaussfilt(chart.ImageGray,1));

% Find distances between registration points and decide if detection is
% good based on their differences and ratios. Dij is the distance between
% registration point i and j normalized by the image columns.
D12 = norm(chart.RegistrationPoints(1,:)-chart.RegistrationPoints(2,:))/chart.ImageCol;
D34 = norm(chart.RegistrationPoints(3,:)-chart.RegistrationPoints(4,:))/chart.ImageCol;
D14 = norm(chart.RegistrationPoints(1,:)-chart.RegistrationPoints(4,:))/chart.ImageCol;
D23 = norm(chart.RegistrationPoints(2,:)-chart.RegistrationPoints(3,:))/chart.ImageCol;
D13 = norm(chart.RegistrationPoints(1,:)-chart.RegistrationPoints(3,:))/chart.ImageCol;
D24 = norm(chart.RegistrationPoints(2,:)-chart.RegistrationPoints(4,:))/chart.ImageCol;

measShape = (abs(D12-D34)+abs(D14-D23)+abs(D13-D24))/3; % Check less than 0.05
checkShape = (measShape > 0.05) || (D12 < 0.1) || (D34 < 0.1) || (D14 < 0.1) || (D23 < 0.1);

if checkShape
    error(message('images:esfrChart:UnalignedRegistrationPoints'));
end

% Check alignment using two dark circular regions
alignmentPoint1 = chart.modelPoints(181,:);
alignmentPoint2 = chart.modelPoints(182,:);

intensity1 = im(alignmentPoint1(2),alignmentPoint1(1));
intensity2 = im(alignmentPoint2(2),alignmentPoint2(1));

% Intensities should be similar
measIntensity1 = norm(intensity1-intensity2);% Check less than 0.1

% Intensity of point in the middle of the two points should be
% significantly more than that of the two dark points.
measIntensity2 = im(round((alignmentPoint1(2)+alignmentPoint2(2))/2),...
    round((alignmentPoint1(1)+alignmentPoint2(1))/2))/((intensity1+intensity2)/2);% Check greater than 2

if(measIntensity1 > 0.1) || (measIntensity2 < 2)
   error(message('images:esfrChart:IntensityMismatchAlignmentPoints'));
end

% check if gray patches have monotonically increasing intensity
GrayROIs = images.internal.testchart.detectGrayPatches(chart);
grayIntensities = zeros(chart.numGrayPatches,1);
for i =1:chart.numGrayPatches
    grayIntensities(i) = mean2(GrayROIs(i).ROIIntensity);
end

measGrayPatches = issorted(movmean(grayIntensities,3),'ascend');
if(measGrayPatches==0)
   error(message('images:esfrChart:IntensityMismatchGrayPatches'));
end
end
