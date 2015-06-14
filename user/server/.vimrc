" Author:  Matthew Wozniski (mjw@drexel.edu)
"
" Feel free to do whatever you would like with this file as long as you give
" credit where credit is due.
"
" NOTE:
" If you're editing this in Vim and don't know how folding works, type zR to
" unfold everything.  And then read ":help folding".

" Stop behaving like vi; vim's enhancements are better.
set nocompatible

if version >= 603
    set helplang=cn
endif

let g:mail = "51feel@gmail.com"
let g:author = "Zeroman Yang"

" Skip the rest of this file unless we have +eval and Vim 7.0 or greater.
" With an older Vim, I'd rather just plain ol' vi-like features reminding me
" to upgrade.
if version >= 700
""" Self define functions
""""  CountMatches
function! CountMatches(...)
  try
    if getreg('/') == ''
      return ""
    endif

    let fast = 0

    if a:0 && a:1
      let fast = 1
    endif

    if fast && line('$') > 5000
      return ""
    endif

    let toomany = 0

    let [buf, lnum, cnum, off] = getpos('.')
    call setpos('.', [buf, lnum, cnum, off])

    let above=0
    let below=0

    while 1
      let [l, c] = searchpos(@/, 'bnW')
      if l == 0 && c == 0
        break
      endif

      let above += 1
      call setpos('.', [buf, l, c, 0])
      if above + below > 100
        let toomany = 1
        break
      endif
    endwhile

    call setpos('.', [buf, lnum, cnum, off])

    if toomany
      return ""
    endif

    let [l, c] = searchpos(@/, 'cnW')
    if l == lnum && c == cnum
      let above += 1
    endif

    call setpos('.', [buf, lnum, cnum, off])

    while 1
      let [l, c] = searchpos(@/, 'nW')
      if l == 0 && c == 0
        break
      endif

      let below += 1
      call setpos('.', [buf, l, c, 0])
      if above + below > 100
        let toomany = 1
        break
      endif
    endwhile

    call setpos('.', [buf, lnum, cnum, off])

    if toomany || (above+below) == 0
      return ""
    endif

    return "Match ".above." of ".(below+above)
  catch /.*/
    return ""
  endtry
endfunction

"""" NewPyFile
function! NewPyFile() 
    exec "normal ggi"."#!/usr/bin/env python\<cr># -*- coding: utf-8 -*-\<cr>"
endfunction 

"""" NewJavaScriptFile
function! NewJavaScriptFile() 
    exec "normal ggi"."\"use strict\"\<cr>"
endfunction 

"""" NewShFile
function! NewShFile() 
    exec "normal ggi"."#!/bin/sh\<cr>\<cr>"
endfunction 

"""" NewT2TFile
function! NewT2TFile() 
    set ft=txt2tags
    let now = strftime('%Y-%m-%d %H:%M:%S', localtime())
    exec "normal ggi"."\<cr>".g:mail."\<cr>".now
    unlet now
    exec "normal gg"
    startinsert!
endfunction 

"""" ReadT2TFile
function! ReadT2TFile() 
    set ft=txt2tags
    let g:tlist_txt2tags_settings='txt2tags;d:Titles'
endfunction 

"""" AutoTag
function! AutoTag() 
    if filereadable("./tags")
        if has("win32")
            silent  exec "!e:\cygwin\root\bin\ctags -a \"%\" > /dev/null"
        else
            silent  exec "!ctags -a \"%\" > /dev/null"
        endif
        " :redraw
    endif
endfunction 

"""" Timestamp
function! Timestamp(comment)
  if (a:comment == '')
    return
  endif
  let pattern = '\('.a:comment.' Last Change:\s\+\)\d\{4}-\d\{2}-\d\{2} \d\{2}:\d\{2}:\d\{2}'
  let row = search('\%^\_.\{-}\(^\zs' . pattern . '\)', 'n')
  let now = strftime('%Y-%m-%d %H:%M:%S', localtime())
  if row != 0
    let new_row_str =substitute(getline(row), '^' . pattern , '\1', '') . now
    call setline(row, new_row_str)
  else
    normal m'
    silent! :1
    normal O
    let new_row_str = a:comment . " Last Change: " . now
    call setline(1, new_row_str)
    normal ''
  endif
endfunction

"""" AutoChangeTheme
function! AutoChangeTheme()
  let col_tags = globpath("d:/vim/vimfiles/colors,", "*.vim")
  let col_files = split(col_tags, "\n", "\zs")
  let col_num = len(col_files)
  for i in range(0,col_num)
    " echo matchstr(col_files[i],
  endfo
  " source d:\vim\vimfiles\colors\adam.vim
  unlet col_files
  unlet col_num
endfunction

"""" Do_splint
function! Do_splint()
  let makeprg_saved='"'.&makeprg.'"'
  exe	":cclose"
  :setlocal makeprg=splint
  exe "make \"%\" -nullpass -warnposix +matchanyintegral"
  exe	"setlocal makeprg=".makeprg_saved
  :redraw!
  exe	":botright cwindow"
endfunction

"""" Do_make
function! Do_make(arch)
  if filereadable("Makefile")
    exe	":cclose"
    if (a:arch == 'arm')
      " exe "make ARCH=arm"
      :set makeprg="make ARCH=arm"
    else
      :set makeprg=make
    endif
    exe ":make"
    :redraw!
    exe	":botright cwindow"
  else
    exe "!gcc % -g"
    :redraw!
    exe	":botright cwindow"
  endif
