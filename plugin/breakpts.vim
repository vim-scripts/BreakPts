" breakpts.vim
" Author: Hari Krishna <hari_vim at yahoo dot com>
" Last Change: 06-May-2004 @ 20:08
" Created: 09-Jan-2003
" Requires: Vim-6.3, genutils.vim(1.13), multvals.vim(3.6)
" Depends On: foldutil.vim(1.4), cmdalias.vim(1.0)
" Version: 3.2.1
" Acknowledgements:
"   - Thanks a lot to David Fishburn (fishburn at sybase dot com) for
"     providing a lot of feedback, ideas and patches, and helping me with
"     finding problems. The plugin is much more usable and bug free because of
"     him.
"   - Bram and Michael Geddes (mgeddes at au dot mediacommand dot com) for
"     fixing the Vim crashes with remote debugging.
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 
" Download From:
"     http://www.vim.org/script.php?script_id=618
" Description:
"   - This plugin allows you to visually set/clear breakpoints in Vim
"     functions/scripts instead of using breakadd/breakdel commands. The
"     advantage is that you know exactly on which line you are setting the
"     breakpoint, especially when you use line-contnuation in your scripts.
"     Though setting breakpoints is the main intention, it is also useful as a
"     Vim function and script browser.
"   - Open the BreakPts window through WinManager (as described in the
"     installation section below) or by stand-alone using :BreakPts command
"     (or by pressing the hot key, if you have chosen one). You can use
"     :BreakPts (or the hot key) again to close the window. The :BreakPts
"     command also allows an option to be passed to specify the initial view
"     (+f for functions, +s for scripts, +b for breakpoints). As a
"     convenience, you can also convert any number of existing buffers to
"     additional BreakPts buffers by executing the :BreakPtsSetupBuf command.
"     This allows you to display as many windows as you want each with
"     different lists/listings.
"
"     E.g., you can convert an arbitrary buffer to display the :breaklist (by
"     executing the :BPPoints command) and use it to enable/disable
"     breakpoints.
"   - The window is normally first opened with the list of all the functions
"     that are loaded into Vim. But you can toggle between the list of
"     functions, scripts and breakpoints, by using the :BPScripts,
"     :BPFunctions and :BPPoints commands respectively, while in the BreakPts
"     window.
"   - Search for the function/script that you are interested in and press <CR>
"     or use :BPSelect command to get the listing. Alternatively you can use
"     :BPListFunc or :BPListScript command to list a function or script
"     directly. This is also the only way you can set a breakpoint in an
"     unloaded plugin (such as a ftplugin that is yet to be loaded). In the
"     script window, you can also use :BPOpen (or o) to open a script script
"     that is already loaded for editing. BPListScript command can take an
"     absoluate path or a relative path that is valid from the current
"     directory or any directory in the 'runtimepath' as an argument.
"
"     TIP: You can use Vim's function or file name completion mechanism (if
"     enabled) with these commands. For script local functions, you can have
"     vim fill in the <SNR> prefix (instead of manually typing it in), by
"     prefixing the function name with an asterisk, before attempting to
"     complete.
"   - You can navigate the history by using <BS> and <Tab> (or :BPBack and
"     :BPForward) commands, just like in an HTML browser.
"   - To toggle a breakpoint at any line, press <F9> (or :BPToggle) command.
"     The plugin uses Vim's |:sign| feature to visually indicate the existence
"     of a breakpoint. You can also use :BPClearAll command to clear all the
"     breakpoints when you are in the BreakPts window (or :BreakPtsClearAll
"     in other windows).
"   - You can save the breakpoints into a global variable using the :BPSave
"     command while in the BreakPts window (or using the :BreakPtsSave in
"     other windows). The command takes in the name of a global variable where
"     the commands to recreate the breakpoints will be saved. You can later
"     reload these breakpoints by simply executing the variable:
"
"         :BPSave BL
"         :BPClearAll
"         .
"         .
"         :exec BL
"
"     You can also use this technique to save and restore breakpoints across
"     sessions. For this to work, just make sure that the '!' option in
"     'viminfo' is set:
"
"         :set viminfo^=!
"
"     and use a variable name that starts with an uppercase letter and contain
"     only uppercase letters and underscore characters (see help on
"     'viminfo'). When you are no longer interested in saving and restoring a
"     breaklist, it is advisable to unlet the corresponding global variable.
"   - To make it easier to jump from one breakpoint to another, the plugin
"     defines two commands, [b and ]b (or :BPPrevious and :BPNext). Also, if
"     the foldutil.vim plugin is found to be installed, the plugin
"     automatically folds all the lines that do not have a breakpoint (with a
"     context of g:brkptsFoldContext, which has a default value of 3). This
"     feature is automatically disabled if foldutil.vim is not found to be
"     installed, but you can also set g:brkptsCreateFolds to 0 to explicitly
"     disable it.
"   - On the scripts view, you can use :BPReload (or O) to reload a script
"     locally or remotely. This basically determines the corresponding
"     g:loaded_<plugin name> variable by following some simple rules and
"     sources this script after unletting the variable. This is intended to be
"     used with the regular plugins, not the others such as ftplugin, indent,
"     syntax, colors or compiler plugins as these plugins will automatically
"     be reloaded by Vim at appropriate times.
"
"     TIP: You can use this command to reload a new version of a plugin
"     without restarting your vim, but make sure the plugin supports such an
"     operation (all my other plugins do, as this is what I do during the
"     development process). Many plugins may not be designed to be just
"     reloaded this way as the script local variables could get reset causing
"     it to misbehave.
"   - The contents of BreakPts window is cached, so to see the latest listing
"     at any time, refresh the window by pressing 'R' (or :BPRefresh) command.
"     You also need to refresh to see the breakpoints added/removed manually.
"     CAUTION: This commands results in a loss of forward history.
"   - To connect to a remote Vim using the |clientserver| functionality, open
"     the BreakPts window and use the :BPRemoteServ command with the Vim
"     server name as the argument (with no arguments the same command prints
"     the current remote server name). You can browse the functions/scripts
"     and set breakpoints in the remote session exactly as you would in the
"     local session. To get back to the local vim session, use the same
"     command with "." as the server name.
"
"     Once the remote vim is in the debug mode (stopped at the > prompt), you
"     can use :BPDWhere command to view the context of the remote session. The
"     current line is marked with the BreakPtsContext highlighting group (by
"     default same as Visual). You can also execute the :debug mode commands
"     in the remote session as follows:
"
"           Remote command    Local command   Local map
"           >next             :BPDNext        <F12>
"           >step             :BPDStep        <F11> 
"           >cont             :BPDCont        <F5>
"           >quit             :BPDQuit        <S-F5>
"           >finish           :BPDFinish      <S-F11>
"
"   - The plugin defines a global command called :Where which you can use
"     during the debugging to see the context of the current line.
"   - Creates the following commands with useful completions, and alias them
"     to the corresponding built-in commands if cmdalias.vim is loaded.
"     - :Runtime (for |:runtime|) that allows you to do partial file
"       completions from your 'runtimepath'.
"     - :Debug (for |:debug|) that allows you to do command-completions.
"     - :Breakadd (for |:breakadd|) that allows you to complete on the
"       function name or file path (from 'runtimepath').
"     - :Breakdel (for |:breakdel|) that allows you to complete on the
"       existing breakpoints (obtained from :breaklist).
"   - The plugin also provides two global functions BPBreak() and BPBreakIf()
"     which can be used to insert, and two more global functions BPDeBreak()
"     and BPDeBreakIf() for clearing breakpoints dynamically. The BPBreak()
"     function works similar to the VB break command. It can also be used to
"     insert breakpoints from the debug prompt. The BPBreakIf() is just a
"     convenience function to conditionally break at a specified location. See
"     the function headers for more information.
"
" Installation:
"   - Place the plugin in a plugin diretory under runtimepath and configure
"     WinManager according to your taste. E.g:
"
"       let g:winManagerWindowLayout = 'FileExplorer,BreakPts'
"
"     You can then switch between FileExplorer and BreakPts by pressing ^N
"     and ^P.
"   - If you don't want to use WinManager, you can still use the :BreakPts
"     comamnd or assign a hotkey by placing the following in your vimrc:
"
"       nmap <silent> <F7> <Plug>BreakPts
"
"     You can substitute any key or sequnce of keys for <F7> in the above map.
"   - Requires multvals.vim to be installed. Download from:
"       http://www.vim.org/script.php?script_id=171
"   - Requires genutils.vim to be installed. Download from:
"       http://www.vim.org/script.php?script_id=197
"   - To have the g:brkptsCreateFolds feature enabled, install the
"     foldutil.vim plugin.  Download from:
"       http://www.vim.org/script.php?script_id=158
"   - Set g:brkptsSortFunctions if you want the functions to be sorted, but this
"     can slowdown the first appearance (and every refresh) of the BreakPts
"     window. To make the sort quicker, you can set the value of
"     g:brkptsSortExternalCmd to the name(e.g., "sort", if already in
"     PATH)/path of an external command. This will make the plugin use
"     external sort (which in general is much faster) instead of the built-in
"     sort.
"   - Set g:brkptsDefStartMode to 'scripts', 'functions' or 'breakpts' to start
"     the browser in that mode.
"   - Set g:brkptsModFuncHeader to a true value, if you want to change
"     "function" to "function!" while listing functions. This will simplify you
"     to block copy the function and redefine it while still in debug mode
"     (kind of incremental update).
"   - Set the '!' flag in viminfo if you want to save the breaklist across
"     sessions (see usage above).
"   - The default maps for debug commands are defined based on the MS Visual
"     Studio, but you can easily configure them.
"
"     Here is a table of all the mappings and their default key associations:
"     
"       Mapping               Default       Description~
"       BreakPtsContKey       <F5>          Continue execution (>cont).
"       BreakPtsQuitKey       <S-F5>        Quit debug mode (>quit).
"       BreakPtsNextKey       <F12>         Exeute next command (>next).
"       BreakPtsStepKey       <F11>         Step into next command (>step).
"       BreakPtsFinishKey     <S-F11>       Finish executing current
"                                           function/script (>finish).
"       BreakPtsClearAllKey   <C-S-F9>      Clear all breakpoints.
"
"     E.g., to change the mapping for the BreakPtsContKey to <F8>, place the
"     following in your vimrc:
"
"       nmap <script> <silent> <Plug>BreakPtsContKey <F8>
" TODO:
"   Features: 
"     - Implement BPDRunToCursor. Create a temporary breakpoint and clear it
"       when hit.
"     - It should be possible to run ctags to get all the local variables in the
"       current function and automatically show their values. We should also
"       be able to show the argument values automatically.
"     - How about a :BPDEvaluate command that takes in an expression and
"       evaluates it in the remote vim and shows the result (using
"       remote_expr() to be safe)?
"     - It should also be possible to create watch expressions to be evaluated
"       everytime the context is refreshed (using the :BPEvaluation infra.).
"     - How about opening an editable function listing window extracted from the
"       remote vim, and allow users to redefine it after modifying it?
"     - Can I make better use of the stack produced by the context? I can
"       maintain a local stack of current line numbers for them. But still Vim
"       will not be able to go up and down the stack, so may be not that
"       important.
"     - A menu will be useful for those who are used to menus.
"     - We need a debug console to show the output of various debug commands.
"     - A statusbar (with current function/script name etc.) will be useful.
"     - It is possible for the debuggee scripts to provide a standard interface
"       (see perforce plugin for example) for the plugin to poke into and obtain
"       the script local values. This allows us to show the local variables at
"       any time, and without needing to execute them at debug prompt remotely.
"
"   - BPListFunc and BPListScript use default Vim completion, but they should
"     really use custom completion which reads the list from current remote
"     Vim server.
"   - How do I detect if the execution of the command has finished, so that I
"     can terminate s:WaitForDbgPrompt()?
"   - If you set a breakpoint during the startup, it doesn't work. Also,
"     BPBreak seems to misbehave 'file' as 'func' in this case.
"     exec 'breakadd file 3' expand('<sfile>')
"     exec BPBreak(1)
"     call input(expand('<sfile>'))
"   - BPRemoteServ should have a global equivalent.
"   - The :BPListFunc should also support SID search.
"   - How can I generate context without executing a normal command?
"     Using remote_expr() doesn't seem feasible. The same is applicable to
"     executing debug mode commands.
"
" Usage Scenarios {{{
"   - Start the browser using :BreakPts command for the first time with each
"     of the three options.
"   - Switch to a each of the three views using :BreakPts by using each of the
"     three options, make sure the history is gone.
"   - Try switching the views for all unique combinations as below, make sure
"     the history is not gone, and there is no duplicate when switching to the
"     same item (use :BPFunctions, :BPScripts, :BPPoints, :BPListFunc,
"     :BPListScript commands)
"     - Functions -> Functions
"     - Functions -> Breakpoints
"     - Breakpoints -> Breakpoints
"     - Breakpoints -> Scripts
"     - Scripts -> Scripts
"     - Scripts -> Script
"     - Script -> Same Script
"     - Script -> Different Script
"     - Script -> Function
"     - Function -> Same Function
"     - Function -> Different Function
"     - Fuction -> Functions
"   - In each of the five views, try doing a refresh, make sure there is no
"     duplicate in the history and that the cursor position is preserved.
"   - In the Functions, Function, Scripts and Script views, try selecting an
"     item.
"   - In the Breakpoints view, try selecting a func item and a file item. Also
"     try selecting when there are no breakpoints defined.
"   - In Functions and Scripts views, try toggling breakpoint, make sure it is
"     ignored.
"   - In the Function, Script and Breakpoints views, try toggling
"     (enable/disable) breakpoint (both func and file type in Breakpoints
"     view). Navigate to the corresponding list view and make sure that the
"     breakpoints are marked (try toggling breakpoint in the list view, again).
"   - In the scripts window, reload a script after making some changes and
"     make sure it gets reflected.
" Usage Scenarios }}}

