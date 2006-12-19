" tAssert.vim
" @Author:      Thomas Link (mailto:samul AT web de?subject=vim-tAssert)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2006-12-13.
" @Last Change: 2006-12-19.
" @Revision:    0.29

fun! <SID>TestFunction(a, b)
    return a:a + a:b
endf

TAssertBegin! "General"

fun! TAssertTemporaryFunction(a, b)
    return a:a + a:b
endf

TAssert! 0 == 0
TAssert! "bla" == "bla"
TAssert! IsNumber(1)
TAssert! IsString("foo")
TAssert! IsFuncref(function('IsFuncref'))
TAssert! IsList([1,2,3])
TAssert! IsDictionary({1:2})
TAssert! !IsNumber("Foo")
TAssert! !IsString(1)
TAssert! !IsFuncref({1:2})
TAssert! !IsList(function('IsFuncref'))
TAssert! !IsDictionary([1,2,3])
TAssert! IsException('0 + [1]') =~ ':E745:'
TAssert! <SID>TestFunction(1, 2) == 3
TAssertEnd var varl vard TAssertTemporaryFunction()

TAssert! !exists('TAssertTemporaryFunction()')

TAssertBegin! "Switching context", '.\{-}/plugin/00tAssert.vim'
TAssert! <SID>Test(1) == 2
TAssertEnd

TAssertBegin! "Unfulfilled assertions"
TAssert! IsEqual(0, 1)
TAssert! IsNumber("Foo")
TAssert! IsString(1)
TAssert! IsFuncref({1:2})
TAssert! IsList(function('IsFuncref'))
TAssert! IsDictionary([1,2,3])
TAssert! IsError('0 + [1]', ':E999:')
TAssert! IsException('0 + 1') =~ ':E745:'
TAssertEnd 
 
