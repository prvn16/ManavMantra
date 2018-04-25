function legstring = bfitgetlegendstring(whichstring,strtype,maxstringlength, dataH)
% BFITGETLEGENDSTRING Get the string for the legend on figure for Data Stats 
%    and Basic Fitting GUIs.

%   Copyright 2006-2011 The MathWorks, Inc.

start = 4;
legstring = blanks(maxstringlength);
if maxstringlength < 16
    error(message('MATLAB:bfitcreatelegend:LegendStringLength'))
end

% The handle is optional
if nargin < 4 || isempty(dataH)
    dataH = [];
end


switch whichstring
case {'fit'}
    tempStr = bfitgetdisplayname(strtype);
    legstring(start:start+numel(tempStr)-1) = tempStr;
case {'xstat','ystat'}    
    if isequal('xstat',whichstring)
       % If my dataSource property is set, and contains no punctuation
       % use that to generate the Legend label
       if ~isempty(dataH) && ~isempty(dataH.XDataSource) && ...
               ~any(isstrprop(dataH.XDataSource,'punct'))
           strStart = dataH.XDataSource;
       else
            strStart  = 'x';
       end
    else
       if ~isempty(dataH) && ~isempty(dataH.YDataSource) && ...
               ~any(isstrprop(dataH.YDataSource,'punct'))
           strStart = dataH.YDataSource;
       else
            strStart  = 'y';
       end
    end
    
    % Clip the name if it is over 12 characters long
    if length(strStart) >= 12
        strStart = [strStart(1:8), '...'];
    end
    
    legstring(start:start+numel(strStart)-1) = strStart;
    
    startplusskip = start + (numel(strStart)-1) + 2;
    switch strtype
    case 1
        tempStr = getString(message('MATLAB:graph2d:bfit:LegendStringMin'));
        legstring(startplusskip:startplusskip+numel(tempStr)-1) = tempStr;
    case 2
        tempStr = getString(message('MATLAB:graph2d:bfit:LegendStringMax'));
        legstring(startplusskip:startplusskip+numel(tempStr)-1) = tempStr;
    case 3
        tempStr = getString(message('MATLAB:graph2d:bfit:LegendStringMean'));
        legstring(startplusskip:startplusskip+numel(tempStr)-1) = tempStr;
    case 4
        tempStr = getString(message('MATLAB:graph2d:bfit:LegendStringMedian'));
        legstring(startplusskip:startplusskip+numel(tempStr)-1) = tempStr;
    case 5
        tempStr = getString(message('MATLAB:graph2d:bfit:LegendStringMode'));
        legstring(startplusskip:startplusskip+numel(tempStr)-1) = tempStr;
    case 6
        tempStr = getString(message('MATLAB:graph2d:bfit:LegendStringStd'));
        legstring(startplusskip:startplusskip+numel(tempStr)-1) = tempStr;
    otherwise
        error(message('MATLAB:bfitcreatelegend:LegendNoRangeString'))
    end
case 'eval results'
    legstring(start:start+7) = 'Y = f(X)';
otherwise
    error(message('MATLAB:bfitcreatelegend:NoStringType'))
end    
