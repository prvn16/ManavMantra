function setBrushingInterval(varName,startRowInd,endRowInd,minRowInd,maxRowInd,action,varargin)

%   Copyright 2007-2009 The MathWorks, Inc.

% Method used by Variable Editor brushing actions to brush rows.

% Get the current brushing array
[mfile,fcnname] = datamanager.getWorkspace(1);
h = datamanager.BrushManager.getInstance();
I = h.getBrushingProp(varName,mfile,fcnname,'I');


if strcmp(action,'cache')
    h.ApplicationData = struct('VarName',varName,'I',I);
    return
elseif strcmp(action,'clearcache')
    h.ApplicationData = [];
    return
end
    

% If the variable had not been brushed it be empty, so initialize it 
% to false.
if isempty(I)
    I = false(evalin('caller',['size(' varName ');']));
end

% Java table does not know about the variable size, so clip the interval
% bounds.
if ~isempty(startRowInd) && ~isempty(endRowInd)
    if isvector(I)
        startRowInd = max(min(startRowInd,length(I)),1);
        endRowInd = max(min(endRowInd,length(I)),1);
        minRowInd = max(min(minRowInd,length(I)),1);
        maxRowInd = max(min(maxRowInd,length(I)),1);        
    else
        startRowInd = max(min(startRowInd,size(I,1)),1);
        endRowInd = max(min(endRowInd,size(I,1)),1);
        minRowInd = max(min(minRowInd,size(I,1)),1);
        maxRowInd = max(min(maxRowInd,size(I,1)),1);
    end
end

% Default color is red.
if nargin>=7
    brushColor = varargin{1};
else
    brushColor = h.getBrushingProp(varName,mfile,fcnname,'Color');
    if isempty(brushColor)
        brushColor = [1 0 0];
    end
end

switch action
    % Add brushing in this interval to everything outside
    % minRowInd-maxRowInd  
    case 'set' 
        I = false(size(I));
        if isvector(I)
            I(startRowInd:endRowInd) = true;
        else
            I(startRowInd:endRowInd,:) = true;
        end
    % Add brushing in this interval to everything outside
    % minRowInd-maxRowInd  
    case 'add'
        if ~isempty(h.ApplicationData) && strcmp(h.ApplicationData.VarName,varName) 
            if isvector(I)
                I(minRowInd:maxRowInd) = h.ApplicationData.I(minRowInd:maxRowInd);
                I(startRowInd:endRowInd) = true;
            else
                I(minRowInd:maxRowInd,:) = h.ApplicationData.I(minRowInd:maxRowInd,:);
                I(startRowInd:endRowInd,:) = true;
            end           
        else      
            if isvector(I)
                I(minRowInd:maxRowInd) = false;
                I(startRowInd:endRowInd) = true;
            else
                I(minRowInd:maxRowInd,:) = false;
                I(startRowInd:endRowInd,:) = true;
            end
        end
        
    % Context menu invoked. Brush this row if it not already brushed.
    case 'popup'
        if I(startRowInd)
            return
        else
            I = false(size(I));
            I(startRowInd) = true;
        end
    case 'removeall'
        I = false(size(I));      
end
% brushColor must be cast to a double array for hg2 brushing
h.setBrushingProp(varName,mfile,fcnname,'I',I,'Color',double(brushColor));
h.draw(varName,mfile,fcnname)
