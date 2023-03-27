if exists('g:loaded_surround_obj')
  finish
endif

if !exists('g:surround_obj_objects')
  let g:surround_obj_objects = {}
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

let s:KEY_NOTATION_TABLE = {
\   '|': '<Bar>',
\   '\': '<Bslash>',
\   '<': '<Lt>',
\   ' ': '<Space>',
\ }

function! s:define_operator(lhs, operator_func) abort
  execute 'nnoremap' '<expr>' a:lhs
  \       'surround_obj#execute_operator_n(' . string(a:operator_func) . ')'
  execute 'vnoremap' '<expr>' a:lhs
  \       'surround_obj#execute_operator_v(' . string(a:operator_func) . ')'
  execute 'onoremap' a:lhs 'g@'
endfunction

function! s:define_text_objects(kind) abort
  for [key, object] in items(g:surround_obj_objects)
    if object.type ==# 'block'
      let arguments = has_key(object, 'pattern')
      \             ? join(map(copy(object.pattern), 'string(v:val)'), ', ')
      \             : type(object.delimiter) == v:t_func
      \             ? string(object.delimiter) . '()'
      \             : join(map(copy(object.delimiter),
      \                        'string(s:make_pattern(v:val))'), ', ')
      if arguments[-2:-1] ==# '()'
        let rhs = printf(':<C-u>call call(%s, %s)<CR>',
        \                string('surround_obj#textobj_block_' . a:kind),
        \                escape(arguments, '|'))
      else
        let rhs = printf(':<C-u>call surround_obj#textobj_block_%s(%s)<CR>',
        \                a:kind,
        \                escape(arguments, '|'))
      endif
    elseif object.type ==# 'inline'
      let arguments = has_key(object, 'pattern')
      \             ? string(object.pattern)
      \             : type(object.delimiter) == v:t_func
      \             ? string(object.delimiter) . '()'
      \             : string(s:make_pattern(object.delimiter))
      let rhs = printf(':<C-u>call surround_obj#textobj_inline_%s(%s)<CR>',
      \                a:kind,
      \                escape(arguments, '|'))
    elseif object.type ==# 'nop'
      continue
    else
      throw printf('Unexpected type "%s". Allowed values are "block", "inline" or "nop".',
      \            object.type)
    endif
    let lhs = printf('<Plug>(surround-obj-%s:%s)',
    \                a:kind,
    \                escape(key, '|'))
    execute 'vnoremap <silent>' lhs rhs
    execute 'onoremap <silent>' lhs rhs
  endfor
endfunction

function! s:define_plugin_mappings() abort
  map <silent> <Plug>(surround-obj-add)  <SID>(operator-add)
  map <Plug>(surround-obj-change)  <Nop>
  map <Plug>(surround-obj-remove)  <Nop>

  for [key, object] in items(g:surround_obj_objects)
    if object.type ==# 'block' || object.type ==# 'inline'
      let textobj = '<Plug>(surround-obj-a:' . escape(key, '|')  . ')'
      let key_notation = get(s:KEY_NOTATION_TABLE, key, key)
      execute 'nmap <silent>'
      \       ('<Plug>(surround-obj-change)' . key_notation)
      \       ('<SID>(operator-change)' . textobj)
      execute 'nmap <silent>'
      \       ('<Plug>(surround-obj-delete)' . key_notation)
      \       ('<SID>(operator-delete)' . textobj)
    endif
  endfor
endfunction

function! s:make_pattern(delimiter) abort
  let delimiter = substitute(a:delimiter, '^\s\+\|\s\+$', '', '')
  if strchars(delimiter) > 1
    return '\V' . escape(delimiter, '\')
  else
    return '\V\%(\[^\\]\\\)\@<!' . escape(delimiter, '\')
  endif
endfunction

call s:define_operator('<SID>(operator-add)',
\                      'surround_obj#operator_add')
call s:define_operator('<SID>(operator-change)',
\                      'surround_obj#operator_change')
call s:define_operator('<SID>(operator-delete)',
\                      'surround_obj#operator_delete')

call s:define_text_objects('a')
call s:define_text_objects('i')

call s:define_plugin_mappings()

let g:loaded_surround_obj = 1
