set runtimepath+=./.vim-test/*
filetype plugin indent on

describe 'javaclasspath#parser#eclipse.parse()'
    before
        let s:parser= javaclasspath#parser#eclipse#define()
        let s:save_cwd= getcwd()
    end

    after
        execute 'cd' s:save_cwd
        unlet s:save_cwd
        unlet s:parser
    end

    it 'return lib and src paths from .classpath'
        cd t/conf-ex/
        let l:paths= s:parser.parse({
        \   'filename': '.classpath',
        \})

        Expect l:paths == [
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
        \]
    end

    it 'return lib and src and var paths from .classpath'
        cd t/conf-ex/
        let l:paths= s:parser.parse({
        \   'filename': '.classpath',
        \   'vars': {
        \       'ECLIPSE_HOME': 'eclipse-home',
        \   },
        \})

        Expect l:paths == [
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
        \]
    end

    it 'return empty list when file not found'
        cd t/conf-ex/
        let l:paths= s:parser.parse({
        \   'filename': 'teketo',
        \})

        Expect l:paths == []
    end

    it 'throw when not passed filename key'
        cd t/conf-ex/

        let g:parser= s:parser
        Expect expr { g:parser.parse({}) } to_throw
        unlet g:parser
    end
end
