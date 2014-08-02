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
let s:P= s:V.import('Process')
unlet s:V

let s:jlang= javalang#get()
let s:timestamp_cache= {}
let s:classpath_cache= {}

let s:obj= {
\   'name': 'maven',
\   'config': {
\       'filename': {
\           'type':     type(''),
\           'required': 1,
\       },
\   },
\}

function! s:obj.parse(config)
    if !(filereadable(a:config.filename) && executable('mvn'))
        return []
    endif
    let path= fnamemodify(a:config.filename, ':p')
    let timestamp= getftime(path)

    if has_key(s:timestamp_cache, path) && s:timestamp_cache[path] == timestamp
        return deepcopy(s:classpath_cache[path])
    endif

    let tfile= tempname()
    let cmd=   'mvn dependency:build-classpath -Dmdep.outputFile=' . tfile

    call s:P.system(cmd)

    let classpath= join(readfile(tfile), s:jlang.constants.path_separator)

    let classpaths= map(split(classpath, s:jlang.constants.path_separator, 0), "
    \   {
    \       'kind': 'lib',
    \       'path': v:val,
    \   }
    \")

    let s:timestamp_cache[path]= timestamp
    let s:classpath_cache[path]= deepcopy(classpaths)

    return classpaths
endfunction

function! javaclasspath#parser#maven#define()
    return deepcopy(s:obj)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
