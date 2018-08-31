function! helloworld#complete(ArgLead, CmdLine, CursorPos) abort
    return filter(['hellolily', 'hellojeky', 'hellofoo', 'world'], 'v:val =~ "^" . a:ArgLead')
endfunction
function! helloworld#test()

    

endfunction

command! -nargs=* -complete=customlist,helloworld#complete HelloWorld call helloworld#test()
