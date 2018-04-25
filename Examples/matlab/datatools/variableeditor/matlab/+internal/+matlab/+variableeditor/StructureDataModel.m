classdef StructureDataModel < internal.matlab.variableeditor.ArrayDataModel & internal.matlab.variableeditor.EditableVariable
    %StructureDataModel 
    %   Structure Data Model

    % Copyright 2013-2014 The MathWorks, Inc.

    properties (Constant)
        NumberOfColumns = 4;
    end
    
    properties (Constant)
        % Type Property
        Type = 'Structure';
        
        ClassType = 'struct';
    end
    
    % Type
    properties (SetObservable=false, SetAccess='private', GetAccess='public', Dependent=false, Hidden=false)        
        CachedSize = [0 0]; %
    end %properties

    properties (SetObservable=true, SetAccess='public', GetAccess='public', Dependent=false, Hidden=true)
        % Data_I Property
        Data_I = struct();
    end %properties
    
    methods
        function storedValue = get.Data_I(this)
            storedValue = this.Data_I;
        end
        
        function set.Data_I(this, newValue)
            if ~isa(newValue,'struct') || length(size(newValue))~=2 || ...
                    size(newValue,1)~=1 || size(newValue,2)~=1
                error(message('MATLAB:codetools:variableeditor:NotAStructure'));
            end

            this.Data_I = newValue;
        end
    end

    % Data
    properties (SetObservable=true, SetAccess='public', GetAccess='public', Dependent=true, Hidden=false)
        % Data Property
        Data;
    end %properties
    
    methods
        function storedValue = get.Data(this)
            storedValue = this.Data_I;
        end
        
        function set.Data(this, newValue)
            this.Data_I = newValue;
            fn = fieldnames(this.Data_I);
            % Cache the size because calling fieldnames can be expensive
            % if there are lots of fields
            if isempty(fn)
                % Empty struct should still have the correct number of
                % columns
                this.CachedSize = [0, internal.matlab.variableeditor.StructureDataModel.NumberOfColumns];
            else
                this.CachedSize = [length(fieldnames(this.Data)) ...
                    internal.matlab.variableeditor.StructureDataModel.NumberOfColumns];
            end
        end
    end

    methods(Access='public')
        % getSize
        function s = getSize(this)
            s = this.CachedSize;
        end %getSize
        
    end %methods    
end

