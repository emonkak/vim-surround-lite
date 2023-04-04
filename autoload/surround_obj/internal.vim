let s:is_running_operator = 0

let s:last_operator_delimiters = 0

let s:last_operator_patterns = 0

function! surround_obj#internal#operator_add(motion_wiseness) abort
  let delimiters = s:ask_delimiters()
  if type(delimiters) == v:t_list
    let [start_delimiter, end_delimiter] = delimiters
    call s:add_surround(start_delimiter, end_delimiter)
  endif
  let s:is_running_operator = 0
endfunction

function! surround_obj#internal#operator_change(motion_wiseness) abort
  if s:last_operator_patterns isnot 0
    let delimiters = s:ask_delimiters()
    if type(delimiters) == v:t_list
      let [start_pattern, end_pattern] = s:last_operator_patterns
      let [start_delimiter, end_delimiter] = delimiters
      call s:change_surround(start_pattern,
      \                      end_pattern,
      \                      start_delimiter,
      \                      end_delimiter)
    endif
  endif
  let s:is_running_operator = 0
endfunction

function! surround_obj#internal#operator_delete(motion_wiseness) abort
  if s:last_operator_patterns isnot 0
    let [start_pattern, end_pattern] = s:last_operator_patterns
    call s:delete_surround(start_pattern, end_pattern)
  endif
  let s:is_running_operator = 0
endfunction

function! surround_obj#internal#setup_operator(operator_func) abort
  let &operatorfunc = a:operator_func
  let s:is_running_operator = 1
  let s:last_operator_delimiters = 0
  let s:last_operator_patterns = 0
  return 'g@'
endfunction

function! surround_obj#internal#textobj_block_a(start_pattern, end_pattern) abort
  let quad_positions = s:search_block(a:start_pattern, a:end_pattern)
  if quad_positions isnot 0
    let [start_head, start_tail, end_head, end_tail] = quad_positions
    call s:select_outer_inclusive(start_head, end_tail)
    if s:is_running_operator
      let s:last_operator_patterns = [a:start_pattern, a:end_pattern]
    endif
  endif
endfunction

function! surround_obj#internal#textobj_block_i(start_pattern, end_pattern) abort
  let quad_positions = s:search_block(a:start_pattern, a:end_pattern)
  if quad_positions isnot 0
    let [start_head, start_tail, end_head, end_tail] = quad_positions
    call s:select_inner(start_tail, end_head)
    if s:is_running_operator
      let s:last_operator_patterns = [a:start_pattern, a:end_pattern]
    endif
  endif
endfunction

function! surround_obj#internal#textobj_inline_a(pattern) abort
  let quad_positions = s:search_inline(a:pattern)
  if quad_positions isnot 0
    let [start_head, start_tail, end_head, end_tail] = quad_positions
    call s:select_outer_inclusive(start_head, end_tail)
    if s:is_running_operator
      let s:last_operator_patterns = [a:pattern, a:pattern]
    endif
  endif
endfunction

function! surround_obj#internal#textobj_inline_i(pattern) abort
  let quad_positions = s:search_inline(a:pattern)
  if quad_positions isnot 0
    let [start_head, start_tail, end_head, end_tail] = quad_positions
    call s:select_inner(start_tail, end_head)
    if s:is_running_operator
      let s:last_operator_patterns = [a:pattern, a:pattern]
    endif
  endif
endfunction

function! s:add_surround(start_delimiter, end_delimiter) abort
  let start_pos = getpos("'[")[1:]
  let end_pos = getpos("']")[1:]

  call s:create_undo_block()

  call cursor(end_pos)
  call s:put_text('p', a:end_delimiter)

  call cursor(start_pos)
  call s:put_text('P', a:start_delimiter)
endfunction

