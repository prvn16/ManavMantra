function funcInfo = findUnlicensedFunctions(funcName)
    funcInfo = cell2struct(cell(2,0), {'NumProducts', 'ProductLinks'});
    try
        firstLetter = extractBefore(funcName, 2);
        if upper(firstLetter) == firstLetter
            % Do not make suggestions for capitalized names, since they are
            % likely properties.
            return;
        end
        
        lines = {};

        unlicensed = getFunctionData(funcName);
        unlicensed = addBaseCode(unlicensed);
        if ~isempty(unlicensed)
            lines = arrayfun(@(func)genProductLinks(funcName, func.prodName, func.baseCode), unlicensed, 'UniformOutput', false);
        end
        
        disabled = matlab.internal.language.introspective.findDisabledAddons(funcName);
        if ~isempty(disabled)
            lines = [lines, arrayfun(@genEnableLinks, disabled, 'UniformOutput', false)];
        end
        
        if ~isempty(lines)
            funcInfo(1).NumProducts = numel(lines);
            funcInfo(1).ProductLinks = [newline, strjoin(lines, newline)];
        end
    catch
    end
end

function funcData = getFunctionData(funcName)
    funcData = [];
    if usejava('jvm')
        registryDir = fullfile(fileparts(mfilename('fullpath')), computer('arch'));
        registry = com.mathworks.mlwidgets.help.functionregistry.UnlicensedFunctionRegistry(registryDir);
        funcs = registry.find(funcName);
        funcData = arrayfun(@(f)struct('prodName', char(f.getProductName), 'helpPath', char(f.getHelpPath)), funcs);
        if ~isempty(funcData)
            [~, ia] = unique({funcData.prodName});
            funcData = funcData(ia);
        end
    end
end

function funcData = addBaseCode(funcData)
    for idx = 1:numel(funcData)
        funcData(idx).baseCode = getProductBaseCode(funcData(idx));
        if isempty(funcData(idx).baseCode)
            % If the function is found in any product already
            % installed and licensed, erase all function data.
            funcData = [];
            break;
        end
    end
end

function baseCode = getProductBaseCode(product)
    productIdentifier = com.mathworks.product.util.ProductIdentifier.get(product.prodName);
    if isempty(productIdentifier)
        baseCode = '';
    elseif matlab.internal.language.registry.isLicensed(char(productIdentifier.getFlexName)) ...
        && matlab.internal.language.registry.isInstalled(product.prodName, product.helpPath)
        baseCode = '';
    else
        baseCode = char(productIdentifier.getBaseCode);
    end
end

function productLink = genProductLinks(funcName, product, baseCode)
    INDENT = '  ';
    if matlab.internal.display.isHot
        productUrl = sprintf('matlab:matlab.internal.language.introspective.showAddon(''%s'', ''%s'');', baseCode, funcName);
        productLink = [INDENT, '<a href="', productUrl, '">', product, '</a>'];
    else
        productLink = [INDENT, product];
    end
end
function enableLink = genEnableLinks(addon)
    INDENT = '  ';
    if matlab.internal.display.isHot
        enableURL = sprintf('matlab:matlab.internal.language.introspective.enableAddon(''%s'');', addon.addonUID);
        enableLink = [INDENT, '<a href="', enableURL, '">', addon.addonName, '</a>'];
    else
        enableLink = [INDENT, addon.addonName];
    end
end
