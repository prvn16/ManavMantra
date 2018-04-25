% Scalar
% Overloads operators to prevent users from making an array.

% Copyright 2014 The MathWorks, Inc.

classdef Scalar
    
    methods (Access=protected)
        % Only derived classes can construct objects of this class.
        function this = Scalar()
        end
    end
    
    methods (Hidden)
        function [varargout] = subsref(this,s)
            if strcmp(s(1).type,'()')
                throwAsCaller(MException(message('images:color:parenReferenceNotAllowed',class(this))));
            elseif strcmp(s(1).type,'{}')
                throwAsCaller(MException(message('images:color:cellReferenceNotAllowed',class(this))));
            else
                % Return default subsref to this object
                [varargout{1:nargout}] = builtin('subsref',this,s);
            end
        end
        
        function [varargout] = subsasgn(this,s,data)
            if     strcmp(s(1).type,'()')
                throwAsCaller(MException(message('images:color:parenAssignmentNotAllowed',class(this))));
            elseif strcmp(s(1).type,'{}')
                throwAsCaller(MException(message('images:color:cellAssignmentNotAllowed',class(this))));...
            else
                % Return default subsasgn to this object
                [varargout{1:nargout}] = builtin('subsasgn',this,s,data);
            end
        end
                
        function a = cat(this,varargin)
            throwAsCaller(catException(class(this)))
        end
        
        function a = horzcat(this,varargin)
            throwAsCaller(catException(class(this)));
        end
        
        function a = vertcat(this,varargin)
            throwAsCaller(catException(class(this)));
        end
        
        function a = repmat(this,varargin)
            throwAsCaller(catException(class(this)));
        end      
    end
    
end

function e = catException(class_name)
e = MException(message('images:color:catNotAllowed',class_name));
end

