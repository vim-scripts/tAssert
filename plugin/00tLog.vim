" tLog.vim
" @Author:      Thomas Link (mailto:samul AT web de?subject=vim-tLog)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2006-12-15.
" @Last Change: 2006-12-16.
" @Revision:    0.1.28

if &cp || exists('loaded_tlog')
    finish
endif
let loaded_tlog = 1

if !exists('g:TLOG')     | let g:TLOG = 'echom'   | endif
" if !exists('g:TLOG')     | let g:TLOG = 'file'  | endif
" if !exists('g:TLOG')     | let g:TLOG = 'Decho' | endif
if !exists('g:tlogFile') | let g:tlogFile = ''    | endif

fun! TLog(text)
    let log = exists('b:tlog') ? b:TLOG : g:TLOG
    call TLog_{log}(a:text)
    return 1
endf

fun! TLogDBG(text)
    return TLog('DBG: '. string(a:text))
endf

fun! TLog_echom(text)
    echom a:text
endf

fun! TLog_file(text)
    let log = exists('b:tlogFile') ? b:tlogFile : g:tlogFile
    if log == ''
        let log = expand('%:r') .'.log'
    endif
    exec 'redir >> '. log
    silent echom a:text
    redir END
endf

fun! TLog_Decho(text)
    call Decho(a:text)
endf

command! -nargs=+ TLog call TLog(<args>)
command! -nargs=+ TLogDBG call TLogDBG(expand('<sfile>:r').': '.string(<args>))

command! TLogComment let s:assertCP = getpos('.') | let s:tassertSR = @/ | 
            \ silent %s/\C^\(\s*\)\(\(call *\)TLog\)/\1" \2/ge | 
            \ let @/ = s:tassertSR | call setpos('.', s:assertCP)
command! TLogUncomment let s:assertCP = getpos('.') | let s:tassertSR = @/ | 
            \ silent %s/\C^\(\s*\)"\s*\(\(call *\)TLog\)/\1\2/ge | 
            \ let @/ = s:tassertSR | call setpos('.', s:assertCP)


finish

CCHANGE LOG {{{1
see 00tAssert.vim