if exists('loaded_breakpts')
  finish
endif
if v:version < 603
  echomsg 'breakpts: You need at least Vim 6.3'
  finish
endif
if !exists('loaded_multvals')
  runtime plugin/multvals.vim
endif
if !exists('loaded_multvals') || loaded_multvals < 306
  echomsg 'breakpts: You need a newer version of multvals.vim plugin'
  finish
endif
if !exists('loaded_genutils')
  runtime plugin/genutils.vim
endif
if !exists('loaded_genutils') || loaded_genutils < 113
  echomsg 'breakpts: You need a newer version of genutils.vim plugin'
  finish
endif
let loaded_breakpts = 300

" No error if not found.
if !exists('loaded_cmdalias')
  runtime plugin/cmdalias.vim
endif

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim

" Initialization {{{

command! -nargs=? BreakPts :call <SID>BrowserMain(<f-args>)
nnoremap <script> <silent> <Plug>BreakPts :BreakPts<cr>
command! -nargs=0 BreakPtsSetupBuf :call <SID>BPSetupBuf()
command! -nargs=1 BreakPtsSave :call <SID>SaveBrkPts(<f-args>)
command! BreakPtsClearAll :call <SID>ClearAllBrkPts()
command! Where :exec <SID>GenContext() | echo g:BPCurContext
command! -bang -nargs=+ -complete=custom,<SID>RuntimeComplete Runtime :runtime<bang> <args>
command! -nargs=+ -complete=custom,<SID>BreakAddComplete Breakadd :breakadd <args>
command! -nargs=+ -complete=custom,<SID>BreakDelComplete Breakdel :breakdel <args>
command! -complete=command -nargs=+ Debug :debug <args>
if exists('*CmdAlias')
  call CmdAlias('runtime', 'Runtime')
  call CmdAlias('breaka', 'Breaka')
  call CmdAlias('breakad', 'Breakad')
  call CmdAlias('breakadd', 'Breakadd')
  call CmdAlias('breakd', 'Breakd')
  call CmdAlias('breakde', 'Breakde')
  call CmdAlias('breakdel', 'Breakdel')
  call CmdAlias('debug', 'Debug')
