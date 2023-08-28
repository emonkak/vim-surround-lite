if exists('g:loaded_surround_obj')
  finish
endif

if !exists('g:surround_obj_config')
  let g:surround_obj_config = {}
end

let s:BUILTIN_DEFINITIONS = {
\   '!': { 'type': 'inline', 'delimiter': '!' },
\   '"': { 'type': 'inline', 'delimiter': '"' },
\   '#': { 'type': 'inline', 'delimiter': '#' },
\   '$': { 'type': 'inline', 'delimiter': '$' },
\   '%': { 'type': 'inline', 'delimiter': '%' },
\   '&': { 'type': 'inline', 'delimiter': '&' },
\   "'": { 'type': 'inline', 'delimiter': "'" },
\   '*': { 'type': 'inline', 'delimiter': '*' },
\   '+': { 'type': 'inline', 'delimiter': '+' },
\   ',': { 'type': 'inline', 'delimiter': ',' },
\   '-': { 'type': 'inline', 'delimiter': '-' },
\   '.': { 'type': 'inline', 'delimiter': '.' },
\   '/': { 'type': 'inline', 'delimiter': '/' },
\   ':': { 'type': 'inline', 'delimiter': ':' },
\   ';': { 'type': 'inline', 'delimiter': ';' },
\   '=': { 'type': 'inline', 'delimiter': '=' },
\   '?': { 'type': 'inline', 'delimiter': '?' },
\   '@': { 'type': 'inline', 'delimiter': '@' },
\   '\': { 'type': 'inline', 'delimiter': '\' },
\   '^': { 'type': 'inline', 'delimiter': '^' },
\   '_': { 'type': 'inline', 'delimiter': '_' },
\   '`': { 'type': 'inline', 'delimiter': '`' },
\   '|': { 'type': 'inline', 'delimiter': '|' },
\   '~': { 'type': 'inline', 'delimiter': '~' },
\   '(': { 'type': 'block', 'delimiter': ['(', ')'] },
\   ')': { 'type': 'block', 'delimiter': ['( ', ' )'] },
\   '<': { 'type': 'block', 'delimiter': ['<', '>'] },
\   '>': { 'type': 'block', 'delimiter': ['< ', ' >'] },
\   '[': { 'type': 'block', 'delimiter': ['[', ']'] },
\   ']': { 'type': 'block', 'delimiter': ['[ ', ' ]'] },
\   '{': { 'type': 'block', 'delimiter': ['{', '}'] },
\   '}': { 'type': 'block', 'delimiter': ['{ ', ' }'] },
\   'B': { 'type': 'block', 'delimiter': ['{', '}'] },
\   'b': { 'type': 'block', 'delimiter': ['(', ')'] },
\   'f': {
\     'type': 'block',
\     'delimiter': function('surround_obj#ask_function_name'),
\     'pattern': ['\h\w*\s*(', ')'],
\   },
\   't': {
\     'type': 'block',
\     'delimiter': function('surround_obj#ask_tag_name'),
\     'pattern': ['<\%(\a[^>]*\)\?>', '</[^>]*>'],
\   },
\ }

function! s:define_block_object(key, definition) abort
  if !has_key(a:definition, 'pattern')
    if type(a:definition.delimiter) is v:t_list
      let a:definition.pattern = map(
      \   copy(a:definition.delimiter),
      \   's:make_pattern(v:val)'
      \ )
    else
      throw 'You must specify the "pattern" when the "delimiter" is a function.'
    endif
  endif
  for kind in ['i', 'a']
    let lhs = printf(
    \   '<Plug>(surround-obj-%s:%s)',
    \   kind,
    \   escape(a:key, '|')
    \ )
    let rhs = printf(
    \   ':<C-u>call surround_obj#textobj_block_%s(%s, %s)<CR>',
    \   kind,
    \   escape(string(a:definition.pattern[0]), '|'),
    \   escape(string(a:definition.pattern[1]), '|')
    \ )
    execute 'vnoremap <silent>' lhs rhs
    execute 'onoremap <silent>' lhs rhs
  endfor
endfunction

