" tAssert.vim
" @Author:      Thomas Link (mailto:samul AT web de?subject=vim-tAssert)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2006-12-12.
" @Last Change: 2006-12-19.
" @Revision:    0.2.465
"
" TODO:
" - Interactive assertions (buffer input, expected vs observed)
" - Support for Autoloading, AsNeeded ...


" Prelude {{{1
if &cp || exists("loaded_tassert")
    if !(!exists("s:assert") || g:TASSERT != s:assert)
        finish
    endif
endif
let loaded_tassert = 2
" echom "DBG: sourcing tAssert.vim"


" Core {{{1
if !exists('g:TASSERT')        | let g:TASSERT = 0                       | endif

if exists('s:assert')
    echo 'TAssertions are '. (g:TASSERT ? 'on' : 'off')
endif
let s:assert = g:TASSERT

" 'Assertion failed: '
if g:TASSERT
    " command! -bar TAssertDefine
    "             \ exec printf('command! -nargs=1 -bang TAssert let s:assertReason = [] |
    "             \ if empty(eval(<q-%s>)) | 
    "             \ call insert(s:assertReason, <q-%s>) | 
    "             \ if "<%s>" != "" | 
    "             \ call TLog(s:assertMsg .": ". join(s:assertReason, ": ")) | 
    "             \ else |
    "             \ throw s:assertMsg .": ". join(s:assertReason, ": ") | 
    "             \ endif | 
    "             \ endif', 'args', 'args', 'bang')
    command! -nargs=1 -bang TAssert 
                \ let s:assertReason = [] |
                \ try |
                \ let s:assertFailed = empty(eval(s:ResolveSIDs(<q-args>))) |
                \ catch |
                \ call insert(s:assertReason, v:exception) | 
                \ let s:assertFailed = 1 |
                \ endtry |
                \ if s:assertFailed | 
                \ call insert(s:assertReason, <q-args>) | 
                \ if "<bang>" != '' | 
                \ call TLog(s:assertMsg .': '. join(s:assertReason, ': ')) | 
                \ else |
                \ throw s:assertMsg .': '. join(s:assertReason, ': ') | 
                \ endif | 
                \ endif
    command! -nargs=* -bang TAssertBegin let s:assertArgs = [<args>] | 
                \ let s:assertMsg = get(s:assertArgs, 0, '') | 
                \ let s:assertFile = get(s:assertArgs, 1, expand("<sfile>:p")) | 
                \ if "<bang>" != '' | call TLog('tAssert: '. s:assertMsg) | endif
    command! -nargs=* -bang TAssertEnd for v in split(<q-args>, '\s\+') | 
                \ if v =~ '()$' |
                \ exec 'delfunction '. matchstr(v, '^[^(]\+') |
                \ else |
                \ exec 'unlet! '. v | 
                \ endif | 
                \ endfor | 
                \ let s:assertMsg = '' | let s:assertFile = ''
    TAssertEnd
else
    command! -nargs=* -bang TAssert :
    command! -nargs=* -bang TAssertBegin :
    command! -nargs=* -bang TAssertEnd :
    if exists(':TAssertOn') | finish | endif
endif


" Convenience commands {{{1

command! TAssertOn let g:TASSERT = 1 | runtime plugin/00tAssert.vim
command! TAssertOff let g:TASSERT = 0 | runtime plugin/00tAssert.vim
command! TAssertToggle let g:TASSERT = !g:TASSERT | runtime plugin/00tAssert.vim
" command! TAssertSource let tassert = g:TASSERT | let g:TASSERT = 1 |
"             \ try |
"             \ echom 'source '. empty(<q-args>) ? '%' : <q-args> |
"             \ finally | let g:TASSERT = tassert | unlet tassert |
"             \ endtry

command! TAssertComment let s:assertCP = getpos('.') | let s:tassertSR = @/ | 
            \ call s:CommentRegion(1) | 
            \ silent %s/\C^\(\s*\)\(TAssert\)/\1" \2/ge | 
            \ let @/ = s:tassertSR | call setpos('.', s:assertCP)
command! TAssertUncomment let s:assertCP = getpos('.') | let s:tassertSR = @/ | 
            \ call s:CommentRegion(0) | 
            \ silent %s/\C^\(\s*\)"\s*\(TAssert\)/\1\2/ge | 
            \ let @/ = s:tassertSR | call setpos('.', s:assertCP)

