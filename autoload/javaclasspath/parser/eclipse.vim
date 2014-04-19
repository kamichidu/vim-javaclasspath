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
\   },
\}

" classpath entry maker for supported kinds {{{
let s:maker= {
\   'lib': {},
\   'src': {},
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
" }}}

function! s:obj.parse(config)
    if !filereadable(a:config.filename)
        return []
    endif

    let l:dom= s:X.parseFile(a:config.filename)
    let l:classpaths= []

    for l:entry in l:dom.childNodes('classpathentry')
        if has_key(s:maker, l:entry.attr.kind)
            let l:maker= s:maker[l:entry.attr.kind]

            if l:maker.can(a:config, l:entry)
                call add(l:classpaths, l:maker.create(a:config, l:entry))
            endif
        endif
    endfor

    return l:classpaths
endfunction

function! javaclasspath#parser#eclipse#define()
    return deepcopy(s:obj)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
