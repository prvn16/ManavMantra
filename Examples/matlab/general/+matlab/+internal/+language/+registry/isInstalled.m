function tf = isInstalled(product, docPath)
    if strcmpi(product, 'matlab')
        tf = true;
    elseif nargin < 2
        tf = doesMatlabFind(product);
    else
        tf = doesDocExist(docPath) || doesMatlabFind(product);
    end
end

function tf = doesDocExist(docPath)
    tf = exist(fullfile(docroot, docPath), 'file');
end

function tf = doesMatlabFind(product)
    persistent installedProducts;
    if isempty(installedProducts)
        if usejava('jvm')
            javaArr = com.mathworks.install.InstalledProductFactory.getInstalledProducts(matlabroot);
            if javaArr.size > 0
                installedProducts = strings(javaArr.size, 1);
                for idx = 1:javaArr.size
                    installedProducts(idx) = char(javaArr.get(idx-1).getName);
                end
            else
                installedProducts = getVerProducts;
            end
        else
            installedProducts = getVerProducts;
        end
    end
    tf = any(installedProducts == product);
end

function products = getVerProducts
    v = ver;
    products = string({v.Name})';
end
