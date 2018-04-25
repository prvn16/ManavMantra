function [javaRichDocument, cleanupObj, browserObj] = open(fileName, reuse)
% OPEN - Opens a MATLAB Code file and returns a headless rich document

% If there is no resuse flag defined, then set the default to false
if nargin == 1
   reuse = false; 
end

import matlab.internal.liveeditor.LiveEditorUtilities
fileName = LiveEditorUtilities.resolveFileName(fileName);

jFile = java.io.File(fileName);
if ~exists(jFile)
    error('matlab:internal:liveeditor:open', 'The file "%s" must exist.', fileName);
end

% Make sure the connector is working
if ~connector.isRunning
	connector.ensureServiceOn();
end  

[javaRichDocument, cleanupObj, browserObj] = openUsingCEF(fileName, reuse);
end

function [javaRichDocument, cleanupObj, webWindow] = openUsingCEF(fileName, reuse)

% lock this function to prevent clear classes to clear the presisent variable
mlock

persistent reuseObjects
import matlab.internal.liveeditor.LiveEditorUtilities

% If reuse, then create and use the cached version
if reuse
     if isempty(reuseObjects)
        [reuseObjects.javaRichDocument, reuseObjects.webWindow] = LiveEditorUtilities.createDocument();
     end
     javaRichDocument = reuseObjects.javaRichDocument;
     webWindow = reuseObjects.webWindow;
     
     % Return an empty cleanup so that these objects are not destroyed
     cleanupObj = [];
else   
    [javaRichDocument, webWindow] = LiveEditorUtilities.createDocument();
    cleanupObj.javaRichDocumentCleanup = onCleanup(@() dispose(javaRichDocument));
    cleanupObj.webWindowCleanup = onCleanup(@() delete(webWindow));
end

file = java.io.File(fileName);

isMLX = com.mathworks.services.mlx.MlxFileUtils.isMlxFile(file.getAbsolutePath());

% Load the content
if isMLX
    opcPackage = com.mathworks.services.mlx.MlxFileUtils.read(file);
else
    opcPackage = com.mathworks.publishparser.PublishParser.convertMToRichScript(file);
end

content = com.mathworks.mde.liveeditor.widget.rtc.RichDocumentBackingStore.convertToMap(opcPackage);

% java heap errors occasionally occur without this hack
t = tic;
while getPercentHeapFree() < 10
    if toc(t) > 30
        error(['low free heap: ' num2str(getPercentHeapFree()) '%'])
    end
    java.lang.System.gc(); % ask java to free some memory
    pause(0.01) % process callbacks and yield this thread
end

javaRichDocument.setContent(content);    

end

function percentHeapFree = getPercentHeapFree()
    runtime = java.lang.Runtime.getRuntime();
    percentHeapFree = runtime.freeMemory() * 100 / runtime.totalMemory();
end
