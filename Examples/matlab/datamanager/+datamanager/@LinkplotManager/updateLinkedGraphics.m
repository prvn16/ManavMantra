function linkedFigStruct = updateLinkedGraphics(h,I)

% Copyright 2008-2015 The MathWorks, Inc.

% Callback for graphic changes in linked plots which update
% linkplotmanager.

linkedFigStruct = [];
if isempty(I)
    return
end
if isempty(h.Figures)
    return
end


% If f is a figure handle look up its index position. Note that ishghandle
% must not be used here since it will return true for indices which
% coincide with figure handle numbers (g675923).
if isa(I,'figure') || isobject(I)
    I = find(I==[h.Figures.Figure]);
    if isempty(I)
        return
    end
end
f = h.Figures(I);

% Find graphic objects which can support linking (but may have empty data
% source properties)
[gObj, gCustom] = datamanager.findLinkedGraphics(f.Figure);

h.Figures(I).IsEmpty = isempty(gObj) && isempty(gCustom);

for k=length(gCustom):-1:1
    bobj = hggetbehavior(gCustom(k),'linked'); 
    bEnable(k) = bobj.Enable; 
    bIsLinked(k) = islinked(bobj);
end

% Identify linked graphics
linkedNonCustomGraphics = handle(findobj(gObj,'flat','-function',...
                              @(x) ~isempty(get(x,'YDataSource')) || ...
                              ~isempty(get(x,'XDataSource')) || ...
                              ~isempty(get(x,'ZDataSource'))));
if ~isempty(gCustom)
    linkedCustomGraphics = handle(gCustom(bIsLinked & bEnable));
    if any(~bEnable)
        linkedNonCustomGraphics = setdiff(linkedNonCustomGraphics,handle(gCustom(~bEnable)));
    end
else
    linkedCustomGraphics = [];
end

% Modified to handle possible non-compatibile 'empty' arrays
if isempty( linkedNonCustomGraphics )
    linkedGraphics = linkedCustomGraphics(:);
elseif isempty( linkedCustomGraphics )
    linkedGraphics = linkedNonCustomGraphics(:);    
else
    linkedGraphics = [linkedNonCustomGraphics(:);linkedCustomGraphics(:)];
end

hasLinkDataErrorProp = handle(findobj(linkedGraphics,'-property','LinkDataError'));
if length(hasLinkDataErrorProp)<length(linkedGraphics)
    for k=1:length(linkedGraphics)
        if ~any(hasLinkDataErrorProp==linkedGraphics(k))
            addprop(linkedGraphics(k),'LinkDataError');
        end
    end 
end
h.Figures(I).LinkedGraphics = linkedGraphics;

% Update current variable list
varNames = cell(length(linkedGraphics),3);
subsStr = cell(length(linkedGraphics),3);
numRegularObjs = length(linkedGraphics)-length(linkedCustomGraphics);
for k=1:numRegularObjs
    [varNames{k,1},subsStr{k,1}] = localExtractVarName(get(linkedGraphics(k),'XDataSource'));    
    [varNames{k,2},subsStr{k,2}] = localExtractVarName(get(linkedGraphics(k),'YDataSource'));
    if ~isempty(findprop(handle(linkedGraphics(k)),'ZDataSource'))
        [varNames{k,3},subsStr{k,3}] = localExtractVarName(get(linkedGraphics(k),'ZDataSource'));
    end
end
for k=1:length(linkedCustomGraphics)
    linkedbehavior = hggetbehavior(linkedCustomGraphics(k),'Linked');
    if linkedbehavior.UsesXDataSource
        [varNames{k+numRegularObjs,1},subsStr{k+numRegularObjs,1}] = ...
            localExtractVarName(get(linkedbehavior,'XDataSource'));
    end
    if linkedbehavior.UsesYDataSource
        [varNames{k+numRegularObjs,2},subsStr{k+numRegularObjs,2}] = ...
            localExtractVarName(get(linkedbehavior,'YDataSource'));
    end
    if linkedbehavior.UsesZDataSource
        [varNames{k+numRegularObjs,3},subsStr{k+numRegularObjs,3}] = ...
            localExtractVarName(get(linkedbehavior,'ZDataSource'));
    end
end

% If plotting over a linked figure with un-linked graphics -> go out of
% linked mode
if ~isempty(h.Figures(I).VarNames) && isempty(varNames)
    fig = h.Figures(I).Figure;
    h.rmFigure(h.Figures(I).Figure);
    linkdata(fig,'off');
    return
end
h.Figures(I).VarNames = varNames;
h.Figures(I).SubsStr = subsStr;

% Signal that LinkPlotManager linkedGraphics are up to date
h.Figures(I).Dirty = false;

linkedFigStruct = h.Figures(I);

function [varName,subsstr] = localExtractVarName(expstr)

% Extract a potential variable name from the contents of a DataSource
% property. Most general from is X.Y(...)

expstr = strtrim(expstr);     
parenPos = strfind(expstr,'(');
if ~isempty(parenPos)
    % Split the string in to variable and substring parts
    subsstr = strtrim(expstr(parenPos:end));
    expstr = expstr(1:parenPos-1);
    % Validate the variable
    varName = validateVariable(expstr);
    if isempty(varName)
        subsstr = ''; % not a valid variable
    else
        % validate substring part % substr must be of the form (*)
        % Ex: (1:10),(1:end),(1:end-1),(1:10,1),(1,1:end),(1:10,1:end)
        subsstr = validateSubstring(subsstr);
    end
    return
end
subsstr = '';
expstrArfterLastPeriod =  expstr;
dotPos = strfind(expstrArfterLastPeriod,'.');
if ~isempty(dotPos)
    expstrArfterLastPeriod = expstrArfterLastPeriod(dotPos(end)+1:end);
end
if ~isvarname(expstrArfterLastPeriod)
    varName = '';
else
    varName = expstr;
end

function varName = validateVariable(expstr)
% check if the variable is a builtin function or a valid varname
if isvarname(expstr) && ~(exist(expstr,'builtin') || exist(expstr,'file') || exist(expstr,'dir') || exist(expstr,'class'))
    varName = expstr;
else
    varName = '';
end

function subsstr = validateSubstring(subsstr)
if length(subsstr)<=2 || subsstr(1)~='(' || subsstr(end)~=')'
    subsstr = '';
else
    subargs = subsstr(2:end-1);
    if exist(subargs,'builtin') || exist(subargs,'file') || exist(subargs,'dir') || exist(subargs,'class')
        subsstr = '';
    else
        % Is this a variable or a valid argument of form ?
        % (1:10),(1:end),(1:end-1),(1:10,1),(1,1:end),(1:10,1:end) etc
        patternStr = '\s*(\d*|(\<end-\>\d+|(\<end\>)))\s*(:|,)*\s*(\d*|(\<end-\>\d+|(\<end\>)))\s*';
        matchstring = regexp(subargs, patternStr ,'match');
        % strcat(matchstring) returns the same string as subsstr if it
        % matches the regular expression.
        if isempty(matchstring) || ~strcmp(strjoin(matchstring,''),subargs) 
            % an invalid substring or a variable
            subsstr = '';
        end
    end
end
