function plotSFR(varargin)
%plotSFR Plot spatial frequency response (SFR)
%
%   plotSFR(sharpnessMeasurementTable) plot spatial frequency response
%   stored in a valid sharpness measurement table or aggregate sharpness
%   measurement table computed using measureSharpness function.
%
%   plotSFR(___, Name, Value, ___) plot spatial frequency response
%   with additional parameters controlling the regions of interest for which
%   SFR is plotted and whether the plot legends are displayed or not.
%
%   Parameters are:
%
%   'ROIIndex'      :   Specify index of a particular ROI for which SFR
%                       would be plotted. Numbering convention is same as displayed when an
%                       esfrChart is displayed using displayChart function.
%                       It can also be a vector of indices in which case multiple
%                       figures would be created. Default corresponds to
%                       ROI index of first row of an input table with only one figure
%                       being created.
%
%   'displayLegend' :   Logical controlling whether plot legends are displayed or not.
%                       Default is true.
%
%   'displayTitle'  :   Logical controlling whether plot title displayed or not.
%                       Default is true.
%
%   'Parent'        :   Handle of an axes or an array of handles of axes that specifies the parent
%                       of the image object(s) created by plotSFR.
%
%   Class Support
%   -------------
%   sharpnessMeasurementTable is a table which can be computed by
%   measureSharpness function. 
%
%   Notes
%   -----
%   1.  When sharpnessMeasurementTable is an aggregate sharpness table,
%       any ROIIndex inputs are ignored and all rows of the input table
%       are plotted.
%   2.  The number of axes handles specified as parameter 'Parent' should equal the
%       number of plots to be generated. In case of an aggregate sharpness table, the parent axes if
%       specified has to be an array of two axes handles.
%
%   Example
%   -------
%   % This example shows how to measure SFR and plot them
%   I = imread('eSFRTestImage.jpg');
%   I = rgb2lin(I);
%   chart = esfrChart(I);
%   figure
%   displayChart(chart)
%
%   % Measure sharpness at ROIs one to four along with their
%   % averaged responses in vertical and horizontal directions
%   [sharpnessTable, aggregateSharpnessTable]  = measureSharpness(chart,'ROIIndex',1:4);
%   plotSFR(sharpnessTable, 'ROIIndex',1:4)
%   plotSFR(aggregateSharpnessTable, 'displayLegend', false)
%
%   See also esfrChart, measureSharpness

%   Copyright 2017 The MathWorks, Inc.


narginchk(1,9);

options = parseInputs(varargin{:});
sharpnessTable = options.sharpnessTable;
ROIIndex = options.ROIIndex;
displayLegend = options.displayLegend;
displayTitle = options.displayTitle;
flagAggregateTable = options.flagAggregateTable;
parentAxis = options.Parent;

inValidROIs = [];
if flagAggregateTable
    % Plot both vertical and horizontal for aggregate tables
    tableRowNumbers = 1:size(sharpnessTable,1);
else
    if isempty(ROIIndex)
        % Plot first row only in case no ROIs are specified
        tableRowNumbers = 1;        
    else
        % Find and plot valid ROIs that exist in the table
        [validROIs,tableRowNumbers, ~] = intersect(sharpnessTable.ROI,ROIIndex);
        inValidROIs = setdiff(ROIIndex, validROIs);
    end
end

if isempty(tableRowNumbers)
    error(message('images:esfrChart:noSlantedEdgeROIs'));
end

if ~isempty(parentAxis)
    if length(parentAxis) ~= length(tableRowNumbers)
        error(message('images:esfrChart:unequalNumberOfAxes'));
    end
end

if ~isempty(inValidROIs)
    warning(message('images:esfrChart:inValidROIIndices'));
end

isOneFigure = length(tableRowNumbers) == 1;

