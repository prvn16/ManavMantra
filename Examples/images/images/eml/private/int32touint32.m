function u = int32touint32(img) %#codegen
% INT32TOUINT32(I) converts int32 data (range = -2147483648 to 2147483647) to uint32
% data (range = 0 to 4294967295).

% Copyright 2013-2014 The MathWorks, Inc.

coder.extrinsic('images.internal.coder.useSharedLibrary');
u = coder.nullcopy(uint32(img));
numElems = numel(img);

switch(class(img))
    case 'int32'
        if (coder.const(images.internal.coder.isCodegenForHost()) && ...
                coder.const(images.internal.coder.useSharedLibrary()))
            u = images.internal.coder.buildable.Int32touint32Buildable.int32touint32core( ...
                img, ...
                u, ...
                numElems);
            
        else % Non-PC Targets
            for idx = 1:numElems
                u(idx) = uint32(double(img(idx)) + 2147483648);
            end
        end
    otherwise
        coder.internal.errorIf(true,'images:int32touint32:invalidType');
end
