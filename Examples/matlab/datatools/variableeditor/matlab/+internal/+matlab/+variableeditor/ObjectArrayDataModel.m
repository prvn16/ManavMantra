classdef ObjectArrayDataModel < internal.matlab.variableeditor.ArrayDataModel
    %OBJECTARRAYDATAMODEL 
    % Object Array Data Model
    %
    % Copyright 2015 The MathWorks, Inc.

    % Type
    properties (Constant)
        % Type Property
        Type = 'ObjectArray';
        
        ClassType = 'objectarray';
    end

    % Data
    properties (SetObservable = true)
        % Data Property
        Data
    end
    
    methods
        function storedValue = get.Data(this)
            storedValue = this.Data;
        end
        
        function set.Data(this, newValue)
%             if ~isobject(newValue) || length(size(newValue))~=2
%                 error(message('MATLAB:codetools:variableeditor:NotAnMxNCellArray'));
%             end
            reallyDoCopy = ~isequal(this.Data, newValue);
            if reallyDoCopy
                this.Data = newValue;
            end
        end
    end

    methods (Access = protected)    
        function lhs = getLHS(~, idx)
            lhs = sprintf('(%s)', idx);
        end
    end
    
%     methods(Access='public')
%         function rhs=getRHS(this,data)
%             if (size(data,1)==1)
%                 rhs = data;
%             else
%                 rhs = '{';
%                 for i=1:size(data,1)
%                     for j=1:size(data,2)
%                         rhs = [rhs mat2str(data{i,j}) ' '];
%                     end
%                     rhs = [rhs ';'];
%                 end
%                 rhs = [rhs '}'];
%             end
%         end
%     end
end

