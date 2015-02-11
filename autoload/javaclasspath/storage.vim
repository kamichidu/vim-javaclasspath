" The MIT License (MIT)
"
" Copyright (c) 2015 kamichidu
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
let s:save_cpo= &cpo
set cpo&vim

let s:V= vital#of('javaclasspath')
let s:Path= s:V.import('System.Filepath')
unlet s:V

let s:schema_version= '0.0.0'
let s:storage_dirname= s:Path.join(g:javaclasspath_data_dir, 'storage/')

function! javaclasspath#storage#get(key, ...) dict abort
    if a:0 == 0
        return self.__data[a:key]
    else
        return get(self.__data, a:key, a:1)
    endif
endfunction

function! javaclasspath#storage#set(key, value) dict abort
    let self.__data[a:key]= a:value
endfunction

function! javaclasspath#storage#has(key) dict abort
    return has_key(self.__data, a:key)
endfunction

function! javaclasspath#storage#load() dict abort
    if !filereadable(self.__filepath)
        return
    endif

    let content= join(readfile(self.__filepath), '')
    let data= eval(content)
    if !has_key(data, 'version')
        return
    endif

    if data.version ==# s:schema_version
        call extend(self.__data, get(data, 'content', {}), 'force')
    endif
endfunction

function! javaclasspath#storage#persist() dict abort
    call s:ensure_storage_directory()

    let data= {
    \   'version': s:schema_version,
    \   'content': self.__data,
    \}
    call writefile([string(data)], self.__filepath)
endfunction

function! javaclasspath#storage#new(seed) abort
    let storage= {
    \   '__data': {},
    \   '__filepath': s:Path.join(s:storage_dirname, javaclasspath#util#safe_filename(a:seed)),
    \   'get': function('javaclasspath#storage#get'),
    \   'set': function('javaclasspath#storage#set'),
    \   'has': function('javaclasspath#storage#has'),
    \   'load': function('javaclasspath#storage#load'),
    \   'persist': function('javaclasspath#storage#persist'),
    \}

    call storage.load()

    return storage
endfunction

function! s:ensure_storage_directory()
    if isdirectory(s:storage_dirname)
        return
    endif

    call mkdir(s:storage_dirname, 'p')
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