endfunction

"""" GtkTags
function! GtkTags()
  " set tag=tags,~/.vim/tags/libc.tags,~/.vim/tags/libgtk.tags,
  " set tag=tags,~/.vim/tags/libc.tags,~/.vim/tags/libgtk.tags,
  " execute 'cscope add ~/.vim/tags/libgtk.out'
  set tag=tags,../tags
endfunction

"""" CreateFunctionDef
function! CreateFunctionDef()
	let a:ln = getline(".")
	let a:ln = substitute(a:ln, '^\s\+', "", "")
	let a:ln = substitute(a:ln, 'virtual\s\+', "", "")
	let a:ln = substitute(a:ln, ';', "", "")

	let a:class = search('class', 'b')
	let a:class = getline(a:class)
	if strlen(a:class)>0
		let a:class = matchlist(a:class, 'class\s\+\(\w\+\)')[1]
		let a:fname = substitute(a:ln, '\(\w\+\s\+\)*\(.*\)', '\1'.a:class.'::\2', '') 
		let a:ln = a:fname
	endif	

	let a:hname = bufname("%")
	let a:cppname = matchlist(a:hname, '\(.*/\)*\(.*\)\.h')[2] . ".cpp"
	let a:cppname = bufname(a:cppname)
	let a:datas = readfile(a:cppname)
	let a:datas = add(a:datas, a:ln)
	let a:datas = add(a:datas, '{')
	" let a:type = substitute(a:ln, '\([a-zA-Z]\+\)\s\+.*', 'return \1();', '')
	" if a:type != a:ln
		" let a:datas = add(a:datas, a:type)
	" endif	
	let a:datas = add(a:datas, '}')
	let a:datas = add(a:datas, '')
	call writefile(a:datas, a:cppname)
	" execute 'e '.a:cppname
endfunction

"""" Auto save session 
function! AutoSaveSession()
    "NERDTree doesn't support session, so close before saving
    " execute ':NERDTreeClose' 
    execute 'mksession! .vim_session'
endfunction

"""" Auto restore session
function! AutoRestoreSession()
    let session_path = expand('.vim_session')
    if filereadable(session_path)
        execute 'source ' . session_path
    endif
endfunction

""" Settings
"""" Locations environment
set exrc

"""" Mouse, Keyboard, Terminal
set mouse=a                 " Allow mouse use in normal and visual mode.
" set timeoutlen=2000         " Wait 2 seconds before timing out a mapping
" set ttimeoutlen=100         " and only 100 ms before timing out on a keypress.
" set lazyredraw              " Avoid redrawing the screen mid-command.
" set ttyscroll=3             " Prefer redraw to scrolling for more than 3 lines

" XXX Fix a vim bug: Only t_te, not t_op, gets sent when leaving an alt screen
exe "set t_te=" . &t_te . &t_op

""""" Titlebar
set notitle                   " Turn on titlebar support

" Set the to- and from-status-line sequences to match the xterm titlebar
" manipulation begin/end sequences for any terminal where
"   a) We don't know for a fact that these sequences would be wrong, and
"   b) the sequences were not already set in terminfo.
" NOTE: This would be nice to fix in terminfo, instead...
if &term !~? '^\v(linux|cons|vt)' && empty(&t_ts) && empty(&t_fs)
  exe "set t_ts=\<ESC>]2;"
  exe "set t_fs=\<C-G>"
endif

"  Titlebar string: hostname> ${PWD:s/^$HOME/~} || (view|vim) filename ([+]|)
let &titlestring  = hostname() . '> ' . '%{expand("%:p:~:h")}'
                \ . ' || %{&ft=~"^man"?"man":&ro?"view":"vim"} %f %m'

" When vim exits and the original title can't be restored, use this string:
if !empty($TITLE)
  " We know the last title set by the shell. (My zsh config exports this.)
  let &titleold = $TITLE
else
  "  Old title was probably something like: hostname> ${PWD:s/^$HOME/~}
  let &titleold = hostname() . '> ' . fnamemodify($PWD,':p:~:s?/$??')
endif

""""" Encoding/Multibyte
if has('multi_byte')        " If multibyte support is available and
  if &enc !~? 'utf-\=8'     " the current encoding is not Unicode,
    if empty(&tenc)         " default to
      let &tenc = &enc      " using the current encoding for terminal output
    endif                   " unless another terminal encoding was already set
  endif
  set encoding=utf-8        " set default encoding as UTF-8
  set termencoding=utf-8    " support Chinese display in rxvt-unicode
  set fileencodings=ucs-bom,utf-8,chinese,latin1 " fileconding detection order
  if has("win32")
    set fileencoding=chinese
    source $VIMRUNTIME/delmenu.vim
    source $VIMRUNTIME/menu.vim
    language messages zh_CN.utf-8
  else
    set fileencoding=utf-8
  endif
endif

"""" Moving Around/Editing
" set nostartofline           " Avoid moving cursor to BOL when jumping around
"set whichwrap=b,s,h,l,<,>   " <BS> <Space> h l <Left> <Right> can change lines
set virtualedit=block       " Let cursor move past the last char in <C-v> mode
set scrolloff=3             " Keep 3 context lines above and below the cursor
" set backspace=2             " Allow backspacing over autoindent, EOL, and BOL
" set backspace=eol,start,indent "Set backspace
set showmatch               " Briefly jump to a paren once it's balanced
set matchtime=4             " (for only .2 seconds).

