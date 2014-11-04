#!/usr/bin/env rake

task :ci => [:dump, :test]

task :dump do
    sh 'vim --version'
end

task :test do
    sh <<'...'
if ! [ -d .deps/ ]; then
    git clone https://github.com/thinca/vim-themis .deps/themis/
fi
...
    sh './.deps/themis/bin/themis --recursive'
end
