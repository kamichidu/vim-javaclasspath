"
" The MIT License (MIT)
"
" Copyright (c) 2014 kamichidu
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
"
let s:save_cpo= &cpo
set cpo&vim

let s:V= vital#of('javaclasspath')
let s:L= s:V.import('Data.List')
unlet s:V

let s:helper= {}

function! s:helper.arguments(defs)
    let l:obj= {
    \   'defs': deepcopy(a:defs),
    \}

    let l:obj.properties= keys(copy(l:obj.defs))
    let l:obj.requires= filter(keys(copy(l:obj.defs)), 'get(l:obj.defs[v:val], "required", 0)')

    function! l:obj.apply(args)
        " only has a defined keys
        let l:invalid_keys= filter(copy(keys(a:args)), '!s:L.has(self.properties, v:val)')
        if !empty(l:invalid_keys)
            throw 'javaclasspath: Unknown argument: ' . string(l:invalid_keys)
        endif
        unlet l:invalid_keys

        " required
        let l:missing_requires= filter(copy(self.requires), '!has_key(a:args, v:val)')
        if !empty(l:missing_requires)
            throw 'javaclasspath: Missing required properties: ' . string(l:missing_requires)
        endif
        unlet l:missing_requires

        " type constraint
        let l:type_mismatches= []
        for l:property in keys(a:args)
            let l:def= self.defs[l:property]

            if has_key(l:def, 'type')
                let l:value= a:args[l:property]

                if type(l:value) !=# l:def.type
                    call add(l:type_mismatches, printf('%s is expected %s type, actually got %s', l:property, s:type_string(l:def.type), string(l:value)))
                endif

                unlet l:value
            endif

            unlet l:def
        endfor
        if !empty(l:type_mismatches)
            throw 'javaclasspath: ' . join(l:type_mismatches, "\n")
        endif
        unlet l:property
        unlet l:type_mismatches

        return a:args
    endfunction

    return l:obj
endfunction

function! s:helper.info(message)
    echomsg 'javaclasspath: ' . a:message
endfunction

function! s:helper.warn(message)
    echohl WarningMsg
    echomsg 'javaclasspath: ' . a:message
    echohl None
endfunction

function! s:helper.error(message)
    echohl ErrorMsg
    echomsg 'javaclasspath: ' . a:message
    echohl None
endfunction

function! s:type_string(type_num)
    if a:type_num ==# type(0)
        return 'Num'
    elseif a:type_num ==# type('')
        return 'Str'
    elseif a:type_num ==# type(function('tr'))
        return 'Func'
    elseif a:type_num ==# type([])
        return 'List'
    elseif a:type_num ==# type({})
        return 'Dict'
    elseif a:type_num ==# type(0.0)
        return 'Float'
    endif
    return 'Unknown'
endfunction

function! javaclasspath#helper#get()
    return deepcopy(s:helper)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
