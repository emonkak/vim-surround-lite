let s:loaded_objects = {}

function! surround_obj#define_built_in_objects(...) abort
  let INLINE_OBJECTS = [
  \   '!',
  \   '"',
  \   '#',
  \   '$',
  \   '%',
  \   '&',
  \   "'",
  \   '*',
  \   '+',
  \   ',',
  \   '-',
  \   '.',
  \   '/',
  \   ':',
  \   ';',
  \   '=',
  \   '?',
  \   '@',
  \   '\',
  \   '^',
  \   '_',
  \   '`',
  \   '|',
  \   '~',
  \ ]

  let BLOCK_OBJECTS = [
  \   ['(', '(', ')'],
  \   [')', '( ', ' )'],
  \   ['<', '<', '>'],
  \   ['>', '< ', ' >'],
  \   ['[', '[', ']'],
  \   [']', '[ ', ' ]'],
  \   ['{', '{', '}'],
  \   ['}', '{ ', ' }'],
  \   ['B', '{', '}'],
  \   ['b', '(', ')'],
  \ ]

  let ALIAS_OBJECTS = [
  \   ['B', '{'],
  \   ['b', '('],
  \ ]

  let allow_list = get(a:000, 0)

  for key in INLINE_OBJECTS
    if allow_list is 0 || index(allow_list, key) >= 0
      call surround_obj#define_object(key, {
      \   'type': 'inline',
      \   'delimiter': key,
      \   'pattern': s:make_pattern(key),
      \ })
    endif
  endfor

  for [key, start_delimiter, end_delimiter] in BLOCK_OBJECTS
    if allow_list is 0 || index(allow_list, key) >= 0
      call surround_obj#define_object(key, {
      \   'type': 'block',
      \   'delimiter': [start_delimiter, end_delimiter],
      \   'pattern': [
      \     s:make_pattern(start_delimiter),
      \     s:make_pattern(end_delimiter)
      \   ],
      \ })
    endif
  endfor

  for [key, alias] in ALIAS_OBJECTS
    if allow_list is 0 || index(allow_list, key) >= 0
      call surround_obj#define_object(key, {
      \   'type': 'alias',
      \   'key': alias,
      \ })
    endif
  endfor

  if allow_list is 0 || index(allow_list, 'f') >= 0
    call surround_obj#define_object('f', {
    \   'type': 'block',
    \   'delimiter': function('s:ask_function_name'),
    \   'pattern': ['\h\w*\s*(', ')'],
    \ })
  endif

  if allow_list is 0 || index(allow_list, 't') >= 0
    call surround_obj#define_object('t', {
    \   'type': 'block',
    \   'delimiter': function('s:ask_tag_name'),
    \   'pattern': ['<\%(\a[^>]*\)\?>', '</[^>]*>'],
    \ })
  endif
endfunction

function! surround_obj#define_local_object(key, object) abort
  if !exists('b:surround_obj_loaded_objects')
    let b:surround_obj_loaded_objects = {}
  endif

  let transition_keys = split(a:key, '.\zs')[:-2]

  for i in range(len(transition_keys))
    let key = join(transition_keys[:i])
    let b:surround_obj_loaded_objects[key] = {
    \   'type': 'transition',
    \ }
  endfor

  call s:define_object_mappings(a:key, a:object, '<buffer>')

  let b:surround_obj_loaded_objects[a:key] = a:object
endfunction

function! surround_obj#define_object(key, object) abort
  let transition_keys = split(a:key, '.\zs')[:-2]

  for i in range(len(transition_keys))
    let key = join(transition_keys[:i])
    let s:loaded_objects[key] = {
    \   'type': 'transition',
    \ }
  endfor

  call s:define_object_mappings(a:key, a:object, '')

  let s:loaded_objects[a:key] = a:object
endfunction

function! surround_obj#_find_object(key) abort
  let key = a:key
  let found_object = 0
  while 1
    if exists('b:surround_obj_loaded_objects')
    \  && has_key(b:surround_obj_loaded_objects, key)
      let found_object = b:surround_obj_loaded_objects[key]
    elseif has_key(s:loaded_objects, key)
      let found_object = s:loaded_objects[key]
    else
      break
    endif
    if found_object.type ==# 'alias'
      let key = found_object.key
    else
      break
    endif
  endwhile
  return found_object
endfunction

function! s:ask_function_name() abort
  return [input('Function Name: ') . '(', ')']
endfunction

function! s:ask_tag_name() abort
  let tag_name = input('Tag Name: ')
  let start_delimiter = '<' . tag_name . '>'
  let end_delimiter = '</' . tag_name . '>'
  return [start_delimiter, end_delimiter]
endfunction

