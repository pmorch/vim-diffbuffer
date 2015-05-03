vim-diffbuffer
==============

Show me a unified diff between the buffer and the file on-disk. Useful
e.g.  for when you're trying to exit, and you discover:

    E37: No write since last change

for some file you had forgotten you'd made changes to.

    :DiffBufferWithTab

shows you a window with all your changes in a unified diff (diff -u)
format.

Yeah, I know there are several other vim plugins that'll give me a diff
between the buffer and the file on-disk, but I like 80 char terminals
and so side-by-side diffs are useless. And I like unified diff.
