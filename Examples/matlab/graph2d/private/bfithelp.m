function bfithelp(cmd)
% BFITHELP Displays help for Basic Fitting and Data Statistics
%   BFITHELP('bf') displays Basic Fitting Help
%   BFITHELP('ds') displays Data Statistics Help

%   Copyright 1984-2011 The MathWorks, Inc.

switch cmd
    case 'bf'
        try
            helpview([docroot '/techdoc/time_series_csh/time_series_csh.map'], ...
                'basic_fitting_options' ,'CSHelpWindow');
        catch err
            bfitcascadeerr(getString(message('MATLAB:graph2d:bfit:ErrorUnableToDisplayHelpForBasicFitting', err.message ))...
                , getString(message('MATLAB:graph2d:bfit:TitleBasicFitting')));
        end
        
    case 'ds'
        try
            helpview([docroot '/techdoc/time_series_csh/time_series_csh.map'], ...
                'plotting_basic_stats2' ,'CSHelpWindow');
        catch err
            bfitcascadeerr(getString(message('MATLAB:graph2d:bfit:ErrorUnableToDisplayHelpForDataStatistics', err.message )),...
                getString(message('MATLAB:graph2d:bfit:TitleDataStatistics')));
        end
end
