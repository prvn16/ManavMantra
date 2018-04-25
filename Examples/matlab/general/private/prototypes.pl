#!/usr/local/bin/perl
# Parse a C/C++ header file and build up three data structures: the first
# is a list of the prototypes defined in the header file; the second is 
# a list of the structures used in those prototypes.  The third is a list of the 
# typedef statements that are defined in the file
#
# The header file must have already been processed by the pre-processor if it contains 
# preprocessor code.
#
# Options supported:
# 
#
# command line:
# prototypes [options] [-outfile=name] input.i  [optional headers to find prototypes in]  
#
# Copyright 2002-2014 The MathWorks, Inc.

# file general information:
# ParseXXXXX functions do not modify known state and may be called recursively
# ProcessXXXXX functions add information to global type tables
use strict 'refs';
use Carp;

my ($FileRev)=''=~/([\d.]+)/;
my $cmdline=join ' ', @ARGV;
$exitcode=0;  #Global
parsArgs(debug=>0,outfile=>'-',calltype=>'cdecl',allsrc=>0);
my $outfile=$options{outfile};
my $GenThunkFile=exists $options{thunkfile};

open OUTFILE,">$outfile" or die "Can not open output file $outfile because $!";
my $inputfile=$ARGV[0];
open INFILE ,"<$inputfile" or die "Can not open file $inputfile because $!";
@keywords= sort qw(auto double int struct break else long switch case enum register 
              typedef char extern return union const float short unsigned continue
              for signed void default goto sizeof volatile do if static while);
#create a hash of all C keywords
foreach (@keywords) {
$keywords{$_}=undef;
} 

%baseTypes = qw(int8_t int8 int8_T int8 char int8 short int16 int int32 long long
              __int64 int64 longlong int64); 
%otherTypes = qw(bool bool _Bool bool struct struct unsigned uint32 float single double double enum int32);
%windowsTypes = qw(DWORD uint32 UINT uint32);

#setting typeOverrides to 1 for a type prevents an error if a header
#file has a conflicting typedef.  Use to replace a c typedef with a custom
#or other compatible type in MATLAB 
$typeOverrides{'bool'}=1;  #cpp has bool native type c has typedef


for (keys %baseTypes) {
    my $bt=$baseTypes{$_};
    $types{$_}=$bt;
    $types{'unsigned' . $_ }='u'.$bt ;    
}
for (keys %otherTypes) {
	$types{$_}=$otherTypes{$_};
}
#if on windows add windows types
for (keys %windowsTypes) {
	$types{$_}=$windowsTypes{$_};
	$typeOverrides{$_}=1;
}

for (keys %types) {
   my $bt=$types{$_};
    $types{$_ . 'Ptr'}=$bt . 'Ptr';
 }


#fix up special types
$types{'int64_T'}='int64';
$types{'uint64_T'}='uint64';
$types{'charPtr'}='cstring';
$types{'charPtrPtr'}='stringPtrPtr';
$types{'mxArrayPtr'}='MATLAB array';
$mxArrayPtrPtr='MATLAB arrayPtr';
$types{'mxArrayPtrPtr'}=$mxArrayPtrPtr;
$types{'void'}='void';  # for void functions
$types{'voidPtr'}='voidPtr';  
$types{'voidPtrPtr'}='voidPtrPtr';  

# Accommodate the __builtin_va_list type for MinGW compiler
$types{'__builtin_va_list'}='__builtin_va_list';

$types{'...'}='vararg';
#    An optional typefile may be specified the format of which is "ctype matlabtype" 
if (exists $options{typefile}) {
    open TYPEFILE,"<$options{typefile}" or die "Can not open typefile $options{typefile} because $!";
    while (<TYPEFILE>) {
        chomp $_;
        ($ctype,$mtype)=split(/\s+/,$_);
        if (defined( $ctype) and defined( $mtype)) {
            print "Adding user type $ctype to be $mtype\n"  if ($options{debug} eq 'types');
            $types{$ctype}=$mtype; 
            $typeOverrides{$ctype}=1;
        }
    }
    close TYPEFILE;
}

if ($GenThunkFile) {
    open THUNKFILE,"> $options{thunkfile}" or die "Can not open C output file $options{thunkfile} because $!";
    print THUNKFILE "/* C thunk file for functions in $outfile generated on " , scalar localtime , ". */\n\n";
############# Header code for thunk file
    print THUNKFILE <<'END_HEADER';

#ifdef _WIN32
  #define DLL_EXPORT_SYM __declspec(dllexport)
#elif __GNUC__ >= 4
  #define DLL_EXPORT_SYM __attribute__ ((visibility("default")))
#else
  #define DLL_EXPORT_SYM
#endif

#ifdef LCC_WIN64
  #define DLL_EXPORT_SYM
#endif

#ifdef  __cplusplus
#define EXPORT_EXTERN_C extern "C" DLL_EXPORT_SYM
#else
#define EXPORT_EXTERN_C DLL_EXPORT_SYM
#endif

#include <tmwtypes.h>

/* use BUILDING_THUNKFILE to protect parts of your header if needed when building the thunkfile */
#define BUILDING_THUNKFILE

END_HEADER
 ############### End of header code

    print THUNKFILE  "#define BUILDING_HTESTLIB\n" if $inputfile=~/htestlib/; #hack for htestlib
    my $headername;
    if  (exists $options{header}) {
    	$headername=$options{header}
    } else {
      $headername=$inputfile;
    	$headername=~s/\.i$/\.h/;
    }
    print THUNKFILE "#include \"$headername\"\n";
    print THUNKFILE "#ifdef LCC_WIN64\n";
    print THUNKFILE "#define EXPORT_EXTERN_C __declspec(dllexport)\n";
    print THUNKFILE "#endif\n\n";  
    
#Now set up special type mappings for thunk file
    my @baseTypes=qw(int8 int16 int32 int64 );
    my $t, @mltypes;
    foreach $t (@baseTypes) {
        $ThunkMatlabTypeMap{$t}=$t . '_T';
        push @mltypes, $t;
        $ThunkMatlabTypeMap{'u' . $t}='u' . $t . '_T';
        push @mltypes, "u$t";
    }
    $ThunkMatlabTypeMap{voidPtr}='void *';
    $ThunkMatlabTypeMap{string}='char *';
    $ThunkMatlabTypeMap{cstring}='char *';
    $ThunkMatlabTypeMap{ulong}='unsigned long';
    $ThunkMatlabTypeMap{single}='float';
     
    push @mltypes,qw(string voidPtr cstring void double ulong long); #other types that work
    foreach (@mltypes) {
        $MatlabType{$_}=undef;
    }
}

