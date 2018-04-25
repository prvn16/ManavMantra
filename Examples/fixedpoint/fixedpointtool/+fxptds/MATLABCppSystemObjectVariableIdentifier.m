classdef MATLABCppSystemObjectVariableIdentifier < fxptds.MATLABVariableIdentifier
%MATLABCppSystemObjectVariableIdentifier

% Copyright 2015-2016 The MathWorks, Inc.

    properties(SetAccess = protected)
        RoundingMethod
        OverflowAction
    end % properties

    methods
        function obj = MATLABCppSystemObjectVariableIdentifier(...
                MATLABFunctionIdentifier,...
                MATLABExpressionIdentifiers,...
                VariableName,...
                MxInfoID,...
                InstanceCount,...
                NumberOfInstances,...
                textLength)
            
            if nargin==0
                Args = {};
            else 
                Args = {
                MATLABFunctionIdentifier
                MATLABExpressionIdentifiers
                VariableName
                MxInfoID
                InstanceCount
                NumberOfInstances
                textLength};
            end
            obj@fxptds.MATLABVariableIdentifier(Args{:});
            if nargin == 0
                return;
            end
            
            % Overwrite some of the baseclass properties            
            obj.ResultConstructor = @fxptds.MATLABCppSystemObjectVariableResult; 
            % A C++ System object does not have a fimath
            obj.FiMath = [];
            % derive & store properties 
            % This Identifier object represents a logged fixed-point
            % property of a C++ System object, and naturally, obj.MxInfoID
            % is the MxInfoID of this property. We want the MxInfoID of the
            % System object. The MATLABExpressionIdentifiers correspond to
            % the System object constructor & usage, so thats the MxInfoID
            % we want here.
            sysObjMxInfoID = MATLABExpressionIdentifiers(1).MxInfoID;
            sysObjMxInfo = obj.MasterInferenceReport.MxInfos{sysObjMxInfoID};
            sysObjPropNames = {sysObjMxInfo.ClassProperties(:).PropertyName};
            % find the value of RoundingMethod property
            idx = strcmpi(sysObjPropNames,'RoundingMethod');
            rmPropInfo = sysObjMxInfo.ClassProperties(idx);
            obj.RoundingMethod = obj.MasterInferenceReport.MxArrays{rmPropInfo.MxValueID};
            % find the value of OverflowAction property
            idx = strcmpi(sysObjPropNames,'OverflowAction');
            oaPropInfo = sysObjMxInfo.ClassProperties(idx);
            obj.OverflowAction = obj.MasterInferenceReport.MxArrays{oaPropInfo.MxValueID};
            % Base class property, but needs to be calculated last because
            % it depends on the other properties of the class.
            % obj.UniqueKey = obj.calcUniqueKey;
        end % MATLABCppSystemObjectVariableIdentifier
        
    end % public methods
    
    methods(Access=protected)
        
        function key = calcUniqueKey(obj)
            % C++ System object properties need their own unique key. The
            % properties of System objects store numerictype objects. Its
            % possible that properties of two different System objects have
            % the same numerictype value, in which case they would have the
            % same MxInfoId. And if the System object variable names are
            % the same, the unique key computed by MATLABVariableIdentifier
            % class would end up being same. G1200933 was caused because of
            % this. The unique key of the properties need to encode some
            % information related to the System object. System object's
            % constructor call location (TextStart) is unique for each
            % System object - so, use it in the unique key. 
            % To build upon calcUniqueKey@fxptds.MATLABVariableIdentifier,
            % call it first and add TextStart at the end.
            key = calcUniqueKey@fxptds.MATLABVariableIdentifier(obj);
            key = sprintf('%s|%i',...
                key,...
                obj.TextStart(1));
        end % calcUniqueKey
        
    end % methods(Access=protected)

    methods(Hidden)
        
        function b = isStruct(~)
            % returns true if the variable identifier is contained within a
            % struct. 
            b = false;
        end
    end
end
