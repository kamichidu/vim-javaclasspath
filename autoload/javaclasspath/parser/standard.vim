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

let s:obj= {
\   'name': 'standard',
\}

function! s:obj.parse(config)
    let l:base_dir= javaclasspath#parser#standard#java_home(a:config)

    if empty(l:base_dir)
        return []
    endif

    let l:parsed= []

    for l:lib in get(a:config, 'libs', [])
        let l:path= globpath(l:base_dir, l:lib.path)

        if !empty(l:path)
            let l:entry= {
            \   'kind': 'lib',
            \   'path': l:path,
            \}

            if has_key(l:lib, 'javadoc')
                let l:entry.javadoc= l:lib.javadoc
            endif

            call add(l:parsed, l:entry)
        endif
    endfor

    return l:parsed
endfunction

function! javaclasspath#parser#standard#java_home(config)
    if has_key(a:config, 'java_home')
        return a:config.java_home
    elseif exists('$JAVA_HOME')
        return $JAVA_HOME
    else
        return ''
    endif
endfunction

function! javaclasspath#parser#standard#define()
    return deepcopy(s:obj)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