function! s:define_inline_object(key, definition) abort
  if !has_key(a:definition, 'pattern')
    if type(a:definition.delimiter) is v:t_string
      let a:definition.pattern = s:make_pattern(a:definition.delimiter)
    else
      throw 'You must specify the "pattern" when the "delimiter" is a function.'
    endif
  endif
  for kind in ['i', 'a']
    let lhs = printf(
    \   '<Plug>(surround-obj-%s:%s)',
    \   kind,
    \   escape(a:key, '|')
    \ )
    let rhs = printf(
    \   ':<C-u>call surround_obj#textobj_inline_%s(%s)<CR>',
    \   kind,
    \   escape(string(a:definition.pattern), '|')
    \ )
    execute 'vnoremap <silent>' lhs rhs
    execute 'onoremap <silent>' lhs rhs
  endfor
endfunction

function! s:define_objects() abort
  let loaded_objects = {}
  let definitions = copy(g:surround_obj_config)

  if !get(g:, 'surround_obj_no_builtin_objects', 0)
    call extend(definitions, s:BUILTIN_DEFINITIONS, 'keep')
  endif

  for [key, definition] in items(definitions)
    if definition.type ==# 'block'
      call s:define_block_object(key, definition)
    elseif definition.type ==# 'inline'
      call s:define_inline_object(key, definition)
    elseif definition.type ==# 'nop'
      continue
    else
      throw printf(
      \   'Unexpected type "%s". Allowed types are "block", "inline", or "nop".',
      \   a:definition.type
      \ )
    endif

    let transition_keys = split(key, '.\zs')[:-2]

    for i in range(len(transition_keys))
      let transition_key = join(transition_keys[:i])
      if !has_key(loaded_objects, transition_key)
        let loaded_objects[transition_key] = {
        \   'type': 'transition',
        \ }
      endif
    endfor

    let loaded_objects[key] = definition
  endfor

  return loaded_objects
endfunction

function! s:define_operator_mappings(objects) abort
  nnoremap <expr> <Plug>(surround-obj-add)
  \        surround_obj#do_operator('surround_obj#operator_add')
  vnoremap <expr> <Plug>(surround-obj-add)
  \        surround_obj#do_operator('surround_obj#operator_add')
  onoremap <Plug>(surround-obj-add)  g@

  noremap <Plug>(surround-obj-change)  <Nop>
  noremap <Plug>(surround-obj-delete)  <Nop>

  noremap <expr> <SID>(operator-change)
  \       surround_obj#do_operator('surround_obj#operator_change')
  noremap <expr> <SID>(operator-delete)
  \       surround_obj#do_operator('surround_obj#operator_delete')

  for [key, object] in items(a:objects)
    let escaped_key = s:escape_key(key)
    if object.type ==# 'block' || object.type ==# 'inline'
      let textobj = printf('<Plug>(surround-obj-a:%s)', escape(key, '|'))
      execute 'nmap <silent>'
      \       ('<Plug>(surround-obj-change)' . escaped_key)
      \       ('<SID>(operator-change)' . textobj)
      execute 'nmap <silent>'
      \       ('<Plug>(surround-obj-delete)' . escaped_key)
      \       ('<SID>(operator-delete)' . textobj)
    else  " object.type = 'transition'
      execute 'nnoremap'
      \       ('<Plug>(surround-obj-change)' . escaped_key)
      \       '<Nop>'
      execute 'nnoremap'
      \       ('<Plug>(surround-obj-delete)' . escaped_key)
      \       '<Nop>'
    endif
  endfor
endfunction

function! s:escape_key(key) abort
  let key = a:key
  let key = substitute(key, ' ', '<Space>', 'g')
  let key = substitute(key, '<', '<Lt>', 'g')
  let key = substitute(key, '\', '<Bslash>', 'g')
  let key = substitute(key, '|', '<Bar>', 'g')
  return key
endfunction

function! s:make_pattern(delimiter) abort
  let delimiter = a:delimiter
  let prefix = ''
  let suffix = ''

  if delimiter =~ '^\s'
    let delimiter = substitute(delimiter, '^\s\+', '', '')
    let prefix .= '\s\*'
  endif

  if delimiter =~ '\s$'
    let delimiter = substitute(delimiter, '\s\+$', '', '')
    let suffix .= '\s\*'
  endif

  if strlen(delimiter) == 1
    " Skip an character escaped by backslash if delimiter is a single byte
    " character.
    let prefix = '\V\%(\\\@1<!\\\)\@2<!' . prefix
  endif

  return prefix . escape(delimiter, '\') . suffix
endfunction

let g:surround_obj#loaded_objects = s:define_objects()

call s:define_operator_mappings(g:surround_obj#loaded_objects)

let g:loaded_surround_obj = 1
