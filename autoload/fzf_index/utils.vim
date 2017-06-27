" =============================================================================
" File:          autoload/fzf_index/utils.vim
" Description:   Utilities
" Author:        Kien Nguyen <github.com/kien>
" =============================================================================

" Static variables {{{1
fu! fzf_index#utils#lash()
	retu &ssl || !exists('+ssl') ? '/' : '\'
endf

fu! s:lash(...)
	retu ( a:0 ? a:1 : getcwd() ) !~ '[\/]$' ? s:lash : ''
endf

fu! fzf_index#utils#opts()
	let s:lash = fzf_index#utils#lash()
	let usrhome = $HOME . s:lash( $HOME )
	let cahome = exists('$XDG_CACHE_HOME') ? $XDG_CACHE_HOME : usrhome.'.cache'
	let cadir = isdirectory(usrhome.'.fzf_index_cache')
		\ ? usrhome.'.fzf_index_cache' : cahome.s:lash(cahome).'fzf_index'
	if exists('g:fzf_index_cache_dir')
		let cadir = expand(g:fzf_index_cache_dir, 1)
		if isdirectory(cadir.s:lash(cadir).'.fzf_index_cache')
			let cadir = cadir.s:lash(cadir).'.fzf_index_cache'
		en
	en
	let s:cache_dir = cadir
endf
cal fzf_index#utils#opts()

let s:wig_cond = v:version > 702 || ( v:version == 702 && has('patch051') )
" Files and Directories {{{1
fu! fzf_index#utils#cachedir()
	retu s:cache_dir
endf

fu! fzf_index#utils#cachefile(...)
	let [tail, dir] = [a:0 == 1 ? '.'.a:1 : '', a:0 == 2 ? a:1 : getcwd()]
	let cache_file = substitute(dir, '\([\/]\|^\a\zs:\)', '%', 'g').tail.'.txt'
	retu a:0 == 1 ? cache_file : s:cache_dir.s:lash(s:cache_dir).cache_file
endf

fu! fzf_index#utils#readfile(file)
	if filereadable(a:file)
		let data = readfile(a:file)
		if empty(data) || type(data) != 3
			unl data
			let data = []
		en
		retu data
	en
	retu []
endf

fu! fzf_index#utils#mkdir(dir)
	if exists('*mkdir') && !isdirectory(a:dir)
		sil! cal mkdir(a:dir, 'p')
	en
	retu a:dir
endf

fu! fzf_index#utils#writecache(lines, ...)
	if isdirectory(fzf_index#utils#mkdir(a:0 ? a:1 : s:cache_dir))
		sil! cal writefile(a:lines, a:0 >= 2 ? a:2 : fzf_index#utils#cachefile())
	en
endf

fu! fzf_index#utils#glob(...)
	let path = fzf_index#utils#fnesc(a:1, 'g')
	retu s:wig_cond ? glob(path, a:2) : glob(path)
endf

fu! fzf_index#utils#globpath(...)
	retu call('globpath', s:wig_cond ? a:000 : a:000[:1])
endf

fu! fzf_index#utils#fnesc(path, type, ...)
	if exists('*fnameescape')
		if exists('+ssl')
			if a:type == 'c'
				let path = escape(a:path, '%#')
			elsei a:type == 'f'
				let path = fnameescape(a:path)
			elsei a:type == 'g'
				let path = escape(a:path, '?*')
			en
			let path = substitute(path, '[', '[[]', 'g')
		el
			let path = fnameescape(a:path)
		en
	el
		if exists('+ssl')
			if a:type == 'c'
				let path = escape(a:path, '%#')
			elsei a:type == 'f'
				let path = escape(a:path, " \t\n%#*?|<\"")
			elsei a:type == 'g'
				let path = escape(a:path, '?*')
			en
			let path = substitute(path, '[', '[[]', 'g')
		el
			let path = escape(a:path, " \t\n*?[{`$\\%#'\"|!<")
		en
	en
	retu a:0 ? escape(path, a:1) : path
endf
"}}}

" vim:fen:fdm=marker:fmr={{{,}}}:fdl=0:fdc=1:ts=2:sw=2:sts=2
