# version

version := '2.2.0'

# variables

c-extra-flags := '-Wno-unused'

# constants

cc := 'gcc'
cd := 'gdb'
ct := 'valgrind'
c-standard := 'c23'
c-common-flags := '-std=' + c-standard + ' -pedantic -W -Wall -Wextra ' + c-extra-flags
c-release-flags := c-common-flags + ' -Werror -O2'
c-debug-flags := c-common-flags + ' -O1 -g -g' + cd

# rules

os-build-dir := './build' / os()
project-name := `basename $(pwd)`
just-self := just_executable() + ' --justfile ' + justfile()

_:
    @ just --list

_validate mode:
    @ if [ '{{ mode }}' != 'debug' ] && [ '{{ mode }}' != 'release' ]; then echo '`mode` must be: `debug` or `release`, not `{{ mode }}`'; exit 1; fi

# build project (`mode` must be: `debug` or `release`)
build mode: (_validate mode)
    @ mkdir -p '{{ os-build-dir / project-name }}'
    @ {{ just-self }} '_build_{{ mode }}'

_build_debug:
    {{ cc }} {{ c-debug-flags }} src/*.c --output '{{ os-build-dir / project-name }}/debug'

_build_release:
    {{ cc }} {{ c-release-flags }} src/*.c --output '{{ os-build-dir / project-name }}/release'

# execute project's binary (`mode` must be: `debug` or `release`)
run mode *args: (build mode)
    '{{ os-build-dir / project-name / mode }}' {{ args }}

# start debugger
debug: (build 'debug')
    {{ cd }} '{{ os-build-dir / project-name / "debug" }}'

# clean project's `build` directory
clean:
    rm -rf '{{ os-build-dir }}'

# run a memory error detector `valgrind`
test mode *args: (build mode)
    {{ ct }} --leak-check=full --show-leak-kinds=all --track-origins=yes '{{ os-build-dir / project-name / mode }}' {{ args }}