function! s:ask_delimiters() abort
  if s:last_operator_delimiters is 0
    let char = nr2char(getchar())
    let object = g:surround_obj#_find_object(char)
    if object isnot 0
      let s:last_operator_delimiters = s:get_delimiters(object)
    else
      let s:last_operator_delimiters = -1
    endif
  endif
  return s:last_operator_delimiters
endfunction

function! s:change_surround(start_pattern, end_pattern, start_delimiter, end_delimiter) abort
  let start_head = getpos("'[")[1:]
  let end_tail = getpos("']")[1:]

  call cursor(end_tail)

  let end_head = searchpos(a:end_pattern, 'Wbcn')
  if end_head is 0
    return
  endif

  call s:select_outer_inclusive(end_head, end_tail)

  call s:put_text('p', a:end_delimiter)

  call cursor(start_head)

  let start_tail = searchpos(a:start_pattern, 'Wecn')
  if start_tail is 0
    return
  endif

  call s:select_outer_inclusive(start_head, start_tail)

  call s:put_text('p', a:start_delimiter)
endfunction

function! s:create_undo_block() abort
  " Create a new undo block to keep the cursor position when undo.
  execute 'normal!' 'i ' . "\<Esc>" . '"_x'
endfunction

function! s:delete_surround(start_pattern, end_pattern) abort
  let start_head = getpos("'[")[1:]
  let end_tail = getpos("']")[1:]

  call cursor(end_tail)

  let end_head = searchpos(a:end_pattern, 'Wbcn')
  if end_head is 0
    return
  endif

  call s:select_outer_inclusive(end_head, end_tail)

  normal! "_d

  call cursor(start_head)

  let start_tail = searchpos(a:start_pattern, 'Wcen')
  if start_tail is 0
    return
  endif

  if start_tail[0] > end_head[0]
  \  || (start_tail[0] == end_head[0] && start_tail[1] >= end_head[1])
    " The head of the tail position overlaps the tail of the head position.
    call s:select_outer_exclusive(start_head, end_head)
  else
    call s:select_outer_inclusive(start_head, start_tail)
  endif

  normal! "_d
endfunction

function! s:get_delimiters(object) abort
  if a:object.type ==# 'block'
    let delimiters = type(a:object.delimiter) == v:t_func
    \              ? a:object.delimiter()
    \              : a:object.delimiter
    return delimiters
  elseif a:object.type ==# 'inline'
    let delimiter = type(a:object.delimiter) == v:t_func
    \             ? a:object.delimiter()
    \             : a:object.delimiter
    return [delimiter, delimiter]
  else
    return ['', '']
  endif
endfunction

function! s:position_le(pos1, pos2)
  return ((a:pos1[0] < a:pos2[0])
  \       || (a:pos1[0] == a:pos2[0] && a:pos1[1] <= a:pos2[1]))
endfunction

function! s:position_lt(pos1, pos2)
  return ((a:pos1[0] < a:pos2[0])
  \       || (a:pos1[0] == a:pos2[0] && a:pos1[1] < a:pos2[1]))
endfunction

function! s:put_text(command, text) abort
  let reg_value = @"
  let reg_type = getregtype('"')
  try
    call setreg('"', a:text, 'v')
    execute 'normal!' ('""' . a:command)
  finally
    call setreg('"', reg_value, reg_type)
  endtry
endfunction

function! s:range_contains_exclusive(start_pos, end_pos, target_pos) abort
  return s:position_lt(a:start_pos, a:target_pos)
  \      && s:position_lt(a:target_pos, a:end_pos)
endfunction

function! s:range_contains_inclusive(start_pos, end_pos, target_pos) abort
  return s:position_le(a:start_pos, a:target_pos)
  \      && s:position_le(a:target_pos, a:end_pos)
endfunction

