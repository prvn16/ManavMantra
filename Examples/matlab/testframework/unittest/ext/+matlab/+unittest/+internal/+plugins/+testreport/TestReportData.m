classdef TestReportData < matlab.unittest.internal.dom.ReportData & handle
    %This class is undocumented and may change in a future release.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        TestSessionData
    end
    
    properties(Dependent, SetAccess=immutable)
        TemporaryFilesFolder
        LinkTargetGenerator
        TemplateLibrary
    end
    
    properties(Access=private)
        InternalLinkTargetGenerator
        InternalTemporaryFolderFixture
        InternalTemplateLibrary
    end
    
    properties(Constant,Access=private)
        IconsFolder = fullfile(...
            matlab.unittest.internal.plugins.testreport.LicensedTemplateLibrary.TemplateRootFolder, ...
            'icons');
    end
    
    methods
        function testReportData = TestReportData(documentType, testSessionData)
            validateattributes(testSessionData,{'matlab.unittest.internal.TestSessionData'},{'scalar'});
            
            testReportData = testReportData@matlab.unittest.internal.dom.ReportData(documentType);
            
            testReportData.TestSessionData = testSessionData;
        end
        
        function value = get.TemporaryFilesFolder(testReportData)
            import matlab.unittest.fixtures.TemporaryFolderFixture;
            if isempty(testReportData.InternalTemporaryFolderFixture)
                testReportData.InternalTemporaryFolderFixture = TemporaryFolderFixture();
                testReportData.InternalTemporaryFolderFixture.setup();
            end
            value = testReportData.InternalTemporaryFolderFixture.Folder;
        end
        
        function value = get.LinkTargetGenerator(testReportData)
            if isempty(testReportData.InternalLinkTargetGenerator)
                testReportData.InternalLinkTargetGenerator = ...
                    matlab.unittest.internal.plugins.testreport.LinkTargetGenerator();
            end
            value = testReportData.InternalLinkTargetGenerator;
        end
        
        function value = get.TemplateLibrary(testReportData)
            import matlab.unittest.internal.plugins.testreport.LicensedTemplateLibrary;
            if isempty(testReportData.InternalTemplateLibrary)
                testReportData.InternalTemplateLibrary = LicensedTemplateLibrary(...
                    testReportData.DocumentType);
                testReportData.InternalTemplateLibrary.licensedOpen();
            end
            value = testReportData.InternalTemplateLibrary;
        end
        
        function delete(testReportData)
            if ~isempty(testReportData.InternalTemporaryFolderFixture)
                testReportData.InternalTemporaryFolderFixture.teardown();
            end
            if ~isempty(testReportData.InternalTemplateLibrary)
                testReportData.InternalTemplateLibrary.close();
            end
        end
    end
    
    methods(Hidden)
        function delegatePart = createDelegateDocumentPartFromName(testReportData,templateName)
            delegatePart = mlreportgen.dom.DocumentPart(testReportData.TemplateLibrary,templateName);
        end
        
        function iconFile = resultToIconFile(testReportData,result)
            if result.Passed
                iconName = 'passed';
            elseif result.FatalAssertionFailed
                iconName = 'killed';
            elseif result.Failed
                iconName = 'failed';
            elseif result.AssumptionFailed
                iconName = 'filtered';
            else
                iconName = 'unreached';
            end
            iconFile = testReportData.getIconFile(iconName);
        end
        
        function iconFile = getIconFile(testReportData,iconName)
            if testReportData.DocumentTypeIsDOCX
                iconExt = '.png';
            else
                iconExt = '.svg';
            end
            iconFile = fullfile(testReportData.IconsFolder,[iconName iconExt]);
        end
    end
end

% LocalWords:  unittest svg
