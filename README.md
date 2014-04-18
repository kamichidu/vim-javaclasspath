vim-javaclasspath [![Build Status](https://travis-ci.org/kamichidu/vim-javaclasspath.svg?branch=master)](https://travis-ci.org/kamichidu/vim-javaclasspath)
====================================================================================================

Abstract
----------------------------------------------------------------------------------------------------

vim-javaclasspath is a plugin to give classpath information. this is for developping plugin which using jvm.
this aim to give a common way to cofigure some plugin which is using jvm (java, scala, et al.).

### Prequirements

* [vim-javalang](https://github.com/kamichidu/vim-javalang)

Installation
----------------------------------------------------------------------------------------------------

* for [neobundle.vim](https://github.com/Shougo/neobundle.vim)

    write below to your `$MYVIMRC`

    ```vim:
    NeoBundle 'kamichidu/vim-javaclasspath', {
    \   'depends': ['kamichidu/vim-javalang'],
    \}

    NeoBundleCheck
    ```
