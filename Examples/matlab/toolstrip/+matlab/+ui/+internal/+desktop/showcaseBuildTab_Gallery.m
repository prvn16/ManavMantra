function tab = showcaseBuildTab_Gallery()
% Build the "Gallery" tab in the toolstrip.

% Author(s): Rong Chen
% Copyright 2015 The MathWorks, Inc.
import matlab.ui.internal.toolstrip.*
%% tab
tab = Tab('GALLERY');
tab.Tag = 'tab_gallery';
%% section 1
section = tab.addSection(upper('Gallery'));
section.Tag = 'section_gallery';
column = section.addColumn();
% build popup
popup = GalleryPopup();
popup.Tag = 'gallerypopup';
% populate popup
localBuildGalleryPopup(popup);
% build gallery
gallery = Gallery(popup,'MaxColumnCount',4,'MinColumnCount',2);
gallery.Tag  = 'gallery';
% assemble
column.add(gallery);
%% section 2
section = tab.addSection(upper('Single Selection Gallery'));
section.Tag = 'section_gallery_single';
column = section.addColumn();
% build popup
popup = GalleryPopup('ShowSelection',true);
popup.Tag = 'gallerypopup_single';
% populate popup
localBuildGalleryPopup_SingleSelection(popup);
% build gallery
gallery = Gallery(popup,'MaxColumnCount',4,'MinColumnCount',2);
gallery.Tag  = 'gallery_single';
% assemble
column.add(gallery);
%% section 3
section = tab.addSection(upper('Multiple Selection Gallery'));
section.Tag = 'section_gallery_multiple';
column = section.addColumn();
% build popup
popup = GalleryPopup('ShowSelection',true);
popup.Tag = 'gallerypopup_multiple';
% populate popup
localBuildGalleryPopup_MultipleSelection(popup);
% build gallery
gallery = Gallery(popup,'MaxColumnCount',4,'MinColumnCount',2);
gallery.Tag  = 'gallery_multiple';
% assemble
column.add(gallery);
%% section 4
section = tab.addSection(upper('Drop Down Gallery'));
section.Tag = 'section_gallery_dropdown';
column = section.addColumn();
% build popup
popup = GalleryPopup();
popup.Tag = 'gallerypopup';
% populate popup
localBuildGalleryPopup(popup);
% build gallery
button = DropDownGalleryButton(popup,'Examples',Icon.MATLAB_24);
button.MinColumnCount = 5;
button.Tag  = 'gallery_dropdown';
% assemble
column.add(button);

