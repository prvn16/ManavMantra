classdef Language < handle
    
    properties (SetAccess=private, GetAccess=public)
        language = 'en';
        templates = connector.internal.academy.i18n.en.Templates
    end
    
    methods
        
        function setLanguage(obj, lang)
            here = fileparts(mfilename('fullpath'));
            templateFolder = fullfile(here,['+' lang]);
            if exist(templateFolder,'dir')
                obj.language = lang;                
                obj.templates = connector.internal.academy.i18n.(lang).Templates;
            end
        end
        
    end
    
end

