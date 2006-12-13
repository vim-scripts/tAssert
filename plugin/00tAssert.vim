" tAssert.vim
" @Author:      Thomas Link (mailto:samul AT web de?subject=vim-tAssert)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2006-12-12.
" @Last Change: 2006-12-13.
" @Revision:    0.1.307
"
" TODO:
" - Logging
" - Support for Autoloading, AsNeeded ...


" Prelude {{{1
if &cp || exists("loaded_tassert")
    if !(!exists("s:assert") || g:TASSERT != s:assert)
        finish
    endif
endif
let loaded_tassert = 1
" echom "DBG: sourcing tAssert.vim"


" Core {{{1
if !exists("g:TASSERT") | let g:TASSERT = 0 | endif

if exists("s:assert") | echo 'TAssertions are '. (g:TASSERT ? 'on' : 'off') | endif
let s:assert = g:TASSERT

if g:TASSERT
    command! -nargs=1 -bang TAssert 
                \ if empty(eval(s:ResolveSIDs(<q-args>))) | 
                \ throw 'Assertion failed: '. s:assertMsg .': '. <q-args> | 
                \ endif
    command! -nargs=* -bang TAssertBegin let s:assertArgs = [<args>] | 
                \ let s:assertMsg = get(s:assertArgs, 0, '') | 
                \ let s:assertFile = get(s:assertArgs, 1, expand("<sfile>:p")) | 
                \ if "<bang>" != '' | echom 'tAssert: '. s:assertMsg | endif
    command! -nargs=* -bang TAssertEnd for v in split(<q-args>, '\W\+') | exec 'unlet! '. v | endfor | 
            \ let s:assertMsg = '' | let s:assertFile = ''
    TAssertEnd
else
    command! -nargs=* -bang TAssert :
    command! -nargs=* -bang TAssertBegin :
    command! -nargs=* -bang TAssertEnd :
    finish
endif

fun! s:ResolveSIDs(string)
    if s:assertFile != ''
        redir => scriptnames
        silent scriptnames
        redir END
        let scripts = split(scriptnames, "\n")
        call filter(scripts, 'v:val =~ '. string('\s'.s:assertFile.'$'))
        let snr = matchstr(scripts[0], '^\s*\zs\d\+')
        let string = substitute(a:string, '<SID>', '<SNR>'.snr.'_', 'g')
        return string
    " else
    "     throw 'tAssert: Missing TAssertBegin'
    endif
endf


" Convenience commands {{{1

command! TAssertOn let g:TASSERT = 1 | runtime plugin/00tAssert.vim
command! TAssertOff let g:TASSERT = 0 | runtime plugin/00tAssert.vim
command! TAssertToggle let g:TASSERT = !g:TASSERT | runtime plugin/00tAssert.vim

fun! <SID>CommentRegion(mode)
    norm! G
    let prefix = a:mode ? '^\s*' : '^\s*"\s*'
    let tb = search(prefix.'TAssertBegin\>', 'w')
    while tb
        let te = search(prefix.'TAssertEnd\>', 'W')
        if te
            if a:mode
                silent exec tb.','.te.'s/^\s*/\0" /'
            else
                silent exec tb.','.te.'s/^\(\s*\)"\s*/\1/'
            endif
            let tb = search(prefix.'TAssertBegin\>', 'W')
        else
            throw 'tAssert: Missing TAssertEnd below line '. tb
        endif
    endwh
endf

command! TAssertComment let s:assertCP = getpos('.') | let s:tassertSR = @/ | 
            \ call <SID>CommentRegion(1) | 
            \ silent %s/\C^\(\s*\)\(TAssert\)/\1" \2/ge | 
            \ let @/ = s:tassertSR | call setpos('.', s:assertCP)
command! TAssertUncomment let s:assertCP = getpos('.') | let s:tassertSR = @/ | 
            \ call <SID>CommentRegion(0) | 
            \ silent %s/\C^\(\s*\)"\s*\(TAssert\)/\1\2/ge | 
            \ let @/ = s:tassertSR | call setpos('.', s:assertCP)


" Test functions
fun! s:Test(a)
    return a:a + a:a
endf


" Convenience functions {{{1
if exists('g:tAssertNoCFs') && g:tAssertNoCFs
    finish
endif

fun! IsNumber(arg)
    return type(a:arg) == 0
endf

fun! IsString(arg)
    return type(a:arg) == 1
endf

fun! IsFuncref(arg)
    return type(a:arg) == 2
endf

fun! IsList(arg)
    return type(a:arg) == 3
endf

fun! IsDictionary(arg)
    return type(a:arg) == 4
endf

fun! DoRaise(expr)
    try
        call eval(a:expr)
        return ''
    catch
        return v:exception
    endtry
endf



finish
CHANGE LOG {{{1

0.1: Initial release


