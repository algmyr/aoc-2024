let g:calc = "norm 0d$A\<C-r>=\<C-r>\"\<cr>\<esc>"

function Part1()
  " Get second column sorted into register as a block.
  g/^$/d
  %s/.* \+//g
  sort
  execute "normal gg\<C-v>G$\"ad"
  norm u

  " Also sort first column and concatenate together with minus.
  g/^$/d
  %s/ \+.*//g
  sort
  %s/$/-/g
  norm gg$"ap

  " Evaluate line using expression register, and remove sign.
  execute "%" .. g:calc
  %s/-//

  " Insert pluses, join, execute expression.
  %norm I+
  %join
  execute g:calc
endfunction

function Part2()
  " Insert multiplication with search count.
  g/^$/d
  %s/ /*/
  execute "%norm ^yt*f*a\<C-r>=searchcount(#{pattern: \" \<C-r>\"$\"}).total\<cr>\<esc>"

  " Clean up, insert pluses, join, execute expression.
  %norm 0f D
  %norm I+
  %join
  execute g:calc
endfunction
