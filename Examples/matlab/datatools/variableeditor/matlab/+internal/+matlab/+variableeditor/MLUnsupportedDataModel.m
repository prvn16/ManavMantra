classdef MLUnsupportedDataModel < internal.matlab.variableeditor.DataModel & internal.matlab.variableeditor.NamedVariable & internal.matlab.variableeditor.MLNamedVariableObserver
    %MLUnsupportedDataModel 
    %   Abstract Unkown Data Model

    % Copyright 2013 The MathWorks, Inc.

    properties
        Data;
    end
    
    properties (Constant)
        % Type Property
        Type = 'Unsupported';
        
        % Class Type Property
        ClassType = 'unsupported';
    end
    
    methods(Access='public')
        % Constructor
        function this = MLUnsupportedDataModel(name, workspace)
            this@internal.matlab.variableeditor.MLNamedVariableObserver(name, workspace);
            this.Name = name;
        end
        
        % getData
        function varargout = getData(this,varargin)
           varargout{1} = this.Data;
        end

        % getSize
        function s = getSize(~)
            s = 1;
        end %getSize
        
        % updateData
        function data = updateData(this, varargin)
            data = varargin{1};
            
            %set the new data
            this.Data = data;
            
            eventdata = internal.matlab.variableeditor.DataChangeEventData;
            eventdata.Range = [];
            eventdata.Values = data;
            this.notify('DataChange',eventdata);                
        end
        
        %getType
        function type = getType(this)
            type = this.Type;
        end
        
        %getClassType
        function type = getClassType(this)
            type = this.ClassType;
        end
        
        function rhs = getRHS(~, ~)
            rhs='';
        end
        
        function data = variableChanged(this, varargin)
            data = this.updateData(varargin{:});
        end
        
        function [I,J]=doCompare(~, ~)
            I = [];
            J = [];
        end

        function lhs=getLHS(varargin)
            lhs = '';
        end
    end
end

