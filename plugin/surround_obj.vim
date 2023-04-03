if exists('g:loaded_surround_obj')
  finish
endif

function! s:define_block_text_object(key, start_pattern, end_pattern, kind) abort
  let lhs = printf('<Plug>(surround-obj-%s:%s)',
  \                a:kind,
  \                escape(a:key, '|'))
  let rhs = printf(':<C-u>call surround_obj#textobj_block_%s(%s, %s)<CR>',
  \                a:kind,
  \                escape(string(a:start_pattern), '|'),
  \                escape(string(a:end_pattern), '|'))
  execute 'vnoremap <silent>' lhs rhs
  execute 'onoremap <silent>' lhs rhs
  return lhs
endfunction

function! s:define_inline_text_object(key, pattern, kind) abort
  let lhs = printf('<Plug>(surround-obj-%s:%s)',
  \                a:kind,
  \                escape(a:key, '|'))
  let rhs = printf(':<C-u>call surround_obj#textobj_inline_%s(%s)<CR>',
  \                a:kind,
  \                escape(string(a:pattern), '|'))
  execute 'vnoremap <silent>' lhs rhs
  execute 'onoremap <silent>' lhs rhs
  return lhs
endfunction

function! s:define_operator(lhs, operator_func) abort
  execute 'nnoremap' '<expr>' a:lhs
  \       'surround_obj#setup_operator_n(' . string(a:operator_func) . ')'
  execute 'vnoremap' '<expr>' a:lhs
  \       'surround_obj#setup_operator_v(' . string(a:operator_func) . ')'
  execute 'onoremap' a:lhs 'g@'
endfunction

function! s:load_object(key, object, objects) abort
  if a:object.type ==# 'block'
    if !has_key(a:object, 'pattern')
      return
    endif
    let textobj_i = s:define_block_text_object(a:key,
    \                                          a:object.pattern[0],
    \                                          a:object.pattern[1],
    \                                          'i')
    let textobj_a = s:define_block_text_object(a:key,
    \                                          a:object.pattern[0],
    \                                          a:object.pattern[1],
    \                                          'a')
  elseif a:object.type ==# 'inline'
    if !has_key(a:object, 'pattern')
      return
    endif
    let textobj_i = s:define_inline_text_object(a:key, a:object.pattern, 'i')
    let textobj_a = s:define_inline_text_object(a:key, a:object.pattern, 'a')
  elseif a:object.type ==# 'alias'
    call s:load_object(a:key, a:objects[a:object.key], a:objects)
    return
  elseif a:object.type ==# 'nop'
    return
  else
    throw printf('Unexpected type "%s". Allowed values are "block", "inline" or "nop".',
    \            a:object.type)
  endif

  let key_notation = get(s:KEY_NOTATIONS, a:key, a:key)

  execute 'nmap <silent>'
  \       ('<Plug>(surround-obj-change)' . key_notation)
  \       ('<SID>(operator-change)' . textobj_a)
  execute 'nmap <silent>'
  \       ('<Plug>(surround-obj-delete)' . key_notation)
  \       ('<SID>(operator-delete)' . textobj_a)
endfunction

function! s:make_alias_object(key) abort
  return {
  \   'type': 'alias',
  \   'key': a:key,
  \ }
endfunction

function! s:make_block_object(start, end) abort
  return {
  \   'type': 'block',
  \   'delimiter': [a:start, a:end],
  \   'pattern': [s:make_pattern(a:start), s:make_pattern(a:end)],
  \ }
endfunction

function! s:make_inline_object(edge) abort
  return {
  \   'type': 'inline',
  \   'delimiter': a:edge,
  \   'pattern': s:make_pattern(a:edge),
  \ }
endfunction

function! s:make_pattern(delimiter) abort
  let prefix = '\V\%(\[^\\]\\\)\@<!'
  if a:delimiter[0] == ' '
    return prefix . '\s\*' . escape(a:delimiter[1:], '\')
  elseif a:delimiter[-1:] == ' '
    return prefix . escape(a:delimiter[:-2], '\') . '\s\*'
  else
    return prefix . escape(a:delimiter, '\')
  endif
endfunction

function! s:reload_objects() abort
  let objects = {}

  if exists('g:surround_obj_custom_objects')
    call extend(objects, g:surround_obj_custom_objects)
  endif

  if !get(g:, 'surround_obj_no_builtin_objects', 0)
    call extend(objects, s:BUILTIN_OBJECTS, 'keep')
  endif

  for [key, object] in items(objects)
    call s:load_object(key, object, objects)
  endfor

  let g:surround_obj_loaded_objects = objects
endfunction

let s:BUILTIN_OBJECTS = {
\   '!': s:make_inline_object('!'),
\   '"': s:make_inline_object('"'),
\   '#': s:make_inline_object('#'),
\   '$': s:make_inline_object('$'),
\   '%': s:make_inline_object('%'),
\   '&': s:make_inline_object('&'),
\   "'": s:make_inline_object("'"),
\   '(': s:make_block_object('(', ')'),
\   ')': s:make_block_object('( ', ' )'),
\   '*': s:make_inline_object('*'),
\   '+': s:make_inline_object('+'),
\   ',': s:make_inline_object(','),
\   '-': s:make_inline_object('-'),
\   '.': s:make_inline_object('.'),
\   '/': s:make_inline_object('/'),
\   ':': s:make_inline_object(':'),
\   ';': s:make_inline_object(';'),
\   '<': s:make_block_object('<', '>'),
\   '=': s:make_inline_object('='),
\   '>': s:make_block_object('< ', ' >'),
\   '?': s:make_inline_object('?'),
\   '@': s:make_inline_object('@'),
\   'B': s:make_alias_object('{'),
\   '[': s:make_block_object('[', ']'),
\   '\': s:make_inline_object('\'),
\   ']': s:make_block_object('[ ', ' ]'),
\   '^': s:make_inline_object('^'),
\   '_': s:make_inline_object('_'),
\   '`': s:make_inline_object('`'),
\   'a': s:make_alias_object('<'),
\   'b': s:make_alias_object('('),
\   'r': s:make_alias_object('['),
\   't': {
\     'type': 'block',
\     'delimiter': function('surround_obj#ask_tag_name'),
\     'pattern': ['<\%(\a[^>]*\)\?>', '</[^>]*>'],
\   },
\   '{': s:make_block_object('{', '}'),
\   '|': s:make_inline_object('|'),
\   '}': s:make_block_object('{ ', ' }'),
\   '~': s:make_inline_object('~'),
\ }

let s:KEY_NOTATIONS = {
\   '|': '<Bar>',
\   '\': '<Bslash>',
\   '<': '<Lt>',
\   ' ': '<Space>',
\ }

let g:surround_obj_loaded_objects = {}

call s:define_operator('<SID>(operator-add)',
\                      'surround_obj#operator_add')
call s:define_operator('<SID>(operator-change)',
\                      'surround_obj#operator_change')
call s:define_operator('<SID>(operator-delete)',
\                      'surround_obj#operator_delete')

map <silent> <Plug>(surround-obj-add)  <SID>(operator-add)
map <Plug>(surround-obj-change)  <Nop>
map <Plug>(surround-obj-remove)  <Nop>

call s:reload_objects()

let g:loaded_surround_obj = 1
