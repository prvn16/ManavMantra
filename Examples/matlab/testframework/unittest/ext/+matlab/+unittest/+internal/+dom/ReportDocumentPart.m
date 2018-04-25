classdef ReportDocumentPart < handle & matlab.mixin.Heterogeneous
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(GetAccess={?matlab.unittest.internal.dom.ReportDocumentPart,...
            ?matlab.unittest.internal.dom.ReportDocument},...
            SetAccess=private)
        DelegateDocumentPart = [];
        HasBeenFilled = false;
    end
    
    properties(Dependent,GetAccess={?matlab.unittest.internal.dom.ReportDocumentPart,...
            ?matlab.unittest.internal.dom.ReportDocument},...
            SetAccess=private)
        HasBeenSetup
    end
    
    methods(Abstract,Access=protected)
        delegateDocPart = createDelegateDocumentPart(docPart,reportData)
    end
    
    methods(Access=protected)
        function setupPart(docPart,reportData) %#ok<INUSD>
            %Can be overridden by subclasses
        end
        
        function teardownPart(docPart) %#ok<MANU>
            %Can be overridden by subclasses
        end
        
        function bool = isApplicablePart(docPart) %#ok<MANU>
            %Can be overridden by subclasses
            bool = true;
        end
    end
    
    methods
        function bool = get.HasBeenSetup(docPart)
            bool = ~isempty(docPart.DelegateDocumentPart);
        end
    end
    
    methods(Sealed)
        function setup(docParts,reportData)
            for docPart = docParts
                if ~docPart.HasBeenSetup
                    docPart.setupPart(reportData);
                    docPart.DelegateDocumentPart = docPart.createDelegateDocumentPart(reportData);
                    assert(isa(docPart.DelegateDocumentPart,'mlreportgen.dom.DocumentPart')); %Internal validation
                    docPart.HasBeenFilled = false;
                end
            end
        end
        
        function teardown(docParts)
            for docPart = docParts
                if docPart.HasBeenSetup
                    docPart.DelegateDocumentPart = [];
                    docPart.teardownPart();
                end
            end
        end
        
        function fill(docParts)
            canBeFilled = all([docParts.HasBeenSetup] & ~[docParts.HasBeenFilled]);
            assert(canBeFilled); %Internal validation
            
            for docPart = docParts
                delegateDocPart = docPart.DelegateDocumentPart;
                keepOpenEnvironment = docPart.openDelegateDocumentPart();
                
                delegateDocPart.moveToNextHole();
                while ~strcmp(delegateDocPart.CurrentHoleId,'#end#')
                    fillHole = str2func(['fill' delegateDocPart.CurrentHoleId]);
                    fillHole(docPart);
                    delegateDocPart.moveToNextHole();
                end
                
                delete(keepOpenEnvironment);
                docPart.HasBeenFilled = true;
            end
        end
        
        function mask = isApplicable(docParts)
            mask = arrayfun(@isApplicablePart,docParts);
        end
    end
    
    methods(Sealed,Access=protected)
        function append(docPart,otherDocParts)
            canAppend = isscalar(docPart) && docPart.HasBeenSetup;
            assert(canAppend); %Internal validation
            
            if isa(otherDocParts,'matlab.unittest.internal.dom.ReportDocumentPart')
                docPart.appendReportDocumentParts(otherDocParts);
            else
                docPart.DelegateDocumentPart.append(otherDocParts);
            end
        end
        
        function appendIfApplicable(docPart,otherDocParts)
            canAppend = isscalar(docPart) && docPart.HasBeenSetup;
            assert(canAppend); %Internal validation
            
            mask = otherDocParts.isApplicable();
            docPart.appendReportDocumentParts(otherDocParts(mask));
            otherDocParts(~mask).teardown(); %To keep a low memory footprint
        end
    end
    
    methods(Sealed,Hidden,Access=protected)
        function appendUnmodifiedText(docPart,txt)
            docPart.appendTextWithSpecifiedWhitespace(txt,'preserve');
        end
        
        function appendPreText(docPart,txt)
            if strcmpi(docPart.DelegateDocumentPart.Type,'html')
                docPart.appendTextWithSpecifiedWhitespace(txt,'pre');
            else
                docPart.appendTextWithSpecifiedWhitespace(txt,'preserve');
            end
        end
    end
    
    methods(Sealed, Access=private)
        function appendTextWithSpecifiedWhitespace(docPart,txt,whiteSpace)
            import mlreportgen.dom.Text;
            assert(isscalar(docPart)); %Internal validation
            validateattributes(txt,{'char'},{});
            txt = removeIllegalCharacters(txt);
            txtObj = Text(txt);
            txtObj.WhiteSpace = whiteSpace;
            docPart.append(txtObj);
        end
        
        function appendReportDocumentParts(docPart,otherDocParts)
            assert(all([otherDocParts.HasBeenSetup])); %Internal validation
            
            for otherDocPart = otherDocParts
                if ~otherDocPart.HasBeenFilled
                    otherDocPart.fill();
                end
                docPart.DelegateDocumentPart.append(otherDocPart.DelegateDocumentPart);
                otherDocPart.teardown(); %To keep a low memory footprint
            end
        end
        
        function keepOpenEnvironment = openDelegateDocumentPart(docPart)
            openSuccess = docPart.DelegateDocumentPart.open();
            assert(openSuccess); %Internal validation
            keepOpenEnvironment = onCleanup(@() docPart.closeDelegateDocumentPart());
        end
        
        function closeDelegateDocumentPart(docPart)
            closeSuccess = docPart.DelegateDocumentPart.close();
            assert(closeSuccess); %Internal validation
        end
    end
end

function txt = removeIllegalCharacters(txt)
indsToRemove = ...
    (txt < 9) | ...
    (10 < txt & txt < 13) | ...
    (13 < txt & txt < 32) | ...
    (55295 < txt & txt < 57344) | ...
    (65533 < txt & txt < 65536) | ...
    (114111 < txt);
txt(indsToRemove) = [];
end

% LocalWords:  mlreportgen dom unittest
