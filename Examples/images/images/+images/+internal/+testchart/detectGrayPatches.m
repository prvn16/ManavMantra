function GrayROIs = detectGrayPatches(chart)
% Find dimensions of the gray ROIs in an esfrChart

X = chart.modelPoints(:,1);
Y = chart.modelPoints(:,2);

GrayPatch = zeros(chart.numGrayPatches,8);
GrayPatch(1,:) = [X(65) Y(65) X(66) Y(66) X(67) Y(67) X(68) Y(68)];
GrayPatch(2,:) = [X(69) Y(69) X(65) Y(65) X(68) Y(68) X(70) Y(70)];
GrayPatch(3,:) = [X(71) Y(71) X(72) Y(72) X(73) Y(73) X(74) Y(74)];
GrayPatch(4,:) = [X(75) Y(75) X(76) Y(76) X(77) Y(77) X(78) Y(78)];
GrayPatch(5,:) = [X(79) Y(79) X(80) Y(80) X(81) Y(81) X(82) Y(82)];
GrayPatch(6,:) = [X(83) Y(83) X(84) Y(84) X(85) Y(85) X(86) Y(86)];
GrayPatch(7,:) = [X(87) Y(87) X(88) Y(88) X(89) Y(89) X(90) Y(90)];
GrayPatch(8,:) = [X(91) Y(91) X(92) Y(92) X(93) Y(93) X(94) Y(94)];
GrayPatch(9,:) = [X(95) Y(95) X(96) Y(96) X(97) Y(97) X(98) Y(98)];
GrayPatch(10,:) = [X(99) Y(99) X(100) Y(100) X(101) Y(101) X(102) Y(102)];
GrayPatch(11,:) = [X(103) Y(103) X(104) Y(104) X(96) Y(96) X(95) Y(95)];
GrayPatch(12,:) = [X(105) Y(105) X(106) Y(106) X(100) Y(100) X(99) Y(99)];
GrayPatch(13,:) = [X(107) Y(107) X(108) Y(108) X(109) Y(109) X(110) Y(110)];
GrayPatch(14,:) = [X(111) Y(111) X(112) Y(112) X(113) Y(113) X(114) Y(114)];
GrayPatch(15,:) = [X(115) Y(115) X(116) Y(116) X(117) Y(117) X(118) Y(118)];
GrayPatch(16,:) = [X(119) Y(119) X(120) Y(120) X(121) Y(121) X(122) Y(122)];
GrayPatch(17,:) = [X(123) Y(123) X(124) Y(124) X(125) Y(125) X(126) Y(126)];
GrayPatch(18,:) = [X(127) Y(127) X(128) Y(128) X(129) Y(129) X(130) Y(130)];
GrayPatch(19,:) = [X(131) Y(131) X(132) Y(132) X(133) Y(133) X(134) Y(134)];
GrayPatch(20,:) = [X(135) Y(135) X(131) Y(131) X(134) Y(134) X(136) Y(136)];

% Calculate height and width of the ROI within the OECF squares to be used
% for noise and OECF calculation. Right now calculated using the first
% square only.
half_GrayPatch_width = round(chart.grayPatch_ratio*abs(GrayPatch(1,1)-GrayPatch(1,3))/2);
half_GrayPatch_height = round(chart.grayPatch_ratio*abs(GrayPatch(1,2)-GrayPatch(1,8))/2);

GrayROIs = repmat(struct('ROI',zeros(1,4),'ROIIntensity',zeros(2*half_GrayPatch_height+1, 2*half_GrayPatch_width+1, size(chart.Image,3))),chart.numGrayPatches,1);

for i=1:chart.numGrayPatches
    x_cen = round(mean(GrayPatch(i,1:2:7)));
    y_cen = round(mean(GrayPatch(i,2:2:8)));
    GrayROIs(i).ROI = [x_cen-half_GrayPatch_width y_cen-half_GrayPatch_height 2*half_GrayPatch_width+1 2*half_GrayPatch_height+1];
    GrayROIs(i).ROIIntensity = chart.Image(y_cen-half_GrayPatch_height:y_cen+half_GrayPatch_height,x_cen-half_GrayPatch_width:x_cen+half_GrayPatch_width,:);
end
end
