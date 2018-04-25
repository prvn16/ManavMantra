%NOTEBOOK  Microsoft Word に M-book を開く (Microsoft Windows プラットフォーム)
%
%   NOTEBOOK 自身では、Microsoft Word を起動し、"Document 1" という名前の
%   新規 M-book を作成します。
%
%   NOTEBOOK(FILENAME) は、Microsoft Word を起動し、FILENAME という M-book を
%   開きます。FILENAME が存在しない場合、FILENAME という名前の新規 M-book を
%   作成します。FILENAME は、常に拡張子を与える必要があります (例. mydoc.doc)。
%   絶対パス名か、"file.doc" という形式のいずれかでなければなりません。
%
%   NOTEBOOK('-SETUP') は、Notebook 用のセットアップ関数を実行します。
%   ダイアログはセットアップ中は現れず、セットアップが成功したかどうかを
%   示すステータスが表示されます。
%
%   例:
%      notebook
%      notebook c:\documents\mymbook.doc
%      notebook -setup


%   Copyright 1984-2009 The MathWorks, Inc.
