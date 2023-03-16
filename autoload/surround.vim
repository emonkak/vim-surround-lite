let s:last_operator_pair = 0

let s:last_textobj_pair = 0

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
  let [start, end] = s:query_operator_pair()

  if a:motion_wiseness ==# 'line'
    let append_command = 'A'
    let insert_command = 'I'
  else
    let append_command = 'a'
    let insert_command = 'i'
  endif

  let start_pos = getpos("'[")[1:]
  let end_pos = getpos("']")[1:]

  call s:new_undo_block()

  call cursor(end_pos)
  execute 'normal!' append_command . end . "\<Esc>"

  call cursor(start_pos)
  execute 'normal!' insert_command . start . "\<Esc>"
endfunction

function! surround#operator_change(motion_wiseness) abort
  let [before_head, before_tail] = s:query_textobj_pair()
  let [after_head, after_tail] = s:query_operator_pair()

  let before_head_count = max([1, strchars(before_head)])
  let before_tail_count = max([1, strchars(before_tail)])

  let start_pos = getpos("'[")[1:]
  let end_pos = getpos("']")[1:]

  call s:new_undo_block()

  call cursor(end_pos)
  execute 'normal!' '"_c' . before_tail_count . 'l' . after_tail . "\<Esc>"

  call cursor(start_pos)
  execute 'normal!' '"_c' . before_head_count . 'l' . after_head . "\<Esc>"
endfunction

function! surround#operator_delete(motion_wiseness) abort
  let [start, end] = s:query_textobj_pair()

  let start_count = max([1, strchars(start)])
  let end_count = max([1, strchars(end)])

  let start_pos = getpos("'[")[1:]
  let end_pos = getpos("']")[1:]

  call s:new_undo_block()

  call cursor(end_pos)
  execute 'normal!' end_count . 'r vgel"_x'

  let cursor_pos = getpos('.')[1:]
  if start_pos[0] == cursor_pos[0] && start_pos[1] + start_count == cursor_pos[1]
    " The cursor position is the same as the start position.
    execute 'normal!' '"_d' . start_count . 'h'
  else
    call cursor(start_pos)
    execute 'normal!' . start_count . 'r `["_dw'
  endif
endfunction

function! surround#textobj_pair_a(start, end) abort
  let start_pattern = s:delimiter_pattern(a:start)
  let end_pattern = s:delimiter_pattern(a:end)
  let range = s:search_pair(start_pattern, end_pattern)
  if range isnot 0
    call s:select_outer(range[0], range[1])
  endif
  let s:last_textobj_pair = [a:start, a:end]
endfunction

function! surround#textobj_pair_i(start, end) abort
  let start_pattern = s:delimiter_pattern(a:start)
  let end_pattern = s:delimiter_pattern(a:end)
  let range = s:search_pair(start_pattern, end_pattern)
  if range isnot 0
    call s:select_inner(range[0], range[1])
  endif
  let s:last_textobj_pair = [a:start, a:end]
endfunction

function! surround#textobj_single_a(delimiter) abort
  let pattern = s:delimiter_pattern(a:delimiter)
  let range = s:search_delimiter(pattern)
  if range isnot 0
    call s:select_outer(range[0], range[1])
  endif
  let s:last_textobj_pair = [a:delimiter, a:delimiter]
endfunction

function! surround#textobj_single_i(delimiter) abort
  let pattern = s:delimiter_pattern(a:delimiter)
  let range = s:search_delimiter(pattern)
  if range isnot 0
    call s:select_inner(range[0], range[1])
  endif
  let s:last_textobj_pair = [a:delimiter, a:delimiter]
endfunction

function! surround#textobj_tag_a(tag_name) abort
  let start = '<' . a:tag_name . '>'
  let end = '</' . a:tag_name . '>'
  return surround#textobj_pair_a(start, end)
endfunction

function! surround#textobj_tag_i(tag_name) abort
  let start = '<' . a:tag_name . '>'
  let end = '</' . a:tag_name . '>'
  return surround#textobj_pair_i(start, end)
endfunction

function s:new_undo_block() abort
  " Create a new undo block to keep the cursor position when undo.
  execute 'normal!' 'i ' . "\<Esc>" . '"_x'
endfunction

function! s:delimiter_pattern(delimiter) abort
  if strchars(a:delimiter) > 1
    return '\V' . escape(a:delimiter, '\\')
  else
    return '\V\%(\[^\\]\\\)\@<!' . escape(a:delimiter, '\\')
  endif
endfunction

function! s:query_operator_pair() abort
  if s:last_operator_pair is 0
    let char = nr2char(getchar())
    if has_key(g:surround_objects, char)
      let object = g:surround_objects[char]
      let s:last_operator_pair = s:surround_object_to_pair(object)
    else
      let s:last_operator_pair = ['', '']
    endif
  endif
  return s:last_operator_pair
endfunction

function! s:query_textobj_pair() abort
  return s:last_textobj_pair is 0 ? ['', ''] : s:last_textobj_pair
endfunction

function! s:search_delimiter(pattern) abort
  let cursor = getpos('.')[1:]

  " Move the cursor to the the first character of the current line.
  call cursor(0, 1)

  try
    let current_pos = searchpos(a:pattern, 'Wc', cursor[0])
    if current_pos == [0, 0]
      return 0
    endif

    let in_quote = 1

    while 1
      let next_pos = searchpos(a:pattern, 'W', cursor[0])
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

function! s:search_pair(start_pattern, end_pattern) abort
  if search('\%#' . a:end_pattern, 'cn') > 0
    let start_flags = 'Wbn'
    let end_flags = 'Wcn'
  else
    let start_flags = 'Wbcn'
    let end_flags = 'Wn'
  endif

  let start_pos = searchpairpos(a:start_pattern, '', a:end_pattern, start_flags)
  if start_pos == [0, 0]
    return 0
  endif

  let end_pos = searchpairpos(a:start_pattern, '', a:end_pattern, end_flags)
  if end_pos == [0, 0]
    return 0
  endif

  return [start_pos, end_pos]
endfunction

function! s:select_inner(start_pos, end_pos) abort
  call cursor(a:start_pos)
  normal! vlo
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
    normal! l
  endif
endfunction

function! s:setup_operator(operator_func) abort
  let &operatorfunc = a:operator_func
  let s:last_operator_pair = 0
  let s:last_textobj_pair = 0
endfunction

function! s:surround_object_to_pair(object) abort
  let delimiter = type(a:object.delimiter) == v:t_func
  \             ? a:object.delimiter()
  \             : a:object.delimiter
  let delimiter_type = type(delimiter)
  if delimiter_type == v:t_string
    return [delimiter, delimiter]
  elseif delimiter_type == v:t_list
    return [delimiter[0], delimiter[1]]
  else
    return ['', '']
  endif
endfunction
