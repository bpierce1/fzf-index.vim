# FZF + Indexing

## Description
A very simple indexing tool for fzf. Useful if you have lots of files or if you have a directory mounted via sshfs and indexing is very slow.

You have to provide a few definitions in your `.vimrc` for it to work:

```vimrc
let g:fzf_index_cache_dir = $HOME.'/.cache/fzf_index'
let g:fzf_index_clear_cache_on_exit = 0
let g:fzf_index_user_command = 'rg -L --no-ignore-vcs --ignore-file ~/.rgignore --files'
```

