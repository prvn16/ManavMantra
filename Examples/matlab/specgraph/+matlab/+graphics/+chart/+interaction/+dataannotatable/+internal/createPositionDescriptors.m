function descriptors = createPositionDescriptors(hObj,position,dimensionNames)

% createPositionDescriptors - creates data descriptors that correspond to X, Y and Z numeric position values of
% the given object
% dimensionNames is an optional argument that will be used as the Name property in a DataDescriptor


descriptors = matlab.graphics.chart.interaction.dataannotatable.DataDescriptor.empty;

if numel(position) < 2 || numel(position) > 3
    return
end

pos3 = [];
if numel(position) == 3
    pos3 = position(3);
end

% Convert the values to the values of the rulers
[xVal,yVal,zVal] = matlab.graphics.internal.makeNonNumeric(hObj,position(1),position(2),pos3);
values = {xVal,yVal,zVal};

dimNames = hObj.DimensionNames;

% If the provided dimension names are the same size as the position vector
% use them
if nargin ==  3
    if isequal(size(position),size(dimensionNames)) && iscellstr(dimensionNames)
        dimNames = dimensionNames;
    end
end   
    
for i = 1:length(values)    
    if isempty(values{i})
        di = matlab.graphics.chart.interaction.dataannotatable.DataDescriptor.empty;
    else        
        di = matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(dimNames{i},values{i});
    end
    descriptors = [descriptors,di]; %#ok<AGROW>    
end
end


