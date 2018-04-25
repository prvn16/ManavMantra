function tf = isLicensed(product)
    if strcmpi(product, 'matlab')
        tf = 1;
    else
        tf = license('test', product);
    end
end