function! s:define_object_mappings(key, object, map_options) abort
  if a:object.type ==# 'block'
    if has_key(a:object, 'pattern')
      let textobj_i = s:define_textobj_block('i',
      \                                      a:key,
      \                                      a:object.pattern[0],
      \                                      a:object.pattern[1],
      \                                      a:map_options)
      let textobj_a = s:define_textobj_block('a',
      \                                      a:key,
      \                                      a:object.pattern[0],
      \                                      a:object.pattern[1],
      \                                      a:map_options)
      call s:map_operator_key_sequences(a:key, textobj_a, a:map_options)
    endif
  elseif a:object.type ==# 'inline'
    if has_key(a:object, 'pattern')
      let textobj_i = s:define_textobj_inline('i',
      \                                       a:key,
      \                                       a:object.pattern,
      \                                       a:map_options)
      let textobj_a = s:define_textobj_inline('a',
      \                                       a:key,
      \                                       a:object.pattern,
      \                                       a:map_options)
      call s:map_operator_key_sequences(a:key, textobj_a, a:map_options)
    endif
  elseif a:object.type ==# 'alias'
    let textobj_i = s:define_textobj_alias('i',
    \                                      a:key,
    \                                      a:object.key,
    \                                      a:map_options)
    let textobj_a = s:define_textobj_alias('a',
    \                                      a:key,
    \                                      a:object.key,
    \                                      a:map_options)
    call s:map_operator_key_sequences(a:key, textobj_a, a:map_options)
  else
    throw printf('Unexpected type "%s". Allowed values are "alias", "block" or "inline".',
    \            a:object.type)
  endif
endfunction

function! s:define_textobj_alias(kind, key, alias, map_options) abort
  let lhs = printf('<Plug>(surround-obj-%s:%s)',
  \                a:kind,
  \                escape(a:key, '|'))
  let rhs = printf('<Plug>(surround-obj-%s:%s)',
  \                a:kind,
  \                escape(a:alias, '|'))
  execute 'vmap' a:map_options lhs rhs
  execute 'omap' a:map_options lhs rhs
  return lhs
endfunction

function! s:define_textobj_block(kind, key, start_pattern, end_pattern, map_options) abort
  let lhs = printf('<Plug>(surround-obj-%s:%s)',
  \                a:kind,
  \                escape(a:key, '|'))
  let rhs = printf(':<C-u>call surround_obj#core#textobj_block_%s(%s, %s)<CR>',
  \                a:kind,
  \                escape(string(a:start_pattern), '|'),
  \                escape(string(a:end_pattern), '|'))
  execute 'vnoremap <silent>' a:map_options lhs rhs
  execute 'onoremap <silent>' a:map_options lhs rhs
  return lhs
endfunction

function! s:define_textobj_inline(kind, key, pattern, map_options) abort
  let lhs = printf('<Plug>(surround-obj-%s:%s)',
  \                a:kind,
  \                escape(a:key, '|'))
  let rhs = printf(':<C-u>call surround_obj#core#textobj_inline_%s(%s)<CR>',
  \                a:kind,
  \                escape(string(a:pattern), '|'))
  execute 'vnoremap <silent>' a:map_options lhs rhs
  execute 'onoremap <silent>' a:map_options lhs rhs
  return lhs
endfunction

function! s:escape_key(key) abort
  let key = a:key
  let key = substitute(key, ' ', '<Space>', 'g')
  let key = substitute(key, '<', '<Lt>', 'g')
  let key = substitute(key, '\', '<Bslash>', 'g')
  let key = substitute(key, '|', '<Bar>', 'g')
  return key
endfunction

function! s:ignore_unbounded_key() abort
  if getchar(1) isnot 0
    call getchar()
  endif
  return ''
endfunction

function! s:make_pattern(delimiter) abort
  let delimiter = a:delimiter
  " Skip an character escaped by backslash.
  let prefix = '\V\%(\\\@1<!\\\)\@2<!'
  let suffix = ''

  if delimiter =~ '^\s'
    let delimiter = substitute(delimiter, '^\s\+', '', '')
    let prefix .= '\s\*'
  endif

  if delimiter =~ '\s$'
    let delimiter = substitute(delimiter, '\s\+$', '', '')
    let suffix .= '\s\*'
  endif

  return prefix . escape(delimiter, '\') . suffix
endfunction

function! s:map_operator_key_sequences(key, textobj, map_options) abort
  let key_characters = split(a:key, '.\zs')
  for i in range(0, len(key_characters) - 2)
    let escaped_key = s:escape_key(join(key_characters[:i]))
    execute 'nnoremap <expr>'
    \       ('<Plug>(surround-obj-change)' . escaped_key)
    \       '<SID>ignore_unbounded_key()'
    execute 'nnoremap <expr>'
    \       ('<Plug>(surround-obj-delete)' . escaped_key)
    \       '<SID>ignore_unbounded_key()'
  endfor
  let escaped_key = s:escape_key(a:key)
  execute 'nmap <silent>'
  \       (a:map_options)
  \       ('<Plug>(surround-obj-change)' . escaped_key)
  \       ('<SID>(operator-change)' . a:textobj)
  execute 'nmap <silent>'
  \       (a:map_options)
  \       ('<Plug>(surround-obj-delete)' . escaped_key)
  \       ('<SID>(operator-delete)' . a:textobj)
endfunction

nnoremap <expr> <SID>(operator-change)
\        surround_obj#core#setup_operator('surround_obj#core#operator_change')
nnoremap <expr> <SID>(operator-delete)
\        surround_obj#core#setup_operator('surround_obj#core#operator_delete')
