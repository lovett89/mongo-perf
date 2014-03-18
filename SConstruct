# -*- mode: python; -*-
import os

AddOption("--extrapath", dest="extrapath", type=str, action="store",
          help=("comma-separated list of paths to search for header files "
                "and libraries"))

env = Environment()

def add_paths(string):
    for path in string.split(","):
        if os.path.exists(path) and os.path.isdir(path):
            # for header files included as dir/header.cpp
            env.Append(CPPPATH=[path])

            base = os.path.basename
            is_lib_dir = lambda s: os.path.isdir(s) and base(s).startswith("lib")
            is_cpp_dir = lambda s: os.path.isdir(s) and base(s).startswith("include")
            for p in os.listdir(path):
                abspath = os.path.join(path, p)
                if is_lib_dir(abspath):
                    env.Append(LIBPATH=[abspath])
                elif is_cpp_dir(abspath):
                    env.Append(CPPPATH=[abspath])

if GetOption("extrapath") is not None:
    add_paths(GetOption("extrapath"))

is_windows = (os.sys.platform == 'win32')

if is_windows:
    cpp_flags = ['/EHsc']
    link_flags = []
else:
    cpp_flags = ['-g']
    link_flags = ['-g']

if not 'darwin' == os.sys.platform and not is_windows:
    cpp_flags.extend(['-O2', '-pthread'])
    link_flags.append('-pthread')

env.Append(CPPFLAGS=cpp_flags)
env.Append(LINKFLAGS=link_flags)

if 'darwin' == os.sys.platform:
    add_paths('/opt/local')
if is_windows:
    # Try to find mongo-cxx-driver in C:\usr\local
    add_paths("C:\usr\local")

    # Try to find boost in C:\local
    if os.path.exists("C:\local"):
        for dir in os.listdir("C:\local"):
            abspath = os.path.join("C:\local", dir)
            if os.path.isdir(abspath) and dir.startswith("boost"):
                add_paths(abspath)
else:
    # use included mongo-cxx-driver
    env.Append(CPPPATH=['mongo-cxx-driver/src'])
    env.Append(CPPPATH=['mongo-cxx-driver/src/mongo'])
    env.Append(LIBPATH=['mongo-cxx-driver'])

conf = Configure( env )
if is_windows:
    libs = ["mongoclient"]
else:
    libs = ["mongoclient",
            "boost_graph",
            "boost_thread",
            "boost_filesystem",
            'boost_program_options',
            'boost_system']

def checkLib( lib ):
    if lib.startswith('boost_'):
        if conf.CheckLib( lib + '-mt' ):
            return True

    if conf.CheckLib( lib ):
        return True

    print( "Error: can't find library: " + str( lib ) )
    Exit(-1)
    return False

for x in libs:
    checkLib( x )

env = conf.Finish()

env.Program(target = './benchmark', source = 'core/benchmark.cc')
env.Program('bench-report', ["report/report.cc",
                             "report/CSVFormatter.cc",
                             "report/Formatter.cc"])
