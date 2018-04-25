# Copyright 2014-2016 MathWorks, Inc.
"""Query Python for the information necessary to initialize an embedded interpreter.

Example

  C:\Python33\python.exe env_data.py

"""
import sys
import platform
import os
try:
    from ctypes.util import find_library
except ImportError:
    find_library = lambda x: None
try:
    from sys import abiflags
except ImportError:
    abiflags = ''


def version():
    """Python interpreter version in major.minor form"""
    return '%d.%d' % (sys.version_info[0], sys.version_info[1])


def executable():
    """absolute path of the executable binary for the Python interpreter"""
    return sys.executable


def home():
    """default 'home' directory, that is, the location of the standard Python libraries

    When home is a single directory, its value is used for both sys.prefix and sys.exec_prefix. 
    When sys.prefix and sys.exec_prefix are different values, home is prefix:exec_prefix.
    """
    if sys.prefix == sys.exec_prefix:
        return sys.prefix
    else:
        return ':'.join((sys.prefix, sys.exec_prefix))


class LibraryFinder(object):
    """Class representing a finder for the Python shared library.

    Peek in a number of locations for the library:
         1. folder with executable
         2. <home>/lib/ folder
         3. ask ctypes.util.find_library
    """

    def __init__(self):
        if os.name == 'nt':
            self._libname = 'python%d%d%s' % (sys.version_info[0],
                                              sys.version_info[1], abiflags)
        else:
            self._libname = 'python%d.%d%s' % (sys.version_info[0],
                                               sys.version_info[1], abiflags)
        self.search_locations = []
        self._create_plan()

    def _create_plan(self):
        """Formulate search plan to find the library."""
        self.search_locations.append(self._check_exe_folder)
        self.search_locations.append(self._check_lib_folder)
        self.search_locations.append(self._ask_ctypes)

    def find(self):
        """find Python shared library

        Returns absolute path if search is successful.
        Returns None if unsuccessful.
        """
        for method in self.search_locations:
            out = method()
            if out is not None:
                return out
        return None

    def _check_folder(self, folder):
        """helper function to check for presence of Python shared library in a given folder

        folder is folder to inspect.
        Returns absolute path if shared library is found.
        Returns None if not found.
        """
        if os.path.exists(folder):
            def ismatch(name):
                # check for libpythonXX or pythonXX... and shared library extension
                sl_name = (self._libname, 'lib' + self._libname)
                sl_ext = ('.dll', '.so', '.dylib')
                return name.startswith(sl_name) and name.endswith(sl_ext)
            names = [n for n in os.listdir(folder) if ismatch(n)]
            if len(names) > 0:
                return os.path.join(folder, names[0])
        return None

    def _check_exe_folder(self):
        """check if shared library is in same folder with executable

        Returns absolute path to library if available.
        Returns None if not available.
        """
        executable_folder = os.path.split(sys.executable)[0]
        return self._check_folder(executable_folder)        

    def _check_lib_folder(self):
        """check if shared library is in <home>/lib

        Returns absolute path to library if available.
        Returns None if not available.
        """
        possible_homes = []
        try:
            possible_homes.append(sys.prefix)
            possible_homes.append(sys.exec_prefix)
            possible_homes.append(sys.base_prefix) # base home for venv
            possible_homes.append(sys.base_exec_prefix)
        except AttributeError:
             # sys.base_prefix and sys.base_exec_prefix aren't available in 2.7
             pass
        for home in set(possible_homes):
            lib_folder = os.path.join(home, 'lib')
            abpath = self._check_folder(lib_folder)
            if abpath is not None:
                return abpath

    def _ask_ctypes(self):
        """query ctypes for location of shared library for the Python interpreter

        Returns absolute path to shared library.
        Returns None if the library is not found.
        """
        if os.name == 'nt':
            libpath = find_library(self._libname)
            libpath = libpath if libpath is not None else find_library(self._libname + '.dll')
        else:
            libpath = find_library(self._libname)
        return str(libpath) if libpath is not None else libpath


def library():
    """absolute path of the shared library for the Python interpreter"""
    finder = LibraryFinder()
    p = finder.find()
    return p if p else ''


def path():
    """default module search path

    Returns a string consisting of a series of directory names separated by
    semicolons.
    """
    # Exclude path to this script from path.
    this_file = os.path.realpath(__file__)
    this_path = os.path.dirname(this_file)
    return os.pathsep.join(p for p in sys.path if p != this_path) 


def bitness():
    """bitness of Python executable determined from sys.maxsize
 
    Returns '32-bit' or '64-bit' depending on sys.maxsize.
    """
    # see https://docs.python.org/2/library/platform.html#platform.architecture
    return '64-bit' if sys.maxsize > 2**32 else '32-bit'


def main():
    message = """struct('version', '%s',...
        'executable', '%s',...
        'library', '%s',...
        'home', '%s',...
        'path', '%s',...
        'bitness', '%s');
    """
    data = (version(), executable(), library(), home(), path(), bitness())
    #sys.stdout.write(message % data)
    sys.stdout.write('\n'.join(data))


if __name__=='__main__':
    main()
