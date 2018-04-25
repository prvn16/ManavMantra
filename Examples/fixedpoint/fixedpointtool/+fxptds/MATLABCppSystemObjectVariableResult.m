classdef MATLABCppSystemObjectVariableResult < fxptds.MATLABVariableResult
%MATLABCppSystemObjectVariableResult

% Copyright 2015-2016 The MathWorks, Inc.

    methods        
        function this = MATLABCppSystemObjectVariableResult(data)
            if nargin  == 0
                argList = {};
            else
                argList = {data};
            end
            this@fxptds.MATLABVariableResult(argList{:});
        end % MATLABCppSystemObjectVariableResult()

        function updateResultData(this, data)
             updateResultData@fxptds.MATLABVariableResult(this, data);
             if isfield(data,'SimMin')
                 % Overwrite CompiledDT & IsScaledDouble set by baseclass.
                 % Not all loggable C++ System objects have implemented
                 % getCompiledFixedPointInfo() yet, so data.CompiledDT may
                 % be empty for the ones that have not yet implemented this
                 % interface to get compiled data-types.
                 if ~isempty(data.CompiledDT)
                     if isscaleddouble(data.CompiledDT)
                         T = data.CompiledDT;
                         T.DataType = 'Fixed';
                         this.CompiledDT = tostring(T);
                         this.IsScaledDouble = true;
                     elseif isscaledtype(data.CompiledDT)
                         this.CompiledDT = tostring(data.CompiledDT);
                         this.IsScaledDouble = false;
                     else
                         % float
                         this.CompiledDT = data.CompiledDT.DataType;
                         this.IsScaledDouble = false;
                     end
                 else
                     this.CompiledDT = [];
                     this.IsScaledDouble = false;
                 end
                 % SpecifiedDT is always fixed-point type
                 this.SpecifiedDT = tostring(data.SpecifiedDT);
             end
        end % updateResultData
    end % methods

    methods(Hidden)
        function setSpecifiedDataType(this, datatype)
            setSpecifiedDataType@fxptds.AbstractResult(this, datatype)
        end

        function ovfAction = getOverflowMode(this)
            % Need to overload this as
            % MATLABCppSystemObjectVariableIdentifier class doesn't have a
            % fimath (while its baseclass has). Only OverflowAction &
            % RoundingMethod apply, which it stores.
            varID = this.getUniqueIdentifier;
            ovfAction = varID.OverflowAction;
        end
    end % methods(Hidden)
end