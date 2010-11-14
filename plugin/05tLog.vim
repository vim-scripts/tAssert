" tLog.vim
" @Author:      Thomas Link (mailto:samul AT web de?subject=vim-tLog)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2006-12-15.
" @Last Change: 2007-04-26.
" @Revision:    0.3.87

if &cp || exists('loaded_tlog')
    finish
endif
let loaded_tlog = 3

" One of: echo, echom, file, Decho
" Format: type:args
" E.g. file:/tmp/foo.log
if !exists('g:tlogDefault') | let g:tlogDefault = 'echom'   | endif
if !exists('g:TLOG')        | let g:TLOG = g:tlogDefault    | endif

fun! TLog(text)
    let log = s:GetLogType()
    if !empty(log)
        call TLog_{log}(a:text)
        return 1
    endif
    return 0
endf

fun! TLogDBG(text)
    return TLog('DBG: '. a:text)
endf

fun! TLogVAR(text, var, val)
    return TLog('VAR: '. a:text .' '. a:var .'='. string(a:val))
endf

fun! TLog_echo(text)
    echo a:text
endf

fun! TLog_echom(text)
    echom a:text
endf

fun! TLog_file(text)
    let fname = s:GetLogArg()
    if fname == ''
        let fname = expand('%:r') .'.log'
    endif
    exec 'redir >> '. fname
    silent echom a:text
    redir END
endf

fun! TLog_Decho(text)
    call Decho(a:text)
endf

fun! s:GetLogPref()
    return exists('b:TLOG') ? b:TLOG : g:TLOG
endf

fun! s:GetLogType()
    let log = s:GetLogPref()
    let arg = matchstr(log, '^\a\+')
    return arg
endf

fun! s:GetLogArg()
    let log = s:GetLogPref()
    let arg = matchstr(log, '^file:\zs.*$')
    return arg
endf

command! -nargs=+ TLog call TLog(<args>)
command! -nargs=+ TLogDBG call TLogDBG(expand('<sfile>').': '. <args>)
command! -nargs=+ TLogVAR if exists(<q-args>) | call TLogVAR(expand('<sfile>').': ', <q-args>, <args>) | else | call TLogDBG(expand('<sfile>').': Var doesn''t exist: '. <q-args>) | endif

command! -bar -nargs=? TLogOn let g:TLOG = empty(<q-args>) ? g:tlogDefault : <q-args>
command! -bar -nargs=? TLogOff let g:TLOG = ''
command! -bar -nargs=? TLogBufferOn let b:TLOG = empty(<q-args>) ? g:tlogDefault : <q-args>
command! -bar -nargs=? TLogBufferOff let b:TLOG = ''

command! -range=% -bar TLogComment let s:tlogCP = getpos('.') | let s:tlogSR = @/ | 
            \ silent <line1>,<line2>s/\C^\(\s*\)\(\(call *\)\?TLog\)/\1" \2/ge | 
            \ let @/ = s:tlogSR | call setpos('.', s:tlogCP)
command! -range=% -bar TLogUncomment let s:tlogCP = getpos('.') | let s:tlogSR = @/ | 
            \ silent <line1>,<line2>s/\C^\(\s*\)"\s*\(\(call *\)\?TLog\)/\1\2/ge | 
            \ let @/ = s:tlogSR | call setpos('.', s:tlogCP)


finish

CHANGE LOG {{{1
see 00tAssert.vim

