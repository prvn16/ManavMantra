function recordSignals(this)
% RECORDSIGNALS Enables recording of signals from SDI.

% Copyright 2015-2017 The MathWorks, Inc.

    % Disable the UI when simulation begins
    msg = 'EngineSimulationStart';
    % Before continuining, verify that that the SimStartPublishChannel
    % attribute has been defined so message.publish does not issue a
    % warning. From g1660978.
    waitfor(this, 'isReadyPostCallback', true);
    message.publish(this.SimStartPublishChannel, msg);

    sdiEngine = Simulink.sdi.Instance.engine();
    if ~Simulink.sdi.Instance.record
        this.InitSDIRecordState = 'off';
        sdiEngine.record;
    end
end