for index=1:length(tableRowNumbers)
    row = tableRowNumbers(index);
    F = sharpnessTable.SFR{row}.F;
    R = sharpnessTable.SFR{row}.SFR_R;
    G = sharpnessTable.SFR{row}.SFR_G;
    B = sharpnessTable.SFR{row}.SFR_B;
    Y = sharpnessTable.SFR{row}.SFR_Y;
    
    n_half = sum(F<=0.5) + 1;
    F_lhalf = F(1:n_half);
    F_rhalf = F(n_half:end);
    
    R_lhalf = R(1:n_half);
    R_rhalf = R(n_half:end);
    
    G_lhalf = G(1:n_half);
    G_rhalf = G(n_half:end);
    
    B_lhalf = B(1:n_half);
    B_rhalf = B(n_half:end);
    
    Y_lhalf = Y(1:n_half);
    Y_rhalf = Y(n_half:end);
    
    if isempty(parentAxis)
        
        if isOneFigure
            h = gcf;
        else
            h = figure;
        end
        plot(F_lhalf,R_lhalf,'r',F_lhalf,G_lhalf,'g',F_lhalf,B_lhalf,'b',F_lhalf,Y_lhalf,'k','LineWidth',1.5); hold on;
        plot(F_rhalf,R_rhalf,':r',F_rhalf,G_rhalf,':g',F_rhalf,B_rhalf,':b',F_rhalf,Y_rhalf,':k','LineWidth',1.5); hold off;
        
        if flagAggregateTable
            set(h,'Name',getString(message('images:esfrChart:AverageSFRPlotFigureName',sharpnessTable.Orientation{row})));
            if displayTitle
                title(getString(message('images:esfrChart:AverageSFRPlotTitle',sharpnessTable.Orientation{row})));
            end
        else
            set(h,'Name',getString(message('images:esfrChart:SFRPlotFigureName',num2str(sharpnessTable.ROI(row)))));
            if displayTitle
                title(getString(message('images:esfrChart:SFRPlotTitle',num2str(sharpnessTable.ROI(row)))));
            end
        end
        
        if displayLegend            
            legend(getString(message('images:esfrChart:RChannelLegend')), ...
                getString(message('images:esfrChart:GChannelLegend')), ...
                getString(message('images:esfrChart:BChannelLegend')), ...
                getString(message('images:esfrChart:LChannelLegend')), ...
                getString(message('images:esfrChart:RChannelBeyondNyquistLegend')), ...
                getString(message('images:esfrChart:GChannelBeyondNyquistLegend')), ...
                getString(message('images:esfrChart:BChannelBeyondNyquistLegend')), ...
                getString(message('images:esfrChart:LChannelBeyondNyquistLegend')));
        end
        
        
        axis tight;
        grid on;

        xlabel(getString(message('images:esfrChart:SFRPlotXLabel')));
        ylabel(getString(message('images:esfrChart:SFRPlotYLabel')));
        
    else
        plot(parentAxis(index),F_lhalf,R_lhalf,'r',F_lhalf,G_lhalf,'g',F_lhalf,B_lhalf,'b',F_lhalf,Y_lhalf,'k','LineWidth',1.5); hold(parentAxis(index),'on');
        plot(parentAxis(index),F_rhalf,R_rhalf,':r',F_rhalf,G_rhalf,':g',F_rhalf,B_rhalf,':b',F_rhalf,Y_rhalf,':k','LineWidth',1.5); hold(parentAxis(index),'off');
        if displayLegend
            legend(parentAxis(index), getString(message('images:esfrChart:RChannelLegend')), ...
                getString(message('images:esfrChart:GChannelLegend')), ...
                getString(message('images:esfrChart:BChannelLegend')), ...
                getString(message('images:esfrChart:LChannelLegend')), ...
                getString(message('images:esfrChart:RChannelBeyondNyquistLegend')), ...
                getString(message('images:esfrChart:GChannelBeyondNyquistLegend')), ...
                getString(message('images:esfrChart:BChannelBeyondNyquistLegend')), ...
                getString(message('images:esfrChart:LChannelBeyondNyquistLegend')));            
        end
        
        if displayTitle
            if flagAggregateTable
                title(parentAxis(index),getString(message('images:esfrChart:AverageSFRPlotTitle',sharpnessTable.Orientation{row})));
            else                
                title(parentAxis(index),getString(message('images:esfrChart:SFRPlotTitle',num2str(sharpnessTable.ROI(row)))));
            end
        end

        axis(parentAxis(index),'tight');
        grid(parentAxis(index),'on');
        
        xlabel(parentAxis(index),getString(message('images:esfrChart:SFRPlotXLabel')));
        ylabel(parentAxis(index),getString(message('images:esfrChart:SFRPlotYLabel')));
        
    end    
    
end
end

function options = parseInputs(varargin)

parser = inputParser();
parser.addRequired('sharpnessTable',@validateTable);
parser.addParameter('ROIIndex',[],@validateROIIndex);
parser.addParameter('displayLegend',true,@validateDisplayFlag);
parser.addParameter('displayTitle',true,@validateDisplayFlag);
parser.addParameter('Parent',[],@validateParentAxis);

parser.parse(varargin{:});
options = parser.Results;

flagAggregateTable = false;
if strcmp(options.sharpnessTable.Properties.VariableNames(1),'Orientation')
    flagAggregateTable = true;
end
options.flagAggregateTable = flagAggregateTable;
end

function validateTable(sharpnessTable)
validateattributes(sharpnessTable,{'table'},{'nonempty'},mfilename,'sharpnessTable',1);
end

function validateDisplayFlag(flag)
supportedClasses = {'logical'};
attributes = {'nonempty','finite','nonsparse','scalar','nonnan'};
validateattributes(flag,supportedClasses,attributes,...
    mfilename);
end

function validateROIIndex(ROIIndex)
supportedClasses = images.internal.iptnumerictypes;
attributes = {'nonempty','nonsparse','real','nonnan','finite','integer', ...
    '<=',60,'positive','nonzero','vector'};
validateattributes(ROIIndex,supportedClasses,attributes,mfilename, ...
    'ROIIndex');
end

function validateParentAxis(Parent)
validateattributes(Parent, {'matlab.graphics.axis.Axes'},{'nonempty','nonsparse','vector'}, mfilename);
end
