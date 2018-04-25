function J = uint16toint16(I) %#codegen
%UINT16TOINT16 converts uint16 data (range = 0 to 65535) to int16
% data (range = -32768 to 32767).

% Copyright 2013-2014 The MathWorks, Inc.

coder.extrinsic('images.internal.coder.useSharedLibrary');
useSharedLibrary = coder.const(images.internal.coder.useSharedLibrary()) ...
    && coder.internal.isTargetMATLABHost() ...
    && coder.const(~images.internal.coder.useSingleThread());

% allocate memory
J = coder.nullcopy(int16(I));
numElems = numel(I);

switch(class(I))
    case 'uint16'
        if useSharedLibrary
            % PC Targets (Host)
            J = images.internal.coder.buildable.Uint16toint16Buildable.uint16toint16core( ...
                I,J,numElems);
        else
            % Non-PC Targets
            for idx = 1:numElems
                J(idx) = int16(int32(I(idx)) - int32(32768));
            end
        end
    otherwise
        coder.internal.errorIf(true,'images:uint16toint16:invalidType');
end