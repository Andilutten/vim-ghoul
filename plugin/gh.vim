if exists('g:loaded_gh')
	finish
endif
let g:loaded_gh = 1

let g:ghoul_gh_path = get(g:, "ghoul_gh_path", "gh")

command! -nargs=* -complete=custom,gh#complete_command Gh
			\ execute gh#exec_command(<q-args>, <q-mods>)

function! s:dot(cmd) abort
	try
		let id = matchlist(getline('.'), '\v^#(\d+)')[1]
		return empty(id) ? '' : printf(":Gh %s  %s\<s-left>\<left>", a:cmd, id)
	catch
	endtry
endfunction

function! s:pr_exec(cmd) abort
	try
		let id = matchlist(getline('.'), '\v^#(\d+)')[1]
		return empty(id) ? '' : printf(":Gh pr %s %s\<cr>", a:cmd, id)
	catch
	endtry
endfunction

augroup gh
	autocmd!
	autocmd FileType ghprlist,ghissuelist,ghpr,ghissue,ghprdiff setl norelativenumber nonumber 
				\ cursorline bufhidden=delete buftype=nofile nobuflisted
	autocmd FileType ghprlist,ghissuelist,ghpr,ghissue,ghprdiff nnoremap <buffer> <silent> q  <cmd>bd!<cr>
	autocmd FileType ghprlist nnoremap <buffer> <expr> . <sid>dot('pr')
	autocmd FileType ghprlist nnoremap <buffer> <silent> <expr> <cr> <sid>pr_exec('view')
	autocmd FileType ghprlist nnoremap <buffer> <silent> <expr> D <sid>pr_exec('diff')
	autocmd FileType ghissuelist nnoremap <buffer> <expr> . <sid>dot('issue')
augroup end
