let s:is_running_operator = 0

let s:last_operator_delimiters = 0

let s:last_textobj_patterns = 0

function! surround#ask_tag_name() abort
  let tag_name = input('Tag Name: ')
  let start = '<' . tag_name . '>'
  let end = '</' . tag_name . '>'
  return [start, end]
endfunction

function! surround#execute_operator_n(operator_func) abort
  call s:setup_operator(a:operator_func)
  let l:count = v:count ? v:count : ''
  return l:count . 'g@'
endfunction

function! surround#execute_operator_v(operator_func) abort
  call s:setup_operator(a:operator_func)
  return 'g@'
endfunction

function! surround#operator_add(motion_wiseness) abort
  let delimiters = s:ask_operator_delimiters()
  if type(delimiters) == v:t_list
    call s:add_surround(delimiters[0], delimiters[1])
  endif
  let s:is_running_operator = 0
endfunction

function! surround#operator_change(motion_wiseness) abort
  if s:last_textobj_patterns isnot 0
    let delimiters = s:ask_operator_delimiters()
    if type(delimiters) == v:t_list
      let [start_pattern, end_pattern] = s:last_textobj_patterns
      call s:change_surround(start_pattern, end_pattern, delimiters[0], delimiters[1])
    endif
  endif
  let s:is_running_operator = 0
endfunction

function! surround#operator_delete(motion_wiseness) abort
  if s:last_textobj_patterns isnot 0
    let [start_pattern, end_pattern] = s:last_textobj_patterns
    call s:delete_surround(start_pattern, end_pattern)
  endif
  let s:is_running_operator = 0
endfunction

function! surround#textobj_block_a(start_pattern, end_pattern) abort
  let range = s:search_surrounded_block(a:start_pattern, a:end_pattern, 1)
  if range isnot 0
    call s:select_outer(range[0], range[1])
    if s:is_running_operator
      let s:last_textobj_patterns = [a:start_pattern, a:end_pattern]
    endif
  endif
endfunction

function! surround#textobj_block_i(start_pattern, end_pattern) abort
  let range = s:search_surrounded_block(a:start_pattern, a:end_pattern, 0)
  if range isnot 0
    call s:select_inner(range[0], range[1])
    if s:is_running_operator
      let s:last_textobj_patterns = [a:start_pattern, a:end_pattern]
    endif
  endif
endfunction

function! surround#textobj_inline_a(pattern) abort
  let range = s:search_surrounded_text(a:pattern, 1)
  if range isnot 0
    call s:select_outer(range[0], range[1])
    if s:is_running_operator
      let s:last_textobj_patterns = [a:pattern, a:pattern]
    endif
  endif
endfunction

function! surround#textobj_inline_i(pattern) abort
  let range = s:search_surrounded_text(a:pattern, 0)
  if range isnot 0
    call s:select_inner(range[0], range[1])
    if s:is_running_operator
      let s:last_textobj_patterns = [a:pattern, a:pattern]
    endif
  endif
endfunction

function! s:add_surround(start_delimiter, end_delimiter) abort
  let start_pos = getpos("'[")[1:]
  let end_pos = getpos("']")[1:]

  call s:create_undo_block()

  call cursor(end_pos)
  call s:put_text_at_cursor('p', a:end_delimiter)

  call cursor(start_pos)
  call s:put_text_at_cursor('P', a:start_delimiter)
endfunction

function! s:ask_operator_delimiters() abort
  if s:last_operator_delimiters is 0
    let char = nr2char(getchar())
    if has_key(g:surround_objects, char)
      let object = g:surround_objects[char]
      let s:last_operator_delimiters = s:surround_object_to_delimiters(object)
    else
      let s:last_operator_delimiters = -1
    endif
  endif
  return s:last_operator_delimiters
endfunction

function! s:change_surround(start_pattern, end_pattern, start_delimiter, end_delimiter) abort
  let start_head = getpos("'[")[1:]
  let end_tail = getpos("']")[1:]

  let end_head = s:search_backward(a:end_pattern, end_tail)
  if end_head is 0
    return
  endif

  call s:select_outer(end_head, end_tail)
  call s:put_text_at_cursor('p', a:end_delimiter)

  let start_tail = s:search_forward(a:start_pattern, start_head)
  if start_tail is 0
    return
  endif

  call s:select_outer(start_head, start_tail)
  call s:put_text_at_cursor('p', a:start_delimiter)
endfunction

function! s:create_undo_block() abort
  " Create a new undo block to keep the cursor position when undo.
  execute 'normal!' 'i ' . "\<Esc>" . '"_x'
endfunction

function! s:delete_surround(start_pattern, end_pattern) abort
  let start_pattern = a:start_pattern . '\m\s*'
  let end_pattern = '\s*' . a:end_pattern

  let start_head = getpos("'[")[1:]
  let end_tail = getpos("']")[1:]

  let end_head = s:search_backward(end_pattern, end_tail)
  if end_head is 0
    return
  endif

  call s:select_outer(end_head, end_tail)
  normal! "_d

  let start_tail = s:search_forward(start_pattern, start_head)
  if start_tail is 0
    return
  endif

  if start_tail[0] > end_head[0]
  \  || (start_tail[0] == end_head[0] && start_tail[1] >= end_head[1])
    " The head of tail position overlaps the tail of head position.
    call s:select_outer(start_head, end_head)
    execute 'normal!' "\<BS>"
  else
    call s:select_outer(start_head, start_tail)
  endif
  normal! "_d
