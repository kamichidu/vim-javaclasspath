let s:suite= themis#suite('helper object')
let s:assert= themis#helper('assert')
call themis#helper('command')

function! s:suite.before_each()
    let s:helper= javaclasspath#helper#get()
endfunction

function! s:suite.after_each()
    unlet s:helper
endfunction

function! s:suite.checks_arguments()
    let obj= s:helper.arguments({
    \   'mes': {
    \       'required': 1,
    \       'type': type(''),
    \   },
    \})

    Throws /^javaclasspath:/ obj.apply({'mes': 0})
    Throws /^javaclasspath:/ obj.apply({'mes': 0.0})
    Throws /^javaclasspath:/ obj.apply({'mes': {}})
    Throws /^javaclasspath:/ obj.apply({'mes': []})

    call s:assert.equals({'mes': 'hello'}, obj.apply({'mes': 'hello'}))
endfunction