my $functionCount=1; #matlab starts at one
my $structCount=1;
$inSrcFile=1;  #Global, if no line statements then all code counts
$srcLine=0;  #Global for debugging, if no line statements default to line 1
$packing=undef; #Global

my $SourceMap;
for (@ARGV) {
    s/([\w\s]+)\.[\w\s]*$/$1/;  #remove file extension because first file is a .i
    quotemeta($_); # fix up for metas
    s"/|\\"[/\\\\]+"g; #" paths can match \ or /
    push @SrcFiles,$_;
    $SourceMap{$_}=0;
}
$str='';
if ( $outfile=~/([^\\]+)\.[^\\]+$/ ) {
    $writingfunc=1;
    $capname=uc($1); 
    print OUTFILE "function [methodinfo,structs,enuminfo,ThunkLibName]=$1\n";
    $hfile=$ARGV[0];
    $hfile=~s/\.i/.h/;
    print OUTFILE "%$capname Create structures to define interfaces found in '$hfile'.\n\n" ;
    print OUTFILE "%This function was generated by loadlibrary.m parser version $FileRev on " ,scalar localtime ,"\n";
    print OUTFILE "%loadlibrary options:'$options{loadlibrarycmd}' \n" if exists $options{'loadlibrarycmd'} ; 
    print OUTFILE "%perl options:'$cmdline'\n"; 
    print OUTFILE "ival={cell(1,0)}; % change 0 to the actual number of functions to preallocate the data.\n";
    print OUTFILE "structs=[];enuminfo=[];fcnNum=1;\n";
    if ($GenThunkFile) {
        print OUTFILE "fcns=struct('name',ival,'calltype',ival,'LHS',ival,'RHS',ival,'alias',ival,'thunkname', ival);\n";
        #add ThunkLibName to mfile for use in loading
        my $ThunkLibName=$options{thunkfile};
        $ThunkLibName=~s/\.c(pp|\+\+)?$//i;
        print OUTFILE "MfilePath=fileparts(mfilename('fullpath'));\n";      
        print OUTFILE "ThunkLibName=fullfile(MfilePath,'$ThunkLibName');\n";
    } else {
        print OUTFILE "fcns=struct('name',ival,'calltype',ival,'LHS',ival,'RHS',ival,'alias',ival);\n";
        print OUTFILE "ThunkLibName=[];\n";
    }
} else {
       $writingfunc=0;
    }
