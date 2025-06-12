autocmd BufNewFile,BufRead *.gitlab-ci.{yaml,yml} set filetype=yaml.gitlab
autocmd BufNewFile,BufRead .gitlab/ci/*.{yaml,yml} set filetype=yaml.gitlab
autocmd BufNewFile,BufRead templates/*.{yaml,yml} set filetype=yaml.gitlab
autocmd BufNewFile,BufRead templates/*/template.{yaml,yml} set filetype=yaml.gitlab
