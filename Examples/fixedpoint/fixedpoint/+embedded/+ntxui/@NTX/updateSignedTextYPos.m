function updateSignedTextYPos(ntx)
% Adjust position of "signed" text, numerictype title,
% and "no histogram" message
%
% Do NOT adjust width, since "Unsigned" is longer than "Signed"
% and will clip until resize

%   Copyright 2010 The MathWorks, Inc.

% Use off screen text to assess width of "Unsigned"
ht = ntx.hOffscreenText;
set(ht,'String','Unsigned','Units','pix'); 
ext = get(ht,'Extent');
set(ht,'Units','data');

% Update the "signed" text pos
ht = ntx.htSigned;
pos_ax = get(ntx.hHistAxis,'Position'); % pixels
pos_t(1) = pos_ax(1);
pos_t(2) = pos_ax(2)+pos_ax(4)+4;
pos_t(3) = ext(3)+20+8; % icon=16 pix, icon/text gutter=8 pix
pos_t(4) = ext(4);
set(ht,'Position',pos_t);

% Update the "title" text pos
ht = ntx.htTitle;
ext = get(ht,'Extent');
pos_t(1) = pos_ax(1)+pos_ax(3)-1-ext(3);
pos_t(2) = pos_ax(2)+pos_ax(4); % next pixel above topmost axis pixel
pos_t(3:4) = ext(3:4);
set(ht,'Position',pos_t);
