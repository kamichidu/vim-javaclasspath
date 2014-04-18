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

    it 'return paths from .classpath'
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
