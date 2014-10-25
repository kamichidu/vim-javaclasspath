let s:suite= themis#suite('eclipse parser')
let s:assert= themis#helper('assert')
call themis#helper('command')

function! s:suite.before_each()
    let s:parser= javaclasspath#parser#eclipse#define()
    let s:save_cwd= getcwd()
endfunction

function! s:suite.after_each()
    execute 'cd' s:save_cwd
    unlet s:save_cwd
    unlet s:parser
endfunction

function! s:suite.__parse__()
    let parse_suite= themis#suite('parse()')

    function! parse_suite.returns_lib_and_src_paths()
        cd t/conf-ex/

        let paths= s:parser.parse({
        \   'filename': '.classpath',
        \})

        call s:assert.equals(paths, [
        \   {
        \       'kind': 'src',
        \       'path': 'src',
        \   },
        \   {
        \       'kind': 'src',
        \       'path': 'test',
        \   },
        \   {
        \       'kind': 'src',
        \       'path': 'conf',
        \   },
        \   {
        \       'kind': 'src',
        \       'path': '/HibernateSQLite',
        \   },
        \   {
        \       'kind': 'lib',
        \       'path': 'lib/commons-io.jar',
        \   },
        \   {
        \       'kind': 'lib',
        \       'path': 'lib/guava.jar',
        \   },
        \   {
        \       'kind': 'lib',
        \       'path': 'build/lib/hibernate-tools-4.0.0.jar',
        \   },
        \])
    endfunction

    function! parse_suite.returns_lib_and_src_and_var_paths()
        cd t/conf-ex/

        let paths= s:parser.parse({
        \   'filename': '.classpath',
        \   'vars': {
        \       'ECLIPSE_HOME': 'eclipse-home',
        \   },
        \})

        call s:assert.equals(paths, [
        \   {
        \       'kind': 'src',
        \       'path': 'src',
        \   },
        \   {
        \       'kind': 'src',
        \       'path': 'test',
        \   },
        \   {
        \       'kind': 'src',
        \       'path': 'conf',
        \   },
        \   {
        \       'kind': 'lib',
        \       'path': 'eclipse-home/plugins/org.eclipse.core.commands_3.6.1.v20120814-150512.jar',
        \   },
        \   {
        \       'kind': 'lib',
        \       'path': 'eclipse-home/plugins/org.eclipse.equinox.common_3.6.100.v20120522-1841.jar',
        \   },
        \   {
        \       'kind': 'lib',
        \       'path': 'eclipse-home/plugins/org.eclipse.jface_3.8.101.v20120817-083647.jar',
        \   },
        \   {
        \       'kind': 'lib',
        \       'path': 'eclipse-home/plugins/org.eclipse.osgi_3.8.1.v20120830-144521.jar',
        \   },
        \   {
        \       'kind': 'lib',
        \       'path': 'eclipse-home/plugins/org.eclipse.swt.gtk.linux.x86_64_3.100.1.v4234e.jar',
        \   },
        \   {
        \       'kind': 'lib',
        \       'path': 'eclipse-home/plugins/org.eclipse.ui.workbench_3.103.1.v20120906-120042.jar',
        \   },
        \   {
        \       'kind': 'src',
        \       'path': '/HibernateSQLite',
        \   },
        \   {
        \       'kind': 'lib',
        \       'path': 'lib/commons-io.jar',
        \   },
        \   {
        \       'kind': 'lib',
        \       'path': 'lib/guava.jar',
        \   },
        \   {
        \       'kind': 'lib',
        \       'path': 'build/lib/hibernate-tools-4.0.0.jar',
        \   },
        \])
    endfunction

    function! parse_suite.returns_empty_list_when_file_not_found()
        cd t/conf-ex/

        let paths= s:parser.parse({
        \   'filename': 'teketo',
        \})

        call s:assert.equals(paths, [])
    endfunction
endfunction
