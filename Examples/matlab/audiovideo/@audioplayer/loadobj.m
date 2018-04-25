function obj = loadobj(B)
%LOADOBJ Load function for audioplayer objects.
%
%    OBJ = LOADOBJ(B) is called by LOAD when an audioplayer object is 
%    loaded from a .MAT file. The return value, OBJ, is subsequently 
%    used by LOAD to populate the workspace.  
%
%    LOADOBJ will be separately invoked for each object in the .MAT file.
%
%    See also AUDIOPLAYER/SAVEOBJ.

%    SM
%    Copyright 2003-2013 The MathWorks, Inc.


% If we're on UNIX and don't have Java, warn and return.

    if isfield(B, 'internalObj')
        savedObj = struct(B);
        props = savedObj.internalObj;
        signal = savedObj.signal;
        
        obj = audioplayer(signal, props.SampleRate, props.BitsPerSample, ...
            props.DeviceID);
        
        % Set the original settable property values.
        %propNames = fieldnames(set(obj));
        propNames = getSettableProperties(obj);
        
        for i = 1:length(propNames)
            try
                set(obj, propNames{i}, props.(propNames{i}));                
            catch %#ok<CTCH>
                warning(message('MATLAB:audiovideo:audioplayer:couldnotset', propNames{ i }));
            end
        end
    else
        B.initialize();
        obj = B;
    end
end