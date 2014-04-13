set runtimepath+=./.vim-test/*
filetype plugin indent on

describe 'arguments object of helper'
    before
        let s:helper= javaclasspath#helper#get()
    end

    after
        unlet s:helper
    end

    it 'checks arguments'
        let obj= s:helper.arguments({
        \   'mes': {
        \       'required': 1,
        \       'type': type(''),
        \   },
        \})

        Expect expr { obj.apply({}) } to_throw
        Expect expr { obj.apply({'mes': 0}) } to_throw
        Expect expr { obj.apply({'mes': 0.0}) } to_throw
        Expect expr { obj.apply({'mes': {}}) } to_throw
        Expect expr { obj.apply({'mes': []}) } to_throw
        Expect obj.apply({'mes': 'hello'}) == {'mes': 'hello'}
    end
end
