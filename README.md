# FZF + Indexing

## Description
A very simple indexing tool for fzf. Useful if you have lots of files or if you have a directory mounted via sshfs and indexing is very slow.

You have to provide a few definitions in your `.vimrc` for it to work:

```vimrc
let g:fzf_index_cache_dir = $HOME.'/.cache/fzf_index'
let g:fzf_index_clear_cache_on_exit = 0
let g:fzf_index_user_command = 'rg -L --no-ignore-vcs --ignore-file ~/.rgignore --files'
```

## Usage

Run the following commands (or map them to a keybinding


Use `g:fzf_index_user_command` to build a cache if it doesn't exist, or read files from cache if they do exist: 

```
FZFIndex
```

Explicitly delete the cache file (so that next time you call `FZFIndex` it will rebuild the cache:

```
FZFIndexClearCache
```

A combination of the above 2 commands - clear the cache and run `FZFIndex` all at once: 

```
FZFIndexReindex
```

