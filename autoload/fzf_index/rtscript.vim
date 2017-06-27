" =============================================================================
" File:          autoload/fzf_index/rtscript.vim
" Description:   Runtime scripts extension
" Author:        Kien Nguyen <github.com/kien>
" =============================================================================

" Init {{{1
if exists('g:loaded_fzf_index_rtscript') && g:loaded_fzf_index_rtscript
	fini
en
let [g:loaded_fzf_index_rtscript, g:fzf_index_newrts] = [1, 0]

cal add(g:fzf_index_ext_vars, {
	\ 'init': 'fzf_index#rtscript#init(s:caching)',
	\ 'accept': 'fzf_index#acceptfile',
	\ 'lname': 'runtime scripts',
	\ 'sname': 'rts',
	\ 'type': 'path',
	\ 'opmul': 1,
	\ })

let s:id = g:fzf_index_builtins + len(g:fzf_index_ext_vars)

let s:filecounts = {}
" Utilities {{{1
fu! s:nocache()
	retu g:fzf_index_newrts ||
		\ !s:caching || ( s:caching > 1 && get(s:filecounts, s:cwd) < s:caching )
endf
" Public {{{1
fu! fzf_index#rtscript#init(caching)
	let [s:caching, s:cwd] = [a:caching, getcwd()]
	if s:nocache() ||
		\ !( exists('g:fzf_index_rtscache') && g:fzf_index_rtscache[0] == &rtp )
		sil! cal fzf_index#progress('Indexing...')
		let entries = split(globpath(fzf_index#utils#fnesc(&rtp, 'g'), '**/*.*'), "\n")
		cal filter(entries, 'count(entries, v:val) == 1')
		let [entries, echoed] = [fzf_index#dirnfile(entries)[1], 1]
	el
		let [entries, results] = g:fzf_index_rtscache[2:3]
	en
	if s:nocache() ||
		\ !( exists('g:fzf_index_rtscache') && g:fzf_index_rtscache[:1] == [&rtp, s:cwd] )
		if !exists('echoed')
			sil! cal fzf_index#progress('Processing...')
		en
		let results = map(copy(entries), 'fnamemodify(v:val, '':.'')')
	en
	let [g:fzf_index_rtscache, g:fzf_index_newrts] = [[&rtp, s:cwd, entries, results], 0]
	cal extend(s:filecounts, { s:cwd : len(results) })
	retu results
endf

fu! fzf_index#rtscript#id()
	retu s:id
endf
"}}}

" vim:fen:fdm=marker:fmr={{{,}}}:fdl=0:fdc=1:ts=2:sw=2:sts=2