function! s:search_block(start_pattern, end_pattern) abort
  let cursor = getpos('.')[1:]

  let end_edges = s:search_block_edges(a:end_pattern, a:start_pattern, 'Wcep', cursor)
  if end_edges is 0
    call cursor(cursor)
    return 0
  endif

  call cursor(cursor)

  let start_edges = s:search_block_edges(a:start_pattern, a:end_pattern, 'Wbcp', cursor)
  if start_edges is 0
    call cursor(cursor)
    return 0
  endif

  return [start_edges[0], start_edges[1], end_edges[0], end_edges[1]]
endfunction

function! s:search_block_edges(pattern1, pattern2, flags, cursor) abort
  let pattern = '\(' . a:pattern1 . '\m\)\|' . a:pattern2
  let has_end_flag = a:flags =~# 'e'

  let nest_depth = 0
  let first_iteration = 1
  let flags = a:flags

  while 1
    let [lnum, col, matching_group] = searchpos(pattern, flags)
    if matching_group == 0
      return 0
    endif
    if matching_group == 2  " matched to the first pattern.
      if nest_depth == 0
        break
      endif
      let nest_depth -= 1
    else
      if has_end_flag
        let head_pos = searchpos(a:pattern2, 'Wbcn')
        let tail_pos = [lnum, col]
      else
        let head_pos = [lnum, col]
        let tail_pos = searchpos(a:pattern2, 'Wcen')
      endif
      if !s:range_contains_inclusive(head_pos, tail_pos, a:cursor)
        let nest_depth += 1
      endif
    endif
    if first_iteration
      let first_iteration = 0
      let flags = substitute(flags, 'c', '', 'g')
    endif
  endwhile

  if has_end_flag
    let head_pos = searchpos(a:pattern1, 'Wbcn')
    let tail_pos = [lnum, col]
  else
    let head_pos = [lnum, col]
    let tail_pos = searchpos(a:pattern1, 'Wcen')
  endif

  return [head_pos, tail_pos]
endfunction

function! s:search_inline(pattern) abort
  let cursor = getpos('.')[1:]

  " Move the cursor to the the first column of the current line.
  normal! 0

  let start_edges = s:search_inline_edges(a:pattern, 'Wc', cursor[0])
  if start_edges is 0
    call cursor(cursor)
    return 0
  endif

  let [start_head, start_tail] = start_edges
  let is_inclusive = 1

  while 1
    let end_edges = s:search_inline_edges(a:pattern, 'W', cursor[0])
    if end_edges is 0
      call cursor(cursor)
      return 0
    endif

    let [end_head, end_tail] = end_edges

    if (is_inclusive
    \   && s:range_contains_inclusive(start_head, end_tail, cursor))
    \  || (!is_inclusive
    \      && s:range_contains_exclusive(start_head, end_tail, cursor))
      return [start_head, start_tail, end_head, end_tail]
    endif

    let start_head = end_head
    let start_tail = end_tail
    let is_inclusive = !is_inclusive
  endwhile
endfunction

function! s:search_inline_edges(pattern, flags, stopline) abort
  let head = searchpos(a:pattern, a:flags, a:stopline)
  if head == [0, 0]
    return 0
  endif

  let tail = searchpos('\%#' . a:pattern, 'Wce')
  if tail == [0, 0]
    return 0
  endif

  return [head, tail]
endfunction

function! s:select_inner(start_pos, end_pos) abort
  call cursor(a:start_pos)
  normal! v o
  call cursor(a:end_pos)
  if &selection !=# 'exclusive'
    execute 'normal!' "\<BS>"
  endif
endfunction

function! s:select_outer_exclusive(start_pos, end_pos) abort
  call cursor(a:start_pos)
  normal! v
  call cursor(a:end_pos)
  if &selection !=# 'exclusive'
    execute 'normal!' "\<BS>"
  endif
endfunction

function! s:select_outer_inclusive(start_pos, end_pos) abort
  call cursor(a:start_pos)
  normal! v
  call cursor(a:end_pos)
  if &selection !=# 'inclusive'
    execute 'normal!' '1 '
  endif
endfunction