"""" Searching and Patterns
" set ignorecase              " Default to using case insensitive searches,
" set smartcase               " unless uppercase letters are used in the regex.
set hlsearch                " Highlight searches by default.
set incsearch               " Incrementally search while typing a /regex

"""" Windows, Buffers
set noequalalways           " Don't keep resizing all windows to the same size
set hidden                  " Hide modified buffers when they are abandoned
set swb=useopen,usetab      " Allow changing tabs/windows for quickfix/:sb/etc
set splitright              " New windows open to the right of the current one

"""" Insert completion
" set completeopt-=preview    " Don't show preview menu for tags.
set completeopt=longest,menu
" set infercase               " Try to adjust insert completions for case.

"""" Folding
set foldmethod=syntax       " By default, use syntax to determine folds
set foldlevelstart=99       " All folds open by default

"""" Text Formatting
" set formatoptions=q         " Format text with gq, but don't format as I type.
" set formatoptions+=n        " gq recognizes numbered lists, and will try to
" set formatoptions+=1        " break before, not after, a 1 letter word

"""" Display
set number                  " Display line numbers
set numberwidth=1           " using only 1 column (and 1 space) while possible

" if &enc =~ '^u\(tf\|cs\)'   " When running in a Unicode environment,
  " set list                  " visually represent certain invisible characters:
  " let s:arr = nr2char(9655) " using U+25B7 (▷) for an arrow, and
  " let s:dot = nr2char(8901) " using U+22C5 (⋅) for a very light dot,
  " display tabs as an arrow followed by some dots (▷⋅⋅⋅⋅⋅⋅⋅),
  " exe "set listchars=tab:"    . s:arr . s:dot
  " and display trailing and non-breaking spaces as U+22C5 (⋅).
  " exe "set listchars+=trail:" . s:dot
  " exe "set listchars+=nbsp:"  . s:dot
  " Also show an arrow+space (↪ ) at the beginning of any wrapped long lines?
  " I don't like this, but I probably would if I didn't use line numbers.
  " let &sbr=nr2char(8618).' '
" endif

"""" Messages, Info, Status
set vb t_vb=                " Disable all bells.  I hate ringing/flashing.
set confirm                 " Y-N-C prompt if closing with unsaved changes.
set showcmd                 " Show incomplete normal mode commands as I type.
set report=0                " : commands always print changed line count.
set shortmess+=a            " Use [+]/[RO]/[w] for modified/readonly/written.
set ruler                   " Show some info, even without statuslines.
set laststatus=2            " Always show statusline, even if only 1 window.

let &statusline = '%<%f%{&mod?"[+]":""}%r%'
 \ . '{&fenc !~ "^$\\|utf-8" || &bomb ? "[".&fenc.(&bomb?"-bom":"")."]" : ""}'
 \ . '%='
 \ . '%{exists("actual_curbuf")&&bufnr("")==actual_curbuf?CountMatches(1):""}'
 \ . '%15.(%l,%c%V %P%)'

"""" Tabs/Indent Levels
set autoindent              " Do dumb autoindentation when no filetype is set
set tabstop=4               " Real tab characters are 4 spaces wide,
set shiftwidth=4            " but an indent level is 4 spaces wide.
set softtabstop=4           " <BS> over an autoindent deletes both spaces.
set expandtab               " Use spaces, not tabs, for autoindent/tab key.

"""" Tags
set tags=./tags;/home       " Tags can be in ./tags, ../tags, ..., /home/tags.
set showfulltag             " Show more information while completing tags.
if has("win32")
    set path=.
    set tag=tags,
else
    set tag=tags,../tags,../../tags,~/.vim/tags/libc.tags
    " set autochdir
    "set tag=tags,~/.vim/tags/libc.tags,~/.vim/tags/libminigui.tags,
    "set path =.,./include,/usr/include/,/usr/include/linux/,/usr/include/sys,
endif
" auto load cscope.out
if has("cscope")
    if has("win32")
        set csprg=e:\cygwin\root\bin\mlcscope.exe
    endif
    set cscopetag               " When using :tag, <C-]>, or "vim -t", try cscope:
    set cscopetagorder=0        " try ":cscope find g foo" and then ":tselect foo"
    set csto=1
    set cspc=10
    set nocsverb
    if filereadable("./cscope.out") 
        execute 'cscope add ./cscope.out'
    elsei filereadable("../cscope.out") 
        execute 'cscope add ../cscope.out'
    elsei filereadable("../../cscope.out") 
        execute 'cscope add ../../cscope.out'
    endif
    if filereadable("~/.vim/tags/libc.out") 
        execute 'cscope add ~/.vim/tags/libc.out'
    endif
endif
nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

"""" Reading/Writing
set noautowrite             " Never write a file unless I request it.
set noautowriteall          " NEVER.
set noautoread              " Don't automatically re-read changed files.
set modeline                " Allow vim options to be embedded in files;
set modelines=5             " they must be within the first or last 5 lines.
set ffs=unix,dos,mac        " Try recognizing dos, unix, and mac line endings.

