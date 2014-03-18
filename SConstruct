# -*- mode: python; -*-
import os

env = Environment()

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
    if os.path.exists('/opt/local/include'):
        env.Append(CPPPATH=['/opt/local/include'])
    if os.path.exists('/opt/local/lib'):
        env.Append(LIBPATH=['/opt/local/lib'])

if is_windows:
    # mongo-cxx-driver installs to C:\usr\local
    env.Append(CPPPATH=[r'C:/usr/local'])
    env.Append(CPPPATH=[r'C:/usr/local/include'])
    env.Append(CPPPATH=[r'C:/usr/local/include/mongo'])
    env.Append(LIBPATH=[r'C:\usr\local\lib'])

    # assume that boost is in C:\local
    if os.path.exists("C:\local"):
        # find boost library
        boost_dirs = []
        for dir in os.listdir("C:\local"):
            abspath = os.path.join("C:\local", dir)
            if os.path.isdir(abspath) and dir.startswith("boost"):
                boost_dirs.append(abspath)

        for dir in boost_dirs:
            env.Append(CPPPATH=[dir])
            env.Append(CPPPATH=[os.path.join(dir, "boost")])
            for lib in os.listdir(dir):
                abspath = os.path.join(dir, lib)
                if os.path.isdir(abspath) and lib.startswith("lib"):
                    env.Append(LIBPATH=[abspath])
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
