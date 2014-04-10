set runtimepath+=./.vim-test/*
filetype plugin indent on

describe 'javaclasspath#parser#variable.parse()'
    before
        let g:javaclasspath_config= {
        \   'variable': {
        \       'paths': [
        \           {
        \               'kind': 'lib',
        \               'path': 'path/to/jar',
        \           },
        \           {
        \               'kind': 'src',
        \               'path': 'path/to/srcdir',
        \           },
        \       ],
        \   },
        \}
        let s:parser= javaclasspath#get()
    end

    after
        unlet g:javaclasspath_config
        unlet s:parser
    end

    it 'return g:javaclasspath_config.variable.paths'
        let l:paths= s:parser.parse()

        Expect l:paths == g:javaclasspath_config.variable.paths
    end
end