"""" Backups/Swap Files
" Make sure that the directory where we want to put swap/backup files exists.
set writebackup             " Make a backup of the original file when writing
set backup                  " and don't delete it after a succesful write.
set backupskip=             " There are no files that shouldn't be backed up.
set updatetime=2000         " Write swap files after 2 seconds of inactivity.
set backupext=~             " Backup for "file" is "file~"
let tempdir = $HOME."/.backup"
if ! isdirectory(tempdir)
    call mkdir(tempdir, "p", 0700)
endif
set backupdir^=~/.backup/      " Backups are written to ~/.backup/ if possible.
set directory^=~/.backup       " Swap files are also written to ~/.backup, too.
unlet tempdir
" ^ Here be magic! Quoth the help:
" For Unix and Win32, if a directory ends in two path separators "//" or "\\",
" the swap file name will be built from the complete path to the file with all
" path separators substituted to percent '%' signs.  This will ensure file
" name uniqueness in the preserve directory.

"""" Undo setting
if version >= 703
  let tempdir = "/tmp/.vim_undo_".$USER
  if ! isdirectory(tempdir)
    call mkdir(tempdir, "p", 0700)
  endif
  set undofile
  set undolevels=200
  set undodir=tempdir
  unlet tempdir
endif


"""" Command Line
set history=1000            " Keep a very long command-line history.
set wildmenu                " Menu completion in command mode on <Tab>
set wildmode=full           " <Tab> cycles between all matching choices.
set wcm=<C-Z>               " Ctrl-Z in a mapping acts like <Tab> on cmdline
source $VIMRUNTIME/menu.vim " Load menus (this would be done anyway in gvim)
" <F4> triggers the menus, even in terminal vim.
" map <F4> :emenu <C-Z>

"""" Per-Filetype Scripts
" NOTE: These define autocmds, so they should come before any other autocmds.
"       That way, a later autocmd can override the result of one defined here.
filetype on                 " Enable filetype detection,
filetype indent on          " use filetype-specific indenting where available,
filetype plugin on          " also allow for filetype-specific plugins,
syntax on                   " and turn on per-filetype syntax highlighting.

"""" Sessions
set sessionoptions=buffers,curdir,help,tabpages


"""" for fcitx
let g:input_toggle = 1
function! Fcitx2en()
   let s:input_status = system("fcitx-remote")
   if s:input_status == 2
      let g:input_toggle = 1
      let l:a = system("fcitx-remote -c")
   endif
endfunction

function! Fcitx2zh()
   let s:input_status = system("fcitx-remote")
   if s:input_status != 2 && g:input_toggle == 1
      let l:a = system("fcitx-remote -o")
      let g:input_toggle = 0
   endif
endfunction

" set timeoutlen=150
autocmd InsertLeave * call Fcitx2en()
"autocmd InsertEnter * call Fcitx2zh()


"""" Others
" set spell spelllang=en_us "美国英文

""" Plugin Settings
"""" Common Settings
let lisp_rainbow=1          " Color parentheses by depth in LISP files.
let is_posix=1              " I don't use systems where /bin/sh isn't POSIX.
let bufExplorerFindActive=0 " Disable emulated 'switchbuf' from BufExplorer
let vim_indent_cont=4       " Spaces to add for vimscript continuation lines
let no_buffers_menu=1       " Disable gvim 'Buffers' menu
let surround_indent=1       " Automatically reindent text surround.vim actions

" Disable FuzzyFinder's MRU Command completion, since it breaks :debug
let FuzzyFinderOptions = { 'MruCmd' : { 'mode_available' : 0 } }

" When using a gvim-only colorscheme in terminal vim with CSApprox
"   - Disable the bold and italic attributes completely
"   - Use the color specified by 'guisp' as the foreground color.
let g:CSApprox_attr_map = { 'bold' : '', 'italic' : '', 'sp' : 'fg' }

" Enable syntax folding in perl scripts.
let [ g:perl_fold, g:perl_fold_blocks ] = [ 1, 1 ]


"""" for vundle
if isdirectory(glob("~/.vim/bundle/vundle"))
    filetype off 
    set rtp+=~/.vim/bundle/vundle

    call vundle#rc()
    Bundle 'a.vim'
    Bundle 'cpp.vim' 
    Bundle 'xml.vim'
    Bundle 'mru.vim'
    Bundle 'txt2tags'
    Bundle 'pydoc.vim'
    Bundle 'ShowMarks'
    Bundle 'Auto-Pairs'
    Bundle 'taglist.vim'
    Bundle 'gmarik/vundle'
    Bundle 'ZenCoding.vim'
    Bundle 'IndentAnything'
    Bundle 'lekv/vim-clewn'
    Bundle 'kien/ctrlp.vim'
    Bundle 'OmniCppComplete'
    Bundle 'bash-support.vim'
    Bundle 'tpope/vim-surround'
    Bundle 'DoxygenToolkit.vim'
    Bundle 'python.vim--Vasiliev'
    Bundle 'scrooloose/syntastic'
    Bundle 'honza/vim-snippets'
    Bundle 'Shougo/neosnippet.git'
    Bundle "Lokaltog/vim-powerline"
    Bundle 'flazz/vim-colorschemes'
    Bundle 'code_complete-new-update'
    Bundle 'skammer/vim-css-color.git'
    Bundle 'git://repo.or.cz/vcscommand'
    Bundle 'scrooloose/nerdcommenter.git'

    " Bundle 'fholgado/minibufexpl.vim.git'
    " Bundle 'Zeroman/minibufexpl.vim.git'

    if exists("g:js_on")
        Bundle 'html5.vim'
        Bundle 'jsbeautify'
        Bundle 'JavaScript-syntax'
        Bundle 'hallettj/jslint.vim'
        Bundle 'Javascript-Indentation'
    endif

    if exists("g:go_on")
        Bundle 'jnwhiteh/vim-golang.git'
    endif

    if exists("g:ycp_on")
        Bundle 'Valloric/YouCompleteMe.git'
    else
        Bundle 'Shougo/vimproc.git'
        Bundle 'Shougo/neocomplcache'
    endif

    " Bundle 'snipMate'
    " Bundle 'echofunc.vim'
    " Bundle 'Shougo/vimshell.git'

    filetype on                 " Enable filetype detection,
    filetype plugin indent on 
