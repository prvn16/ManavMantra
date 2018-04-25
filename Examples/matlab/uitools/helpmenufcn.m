function helpmenufcn(~, cmd)
% This function is undocumented and will change in a future release

%HELPMENUFCN Implements part of the figure help menu.
%  HELPMENUFCN(H, CMD) invokes help menu command CMD in figure H.
%
%  CMD can be one of the following:
%
%    HelpGraphics
%    HelpPlottingTools
%    HelpAnnotatingGraphs
%    HelpPrintingExport

%  Copyright 1984-2014 The MathWorks, Inc.

if nargin > 1
    cmd = convertStringsToChars(cmd);
end

switch cmd
    case 'HelpGraphics'
        helpview([docroot '/techdoc/creating_plots/creating_plots.map'],'creating_plots')
    case 'HelpPlottingTools'
        helpview([docroot '/techdoc/creating_plots/creating_plots.map'],'matlab_plotting_tools')
    case 'HelpAnnotatingGraphs'
        helpview([docroot '/techdoc/creating_plots/creating_plots.map'],'annotating_graphs')
    case 'HelpPrintingExport'
        helpview([docroot '/techdoc/creating_plots/creating_plots.map'],'print_collection_intro')
    case 'HelpTerms'
        web(matlab.internal.licenseAgreement);
    case 'HelpPatents'
        web(strcat(matlabroot,'/patents.txt'));
end

