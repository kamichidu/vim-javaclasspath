@echo off

IF NOT EXIST ".deps/" (
    git clone https://github.com/thinca/vim-themis .deps/themis/
)

.deps\themis\bin\themis.bat --recursive