endif


"""" for OmniCppComplete
" Turn off automatic omnicompletion for C++, I'll ask for it if I want it.
" let [ OmniCpp_MayCompleteDot, OmniCpp_MayCompleteArrow ] = [ 0, 0 ]
let OmniCpp_DefaultNamespaces   = ["std", "_GLIBCXX_STD"]


"""" for BASH_SUPPORT
let g:BASH_AuthorName   = 'Zeroman Yang'     
let g:BASH_AuthorRef    = 'Zeroman'                         
let g:BASH_Email        = '51feel@gmail.com'            
let g:BASH_Company      = 'BLT.Ltd'    

"""" for doxygen
let g:DoxygenToolkit_authorName="Zeroman Yang <51feel@gmail.com>" 
let g:DoxygenToolkit_versionTag="0.01"
let g:DoxygenToolkit_commentType = "C++" 

"""" for grep.vim
nnoremap <silent> <F6> :Rgrep<CR>
let Grep_Default_Filelist = '*.cpp *.c *.h *.CPP *.H'
if has("win32")
    let Grep_Path = 'd:\\Vim\\GnuWin32\\bin\\grep.exe'
    let Fgrep_Path = 'd:\\Vim\GnuWin32\\bin\\fgrep.exe'
    let Egrep_Path = 'd:\\Vim\\GnuWin32\\bin\\egrep.exe'
    let Grep_Find_Path = 'd:\\Vim\\GnuWin32\\bin\\find.exe'
    let Grep_Xargs_Path = 'd:\\Vim\\GnuWin32\\bin\\xargs.exe'
    "let Grep_Default_Options = 
    let Grep_OpenQuickfixWindow = 1
    " let Grep_Cygwin_Find = 1
endif

"""" for showmarks
let g:showmarks_hlline_lower=1
let g:showmarks_textlower=" "
let g:showmarks_include="abcdefghijklmnopqrstuvwxyz"

"""" for suptab
" let g:SuperTabRetainCompletionType=2
" 由于NeoComplCache在手工模式下使用快捷键组合<C-X><C-U>打开补全列表，故设置SuperTab的默认补全操作为<C-X><C-U>
" let g:SuperTabDefaultCompletionType = "<C-X><C-O>"
" 设置按下<Tab>后默认的补全方式, 默认是<C-P>, 现在改为<C-X><C-O>.
" let g:SuperTabDefaultCompletionType="<C-X><C-O>"

"""" for neocomplcache
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_max_list = 30
let g:neocomplcache_max_keyword_width = 32
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Enable heavy features.
" Use camel case completion.
"let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
"let g:neocomplcache_enable_underbar_completion = 1

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
" inoremap <expr><C-g>     neocomplcache#undo_completion()
" inoremap <expr><C-l>     neocomplcache#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
" <TAB>: completion.
" inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
" inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
" inoremap <expr><C-y>  neocomplcache#close_popup()
" inoremap <expr><C-e>  neocomplcache#cancel_popup()

" for insert mode move cursor
" inoremap <expr> <C-j> neocomplcache#smart_close_popup()."\<Down>"
" inoremap <expr> <C-k> neocomplcache#smart_close_popup()."\<Up>"
" inoremap <expr> <C-l> neocomplcache#smart_close_popup()."\<Right>"
" inoremap <expr> <C-h> neocomplcache#smart_close_popup()."\<Left>"
" inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"

" AutoComplPop like behavior.
" let g:neocomplcache_enable_auto_select = 1

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplcache_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
highlight Pmenu ctermbg=8 guibg=#606060
highlight PmenuSel ctermbg=1 guifg=#dddd00 guibg=#1f82cd
highlight PmenuSbar ctermbg=0 guibg=#d6d6d6


"""" for youcompleteme
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/cpp/ycm/.ycm_extra_conf.py'


