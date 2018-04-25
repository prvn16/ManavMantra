function [metadata,dom] = readMetadata(id, componentDir)
metadata = struct;
metadata.id = id;

tokens = regexp(id,'(\w+)-(\w+)','tokens','once');
metadata.component = tokens{1};
metadata.filename = tokens{2};
metadata.componentDir = componentDir;
metadataFile = fullfile(metadata.componentDir,[metadata.filename '.xml']);

dom = xmlread(metadataFile);

% Main file
mainNode = dom.getElementsByTagName('main').item(0);
metadata.main = getChar(mainNode);
metadata.extension = char(mainNode.getAttribute('type'));
if isempty(metadata.extension)
    metadata.extension = 'm';
end

% Supporting files.
fileNodes = dom.getElementsByTagName('file');
files = cell(fileNodes.getLength(),1);
for i = 1:fileNodes.getLength()    
    fileNode = fileNodes.item(i-1);
    fileComponent = char(fileNode.getAttribute('component'));
    files{i,1} = struct( ...
        'filename', getChar(fileNode), ...
        'component', fileComponent, ...
        'componentDir', exampleUtils.componentExamplesDir(fileComponent), ...
        'timestamp', char(fileNode.getAttribute('timestamp')), ...
        'open', char(fileNode.getAttribute('open')));
end
metadata.files = files;

productNodes = dom.getElementsByTagName('product');
metadata.products = '';
products = [];
for i = 1:productNodes.getLength()
    productNode = productNodes.item(i-1);
    products{end+1} = getChar(productNode);
end
if ~isempty(products)
    metadata.products = strjoin(products, ',');
end

% Callback.
cb = getNodeValue(dom,'callback','char');
if ~isempty(cb)
    metadata.callback = cb;
end

% Sandbox-published
sp = getNodeValue(dom,'sandboxPublished','logical');
if ~isempty(sp)
    metadata.sandboxPublished = true;
end

% Hide code
hc = getNodeValue(dom,'hideCode','logical');
if ~isempty(hc)
    metadata.hideCode = true;
end

% Thumbnail
metadata.thumbnail = '';
tn = getNodeValue(dom,'thumbnail','char');
if ~isempty(tn)
    metadata.thumbnail = strrep(tn, 'html/', '');
end

end

function s = getNodeValue(dom,nodeName,nodeType)
s = [];
nodes = dom.getElementsByTagName(nodeName);
if nodes.getLength() ~= 1
    % TODO error?
    return;
else
    node = nodes.item(0);
    switch nodeType
        case 'char'
            s = getChar(node);
        case 'logical'
            % Don't actually check the node value, its presence indicates
            % the value was set.
            s = true;
    end
end
    
    
end

function s = getChar(n)
textNode = n.getFirstChild();
s = '';
if ~isempty(textNode)    
    s = char(textNode.getData);
end
end
