function colors = getColorChoices
%getColorChoices Returns a structure containing several high-contrast colors.
%   COLORS = getColorChoices returns a structure containing several colors
%   defined as RGB triplets.

%   Copyright 2005-2011 The MathWorks, Inc.
%   

% First color in the list will be the default.
temp = {getString(message('images:roiContextMenuUIString:mediumBlueColorChoiceContextMenuLabel')), [ 72  72 248]/255
        getString(message('images:roiContextMenuUIString:lightBlueColorChoiceContextMenuLabel')),  [ 72 136 248]/255
        getString(message('images:roiContextMenuUIString:lightRedColorChoiceContextMenuLabel')),   [248  79  79]/255
        getString(message('images:roiContextMenuUIString:greenColorChoiceContextMenuLabel')),      [ 72 248  72]/255
        getString(message('images:roiContextMenuUIString:yellowColorChoiceContextMenuLabel')),     [248 246  74]/255
        getString(message('images:roiContextMenuUIString:magentaColorChoiceContextMenuLabel')),    [248  72 248]/255
        getString(message('images:roiContextMenuUIString:cyanColorChoiceContextMenuLabel')),       [ 72 248 248]/255
        getString(message('images:roiContextMenuUIString:lightGrayColorChoiceContextMenuLabel')),  [232 232 232]/255
        getString(message('images:roiContextMenuUIString:blackColorChoiceContextMenuLabel')),      [  0   0   0]/255};
    
tagStrings = {'medium blue cmenu item'
              'light blue cmenu item'
              'light red cmenu item'
              'green cmenu item'
              'yellow cmenu item'
              'magenta cmenu item'
              'cyan cmenu item'
              'light gray cmenu item'
              'black cmenu item'};    
    
colors = struct('Label', temp(:,1), 'Color', temp(:,2), 'Tag',tagStrings(:));
