function addPolarAxesBehaviors(obj)
% This is an undocumented function and may be removed in a future release.

%   Copyright 2015 The MathWorks, Inc.

b = hggetbehavior(obj, 'Zoom');
b.Enable = false;
b = hggetbehavior(obj, 'Pan');
b.Enable = false;
b = hggetbehavior(obj, 'Rotate3d');
b.Enable = false;
b = hggetbehavior(obj, 'Brush');
b.Enable = false;
b.Serialize = true; % brushing is the only behavior not serialized by default
b = hggetbehavior(obj, 'MCodeGeneration');
b.Enable = false;
b.MCodeIgnoreHandleFcn ='true';
