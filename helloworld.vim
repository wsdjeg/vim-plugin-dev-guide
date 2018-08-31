function! helloworld#complete(ArgLead, CmdLine, CursorPos) abort
    return "hellojeky\nhellolucy\nhellolily"
endfunction
function! helloworld#test()

    

endfunction

command! -nargs=* -complete=custom,helloworld#complete HelloWorld call helloworld#test()
