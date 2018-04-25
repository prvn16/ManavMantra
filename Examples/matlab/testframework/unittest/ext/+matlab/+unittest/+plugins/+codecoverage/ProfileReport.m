classdef ProfileReport <  matlab.unittest.plugins.codecoverage.CoverageFormat
    % ProfileReport - A format to create a profiler code coverage report.
    %
    %   To display a MATLAB Profiler Coverage Report, use an instance of the
    %   ProfileReport class with the CodeCoveragePlugin.
    %                                                                      
    %   Example:
    %                                                                      
    %       import matlab.unittest.plugins.CodeCoveragePlugin;
    %       import matlab.unittest.plugins.codecoverage.ProfileReport;
    %          
    %       % Construct a CodeCoveragePlugin with the ProfileReport 
    %       % coverage format
    %       plugin = CodeCoveragePlugin.forFolder('C:\projects\myproj',...
    %           'Producing',ProfileReport);
    %
    %   See also: matlab.unittest.plugins.CodeCoveragePlugin
    
    % Copyright 2017 The MathWorks, Inc. 
    
    methods (Hidden,Access = {?matlab.unittest.internal.mixin.CoverageFormatMixin,...
            ?matlab.unittest.plugins.codecoverage.CoverageFormat})
        function generateCoverageReport(~,sources,~)
            import matlab.unittest.internal.diagnostics.indent;

            for idx = 1:numel(sources)
                try
                    html = coveragerpt(char(sources(idx).Name));
                catch me
                    warning(message('MATLAB:unittest:CodeCoveragePlugin:UnableToGenerateReport', ...
                        char(sources(idx).Name), indent(me.message, '    ')));
                    continue;
                end
                web(['text://', html{:}], '-noaddressbox', '-new');
            end 
        end
    end
end