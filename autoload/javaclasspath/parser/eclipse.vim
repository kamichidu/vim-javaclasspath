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
let s:X= s:V.import('Web.XML')
let s:L= s:V.import('Data.List')
let s:S= s:V.import('Data.String')
unlet s:V

let s:obj= {
\   'name': 'eclipse',
\   'config': {
\       'filename': {
\           'type':     type(''),
\           'required': 1,
\       },
\       'vars': {
\           'type': type([]),
\       },
\   },
\}

" classpath entry maker for supported kinds {{{
let s:maker= {
\   'lib': {},
\   'src': {},
\   'var': {},
\}

function! s:maker.lib.can(config, entry)
    return 1
endfunction

function! s:maker.lib.create(config, entry)
    return {
    \   'kind': 'lib',
    \   'path': a:entry.attr.path,
    \}
endfunction

function! s:maker.src.can(config, entry)
    return 1
endfunction

function! s:maker.src.create(config, entry)
    return {
    \   'kind': 'src',
    \   'path': a:entry.attr.path,
    \}
endfunction

function! s:maker.var.can(config, entry)
    let vars= get(a:config, 'vars', {})

    let var_name= matchstr(a:entry.attr.path, '^\w\+')

    return has_key(vars, var_name)
endfunction

function! s:maker.var.create(config, entry)
    let var_name= matchstr(a:entry.attr.path, '^\w\+')
    let var_value= a:config.vars[var_name]

    return {
    \   'kind': 'lib',
    \   'path': s:S.replace_first(a:entry.attr.path, var_name, var_value),
    \}
endfunction
" }}}

function! s:obj.parse(config)
    if !filereadable(a:config.filename)
        return []
    endif

    let dom= s:X.parseFile(a:config.filename)
    let classpaths= []

    for entry in dom.childNodes('classpathentry')
        if has_key(s:maker, entry.attr.kind)
            let maker= s:maker[entry.attr.kind]

            if maker.can(a:config, entry)
                call add(classpaths, maker.create(a:config, entry))
            endif
        endif
    endfor

    return classpaths
endfunction

function! javaclasspath#parser#eclipse#define()
    return deepcopy(s:obj)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
