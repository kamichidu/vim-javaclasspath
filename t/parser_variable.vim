set runtimepath+=./.vim-test/*
filetype plugin indent on

describe 'javaclasspath#parser#variable.parse()'
    before
        let s:parser= javaclasspath#parser#variable#define()
    end

    after
        unlet s:parser
    end

    it 'return paths directly'
        let l:paths= s:parser.parse({
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

        Expect l:paths == [
        \   {
        \       'kind': 'lib',
        \       'path': 'path/to/jar',
        \   },
        \   {
        \       'kind': 'src',
        \       'path': 'path/to/srcdir',
        \   },
        \]
    end

    it 'return empty list when arguments not passed'
        let l:paths= s:parser.parse({})

        Expect l:paths == []

        let l:paths= s:parser.parse({'paths': []})

        Expect l:paths == []
    end
end
