let s:commands = {
			\ "issue": {
			\ 	"list": {
			\ 		"ft": "ghissuelist"
			\ 	}, 
			\		"view": {
			\			"ft": "ghissue"
			\		}
			\ },
			\ "pr": { 
			\ 	"list": {
			\			"handler": "gh#exec_pr_list",
			\			"ft": "ghprlist"
			\		}, 
			\ 	"view": {
			\			"handler": "gh#exec_pr_view",
			\			"ft": "ghpr"
			\		},
			\ 	"diff": {
			\			"handler": "gh#exec_pr_diff",
			\			"ft": "ghprdiff"
			\		}
			\	}
			\}

function! gh#buf_create(cmd, mods) abort
	execute a:mods .. " split | enew"
	execute printf("setl ft=%s", a:cmd["ft"])
endfunction

function! gh#call(args) abort
	return systemlist(printf("%s %s", g:ghoul_gh_path, a:args))
endfunction

function! gh#exec_pr_list(args, mods) abort
	let cmd = s:commands["pr"]["list"]
	let output = json_decode(join(gh#call(a:args .. " --json number,title,headRefName,state,updatedAt"), "\n"))
	call gh#buf_create(cmd, a:mods)
	let index = 0
	for item in output
		call append(index, printf("#%s\t%s\t@%s\t%s\t%s", item['number'], item['title'], item['headRefName'], item['state'], item['updatedAt']))
		let index = index + 1
	endfor
	return ''
endfunction

function! gh#exec_pr_diff(args, mods) abort
	let cmd = s:commands["pr"]["diff"]
	let id = matchstr(a:args, '\d\+$')
	if empty(id)
		echoerr "Misformed command"
		return ''
	endif
	let output = gh#call(a:args)
	call gh#buf_create(cmd, a:mods)
	execute "setl syntax=diff"
	call append(0, output)
	return ''
endfunction

function! gh#exec_pr_view(args, mods) abort
	let cmd = s:commands["pr"]["view"]
	let id = matchstr(a:args, '\v\d+$')
	if empty(id)
		echoerr "Misformed command"
		return ''
	endif
	let output = gh#call(a:args)
	call gh#buf_create(cmd, a:mods)
	call append(0, output)
	return ''
endfunction

function! gh#exec_command(args, mods) abort
	if !executable(g:ghoul_gh_path)
		echoerr "gh executable not found"
	endif
	let parts = matchlist(a:args,  '^\(\S\+\)\s\+\(\S\+\)')
	if empty(parts)
		echoerr "Unknown command"
		return ''
	endif
	let cmd = parts[1]
	let subcmd = parts[2]

	if !has_key(s:commands, cmd)
		echoerr "Unknown command"	
		return ''
	endif

	if !has_key(s:commands[cmd], subcmd)
		echoerr "Unknown subcommand"	
		return ''
	endif

	let FuncRef = function(s:commands[cmd][subcmd]["handler"], [a:args, a:mods])	
	call FuncRef()
	execute "norm! Gddgg$"
	setl nomodifiable
endfunction

function! gh#complete_command(A, L, P) abort
	let pre = a:L[0 : a:P-1]
	let cmd = matchstr(pre, '\S*\s\+\zs\(\S\+\)\ze\s')
	if (cmd ==# '')
		return join(keys(s:commands), "\n")
	endif
	return join(keys(get(s:commands, cmd, {})), "\n")
endfunction
