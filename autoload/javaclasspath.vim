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

let s:jlang= javalang#get()
let s:helper= javaclasspath#helper#get()

let s:obj= {
\   '_parsers': [],
\   '_config': {},
\}

"
" return joined classpaths.
"
function! s:obj.classpath()
    let l:paths= self.parse()
    let l:classpaths= filter(l:paths, 'v:val.kind ==# "lib"')

    return join(map(l:classpaths, 'v:val.path'), s:jlang.constants.path_separator)
endfunction

"
" return joined source path.
"
function! s:obj.source_path()
    let paths= self.parse()
    let sourcepaths= filter(paths, 'v:val.kind ==# "src"')

    return join(map(sourcepaths, 'v:val.path'), s:jlang.constants.path_separator)
endfunction

"
" allow to parse for any class format.
" return a list of dictionaries. each dictionary has items below.
"
"   kind - one of {'lib', 'src'}
"   path - a classpath
"   javadoc - uri of javadoc attached to its path
"
function! s:obj.parse()
    let l:classpaths= []

    for l:parser in self._parsers
        try
            let l:config= self.config(l:parser)

            let l:buf= l:parser.parse(l:config)

            call extend(l:classpaths, l:buf)
        catch /.*/
            call s:helper.error(join([l:parser.name, v:exception], '/'))
        endtry
    endfor

    return l:classpaths
endfunction

function! s:obj.config(parser)
    if exists('b:javaclasspath_config') && has_key(b:javaclasspath_config, a:parser.name)
        let l:config= b:javaclasspath_config[a:parser.name]
    else
        let l:config= self._config[a:parser.name]
    endif

    " validate if enabled argument validation
    if has_key(a:parser, 'config')
        let l:validator= s:helper.arguments(a:parser.config)

        return l:validator.apply(l:config)
    else
        return l:config
    endif
endfunction

"
" get parser object to parse any format you like.
"
" return a dictionary which has items below.
"
"   parse
"       *function type*
"       this takes a dictionary.
"       see each parser's documentation for more details.
"
function! javaclasspath#get()
    let l:obj= deepcopy(s:obj)

    let l:obj._config= deepcopy(g:javaclasspath_config)

    for l:format in keys(l:obj._config)
        call add(l:obj._parsers, javaclasspath#parser#{l:format}#define())
    endfor

    return l:obj
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
