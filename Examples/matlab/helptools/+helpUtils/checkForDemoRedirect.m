function [redirect,mapfile,topic] = checkForDemoRedirect(html_file)
% Internal use only.

% This fuction helps map references to examples from the legacy location
% under toolbox, e.g. toolbox/matlab/demos/html/sparsity.html, to their new
% location under docroot, e.g. matlab/examples/sparse-matrices.html. It
% does this by figuring out which doc set a given toolbox folder 
% corresponds to and looking there for an anchor matching the filename.
% If one is found, it can open the page in the new location instead.

%   Copyright 2012-2017 The MathWorks, Inc.

% Defaults.
redirect = false;
mapfile = '';
topic = '';

% WEB called with no arguments?
if isempty(html_file)
    return
end

% Break up the full path, and standardize fileseps to "/".
[htmlDir,topic] = fileparts(fullfile(html_file));
htmlDir = canonicalizeFilesep(htmlDir);

% In an "html" directory?
if isempty(regexp(htmlDir,'/html$','once')) 
    return
end
    
% In foodemos (or foodemo for wavedemo) or examples or fooexamples?
if isempty(regexp(htmlDir,'demos?/','once')) && ...
   isempty(regexp(htmlDir,'examples/','once'))
    return
end

% Under matlab/toolbox? Check for entry in MAP file.
matlabToolbox = canonicalizeFilesep(fullfile(matlabroot,'toolbox'));
if strncmp(matlabToolbox,htmlDir,numel(matlabToolbox))
    relDir = strrep(htmlDir(numel(matlabToolbox)+2:end),'\','/');
    mapfile = findInMapFile(relDir,topic);
    if ~isempty(mapfile)
        redirect = true;
        return
    end
end

% Under toolbox elsewhere, i.e. support packages? Check for entry in index.
toolboxStr = '/toolbox/';
toolboxIndex = strfind(htmlDir,toolboxStr);
if ~isempty(toolboxIndex)
    relDir = htmlDir(toolboxIndex(end)+numel(toolboxStr):end);
    [~,mapfile] = mapToolboxDirToHelpDir(relDir);
    if ~isempty(get_location_for_shortname_and_topic(mapfile,topic))
        redirect = true;
        return
    end
end

end

%--------------------------------------------------------------------------
function mapfile = findInMapFile(relDir,topic)

% A corresponding map file?
[helpGroup,helpDir] = mapToolboxDirToHelpDir(relDir);
mapfile = fullfile(docroot,helpGroup,helpDir,'helptargets.map');
if numel(dir(mapfile)) ~= 1
    % MAP not found with the standard filename. Try non-standard filenames.
    switch helpDir
        case 'mpc'
            mapFilename = 'mpctool.map';
        otherwise
            mapFilename = [helpDir '.map'];
    end
    mapfile = fullfile(docroot,helpGroup,helpDir,mapFilename);
    if numel(dir(mapfile)) ~= 1
        % Still not found. Bail.
        mapfile = '';
        return
    end
end

% Contains topic?
topicMap = com.mathworks.mlwidgets.help.CSHelpTopicMap(mapfile);
if isempty(topicMap.mapID(topic))
    mapfile = '';
    return
end
end

%--------------------------------------------------------------------------
function [helpGroup,helpDir] = mapToolboxDirToHelpDir(relDir)

helpGroup = '';
dc = @(d)strncmp(relDir,[d '/'],numel(d)+1);
if dc('aero')
    helpDir = 'aerotbx';
elseif dc('shared/eda') || dc('shared/tlmgenerator') || dc('edalink')
    helpDir = 'hdlverifier';
elseif dc('shared/sdr/sdrplug/plutoradio_hspdef/plutoradiodemos')
    helpGroup = 'supportpkg';
    helpDir = 'plutoradio';
elseif dc('shared/sdr/sdrr')
    helpGroup = 'supportpkg';
    helpDir = 'rtlsdrradio';
elseif dc('shared/sdr/sdru')
    helpGroup = 'supportpkg';
    helpDir = 'usrpradio';
elseif dc('shared/sdr/sdrz/usrpe3xxdemos')
    helpGroup = 'supportpkg';
    helpDir = 'usrpembeddedseriesradio';
elseif dc('shared/sdr/sdrz')
    helpGroup = 'supportpkg';
    helpDir = 'xilinxzynqbasedradio';
elseif dc('globaloptim')
    helpDir = 'gads';
elseif  dc('dsp/supportpackages') || ...
        dc('hdlcoder/supportpackages') || ...
        dc('instrument/supportpackages') || ...
        dc('matlab/hardware/supportpackages') || ...
        dc('robotics/supportpackages') || ...
        dc('target/supportpackages')
    helpGroup = 'supportpkg';
    helpDir = regexp(relDir,'(?<=supportpackages\/)[^\/]+','match','once');
elseif dc('idelink') || dc('target')
    helpDir = 'rtw';
elseif dc('rfblks')
    helpDir = 'simrf';
elseif dc('simulink/fixedandfloat')
    helpDir = 'fixedpoint';
elseif dc('simulinktest')
    helpDir = 'sltest';
elseif dc('slde')
    helpDir = 'simevents';
elseif dc('physmod')
    helpGroup = 'physmod';
    helpDir = regexp(relDir,'(?<=/)[^\/]+','match','once');
    switch helpDir
        case 'sh'
            helpDir = 'hydro';
        case 'powersys'
            helpDir = 'sps';
        case 'pe'
            helpDir = 'sps';
        case 'mech'
            helpDir = 'sm';
    end
elseif dc('rtw/targets')
    helpDir = regexp(relDir,'(?<=targets\/)[^\/]+','match','once');
elseif dc('rptgenext/rptgenextdemos/slxmlcomp')
    helpDir = 'simulink';
else
    helpDir = regexp(relDir,'[^\/]+','match','once');
end
end

%--------------------------------------------------------------------------
function s = canonicalizeFilesep(s)
s = strrep(s,'\','/');
end

%--------------------------------------------------------------------------
% get_location_for_shortname_and_topic copied from HELPVIEW.
function help_path = get_location_for_shortname_and_topic(short_name, topic_id)
% Get the path from the search database using the short name and topic id.
try
    factory = com.mathworks.mlwidgets.help.MLHelpTopicUrlRetrieverFactory;
    retriever = factory.buildDocSetItemRetriever(short_name); 
    help_path = get_location_for_topic(retriever, topic_id);
catch
    help_path = '';
end
end

%--------------------------------------------------------------------------
% get_location_for_topic copied from HELPVIEW.
function help_path = get_location_for_topic(retriever, topic_id)
help_path = char(retriever.getLocationForTopic(topic_id));
end

