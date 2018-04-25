function tablePanel = addtopanel(h,host)

% Copyright 2005-2017 The MathWorks, Inc.

import com.mathworks.toolbox.timeseries.*;
import javax.swing.*;
import com.mathworks.mwswing.*;

%% Createa parent panel. Parent figure passed as the first argument until
%% javacomponents can be parented directly to uipanels
[jPeer,tablePanel] =  javacomponent(h.ScrollPane,[0 0 1 1],ancestor(host,'figure'));

%% Don't show the table. Note the units must be pixels
set(tablePanel,'Parent',host,'Units','Pixels');