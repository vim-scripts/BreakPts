" breakpts.vim
" Author: Hari Krishna <hari_vim at yahoo dot com>
" Last Change: 07-Apr-2003 @ 09:37AM
" Created: 09-Jan-2003
" Requires: Vim-6.1
" Depends On: genutils.vim(1.4), multvals.vim(1.4)
" Version: 1.0.8
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 
" Download From:
"     http://www.vim.org//script.php?script_id=
" Description:
"   - This plugin allows you to visually set/clear breakpoints in Vim
"     functions instead of using breakadd/breakdel commands. The advantage is
"     that you know exactly on which line you are setting the breakpoint,
"     especially when you use line-contnuation in your scripts.
"   - You can open the breakpointlist window through WinManager (as described
"     in the installation section below) or by assigning a hot key. You can
"     use the same hot key to open/close the window. Alternatively, you can
"     also use the :BreakPts command to open/close the breakpts window.
"   - Search for the function that you are interested in and press <CR> or use
"     :BPSelect command to get the function's listing. Alternatively you can
"     use :BPList command with the name of the function to directly jump to
"     the particular function.
"   - You can use <BS> and <Tab> (or :BPBack and :BPForward) to navigate the
"     BreakPts window.
"   - For the sake of speed, the breakpts window is cached. To see the latest
"     function definition/function list at any time, refresh the window by
"     pressing 'R' (or using :BPRefresh command).
"   - It depends on multvals plugin to keep track of where the breakpoints are
"     set.
"   - It depends on genutils plugin only if you have g:brkptsSortFunctions
"     enabled but didn't set g:brkptsSortExternalCmd (requiring a built-in
"     sort).
" Installation:
"   - Place the plugin in a plugin diretory under runtimepath and configure
"     WinManager according to your taste. E.g:
"
"	let g:winManagerWindowLayout = 'FileExplorer,BreakPts'
"
"     You can then switch between FileExplorer and BreakPts by pressing ^N
"     and ^P.
"   - If you don't want to use WinManager, you can still use the :BreakPts
"     comamnd or assign a hotkey by placing the following in your vimrc:
"
"	nmap <silent> <F7> <Plug>BreakPts
"
"     You can substitute any key or sequnce of keys for <F7> in the above map.
"   - Requires multvals.vim to be installed. Download from:
"	http://www.vim.org/script.php?script_id=171
"   - Set g:brkptsSortFunctions if you want the functions to be sorted, but this
"     can slowdown the first appearance of the BreakPts window. You can in
"     addition set g:brkptsSortExternalCmd to e.g., "sort" to use external
"     sort instead of built-in sort to make it faster.
"   - Set g:brkptsVimIsPatched if you know that your vim has patch 6.1.288
"     (6.1 with patch 288 or higher). This generates function listing in
"     silent mode.
"   - Also apply patch 6.1.344 which fixes the problem with messages getting
"     flooded.
" TODO:
"   - It is possible to browse by script too (filter functions by script number)

if exists('loaded_breakpts')
  finish
endif
let loaded_breakpts = 1

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim

" Initialization {{{

command! -nargs=0 BreakPts :call <SID>ListFunctions()
nnoremap <script> <silent> <Plug>BreakPts :BreakPts<cr>

let g:BreakPts_title = "[BreakPts]"
let s:myBufNum = -1
let s:funcBufNum = -1
let s:opMode = ""
if !exists("g:brkptsSortFunctions")
  let g:brkptsSortFunctions = 0
endif
if !exists("g:brkptsSortExternalCmd")
  let g:brkptsSortExternalCmd = ''
endif
if !exists("g:brkptsVimIsPatched")
  if v:version > 601
    let g:brkptsVimIsPatched = 1
  else
    let g:brkptsVimIsPatched = 0
  endif
endif

function! s:MyScriptId()
  map <SID>xx <SID>xx
  let s:sid = maparg("<SID>xx")
  unmap <SID>xx
  return substitute(s:sid, "xx$", "", "")
