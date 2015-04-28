"-------------------------------------------------------------------------------
" DiffBufferWithFile
"  and
" DiffAllBuffersWithFile
"-------------------------------------------------------------------------------
" 
" Note that in 7.1, in the vimrc_example.vim, there is this command from
" ':help :DiffOrig':
"   command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
"         \ | wincmd p | diffthis
" It does a similar thing, but using vim's own diff, which I dislike
"
" There is also
" "diffchanges.vim : Show changes made to current buffer since the last save"
" http://www.vim.org/scripts/script.php?script_id=2158
" and
" http://vim.wikia.com/wiki/Special:Search?search=diff&go=1
" http://vim.wikia.com/wiki/Diff_current_buffer_and_the_original_file

if ! exists("s:diffBufferNewFile")
  let s:diffBufferNewFile = tempname()
  " Just need a file name for display purposes
  let s:diffBufferDispFile = "/DiffOutput"
  let s:diffBufferDiffFile = tempname()
endif

func! s:DiffFileList(filelist)
  if bufexists(s:diffBufferDispFile)
    execute "bwipeout! " . s:diffBufferDispFile
  endif
  execute "silent !rm -f " . s:diffBufferDiffFile 

  for f in a:filelist
      echo "Arg: " . f
      execute "buffer " . f
      execute "1,$w! " . s:diffBufferNewFile 
      execute "silent !diff --label \"" . f . "\" --label \"" . f . 
    \"\" -u \"%\" " . s:diffBufferNewFile . ">> " . 
    \s:diffBufferDiffFile . " 2>&1"
      " Perhaps the exitcode of diff can be queried to make sure the
      " modified flag of the file is set correctly.  Pseudocode from
      " :help getbufvar() : :let bufmodified = getbufvar(1, "&mod")
      " (Maybe even bufname("%") instead of 1.)
  endfor
  redraw!
  execute "edit " . s:diffBufferDiffFile
  execute "silent file " . s:diffBufferDispFile
  set buftype=nofile
  set bufhidden=hide
  setlocal noswapfile

endfunc

func! DiffBufferWithFile()
  if ! strlen(glob(expand("%")))
      echo "No file or file name - won't diff"
  else
      let l:bufnr = bufnr("")
      let s:oldhidden=&hidden
      set hidden
      try
        call s:DiffFileList([expand("%:p")])
        " Set up the alternate file, so CTRL-6, CTRL-^ and :b# go "back"
        execute "buffer " . l:bufnr
        execute "buffer " . s:diffBufferDispFile
      finally
        let &hidden=s:oldhidden
      endtry
  endif
endfunc
command! DiffBufferWithFile call DiffBufferWithFile() 

func! DiffAllBuffersWithFile()
  " The main thrust of this func is to create a list of all files, and
  " give it to Xx
  if bufexists(s:diffBufferDiffFile)
    execute "bwipeout! " . s:diffBufferDiffFile
  endif
  let s:oldhidden=&hidden
  set hidden
  try
    let l:bufnr = bufnr("")
    " This autocmd/augroup stuff is to handle the warnings that would
    " otherwise be shown for each changed file
    let s:allFiles = []
    augroup _tmp_
    autocmd!
    " The must have same width or the output will look weird
    autocmd FileChangedShell * echo ""
          execute "bufdo if strlen(glob(expand(\"%:p\"))) | " .
        \"call add(s:allFiles, expand(\"%:p\")) | endif"
    autocmd!
    augroup END
    execute 'buffer ' . l:bufnr
    call s:DiffFileList(s:allFiles)
    " Set up the alternate file, so CTRL-6, CTRL-^ and :b# go "back"
    execute "buffer " . l:bufnr
    execute "buffer " . s:diffBufferDispFile
  finally
    let &hidden=s:oldhidden
  endtry
endfunc
command! DiffAllBuffersWithFile call DiffAllBuffersWithFile() 
