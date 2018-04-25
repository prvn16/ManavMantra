classdef ReportConstants
    %REPORTCONSTANTS String contants for the directory reports
    
    % Copyright 2009-2016 The MathWorks, Inc.
    
    properties(SetAccess = private, Constant)
        Error = getString(message('MATLAB:codetools:reports:ErrorStrong'));
        
        %% call types
        Variable = getString(message('MATLAB:codetools:reports:Variable'));
        Unknown = getString(message('MATLAB:codetools:reports:Unknown'));
        Builtin = getString(message('MATLAB:codetools:reports:BuiltIn'));
        MatlabToolbox = getString(message('MATLAB:codetools:reports:MatlabToolbox'));
        Private = getString(message('MATLAB:codetools:reports:Private'));
        CurrentDirectory = getString(message('MATLAB:codetools:reports:CurrentDir'));
        Toolbox = getString(message('MATLAB:codetools:reports:Toolbox'));
        JavaMethod = getString(message('MATLAB:codetools:reports:JavaMethod'));
        StaticMethod = getString(message('MATLAB:codetools:reports:StaticClassMethod'));
        PackageFunction = getString(message('MATLAB:codetools:reports:PackageFunction'));
		SubFunction = getString(message('MATLAB:codetools:reports:Subfunction'));
        Other = getString(message('MATLAB:codetools:reports:Other'));
    end
    
    methods
    end
    
end