$srcFile='';
while (<INFILE>)
{
    # Ignore pre-processor directives and blank lines
    chomp;
    next if  /^\s*$/; #Just skip white space lines
    if (/^\s*#/) {
     #print "skipping $_";
     if (/^\s*#line\s+(\d+)\s+\"(.*)\"/ || /^# (\d+) \"(.*)\"/ ) {
        $srcLine=$.-$1+1; #srcLine is a fixup (offset) for $.
        if ($2 ne $srcFile) {
            $srcFile=$2;
            my $checkSource;
            $inSrcFile=0;
            foreach $checkSource (@SrcFiles) {
                if ($srcFile=~ m"\b$checkSource(\.[^/\\]*)$"i){
                    $inSrcFile=1;
                    $SourceMap{$checkSource}++;
                    last;
                }
            }
            print "dumping ************* \n'$str'\n *****because of include file change\n" if ($options{debug} && $str ne '') ;  
            $str='' ;  #clear out string for safety
            print "inSrcFile is $inSrcFile for $2\n" if ($options{debug} eq 'srcfile');
     	} 
     }
     #TODO try /#\s*pragma\s+pack\s*\(\s*(push|pop)?,?\s*(\d+)\s*\)
     if (/^\s*#\s*pragma\s+pack\s*/) {
         if ($'=~/^\(\s*(\d+)\s*\)/) { #' fix highlighting
            $packing=$1;
         } elsif ($'=~/^\(\s*push\s*/) {
            push(@packing,$packing);
            $_=$';
            if (/,\s*(\d+)\s*\)\s*$/) {
                $packing=$1;
            }
            if (/^,\s*([a-zA-Z_]\w*)/) {# if a tag
                $packtag=$1;
            } 
         } elsif ($'=~/^\(\s*pop\s*/) {
            $packing=pop(@packing);
            $_=$';
            if (/^,\s*(\d+)\s*\)\s*$/) {
                $packing=$1;
            }
            if (/^,\s*([a-zA-Z_]\w*)/) {# if a tag
                DumpError("Packing tags did not match $packtag!=$1") if $packtag ne $1;
            } 
            undef $packtag;
         } elsif (length ($') == 0 || $'=~/^\(\s*\)\s*$/) { 
            $packing=undef;
         } else {
            DumpInfo( "Unsupported packing pragma '$_'");
         }
     } # end of pack
     next; 
    } # end of preprocessor tag
    #split up a line on semicolons because this script only can deal with one statement at a time
    @statements=split /;/ ;
    @statements=map { $_ . ';'} @statements; #put back the semi's
    $statements[-1]=substr($statements[-1],0,-1) unless /;$/;  #remove the last semi if there was not one there

    foreach $st (@statements) 
    {
        
    $str = $str . ' ' . $st;    #space is needed because line end is a delimiter
    print "str '$str' is blank\n" if (length($str)<2 && $options{debug});
    
    #check for matched parens
    my $t=$str;
    if ($t=~ tr/{([// != $t=~tr/})]//) {
        #print "odd parens found appending str is '$str'\n";
        next; 
    }

    #make sure all boundaries are single space delimited
    $str=join(' ',grep(length>0,split(/\b|\s+/,$str)));
    #$str2=~ s/\s+|\b/ /g; #doubles some spaces
    # Collapse multiple whitespace to a single space character
    #$str =~ s/\s+/ /g;

    #pull Windows __declspec(dllimport) and export they confuse other processing
    $str=~s/__declspec\s?\(.*?\)//;

    #MinGW preprocessor changes __declspec(...) to
    #__attribute__((...)).To handle __attribute__ appropriately:

    #1) change __attribute__((__stdcall__)) to _stdcall
    #(leave stdcall so it's picked up as the call type in M-file;
    # if not left, the call type is cdecl, which sometimes causes crash)
    $str=~s/__attribute__\s*\050\050?\s*__stdcall__\s*\051\051?/_stdcall /g;
  
    #2) remove __attribute__(dllimport) and __attribute__(dllexport)
    $str=~s/__attribute__\s*\050\050?\s*(dllimport|dllexport)\s*\051\051?//g;
	
     	

    if (!($st=~/;\s*$/)) { # line does not end in semi just concat it
        #print "Appending $_\n";
        next if ($str=~/^ ?(typedef|struct|enum) /);
        if ($str=~/\} ?$/) {
             if ($str=~/extern\s+"\s?C\s?"\s*\{/) { #spaces were added when word delimiters were spaced
                 DumpError('extern "C" { found in file. C++ files are not supported.  Use #ifdef __cplusplus to protect.')  ;
             }
             print "**** found function '$str'\n" if $options{debug};;
             $str='';
             next;
        }  
        #print "**** found no semi in '$str'\n" if $options{debug};
        next;
    }

 
    # Build an association list of typedefs. The goal is to be able to
    # resolve a defined type into the native C/++ type underlying it
    if ($str =~/typedef /) { 
        if ($str =~/typedef\s(struct|enum) / ) {  # if it is an enum or struct
            my $type=$1;
            my $tstr=$'; #' fix editor highlighting
            if ($tstr=~/^\w*\s?\{[^}]*$/) {# append more data
                print "**** found partial $1 in $str\n" if $options{debug};
                next;
            }
            if ($tstr =~/^\s?(\w+) ([^;{}]+);/) {  # found an enum or struct typedef with no declaration
                    my $Name=$1;
                    my $mlName=MakeMatlabVar($Name,substr($type,0,1) . '_');
                    my $Types=$2;
                    print "Found $type typedef of $Name ($mlName) with no declaration.\n" if exists $debug{'types'};

                    if ($type eq 'struct' && !exists $types{$Name}) {
                        $structs{$mlName}=[];
                        push @structOrder,$mlName;
                     }
                    AddType($Name,$mlName);
                    ProcessTypedef($Name,$Types);
                    $str='';
                    next;
            } 
            if ($type eq 'enum') { #found an enum
                my $enumName;
                my $enumTypes;
                my $enumDefines;
                
                if ($tstr =~ /^(\w+)\s?\{(.*)\}([^;]*)/) { #It has a name
                    $enumName=$1;
                    $enumDefines=$2;
                    $enumTypes=$3;
                } elsif ($tstr =~/^\s?\{(.*)\} ?(\w+) ?,?([^;]*)/) { # it is nameless
                    $enumDefines=$1;
                    $enumName=$2;
                    $enumTypes=$3;
                } elsif ($tstr =~/^\s?\{(.*)\}\s?;/) { # typedef enum {...};
                    $enumDefines=$1;
                    $enumName='dummyEnumName';
                    $enumTypes=undef;
                } else {
                    print "error matching enum typedef in '$str' trying more data.\n" if $options{debug};
                    next;
                }
                if ($enumDefines=~/^\s*$/) { #no actual enum values
        	    AddType($enumName,'int32');
        	}else {
                    ProcessEnum($enumName,$enumDefines);
                    ProcessTypedef($enumName,$enumTypes) if defined $enumTypes;
                }
                $str='';
                next;        
            }
    
            if ($str =~/typedef struct (\w+)\s?\{(.*)\}\s*([^;]*)/ ) {# we got a struct 
                print "Found struct $1 to be $3.\n" if $options{debug} eq 'structs';
                ProcessStruct($1,$2,$3);
                $str='';
                next;
            }
    
            if ($str =~/typedef struct\s?\{(.*)\}\s*(\w+)? ?,?([^;]*)/ ) {# we got nameless a struct
                print "Found nameless struct to be $2.\n" if $options{debug} eq 'structs';
                my $typedefs=$3;
                my $sname=$2;
                if (!defined $sname) {
                    $sname='dummy'. $.; # add input line number to dummy
                }
                ProcessStruct($sname,$1,$typedefs);
                $str='';
                next;
            }
            # error ?
            print "Error matching typedef (enum|struct) in '$str'.\n" if $options{debug};

        } #end of typedef (enum|struct)

        if ($str =~/\)\s*[;,]/) {
            print "found function prototype typedef '$str'.\n" if $options{debug};
            #try to find the name
            if ( $str =~/typedef .*?\(.*\b(\w+) \) ?\(.*\) ?[,;]/ 
                 || $str =~/typedef .*\b(\w+) ?\(.*\) ?[,;]/  ) {
                AddType($1,'FcnPtr'); # if !exists $keywords{$1};
            }
            $str='';
            next;
        }
        
        if ($str =~/typedef([^;,\[]+)([*\s]+[a-zA-Z_]\w*.*);/) #one line typedef
        {
            $typedef = $1;
            $newtypes = $2;
            $typedef =~ s/\s+$//; #remove trailing spaces
            if ($typedef =~ s/(\*+)$//) {   #if ending with *, move * to new types part
                $newtypes = $1 . $newtypes;
            }
            if ($typedef =~ /^ (struct|enum)\s*\{/) {
                DumpError("Punted typedef because found '$1'.");
                next;
            }            
            # Chop off leading and trailing spaces
            trim($newtypes);
            trim($typedef);
            print "defining '$newtypes' to be '$typedef'\n" if $options{debug} eq 'types';
            ProcessTypedef($typedef,$newtypes);
            $str='';
            next;
        }
    } elsif ($str =~/^\s*enum\s*(\w+)\s*\{(.*?)\}\s*;/) {#found a naked enum
    	if ($2=~/^\s*$/) {#no actual enum values
    	    AddType($1,'int32');
    	}else {
            ProcessEnum($1,$2);
        }
        $str='';
    } elsif ($str =~/^\s*struct (\w+)\s*\{(.*?)\}\s*;/) {#found a naked struct
        ProcessStruct($1,$2,'');
        $str='';
    } elsif ($str =~/^\s*struct (\w+)\s*;/) {#found a struct forward declaration
        ProcessStruct($1,'','');
        $str='';
    } elsif ($str =~/^.*?\( ?\* ?(\w+)\) ?\(.*\) ?; ?/) {
        #function pointer data declaration drop it
        print "found function pointer data declaration of $str\n" if $options{debug};

        $str='';
        next;
    } elsif ($str =~ /^ ?(.*?)(\w+) ?\(\s*(.*?)\) ?;/) {
    # Function prototype. Emit a line of MATLAB code to build up the function
	if (!$inSrcFile) {
                print "Function '$2' skipped because srcfile is '$srcFile'.\n" if $options{debug} eq 'srcfile';
		$str = "";
		next;
	}
        $ftype= $rtype = $1;
        $name = $2;
        $pstr = $3;
        if ( $pstr=~/\([^\)]*,/  ) {
            # supporting this will require rewriting the parameter parser
            print "Function $name skipped because '$pstr' contains function pointer arguments.\n" if $options{debug};
            $str="";
            next;
        } 
    	$calltype=$options{calltype};
        #pull any 'extern' or 'far' statements
        if ($rtype =~ s/\b(extern|far)\b//g) {
            $rtype =~ s/\"\s?C\s?\"// ; # did it have extern "C"?  spaces were added when word delimiters were spaced
        }
        
        #pull any 'stdcall' statements. WINAPI is present to help reduce the need for windows.h 
        if ($rtype =~ s/\b(_*stdcall|WINAPI)\b//g) {
            $calltype='stdcall';
        }

        if ($rtype =~ s/\b_*cdecl\b//g) {
            $calltype='cdecl';
        }
    		
        $lhs=GetUddType($rtype);
        print "function '$name' type is $ftype striped is '$rtype' translated to $lhs\n" if ($options{debug} eq 'functions');

        #$pstr=~s/(\w+)\s*\[\]/\*$1/g; # change var[] to *var
        @parameters = split(/,/, $pstr);

        #save the untranslated parameters  used by addFunctionThunk
        my @rawParameters if $GenThunkFile;
        my $vararg=0;
        # translate the parameter list 
        foreach $parameter (@parameters)
        {
            my ($cleanedParameter,$varName)=ParseType($parameter);
            if (defined $cleanedParameter) {
                $cleanedParameter=~s/#\d+(Ptr)?/Ptr/; #Do not add a pointer if one exists                
            } else {
                print "Error parsing argument for function $name function may be invalid.\n" ;
                $cleanedParameter="error";
            }
            if ($GenThunkFile) {
                $parameter=~s/\s+$varName\s*$// if defined $varName;
                push @rawParameters,$parameter;
                $vararg=1 if $parameter=~/\s*(\.\.\.|va_list)\s*/;
            } 
            $parameter=$cleanedParameter;  #update @parameter list
        }
        
        #now print out prototype to the file
        print OUTFILE "% $str \n";
        #is it a mex style function?
        if (@parameters==4 && ($lhs eq 'void' || $lhs eq 'bool') && $parameters[0] eq 'int32' && $parameters[2] eq 'int32'
            && $parameters[1] eq $mxArrayPtrPtr && $parameters[3] eq $mxArrayPtrPtr) {
                $calltype='matlabcall'
            }
        #if creating a thunk file write out the thunk
        if ($GenThunkFile && ($calltype ne 'matlabcall') && !$vararg) {
            my $thunkname=addFunctionThunk($lhs,$rtype,\@parameters,\@rawParameters);
            $calltype='Thunk';
            print OUTFILE "fcns.thunkname{fcnNum}='$thunkname';";
        }
        print OUTFILE "fcns.name{fcnNum}='$name'; ";
        $alias=MakeMatlabVar($name);
        print OUTFILE "fcns.alias{fcnNum}='$alias'; " if $alias ne $name;
                        
        print OUTFILE "fcns.calltype{fcnNum}='$calltype'; ";
        if ($lhs eq 'void') {
            print OUTFILE "fcns.LHS{fcnNum}=[]; ";
        } else {
            print OUTFILE "fcns.LHS{fcnNum}='$lhs'; ";
        }
        if (@parameters==0 || $parameters[0] eq 'void') {
            print OUTFILE "fcns.RHS{fcnNum}=[];";
        }else {
            print OUTFILE "fcns.RHS{fcnNum}={'" ,join("', '",@parameters),"'};";
        }
        
        print OUTFILE "fcnNum=fcnNum+1;\n";
        $functionCount++;
        print "function string was '$str'\n" if ($options{debug} eq 'functions');
        $str = "";
    }  elsif ($str =~/^\s*extern\s*([^=]*\w+[^(=]*)(=.*)?\s*;\s*$/) {
        #advanced (one with parens /casting) data declaration emit a data calltype function
	if (!$inSrcFile) {
                print "Data Export '$1' skipped because srcfile is '$srcFile'.\n" if $options{debug} eq 'srcfile';
		$str = "";
		next;
	}
        my ($Type,$Name)=ParseType($1);
        #now print out prototype to the file
        if (defined $Type && defined $Name) {
            $Type=~s/#\d+//; #Remove size for sized types in data declarations
            $Type.=Ptr; #Add one level of indirection
            print "Found data export of $Name to be of type $Type\n" if $options{debug};
            print OUTFILE "% $str \n";
            #is it a mex style function?
            print OUTFILE "fcns.name{fcnNum}='$Name'; ";
            $alias=MakeMatlabVar($Name);
            print OUTFILE "fcns.alias{fcnNum}='$alias'; " if $alias ne $Name;
                            
            print OUTFILE "fcns.calltype{fcnNum}='data'; ";
            print OUTFILE "fcns.LHS{fcnNum}='$Type'; ";
            print OUTFILE "fcns.RHS{fcnNum}=[];fcnNum=fcnNum+1;\n";
            $functionCount++;
        }
        $str='';
        next;
    }
        #can the string be dumped?
        print "Dumping '$str'\n" if ($options{debug} && length($str)>1);
        $str="";
}
}

print "Last string was '$str'\n" if ($options{debug} && length($str)>1);

for (@structOrder) {
    if (exists $typesUsed{$_}) {
        if (!exists $structs{$_}) {
            print "warning struct $_ not found\n";
        } else {
            print OUTFILE "structs.$_.packing=$structPacking{$_};\n" if defined $structPacking{$_};
            print OUTFILE "structs.$_.members=struct('",join( "', '",@{$structs{$_}}),"');\n"; 
            $structCount++;
        }
    }
}

for (keys %enums) {
    if (exists $typesUsed{$_}) {
        print OUTFILE "enuminfo.$_=struct(" ,join(",",@{$enums{$_}}) , ");\n"; 
    }
}    
    
print OUTFILE "methodinfo=fcns;" if $writingfunc;

print "Source files found is @{[ %SourceMap ]}\n" if $options{debug} eq 'srcfile';

while( my ($k, $v) = each %SourceMap ) {
    if ($v == 0) {
        $k=~s"\[.{1,3}\]\+"/"g; %"; #" Put back a normal file separator
        print "Warning no reference to header '$k' added with addheader was found in source.\n" ;
    }
}
exit $exitcode;

#end of main function
###############################################################################

#clean up a type name to one that is representable in matlab as a variable name
sub MakeMatlabVar {
    $_=$_[0];
    my $rep=defined $_[1] ? $_[1] : '';
    s/^_+/$rep/;  # change leading _ they are illegal in matlab
    $_;
}
    
#create a new type basictype is the matlab type 
sub AddType {
    my $newtype=$_[0];
    my $basictype=$_[1];
    die if (!defined $newtype || !defined $basictype );
    if (exists $types{$newtype} && (!$types{$newtype}=~/^(error|void(Ptr)+)$/ || $types{$newtype} eq $basictype))
        {
            if (!exists $typeOverrides{$newtype}) {
                if ($types{$newtype} ne $basictype)  {
                    DumpInfo("Attempt to redefine '$basictype' current definition $types{$newtype} new definition $basictype."); 
                } else {
                    print "Found second identical definition of type $newtype.\n" if $options{debug} eq 'types';
                }
            } else {
                print "Skipping type '$newtype' defined as '$basictype' because override\n" if ($options{debug} eq 'types');
            }                
        }
    else {
        print "Creating type '$newtype' to be '$basictype'\n" if ($options{debug} eq 'types');
        $types{$newtype} = $basictype;
    }
}


sub ParseType {
    # given an input return the MATLAB type [and name in $varName]
    my $type=$_[0];
    my $arraysize;
    my $varName;
    #remove leading spaces and trailing [ ;]+
    $type =~ s/^\s+//;
    $type =~ s/[\s;]+$//;

    #find the name if it exists
    #pull any 'const' statements
    $type =~ s/_{0,2}const\s+//g; #what code needs __const?
    #remove array notation first
    ($type,$arraysize)=FoldArrayToPtr($type) if $type=~/\[|&/;
    if ($type=~/^\w+$/ || $type=~/\*$/) { # simple case one word or trailing ptr
        $type=GetUddType($type);
    } elsif ($type=~/^((?:\w+[*\s]+)+)(\w+) ?$/ ){
        # 2 or more words
        # check to see if found name is a reserved word
        if (exists $keywords{$2} || $1=~/^(struct|enum)[*\s]+$/) {
            #Rebuild the parameter
            $type=GetUddType($type);
        } else {
            $varName= $2;
            $type=GetUddType($1);
        }
    } elsif ($type =~/\)\s*$/) {  #Is the type a function prototype?
        print "found function prototype in '$type'.\n" if $options{debug};
        #try to find the name
        if ( $type =~/^[^(]*\([^)]*\b(\w+) ?\)\([^)]*\) ?$/ 
             || $type =~/^.*\b(\w+) ?\(.*\) ?$/  ) {
            $varName=$1
        } else {
            DumpInfo("Failed to find variable name in $type");
        }
        return 'FcnPtr';
    } else {
        DumpInfo("Failed to parse type '$type' original input '$_[0]'");
        return undef;
    }
    $type = $type.'#'.$arraysize if defined $arraysize; 
    print "Found something named $varName in'$_[0]'\n" if (defined $varName && exists $debug{'names'});
    return ($type,$varName);
     
}

sub isBalanced {
    my $t=$_[0];
    $t=~tr/{([// == $t=~tr/})]// ;
}

sub findMatch1 {
    local $_=$_[0];
    #taken from perlfaq4
    #finds inner block and returns it
    my $B='{';
    my $E='}';
    while (s/$B((?:(?!$B)(?!$E).)*)$E//gs) {
	print "Match:$1\n"# do something with $1
    }
    print "Final string:$_\n";
}

sub splitTypes { #split types,vars or parameters on commas
    local $_=$_[0];
    #can we do a simple split ?
    if (!/[{(]/) {
        return split ',',$_;
    }
    print "found parens in $_\n";
    findMatch1($_);
    return $_
}

sub ProcessTypedef {
    local $_;
    my $basetype=$_[0];
    my $newtype;
    my @newtypes=splitTypes($_[1]);
    $basetype =~ s/__typeof__.*sizeof\s*\(\s*int\s*\)\s*\)/uint64_T/;
    $basetype =~ s/__typeof__.*/int64_T/;
#    print "newtypes is '@newtypes' split from '$_[1]'\n";
    for (@newtypes) {
        my ($baseType,$varName)= ParseType($basetype .' '. $_);
        if (!defined $varName) {
            print "No types defined in $basetype $_\n found in:$str\n" if $options{debug};
            next;
        }
        $baseType='error' if !defined $baseType;
        next if !defined $varName;
        AddType($varName,$baseType);
        $_=$varName;
    }
    $newtypes[0];
}

sub ProcessEnum {
    my $cname=$_[0];
    my $members=$_[1];
    my $mlname=MakeMatlabVar($cname,'e_');
    AddType($mlname,$mlname);
    AddType($cname,$mlname) if ($mlname ne $cname);

    my @ed;
    my @memb=split ',', $members;
    my $value=-1;  # start value at -1 because it is incremented before use.
    print "Found enum $mlname with c name $cname.\n" if exists $debug{'enums'}; 
    for (@memb) {
        s/\s//g; #trim all spaces
        next if ($_ eq '');
        my $enum=$_; 
        if (/^(\w+)=(.*)$/) {
            $enum=$1;
            my $newvalue=ParseConstExp($2);
            next if !defined $newvalue;
            $value=$newvalue;
            print "translated to '$value'.\n" if exists $debug{'enums'}
            
        } else {
            $value++;
        }
        $enumValueMap{$enum}=$value;
        $_=MakeMatlabVar($enum);
        push @ed,"'$_',$value";
    }
    $enums{$mlname}=\@ed; 
    if ($inSrcFile) {
        $typesUsed{$mlname}=[];
    }
}

sub ParseConstExp { #one input contains exp to parse returns undef on failure
    my $inp=$_[0];
    local $_;
    #first change const vars to numeric value
    print "Parsing $inp\n" if $options{debug} eq 'constexp';
    while ($inp=~/\b[A-Za-z_]\w+\b/) {
        print "Evaluating $& value from $inp" if $options{debug} eq 'constexp';
        if (exists $enumValueMap{$&}) {
            $inp=~s/$&/$enumValueMap{$&}/;
            print "reduced to $inp\n"  if $options{debug} eq 'constexp';
        } else { 
            #some error here?  for now just remove it
            DumpInfo("\nNo match found for enum value expression $& in $inp expression ignored.");
            return undef;
       } 
    } 
    #strip trailing [uUlL] from numbers
    $inp=~s/(\d)[uUlL]+\b/\1/;
        
    $_=eval($inp);
    $_=ord($_) if /^[^0-9]$/; 
    if (!defined $_) {
        DumpInfo("Eval of const expression $inp failed with error $@.");
        return undef;
    }
    $_=oct($_) if $_=~/^0/;
    print "Evaluated $_[0] and found a value of $_\n" if $options{debug} eq 'constexp';
    return $_;
}
    
# mark a datatype as used by a function that will be imported
sub AddUsedType {
    $_=$_[0];
    s/Ptr//g;
    return if exists $typesUsed{$_};
    
    if ($options{debug} eq 'types')
    {
        if (exists $structs{$_}){
            print "Found use of struct $_\n" ;
        } elsif (exists $enums{$_}) {
            print "Found use of enum $_\n" ;
        } else {
            print "Found use of type $_\n";
        }
    }
    $typesUsed{$_}=[];
    if (exists $structs{$_}) {
        my %st=@{$structs{$_}};
        #Need to mark embedded types as used
        for $key (keys %st) {
            my $type=$st{$key};
            $type=~s/Ptr//g;
            AddUsedType($type) if ~exists $typesUsed{$type};
        } 
    }
}

sub ParseStruct {
    $_=$_[0];  # input is the struct definition  
    #output1 is a reference to an array consisting of name,type,name,type ....
    print "Processing structure members $_\n" if exists $debug{'structs'};
    my @memb=split ';', $_[0];
    pop @memb;  #last element is empty
    my @sd;
    my $errcount;
    for (@memb) {
        my $type;
        my $var;
        #need to detect function ptr types by unbalanced ( before ,
        if (/^(.*?)\b(\w+)\s?,(.*)$/) {  # if multiple vars of same type
             $type=$1;
             if (!isBalanced($type)) {
                DumpInfo ("Function pointer types are unsupported in structures $type.") ;
                push @sd,('error' . $errcount++ ,'voidPtr');
                $type='voidPtr';
                next;
             }
             my $var1=MakeMatlabVar($2,'m_');
             my @othervars=split ',', $3;
             print "Found multiple struct members type=$type, var1=$var1, othervars=@othervars\n" if exists $debug{'structs'};
             push @sd,$var1;
             push @sd,GetUddType($type);
             
             for (@othervars) {
                my $st=$type . ' ' .$_;
			    ParseStructHelper($st, \@sd, \$errcount);
            }           
        } 
		else {
	         ParseStructHelper($_, \@sd, \$errcount);
		}
    }
    return \@sd;
}    
 
 sub ParseStructHelper{
	my $st = $_[0];
	my $sd = $_[1];
	my $errcount = $_[2];
	
	if ($st=~/^(.*)\b(\w+)\s*$/) {
		$var=MakeMatlabVar($2,'m_');
		$t=$1;
		push @$sd,$var;
		push @$sd,GetUddType($t);
	} elsif ($st=~/^(.*)\b(\w+)\s*\[(.*)]\s*$/) { #sized array
		$var=MakeMatlabVar($2,'m_');
		$type=$1;
		my $arraydims=$3;
		# replace 2 d indexing with multiplier
		$arraydims=~s/\]\s*\[/*/g;

		my $size=ParseConstExp($arraydims); #todo should this be a call to FoldArrayToPtr
		print "found sized array of $1 size $3 in structure\n " if exists $debug{'structs'};
		push @$sd,$var;
		push @$sd,GetUddType($type).'#'.$size;
	} else {
		print "Could not parse structure member $_\n " if exists $debug{'structs'};

		push @$sd,('error' . $$errcount++ ,$_) if (!/^ ?$/);
	}
 }
 
sub ProcessStruct {
    my $cname=$_[0];
    my $sname=MakeMatlabVar($cname,'s_');
    my $members=$_[1];
    my $types=$_[2];
    if ($members=~/:/) {
        DumpInfo ("Bitfields are unsupported in structures. Structure $sname skipped." ) if $options{debug};
        return;
    }
    if ($members=~/\bunion\b/) {
        DumpInfo ("Unions are unsupported in structures. Structure $sname skipped.") if $options{debug};
        return;
    }
    if ($members =~/struct([^;,{(]*){(.*?)\}([^;])*;/) {#found an embedded struct
        DumpInfo ("Embedded structures are unsupported in structures. Structure $sname skipped.") if $options{debug} ;
        return;
        #ProcessStruct($1,$2,$3);
        #$members'';
    }
    
    AddType($cname,$sname) if $cname ne $sname;
    AddType($sname,$sname);
    ProcessTypedef($sname,$types);
    
    push @structOrder,$sname if !exists $structs{$sname};
    $structs{$sname}=ParseStruct($members);
    $structPacking{$sname}=$packing; 
    if ($inSrcFile) {
        $typesUsed{$sname}=[];
    }

}

# get the udd type for a given c type

sub GetUddType{
    my $type=cleanupType($_[0]);
    if (exists $types{$type})
    {
        $type=$types{$type};
        if ($inSrcFile  ) {
            AddUsedType($type);
        }
        
    } else { 
        my $deftype='error';
        if ($type=~/Ptr(Ptr)?$/) {
             $deftype=defined $1 ? "voidPtr$1" : "voidPtr";
        }
        DumpInfo("Type '$type' was not found.  Defaulting to type $deftype.\n") ;
        $type=$deftype;
    }
    $type;    
}

#this function returns two outputs the second is $arraysize if a fully qualified sized array is found
sub FoldArrayToPtr{
    my $type=$_[0];
    my $arraysize=undef;
    #fold declarations of type [] [5]
    $type=~ s/\[\s*\](\s*\[[^\]]*\])+/[]/g;
    
    while ($type =~ /(.*\S)\s*\[(\s*[^\]]+)\]$/){
        print "Found array size $2 of type $1 in $_\n" if exists $debug{'types'};
        $arraysize=1 if !defined $arraysize; 
        $type=$1;
        $arraysize*=ParseConstExp($2);
    }
    
    if ($type =~ s/(\w+)\s*\[([^]]*)\]/\*$1/g && exists $keywords{$1}) {
        #put pointer back if no name ie int []
        $type =~ s/(\*+)(\w+)$/$2$1/;
    }
    $type =~ s/&/*/g;
    print "type of $_[0] is $type with size $arraysize\n" if defined $arraysize && exists $debug{'types'};
   
    return ($type,$arraysize);
}


# Take a c type and remove all extra information and change * to Ptr or PtrPtr
sub cleanupType{
    my $type=$_[0];
    my $originalType=$type;
    #pull any 'const,signed, enum or struct' statements
    $type =~ s/\b(?:_{0,2}const|signed|struct|enum|volatile|__w64)\b//g; #__w64 is used on 32 bit windows to produce 64 bit compatibility warnings
    # if type has two or more words parse modifiers
    if ($type =~ /\w+[^\w]+\w+/ ) {
        my $newtype = 'int';
        $type =~ s/\bint\b//; #remove int because assumed
        $newtype = $1 if $type =~s/\b(char|short|long long|long|__int\d\d)\b//;  # also need to match Windows __int64 style types
        $newtype = 'unsigned' . $newtype if $type =~s/\bunsigned\b//;
        $type=$newtype . $type;        
        print "Translated compound type '$originalType' into $type.\n" if exists $debug{'types'};
    }
    #clean all whitespace 
    $type =~ s/\s+//g;
        
    $ptr=index($type, "*");
    if ($ptr>=0) {
        $type =~ s/\*/Ptr/g; 
        if (!exists $types{$type}) { # check to see if the base type exists and if so add the Ptr type       
            $basetype=substr($type,0,$ptr); 
            if (exists $types{$basetype}  ) { #create the new type
                #create a new pointer type
                my $newtype=$type;
                $newtype=~s/$basetype/$types{$basetype}/;
                print "Dynamically adding type '$type' to be '$newtype'\n" if exists $debug{'types'};
                AddType($type,$newtype); 
            } else {
                print "Type '$type' not added because could not find basetype of '$basetype'\n" if exists $debug{'types'};
            }                
        }            
    }
    $type;
}

#Remove leading and trailing spaces from the input string in place
sub trim{ 
    $_[0]=~s/^\s+//;
    $_[0]=~s/\s+$//;
    return;
}

#for a given uddtype return the representative c data type
sub getCtype {
    my ($uddtype,$ctype)=@_;
    return 'voidPtr' if $uddtype=~/^MATLAB array/;
    return 'voidPtr' if $uddtype=~/Ptr|\#\d+$/;
    return $uddtype if exists $MatlabType{$uddtype};
    $ctype=~s/\bconst\b//;
    trim($ctype);    
    print "For a uddtype of '$uddtype' returning '$ctype'\n" if $options{debug} eq 'thunks'; 
    return $ctype;
}

#for a given uddtype return the representative c data type
sub uddCtypeToMwType {
    my $uddtype=@_[0];
    my $ctype=exists $ThunkMatlabTypeMap{$uddtype} ? $ThunkMatlabTypeMap{$uddtype} : $uddtype;
    return $ctype;
}


#uses the following globals
#called with ($lhs,$rtype,\@parameters,\@rawParameters);
sub addFunctionThunk {
    my ($lhs,$lhsCtype,$paramsIn,$paramsCtype)=@_;
    my $thunkname;
    my $p;
    $lhs=getCtype($lhs,$lhsCtype);
    my @rhs;
    my @params;
    for  ($_=0;$_ < @$paramsIn;$_++) { #fix up input types to 
        $rhs[$_]='voidPtr' if $$paramsIn[$_]=~/Ptr|\#\d+$/;
        $rhs[$_]=getCtype($$paramsIn[$_],$$paramsCtype[$_]);
    }
    $thunkname=$lhs . join("",@rhs) . 'Thunk';
    $thunkname=~s/ //g; #remove all spaces
    if (exists $thunkTable{$thunkname}) {
        return $thunkname;
    }
    $thunkTable{$thunkname}=undef;
    $lhs= uddCtypeToMwType($lhs);
    print THUNKFILE "/* $str */\n";
    print THUNKFILE "EXPORT_EXTERN_C $lhs $thunkname(void fcn(),const char *callstack,int stacksize)\n{\n";
    @rhs= map  uddCtypeToMwType($_) , @rhs;
    if (@rhs==1 && $rhs[0] eq 'void') {
        @params=();
    } else {
        $p=0;
        foreach (@rhs) {
            print THUNKFILE "\t$_ p$p;\n";
            push @params,"p$p";
            $p+=1;
        }
        $p=0;
        foreach (@rhs) {
            print THUNKFILE "\tp$p=*($_ const *)callstack;\n";
            print THUNKFILE "\tcallstack+=sizeof(p$p) % sizeof(size_t) ? ((sizeof(p$p) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p$p);\n";
            $p+=1;
        }
    }
    if ($lhs eq 'void') {
        print THUNKFILE "\t(($lhs (*)(", join(" , ",@rhs) ," ))fcn)(",join(" , ",@params),");\n}\n\n";
    } else {
        print THUNKFILE "\treturn (($lhs (*)(", join(" , ",@rhs) ," ))fcn)(",join(" , ",@params),");\n}\n\n";
    }
    return $thunkname;
}

sub DumpInfo{
    $exitcode=1;
    print "\n@_\n";
    my $line=$.-$srcLine;
    print "Found on line $. of input from line $line of file $srcFile\n";
}

sub DumpError{
    DumpInfo( "ERROR: @_");
    confess("Working string is '$str'.\n");
}



sub parsArgs
{
%options=@_; #qw(s 1 d 0 m 0 r 0 a 0 l 1 e path);
my @inputs;
#parse the input for options
while (@ARGV) {
	$_=shift @ARGV;
	if (/^-(\w+)/) { 
		my $opt=$1;
		#now look for special opts
		if (/-debug=/) {
		  $debug{$'}=1;
		  $options{'debug'}=$'; #for compatibility  
		} elsif (/-\w+=/) { #options that store there own string
		  #print "found string option '$opt' in '$_'.\n";
			$options{$opt}=$'; #' fix editor highlighting 
		} elsif (/-\w+-/) { #disable opt
			$options{$opt}=0;
		} elsif (/-\w+\+/) {
			$options{$opt}=1;
		} else { $options{$opt}=!$options{$opt};}
		print "option $opt is now $options{$opt}\n" if ($options{debug});
				
	} else {
		push (@inputs,$_);
	}
}
#put ARGV back
@ARGV=@inputs;
}
