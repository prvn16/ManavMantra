function u = int8touint8(img) %#codegen
% INT8TOUINT8(I) converts int8 data (range = -128 to 127) to uint8
% data (range = 0 to 255).

% Copyright 2013-2014 The MathWorks, Inc.

coder.extrinsic('images.internal.coder.useSharedLibrary');
u = coder.nullcopy(uint8(img));
numElems = numel(img);

switch(class(img))
    case 'int8'
        if (images.internal.coder.isCodegenForHost() && ...
                coder.const(images.internal.coder.useSharedLibrary()))
            u = images.internal.coder.buildable.Int8touint8Buildable.int8touint8core( ...
                img, ...
                u, ...
                numElems);
            
        else % Non-PC Targets
            for idx = 1:numElems
                u(idx) = uint8(int16(img(idx)) + 128);
            end
        end
    otherwise
        coder.internal.errorIf(true,'images:int8touint8:invalidType');
end