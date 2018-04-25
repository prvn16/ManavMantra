function J = grayto16(img) %#codegen
%GRAYTO16 Convert a single, double or uint8 image to uint16

% Copyright 2013-2014 The MathWorks, Inc.

if isempty(img)
    J = uint16(img);
    return
end

% we only deal with real inputs
if ~isreal(img)
    eml_warning('images:grayto16:ignoringImaginaryPartOfInput');
    I = real(img);
else
    I = img;
end

coder.extrinsic('images.internal.coder.useSharedLibrary');
useSharedLibrary = coder.const(images.internal.coder.useSharedLibrary()) ...
    && coder.internal.isTargetMATLABHost() ...
    && coder.const(~images.internal.coder.useSingleThread());

% initialize memory
J = coder.nullcopy(uint16(I));
numElems = numel(I);

if useSharedLibrary
    % PC Targets
    switch(class(I))
        case 'single'
            J = images.internal.coder.buildable.Grayto16Buildable.grayto16core_single( ...
                I,J,numElems);
        case 'double'
            J = images.internal.coder.buildable.Grayto16Buildable.grayto16core_double( ...
                I,J,numElems);
        case 'uint8'
            J = images.internal.coder.buildable.Grayto16Buildable.grayto16core_uint8( ...
                I,J,numElems);
        otherwise
            coder.internal.errorIf(true,'images:grayto16:invalidType');
    end
else
    % Non-PC Targets
    switch(class(I))
        case {'single','double'}
            maxVal = cast(65535,'like',I);
            for idx = 1:numElems
                val = I(idx);
                if isnan(val)
                    J(idx) = uint16(0);
                else
                    % clamp val between 0 and 1
                    % to avoid ConstantFoldingOverFlow warning
                    satMin = cast(0,'like',I);
                    satMax = cast(1,'like',I);
                    if val < satMin
                        val = satMin;
                    elseif val > satMax
                        val = satMax;
                    end
                    % safe to cast only if val is in [0,1]
                    J(idx) = castToUint16(val*maxVal + cast(0.5,'like',I));
                end
            end
        case 'uint8'
            J = uint16(I)*uint16(257);
        otherwise
            assert('Invalid input class')
    end
end

function out = castToUint16(in)
% C-style casting
coder.inline('always');
out = eml_cast(in,'uint16','floor');