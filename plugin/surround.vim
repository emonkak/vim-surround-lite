if exists('g:loaded_surround')
  finish
endif

if !exists('g:surround_objects')
  let g:surround_objects = {}
endif

if !get(g:, 'surround_no_default_objects', 0)
  call extend(g:surround_objects, {
  \   '!': { 'type': 'single', 'delimiter': '!' },
  \   '"': { 'type': 'single', 'delimiter': '"' },
  \   '#': { 'type': 'single', 'delimiter': '#' },
  \   '$': { 'type': 'single', 'delimiter': '$' },
  \   '%': { 'type': 'single', 'delimiter': '%' },
  \   '&': { 'type': 'single', 'delimiter': '&' },
  \   "'": { 'type': 'single', 'delimiter': "'" },
  \   '(': { 'type': 'pair', 'delimiter': ['(', ')'] },
  \   ')': { 'type': 'pair', 'delimiter': ['(', ')'] },
  \   '*': { 'type': 'single', 'delimiter': '*' },
  \   '+': { 'type': 'single', 'delimiter': '+' },
  \   ',': { 'type': 'single', 'delimiter': ',' },
  \   '-': { 'type': 'single', 'delimiter': '-' },
  \   '.': { 'type': 'single', 'delimiter': '.' },
  \   '/': { 'type': 'single', 'delimiter': '/' },
  \   ':': { 'type': 'single', 'delimiter': ':' },
  \   ';': { 'type': 'single', 'delimiter': ';' },
  \   '<': { 'type': 'pair', 'delimiter': ['<', '>'] },
  \   '=': { 'type': 'single', 'delimiter': '=' },
  \   '>': { 'type': 'pair', 'delimiter': ['<', '>'] },
  \   '?': { 'type': 'single', 'delimiter': '?' },
  \   '@': { 'type': 'single', 'delimiter': '@' },
  \   'B': { 'type': 'pair', 'delimiter': ['{', '}'] },
  \   '[': { 'type': 'pair', 'delimiter': ['[', ']'] },
  \   '\': { 'type': 'single', 'delimiter': '\' },
  \   ']': { 'type': 'pair', 'delimiter': ['[', ']'] },
  \   '^': { 'type': 'single', 'delimiter': '^' },
  \   '_': { 'type': 'single', 'delimiter': '_' },
  \   '`': { 'type': 'single', 'delimiter': '`' },
  \   'a': { 'type': 'pair', 'delimiter': ['<', '>'] },
  \   'b': { 'type': 'pair', 'delimiter': ['(', ')'] },
  \   'r': { 'type': 'pair', 'delimiter': ['[', ']'] },
  \   't': { 'type': 'pair', 'delimiter': function('surround#ask_tag_name'), 'pattern': ['<\%(\a[^>]*\)\?>', '</[^>]*>'] },
  \   '{': { 'type': 'pair', 'delimiter': ['{', '}'] },
  \   '|': { 'type': 'single', 'delimiter': '|' },
  \   '}': { 'type': 'pair', 'delimiter': ['{', '}'] },
  \   '~': { 'type': 'single', 'delimiter': '~' },
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
  \       'surround#execute_operator_n(' . string(a:operator_func) . ')'
  execute 'vnoremap' '<expr>' a:lhs
  \       'surround#execute_operator_v(' . string(a:operator_func) . ')'
  execute 'onoremap' a:lhs 'g@'
endfunction

function! s:define_text_objects(kind) abort
  for [key, object] in items(g:surround_objects)
    if object.type ==# 'single'
      let arguments = has_key(object, 'pattern')
      \             ? string(object.pattern)
      \             : type(object.delimiter) == v:t_func
      \             ? string(object.delimiter) . '()'
      \             : string(s:make_pattern(object.delimiter))
      let rhs = printf(':<C-u>call surround#textobj_single_%s(%s)<CR>',
      \                a:kind,
      \                escape(arguments, '|'))
    elseif object.type ==# 'pair'
      let arguments = has_key(object, 'pattern')
      \             ? join(map(copy(object.pattern), 'string(v:val)'), ', ')
      \             : type(object.delimiter) == v:t_func
      \             ? string(object.delimiter) . '()'
      \             : join(map(copy(object.delimiter),
      \                        'string(s:make_pattern(v:val))'), ', ')
      if arguments[-2:-1] ==# '()'
        let rhs = printf(':<C-u>call call(%s, %s)<CR>',
        \                string('surround#textobj_pair_' . a:kind),
        \                escape(arguments, '|'))
      else
        let rhs = printf(':<C-u>call surround#textobj_pair_%s(%s)<CR>',
        \                a:kind,
        \                escape(arguments, '|'))
      endif
    elseif object.type ==# 'nop'
      continue
    else
      throw printf('Unexpected type "%s". Allowed values are "single", "pair" or "nop".',
      \            object.type)
    endif
    let lhs = printf('<Plug>(surround-textobj-%s:%s)',
    \                a:kind,
    \                escape(key, '|'))
    execute 'vnoremap <silent>' lhs rhs
    execute 'onoremap <silent>' lhs rhs
  endfor
endfunction

function! s:define_plugin_mappings() abort
  map <silent> <Plug>(surround-add)  <SID>(operator-add)
  map <Plug>(surround-change)  <Nop>
  map <Plug>(surround-remove)  <Nop>

  for [key, object] in items(g:surround_objects)
    if object.type ==# 'single' || object.type ==# 'pair'
      let textobj = '<Plug>(surround-textobj-a:' . escape(key, '|')  . ')'
      let key_notation = get(s:KEY_NOTATION_TABLE, key, key)
      execute 'nmap <silent>'
      \       ('<Plug>(surround-change)' . key_notation)
      \       ('<SID>(operator-change)' . textobj)
      execute 'nmap <silent>'
      \       ('<Plug>(surround-delete)' . key_notation)
      \       ('<SID>(operator-delete)' . textobj)
    endif
  endfor
endfunction

function! s:make_pattern(delimiter) abort
  if strchars(a:delimiter) > 1
    return '\V' . escape(a:delimiter, '\')
  else
    return '\V\%(\[^\\]\\\)\@<!' . escape(a:delimiter, '\')
  endif
endfunction

call s:define_operator('<SID>(operator-add)',
\                      'surround#operator_add')
call s:define_operator('<SID>(operator-change)',
\                      'surround#operator_change')
call s:define_operator('<SID>(operator-delete)',
\                      'surround#operator_delete')

call s:define_text_objects('a')
call s:define_text_objects('i')

call s:define_plugin_mappings()

let g:loaded_surround = 1