"""" for snipMate
" ino <c-d> <c-r>=TriggerSnippet()<cr>
" snor <c-d> <esc>i<right><c-r>=TriggerSnippet()<cr>

"""" for neosnippet
" Plugin key-mappings.
imap <C-d>     <Plug>(neosnippet_expand_or_jump)
smap <C-d>     <Plug>(neosnippet_expand_or_jump)
" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif
let g:neosnippet#snippets_directory='~/.vim/bundle/snipmate-snippets/snippets'
let g:neosnippet#enable_snipmate_compatibility = 1


"""" for plugin Align
let g:Align_xstrlen = 3

"""" set MRU
map <F7> <C-c>:Mru <cr>
let MRU_Max_Entries = 2000
let MRU_Auto_Close = 1
let MRU_Add_Menu = 0

"""" for EnhComment
let g:EnhCommentifyMultiPartBlocks = 'yes'
let g:EnhCommentifyPretty = 'Yes'
let g:EnhCommentifyRespectIndent = 'Yes'

"""" for command-t
set wildignore+=*.o,*.arm,*.html,*.obj,.git,.svn,*.d

"""" for errormarker
let errormarker_disablemappings = 1
"nmap <silent> <unique> <Leader>em :ErrorAtCursor<CR>

"""" for vcscommand
let VCSCommandMapPrefix='<Leader>v'

"""" for taglist
nnoremap <silent> <M-l> :TlistToggle<CR>
let Tlist_Show_One_File=1
" let Tlist_Use_Right_Window=1

"""" for NerdComment
let NERDSpaceDelims = 1
let NERDCompactSexyComs = 1
nmap <M-m> <plug>NERDCommenterInvert
vmap <M-m> <plug>NERDCommenterMinimal
" map  <M-N> <plug>NERDCommenterUncomment
nmap <M-M> <plug>NERDCommenterAppend

"""" for NERDTree"
map <F1> :NERDTree<CR> 

"""" for autopair"
let g:AutoPairs = {'[':']', '{':'}',"'":"'",'"':'"', '`':'`'}

"""" for minibufexplorer
let g:miniBufExplSplitBelow = 1 
let g:miniBufExplSplitToEdge = 1
let g:statusLineText=''

"""" for code_complete.vim
" let g:completekey = "<F9>"   "hotkey
" let g:CodeCompl_Hotkey = "<tab>"
let g:CodeCompl_Hotkey = "<F9>"

"""" for a.vim
let g:alternateNoDefaultAlternate = 1

"""" for Solarized 
if has('gui_running') || &t_Co > 16
    let g:solarized_termcolors=256
    let g:solarized_contrast="high"
    set background=light
else
    let g:solarized_termcolors=16
    let g:solarized_contrast="high"
    set background=dark
endif
syntax enable
" colorscheme solarized

""" Autocommands
if has("autocmd")
  augroup vimrcEx
  au!
  " In plain-text files and svn commit buffers, wrap automatically at 78 chars
  au FileType text,svn setlocal tw=78 fo+=t

  " Try to jump to the last spot the cursor was at in a file when reading it.
  au BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal g`\"" |
      \ endif

  " Use :make to syntax check a perl script.
  au FileType perl set makeprg=perl\ -c\ %\ $* errorformat=%f:%l:%m

  " Use :make to compile C, even without a makefile
  au FileType c   if glob('[Mm]akefile') == "" | let &mp="gcc -o %< %" | endif

  " Use :make to compile C++, too
  au FileType cpp if glob('[Mm]akefile') == "" | let &mp="g++ -o %< %" | endif

  " When py files Don't use spaces, not tabs, for autoindent/tab key.
  au Filetype py set expandtab 

  " Insert Vim-version as X-Editor in mail headers
  au FileType mail sil 1  | call search("^$")
               \ | sil put! ='X-Editor: Vim-' . Version()

  au Filetype * let &l:ofu = (len(&ofu) ? &ofu : 'syntaxcomplete#Complete')

  au BufRead,BufNewFile ~/.zsh/.zfunctions/[^.]* setf zsh

  au BufWritePost ~/.Xdefaults redraw|echo system('xrdb '.expand('<amatch>'))

  au BufNewFile *.h,*.c,*.cpp           :DoxAuthor
  au BufNewFile *.py                    call NewPyFile()
  au BufNewFile *.js                    call NewJavaScriptFile()
  " au BufNewFile *.sh                  call NewShFile()
  au BufNewFile *.t2t                   call NewT2TFile()
  au BufRead *.t2t                      call ReadT2TFile()
  " au FileType c,cpp set efm=%f%l:\ %m,In\ file\ included\ from\ %f:%l:%c:,%f:%l:%c:\ %m
  " au BufWritePost,FileWritePost   *.h,*.c,*.cpp    call AutoTag()
  " au BufWritePre *vimrc,*.vim         call Timestamp('"')
  " au BufWritePre .exrc                call Timestamp('"')
  " au BufWritePre *.h,*.c              call Timestamp('//')
  " au BufWritePre Makefile             call Timestamp('#')



  " au BufRead,BufNewFile * nested if &l:filetype =~# '^\(c\|cpp\)$'
  " \ | let &l:ft .= ".doxygen.glib.gobject.gdk.gdkpixbuf.gtk.gimp"
  " \ | endif

  " for valgrind
  au BufNewFile,BufRead *.supp set ft=supp

  augroup END
endif

""" Colorscheme
" if $background == "light" && (&t_Co > 16 || has('gui_running'))
" colorscheme autumnleaf  " 256 color light scheme
" elseif $background == "light"
" colorscheme biogoo      " 16 color light scheme
" colorscheme solarized
" elseif &t_Co > 16 || has('gui_running')
" colorscheme brookstream " 256 color dark scheme
" colorscheme blacksea " 256 color dark scheme
" colorscheme solarized
" else
" colorscheme torte       " 16 color dark scheme
" endif
" hi Pmenu guibg=#010101 guifg=#ffccff
" colorscheme BlackSea " 256 color dark scheme

