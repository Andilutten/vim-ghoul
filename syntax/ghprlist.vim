if exists("b:current_syntax")
	finish
endif

syn sync fromstart

syn region ghPrRow display oneline start='^' end='$'
			\ contains=ghPrId,ghPrStatus,ghPrTimestamp

syn match ghPrId /^#\d\+/ contained nextgroup=ghPrTitle skipwhite
syn match ghPrTitle /[^\t]\+/ transparent contained nextgroup=ghPrBranch skipwhite
syn match ghPrBranch /@\S\+/ contained nextgroup=ghPrStatus skipwhite
syn keyword ghPrStatus OPEN CLOSED contained
syn match ghPrTimestamp /\d\{4}-[^$]\+/ contained

hi def link ghPrId Number
hi def link ghPrBranch String
hi def link ghPrStatus Keyword
hi def link ghPrTimestamp Type

let b:current_syntax = "ghprlist"