endif

if !exists('s:myBufNum')
let s:myBufNum = -1
let s:funcBufNum = -1

let g:BreakPts_title = "[BreakPts]"
let s:BreakListing_title = "[BreakPts Listing]"
let s:opMode = ""
let s:remoteServName = '.'
let s:remoteScriptId = ''
let s:curLineInCntxt = '' " Current line for context.
endif
let s:BM_SCRIPT = 'script'
let s:BM_SCRIPTS = 'scripts'
let s:BM_FUNCTION = 'function'
let s:BM_FUNCTIONS = 'functions'
let s:BM_BRKPTS = 'breakpts'
let s:cmd_scripts = 'script'
let s:cmd_functions = 'function'
let s:cmd_breakpts = 'breaklist'
let s:header{s:BM_SCRIPTS} = 'Scripts:'
let s:header{s:BM_FUNCTIONS} = 'Functions:'
let s:header{s:BM_BRKPTS} = 'Breakpoints:'
"let s:header{s:BM_SCRIPT}= "'Script: '.a:curScript.' (Id: '.a:curScriptId.')'"
"let s:browserMode = s:BM_FUNCTION
let s:FUNC_NAME_PAT = '\%(<SNR>\d\+_\)\?\k\+'
if !exists("g:brkptsSortFunctions")
  let g:brkptsSortFunctions = 0
endif
if !exists("g:brkptsSortExternalCmd")
  let g:brkptsSortExternalCmd = ''
endif
if !exists("g:brkptsCreateFolds")
  let g:brkptsCreateFolds = 1
endif
if !exists("g:brkptsFoldContext")
  let g:brkptsFoldContext = 3
endif
if !exists("g:brkptsDefStartMode")
  let g:brkptsDefStartMode = s:BM_FUNCTIONS
endif
if !exists("g:brkptsModFuncHeader")
  let g:brkptsModFuncHeader = 0
endif

function! s:MyScriptId()
  map <SID>xx <SID>xx
  let s:sid = maparg("<SID>xx")
  unmap <SID>xx
  return substitute(s:sid, "xx$", "", "")
endfunction
let s:myScriptId = s:MyScriptId()
delfunction s:MyScriptId

if has("signs")
  sign define VimBreakPt linehl=BreakPtsBreakLine text=>>
        " \ texthl=BreakPtsBreakLine
endif
" Initialization }}}


" Browser functions {{{
 
