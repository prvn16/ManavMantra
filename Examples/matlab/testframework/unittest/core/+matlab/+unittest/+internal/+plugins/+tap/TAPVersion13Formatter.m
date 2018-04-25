classdef TAPVersion13Formatter < matlab.unittest.internal.eventrecords.EventRecordFormatter & ...
        matlab.unittest.internal.diagnostics.ErrorReportingMixin
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016 The MathWorks, Inc.
    properties(Access=private, Constant)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TAPVersion13YAMLDiagnostic');
    end
    
    methods
        function str = getFormattedExceptionReport(formatter, eventRecord)
            exceptionReport = formatter.getExceptionReport(eventRecord.Exception);
            parts = [createLineText({'ErrorIdentifierHeader'},eventRecord.Exception.identifier),...
                createFormattableSectionString({'ErrorReportHeader'},exceptionReport),...
                getDiagResultParts(eventRecord.FormattableAdditionalDiagnosticResults,'AdditionalDiagnosticHeader')];
            str = createFormattableYAMLBlockString(parts,eventRecord);
        end
        
        function str = getFormattedLoggedReport(~, eventRecord)
            parts = getDiagResultParts(eventRecord.FormattableDiagnosticResults,'LoggedDiagnosticHeader');
            str = createFormattableYAMLBlockString(parts, eventRecord);
        end
        
        function str = getFormattedQualificationReport(~, eventRecord)
            parts = [getDiagResultParts(eventRecord.FormattableTestDiagnosticResults,'TestDiagnosticHeader'),...
                getDiagResultParts(eventRecord.FormattableFrameworkDiagnosticResults,'FrameworkDiagnosticHeader'),...
                getDiagResultParts(eventRecord.FormattableAdditionalDiagnosticResults,'AdditionalDiagnosticHeader')];
            str = createFormattableYAMLBlockString(parts, eventRecord);
        end
    end
end

function txt = getCatalogText(varargin)
catalog = matlab.unittest.internal.plugins.tap.TAPVersion13Formatter.Catalog;
txt = catalog.getString(varargin{:});
end

function txt = createLineText(labelMsgArgs,bodyTxt)
txt = sprintf('%s ''%s''',getCatalogText(labelMsgArgs{:}),bodyTxt);
end

function str = createFormattableSectionString(labelMsgArgs,formattableBodyStr)
str = sprintf('%s |\n%s',getCatalogText(labelMsgArgs{:}),indent(formattableBodyStr));
end

function resultParts = getDiagResultParts(formattableResults,headerMsgKey)
import matlab.unittest.internal.diagnostics.FormattableString;
formattableDiagStrings = formattableResults.toFormattableStrings();

%Remove results that have empty text
emptyTextMask = string([formattableDiagStrings.Text]) == "";
formattableDiagStrings(emptyTextMask) = [];

numDiagResults = numel(formattableDiagStrings);
if numDiagResults == 1
    getHeaderMsgArgs = @(k) {headerMsgKey};
else
    getHeaderMsgArgs = @(k) {['Numbered' headerMsgKey], k};
end
resultParts = arrayfun(@(k) createFormattableSectionString(getHeaderMsgArgs(k),...
    formattableDiagStrings(k)),1:numDiagResults,'UniformOutput',false);
resultParts = [FormattableString.empty, resultParts{:}];
end

function str = createFormattableYAMLBlockString(parts, eventRecord)
import matlab.unittest.internal.diagnostics.createStackInfo;
parts = [createLineText({'EventNameLabel'}, eventRecord.EventName),...
    createLineText({'EventLocationLabel'}, eventRecord.EventLocation),parts];
if ~isempty(eventRecord.Stack)
    parts(end+1) = createFormattableSectionString({'StackHeader'},createStackInfo(eventRecord.Stack));
end
str = join(parts, newline);
end

% LocalWords:  YAML formatter Formattable