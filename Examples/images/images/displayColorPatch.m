function displayColorPatch(varargin)
%displayColorPatch Display visual color reproduction as color patches
%
%   displayColorPatch(colorTable) displays measured color values from color
%   patches of esfrChart as color patches surrounded by a thick boundary of 
%   the corresponding reference color.
%
%   displayColorPatch(___, Name, Value, ___) displays measured color values from color
%   patches of esfrChart with additional parameters controlling aspects of
%   the display.
%
%   Parameters are:
%
%   'displayROIIndex'   :   Logical controlling whether color patch indices are 
%                           overlaid or not. Default is true.
%
%   'displayDeltaE'     :   Logical controlling whether delta E values are 
%                           overlaid or not. Default is true.
%
%   'Parent'            :   Handle of an axes that specifies the parent of the 
%                           image object created by displayColorPatch.
%
%   Class Support
%   -------------
%   colorTable is a table which can be computed by measureColor function. 
%
%   Notes
%   -----
%   1.  Numbering convention for color patches match the displayed numbers on 
%       an esfrChart using displayChart function.
%   2.  deltaE values are according to CIE76 specifications and are
%       Euclidean distances between measured and reference colors in CIELab
%       space.
%
%   Example
%   -------
%   % This example shows the procedure for measuring color
%   % and plotting the results
%
%   I = imread('eSFRTestImage.jpg');
%   I = rgb2lin(I);
%   chart = esfrChart(I);
%   figure
%   displayChart(chart);
%   colorTable = measureColor(chart);
%
%   % Plot results
%   figure
%   displayColorPatch(colorTable)
%
%   See also esfrChart, measureColor, plotChromaticity

%   Copyright 2017 The MathWorks, Inc.
            
narginchk(1,7);

options = parseInputs(varargin{:});
colorTable = options.colorTable;
displayROIIndex = options.displayROIIndex;
displayDeltaE = options.displayDeltaE;
parentAxis = options.Parent;

measuredRGB = im2double([colorTable.Measured_R colorTable.Measured_G colorTable.Measured_B]);
referenceRGB = lab2rgb([colorTable.Reference_L colorTable.Reference_a colorTable.Reference_b],'OutputType','double');
del_E = colorTable.Delta_E;
displayTextLocation = zeros(16,2);

col_sq_sz = 180;
col_sq_width=round(col_sq_sz/6);

full_col_ch = zeros(4*col_sq_sz,4*col_sq_sz,3);

displayText = cell(16,1);

for m =1:4
    for n=1:4
        ind = (n-1)+4*(m-1)+1;
        col_sq = zeros(col_sq_sz,col_sq_sz,3);
        col_sq(:,:,1) = referenceRGB(ind,1)*255;
        col_sq(:,:,2) = referenceRGB(ind,2)*255;
        col_sq(:,:,3) = referenceRGB(ind,3)*255;
        
        col_sq(col_sq_width:end-col_sq_width,col_sq_width:end-col_sq_width,1) = measuredRGB(ind,1)*255;
        col_sq(col_sq_width:end-col_sq_width,col_sq_width:end-col_sq_width,2) = measuredRGB(ind,2)*255;
        col_sq(col_sq_width:end-col_sq_width,col_sq_width:end-col_sq_width,3) = measuredRGB(ind,3)*255;
        
        full_col_ch(col_sq_sz*(m-1)+1:col_sq_sz*(m-1)+col_sq_sz,col_sq_sz*(n-1)+1:col_sq_sz*(n-1)+col_sq_sz,:) = col_sq;
        displayTextLocation(ind,1) = round(col_sq_sz*(n-1)+1+col_sq_sz/4); % X location
        displayTextLocation(ind,2) = round(col_sq_sz*(m-1)+1+col_sq_sz/2); % Y location
                
        if displayROIIndex && displayDeltaE            
            displayText{ind} = sprintf('Patch %d \n\n$$\\Delta$$E = %3.1f ', ind, del_E(ind));
        elseif displayROIIndex && ~displayDeltaE
            displayText{ind} = sprintf('Patch %d', ind);
        elseif ~displayROIIndex && displayDeltaE
            displayText{ind} = sprintf('$$\\Delta$$E = %3.1f ', del_E(ind));
        end
    end
end

if isempty(parentAxis)
    hIm = imshow(uint8(full_col_ch));
    h = ancestor(hIm,'figure');
    set(h,'Name','Visual Color Comparison')
else
    imshow(uint8(full_col_ch), 'Parent', parentAxis);
end
text(displayTextLocation(:,1),displayTextLocation(:,2),displayText,'FontSize',15,'FontWeight','bold','Color',[1 1 1],'Interpreter','latex');

end

function options = parseInputs(varargin)

parser = inputParser();
parser.addRequired('colorTable',@validateTable);
parser.addParameter('displayROIIndex',true,@validateDisplayFlag);
parser.addParameter('displayDeltaE',true,@validateDisplayFlag);
parser.addParameter('Parent',[],@validateParentAxis);

parser.parse(varargin{:});
options = parser.Results;
end

function validateTable(colorTable)
    validateattributes(colorTable,{'table'},{'nonempty'},mfilename,'colorTable',1);
end

function validateDisplayFlag(flag)
    supportedClasses = {'logical'};
    attributes = {'nonempty','finite','nonsparse','scalar','nonnan'};
    validateattributes(flag,supportedClasses,attributes,...
        mfilename);
end

function validateParentAxis(Parent)
validateattributes(Parent, {'matlab.graphics.axis.Axes'},{'nonempty','nonsparse'});
end
