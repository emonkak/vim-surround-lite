let s:is_pending_operator = 0

let s:last_delimiters = 0

let s:last_patterns = 0

let s:count = 1

function! surround_obj#ask_function_name() abort
  return [input('Function Name: ') . '(', ')']
endfunction

function! surround_obj#ask_tag_name() abort
  let tag_name = input('Tag Name: ')
  let start_delimiter = '<' . tag_name . '>'
  let end_delimiter = '</' . tag_name . '>'
  return [start_delimiter, end_delimiter]
endfunction

function! surround_obj#count() abort
  return s:count
endfunction

function! surround_obj#operator_add(motion_wiseness) abort
  let delimiters = s:ask_delimiters()
  if type(delimiters) == v:t_list
    let [start_delimiter, end_delimiter] = delimiters
    let l:count = v:count > 0 ? v:count : s:count
    call s:add_surround(start_delimiter, end_delimiter, l:count)
  endif
  let s:is_pending_operator = 0
endfunction

function! surround_obj#operator_change(motion_wiseness) abort
  if s:last_patterns isnot 0
    let delimiters = s:ask_delimiters()
    if type(delimiters) == v:t_list
      let [start_pattern, end_pattern] = s:last_patterns
      let [start_delimiter, end_delimiter] = delimiters
      call s:change_surround(
      \   start_pattern,
      \   end_pattern,
      \   start_delimiter,
      \   end_delimiter
      \ )
    endif
  endif
  let s:is_pending_operator = 0
endfunction

function! surround_obj#operator_delete(motion_wiseness) abort
  if s:last_patterns isnot 0
    let [start_pattern, end_pattern] = s:last_patterns
    call s:delete_surround(start_pattern, end_pattern)
  endif
  let s:is_pending_operator = 0
endfunction

function! surround_obj#setup_operator(operator_func) abort
  let &operatorfunc = a:operator_func
  let s:is_pending_operator = 1
  let s:last_delimiters = 0
  let s:last_patterns = 0
  let s:count = v:count1
endfunction

function! surround_obj#textobj_block_a(start_pattern, end_pattern) abort
  let quad_positions = s:search_block(a:start_pattern, a:end_pattern, v:count1)
  if quad_positions isnot 0
    let [start_head, start_tail, end_head, end_tail] = quad_positions
    call s:select_outer_inclusive(start_head, end_tail)
    if s:is_pending_operator
      let s:last_patterns = [a:start_pattern, a:end_pattern]
    endif
  endif
endfunction

function! surround_obj#textobj_block_i(start_pattern, end_pattern) abort
  let quad_positions = s:search_block(a:start_pattern, a:end_pattern, v:count1)
  if quad_positions isnot 0
    let [start_head, start_tail, end_head, end_tail] = quad_positions
    call s:select_inner(start_tail, end_head)
    if s:is_pending_operator
      let s:last_patterns = [a:start_pattern, a:end_pattern]
    endif
  endif
endfunction

function! surround_obj#textobj_inline_a(pattern) abort
  let quad_positions = s:search_inline(a:pattern, v:count1)
  if quad_positions isnot 0
    let [start_head, start_tail, end_head, end_tail] = quad_positions
    call s:select_outer_inclusive(start_head, end_tail)
    if s:is_pending_operator
      let s:last_patterns = [a:pattern, a:pattern]
    endif
  endif
endfunction

function! surround_obj#textobj_inline_i(pattern) abort
  let quad_positions = s:search_inline(a:pattern, v:count1)
  if quad_positions isnot 0
    let [start_head, start_tail, end_head, end_tail] = quad_positions
    call s:select_inner(start_tail, end_head)
    if s:is_pending_operator
      let s:last_patterns = [a:pattern, a:pattern]
    endif
  endif
endfunction

function! s:add_surround(start_delimiter, end_delimiter, count) abort
  let start_pos = getpos("'[")[1:]
  let end_pos = getpos("']")[1:]

  call s:create_undo_block()

  call cursor(end_pos)
  call s:put_text('p', a:end_delimiter, a:count)

  call cursor(start_pos)
  call s:put_text('P', a:start_delimiter, a:count)
endfunction

function! s:ask_delimiters() abort
  if s:last_delimiters is 0
    let key = nr2char(getchar())
    let object = s:find_object(key)
    if object isnot 0
      let s:last_delimiters = s:eval_delimiters(key, object)
    else
      let s:last_delimiters = -1
    endif
  endif
  return s:last_delimiters
endfunction

function! s:change_surround(start_pattern, end_pattern, start_delimiter, end_delimiter) abort
  let start_head = getpos("'[")[1:]
  let end_tail = getpos("']")[1:]

  let inner_edge = s:search_inner_edge(
  \   a:start_pattern,
  \   a:end_pattern,
  \   start_head,
  \   end_tail
  \ )
  if inner_edge is 0
    return
  endif

  let [start_tail, end_head] = inner_edge

  call s:select_outer_inclusive(end_head, end_tail)

  call s:put_text('p', a:end_delimiter, '')

  if s:position_lt(start_tail, end_head)
    call s:select_outer_inclusive(start_head, start_tail)
  else
    " The start of the tail position overlaps the end of the head position.
    call s:select_outer_exclusive(start_head, end_head)
  endif

  call s:put_text('p', a:start_delimiter, '')
endfunction

function! s:create_undo_block() abort
  " Create a new undo block to keep the cursor position when undo.
  execute 'normal!' 'i ' . "\<Esc>" . '"_x'
endfunction

