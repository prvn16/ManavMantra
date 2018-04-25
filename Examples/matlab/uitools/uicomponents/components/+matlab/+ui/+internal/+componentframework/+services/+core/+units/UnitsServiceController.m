classdef UnitsServiceController
    methods ( Static )
        
        
        % Methods for SERVER --> CLIENT communications
        
        % Returns ValueInUnitsMin
        %   ScreenResolution (MATLAB, not device)
        %   Units
        %   Value
        function valInUnitsStruct = getUnitsValueDataForView(objModel, propName)
			unitsService = objModel.getUnitsService();
			valInUnitsStruct = unitsService.getUnitsValueForView(propName);
        end
        
        function units = getUnits(valInUnitsStruct)
            units = valInUnitsStruct.Units;
        end
        
        function valInUnits = getValue(valInUnitsStruct)
            valInUnits = valInUnitsStruct.Value;
        end
        
        function newValInUnitsStruct = setValueInUnitsValueDataForView(valInUnitsStruct, newVal)
            newValInUnitsStruct = valInUnitsStruct;
            newValInUnitsStruct.Value = newVal;
        end
        
        
        % Methods for SERVER <-- CLIENT communications
        
        function value = getValueFromUnitsServiceClientEventData(evtStructure, propName)
            eventData = evtStructure.valuesInUnits;
            value = eventData.(propName).Value;
        end
       
        function value = getUnitsFromUnitsServiceClientEventData(evtStructure, propName)
            eventData = evtStructure.valuesInUnits;
            value = eventData.(propName).Units;
        end
        
    end
end