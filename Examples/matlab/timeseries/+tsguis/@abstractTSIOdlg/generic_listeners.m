function generic_listeners(h)

% Copyright 2004-2017 The MathWorks, Inc.


%% Dialog visibility listener
h.Listeners = [h.Listeners; ...
    event.proplistener(h,h.findprop('Visible'),'PostSet', ...
    @(es,ed) set(h.Figure,'Visible',get(h,'Visible')))];