let s:suite= themis#suite('javaclasspath')
let s:assert= themis#helper('assert')

function! s:suite.before_each()
    new
    set filetype=java
    let s:save_javaclasspath_config= g:javaclasspath_config
endfunction

function! s:suite.after_each()
    close!
    let g:javaclasspath_config= s:save_javaclasspath_config
endfunction

function! s:suite.__gets_parsers__()
    let gets_parsers= themis#suite('gets parsers')

    function! gets_parsers.by_global_config()
        let g:javaclasspath_config= {'standard': {}}

        let parsers= javaclasspath#get_parsers()

        call s:assert.is_list(parsers)
        call s:assert.length_of(parsers, 1)
        call s:assert.same(parsers[0].name, 'standard')
    endfunction

    function! gets_parsers.by_empty_buffer_config()
        let b:javaclasspath_config= {}

        let parsers= javaclasspath#get_parsers()

        call s:assert.is_list(parsers)
        call s:assert.length_of(parsers, 0)
    endfunction

    function! gets_parsers.by_buffer_config()
        let b:javaclasspath_config= {'standard': {}}

        let parsers= javaclasspath#get_parsers()

        call s:assert.is_list(parsers)
        call s:assert.length_of(parsers, 1)
        call s:assert.same(parsers[0].name, 'standard')
    endfunction
endfunction

function! s:suite.__gets_config__()
    let gets_config= themis#suite('gets a config')

    function! gets_config.by_global()
        let config= javaclasspath#get_config()

        call s:assert.equals(config, g:javaclasspath_config)
    endfunction

    function! gets_config.by_buffer()
        let b:javaclasspath_config= {'standard': {}}

        let config= javaclasspath#get_config()

        call s:assert.equals(config, b:javaclasspath_config)
    endfunction
endfunction

function! s:suite.gets_classpath()
    let g:javaclasspath_config= {
    \   'variable': {
    \       'paths': [
    \           {
    \               'kind': 'lib',
    \               'path': 'hoge',
    \           },
    \           {
    \               'kind': 'src',
    \               'path': 'fuga',
    \           },
    \       ],
    \   },
    \}

    let classpath= javaclasspath#classpath()

    call s:assert.is_string(classpath)
    call s:assert.same(classpath, 'hoge')
endfunction

function! s:suite.gets_source_path()
    let g:javaclasspath_config= {
    \   'variable': {
    \       'paths': [
    \           {
    \               'kind': 'lib',
    \               'path': 'hoge',
    \           },
    \           {
    \               'kind': 'src',
    \               'path': 'fuga',
    \           },
    \       ],
    \   },
    \}

    let source_path= javaclasspath#source_path()

    call s:assert.is_string(source_path)
    call s:assert.same(source_path, 'fuga')
endfunction

function! s:suite.__java_home__()
    let java_home= themis#suite('$JAVA_HOME')

    function! java_home.gets_by_buffer_variable()
        let g:javaclasspath_config= {
        \   'standard': {
        \       'java_home': 'HOGE'
        \   },
        \}
        let b:javaclasspath_config= {
        \   'standard': {
        \       'java_home': 'hoge'
        \   },
        \}

        call s:assert.same(javaclasspath#java_home(), 'hoge')
    endfunction

    function! java_home.gets_by_global_variable()
        let g:javaclasspath_config= {
        \   'standard': {
        \       'java_home': 'HOGE'
        \   },
        \}

        call s:assert.same(javaclasspath#java_home(), 'HOGE')
    endfunction

    function! java_home.gets_by_environment_variable()
        call s:assert.same(javaclasspath#java_home(), $JAVA_HOME)
    endfunction
endfunction
