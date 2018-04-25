classdef FeedbackTemplates
    
    properties (Constant)
        language = connector.internal.academy.i18n.Language;
    end
    
    methods (Static)
        function str = constructFeedback(base,varargin)
            import connector.internal.academy.i18n.FeedbackTemplates;
            try
                str = FeedbackTemplates.language.templates.(base);
                for i = 1:numel(varargin)
                    oldPart = ['${' num2str(i) '}'];
                    newPart = varargin{i};
                    assert(ischar(newPart),'Input to constructFeedback should be char');
                    str = strrep(str,oldPart,newPart);
                end
                assert(isempty(strfind(str,['${' num2str(i+1) '}'])),'Unable to construct feedback');
            catch 
                str = FeedbackTemplates.language.templates.incorrect;
            end
        end
    end    
    
end