function! s:BrowserMain(...) " {{{
  if s:myBufNum == -1
    " Temporarily modify isfname to avoid treating the name as a pattern.
    let _isf = &isfname
    try
      set isfname-=\
      set isfname-=[
      if exists('+shellslash')
        exec "sp \\\\". g:BreakPts_title
      else
        exec "sp \\". g:BreakPts_title
      endif
    finally
      let &isfname = _isf
    endtry
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

  if a:0 > 0
    let browserMode = ''
    if a:1 =~ '^+f\%[unction]$'
      let browserMode = s:BM_FUNCTIONS
    elseif a:1 =~ '^+s\%[cripts]$'
      let browserMode = s:BM_SCRIPTS
    elseif a:1 =~ '^+b\%[reakpts]$'
      let browserMode = s:BM_BRKPTS
    endif
    call s:Browser(1, browserMode, '', '')
  else
    call s:BrowserRefresh(0)
  endif
endfunction " }}}

" Call this function to convert any buffer to a breakpts buffer.
function! s:BPSetupBuf() " {{{
  call OptClearBuffer()
  call s:SetupBuf(0)
endfunction " }}}

" Refreshes with the same mode.
function! s:BrowserRefresh(force) " {{{
  call s:Browser(a:force, s:GetBrowserMode(), s:GetListingId(),
        \ s:GetListingName())
endfunction " }}}

" The commands local to the browser window can directly call this, as the
"   browser window is gauranteed to be already open (which is where the user
"   must have executed the command in the first place).
function! s:Browser(force, browserMode, id, name) " {{{
  call s:ClearSigns()
  " First mark the current position so navigation will work.
  normal! mt
  setlocal modifiable
  if a:force || getline(1) == ''
    call OptClearBuffer()

  " Refreshing the current listing or list view.
  elseif ((a:browserMode == s:BM_FUNCTION || a:browserMode == s:BM_SCRIPT) &&
        \ s:GetListingName() == a:name) ||
        \((a:browserMode == s:BM_FUNCTIONS || a:browserMode == s:BM_SCRIPTS ||
        \  a:browserMode == s:BM_BRKPTS) &&
        \ a:browserMode == s:GetBrowserMode())
    call SaveHardPosition('BreakPts')
    silent! undo
  endif

  if a:name != ''
    call s:List_{a:browserMode}(a:id, a:name)
  else
    let output = s:GetVimCmdOutput(s:cmd_{a:browserMode})
    let lastLine = line('$')
    silent! $put =output
    silent! exec '1,' . (lastLine + 1) . 'delete _'

    if exists('*s:Process_{a:browserMode}_output')
      call s:Process_{a:browserMode}_output()
    endif
    call append(0, s:header{a:browserMode})
  endif
  setlocal nomodifiable
  call s:MarkBreakPoints(a:name)
  if IsPositionSet('BreakPts')
    call RestoreHardPosition('BreakPts')
    call ResetHardPosition('BreakPts')
  endif
  call s:SetupBuf(a:name == "")
endfunction " }}}

function! s:Process_functions_output() " {{{
  " Remove function prefix and parenthesis.
  let _search = @/
  try
    let @/ = '(.*)$'
    silent! exec "normal! 0\<C-V>Gel\"_d:%s///\<CR>gg0"
  finally
    let @/ = _search
  endtry

  if g:brkptsSortFunctions
    if g:brkptsSortExternalCmd != ''
      silent! exec '%!' . g:brkptsSortExternalCmd
    else
      silent! 1,$call QSort(s:myScriptId . 'FuncNameComparator', 1)
    endif
  endif
endfunction " }}}

function! s:List_script(curScriptId, curScript) " {{{
  let lastLine = line('$')
  silent! call append('$', 'Script: ' . a:curScript . ' (Id: ' . a:curScriptId
        \ . ')')
  let v:errmsg = ''
  silent! exec '$read ' . a:curScript
  if v:errmsg != ''
    call confirm("There was an error loading the script, make sure the path " .
          \ "is absolute or is reachable from current directory: \'" . getcwd()
          \ . "\".\nNOTE: Filenames with regular expressions are not supported."
          \ ."\n".v:errmsg, "&OK", 1, "Error")
    return
  endif
  silent! exec '1,' . lastLine . 'delete _'
  " Insert line numbers in the front.
  let _search = @/
  try
    let @/ = '^'
    silent! 2,$s//\=strpart((line(".") - 1)."    ", 0, 5)/
    1
  finally
    let @/ = _search
  endtry
endfunction " }}}

function! s:List_function(sid, funcName) " {{{
  let funcListing = s:GetVimCmdOutput('function ' . a:funcName)
  if funcListing == ""
    return
  endif

  let lastLine = line('$')
  silent! $put =funcListing
  silent! exec '1,' . (lastLine + 1) . 'delete _'
  if g:brkptsModFuncHeader
    let _search = @/
    try
      let @/ = '^\(\s\+\)function '
      silent! 1s//\1function! /
    finally
      let @/ = _search
    endtry
  endif
  call s:FixInitWhite()
endfunction " }}}

function! s:FuncNameComparator(func1, func2, direction) " {{{
  let sid1 = s:ExtractSID(a:func1)
  let funcName1 = s:ExtractFuncName(a:func1)
  let sid2 = s:ExtractSID(a:func2)
  let funcName2 = s:ExtractFuncName(a:func2)

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

function! s:GetBrowserMode() " {{{
  let headLine = getline(1)
  if headLine =~ '^\s*function!\= '
    let mode = s:BM_FUNCTION
  elseif headLine =~ '^'.s:header{s:BM_FUNCTIONS}.'$'
    let mode = s:BM_FUNCTIONS
  elseif headLine =~ '^Script: '
    let mode = s:BM_SCRIPT
  elseif headLine =~ '^'.s:header{s:BM_SCRIPTS}.'$'
    let mode = s:BM_SCRIPTS
  elseif headLine =~ '^'.s:header{s:BM_BRKPTS}.''
    let mode = s:BM_BRKPTS
  else
    let mode = g:brkptsDefStartMode
  endif
  return mode
endfunction " }}}

" Browser functions }}}


" Breakpoint handling {{{

function! s:DoAction() " {{{
  if line('.') == 1 " Ignore the header line.
    return
  endif
  let browserMode = s:GetBrowserMode()
  if browserMode == s:BM_BRKPTS
    " FIXME: Won't work if not English.
    if getline('.') =~ 'No breakpoints defined'
      return
    endif
    exec s:GetBrklistLineParser(getline('.'), 'name', 'mode')
    if mode ==# 'func'
      let mode = s:BM_FUNCTION
    elseif mode ==# 'file'
      let mode = s:BM_SCRIPT
    endif
    call s:OpenListing(0, mode, 0, name)
    call search('^'.lnum.'\>', 'w')
  elseif browserMode == s:BM_SCRIPTS
    let curScript = s:GetScript()
    let curScriptId = s:GetScriptId()
    if curScript != '' && curScriptId != ''
      call s:OpenListing(0, s:BM_SCRIPT, curScriptId, curScript)
    endif
  elseif browserMode == s:BM_FUNCTION || browserMode == s:BM_FUNCTIONS
        \ || browserMode == s:BM_SCRIPT
    let curFunc = s:GetFuncName()
    if curFunc != ''
      let scrPrefix = matchstr(curFunc, '^\%(s:\|<SID>\)')
      if scrPrefix != ''
        let curSID = s:GetListingId()
        let curFunc = strpart(curFunc, strlen(scrPrefix))
        if curSID == ""
          let curSID = s:SearchForSID(curFunc)
        endif
        if curSID == ""
          echohl ERROR | echo "Sorry, SID couldn't be determined!!!" |
                \ echohl NONE
          return
        endif
        let curFunc = '<SNR>' . curSID . '_' . curFunc
      endif
      call s:OpenListing(0, s:BM_FUNCTION, '', curFunc)
    endif
  endif
endfunction " }}}

function! s:OpenListing(force, mode, id, name) " {{{
  call s:OpenListingWindow(0)
  call s:Browser(a:force, a:mode, a:id, a:name)
endfunction " }}}

" Accepts a partial path valid under 'rtp'
function! s:OpenScript(rtPath) " {{{
  let path = a:rtPath
  if ! filereadable(path) && fnamemodify(path, ':p') != path
    call MvIterCreate(&rtp, '\\\@<!\(\\\\\)*\zs,', 'BPRTP', ',')
    while MvIterHasNext('BPRTP')
      let dir = MvIterNext('BPRTP')
      if filereadable(dir.'/'.a:rtPath)
        let path = dir.'/'.a:rtPath
      endif
    endwhile
    call MvIterDestroy('BPRTP')
  else
    let path = fnamemodify(path, ':p')
  endif
  call s:OpenListing(0, s:BM_SCRIPT, 0, path )
endfunction " }}}

" Pattern to extract the breakpt number out of the :breaklist.
let s:BRKPT_NR = '\%(^\|['."\n".']\+\)\s*\zs\d\+\ze\s\+\%(func\|file\)' .
      \ '\s\+\S\+\s\+line\s\+\d\+'
" Mark breakpoints {{{
function! s:MarkBreakPoints(name)
  let b:brkPtLines = ''
  let brkPts = s:GetVimCmdOutput('breaklist')
  let pat = ''
  let browserMode = s:GetBrowserMode()
  if browserMode == s:BM_FUNCTIONS
    let pat = '\d\+\s\+func \zs\%(<SNR>\d\+_\)\?\k\+\ze\s\+line \d\+'
  elseif browserMode == s:BM_FUNCTION
    let pat = '\d\+\s\+func ' . a:name . '\s\+line \zs\d\+'
  elseif browserMode == s:BM_SCRIPTS
    let pat = '\d\+\s\+file \zs\f\+\ze\s\+line \d\+'
  elseif browserMode == s:BM_SCRIPT
    let pat = '\d\+\s\+file \m' . escape(a:name, "\\") . '\M\s\+line \zs\d\+'
  elseif browserMode == s:BM_BRKPTS
    let pat = s:BRKPT_NR
  endif
  let loc = ''
  let curIdx = 0
  if pat != ''
    while curIdx != -1 && curIdx < strlen(brkPts)
      let loc = matchstr(brkPts, pat, curIdx)
      if loc != ''
        let line = 0
        if (browserMode == s:BM_FUNCTION || browserMode == s:BM_FUNCTIONS) &&
              \ search('^'. loc . '\>')
          let line = line('.')
        elseif browserMode == s:BM_SCRIPTS && search('\V'.escape(loc, "\\"))
          let line = line('.')
        elseif browserMode == s:BM_SCRIPT
          let line = loc + 1
        elseif browserMode == s:BM_BRKPTS && search('^\s*'.loc)
          let line = line('.')
        endif
        if line != 0
          if !MvContainsElement(b:brkPtLines, ',', line) && has("signs")
            exec 'sign place ' . line . ' line=' . line .
                  \ ' name=VimBreakPt buffer=' . bufnr('%')
          endif
          let b:brkPtLines = b:brkPtLines . line . ','
        endif
      endif
      let curIdx = matchend(brkPts, pat, curIdx)
    endwhile
  endif
  if b:brkPtLines != ''
    let b:brkPtLines = MvQSortElements(b:brkPtLines, ',', 'CmpByNumber', 1)
    if g:brkptsCreateFolds && exists(':FoldNonMatching')
      silent! exec "FoldShowLines " . b:brkPtLines . " " . g:brkptsFoldContext
      1
    endif
  endif
  call s:MarkCurLineInCntxt()
  return
endfunction

function! s:MarkCurLineInCntxt()
  silent! syn clear BreakPtsContext
  if s:curLineInCntxt != '' && s:GetListingName() == s:curNameInCntxt
    exec 'syn match BreakPtsContext "\%'.s:curLineInCntxt.'l.*"'
  endif
endfunction
" }}}

function! s:NextBrkPt(dir) " {{{
  let nextBP = MvNumSearchNext(b:brkPtLines, ',', line('.'), a:dir)
  if nextBP != ''
    exec nextBP
  endif
endfunction " }}}

" Add/Remove breakpoints {{{
" Add breakpoint at the current line.
function! s:AddBreakPoint(name, mode, browserMode, brkLine)
  let v:errmsg = ""
  let lnum = a:brkLine
  let browserMode = a:browserMode
  let mode = a:mode
  if browserMode == s:BM_FUNCTION
    let name = a:name
  elseif browserMode == s:BM_SCRIPT
    let name = substitute(a:name, "\\\\", '/', 'g')
  elseif browserMode == s:BM_BRKPTS
    exec s:GetBrklistLineParser(getline('.'), 'name', 'mode')
  endif
  if lnum == 0
    call s:ExecCmd('breakadd ' . mode . ' ' . name)
  else
    call s:ExecCmd('breakadd ' . mode . ' ' . lnum . ' ' . name)
  endif
  if v:errmsg != ""
    echohl ERROR | echo s:GetMessage("Error setting breakpoint for: ",
          \ name, lnum)."\n".v:errmsg | echohl None
    return
  endif
  echo s:GetMessage("Break point set for: ", name, lnum)
  if browserMode == s:BM_BRKPTS
    " We need to update the current line for the new id.
    " Get the breaklist output, the last line would be for the latest
    "   breakadd.
    setl modifiable
    let brkLine = matchstr(s:GetVimCmdOutput('breaklist'), s:BRKPT_NR.'$')
    call setline('.',
          \ substitute(getline('.'), '^\(\s*\)\d\+', '\1'.brkLine, ''))
    setl nomodifiable
  endif
  if !MvContainsElement(b:brkPtLines, ',', line('.')) && has("signs")
    exec 'sign place ' . line('.') . ' line=' . line('.') .
          \ ' name=VimBreakPt buffer=' . winbufnr(0)
  endif
  let b:brkPtLines = b:brkPtLines . line('.') . ','
endfunction

function! s:GetMessage(msg, name, brkLine)
  return a:msg . a:name . "(line: " . a:brkLine . ")."
endfunction

" Remove breakpoint at the current line.
function! s:RemoveBreakPoint(name, mode, browserMode, brkLine)
  let v:errmsg = ""
  let lnum = a:brkLine
  let browserMode = a:browserMode
  let mode = a:mode
  if browserMode == s:BM_FUNCTION
    let name = a:name
    let mode = 'func'
  elseif browserMode == s:BM_SCRIPT
    let name = a:name
    let mode = 'file'
  elseif browserMode == s:BM_BRKPTS
    exec s:GetBrklistLineParser(getline('.'), 'name', 'mode')
  endif
  if lnum == 0
    call s:ExecCmd('breakdel ' . mode . ' ' . name)
  else
    call s:ExecCmd('breakdel ' . mode . ' ' . lnum . ' ' . name)
  endif
  if v:errmsg != ""
    echohl ERROR | echo s:GetMessage("Error clearing breakpoint for: ",
          \ name, lnum) . "\nRefresh to see the latest breakpoints."
          \ | echohl None
    return
  endif
  echo s:GetMessage("Break point cleared for: ", name, lnum)
  let b:brkPtLines = MvRemoveElement(b:brkPtLines, ',', line('.'))
  " There could be multiple breakpoints at the same line.
  if !MvContainsElement(b:brkPtLines, ',', line('.')) && has("signs")
    sign unplace
  endif
endfunction

function! s:ToggleBreakPoint()
  let brkLine = -1
  let browserMode = s:GetBrowserMode()
  if browserMode == s:BM_FUNCTIONS || browserMode == s:BM_SCRIPTS
    return
  endif
  if browserMode == s:BM_FUNCTION
    let name = s:GetListingName()
    let mode = 'func'
    if line('.') == 1 || line('.') == line('$')
      let brkLine = 1
    else
      let brkLine = matchstr(getline('.'), '^\d\+')
      if brkLine == ''
        let brkLine = 0
      endif
    endif
  elseif browserMode == s:BM_SCRIPT
    let name = s:GetListingName()
    let mode = 'file'
    if line('.') == 1
      +
    endif
    let brkLine = line('.')
    let brkLine = brkLine - 1
  elseif browserMode == s:BM_BRKPTS
    exec s:GetBrklistLineParser(getline('.'), 'name', 'mode')
    let brkLine = line('.')
  endif
  if brkLine >= 0
    if MvContainsElement(b:brkPtLines, ',', line('.'))
      call s:RemoveBreakPoint(name, mode, browserMode, brkLine)
    else
      call s:AddBreakPoint(name, mode, browserMode, brkLine)
    endif
  endif
endfunction

function! s:ClearSigns()
  if exists('b:brkPtLines') && b:brkPtLines != ''
    call SaveHardPosition('ClearSigns')
    call MvIterCreate(b:brkPtLines, ',', 'ClearSigns')
    let linesCleared = ''
    while MvIterHasNext('ClearSigns')
      let nextBrkLine = MvIterNext('ClearSigns')
      "exec 'sign unplace ' . nextBrkLine . ' buffer=' . bufnr('%')
      if !MvContainsElement(linesCleared, ',', nextBrkLine) && has("signs")
        exec nextBrkLine
        " FIXME: Weird, I am getting E159 here. This used to work fine.
        "sign unplace
        exec 'sign unplace' nextBrkLine
      endif
      let linesCleared = linesCleared . ',' . nextBrkLine
    endwhile
    call MvIterDestroy('ClearSigns')
    call RestoreHardPosition('ClearSigns')
    call ResetHardPosition('ClearSigns')
  endif
endfunction

function! s:SaveBrkPts(varName)
  let brkList = s:GetVimCmdOutput('breaklist')
  if brkList =~ '.*No breakpoints defined.*'
    call confirm("There are currently no breakpoints defined.",
          \ "&OK", 1, "Info")
  else
    let brkList = substitute(brkList,
          \ '\%(^\|'."\n".'\)\@<=\s*\d\+\s\+\(\S\+\)\s\+\([^'."\n".
          \     ']\+\)\s\+line\s\+\(\d\+\)\%('."\n".'\|$\)\@=',
          \ '\=":breakadd ".submatch(1)." ".submatch(3)." ".'.
          \     'substitute(submatch(2), "\\\\", "/", "g")', 'g')
    let varName = substitute(a:varName, '^g:', '', '')
    exec 'let g:'.a:varName.' = brkList'
    call confirm("The breakpoints have been saved into global variable: " .
          \ a:varName, "&OK", 1, "Info")
  endif
endfunction
 
function! s:ClearAllBrkPts()
  let choice = confirm("Do you want to clear all the breakpoints?",
        \ "&Yes\n&No", "1", "Question")
  if choice == 1
    let breakList = s:GetVimCmdOutput('breaklist')
    let clearCmds = substitute(breakList,
          \ '\(\d\+\)\%(\s\+\%(func\|file\)\)\@=' . "[^\n]*",
          \ ':breakdel \1', 'g')
    let v:errmsg = ''
    call s:ExecCmd(clearCmds)
    if v:errmsg != ''
      call confirm("There were errors clearing breakpoints.\n".v:errmsg,
            \ "&OK", 1, "Error")
    endif
  endif
endfunction

function! s:GetBrklistLineParser(line, nameVar, modeVar)
  return substitute(a:line,
        \ '^\s*\d\+\s\+\(\S\+\)\s\+\(.\{-}\)\s\+line\s\+\(\d\+\)$', "let ".
        \ a:modeVar."='\\1' | let ".a:nameVar."='\\2' | let lnum=\\3", '')
endfunction
" Add/Remove breakpoints }}}

" Breakpoint handling }}}


" Utilities {{{

" {{{
" Get the function/script name that is currently being listed. 
" As it appears in the :breaklist command.
function! s:GetListingName()
  let browserMode = s:GetBrowserMode()
  if browserMode == s:BM_FUNCTION
    return s:GetListedFunction()
  elseif browserMode == s:BM_SCRIPT
    return s:GetListedScript()
  else
    return ''
  endif
endfunction

" Get the function/script id that is currently being listed. 
" As it appears in the :breaklist command.
function! s:GetListingId()
  let browserMode = s:GetBrowserMode()
  if browserMode == s:BM_FUNCTION
    return s:ExtractSID(s:GetListedFunction())
  elseif browserMode == s:BM_SCRIPT
    return s:GetListedScriptId()
  else
    return ''
  endif
endfunction

function! s:GetListedScript()
  return matchstr(getline(1), '^Script: \zs\f\+\ze (Id: \d\+)')
endfunction

function! s:GetListedScriptId()
  return matchstr(getline(1), '^Script: \f\+ (Id: \zs\d\+\ze)')
endfunction

function! s:GetScript()
  return matchstr(getline('.'), '^\s*\d\+: \zs\f\+\ze$')
endfunction

function! s:GetScriptId()
  return matchstr(getline('.'), '^\s*\zs\d\+\ze: \f\+$')
endfunction

function! s:GetFuncName()
  let funcName = expand('<cWORD>') " Treat any word as a possible function name.
  " Any non-alpha except <>_: which are not allowed in the function name.
  if match(funcName, "[~`!@$%^&*()-+={}[\\]|\\;'\",.?/]") != -1
    let funcName = ''
  endif
  return funcName
endfunction

function! s:GetListedFunction() " Includes SID.
  return matchstr(getline(1),
        \ '\%(^\s*function!\? \)\@<=\%(<SNR>\d\+_\)\?\f\+\%(([^)]*)\)\@=')
endfunction

function! s:ExtractSID(funcName)
  return matchstr(a:funcName, '^<SNR>\zs\d\+\ze_')
endfunction

function! s:ExtractFuncName(funcName)
  let sidEnd = matchend(a:funcName, '>\d\+_')
  let sidEnd = (sidEnd == -1) ? 0 : sidEnd
  let funcEnd = stridx(a:funcName, '(') - sidEnd
  let funcEnd = (funcEnd < 0) ? strlen(a:funcName) : funcEnd
  return strpart(a:funcName, sidEnd, funcEnd)
endfunction
" }}}

function! s:SearchForSID(funcName) " {{{
  " First find the current maximum SID (keeps increasing as more scrpits get
  "   loaded, ftplugin, syntax and others).
  let maxSID = 0
  let scripts = s:GetVimCmdOutput("script")
  let maxSID = matchstr(scripts, "\\d\\+\\ze: [^\x0a]*$") + 0

  let i = 0
  while i <= maxSID
    if exists('*<SNR>' . i . '_' . a:funcName)
      return i
    endif
    let i = i + 1
  endwhile
  return ''
endfunction " }}}

function! s:OpenListingWindow(always) " {{{
  if s:opMode ==# 'WinManager' || a:always
    if s:funcBufNum == -1
      " Temporarily modify isfname to avoid treating the name as a pattern.
      let _isf = &isfname
      try
        set isfname-=\
        set isfname-=[
        if s:opMode ==# 'WinManager'
          if exists('+shellslash')
            call WinManagerFileEdit("\\\\".escape(s:BreakListing_title, ' '), 1)
          else
            call WinManagerFileEdit("\\".escape(s:BreakListing_title, ' '), 1)
          endif
        else
          if exists('+shellslash')
            exec "sp \\\\". escape(s:BreakListing_title, ' ')
          else
            exec "sp \\". escape(s:BreakListing_title, ' ')
          endif
        endif
      finally
        let &isfname = _isf
      endtry
      let s:funcBufNum = bufnr('%') + 0
    else
      if s:opMode ==# 'WinManager'
        call WinManagerFileEdit(s:funcBufNum, 1)
      else
        let win = bufwinnr(s:funcBufNum)
        if win != -1
          exec win.'wincmd w'
        else
          exec 'sp #'.s:funcBufNum
        endif
      endif
    endif
    call s:SetupBuf(0)
  endif
endfunction " }}}

function! s:ReloadCurrentScript() " {{{
  let browserMode = s:GetBrowserMode()
  let curScript = ''
  if browserMode == s:BM_SCRIPTS
    let curScript = s:GetScript()
    let needsRefresh = 0
  elseif browserMode == s:BM_SCRIPT
    let curScript = s:GetListedScript()
    let needsRefresh = 1
  endif
  if curScript != ''
    let plugName = substitute(fnamemodify(curScript, ':t:r'), '\W', '_', 'g')
    let varName = s:GetPlugVarIfExists(curScript)
    if varName == ''
      let choice = confirm("Couldn't identify the global variable that ".
            \ "indicates that this plugin has already been loaded.\nDo you " .
            \ "want to continue anyway?", "&Yes\n&No", 1, "Question")
      if choice == 2
        return
      endif
    else
      call s:ExecCmd('unlet ' . varName)
    endif

    let v:errmsg = ''
    call s:ExecCmd('source ' . curScript)
    if v:errmsg == ''
      call confirm("The script: \"" . curScript .
            \ "\" has been successfully reloaded.", "&OK", 1, "Info")
      if needsRefresh
        call s:BrowserRefresh(0)
      endif
    else
      call confirm("There were errors reloading script: \"" . curScript .
            \ "\".\n" . v:errmsg, "&OK", 1, "Error")
    endif
  endif
endfunction " }}}

function! s:GetPlugVarIfExists(curScript) " {{{
  let plugName = fnamemodify(a:curScript, ':t:r')
  let varName = 'g:loaded_' . plugName
  if ! s:EvalExpr("exists('".varName."')")
    let varName = 'g:loaded_' . substitute(plugName, '\W', '_', 'g')
    if ! s:EvalExpr("exists('".varName."')")
      let varName = 'g:loaded_' . substitute(plugName, '\u', '\L&', 'g')
      if ! s:EvalExpr("exists('".varName."')")
        return ''
      endif
    endif
  endif
  return varName
endfunction " }}}

" functions SetupBuf/Quit {{{
function! s:SetupBuf(full)
  call SetupScratchBuffer()
  setlocal nowrap
  setlocal bufhidden=hide
  setlocal isk+=< isk+=> isk+=: isk+=_
  set ft=vim
  " Don't make the <SNR> part look like an error.
  if hlID("vimFunctionError") != 0
    syn clear vimFunctionError
    syn clear vimCommentString
  endif
  syn match vimFunction "\<fu\%[nction]!\=\s\+\U.\{-}("me=e-1 contains=@vimFuncList nextgroup=vimFuncBody
  syn match vimFunction "^\k\+$"
  syn region vimCommentString contained oneline start='\%(^\d\+\s*\)\@<!\S\s\+"'ms=s+1 end='"'
  syn match vimLineComment +^\d\+\s*[ \t:]*".*$+ contains=@vimCommentGroup,vimCommentString,vimCommentTitle
  syn match BreakPtsHeader "^\%1l\%(Script:\|Scripts:\|Functions:\|Breakpoints:\).*"
  syn match BreakPtsScriptLine "^\s*\d\+: \f\+$" contains=BreakPtsScriptId
  syn match BreakPtsScriptId "^\s*\d\+" contained

  if a:full
    " Invert these to mean close instead of open.
    command! -buffer -nargs=? BreakPts :call <SID>BreakPtsLocal(<f-args>)
    nnoremap <buffer> <silent> <Plug>BreakPts :BreakPts<CR>
    nnoremap <silent> <buffer> q :BreakPts<CR>
  endif

  exec 'command! -buffer BPScripts :call <SID>Browser(0,
        \ "' . s:BM_SCRIPTS . '", "", "")'
  exec 'command! -buffer BPFunctions :call <SID>Browser(0,
        \ "' . s:BM_FUNCTIONS . '", "", "")'
  exec 'command! -buffer BPPoints :call <SID>Browser(0,
        \ "' . s:BM_BRKPTS . '", "", "")'
  command! -buffer -nargs=? BPRemoteServ :call <SID>SetRemoteServer(<f-args>)

  command! -buffer BPBack :call <SID>NavigateBack()
  command! -buffer BPForward :call <SID>NavigateForward()
  command! -buffer BPSelect :call <SID>DoAction()
  command! -buffer BPOpen :call <SID>Open()
  command! -buffer BPToggle :call <SID>ToggleBreakPoint()
  command! -buffer BPRefresh :call <SID>BrowserRefresh(0)
  command! -buffer BPNext :call <SID>NextBrkPt(1)
  command! -buffer BPPrevious :call <SID>NextBrkPt(-1)
  command! -buffer BPReload :call <SID>ReloadCurrentScript()
  command! -buffer BPClearAll :BreakPtsClearAll
  command! -buffer -nargs=1 BPSave :BreakPtsSave <args>
  exec "command! -buffer -nargs=1 -complete=function BPListFunc " .
        \ ":call <SID>OpenListing(0, '".s:BM_FUNCTION."', '', " .
        \ "substitute(<f-args>, '()\\=', '', ''))"
  exec "command! -buffer -nargs=1 -complete=file BPListScript " .
        \ ":call <SID>OpenScript(<f-args>)"
  nnoremap <silent> <buffer> <BS> :BPBack<CR>
  nnoremap <silent> <buffer> <Tab> :BPForward<CR>
  nnoremap <silent> <buffer> <CR> :BPSelect<CR>
  nnoremap <silent> <buffer> o :BPOpen<CR>
  nnoremap <silent> <buffer> <2-LeftMouse> :BPSelect<CR>
  nnoremap <silent> <buffer> <F9> :BPToggle<CR>
  nnoremap <silent> <buffer> R :BPRefresh<CR>
  nnoremap <silent> <buffer> [b :BPPrevious<CR>
  nnoremap <silent> <buffer> ]b :BPNext<CR>
  nnoremap <silent> <buffer> O :BPReload<CR>

  command! -buffer BPDWhere :call <SID>ShowRemoteContext()
  command! -buffer BPDCont :call <SID>ExecDebugCmd('cont')
  command! -buffer BPDQuit :call <SID>ExecDebugCmd('quit')
  command! -buffer BPDNext :call <SID>ExecDebugCmd('next')
  command! -buffer BPDStep :call <SID>ExecDebugCmd('step')
  command! -buffer BPDFinish :call <SID>ExecDebugCmd('finish')

  call s:DefMap("n", "ContKey", "<F5>", ":BPDCont<CR>")
  call s:DefMap("n", "QuitKey", "<S-F5>", ":BPDQuit<CR>")
  call s:DefMap("n", "NextKey", "<F12>", ":BPDNext<CR>")
  call s:DefMap("n", "StepKey", "<F11>", ":BPDStep<CR>")
  call s:DefMap("n", "FinishKey", "<S-F11>", ":BPDFinish<CR>")
  call s:DefMap("n", "ClearAllKey", "<C-S-F9>", ":BPClearAll<CR>")
  "call s:DefMap("n", "RunToCursorKey", "<C-F10>", ":BPDRunToCursor<CR>")

  " A bit of a setup for syntax colors.
  hi def link BreakPtsBreakLine WarningMsg
  hi def link BreakPtsContext Visual
  hi def link BreakPtsHeader Comment
  hi def link BreakPtsScriptId Number
