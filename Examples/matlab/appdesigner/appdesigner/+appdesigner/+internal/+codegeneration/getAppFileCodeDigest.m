function hash = getAppFileCodeDigest(filePath)
    % reads app code from a mlapp file specified by filePath which is the 
    % full file path to a mlapp file and converts into a hash

    % Copyright 2017 The MathWorks, Inc.

    try
        code = appdesigner.internal.codegeneration.getAppFileCode(filePath);
        % append a prefix to make the hash the same as the client
        msg = ['string:', num2str(length(code)), ':', code];
        digestEngine = java.security.MessageDigest.getInstance('SHA1');
        digestEngine.update(java.lang.String(msg).getBytes('UTF-8'));
        hash = sprintf('%.2x', double(typecast(digestEngine.digest()','uint8')));
    catch
        hash = '';
    end
end