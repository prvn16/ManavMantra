function FigName = dlgfigname(Fig)
%DLGFIGNAME Determine name to use in PrintDlg for Figure
%   Name consistents values of Handle and Name properties
%   of Figure argument.

%   Copyright 1984-2017 The MathWorks, Inc.

FigName = get(Fig,'name');
FigNum = double(Fig);
if strcmp(get(Fig,'numbertitle'),'on') 
    if ~isempty(FigName)
        FigName = [': ' FigName];
    end
    if strcmp(get(Fig,'IntegerHandle'),'on')
        FigName = ['Figure ' sprintf('%d', FigNum) FigName];
    else
        FigName = ['Figure ' sprintf('%.16g',FigNum) FigName];
    end
end

if isempty(FigName)   % no name, number title off
    if strcmp(get(Fig,'IntegerHandle'),'on')
        FigName = ['Figure ' sprintf('%d',FigNum)];
    else
        FigName = ['Figure ' sprintf('%.16f',FigNum)];
    end
end
