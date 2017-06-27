" =============================================================================
" File:          autoload/fzf_index/mixed.vim
" Description:   Mixing Files + MRU + Buffers
" Author:        Kien Nguyen <github.com/kien>
" =============================================================================

" Init {{{1
if exists('g:loaded_fzf_index_mixed') && g:loaded_fzf_index_mixed
	fini
en
let [g:loaded_fzf_index_mixed, g:fzf_index_newmix] = [1, 0]

cal add(g:fzf_index_ext_vars, {
	\ 'init': 'fzf_index#mixed#init(s:compare_lim)',
	\ 'accept': 'fzf_index#acceptfile',
	\ 'lname': 'fil + mru + buf',
	\ 'sname': 'mix',
	\ 'type': 'path',
	\ 'opmul': 1,
	\ 'specinput': 1,
	\ })

let s:id = g:fzf_index_builtins + len(g:fzf_index_ext_vars)
" Utilities {{{1
fu! s:newcache(cwd)
	if g:fzf_index_newmix || !has_key(g:fzf_index_allmixes, 'data') | retu 1 | en
	retu g:fzf_index_allmixes['cwd'] != a:cwd
		\ || g:fzf_index_allmixes['filtime'] < getftime(fzf_index#utils#cachefile())
		\ || g:fzf_index_allmixes['mrutime'] < getftime(fzf_index#mrufiles#cachefile())
		\ || g:fzf_index_allmixes['bufs'] < len(fzf_index#mrufiles#bufs())
endf

fu! s:getnewmix(cwd, clim)
	if g:fzf_index_newmix
		cal fzf_index#mrufiles#refresh('raw')
		let g:fzf_index_newcache = 1
	en
	let g:fzf_index_lines = copy(fzf_index#files())
	cal fzf_index#progress('Mixing...')
	let mrufs = copy(fzf_index#mrufiles#list('raw'))
	if exists('+ssl') && &ssl
		cal map(mrufs, 'tr(v:val, "\\", "/")')
	en
	let allbufs = map(fzf_index#buffers(), 'fnamemodify(v:val, ":p")')
	let [bufs, ubufs] = [[], []]
	for each in allbufs
		cal add(filereadable(each) ? bufs : ubufs, each)
	endfo
	let mrufs = bufs + filter(mrufs, 'index(bufs, v:val) < 0')
	if len(mrufs) > len(g:fzf_index_lines)
		cal filter(mrufs, 'stridx(v:val, a:cwd)')
	el
		let cwd_mrufs = filter(copy(mrufs), '!stridx(v:val, a:cwd)')
		let cwd_mrufs = fzf_index#rmbasedir(cwd_mrufs)
		for each in cwd_mrufs
			let id = index(g:fzf_index_lines, each)
			if id >= 0 | cal remove(g:fzf_index_lines, id) | en
		endfo
	en
	let mrufs += ubufs
	cal map(mrufs, 'fnamemodify(v:val, ":.")')
	let g:fzf_index_lines = len(mrufs) > len(g:fzf_index_lines)
		\ ? g:fzf_index_lines + mrufs : mrufs + g:fzf_index_lines
	if len(g:fzf_index_lines) <= a:clim
		cal sort(g:fzf_index_lines, 'fzf_index#complen')
	en
	let g:fzf_index_allmixes = { 'filtime': getftime(fzf_index#utils#cachefile()),
		\ 'mrutime': getftime(fzf_index#mrufiles#cachefile()), 'cwd': a:cwd,
		\ 'bufs': len(fzf_index#mrufiles#bufs()), 'data': g:fzf_index_lines }
endf
" Public {{{1
fu! fzf_index#mixed#init(clim)
	let cwd = getcwd()
	if s:newcache(cwd)
		cal s:getnewmix(cwd, a:clim)
	el
		let g:fzf_index_lines = g:fzf_index_allmixes['data']
	en
	let g:fzf_index_newmix = 0
	retu g:fzf_index_lines
endf

fu! fzf_index#mixed#id()
	retu s:id
endf
"}}}

" vim:fen:fdm=marker:fmr={{{,}}}:fdl=0:fdc=1:ts=2:sw=2:sts=2
