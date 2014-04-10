"
" The MIT License (MIT)
"
" Copyright (c) 2014 raa0121
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
let s:P= s:V.import('ProcessManager')
unlet s:V

let s:obj= {
\   'name': 'sbt',
\}

function! s:obj.parse(config)
    if !filereadable(a:config.filename)
        return []
    endif

    let l:t = s:P.touch('sbt', 'sbt')
    if t ==# 'new'
      let l:temp = s:P.read_wait('sbt', 3.0, ["> "])
      call s:P.writeln('sbt', 'show fullClasspath')
    else
      call s:P.writeln('sbt', 'show fullClasspath')
    endif
    let l:temp = s:P.read('sbt', ["> "])
    let l:fullClasspath = map(split(temp[0], ','), 'matchstr(v:val, ''Attributed(\zs.\{-}\ze)'')')
    if fullClasspath == []
      let l:temp = s:P.read('sbt', ["> "])
      let l:fullClasspath = map(split(temp[0], ','), 'matchstr(v:val, ''Attributed(\zs.\{-}\ze)'')')
    endif
    let l:classpaths= []

    for l:entry in fullClasspath
        let l:classpath= {
        \   'kind': 'lib',
        \   'path': l:entry,
        \}
        call add(l:classpaths, l:classpath)
    endfor

    return l:classpaths
endfunction

function! javaclasspath#parser#sbt#define()
    return deepcopy(s:obj)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
