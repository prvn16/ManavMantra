function codeCompatibilityReport(varargin)
%CODECOMPATIBILITYREPORT Creates and opens a code compatibility report.
%
%   codeCompatibilityReport creates a code compatiblity report for the
%   current working folder and subfolders.
%
%   codeCompatibilityReport(names) creates a code compatibility report for
%   files or folders specified by names, where names is a string scalar,
%   character vector, string array, or cell array of character vectors. The
%   filename must be a valid MATLAB code or App file (*.m, *.mlx, or *.mlapp).
%
%   codeCompatibilityReport(..., 'IncludeSubfolders', false) excludes
%   subfolders from the code compatibility analysis. Use this syntax with
%   any of the arguments in previous syntaxes.
%
%   codeCompatibilityReport(CCA) displays a report for CodeCompatibilityAnalysis
%   object CCA.
%
%   Example:
%   codeCompatibilityReport
%   codeCompatibilityReport(CCA)
%
%   See also analyzeCodeCompatibility, CodeCompatibilityAnalysis

%   Copyright 2017 The MathWorks, Inc.
    try
        validatedAnalysisResults = @(x)(isa(x, 'CodeCompatibilityAnalysis'));

        if ~any(cellfun(validatedAnalysisResults, varargin))
            % Input does not contains code compatibility result
            cca = analyzeCodeCompatibility(varargin{:});
            matlab.internal.codecompatibilityreport.viewReport(cca);
        elseif isscalar(varargin) && isscalar(varargin{1})
            % There is only one code compatibility result, and it is scalar
            matlab.internal.codecompatibilityreport.viewReport(varargin{:});
        elseif isscalar(varargin)
            % There is only one code compatibility result, but it is not scalar
            error(message('codeanalysis:ccrAnalysis:ScalarObject'));
        else
            % There are multiple inputs, at least one of them is code compatibility result
            error(message('codeanalysis:ccrAnalysis:TooManyInputsWithObject'));
        end
    catch ex
        throw(ex);
    end
end