fun! s:GetSNR(file, ...)
    let update = a:0 >= 1 ? a:1 : 0
    if update || !exists('s:scripts')
        redir => scriptnames
        silent! scriptnames
        redir END
        let s:scripts = split(scriptnames, "\n")
        call map(s:scripts, '[matchstr(v:val, ''^\s*\zs\d\+''), matchstr(v:val, ''^\s*\d\+: \zs.*$'')]')
    endif
    for fn in s:scripts
        if fn[1] =~ a:file.'$'
            return fn[0]
        endif
    endfor
    if !update
        return s:GetSNR(a:file, 1)
    else
        TLog 'tAssert: Unknown script context: '. a:file
        return 0
    endif
endf

fun! s:ResolveSIDs(string)
    if s:assertFile != ''
        let snr = s:GetSNR(s:assertFile)
        if snr
            let string = substitute(a:string, '<SID>', '<SNR>'.snr.'_', 'g')
            " TLogDBG a:string .': '. snr
            return string
        else
            TLog 'tAssert: Unknown script context: '. a:string
        endif
    endif
    return a:string
endf

fun! s:CommentRegion(mode)
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


" Test functions
fun! s:Test(a)
    return a:a + a:a
endf


" Convenience functions {{{1
if exists('g:tAssertNoCFs') && g:tAssertNoCFs
    finish
endif

fun! s:CheckType(expr, type)
    " let val  = eval(a:expr)
    let Val  = a:expr
    let type = type(Val)
    let rv   = type == a:type
    if !rv
        let types = {0: "Number", 1: "String", 2: "Funcref", 3: "List", 4: "Dictionary"}
        call add(s:assertReason, string(Val) .' is a '. types[type])
    endif
    return rv
endf

fun! IsNumber(expr)
    return s:CheckType(a:expr, 0)
endf

fun! IsString(expr)
    return s:CheckType(a:expr, 1)
endf

fun! IsFuncref(expr)
    return s:CheckType(a:expr, 2)
endf

fun! IsList(expr)
    return s:CheckType(a:expr, 3)
endf

fun! IsDictionary(expr)
    return s:CheckType(a:expr, 4)
endf

fun! IsException(expr)
    try
        call eval(a:expr)
        return ''
    catch
        return v:exception
    endtry
endf

fun! IsError(expr, expected)
    let rv = IsException(a:expr)
    if rv =~ a:expected
        return 1
    else
        call add(s:assertReason, 'Exception '. string(a:expected) .' expected but got '. string(rv))
        return 0
    endif
endf

fun! IsEqual(expr, expected)
    " let val = eval(a:expr)
    let val = a:expr
    let rv  = val == a:expected
    if !rv
        call add(s:assertReason, 'Expected '. string(a:expected) .' but got '. string(val))
    endif
    return rv
endf

fun! IsNotEqual(expr, expected)
    let val = eval(a:expr)
    let rv  = val != a:expected
    if !rv
        call add(s:assertReason, string(a:expected) .' is equal to '. string(val))
    endif
    return rv
endf


fun! IsEmpty(expr)
    let rv = empty(a:expr)
    if !rv
        call add(s:assertReason, string(a:expr) .' isn''t empty')
    endif
    return rv
endf

fun! IsNotEmpty(expr)
    let rv = !empty(a:expr)
    if !rv
        call add(s:assertReason, string(a:expr) .' is empty')
    endif
    return rv
endf

fun! IsMatch(expr, expected)
    let val = a:expr
    let rv  = val =~ a:expected
    if !rv
        call add(s:assertReason, string(val) .' doesn''t match '. string(a:expected))
    endif
    return rv
endf

fun! IsNotMatch(expr, expected)
    let val = a:expr
    let rv  = val !~ a:expected
    if !rv
        call add(s:assertReason, string(val) .' matches '. string(a:expected))
    endif
    return rv
endf


finish
CHANGE LOG {{{1

0.1: Initial release

0.2
- Convenience commands weren't loaded when g:TASSERT was off.
- s:ResolveSIDs() didn't return a string if s:assertFile wasn't set.
- More convenience functions
- The convenience functions now display an explanation for a failure
- TAssert! (the one with the bang) doesn't throw an error but simply 
displays the failure in the log
- Logging to a file & via Decho()
- s:ResolveSIDs() caches scriptnames
- Moved logging code to 00tLog.vim

