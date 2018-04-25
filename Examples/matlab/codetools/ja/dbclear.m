%DBCLEAR  ブレークポイントのクリア
%
%   DBCLEAR コマンドは、対応する DBSTOP で設定されたブレークポイントを
%   削除します。このコマンドには、いくつかの形式があります。
%   以下のようになります。
%
%   (1)  DBCLEAR in MFILE at LINENO
%   (2)  DBCLEAR in MFILE at LINENO@
%   (3)  DBCLEAR in MFILE at LINENO@N
%   (4)  DBCLEAR in MFILE at SUBFUN
%   (5)  DBCLEAR in MFILE
%   (6)  DBCLEAR if ERROR
%   (7)  DBCLEAR if CAUGHT ERROR
%   (8)  DBCLEAR if WARNING
%   (9)  DBCLEAR if NANINF  or  DBCLEAR if INFNAN
%   (10) DBCLEAR if ERROR IDENTIFIER
%   (11) DBCLEAR if CAUGHT ERROR IDENTIFIER
%   (12) DBCLEAR if WARNING IDENTIFIER
%   (13) DBCLEAR ALL
%
%   MFILE は、M-ファイルの名前、または MATLABPATH 相対部分パス名でなければ
%   なりません (参照 PARTIALPATH)。コマンドが -completenames オプションを含み、
%   MFILE が完全修飾子付きのファイル名として指定されている場合は、MFILE はパス上
%   にある必要はありません。(Windows では、これは、コロンが \\ またはドライブ名
%   の後に続いて始まるファイル名です。Unix では、これは、/ または ~ で始まる
%   ファイル名です。) MFILE は、M-ファイル内の特定のサブ関数、または、ネスト
%   関数へのパスを指定する filemarker を含むことができます。
%
%   LINENO は、MFILE 内の行番号で、N はその行にある N 番目の無名関数を指定
%   する整数で、SUBFUN は MFILE 内のサブ関数の名前です。IDENTIFIER は、
%   MATLAB のメッセージ識別子です (メッセージ識別子の記述は ERROR のヘルプを参照)。
%   キーワード AT, IN はオプションです。
%
%   いくつかの形式は、以下のように動作します。
%
%   (1)  MFILE の行 LINENO のブレークポイントを削除します。
%   (2)  MFILE の行 LINENO の最初の無名関数のブレークポイントを削除します。
%   (3)  MFILE 内の行 LINENO の N 番目の無名関数のブレークポイントを削除します。
%        (同じ行上に複数の無名関数がある場合に使用します。)
%   (4)  MFILE の指定したサブ関数内のすべてのブレークポイントを削除します。
%   (5)  MFILE 内のすべてのブレークポイントを削除します。
%   (6)  DBSTOP IF ERROR ステートメントと任意の DBSTOP IF ERROR IDENTIFIER 
%        ステートメントが設定されている場合、クリアします。
%   (7)  DBSTOP IF CAUGHT ERROR ステートメントと DBSTOP IF CAUGHT ERROR IDENTIFIER 
%        ステートメントが設定されている場合、クリアします。
%   (8)  DBSTOP IF WARNING ステートメントと DBSTOP IF WARNING IDENTIFIER 
%        ステートメントが設定されている場合、クリアします
%   (9)  無限大 と NaN のDBSTOP を設定されている場合、クリアします。
%   (10) 指定したIDENTIFIER に対する DBSTOP IF ERROR IDENTIFIER ステートメントを
%        クリアします。DBSTOP IF ERROR または DBSTOP IF ERROR ALL が設定されて
%        いる場合、指定した識別子のこの設定をクリアすると、エラーになります。
%   (11) 指定したIDENTIFIER に対する DBSTOP IF CAUGHT ERROR IDENTIFIER 
%        ステートメントをクリアします。DBSTOP IF CAUGHT ERROR または 
%        DBSTOP IF CAUGHT ERROR ALL が設定されている場合、指定した識別子の
%        この設定をクリアすると、エラーになります。
%   (12) 指定された IDENTIFIER に対する DBSTOP IF WARNING IDENTIFIER 
%        ステートメントをクリアします。DBSTOP IF WARNING または 
%        DBSTOP IF WARNING ALL が設定されている場合、指定した識別子の
%        この設定をクリアするとエラーになります。
%   (13) 上記の (6)-(9) に述べたように、すべての M-ファイルのブレークポイント
%        をクリアします。
%
%   参考 DBSTEP, DBSTOP, DBCONT, DBTYPE, DBSTACK, DBUP, DBDOWN, DBSTATUS,
%        DBQUIT, FILEMARKER, ERROR, PARTIALPATH, TRY, WARNING.


%   Copyright 1984-2009 The MathWorks, Inc.