endfunction

function! s:put_text_at_cursor(put_command, text) abort
  let reg_value = @"
  let reg_type = getregtype('"')
  try
    call setreg('"', a:text, 'v')
    execute 'normal!' ('""' . a:put_command)
  finally
    call setreg('"', reg_value, reg_type)
  endtry
endfunction

function! s:search_backward(pattern, initial_pos) abort
  let old_virtualedit = &l:virtualedit

  setlocal virtualedit=all

  try
    let pattern = a:pattern . '\%#'

    " Move the cursor one character to the right to match the pattern.
    call cursor(a:initial_pos[0], a:initial_pos[1] + 1, 1)

    let pos = searchpos(pattern, 'Wbc')
    if pos == [0, 0]
      return 0
    endif

    return pos
  finally
    let &l:virtualedit = old_virtualedit
  endtry

  return pos
endfunction

function! s:search_edges(pattern, flags, stopline) abort
  let head = searchpos(a:pattern, a:flags, a:stopline)
  if head == [0, 0]
    return 0
  endif

  let tail = searchpos('\%#' . a:pattern, 'Wcen')
  if tail == [0, 0]
    return 0
  endif

  return [head, tail]
endfunction

function! s:search_forward(pattern, initial_pos) abort
  let pattern = '\%#' . a:pattern

  call cursor(a:initial_pos)

  let pos = searchpos(pattern, 'Wce')
  if pos == [0, 0]
    return 0
  endif

  return pos
endfunction

function! s:search_surrounded_block(start_pattern, end_pattern, is_outer) abort
  let cursor = getpos('.')[1:]

  " BUGS: It dosen't work when the pattern contained newline characters.
  let end_edges = s:search_edges(a:end_pattern, 'Wbc', cursor[0])
  if end_edges is 0
    let in_end_delimiter = 0
  else
    if end_edges[0][1] <= cursor[1] && cursor[1] <= end_edges[1][1]
      let in_end_delimiter = 1
    else
      let in_end_delimiter = 0
      call cursor(cursor)
    endif
  endif

  if in_end_delimiter
    let [end_head, end_tail] = end_edges

    let start_head = searchpairpos(a:start_pattern, '', a:end_pattern, 'Wb')
    if start_head == [0, 0]
      call cursor(cursor)
      return 0
    endif

    if a:is_outer
      let start = start_head
      let end = end_tail
    else
      let start = searchpos('\%#' . a:start_pattern, 'Wecn')
      let end = end_head
    endif
  else
    let end_head = searchpairpos(a:start_pattern, '', a:end_pattern, 'W')
    if end_head == [0, 0]
      return 0
    endif

    let end = a:is_outer
    \       ? searchpos('\%#' . a:end_pattern, 'Wcen')
    \       : end_head

    let start_head = searchpairpos(a:start_pattern, '', a:end_pattern, 'Wb')
    if start_head == [0, 0]
      call cursor(cursor)
      return 0
    endif

    let start = a:is_outer
    \         ? start_head
    \         : searchpos('\%#' . a:start_pattern, 'Wecn')
  endif

  return [start, end]
endfunction

function! s:search_surrounded_text(pattern, is_outer) abort
  let cursor = getpos('.')[1:]

  " Move the cursor to the the first column of the current line.
  normal! 0

  let start_edges = s:search_edges(a:pattern, 'Wc', cursor[0])
  if start_edges is 0
    return 0
  endif

  let [start_head, start_tail] = start_edges
  let is_opened = 1

  while 1
    let end_edges = s:search_edges(a:pattern, 'W', cursor[0])
    if end_edges is 0
      call cursor(cursor)
      return 0
    endif

    let [end_head, end_tail] = end_edges

    if is_opened
      if start_head[1] <= cursor[1] && cursor[1] <= end_tail[1]
        break
      endif
    else
      if start_head[1] < cursor[1] && cursor[1] < end_tail[1]
        break
      endif
    endif

    let start_head = end_head
    let start_tail = end_tail
    let is_opened = !is_opened
  endwhile

  return a:is_outer ? [start_head, end_tail] : [start_tail, end_head]
endfunction

function! s:select_inner(start_pos, end_pos) abort
  call cursor(a:start_pos)
  normal! v o
  call cursor(a:end_pos)
  if &selection !=# 'exclusive'
    execute 'normal!' "\<BS>"
  endif
endfunction

function! s:select_outer(start_pos, end_pos) abort
  call cursor(a:start_pos)
  normal! v
  call cursor(a:end_pos)
  if &selection ==# 'exclusive'
    execute 'normal!' ' '
  endif
endfunction

function! s:setup_operator(operator_func) abort
  let &operatorfunc = a:operator_func
  let s:is_running_operator = 1
  let s:last_operator_delimiters = 0
  let s:last_textobj_patterns = 0
endfunction

function! s:surround_object_to_delimiters(object) abort
  if a:object.type ==# 'block'
    let delimiter = type(a:object.delimiter) == v:t_func
    \             ? a:object.delimiter()
    \             : a:object.delimiter
    return delimiter
  elseif a:object.type ==# 'inline'
    let delimiter = type(a:object.delimiter) == v:t_func
    \             ? a:object.delimiter()
    \             : a:object.delimiter
    return [delimiter, delimiter]
  else
    return ['', '']
  endif
endfunction
