function B = labeloverlayalgo(A,L,colormap,alphaVal,includeLabelList)
%   Copyright 2017 The MathWorks, Inc.

if ismatrix(A)
    A = repmat(A,[1 1 3]); % Convert grayscale image to 3 identical planes
end

% Form corresponding alphamap based on alphaVal and skipLabelList declared.
alphamap = zeros([1,size(colormap,1)],'single');
alphamap(includeLabelList) = alphaVal;

% Modify colormap and alphamap to include room for the zero label
colormap = [colormap(1,:);colormap];
alphamap = [0,alphamap];

B = images.internal.labeloverlaymex(A,L,colormap,alphamap);