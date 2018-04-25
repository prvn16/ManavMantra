classdef(Hidden) MatlabFileType
    %MATLABFILETYPE an enumeration describing the MATLAB-file type
    %
    %   This function is unsupported and might change or be removed without
    %   notice in a future version.
    
    % Copyright 2008-2009 The MathWorks, Inc.
%     
%     enumeration
%         Class(sprintf('class'))
%         Function(sprintf('function'))
%         Script(sprintf('script'))
%         Unknown(spritnf('unknown'))
%     end
%     properties(Hidden, Access = private)
%         Name;
%     end
%     
%     methods(Access = private)
%         function obj = MatlabFileType(name)
%             obj.Name = name;
%         end
%     end
%     methods
%         function str = char(obj)
%             str = obj.Name;
%         end
%         
%     end
% end
    methods (Abstract, Static)
        string = char(obj);
    end

    methods
        function is = eq(objA, objB)
            is = strcmp(class(objA), class(objB));
        end
    end
end
