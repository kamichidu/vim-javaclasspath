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
let s:M= s:V.import('Vim.Message')
unlet s:V

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
    let paths= self.parse()
    let classpaths= filter(paths, 'v:val.kind ==# "lib"')

    return join(map(classpaths, 'v:val.path'), s:jlang.constants.path_separator)
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
    let classpaths= []

    for parser in self._parsers
        try
            let config= self.config(parser)

            let buf= parser.parse(config)

            call extend(classpaths, buf)
        catch /.*/
            call s:helper.error(join([parser.name, v:exception], '/'))
        endtry
    endfor

    return classpaths
endfunction

function! s:obj.config(parser)
    if exists('b:javaclasspath_config') && has_key(b:javaclasspath_config, a:parser.name)
        let config= b:javaclasspath_config[a:parser.name]
    else
        let config= self._config[a:parser.name]
    endif

    " validate if enabled argument validation
    if has_key(a:parser, 'config')
        let validator= s:helper.arguments(a:parser.config)

        return validator.apply(config)
    else
        return config
    endif
endfunction

function! javaclasspath#classpath()
    return javaclasspath#get().classpath()
endfunction

function! javaclasspath#source_path()
    return javaclasspath#get().source_path()
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
    let obj= deepcopy(s:obj)

    let obj._config= deepcopy(g:javaclasspath_config)

    for format in keys(obj._config)
        call add(obj._parsers, javaclasspath#parser#{format}#define())
    endfor

    return obj
endfunction

function! javaclasspath#on_filetype()
    if !g:javaclasspath_enable_auto_analyze
        return
    endif

    if exists('s:on_filetype_parsers')
        for parser_name in s:on_filetype_parsers
            try
                let config= get(g:javaclasspath_config, parser_name, {})

                call javaclasspath#parser#{parser_name}#on_filetype(config)
            catch
                call s:M.error(v:exception)
                call s:M.error(v:throwpoint)
            endtry
        endfor
    else
        let files= split(globpath(&runtimepath, 'autoload/javaclasspath/parser/*.vim'), "\n")
        let parser_names= map(files, 'fnamemodify(v:val, ":t:r")')

        let s:on_filetype_parsers= []
        for parser_name in parser_names
            try
                let config= get(g:javaclasspath_config, parser_name, {})

                call javaclasspath#parser#{parser_name}#on_filetype(config)
                let s:on_filetype_parsers+= [parser_name]
            catch /^javaclasspath:/
                call s:M.error(v:exception)
                call s:M.error(v:throwpoint)
                let s:on_filetype_parsers+= [parser_name]
            catch /E117/
                " ignore
            catch
                call s:M.error(v:exception)
                call s:M.error(v:throwpoint)
            endtry
        endfor
    endif
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
