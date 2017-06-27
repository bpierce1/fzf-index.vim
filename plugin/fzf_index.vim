" =============================================================================
" File:          plugin/fzf_index.vim
" Description:   CtrlP Most Recently Used Files source for FZF
" Author:        Pawel Bogut <github.com/pbogut>
" =============================================================================

if exists('g:fzf_index_loaded')
  finish
endif
let g:fzf_index_loaded = 1

let [g:fzf_index_lines, g:fzf_index_allfiles, g:fzf_index_alltags, g:fzf_index_alldirs,
	\ g:fzf_index_allmixes, g:fzf_index_buftags, g:fzf_index_ext_vars, g:fzf_index_builtins]
	\ = [[], [], [], [], {}, {}, [], 2]

if !exists('g:fzf_index_map') | let g:fzf_index_map = '<c-p>' | en
if !exists('g:fzf_index_cmd') | let g:fzf_index_cmd = 'fzf_index' | en

" prepare params
function! s:params(params)
  let params = join(a:params, ' ')
  if (len(params) && params[0] != '-')
    let params = '-q ' . shellescape(params)
  endif

  return params
endfunction

function! s:fzf_index(...) abort
  let options = {
        \   'source': fzf_index#init(0, { 'dir': a:0 }),
        \ }
  let extra = extend(copy(get(g:, 'fzf_layout', {'down': '~40%'})), options)

  call fzf#run(fzf#wrap('name', extra, 0))
endfunction

command! -nargs=* FZFIndex call s:fzf_index(<q-args>)
command! -bar FZFClearCache call fzf_index#clr()

