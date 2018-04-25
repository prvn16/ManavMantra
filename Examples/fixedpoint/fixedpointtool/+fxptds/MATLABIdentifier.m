
%   Copyright 2014 The MathWorks, Inc.

classdef MATLABIdentifier < fxptds.AbstractIdentifier
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Dependent = true, SetAccess = private)
        MasterInferenceReport        
    end
   
    properties(Dependent = true, GetAccess = protected)
        MasterInferenceManager
    end

    properties(SetAccess = protected)
        ResultConstructor
    end
    
    methods(Abstract)
        newId = getIdWithNewSID(this, newSID);
    end
    
    methods
        function value = get.MasterInferenceReport(obj)
            value = obj.MasterInferenceManager.MasterInferenceReport;
        end
        
        function value = get.MasterInferenceManager(~)
            value = fxptds.MasterInferenceManager.getInstance;
        end

        function obj = MATLABIdentifier()
            obj.MasterInferenceManager.incrementIdCount;
        end
        
        function delete(obj)
            obj.MasterInferenceManager.decrementIdCount;
        end
    end
    
    
    methods
        function restoreObj(this)     
            % TODO: to be implemented for import/export
            % base class abstract class implementation: place holder to
            % submit other type of blocks
        end 
    end
    methods(Access = protected)
        function obj = copyElement(this)
            % TODO: to be implemented for import/export
            % base class abstract class implementation: place holder to
            % submit other type of blocks
        end 
    end
    methods (Static)
        function masterInference = setCurrentInferenceReport(inferenceReport, varargin)
            masterInferenceManager = fxptds.MasterInferenceManager.getInstance;
            masterInference = masterInferenceManager.setCurrentInferenceReport(...
                inferenceReport, varargin{:});           
        end
        
        function holdMasterInferenceReport()
            masterInferenceManager = fxptds.MasterInferenceManager.getInstance;
            masterInferenceManager.holdMasterInferenceReport;           
        end
        
        function releaseMasterInferenceReport()
            masterInferenceManager = fxptds.MasterInferenceManager.getInstance;
            masterInferenceManager.releaseMasterInferenceReport;          
        end        
        
        function obj = loadobj(obj)
            masterInferenceManager = fxptds.MasterInferenceManager.getInstance;
            masterInferenceManager.incrementIdCount;         
        end        
    end % methods (Static)
    
end

