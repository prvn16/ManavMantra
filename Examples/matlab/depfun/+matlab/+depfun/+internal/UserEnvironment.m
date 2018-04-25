classdef UserEnvironment < matlab.depfun.internal.Environment
    
    properties
        FullToolboxRoot = fullfile(matlabroot,'toolbox')
        RelativeToolboxRoot = 'toolbox'
        DependencyDatabasePath = ...
            fullfile(fileparts(mfilename('fullpath')), ...
            ['requirements_' computer('arch') '_dfdb']);
    end
    
end