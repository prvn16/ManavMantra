% MDBFILEONPATH  エディタ/デバッガの補助関数
%
%   MDBFILEONPATH は絶対パスのファイル名を含む文字列を渡されます。
%   つぎのものが出力されます。
%      ファイル名:
%         実行されるファイル名 (隠れている可能性があります)
%         ファイルがパス上に見つからず、隠れされていない場合、ファイル名は、
%           com.mathworks.mlwidgets.dialog.PathUpdateDialog
%         で定義される整数内に渡されます。
%      状態の説明:
%         FILE_NOT_ON_PATH - ファイルがパス上にないか、エラーが発生しました。
%         FILE_WILL_RUN - M-ファイルは実行される MATLAB 上にあります 
%         (あるいは新しい P-ファイルで隠されています)。
%         FILE_SHADOWED_BY_PWD - M-ファイルはカレントディレクトリ内の
%         別のファイルで隠されています。
%         FILE_SHADOWED_BY_TBX - M-ファイルは MATLAB パス内のどこかの
%         別のファイルで隠されています。
%         FILE_SHADOWED_BY_PFILE - M-ファイルは同じディレクトリ内の 
%         P-ファイルで隠されています。
%         FILE_SHADOWED_BY_MEXFILE - M-ファイルは同じディレクトリ内の 
%         MEX か MDL ファイルで隠されています。


%   Copyright 1984-2006 The MathWorks, Inc.
