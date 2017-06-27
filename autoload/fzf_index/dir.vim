" =============================================================================
" File:          autoload/fzf_index/dir.vim
" Description:   Directory extension
" Author:        Kien Nguyen <github.com/kien>
" =============================================================================

" Init {{{1
if exists('g:loaded_fzf_index_dir') && g:loaded_fzf_index_dir
	fini
en
let [g:loaded_fzf_index_dir, g:fzf_index_newdir] = [1, 0]

let s:ars = ['s:maxdepth', 's:maxfiles', 's:compare_lim', 's:glob', 's:caching']

cal add(g:fzf_index_ext_vars, {
	\ 'init': 'fzf_index#dir#init('.join(s:ars, ', ').')',
	\ 'accept': 'fzf_index#dir#accept',
	\ 'lname': 'dirs',
	\ 'sname': 'dir',
	\ 'type': 'path',
	\ 'specinput': 1,
	\ })

let s:id = g:fzf_index_builtins + len(g:fzf_index_ext_vars)

let s:dircounts = {}
" Utilities {{{1
fu! s:globdirs(dirs, depth)
	let entries = split(globpath(a:dirs, s:glob), "\n")
	let [dirs, depth] = [fzf_index#dirnfile(entries)[0], a:depth + 1]
	cal extend(g:fzf_index_alldirs, dirs)
	let nr = len(g:fzf_index_alldirs)
	if !empty(dirs) && !s:max(nr, s:maxfiles) && depth <= s:maxdepth
		sil! cal fzf_index#progress(nr)
		cal map(dirs, 'fzf_index#utils#fnesc(v:val, "g", ",")')
		cal s:globdirs(join(dirs, ','), depth)
	en
endf

fu! s:max(len, max)
	retu a:max && a:len > a:max
endf

fu! s:nocache()
	retu !s:caching || ( s:caching > 1 && get(s:dircounts, s:cwd) < s:caching )
endf
" Public {{{1
fu! fzf_index#dir#init(...)
	let s:cwd = getcwd()
	for each in range(len(s:ars))
		let {s:ars[each]} = a:{each + 1}
	endfo
	let cadir = fzf_index#utils#cachedir().fzf_index#utils#lash().'dir'
	let cafile = cadir.fzf_index#utils#lash().fzf_index#utils#cachefile('dir')
	if g:fzf_index_newdir || s:nocache() || !filereadable(cafile)
		let [s:initcwd, g:fzf_index_alldirs] = [s:cwd, []]
		if !fzf_index#igncwd(s:cwd)
			cal s:globdirs(fzf_index#utils#fnesc(s:cwd, 'g', ','), 0)
		en
		cal fzf_index#rmbasedir(g:fzf_index_alldirs)
		if len(g:fzf_index_alldirs) <= s:compare_lim
			cal sort(g:fzf_index_alldirs, 'fzf_index#complen')
		en
		cal fzf_index#utils#writecache(g:fzf_index_alldirs, cadir, cafile)
		let g:fzf_index_newdir = 0
	el
		if !( exists('s:initcwd') && s:initcwd == s:cwd )
			let s:initcwd = s:cwd
			let g:fzf_index_alldirs = fzf_index#utils#readfile(cafile)
		en
	en
	cal extend(s:dircounts, { s:cwd : len(g:fzf_index_alldirs) })
	retu g:fzf_index_alldirs
endf

fu! fzf_index#dir#accept(mode, str)
	let path = a:mode == 'h' ? getcwd() : s:cwd.fzf_index#call('s:lash', s:cwd).a:str
	if a:mode =~ 't\|v\|h'
		cal fzf_index#exit()
	en
	cal fzf_index#setdir(path, a:mode =~ 't\|h' ? 'chd!' : 'lc!')
	if a:mode == 'e'
		sil! cal fzf_index#statusline()
		cal fzf_index#setlines(s:id)
		cal fzf_index#recordhist()
		cal fzf_index#prtclear()
	en
endf

fu! fzf_index#dir#id()
	retu s:id
endf
"}}}

" vim:fen:fdm=marker:fmr={{{,}}}:fdl=0:fdc=1:ts=2:sw=2:sts=2