function localBuildGalleryPopup(popup)
import matlab.ui.internal.toolstrip.*
str = [fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image') filesep];
% build categories
cat1 = GalleryCategory('CATEGORY #1');
cat1.Tag = 'category1';
cat2 = GalleryCategory('CATEGORY #2');
cat2.Tag = 'category2';
cat3 = GalleryCategory('CATEGORY #3');
cat3.Tag = 'category3';
popup.add(cat1);
popup.add(cat2);
popup.add(cat3);
% build items
item1 = GalleryItem('Biology',Icon([str 'biology_app_24.png']));
item1.Tag = 'biology';
item1.Description = 'this is a description';
item1.ItemPushedFcn = @(x,y) ItemPushedCallback(x,y);
cat1.add(item1);
item2 = GalleryItem('Code Generation',Icon([str 'code_gen_app_24.png']));
item2.Tag = 'codegen';
item2.Description = 'this is a description';
item2.ItemPushedFcn = @(x,y) ItemPushedCallback(x,y);
cat1.add(item2);
item3 = GalleryItem('Control',Icon([str 'control_app_24.png']));
item3.Tag = 'control';
item3.Description = 'this is a description';
item3.ItemPushedFcn = @(x,y) ItemPushedCallback(x,y);
cat1.add(item3);
item4 = GalleryItem('Database',Icon([str 'database_app_24.png']));
item4.Tag = 'datebase';
item4.Description = 'this is a description';
item4.ItemPushedFcn = @(x,y) ItemPushedCallback(x,y);
cat1.add(item4);
item5 = GalleryItem('Depolyment',Icon([str 'deployment_app_24.png']));
item5.Tag = 'deploy';
item5.Description = 'this is a description';
item5.ItemPushedFcn = @(x,y) ItemPushedCallback(x,y);
cat1.add(item5);
item6 = GalleryItem('Finance',Icon([str 'finance_app_24.png']));
item6.Tag = 'finance';
item6.Description = 'this is a description';
item6.ItemPushedFcn = @(x,y) ItemPushedCallback(x,y);
cat2.add(item6);
item7 = GalleryItem('Fitting Tool',Icon([str 'fit_app_24.png']));
item7.Tag = 'fittool';
item7.Description = 'this is a description';
item7.ItemPushedFcn = @(x,y) ItemPushedCallback(x,y);
cat2.add(item7);
item8 = GalleryItem('Image Processing',Icon([str 'image_app_24.png']));
item8.Tag = 'image';
item8.Description = 'this is a description';
item8.ItemPushedFcn = @(x,y) ItemPushedCallback(x,y);
cat2.add(item8);
item9 = GalleryItem('Math',Icon([str 'math_app_24.png']));
item9.Tag = 'math';
item9.Description = 'this is a description';
item9.ItemPushedFcn = @(x,y) ItemPushedCallback(x,y);
cat2.add(item9);
item10 = GalleryItem('Neural Network',Icon([str 'neural_app_24.png']));
item10.Tag = 'neural';
item10.Description = 'this is a description';
item10.ItemPushedFcn = @(x,y) ItemPushedCallback(x,y);
cat2.add(item10);
item11 = GalleryItem('Optimization',Icon([str 'optim_app_24.png']));
item11.Tag = 'optim';
item11.Description = 'this is a description';
item11.ItemPushedFcn = @(x,y) ItemPushedCallback(x,y);
cat3.add(item11);
item12 = GalleryItem('Signal Processing',Icon([str 'signal_app_24.png']));
item12.Tag = 'signal';
item12.Description = 'this is a description';
item12.ItemPushedFcn = @(x,y) ItemPushedCallback(x,y);
cat3.add(item12);
item13 = GalleryItem('Statistics',Icon([str 'stats_app_24.png']));
item13.Tag = 'stats';
item13.Description = 'this is a description';
item13.ItemPushedFcn = @(x,y) ItemPushedCallback(x,y);
cat3.add(item13);
item14 = GalleryItem('Test Measurement',Icon([str 'test_app_24.png']));
item14.Tag = 'test';
item14.Description = 'this is a description';
item14.ItemPushedFcn = @(x,y) ItemPushedCallback(x,y);
cat3.add(item14);

function localBuildGalleryPopup_SingleSelection(popup)
import matlab.ui.internal.toolstrip.*
str = [fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image') filesep];
% buttongroup
group = matlab.ui.internal.toolstrip.ButtonGroup;
% build categories
cat1 = GalleryCategory('CATEGORY #1 Single');
cat1.Tag = 'category1_single';
cat2 = GalleryCategory('CATEGORY #2 Single');
cat2.Tag = 'category2_single';
cat3 = GalleryCategory('CATEGORY #3 Single');
cat3.Tag = 'category3_single';
popup.add(cat1);
popup.add(cat2);
popup.add(cat3);
% build items
item1 = ToggleGalleryItem('Biology',Icon([str 'biology_app_24.png']),group);
item1.Tag = 'biology';
item1.Description = 'this is a description';
item1.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat1.add(item1);
item2 = ToggleGalleryItem('Code Generation',Icon([str 'code_gen_app_24.png']),group);
item2.Tag = 'codegen';
item2.Description = 'this is a description';
item2.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat1.add(item2);
item3 = ToggleGalleryItem('Control',Icon([str 'control_app_24.png']),group);
item3.Tag = 'control';
item3.Description = 'this is a description';
item3.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat1.add(item3);
item4 = ToggleGalleryItem('Database',Icon([str 'database_app_24.png']),group);
item4.Tag = 'datebase';
item4.Description = 'this is a description';
item4.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat1.add(item4);
item5 = ToggleGalleryItem('Depolyment',Icon([str 'deployment_app_24.png']),group);
item5.Tag = 'deploy';
item5.Description = 'this is a description';
item5.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat1.add(item5);
item6 = ToggleGalleryItem('Finance',Icon([str 'finance_app_24.png']),group);
item6.Tag = 'finance';
item6.Description = 'this is a description';
item6.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat2.add(item6);
item7 = ToggleGalleryItem('Fitting Tool',Icon([str 'fit_app_24.png']),group);
item7.Tag = 'fittool';
item7.Description = 'this is a description';
item7.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat2.add(item7);
item8 = ToggleGalleryItem('Image Processing',Icon([str 'image_app_24.png']),group);
item8.Tag = 'image';
item8.Description = 'this is a description';
item8.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat2.add(item8);
item9 = ToggleGalleryItem('Math',Icon([str 'math_app_24.png']),group);
item9.Tag = 'math';
item9.Description = 'this is a description';
item9.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat2.add(item9);
item10 = ToggleGalleryItem('Neural Network',Icon([str 'neural_app_24.png']),group);
item10.Tag = 'neural';
item10.Description = 'this is a description';
item10.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat2.add(item10);
item11 = ToggleGalleryItem('Optimization',Icon([str 'optim_app_24.png']),group);
item11.Tag = 'optim';
item11.Description = 'this is a description';
item11.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat3.add(item11);
item12 = ToggleGalleryItem('Signal Processing',Icon([str 'signal_app_24.png']),group);
item12.Tag = 'signal';
item12.Description = 'this is a description';
item12.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat3.add(item12);
item13 = ToggleGalleryItem('Statistics',Icon([str 'stats_app_24.png']),group);
item13.Tag = 'stats';
item13.Description = 'this is a description';
item13.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat3.add(item13);
item14 = ToggleGalleryItem('Test Measurement',Icon([str 'test_app_24.png']),group);
item14.Tag = 'test';
item14.Description = 'this is a description';
item14.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat3.add(item14);

function localBuildGalleryPopup_MultipleSelection(popup)
import matlab.ui.internal.toolstrip.*
str = [fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image') filesep];
% build categories
cat1 = GalleryCategory('CATEGORY #1 Multiple');
cat1.Tag = 'category1_multiple';
cat2 = GalleryCategory('CATEGORY #2 Multiple');
cat2.Tag = 'category2_multiple';
cat3 = GalleryCategory('CATEGORY #3 Multiple');
cat3.Tag = 'category3_multiple';
popup.add(cat1);
popup.add(cat2);
popup.add(cat3);
% build items
item1 = ToggleGalleryItem('Biology',Icon([str 'biology_app_24.png']));
item1.Tag = 'biology';
item1.Description = 'this is a description';
item1.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat1.add(item1);
item2 = ToggleGalleryItem('Code Generation',Icon([str 'code_gen_app_24.png']));
item2.Tag = 'codegen';
item2.Description = 'this is a description';
item2.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat1.add(item2);
item3 = ToggleGalleryItem('Control',Icon([str 'control_app_24.png']));
item3.Tag = 'control';
item3.Description = 'this is a description';
item3.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat1.add(item3);
item4 = ToggleGalleryItem('Database',Icon([str 'database_app_24.png']));
item4.Tag = 'datebase';
item4.Description = 'this is a description';
item4.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat1.add(item4);
item5 = ToggleGalleryItem('Depolyment',Icon([str 'deployment_app_24.png']));
item5.Tag = 'deploy';
item5.Description = 'this is a description';
item5.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat1.add(item5);
item6 = ToggleGalleryItem('Finance',Icon([str 'finance_app_24.png']));
item6.Tag = 'finance';
item6.Description = 'this is a description';
item6.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat2.add(item6);
item7 = ToggleGalleryItem('Fitting Tool',Icon([str 'fit_app_24.png']));
item7.Tag = 'fittool';
item7.Description = 'this is a description';
item7.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat2.add(item7);
item8 = ToggleGalleryItem('Image Processing',Icon([str 'image_app_24.png']));
item8.Tag = 'image';
item8.Description = 'this is a description';
item8.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat2.add(item8);
item9 = ToggleGalleryItem('Math',Icon([str 'math_app_24.png']));
item9.Tag = 'math';
item9.Description = 'this is a description';
item9.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat2.add(item9);
item10 = ToggleGalleryItem('Neural Network',Icon([str 'neural_app_24.png']));
item10.Tag = 'neural';
item10.Description = 'this is a description';
item10.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat2.add(item10);
item11 = ToggleGalleryItem('Optimization',Icon([str 'optim_app_24.png']));
item11.Tag = 'optim';
item11.Description = 'this is a description';
item11.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat3.add(item11);
item12 = ToggleGalleryItem('Signal Processing',Icon([str 'signal_app_24.png']));
item12.Tag = 'signal';
item12.Description = 'this is a description';
item12.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat3.add(item12);
item13 = ToggleGalleryItem('Statistics',Icon([str 'stats_app_24.png']));
item13.Tag = 'stats';
item13.Description = 'this is a description';
item13.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat3.add(item13);
item14 = ToggleGalleryItem('Test Measurement',Icon([str 'test_app_24.png']));
item14.Tag = 'test';
item14.Description = 'this is a description';
item14.ValueChangedFcn = @(x,y) ValueChangedCallback(x,y);
cat3.add(item14);

function ItemPushedCallback(src, data)
if isempty(data.EventName)
    fprintf('Event "%s" occurs from the UI.\n', data.EventData.EventType);
else
    fprintf('Event "%s" occurs from the UI.\n', data.EventName);
end

function ValueChangedCallback(src, data)
fprintf('Property "%s" is changed in the UI.  Old value is "%s".  New value is "%s".\n',data.EventData.Property,num2str(data.EventData.OldValue),num2str(data.EventData.NewValue));
