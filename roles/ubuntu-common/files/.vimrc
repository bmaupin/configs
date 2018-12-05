set expandtab
set shiftwidth=4
set tabstop=4

" https://stackoverflow.com/a/774599/399105
" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif
