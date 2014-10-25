let s:suite= themis#suite('standard parser')
let s:assert= themis#helper('assert')
call themis#helper('command')

function! s:suite.before_each()
    let s:save_java_home= $JAVA_HOME
    let s:parser= javaclasspath#parser#standard#define()
endfunction

function! s:suite.after_each()
    let $JAVA_HOME= s:save_java_home
    unlet s:parser
endfunction

function! s:suite.__parse__()
    let parse_suite= themis#suite('parse()')

    function! parse_suite.returns_fully_filename_via_JAVA_HOME()
        if !exists('$JAVA_HOME')
            call s:assert.skip('$JAVA_HOME is not exists.')
        endif

        let paths= s:parser.parse({
        \   'libs': [
        \       {
        \           'path': 'jre/lib/rt.jar',
        \       },
        \   ],
        \})

        call s:assert.equals(paths, [{'kind': 'lib', 'path': globpath($JAVA_HOME, 'jre/lib/rt.jar')}])
    endfunction

    function! parse_suite.returns_fully_filename_via_arguments()
        let $JAVA_HOME= ''
        let paths= s:parser.parse({
        \   'java_home': s:save_java_home,
        \   'libs': [
        \       {
        \           'path': 'jre/lib/rt.jar',
        \       },
        \   ],
        \})
        let $JAVA_HOME= s:save_java_home

        call s:assert.equals(paths, [{'kind': 'lib', 'path': globpath($JAVA_HOME, 'jre/lib/rt.jar')}])
    endfunction

    function! parse_suite.returns_empty_list_when_no_arguments_is_given()
        call s:assert.equals([], s:parser.parse({
        \   'libs': [],
        \}))
        call s:assert.equals([], s:parser.parse({}))
    endfunction
endfunction
