function [I,pvPairs] = createRemovedProperties(h,keepflag)
% This undocumented function may be removed in a future release.

% Copyright 2013-2016 The MathWorks, Inc.

% Compute the result of removing brushed data from a graphic
% object. The following parameters are returned:
% I - logical array representing removed points
% pvPairs - pv-pair cell array which can be passed to "set" on the
% graphic object to display the results of the remove operation.
%
% The results of this method may need to be augmented for graphic
% objects such as scatter where additional properties such as
% SizeData and CData are effected by removing brushed data.

if ~isempty(h.findprop('ZData')) && ~isempty(h.ZData)
    zdata = get(h,'ZData');
else
    zdata = [];
end
xdata = get(h,'XData');
ydata = get(h,'YData');
brushdata = h.BrushData;

% Find brushed points for this object
if ~isempty(brushdata)
    % If zdata is a matrix or nd array OR the brushData along the 3rd
    % dimension
    if ~isempty(zdata) && ~isvector(zdata)
        I = brushdata(:,:,1)>0;
        for j=2:size(brushdata,3)
            I = I | (brushdata(:,:,j)>0);
        end
        
    else
        I = (h.BrushData(1,:)>0);
        for j=2:size(brushdata,1)
            I = I | (brushdata(j,:)>0);
        end
    end
else
    return;
end

% Invert if keep
if keepflag
    I = ~I;
end

% Remove brushed data from arrays

if ~isempty(zdata) && ~isvector(zdata)
    % Find complete columns/rows
    Icols = all(I,1);
    Irows = all(I,2);
    if ~any(Icols) && ~any(Irows)
        if keepflag
            errordlg(getString(message('MATLAB:datamanager:dataEdit:NoRemoveNoBrush')), ...
            'MATLAB','modal');
        else
            errordlg(getString(message('MATLAB:datamanager:dataEdit:NoRemoveBrush')), ...
           'MATLAB','modal');
        end
        pvPairs = {};
        return
    end
    if isvector(ydata)
        ydata(Irows) = [];
    else
        ydata(Irows,:) = [];
    end
    if isvector(xdata)
        xdata(Icols) = [];
    else
        xdata(:,Icols) = [];
    end
    zdata(:,Icols) = [];
    zdata(Irows,:) = [];
    brushdata(:,Icols) = [];
    brushdata(Irows,:) = [];
    if isempty(zdata) || isempty(xdata) || isempty(ydata)
        zdata = NaN;
        xdata = NaN;
        ydata = NaN;
    end
else
    brushdata(:,I) = [];
    xdata(I) = [];
    ydata(I) = [];
    if ~isempty(h.findprop('ZData')) && ~isempty(h.ZData)
        zdata = get(h,'ZData');
        zdata(I) = [];
    else
        zdata = [];
    end
end

% Apply modified data to graphic objects
manMode = true;
try  %#ok<TRYNC>
    manMode = strcmp(get(h,'XDataMode'),'manual');
end

if manMode
    if isempty(zdata)
        pvPairs = {'XData',xdata,'YData',ydata,'BrushData',brushdata};
    else
        pvPairs = {'XData',xdata,'YData',ydata,'ZData',zdata,'BrushData',brushdata};
    end
else
    if isempty(zdata)
        pvPairs = {'YData',ydata,'BrushData',brushdata};
    else
        pvPairs = {'YData',ydata,'ZData',zdata,'BrushData',brushdata};
    end
end

% Removal of MarkerIndices
if isprop(h,'MarkerIndices') && strcmpi(get(h,'MarkerIndicesMode'),'manual')
   
    markerInd =  h.MarkerIndices;   
    
    %Create an array of the same size as brushed data
    IMarker = false(size(I));     
    IMarker(markerInd) = true;    
    
    %get the new marker Indecies based the indecies that will exist after removal of brushed data 
    markerInd = find(IMarker(~I));
    
    % Add the values to the pvPairs
    pvPairs = [pvPairs,{'MarkerIndices',markerInd}];
end
end