endfunction

" With no arguments, behaves like quit, and with arguments, just refreshes.
function! s:BreakPtsLocal(...)
  if a:0 == 0
    call s:Quit()
  else
    call s:BrowserMain(a:1)
  endif
endfunction

function! s:Quit()
  " The second condition is for non-buffer plugin buffers.
  if s:opMode !=# 'WinManager' || bufnr('%') != s:myBufNum
    if NumberOfWindows() == 1
      redraw | echohl WarningMsg | echo "Can't quit the last window" |
            \ echohl NONE
    else
      quit
    endif
  endif
endfunction " }}}

function! s:DefMap(mapType, mapKeyName, defaultKey, cmdStr) " {{{
  let key = maparg('<Plug>BreakPts' . a:mapKeyName)
  " If user hasn't specified a key, use the default key passed in.
  if key == ""
    let key = a:defaultKey
  endif
  exec a:mapType . "noremap <buffer> <silent> " . key a:cmdStr
endfunction " DefMap " }}}

" Sometimes there is huge amount white-space in the front for some reason.
function! s:FixInitWhite() " {{{
  let nWhites = strlen(matchstr(getline(2), '^\s\+'))
  if nWhites > 0
    let _search = @/
    try
      let @/ = '^\s\{'.nWhites.'}'
      silent! %s///
      1
    finally
      let @/ = _search
    endtry
  endif
