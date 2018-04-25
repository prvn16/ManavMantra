function u = grayto8(I) %#codegen
% Copyright 2013-2014 The MathWorks, Inc.

if(~isreal(I))
    eml_warning('images:grayto8:ignoringImaginaryPartOfInput');
    img = real(I);
else
    img = I;
end

                
u = coder.nullcopy(uint8(img));
numElems = numel(img);

if(isa(img,'single') || isa(img,'double') || isa(img,'uint16'))
    ctype = images.internal.coder.getCtype(img);
    fcnName = ['grayto8_', ctype];

    u = images.internal.coder.buildable.Grayto8Buildable.grayto8core( ...
                fcnName, ...
                img, ...
                u, ...
                numElems);
else
    coder.internal.errorIf(true,'images:grayto8:invalidType');
end