""" Key Mappings

" Make [[ and ]] work even if the { is not in the first column
nnoremap <silent> [[ :call search('^\S\@=.*{$', 'besW')<CR>
nnoremap <silent> ]] :call search('^\S\@=.*{$', 'esW')<CR>
onoremap <expr> [[ (search('^\S\@=.*{$', 'ebsW') && (setpos("''", getpos('.'))
                  \ <bar><bar> 1) ? "''" : "\<ESC>")
onoremap <expr> ]] (search('^\S\@=.*{$', 'esW') && (setpos("''", getpos('.'))
                  \ <bar><bar> 1) ? "''" : "\<ESC>")

" Use \sq to squeeze blank lines with :Squeeze, defined below
nnoremap <leader>sq :Squeeze<CR>

" In visual mode, \box draws a box around the highlighted text.
vnoremap <leader>box <ESC>:call <SID>BoxIn()<CR>gvlolo

" I'm sorry.  :(  Some Emacs bindings for the command window
cnoremap <C-A>     <Home>
cnoremap <ESC>b    <S-Left>
cnoremap <ESC>f    <S-Right>
cnoremap <ESC><BS> <C-W>

" CTRL-g shows filename and buffer number, too.
nnoremap <C-g> 2<C-g>

" <C-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <C-l> :nohl<CR><C-l>

" In normal/insert mode, ar inserts spaces to right align to &tw or 80 chars
nnoremap <leader>ar :AlignRight<CR>

" In normal/insert mode, ac center aligns the text after it to &tw or 80 chars
nnoremap <leader>ac :center<CR>

" Zoom in on the current window with <leader>z
nmap <leader>z <Plug>ZoomWin

" F10 toggles highlighting lines that are too long
" nnoremap <F10> :call <SID>ToggleTooLongHL()<CR>

" F11 toggles line numbering
" nnoremap <silent> <F11> :set number! <bar> set number?<CR>

" F12 toggles search term highlighting
" nnoremap <silent> <F12> :set hlsearch! <bar> set hlsearch?<CR>

" Q formats paragraphs, instead of entering ex mode
noremap Q gq

nnoremap <silent> gqJ :call Exe#ExeWithOpts('norm! gqj', { 'tw' : 2147483647 })<CR>

" <space> toggles folds opened and closed
nnoremap <space> za

" <space> in visual mode creates a fold over the marked range
vnoremap <space> zf

" Pressing an 'enter visual mode' key while in visual mode changes mode.
vmap <C-V> <ESC>`<<C-v>`>
vmap V     <ESC>`<V`>
vmap v     <ESC>`<v`>

" Make { and } in visual mode stay in the current column unless 'sol' is set.
vnoremap <expr> { line("'{") . 'G'
vnoremap <expr> } line("'}") . 'G'

" <leader>bsd inserts BSD copyright notice
nnoremap <leader>bsd :BSD<CR>

" <leader>sk inserts skeleton for the current filetype
nnoremap <leader>sk :Skel<CR>

" Insert a modeline on the last line with <leader>ml
nmap <leader>ml :$put =ModelineStub()<CR>

" Tapping C-W twice brings me to previous window, not next.
nnoremap <C-w><C-w> :winc p<CR>

" Get old behavior with <C-w><C-e>
nnoremap <C-w><C-e> :winc w<CR>

" Y behaves like D rather than like dd
nnoremap Y y$

" Tab configuration
nmap T :tab split<cr>
" map <M-1> <ESC><ESC>:tabnext<cr>
" map <M-2> <ESC><ESC>:tabprevious<cr>
" imap <M-1> <ESC><ESC>:tabnext<cr>
" imap <M-2> <ESC><ESC>:tabprevious<cr>

" Fast cmd
map <leader>qq :qa<cr>
map <leader>qw :wqa<cr>
map <leader>set :tabedit ~/.vimrc<cr>
map <leader>sh :tabedit ~/.bashrc<cr>
map <M-v> "+p
imap <M-v> "+p
map <M-c> "+y
imap <M-c> "+y
map <M-t> d

" Fast remove highlight search
nmap <silent> <leader><cr> :noh<cr>

" For Some shorcut keys
map  <F2> <ESC>:w<cr>
imap <F2> <ESC>:w<cr>
nmap <F5> <ESC>:Dox<cr>
imap <F5> <ESC>:Dox<cr>
nmap <F8> <ESC>:call Do_make('')<cr>
nmap <M-F8> <ESC>:call Do_make('arm')<cr>
map <F12> <ESC>:bd<cr>

" For debug error, set shortcut key for cnext and cprevious
map <M--> <ESC>:cn<cr>
map <M-=> <ESC>:cp<cr>

" for alt-s可以切换有spell check和没有spell check
map <M-s> :set spell! spelllang=en_us<cr>

" 设置class CreateFunctionDef
map <Leader>gc :call CreateFunctionDef()<CR>

map <leader>as :call AutoSaveSession()<CR>
map <leader>ar :call AutoRestoreSession()<CR>

""" Abbreviations
function! EatChar(pat)
  let c = nr2char(getchar(0))
  return (c =~ a:pat) ? '' : c