function! s:delete_surround(start_pattern, end_pattern) abort
  let start_head = getpos("'[")[1:]
  let end_tail = getpos("']")[1:]

  let inner_edge = s:search_inner_edge(
  \   a:start_pattern,
  \   a:end_pattern,
  \   start_head,
  \   end_tail
  \ )
  if inner_edge is 0
    return
  endif

  let [start_tail, end_head] = inner_edge

  call s:select_outer_inclusive(end_head, end_tail)

  normal! "_d

  if s:position_lt(start_tail, end_head)
    call s:select_outer_inclusive(start_head, start_tail)
  else
    " The start of the tail position overlaps the end of the head position.
    call s:select_outer_exclusive(start_head, end_head)
  endif

  normal! "_d
endfunction

function! s:eval_delimiters(key, object) abort
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
  elseif a:object.type ==# 'transition'
    let key = a:key . nr2char(getchar())
    let object = s:find_object(key)
    if object isnot 0
      return s:eval_delimiters(key, object)
    else
      return -1
    endif
  else
    return -1
  endif
endfunction

function! s:find_object(key) abort
  return exists('g:surround_obj#loaded_objects')
  \  ? get(g:surround_obj#loaded_objects, a:key, 0)
  \  : 0
endfunction

function! s:position_le(pos1, pos2) abort
  return ((a:pos1[0] < a:pos2[0])
  \       || (a:pos1[0] == a:pos2[0] && a:pos1[1] <= a:pos2[1]))
endfunction

function! s:position_lt(pos1, pos2) abort
  return ((a:pos1[0] < a:pos2[0])
  \       || (a:pos1[0] == a:pos2[0] && a:pos1[1] < a:pos2[1]))
endfunction

function! s:put_text(command, text, count) abort
  let reg_value = @"
  let reg_type = getregtype('"')
  try
    call setreg('"', a:text, 'v')
    execute 'normal!' (a:count . '""' . a:command)
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

function! s:search_block(start_pattern, end_pattern, count) abort
  let cursor = getcurpos()[1:]

  try
    let end_edges = s:search_block_edges(
    \   a:end_pattern,
    \   a:start_pattern,
    \   'Wcep',
    \   cursor,
    \   a:count
    \ )
    if end_edges is 0
      return 0
    endif

    call cursor(cursor)

    let start_edges = s:search_block_edges(
    \   a:start_pattern,
    \   a:end_pattern,
    \   'Wbcp',
    \   cursor,
    \   a:count
    \ )
    if start_edges is 0
      return 0
    endif

    return [start_edges[0], start_edges[1], end_edges[0], end_edges[1]]
  finally
    call cursor(cursor)
  endtry
endfunction

function! s:search_block_edges(pattern1, pattern2, flags, cursor, count) abort
  let pattern = '\(' . a:pattern1 . '\m\)\|' . a:pattern2
  let has_end_flag = stridx(a:flags, 'e') >= 0

  let remains = a:count
  let flags = a:flags
  let flags_without_c = substitute(flags, 'c', '', 'g')

  while remains > 0
    let [lnum, col, group] = searchpos(pattern, flags)
    if group == 0  " No match
      return 0
    endif
    if group == 2  " When matching to pattern1
      let remains -= 1
    else  " When matching to pattern2
      if has_end_flag
        let head_pos = searchpos(a:pattern2, 'Wbcn')
        let tail_pos = [lnum, col]
      else
        let head_pos = [lnum, col]
        let tail_pos = searchpos(a:pattern2, 'Wcen')
      endif
      if !s:range_contains_inclusive(head_pos, tail_pos, a:cursor)
        let remains += 1
      endif
    endif
    let flags = flags_without_c
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

function! s:search_inline(pattern, count) abort
  let cursor = getcurpos()[1:]

  " Prerequisite: The cursor must be in the first column.
  normal! 0

  try
    let start_edges = s:search_inline_edges(a:pattern, 'Wc', cursor[0])
    if start_edges is 0
      return 0
    endif

    let remains = a:count
    let inclusive = 1

    while remains > 0
      let end_edges = s:search_inline_edges(a:pattern, 'W', cursor[0])
      if end_edges is 0
        return 0
      endif

      if inclusive
      \  ? s:range_contains_inclusive(start_edges[0], end_edges[1], cursor)
      \  : s:range_contains_exclusive(start_edges[0], end_edges[1], cursor)
        let remains -= 1
      else
        let start_edges = end_edges
        let inclusive = !inclusive
      endif
    endwhile

    return [start_edges[0], start_edges[1], end_edges[0], end_edges[1]]
  finally
    call cursor(cursor)
  endtry
endfunction

function! s:search_inline_edges(pattern, flags, stopline) abort
  let head = searchpos(a:pattern, a:flags, a:stopline)
  if head == [0, 0]
    return 0
  endif

  let tail = searchpos('\%#' . a:pattern, 'Wce', a:stopline)
  if tail == [0, 0]
    return 0
  endif

  return [head, tail]
endfunction

function! s:search_inner_edge(start_pattern, end_pattern, start_head, end_tail) abort
  call cursor(a:end_tail)

  let end_head = searchpos(a:end_pattern, 'Wbcn')
  if end_head is 0
  \  || !s:range_contains_inclusive(a:start_head, a:end_tail, end_head)
    return
  endif

  call cursor(a:start_head)

  let start_tail = searchpos(a:start_pattern, 'Wecn')
  if start_tail is 0
  \  || !s:range_contains_inclusive(a:start_head, a:end_tail, start_tail)
    return
  endif

  return [start_tail, end_head]
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
