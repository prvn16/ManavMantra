
%   Copyright 2014 The MathWorks, Inc.

classdef (Sealed) MasterInferenceManager < handle
    methods (Access = private)
        function obj = MasterInferenceManager
            obj.MasterInferenceObj = eml.MasterInferenceReport;
            obj.updateMasterInferenceReport();
            obj.MatlabIdCount = 0;
            obj.HoldMaster = false;
            obj.RemappingDisabled = false;
            obj.PassThroughMap = [];
            obj.LastMap = [];
            mlock; % Prevents clearing of the class from MATLAB.
        end
    end
    
    properties (GetAccess = ?fxptds.MATLABIdentifier, SetAccess = private)
        % It is faster to work with a native struct, and since this is
        % accessed many times we will have clients work with a struct
        % instead of the object.
        MasterInferenceReport;
    end
    
    
    properties (Access = ?fxptds.MATLABIdentifier, Dependent = true)
        CurrentMap;
    end
    
    properties (Access = private)
        MatlabIdCount;
        PassThroughMap;
        LastMap;
        HoldMaster;
        RemappingDisabled;
        MasterInferenceObj;
    end
    
    methods
        function value = get.CurrentMap(obj)
            if(obj.RemappingDisabled)
                value = obj.PassThroughMap;
            else
                value = obj.LastMap;
            end
        end  
    end
    
    methods (Access = ?fxptds.MATLABIdentifier)
                      
        function incrementIdCount(obj)
            obj.MatlabIdCount = obj.MatlabIdCount + 1;
        end
                        
        function masterInference = setCurrentInferenceReport(obj, inferenceReport, varargin)
            if ~isempty(varargin)
                obj.LastMap = obj.MasterInferenceObj.getInferenceReportMap(inferenceReport, varargin{1});
            else
                obj.LastMap = obj.MasterInferenceObj.getInferenceReportMap(inferenceReport);
            end
            obj.updateMasterInferenceReport();
            obj.PassThroughMap.Functions = (1:length(obj.MasterInferenceReport.Functions))';
            obj.PassThroughMap.Scripts = (1:length(obj.MasterInferenceReport.Scripts))';
            obj.PassThroughMap.MxInfos = (1:length(obj.MasterInferenceReport.MxInfos))';
            obj.PassThroughMap.MxArrays = (1:length(obj.MasterInferenceReport.MxArrays))';
            masterInference = obj.MasterInferenceReport;
        end
        
        function decrementIdCount(obj)
            obj.MatlabIdCount = obj.MatlabIdCount - 1;
            if(obj.MatlabIdCount == 0 && ~obj.HoldMaster)
                obj.MasterInferenceObj.clear;
                obj.updateMasterInferenceReport();
            end
        end
        
        function holdMasterInferenceReport(obj)
            obj.HoldMaster = true;
        end
        
        function releaseMasterInferenceReport(obj)
            obj.HoldMaster = false;
            if(obj.MatlabIdCount == 0)
                obj.MasterInferenceObj.clear;
                obj.updateMasterInferenceReport();
            end
        end
        
        function disableRemapping(obj)
            obj.RemappingDisabled = true;
            obj.MasterInferenceReport.CurrentMap = obj.CurrentMap;
        end
        
        function enableRemapping(obj)
            obj.RemappingDisabled = false;
            obj.MasterInferenceReport.CurrentMap = obj.CurrentMap;
        end
    end
    
    methods (Access = private)
        function updateMasterInferenceReport(obj)
            obj.MasterInferenceReport.RootFunctionIDs = obj.MasterInferenceObj.RootFunctionIDs;
            obj.MasterInferenceReport.Functions = obj.MasterInferenceObj.Functions;
            obj.MasterInferenceReport.Scripts = obj.MasterInferenceObj.Scripts;
            obj.MasterInferenceReport.MxInfos = obj.MasterInferenceObj.MxInfos;
            obj.MasterInferenceReport.MxArrays = obj.MasterInferenceObj.MxArrays;
            obj.MasterInferenceReport.CurrentMap = obj.CurrentMap;
        end
    end
    
    methods (Static, Access = ?fxptds.MATLABIdentifier)
        function singleObj = getInstance
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = fxptds.MasterInferenceManager;
            end
            singleObj = localObj;
        end
    end
end
