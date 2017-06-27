" =============================================================================
" File:          plugin/fzf_index.vim
" Description:   FZF + simple indexing
" Author:        Brian Pierce <github.com/bpierce1>
" =============================================================================

function! s:fzf_index_cachefile() abort
  return g:fzf_index_cache_dir . '/' . substitute(getcwd(), '/', '%', 'g')
endfunction

function! s:fzf_index() abort
  " create directory
  if !isdirectory(g:fzf_index_cache_dir)
    silent! call mkdir(g:fzf_index_cache_dir, 'p')
  endif

  " get cache file path
  let s:cache_file = s:fzf_index_cachefile()

  " if file doesn't exist, run command
  if !filereadable(s:cache_file)
    silent execute "!" . g:fzf_index_user_command . " > " . fnameescape(s:cache_file)
  endif

  let options = {
        \   'source': 'cat ' . s:cache_file
        \ }
  let extra = extend(copy(get(g:, 'fzf_layout', {'down': '~40%'})), options)

  call fzf#run(fzf#wrap('name', extra, 0))
endfunction

function! s:fzf_index_clear_cache() abort
  let s:cache_file = s:fzf_index_cachefile()
  if filereadable(s:cache_file)
    silent execute "!" . 'rm ' . fnameescape(s:cache_file)
  endif
endfunction

function! s:fzf_index_reindex() abort
    call s:fzf_index_clear_cache()
    call s:fzf_index()
endfunction

command! -nargs=* FZFIndex call s:fzf_index()
command! -nargs=* FZFIndexClearCache call s:fzf_index_clear_cache()
command! -nargs=* FZFIndexReindex call s:fzf_index_reindex()

augroup autocom
  if g:fzf_index_clear_cache_on_exit
    autocmd!
    autocmd VimLeave * call s:fzf_index_clear_cache()
  endif
augroup END
