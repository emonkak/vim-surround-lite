if exists('g:loaded_surround_obj')
  finish
endif

let g:surround_obj_objects = {}

if exists('g:surround_obj_custom_objects')
  call extend(g:surround_obj_objects, g:surround_obj_custom_objects)
endif

if !get(g:, 'surround_obj_no_default_objects', 0)
  call extend(g:surround_obj_objects, {
  \   '!': { 'type': 'inline', 'delimiter': '!' },
  \   '"': { 'type': 'inline', 'delimiter': '"' },
  \   '#': { 'type': 'inline', 'delimiter': '#' },
  \   '$': { 'type': 'inline', 'delimiter': '$' },
  \   '%': { 'type': 'inline', 'delimiter': '%' },
  \   '&': { 'type': 'inline', 'delimiter': '&' },
  \   "'": { 'type': 'inline', 'delimiter': "'" },
  \   '(': { 'type': 'block', 'delimiter': ['(', ')'] },
  \   ')': { 'type': 'block', 'delimiter': ['( ', ' )'] },
  \   '*': { 'type': 'inline', 'delimiter': '*' },
  \   '+': { 'type': 'inline', 'delimiter': '+' },
  \   ',': { 'type': 'inline', 'delimiter': ',' },
  \   '-': { 'type': 'inline', 'delimiter': '-' },
  \   '.': { 'type': 'inline', 'delimiter': '.' },
  \   '/': { 'type': 'inline', 'delimiter': '/' },
  \   ':': { 'type': 'inline', 'delimiter': ':' },
  \   ';': { 'type': 'inline', 'delimiter': ';' },
  \   '<': { 'type': 'block', 'delimiter': ['<', '>'] },
  \   '=': { 'type': 'inline', 'delimiter': '=' },
  \   '>': { 'type': 'block', 'delimiter': ['< ', ' >'] },
  \   '?': { 'type': 'inline', 'delimiter': '?' },
  \   '@': { 'type': 'inline', 'delimiter': '@' },
  \   'B': { 'type': 'block', 'delimiter': ['{', '}'] },
  \   '[': { 'type': 'block', 'delimiter': ['[', ']'] },
  \   '\': { 'type': 'inline', 'delimiter': '\' },
  \   ']': { 'type': 'block', 'delimiter': ['[ ', ' ]'] },
  \   '^': { 'type': 'inline', 'delimiter': '^' },
  \   '_': { 'type': 'inline', 'delimiter': '_' },
  \   '`': { 'type': 'inline', 'delimiter': '`' },
  \   'a': { 'type': 'block', 'delimiter': ['<', '>'] },
  \   'b': { 'type': 'block', 'delimiter': ['(', ')'] },
  \   'r': { 'type': 'block', 'delimiter': ['[', ']'] },
  \   't': { 'type': 'block', 'delimiter': function('surround_obj#ask_tag_name'), 'pattern': ['<\%(\a[^>]*\)\?>', '</[^>]*>'] },
  \   '{': { 'type': 'block', 'delimiter': ['{', '}'] },
  \   '|': { 'type': 'inline', 'delimiter': '|' },
  \   '}': { 'type': 'block', 'delimiter': ['{ ', ' }'] },
  \   '~': { 'type': 'inline', 'delimiter': '~' },
  \ }, 'keep')
endif

let s:KEY_NOTATIONS = {
\   '|': '<Bar>',
\   '\': '<Bslash>',
\   '<': '<Lt>',
\   ' ': '<Space>',
\ }

function! s:define_plugin_mappings() abort
  call s:define_operator('<SID>(operator-add)',
  \                      'surround_obj#operator_add')
  call s:define_operator('<SID>(operator-change)',
  \                      'surround_obj#operator_change')
  call s:define_operator('<SID>(operator-delete)',
  \                      'surround_obj#operator_delete')

  map <silent> <Plug>(surround-obj-add)  <SID>(operator-add)
  map <Plug>(surround-obj-change)  <Nop>
  map <Plug>(surround-obj-remove)  <Nop>

  for [key, object] in items(g:surround_obj_objects)
    let textobj_a = s:define_text_object(key, object, 'a')

    call s:define_text_object(key, object, 'i')

    if textobj_a isnot 0
      let key_notation = get(s:KEY_NOTATIONS, key, key)
      execute 'nmap <silent>'
      \       ('<Plug>(surround-obj-change)' . key_notation)
      \       ('<SID>(operator-change)' . textobj_a)
      execute 'nmap <silent>'
      \       ('<Plug>(surround-obj-delete)' . key_notation)
      \       ('<SID>(operator-delete)' . textobj_a)
    endif
  endfor
endfunction

function! s:define_operator(lhs, operator_func) abort
  execute 'nnoremap' '<expr>' a:lhs
  \       'surround_obj#setup_operator_n(' . string(a:operator_func) . ')'
  execute 'vnoremap' '<expr>' a:lhs
  \       'surround_obj#setup_operator_v(' . string(a:operator_func) . ')'
  execute 'onoremap' a:lhs 'g@'
endfunction

function! s:define_text_object(key, object, kind) abort
  if a:object.type ==# 'block'
    if has_key(a:object, 'pattern')
      let arguments = join(map(copy(a:object.pattern), 'string(v:val)'), ', ')
    elseif type(a:object.delimiter) == v:t_list
      let arguments = join(map(copy(a:object.delimiter),
      \                        'string(s:make_pattern(v:val))'), ', ')
    else
      return 0
    endif
    let rhs = printf(':<C-u>call surround_obj#textobj_block_%s(%s)<CR>',
    \                a:kind,
    \                escape(arguments, '|'))
  elseif a:object.type ==# 'inline'
    if has_key(a:object, 'pattern')
      let arguments = string(a:object.pattern)
    elseif type(a:object.delimiter) == v:t_string
      let arguments = string(s:make_pattern(a:object.delimiter))
    else
      return 0
    endif
    let rhs = printf(':<C-u>call surround_obj#textobj_inline_%s(%s)<CR>',
    \                a:kind,
    \                escape(arguments, '|'))
  elseif a:object.type ==# 'nop'
    return 0
  else
    throw printf('Unexpected type "%s". Allowed values are "block", "inline" or "nop".',
    \            a:object.type)
  endif
  let lhs = printf('<Plug>(surround-obj-%s:%s)',
  \                a:kind,
  \                escape(a:key, '|'))
  execute 'vnoremap <silent>' lhs rhs
  execute 'onoremap <silent>' lhs rhs
  return lhs
endfunction

function! s:make_pattern(delimiter) abort
  let delimiter = substitute(a:delimiter, '^\s\+\|\s\+$', '', '')
  if strchars(delimiter) > 1
    return '\V' . escape(delimiter, '\')
  else
    return '\V\%(\[^\\]\\\)\@<!' . escape(delimiter, '\')
  endif
endfunction

call s:define_plugin_mappings()

let g:loaded_surround_obj = 1
