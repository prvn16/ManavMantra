function J = int16touint16(I) %#codegen
%INT16TOUINT16 converts int16 data (range = -32768 to 32767) to uint16
% data (range = 0 to 65535).

% Copyright 2013-2014 The MathWorks, Inc.

coder.extrinsic('images.internal.coder.useSharedLibrary');
useSharedLibrary = coder.const(images.internal.coder.useSharedLibrary()) ...
    && coder.internal.isTargetMATLABHost() ...
    && coder.const(~images.internal.coder.useSingleThread());

% allocate memory
J = coder.nullcopy(uint16(I));
numElems = numel(I);

switch(class(I))
    case 'int16'
        if useSharedLibrary
            % PC Targets (Host)
            J = images.internal.coder.buildable.Int16touint16Buildable.int16touint16core( ...
                I,J,numElems);
        else
            % Non-PC Targets
            for idx = 1:numElems
                J(idx) = uint16(int32(I(idx)) + int32(32768));
            end
        end
    otherwise
        coder.internal.errorIf(true,'images:int16touint16:invalidType');
end