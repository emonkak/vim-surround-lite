let s:operator_pair = 0

function! surround#do_operator_n(operator_func) abort
  call s:setup_operator(a:operator_func)
  let l:count = v:count ? v:count : ''
  return l:count . 'g@'
endfunction

function! surround#do_operator_v(operator_func) abort
  call s:setup_operator(a:operator_func)
  return 'g@'
endfunction

function! surround#operator_add(motion_wiseness) abort
  let [head, tail] = s:query_operator_pair()

  if a:motion_wiseness ==# 'line'
    let append_command = 'A'
    let insert_command = 'I'
  else
    let append_command = 'a'
    let insert_command = 'i'
  endif

  let head_pos = getpos("'[")[1:]
  let tail_pos = getpos("']")[1:]

  call s:new_undo_block()

  call cursor(tail_pos)
  execute 'normal!' append_command . tail . "\<Esc>"

  call cursor(head_pos)
  execute 'normal!' insert_command . head . "\<Esc>"
endfunction

function! surround#operator_change(motion_wiseness) abort
  let [head, tail] = s:query_operator_pair()

  let head_pos = getpos("'[")[1:]
  let tail_pos = getpos("']")[1:]

  call s:new_undo_block()

  call cursor(tail_pos)
  execute 'normal!' 'r' . tail

  call cursor(head_pos)
  execute 'normal!' 'r' . head
endfunction

function! surround#operator_delete(motion_wiseness) abort
  let head_pos = getpos("'[")[1:]
  let tail_pos = getpos("']")[1:]

  call s:new_undo_block()

  call cursor(tail_pos)
  execute 'normal!' 'r vgel"_x'

  let cursor_pos = getpos('.')[1:]
  if head_pos[0] == cursor_pos[0] && head_pos[1] + 1 == cursor_pos[1]
    execute 'normal!' '"_dh'
  else
    call cursor(head_pos)
    execute 'normal!' 'r "_dw'
  endif
endfunction

function! surround#textobj_around_a(head, tail) abort
  let range = s:search_around(a:head, a:tail)
  if range isnot 0
    call s:select_outer(range[0], range[1])
  endif
endfunction

function! surround#textobj_around_i(head, tail) abort
  let range = s:search_around(a:head, a:tail)
  if range isnot 0
    call s:select_inner(range[0], range[1])
  endif
endfunction

function! surround#textobj_between_a(edge) abort
  let range = s:search_between(a:edge)
  if range isnot 0
    call s:select_outer(range[0], range[1])
  endif
endfunction

function! surround#textobj_between_i(edge) abort
  let range = s:search_between(a:edge)
  if range isnot 0
    call s:select_inner(range[0], range[1])
  endif
endfunction

function! s:setup_operator(operator_func) abort
  let &operatorfunc = a:operator_func
  let s:operator_pair = 0
endfunction

function! s:query_operator_pair() abort
  if s:operator_pair is 0
    let char = nr2char(getchar())
    let s:operator_pair = has_key(g:surround_objects, char)
    \                   ? g:surround_objects[char]
    \                   : ['', '']
  endif
  return s:operator_pair
endfunction

function! s:search_around(head, tail) abort
  let head_pattern = '\V\%(\[^\\]\\\)\@<!' . escape(a:head, '\')
  let tail_pattern = '\V\%(\[^\\]\\\)\@<!' . escape(a:tail, '\')

  if search('\%#' . tail_pattern, 'cn') > 0
    let head_flags = 'Wbn'
    let tail_flags = 'Wcn'
  else
    let head_flags = 'Wbcn'
    let tail_flags = 'Wn'
  endif

  let head_pos = searchpairpos(head_pattern, '', tail_pattern, head_flags)
  if head_pos == [0, 0]
    return 0
  endif

  let tail_pos = searchpairpos(head_pattern, '', tail_pattern, tail_flags)
  if tail_pos == [0, 0]
    return 0
  endif

  return [head_pos, tail_pos]
endfunction

function! s:search_between(edge) abort
  let cursor = getpos('.')[1:]
  let pattern = '\V\%(\[^\\]\\\)\@<!' . escape(a:edge, '\\')

  " Move the cursor to the the first character of the current line.
  call cursor(0, 1)

  try
    let current_pos = searchpos(pattern, 'Wc', cursor[0])
    if current_pos == [0, 0]
      return 0
    endif

    let in_quote = 1

    while 1
      let next_pos = searchpos(pattern, 'W', cursor[0])
      if next_pos == [0, 0]
        return 0
      endif

      if in_quote
        if current_pos[1] <= cursor[1] && cursor[1] <= next_pos[1]
          return [current_pos, next_pos]
        endif
      else
        if current_pos[1] < cursor[1] && cursor[1] < next_pos[1]
          return [current_pos, next_pos]
        endif
      endif

      let current_pos = next_pos
      let in_quote = !in_quote
    endwhile
  finally
    call cursor(cursor)
  endtry
endfunction

function! s:select_outer(head_pos, tail_pos) abort
  call cursor(a:head_pos)
  normal! v
  call cursor(a:tail_pos)
  if &selection ==# 'exclusive'
    normal! l
  endif
endfunction

function! s:select_inner(head_pos, tail_pos) abort
  call cursor(a:head_pos)
  normal! vlo
  call cursor(a:tail_pos)
  if &selection !=# 'exclusive'
    execute 'normal!' "\<BS>"
  endif
endfunction

function s:new_undo_block() abort
  " Create a new undo block to keep the cursor position when undo.
  execute 'normal!' 'i ' . "\<Esc>" . '"_x'
endfunction
