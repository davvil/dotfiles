function! MultiLineSearchKeys()
   cnoremap <silent> <buffer> <Space> \_s\+
   cnoremap <silent> <buffer> <CR> <CR>:call RemoveMultiLineSearchKeys()<CR>
endfunction

function! RemoveMultiLineSearchKeys()
   cunmap <buffer> <Space>
   cunmap <buffer> <CR>
endfunction

"~ noremap / :cnoremap <Space> \_s<CR>/
noremap / :call MultiLineSearchKeys()<CR>/