endfunction
let s:myScriptId = s:MyScriptId()
delfunction s:MyScriptId

sign define VimBreakPt linehl=BreakPtsBreakLine text=>>
      " \ texthl=BreakPtsBreakLine
" Initialization }}}


function! s:ListFunctions() " {{{
  if s:myBufNum == -1
    " Temporarily modify isfname to avoid treating the name as a pattern.
    let _isf = &isfname
    set isfname-=\
    set isfname-=[
    exec "sp \\". g:BreakPts_title
    let &isfname = _isf
    let s:myBufNum = bufnr('%')
  else
    let buffer_win = bufwinnr(s:myBufNum)
    if buffer_win == -1
      exec 'sb '. s:myBufNum
      let s:opMode = 'user'
    else
      exec buffer_win . 'wincmd w'
    endif
  endif

  call s:FuncBrowser(0)
endfunction " }}}


function! s:FuncBrowser(force) " {{{
  if a:force || getline(1) == ''
    setlocal modifiable

    let curFunc = s:GetCurrentFuncName()
    if curFunc != ''
      silent! undo
      call s:ListFunction(curFunc)
    else
      call s:ClearSigns()
      " Go as far as possible in the undo history.
      while line('$') != 1
	silent! undo
      endwhile
      silent! 1,$d

      let funcList = s:GetVimCmdOutput("function", 1)
      silent! $put =funcList
      silent! 1,2d
      silent! exec "normal 0\<C-V>Geld:%s/(.*)$//\<CR>gg0"

      if g:brkptsSortFunctions
	if g:brkptsSortExternalCmd != ''
	  silent! exec '%!' . g:brkptsSortExternalCmd
	else
	  silent! 1,$call QSort(s:myScriptId . 'FuncNameComparator', 1)
	endif
      endif
    endif

    call s:MarkBreakPoints('')

    setlocal nomodifiable
  endif
  call s:SetupBuf()
endfunction " }}}


function! s:ListFunction(funcName) " {{{
  if s:opMode == 'WinManager'
    if s:funcBufNum == -1
      " Temporarily modify isfname to avoid treating the name as a pattern.
      let _isf = &isfname
      set isfname-=\
      set isfname-=[
      call WinManagerFileEdit("\\[Function Listing]", 1)
      let &isfname = _isf
      let s:funcBufNum = bufnr('%') + 0
    else
      call WinManagerFileEdit(s:funcBufNum, 1)
    endif
    call s:SetupBuf()
  endif
  setlocal modifiable

  let funcListing = s:GetVimCmdOutput('function ' . a:funcName,
	\ g:brkptsVimIsPatched)
  if funcListing == ""
    return
  endif

  call s:ClearSigns()
  " First mark the current position so navigation will work.
  mark t
  let lastLine = line('$')
  silent! $put =funcListing
  silent! exec '1,' . (lastLine + 1) . 'd'

  setlocal nomodifiable

  " If there are any breakpoints known for this function, then let us mark
  " them.
  call s:MarkBreakPoints(a:funcName)
endfunction " }}}


function! s:FuncNameComparator(func1, func2, direction) " {{{
  let sid1 = s:GetSID(a:func1)
  let funcName1 = s:GetFuncName(a:func1)
  let sid2 = s:GetSID(a:func2)
  let funcName2 = s:GetFuncName(a:func2)

  if sid1 == "" || sid2 == ""
    " Push non-script functions ahead.
    if sid2 != ""
      let cmp = -a:direction
    elseif sid1 != ""
      let cmp = a:direction
    else
      let cmp = 0
    endif
  else
    let cmp = CmpByNumber(sid1+0, sid2+0, a:direction)
  endif

  if cmp == 0
    let cmp = CmpByString(funcName1, funcName2, a:direction)
  endif

  return cmp
endfunction " }}}


function! s:DoAction() " {{{
  let curFunc = expand('<cword>')
  " Any non-alpha except <>_: which are allowed in the function name.
  if curFunc != '' && match(curFunc, "[~`!@#$%^&*()-+={}[\\]|\\;'\",.?/]") == -1
    if match(curFunc, '^s:') == 0
      let curSID = s:GetSID(s:GetCurrentFuncName())
      let curFunc = strpart(curFunc, 2)
      if curSID == ""
	let curSID = s:SearchForSID(curFunc)
      endif
      if curSID == ""
	echohl ERROR | echo "Sorry, SID couldn't be determined!!!" | echohl NONE
	return
      endif
      let curFunc = '<SNR>' . curSID . '_' . curFunc
    endif
    call s:ListFunction(curFunc)
  endif
endfunction " }}}


" Mark breakpoints {{{
function! s:MarkBreakPoints(funcName)
  let brkPts = s:GetVimCmdOutput('breaklist', 1)
  let curIdx = 0
  if a:funcName == ''
    let pat = '\d\+\s\+func \zs\%(<SNR>\d\+_\)\?\k\+\ze\s\+line \d\+'
  else
    let pat = '\d\+\s\+func ' . a:funcName . '\s\+line \zs\d\+'
  endif
  let loc = ''
  let line = 0
  let b:brkPtLines = ''
  while curIdx != -1 && curIdx < strlen(brkPts)
    let loc = matchstr(brkPts, pat, curIdx)
    if loc != '' && search('^'. loc . '\>')
      if a:funcName == ''
	let line = line('.')
      else
	let line = loc
      endif
      if !MvContainsElement(b:brkPtLines, ',', line('.'))
	exec 'sign place ' . line . ' line=' . line('.') .
	      \ ' name=VimBreakPt buffer=' . bufnr('%')
      endif
      let b:brkPtLines = b:brkPtLines . line('.') . ','
    endif
    let curIdx = matchend(brkPts, pat, curIdx)
  endwhile
  return
endfunction
" }}}


" Add/Remove breakpoints {{{
" Add breakpoint at the current line.
function! s:AddBreakPoint(funcName, sid, brkLine)
  let funcName = ((a:sid != '') ? '<SNR>' . a:sid . '_' : '') . a:funcName
  let v:errmsg = ""
  if a:brkLine == 0
    exec 'breakadd func ' . funcName
  else
    exec 'breakadd func ' . a:brkLine . ' ' . funcName
  endif
  if v:errmsg != ""
    echohl ERROR | echo s:GetFuncMessage("Error setting breakpoint for: ",
	  \ funcName, a:brkLine)
    return
  endif
  echo s:GetFuncMessage("Break point set for function: ", funcName, a:brkLine)
  if !MvContainsElement(b:brkPtLines, ',', line('.'))
    exec 'sign place ' . line('.') . ' line=' . line('.') .
	  \ ' name=VimBreakPt buffer=' . winbufnr(0)
  endif
  let b:brkPtLines = b:brkPtLines . line('.') . ','
endfunction

function! s:GetFuncMessage(msg, funcName, brkLine)
  return a:msg . a:funcName . "(line: " . a:brkLine . ")."
endfunction

" Remove breakpoint at the current line.
function! s:RemoveBreakPoint(funcName, sid, brkLine)
  let funcName = ((a:sid != '') ? '<SNR>' . a:sid . '_' : '') . a:funcName
  let v:errmsg = ""
  if a:brkLine == 0
    exec 'breakdel func ' . funcName
  else
    exec 'breakdel func ' . a:brkLine . ' ' . funcName
  endif
  if v:errmsg != ""
    echohl ERROR | echo s:GetFuncMessage("Error clearing breakpoint for: ",
	  \ funcName, a:brkLine)
    return
  endif
  echo s:GetFuncMessage("Break point cleared for function: ", funcName,
	\ a:brkLine)
  let b:brkPtLines = MvRemoveElement(b:brkPtLines, ',', line('.'))
  " There could be multiple breakpoints at the same line.
  if !MvContainsElement(b:brkPtLines, ',', line('.'))
    sign unplace
  endif
endfunction

function! s:ToggleBreakPoint()
  let curFunc = s:GetCurrentFuncName()
  let sid = s:GetSID(curFunc)
  let funcName = s:GetFuncName(curFunc)
  if funcName != ""
    if line('.') == 1 || line('.') == line('$')
      let brkLine = 1
    "elseif line('.') == line('$')
    "  1
    "  let brkLine = 0
    else
      let brkLine = matchstr(getline('.'), '^\d\+')
      if brkLine == ''
	let brkLine = 0
      endif
    endif
    "if s:CurLineHasSign()
    if MvContainsElement(b:brkPtLines, ',', line('.'))
      call s:RemoveBreakPoint(funcName, sid, brkLine)
    else
      call s:AddBreakPoint(funcName, sid, brkLine)
    endif
  endif
endfunction

function! s:ClearSigns()
  if exists('b:brkPtLines') && b:brkPtLines != ''
    call SaveHardPosition('BreakPts')
    call MvIterCreate(b:brkPtLines, ',', 'BreakPts')
    let linesCleared = ''
    while MvIterHasNext('BreakPts')
      let nextBrkLine = MvIterNext('BreakPts')
      "exec 'sign unplace ' . nextBrkLine . ' buffer=' . bufnr('%')
      if !MvContainsElement(linesCleared, ',', nextBrkLine)
	exec nextBrkLine
	sign unplace
      endif
      let linesCleared = linesCleared . ',' . nextBrkLine
    endwhile
    call MvIterDestroy('BreakPts')
    call RestoreHardPosition('BreakPts')
  endif
endfunction

"function! s:ClearSigns()
"  let signs = s:GetVimCmdOutput('sign place buffer=' . bufnr('%'), 1)
"  let curIdx = 0
"  let pat = 'line=\d\+\s\+id=\zs\d\+\ze\s\+name=VimBreakPt'
"  let id = 0
"  while curIdx != -1 && curIdx < strlen(signs)
"    let id = matchstr(signs, pat, curIdx)
"    if id != ''
"      exec 'sign unplace ' . id . ' buffer=' . bufnr('%')
"    endif
"    let curIdx = matchend(signs, pat, curIdx)
"  endwhile
"endfunction
"
"function! s:CurLineHasSign()
"  let signs = s:GetVimCmdOutput('sign place buffer=' . bufnr('%'), 1)
"  return (match(signs,
"	\ 'line=' . line('.') . '\s\+id=\d\+\s\+name=VimBreakPt') != -1)
"endfunction
" }}}


function! s:GetVimCmdOutput(cmd, withSilent) " {{{
  let v:errmsg = ""
  let _z = @z
  redir @z
  " Vim 6.1 has a bug that makes it hang if you use silent!.
  if a:withSilent
    silent! exec a:cmd
  else
    let _more = &more
    set nomore
    exec a:cmd
    let &more = _more
  endif
  redir END
  let output = @z
  let @z = _z
  if v:errmsg == ""
    return output
  endif
  return ""
endfunction " }}}


" Utilities {{{
function! s:GetSID(funcName)
  return matchstr(a:funcName, '^<SNR>\zs\d\+\ze_')
endfunction


function! s:GetFuncName(funcName)
  let sidEnd = matchend(a:funcName, '>\d\+_')
  let sidEnd = (sidEnd == -1) ? 0 : sidEnd
  let funcEnd = stridx(a:funcName, '(') - sidEnd
  let funcEnd = (funcEnd < 0) ? strlen(a:funcName) : funcEnd
  return strpart(a:funcName, sidEnd, funcEnd)
endfunction


function! s:GetCurrentFuncName()
  return matchstr(getline(1), '\%(^\s*function \)\@<=\%(<SNR>\d\+_\)\?\k\+\%(([^)]*)\)\@=')
endfunction


function! s:SearchForSID(funcName)
  " First find the current maximum SID (keeps increasing as more scrpits get
  "   loaded, ftplugin, syntax and others).
  let maxSID = 0
  let scripts = s:GetVimCmdOutput("script", 1)
  let maxSID = matchstr(scripts, "\\d\\+\\ze: [^\x0a]*$") + 0

  let i = 0
  while i <= maxSID
    if exists('*<SNR>' . i . '_' . a:funcName)
      return i
    endif
    let i = i + 1
  endwhile
  return ''
endfunction
" Utilities }}}


" functions SetupBuf/Quit {{{
function! s:SetupBuf()
  setlocal nobuflisted
  setlocal nowrap
  setlocal noreadonly
  setlocal bufhidden=hide
  setlocal buftype=nofile
  setlocal isk+=<
  setlocal isk+=>
  setlocal isk+=:
  setlocal isk+=_
  setlocal nonumber
  setlocal foldcolumn=0
  set ft=vim
  " Don't make the <SNR> part look like an error.
  syn clear vimFunctionError
  syn match   vimFunction	"\<fu\%[nction]!\=\s\+\U.\{-}("me=e-1	contains=@vimFuncList nextgroup=vimFuncBody
  " Invert these to mean close instead of open.
  command! -buffer -nargs=0 BreakPts :call s:Quit()
  nnoremap <buffer> <silent> <Plug>BreakPts :call s:Quit()<CR>

  command! -buffer BPBack :call <SID>NavigateBack()
  command! -buffer BPForward :call <SID>NavigateForward()
  command! -buffer BPSelect :call <SID>DoAction()
  command! -buffer BPToggle :call <SID>ToggleBreakPoint()
  command! -buffer BPRefresh :call <SID>FuncBrowser(1)
  command! -buffer -nargs=1 -complete=function BPList
	\ :call <SID>ListFunction(substitute(<f-args>, '()\?', '', ''))
  nnoremap <silent> <buffer> <BS> :BPBack<CR>
  nnoremap <silent> <buffer> <Tab> :BPForward<CR>
  nnoremap <silent> <buffer> <CR> :BPSelect<CR>
  nnoremap <silent> <buffer> <F9> :BPToggle<CR>
  nnoremap <silent> <buffer> R :BPRefresh<CR>
  nnoremap <silent> <buffer> q :BreakPts<CR>

  " A bit of a setup for syntax colors.
  hi def link BreakPtsBreakLine	WarningMsg
endfunction


function! s:Quit()
  if s:opMode != 'WinManager' || bufnr('%') != s:myBufNum
    quit
  endif
endfunction " }}}


" Navigation {{{
function! s:NavigateBack()
  call s:Navigate('u')
  if getline(1) == ''
    call s:NavigateForward()
  endif
endfunction


function! s:NavigateForward()
  call s:Navigate("\<C-R>")
endfunction


function! s:Navigate(key)
  call s:ClearSigns()
  let _modifiable = &l:modifiable
  setlocal modifiable
  mark t

  silent! exec "normal" a:key

  let &l:modifiable = _modifiable
  call s:MarkBreakPoints(s:GetCurrentFuncName())

  if line("'t") > 0
    normal `t
  endif
endfunction
" Navigation }}}


" WinManager call backs {{{
function! BreakPts_Start()
  let s:myBufNum = bufnr('%')
  call BreakPts_Refresh()
endfunction

function! BreakPts_Refresh()
  let s:opMode = 'WinManager'
  call s:ListFunctions()
endfunction

function! BreakPts_IsValid()
  return 1
endfunction

function! BreakPts_ReSize()
endfunction
" WinManager call backs }}}

" Restore cpo.
let &cpo = s:save_cpo
unlet s:save_cpo

" vim6:fdm=marker sw=2
