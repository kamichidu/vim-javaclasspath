set runtimepath+=./.vim-test/*
filetype plugin indent on

describe 'javaclasspath#parser#standard.parse()'
    before
        let s:save_java_home= $JAVA_HOME
        let s:parser= javaclasspath#parser#standard#define()
    end

    after
        let $JAVA_HOME= s:save_java_home
        unlet s:parser
    end

    it 'return fully filename via $JAVA_HOME'
        if !exists('$JAVA_HOME')
            SKIP '$JAVA_HOME is not exists.'
        endif

        let l:paths= s:parser.parse({
        \   'libs': [
        \       {
        \           'path': 'jre/lib/rt.jar',
        \       },
        \   ],
        \})

        Expect l:paths == [{'kind': 'lib', 'path': globpath($JAVA_HOME, 'jre/lib/rt.jar')}]
    end

    it 'return fully filename via arguments'
        let $JAVA_HOME= ''
        let l:paths= s:parser.parse({
        \   'java_home': s:save_java_home,
        \   'libs': [
        \       {
        \           'path': 'jre/lib/rt.jar',
        \       },
        \   ],
        \})
        let $JAVA_HOME= s:save_java_home

        Expect l:paths == [{'kind': 'lib', 'path': globpath($JAVA_HOME, 'jre/lib/rt.jar')}]
    end

    it 'return empty list when arguments not passed'
        let l:paths= s:parser.parse({
        \   'libs': [],
        \})

        Expect l:paths == []

        let l:paths= s:parser.parse({
        \})

        Expect l:paths == []
    end
end