endfunc

iabbr _me Matthew Wozniski (mjw@drexel.edu)<C-R>=EatChar('\s')<CR>
iabbr #i< #include <><left><C-R>=EatChar('\s')<CR>
iabbr #i" #include ""<left><C-R>=EatChar('\s')<CR>
iabbr _t  <C-R>=strftime("%H:%M:%S")<CR><C-R>=EatChar('\s')<CR>
iabbr _d  <C-R>=strftime("%a, %d %b %Y")<CR><C-R>=EatChar('\s')<CR>
iabbr _dt <C-R>=strftime("%a, %d %b %Y %H:%M:%S %z")<CR><C-R>=EatChar('\s')<CR>

""" Cute functions
" Squeeze blank lines with :Squeeze
command! -nargs=0 Squeeze g/^\s*$/,/\S/-j

function! s:ToggleTooLongHL()
  if exists('*matchadd')
    if ! exists("w:TooLongMatchNr")
      let last = (&tw <= 0 ? 80 : &tw)
      let w:TooLongMatchNr = matchadd('ErrorMsg', '.\%>' . (last+1) . 'v', 0)
      echo "   Long Line Highlight"
    else
      call matchdelete(w:TooLongMatchNr)
      unlet w:TooLongMatchNr
      echo "No Long Line Highlight"
    endif
  endif
endfunction

function! s:BoxIn()
  let mode = visualmode()
  if mode == ""
    return
  endif
  let vesave = &ve
  let &ve = "all"
  exe "norm! ix\<BS>\<ESC>"
  if line("'<") > line("'>")
    undoj | exe "norm! gvo\<ESC>"
  endif
  if mode != "\<C-v>"
    let len = max(map(range(line("'<"), line("'>")), "virtcol([v:val, '$'])"))
    undoj | exe "norm! gv\<C-v>o0o0" . (len-2?string(len-2):'') . "l\<esc>"
  endif
  let diff = virtcol("'>") - virtcol("'<")
  if diff < 0
    let diff = -diff
  endif
  let horizm = "+" . repeat('-', diff+1) . "+"
  if mode == "\<C-v>"
    undoj | exe "norm! `<O".horizm."\<ESC>"
  else
    undoj | exe line("'<")."put! ='".horizm."'" | norm! `<k
  endif
  undoj | exe "norm! yygvA|\<ESC>gvI|\<ESC>`>p"
  let &ve = vesave
endfunction

function! ModelineStub()
  let fmt = ' vim: set ts=%d sts=%d sw=%d %s: '
  let x = printf(&cms, printf(fmt, &ts, &sts, &sw, (&et?"et":"noet")))
  return substitute(substitute(x, '\ \+', ' ', 'g'), ' $', '', '')
endfunction

" Replace tabs with spaces in a string, preserving alignment.
function! Retab(string)
  let rv = ''
  let i = 0

  for char in split(a:string, '\zs')
    if char == "\t"
      let rv .= repeat(' ', &ts - i)
      let i = 0
    else
      let rv .= char
      let i = (i + 1) % &ts
    endif
  endfor

  return rv
endfunction

" Right align the portion of the current line to the right of the cursor.
" If an optional argument is given, it is used as the width to align to,
" otherwise textwidth is used if set, otherwise 80 is used.
function! AlignRight(...)
  if getline('.') =~ '^\s*$'
    call setline('.', '')
  else
    let line = Retab(getline('.'))

    let prefix = matchstr(line, '.*\%' . virtcol('.') . 'v')
    let suffix = matchstr(line, '\%' . virtcol('.') . 'v.*')

    let prefix = substitute(prefix, '\s*$', '', '')
    let suffix = substitute(suffix, '^\s*', '', '')

    let len  = len(substitute(prefix, '.', 'x', 'g'))
    let len += len(substitute(suffix, '.', 'x', 'g'))

    let width  = (a:0 == 1 ? a:1 : (&tw <= 0 ? 80 : &tw))

    let spaces = width - len

    call setline('.', prefix . repeat(' ', spaces) . suffix)
  endif
endfunction
com! -nargs=? AlignRight :call AlignRight(<f-args>)

function! Version()
  let i=1
  while has("patch" . i)
    let i+=1
  endwhile
  return v:version / 100 . "." . v:version % 100 . "." . (i-1)
endfunction
command! Version :echo Version()

command! -nargs=1 -complete=dir Rename saveas <args> | call delete(expand("#"))

""" Some help
" :%s/^[0-9]\{1,4}//g  删除首行的4个数字。
" :%s/^[0-9]\{1,}//g  删除首行的数字。

"" Stop skipping here
endif
"" vim:fdm=expr:fdl=0
"" vim:fde=getline(v\:lnum)=~'^""'?'>'.(matchend(getline(v\:lnum),'""*')-2)\:'='
