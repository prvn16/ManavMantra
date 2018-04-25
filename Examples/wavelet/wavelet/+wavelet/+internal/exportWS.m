function exportFlag = exportWS(currentSignalName,dataToExport)

% Find variables in workspace
S = evalin('base','whos');
% Check for unique names in workspace
varnames = cell(numel(S),1);
for ii = 1:numel(S)
    varnames{ii} = S(ii).name;
end

tf = strcmpi(varnames,currentSignalName);

if any(tf)
    response = questdlg(getString(message('Wavelet:SignalDenoiserApp:OverWriteWSVar',currentSignalName)),...
        getString(message('Wavelet:SignalDenoiserApp:ToolGroup')), ...
        getString(message('Wavelet:SignalDenoiserApp:OK')),...
        getString(message('Wavelet:SignalDenoiserApp:Cancel')),...
        getString(message('Wavelet:SignalDenoiserApp:Cancel')));
    if strcmpi(response,getString(message('Wavelet:SignalDenoiserApp:Cancel')))
        exportFlag = false;
        return;
    elseif strcmpi(response,getString(message('Wavelet:SignalDenoiserApp:OK')))
        exportFlag = true;
        assignin('base',currentSignalName,dataToExport);
    end
    
else
    exportFlag = true;
    assignin('base',currentSignalName,dataToExport);
end

