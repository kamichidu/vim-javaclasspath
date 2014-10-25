let s:suite= themis#suite('variable parser')
let s:assert= themis#helper('assert')

function! s:suite.before_each()
    let s:parser= javaclasspath#parser#variable#define()
endfunction

function! s:suite.after_each()
    unlet s:parser
endfunction

function! s:suite.__parse__()
    let parse_suite= themis#suite('parse()')

    function! parse_suite.returns_paths_directly()
        let paths= s:parser.parse({
        \   'paths': [
        \       {
        \           'kind': 'lib',
        \           'path': 'path/to/jar',
        \       },
        \       {
        \           'kind': 'src',
        \           'path': 'path/to/srcdir',
        \       },
        \   ],
        \})

        call s:assert.equals(paths, [
        \   {
        \       'kind': 'lib',
        \       'path': 'path/to/jar',
        \   },
        \   {
        \       'kind': 'src',
        \       'path': 'path/to/srcdir',
        \   },
        \])
    endfunction

    function! parse_suite.returns_empty_list_when_no_arguments_is_given()
        call s:assert.equals(s:parser.parse({}), [])
        call s:assert.equals(s:parser.parse({'paths': []}), [])
    endfunction
endfunction
