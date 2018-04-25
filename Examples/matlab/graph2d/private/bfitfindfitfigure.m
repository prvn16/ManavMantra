function fig = bfitfindfitfigure(~,figtag)
% BFITFINDFITFIGURE is used to find a Basic Fitting or Data Stats figure 
%
% It should be used only by private Basic Fitting and Data Stats 
% functions. 

%   Copyright 2006-2017 The MathWorks, Inc.
%     

% If a Basic Fitting figure is opened after having been saved, it will have
% the same 'Basic_Fit_Fig_Tag' identifier as the original figure until
% Basic Fitting is opened on it. Therefore check for an additional property
% that will only appear on the original figure

potentialfigures = findobj(groot,'-function',@(x) isprop(x,'Basic_Fit_Fig_Tag') && isequal(x.Basic_Fit_Fig_Tag, figtag));
fig = [];
for i=1:length(potentialfigures)
    if ishghandle(potentialfigures(i)) && ...
            ~isempty(bfitFindProp(potentialfigures(i), 'Basic_Fit_GUI_Object'))
        fig = potentialfigures(i);
        break;
    end
end         