endfunction " }}}

function! s:SetRemoteServer(...) " {{{
  if a:0 == 0
    echo "Current remote Vim server: " . s:remoteServName
  else
    let servName = a:1
    if s:remoteServName != servName
      if servName == v:servername
        let servName = '.'
      endif
      let s:remoteScriptId = s:EvalExpr('BPScriptId()')
      let s:remoteServName = servName
      setl modifiable
      call OptClearBuffer()
      call s:BrowserRefresh(1)
      setl nomodifiable
    endif
  endif
endfunction " }}}

function! s:EvalExpr(expr) " {{{
  if s:remoteServName !=# '.'
    try
      return remote_expr(s:remoteServName, a:expr)
    catch
      let v:errmsg = substitute(v:exception, '^[^:]\+:', '', '')
      call s:ShowRemoteError(v:exception, s:remoteServName)
      return ''
    endtry
  else
    let result = ''
    try
      exec 'let result =' a:expr
    catch
      " Ignore
    endtry
    return result
  endif
endfunction " }}}

function! s:GetVimCmdOutput(cmd) " {{{
  return s:EvalExpr('GetVimCmdOutput('.QuoteStr(a:cmd).')')
endfunction " }}}

function! s:ShowRemoteError(msg, servName) " {{{
  call confirm('Error executing remote command: ' . a:msg .
        \ "\nCheck that the Vim server with the name: " . a:servName .
        \ ' exists and that it has breakpts.vim installed.', '&OK', 1, 'Error')
