classdef CompilerConfiguration
% CompilerConfiguration class encapsulates information used by MEX.
%
% See also MEX MEX.getCompilerConfigurations

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2013/07/23 01:17:18 $

    properties( SetAccess=private )
        Name
        ShortName
        Manufacturer
        Language
        Version
        Location
        Details
        LinkerName
        LinkerVersion
        MexOpt
        Priority
    end

    methods
        function CC = CompilerConfiguration(basicStruct,ccDetails)
        %
        
        % CompilerConfiguration constructor
        %   CompilerConfiguration(basicStruct,ccDetails) creates
        %   CompilerConfiguration from basicStruct that contains the values
        %   of its properties and a MEX.CompilerConfigurationDetails object
        %   ccDetails.
        %
        %   See help for MEX.getCompilerConfigurations for more information.
        %
        % See also MEX MEX.getCompilerConfigurations
        % MEX.CompilerConfiguration MEX.CompilerConfigurationDetails
            CC.Name = basicStruct.Name;
            CC.Manufacturer = basicStruct.Manufacturer;
            CC.Language = basicStruct.Language;
            CC.Version = basicStruct.Version;
            CC.ShortName = basicStruct.ShortName;
            CC.MexOpt = basicStruct.MexOpt;
            CC.Priority = basicStruct.Priority;
            try
                % These fields were introduced in 12b. The initialization
                % is done inside a try-catch block to maintain forward
                % compatibility.
                CC.LinkerName = basicStruct.LinkerName;
                CC.LinkerVersion = basicStruct.LinkerVersion;
            catch mExp %#ok<NASGU>
                CC.LinkerName = '';
                CC.LinkerVersion = '';
            end
            CC.Location = basicStruct.Location;
            CC.Details = ccDetails;
        end
    end

end