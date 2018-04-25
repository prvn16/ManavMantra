function executionTime = execute(javaRichDocument, fileName)
% execute - executes the rich document 

editorId = char(javaRichDocument.getUniqueKey);
uuid = char(java.util.UUID.randomUUID);

pollForReadyDocument(javaRichDocument);

regionDataFuture = com.mathworks.mde.embeddedoutputs.RegionsDataUtil.getRegionDataFuture(editorId);
regionDataList = regionDataFuture.get();

fullFileText = char(com.mathworks.services.mlx.MlxFileUtils.getCode(java.io.File(fileName)));

%Use existing mtree API to find the first function line
tree = com.mathworks.widgets.text.mcode.MTree.parse(fullFileText);
node = com.mathworks.widgets.text.mcode.MDocumentUtils.getFirstFunctionNode(tree);

if ~isempty(node)
    firstFunctionLineNumber = double(node.getStartLine());
else
    firstFunctionLineNumber = -1;
end

% Attach listeners to the figure manager to determine if all figures have been snapshoted
observer = matlab.internal.liveeditor.FigureManagerObserver();
figureManager = matlab.internal.editor.FigureManager.getInstance();

snapshotStartedListener = event.listener(figureManager,'FigureSnapshotStart',@(~,~) observer.increment());
cleanupListener(1) = onCleanup(@()delete(snapshotStartedListener));

snapshotEndedListener = event.listener(figureManager,'FigureSnapshotEnd',@(~,~) observer.decrement());
cleanupListener(2) = onCleanup(@()delete(snapshotEndedListener)); %#ok<NASGU>

startTime = tic;
matlab.internal.editor.EvaluationOutputsService.evalRegions(editorId, uuid, regionDataList, fullFileText, firstFunctionLineNumber, false, true, fileName, -1);
executionTime = toc(startTime);
cleanupObj = onCleanup(@() matlab.internal.editor.EvaluationOutputsService.cleanup(editorId));

% In 2 minutes, change the status to true so we get out of the waitfor
% We are using a timer object to update the staus of the observer to true so that it doesn't wait forever
timerFcn = @(~,~)(stopObserver(observer));
timerObj = timer('StartDelay', 2*60, 'TimerFcn', timerFcn ,'ExecutionMode', 'singleShot');
cleanObj = onCleanup(@()delete(timerObj));

% Wait for all figures to have been snapshoted 
start(timerObj);
if observer.FiguresOnServer > 0
    waitfor(observer, 'Status', true)
end

% Timer could have been cleaned up by some user code (e.g. timerfind)
if isvalid(timerObj)
    stop(timerObj);
end

% Throw an error if it timed out and there are figures that haven't been snapshotted
if observer.FiguresOnServer > 0
    error('matlab:internal:liveeditor:execute', 'The %i figure(s) did not finish snapshoting on the server.', observer.FiguresOnServer);
end

end

function stopObserver(observer)
    % Update the observer status
    observer.Status = true;
end

function pollForReadyDocument(javaDocument)
    %Poll for 20 seconds.
    for i = 1:20
        if javaDocument.isReady
            return;
        end
        pause(1);
    end
    error('Timeout error when loading document.');
end
