#!/usr/bin/env rake

task :ci => [:dump, :test]

task :dump do
    sh 'vim --version'
end

task :test do
    sh <<'...'
if ! [ -d .vim-test/ ]; then
    mkdir .vim-test/
    git clone https://github.com/kamichidu/vim-javalang.git .vim-test/vim-javalang/
fi
if ! [ -d .vim-themis ]; then
    git clone https://github.com/thinca/vim-themis .vim-themis/
fi
...
    sh '.vim-themis/bin/themis --runtimepath .vim-test/vim-javalang/'
end
