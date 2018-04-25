function onDataSourceChanged(this)
%ONDATASOURCECHANGED React to DataSourceChanged events.

%   Copyright 2010-2017 The MathWorks, Inc.

if ~validateSource(this, this.Application.DataSource)
    % Reset visual if source is invalid.
    resetVisual(this);
    return;
end
resetDataOnSourceChange(this);
this.NewDataListener = addNewDataListener(this.Application, makeOnNewData(this));

%-------------------------------------------------------------------------
function cb = makeOnNewData(this)

cb = @(hSource) onNewData(this, hSource);

%---------------------------------------------------------------------------
function resetDataOnSourceChange(this)

if ~isempty(this.Application.source)
    prevSourcePath = [this.ConnectedSourceName '/' num2str(this.ConnectedSourcePort)];
    newSource = this.Application.source{1};
    if isempty(newSource); return; end
    newSourcePath = [newSource{1} '/' num2str(newSource{2})];
    % reset only if the source path is different.
    if ~strcmpi(prevSourcePath, newSourcePath)
        resetVisual(this);
        % Cache the new connection.
        this.ConnectedSourceName = newSource{1};
        this.ConnectedSourcePort = newSource{2};
    end
end

%-------------------------------------------------------------------------
% [EOF]
