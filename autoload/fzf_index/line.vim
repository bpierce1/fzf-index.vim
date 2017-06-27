" =============================================================================
" File:          autoload/fzf_index/line.vim
" Description:   Line extension
" Author:        Kien Nguyen <github.com/kien>
" =============================================================================

" Init {{{1
if exists('g:loaded_fzf_index_line') && g:loaded_fzf_index_line
	fini
en
let g:loaded_fzf_index_line = 1

cal add(g:fzf_index_ext_vars, {
	\ 'init': 'fzf_index#line#init(s:crbufnr)',
	\ 'accept': 'fzf_index#line#accept',
	\ 'lname': 'lines',
	\ 'sname': 'lns',
	\ 'type': 'tabe',
	\ })

let s:id = g:fzf_index_builtins + len(g:fzf_index_ext_vars)
" Utilities {{{1
fu! s:syntax()
	if !fzf_index#nosy()
		cal fzf_index#hicheck('CtrlPBufName', 'Directory')
		cal fzf_index#hicheck('CtrlPTabExtra', 'Comment')
		sy match CtrlPBufName '\t|\zs[^|]\+\ze|\d\+:\d\+|$'
		sy match CtrlPTabExtra '\zs\t.*\ze$' contains=CtrlPBufName
	en
endf
" Public {{{1
fu! fzf_index#line#init(bufnr)
	let [lines, bufnr] = [[], exists('s:bufnr') ? s:bufnr : a:bufnr]
	let bufs = exists('s:lnmode') && !empty(s:lnmode) ? fzf_index#buffers('id') : [bufnr]
	for bufnr in bufs
		let [lfb, bufn] = [getbufline(bufnr, 1, '$'), bufname(bufnr)]
		if lfb == [] && bufn != ''
			let lfb = fzf_index#utils#readfile(fnamemodify(bufn, ':p'))
		en
		cal map(lfb, 'tr(v:val, ''	'', '' '')')
		let [linenr, len_lfb] = [1, len(lfb)]
		let buft = bufn == '' ? '[No Name]' : fnamemodify(bufn, ':t')
		wh linenr <= len_lfb
			let lfb[linenr - 1] .= '	|'.buft.'|'.bufnr.':'.linenr.'|'
			let linenr += 1
		endw
		cal extend(lines, filter(lfb, 'v:val !~ ''^\s*\t|[^|]\+|\d\+:\d\+|$'''))
	endfo
	cal s:syntax()
	retu lines
endf

fu! fzf_index#line#accept(mode, str)
	let info = matchlist(a:str, '\t|[^|]\+|\(\d\+\):\(\d\+\)|$')
	let bufnr = str2nr(get(info, 1))
	if bufnr
		cal fzf_index#acceptfile(a:mode, bufnr, get(info, 2))
	en
endf

fu! fzf_index#line#cmd(mode, ...)
	let s:lnmode = a:mode
	if a:0 && !empty(a:1)
		let s:lnmode = 0
		let bname = a:1 =~# '^%$\|^#\d*$' ? expand(a:1) : a:1
		let s:bufnr = bufnr('^'.fnamemodify(bname, ':p').'$')
	en
	retu s:id
endf
"}}}

" vim:fen:fdm=marker:fmr={{{,}}}:fdl=0:fdc=1:ts=2:sw=2:sts=2
