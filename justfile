# variables

justfile-version := '1.0.0'
c-extra-flags := ''

# configuration

cc := 'gcc'
c-standard := 'c23'
c-common-flags := '-std=' + c-standard + ' -pedantic -W -Wall -Wextra -Werror'
c-release-flags := c-common-flags + ' -O3 ' + c-extra-flags
c-debug-flags := c-common-flags + ' -g2 -ggdb ' + c-extra-flags

# rules

current-dir := `pwd`
os-build-dir := './build' / os()
just-self := just_executable() + ' --justfile ' + justfile()

_validate mode:
    @ if [ '{{ mode }}' != 'debug' ] && [ '{{ mode }}' != 'release' ]; then echo '`mode` must be: `debug` or `release`, not `{{ mode }}`'; exit 1; fi

# build project (`mode` must be: `debug` or `release`)
build mode: (_validate mode)
    @ {{ just-self }} '_build_{{ mode }}' `basename {{ current-dir }}`

_build_debug project-name:
    @ mkdir -p '{{ os-build-dir / project-name }}'
    {{ cc }} {{ c-debug-flags }} src/*.c -o '{{ os-build-dir / project-name }}/debug'

_build_release project-name:
    @ mkdir -p '{{ os-build-dir / project-name }}'
    {{ cc }} {{ c-release-flags }} src/*.c -o '{{ os-build-dir / project-name }}/release'

# execute project's binary (`mode` must be: `debug` or `release`)
run mode *args: (build mode)
    @ {{ just-self }} '_run_{{ mode }}' `basename {{ current-dir }}` {{ args }}

_run_debug project-name *args:
    '{{ os-build-dir / project-name }}/debug' {{ args }}

_run_release project-name *args:
    '{{ os-build-dir / project-name }}/release' {{ args }}

# start debugger
debug: (build 'debug')
    @ {{ just-self }} _gdb `basename {{ current-dir }}`

_gdb project-name:
    gdb '{{ os-build-dir / project-name }}/debug'

# clean project's `build` directory
clean:
    rm -rf '{{ os-build-dir }}'