endfunction " }}}

function! s:ExecCmd(cmd) " {{{
  if s:remoteServName !=# '.'
    try
      call remote_expr(s:remoteServName, "GetVimCmdOutput('".a:cmd."')")
    catch
      let v:errmsg = substitute(v:exception, '^[^:]\+:', '', '')
      call s:ShowRemoteError(v:exception, s:remoteServName)
      return 1
    endtry
  else
    silent! exec a:cmd
  endif
  return 0
endfunction " }}}

function! s:ExecDebugCmd(cmd) " {{{
  try
    if s:remoteServName !=# '.' &&
          \ remote_expr(s:remoteServName, 'mode()') ==# 'c'
      call remote_send(s:remoteServName, "\<C-U>".a:cmd."\<CR>")
      call s:WaitForDbgPrompt()
      if remote_expr(s:remoteServName, 'mode()') ==# 'c'
        call s:ShowRemoteContext()
      endif
    endif
  catch
    let v:errmsg = substitute(v:exception, '^[^:]\+:', '', '')
    call s:ShowRemoteError(v:exception, s:remoteServName)
  endtry
endfunction " }}}

function! s:WaitForDbgPrompt() " Throws remote exceptions. {{{
  sleep 100m " Minimum time.
  try
    if remote_expr(s:remoteServName, 'mode()') ==# 'c'
      return 1
    else
      try
        while 1
          sleep 1
          if remote_expr(s:remoteServName, 'mode()') ==# 'c'
            break
          endif
        endwhile
        return 1
      catch /^Vim:Interrupt$/
      endtry
    endif
    return 0
  catch
    let v:errmsg = substitute(v:exception, '^[^:]\+:', '', '')
    call s:ShowRemoteError(v:exception, s:remoteServName)
  endtry
