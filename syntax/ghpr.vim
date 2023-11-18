if exists("b:current_syntax")
	finish
endif

let s:keywords = ["title","state","author","labels","assignees","reviewers","projects","milestone","number","url","additions","deletions","auto-merge"]

syn sync fromstart

syn region ghPrKeyValue start='^' end='$' contains=ghPrKey,ghPrStatus

exec "syn match ghPrKey '\\v^(" . join(s:keywords, '|') . ")\\ze:' contained nextgroup=ghPrStatus,ghPrUrl skipwhite"
syn keyword ghPrStatus OPEN CLOSED contained
syn match ghPrUrl 'https\S\+' contained

hi def link ghPrKey Constant
hi def link ghPrUrl String

let b:current_syntax = "ghpr"