endfunction " }}}

function! s:ShowRemoteContext() " {{{
  let context = s:GetRemoteContext()
  if context != ''
    let mode = s:BM_FUNCTION
    " FIXME: Get the function stack and make better use of it.
    exec substitute(context,
          \ '^function \%('.s:FUNC_NAME_PAT.'\.\.\)*\('.s:FUNC_NAME_PAT.
          \ '\), line \(\d\+\)$',
          \ 'let name = "\1" | let lineNo = "\2"', '')
    if name == ''
      exec substitute(context,
            \ '^\([^,]\+\), line \(\d\+\)$',
            \ 'let name = "\1" | let lineNo = "\2"', '')
      let mode = s:BM_SCRIPT
    endif
    if name != ''
      if name != s:GetListingName()
        call s:Browser(0, mode, '', name)
      endif
      let s:curNameInCntxt = name
      let s:curLineInCntxt = lineNo + 1 " 1 extra for function header.
      if s:curLineInCntxt != ''
        exec s:curLineInCntxt
        if winline() == winheight(0)
          normal! z.
        endif
        call s:MarkCurLineInCntxt()
      endif
    else
      let s:curNameInCntxt = ''
      let s:curLineInCntxt = ''
    endif
  endif
endfunction " }}}

function! s:GetRemoteContext() " {{{
  try
    if s:remoteServName !=# '.' &&
          \ remote_expr(s:remoteServName, 'mode()') ==# 'c'
      " FIXME: Assume C-U is not mapped.
      call remote_send(s:remoteServName, "\<C-U>exec ".
            \ s:remoteScriptId."GenContext()\<CR>")
      sleep 100m " FIXME: Otherwise the var is not getting updated.
      " WHY: if the remote vim crashes in this call, no exception seems to get
      "   generated.
      return remote_expr(s:remoteServName, 'g:BPCurContext')
    endif
  catch
    let v:errmsg = substitute(v:exception, '^[^:]\+:', '', '')
    call s:ShowRemoteError(v:exception, s:remoteServName)
  endtry
  return ''
endfunction " }}}

function! s:Open() " {{{
  let browserMode = s:GetBrowserMode()
  if browserMode == s:BM_SCRIPTS
    let curScript = s:GetScript()
    let bufNr = bufnr(curScript)
    let winNr = bufwinnr(bufNr)
    if winNr != -1
      exec winNr . 'wincmd w'
    else
      if winbufnr(2) == -1
        split
      else
        wincmd p
      endif
      if bufNr != -1
        exec 'edit #'.bufNr
      else
        exec 'edit '.curScript
      endif
    endif
  else
    call s:DoAction()
  endif
endfunction " }}}

" BPBreak {{{
let s:breakIf = ''
function! s:BPBreak(offset, clear)
  if s:breakIf == ''
    let s:breakIf = ExtractFuncListing(s:myScriptId.'_BreakIf', 0, 0)
  endif
  return substitute(substitute(s:breakIf, '<offset>', a:offset, 'g'),
        \ '<clear>', a:clear, 'g')
endfunction

function! BPBreak(offset)
  return s:BPBreak(a:offset, 1)
endfunction

function! BPBreakIf(cond, offset)
  if a:cond
    return BPBreak(a:offset)
  else
    return ''
  endif
endfunction

function! BPScriptId()
  return s:myScriptId
endfunction

function! BPDeBreak(offset)
  return s:BPBreak(a:offset, 0)
endfunction

function! BPDeBreakIf(cond, offset)
  if a:cond
    return BPDeBreak(a:offset)
  else
    return ''
  endif
endfunction

function! s:_BreakIf()
  try
    throw ''
  catch
    let __breakLine = v:throwpoint
  endtry
  if __breakLine =~# '^function '
    let __breakLine = substitute(__breakLine,
          \ '^function \%(\%(\k\|[<>]\)\+\.\.\)*\(\%(\k\|[<>]\)\+\), ' .
          \     'line\s\+\(\d\+\)$',
          \ '\="func " . (submatch(2) + <offset>) . " " . submatch(1)', '')
  else
    let __breakLine = substitute(__breakLine,
          \ '^\(.\{-}\), line\s\+\(\d\+\)$',
          \ '\="file " . (submatch(2) + <offset>) . " " . submatch(1)', '')
  endif
  if __breakLine != ''
    silent! exec "breakdel " . __breakLine
    if <clear>
      exec "breakadd " . __breakLine
    endif
  endif
  unlet __breakLine
endfunction
" BPBreak }}}

" Context {{{
" Generate the current context into g:BPCurContext variable
let g:BPCurContext = ''
let s:genContext = ''
function! s:GenContext()
  if s:genContext == ''
    let s:genContext = ExtractFuncListing(s:myScriptId.'_GenContext', 0, 0)
  endif
  return s:genContext
endfunction

function! s:_GenContext()
  try
    throw ''
  catch
    let g:BPCurContext = v:throwpoint
  endtry
endfunction
" Context }}}

function! s:RuntimeComplete(ArgLead, CmdLine, CursorPos)
  return s:RuntimeCompleteImpl(a:ArgLead, a:CmdLine, a:CursorPos, 1)
endfunction

function! s:RuntimeCompleteImpl(ArgLead, CmdLine, CursorPos, smartSlash)
  return UserFileComplete(a:ArgLead, a:CmdLine, a:CursorPos, a:smartSlash, &rtp)
endfunction

function! s:BreakAddComplete(ArgLead, CmdLine, CursorPos)
  let sub = strpart(a:CmdLine, 0, a:CursorPos)
  let cmdPrefixPat = '^\s*Breaka\%[dd]\s\+'
  if sub =~# cmdPrefixPat.'func\s\+'
    return substitute(GetVimCmdOutput('function'), '^\n\|function \([^(]\+\)([^)]*)'
          \ , '\1', 'g')
  elseif sub =~# cmdPrefixPat.'file\s\+'
    return s:RuntimeCompleteImpl(a:ArgLead, a:CmdLine, a:CursorPos, 0)
  else
    return "func\nfile\n"
  endif
endfunction

function! s:BreakDelComplete(ArgLead, CmdLine, CursorPos)
  let brkPts = substitute(GetVimCmdOutput('breaklist'), '^\n', '', '')
  if brkPts !~ 'No breakpoints defined'
    return substitute(brkPts, '\s*\d\+\s\+\(func\|file\)\([^'."\n".
          \ ']\{-}\)\s\+line\s\+\(\d\+\)', '\1 \3 \2', 'g')
  else
    return ''
  endif
endfunction
" Utilities }}}


" Navigation {{{
function! s:NavigateBack()
  call s:Navigate('u')
  if getline(1) == ''
    call s:NavigateForward()
    call s:MarkBreakPoints(s:GetListingName())
  endif
endfunction


function! s:NavigateForward()
  call s:Navigate("\<C-R>")
endfunction


function! s:Navigate(key)
  call s:ClearSigns()
  let _modifiable = &l:modifiable
  setlocal modifiable
  normal! mt

  silent! exec "normal" a:key

  let &l:modifiable = _modifiable
  call s:MarkBreakPoints(s:GetListingName())

  if line("'t") > 0 && line("'t") <= line('$')
    normal! `t
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
  call s:BrowserRefresh(0)
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

" vim6:fdm=marker sw=2 et
