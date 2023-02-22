if exists('g:loaded_surround')
  finish
endif

if !exists('g:surround_objects')
  let g:surround_objects = {
  \   '!': { 'type': 'single', 'delimiter': '!' },
  \   '"': { 'type': 'single', 'delimiter': '"' },
  \   '#': { 'type': 'single', 'delimiter': '#' },
  \   '$': { 'type': 'single', 'delimiter': '$' },
  \   '%': { 'type': 'single', 'delimiter': '%' },
  \   '&': { 'type': 'single', 'delimiter': '&' },
  \   "'": { 'type': 'single', 'delimiter': "'" },
  \   '(': { 'type': 'pair', 'start': '(', 'end': ')' },
  \   ')': { 'type': 'pair', 'start': '(', 'end': ')' },
  \   '*': { 'type': 'single', 'delimiter': '*' },
  \   '+': { 'type': 'single', 'delimiter': '+' },
  \   ',': { 'type': 'single', 'delimiter': ',' },
  \   '-': { 'type': 'single', 'delimiter': '-' },
  \   '.': { 'type': 'single', 'delimiter': '.' },
  \   '/': { 'type': 'single', 'delimiter': '/' },
  \   ':': { 'type': 'single', 'delimiter': ':' },
  \   ';': { 'type': 'single', 'delimiter': ';' },
  \   '<': { 'type': 'pair', 'start': '<', 'end': '>' },
  \   '=': { 'type': 'single', 'delimiter': '=' },
  \   '>': { 'type': 'pair', 'start': '<', 'end': '>' },
  \   '?': { 'type': 'single', 'delimiter': '?' },
  \   '@': { 'type': 'single', 'delimiter': '@' },
  \   'B': { 'type': 'pair', 'start': '{', 'end': '}' },
  \   '[': { 'type': 'pair', 'start': '[', 'end': ']' },
  \   '\\': { 'type': 'single', 'delimiter': '\\' },
  \   ']': { 'type': 'pair', 'start': '[', 'end': ']' },
  \   '^': { 'type': 'single', 'delimiter': '^' },
  \   '_': { 'type': 'single', 'delimiter': '_' },
  \   '`': { 'type': 'single', 'delimiter': '`' },
  \   'a': { 'type': 'pair', 'start': '<', 'end': '>' },
  \   'b': { 'type': 'pair', 'start': '(', 'end': ')' },
  \   'r': { 'type': 'pair', 'start': '[', 'end': ']' },
  \   't': { 'type': 'tag' },
  \   '{': { 'type': 'pair', 'start': '{', 'end': '}' },
  \   '|': { 'type': 'single', 'delimiter': '|' },
  \   '}': { 'type': 'pair', 'start': '{', 'end': '}' },
  \   '~': { 'type': 'single', 'delimiter': '~' },
  \ }
endif

let s:KEY_NOTATION_TABLE = {
\   '|': '<Bar>',
\   '\\': '<Bslash>',
\   '<': '<Lt>',
\   ' ': '<Space>',
\ }

function! s:define_operator(lhs, operator_func) abort
  execute 'nnoremap' '<expr>' a:lhs
  \       'surround#do_operator_n(' . string(a:operator_func) . ')'
  execute 'vnoremap' '<expr>' a:lhs
  \       'surround#do_operator_v(' . string(a:operator_func) . ')'
  execute 'onoremap' a:lhs 'g@'
endfunction

function! s:define_text_objects(kind) abort
  for [key, object] in items(g:surround_objects)
    if object.type ==# 'single'
      let rhs = printf(':<C-u>call surround#textobj_single_%s(%s)<CR>',
      \                a:kind,
      \                string(escape(object.delimiter, '|')))
    elseif object.type ==# 'pair'
      let rhs = printf(':<C-u>call surround#textobj_pair_%s(%s, %s)<CR>',
      \                a:kind,
      \                string(escape(object.start, '|')),
      \                string(escape(object.end, '|')))
    elseif object.type ==# 'tag'
      let rhs = printf(':<C-u>call surround#textobj_tag_%s(input("Tag Name: "))<CR>',
      \                a:kind)
    else
      throw printf('Unexpected type "%s". Allowed values are "single", "pair" or "tag".',
      \            object.type)
    endif
    let lhs = printf('<Plug>(surround-textobj-%s:%s)',
    \                a:kind,
    \                escape(key, '|'))
    execute 'vnoremap <silent>' lhs rhs
    execute 'onoremap <silent>' lhs rhs
  endfor
endfunction

function! s:define_default_key_mappings() abort
  nmap ys  <Plug>(surround-operator-add)

  nnoremap cs  <Nop>
  nnoremap ds  <Nop>

  for key in keys(g:surround_objects)
    let textobj = '<Plug>(surround-textobj-a:' . escape(key, '|')  . ')'
    let key_notation = get(s:KEY_NOTATION_TABLE, key, key)
    execute 'nmap'
    \       ('cs' . key_notation)
    \       ('<Plug>(surround-operator-change)' . textobj)
    execute 'nmap'
    \       ('ds' . key_notation)
    \       ('<Plug>(surround-operator-delete)' . textobj)
  endfor
endfunction

call s:define_operator('<Plug>(surround-operator-add)',
\                      'surround#operator_add')
call s:define_operator('<Plug>(surround-operator-change)',
\                      'surround#operator_change')
call s:define_operator('<Plug>(surround-operator-delete)',
\                      'surround#operator_delete')

call s:define_text_objects('a')
call s:define_text_objects('i')

if !get(g:, 'surround_no_default_key_mappings', 0)
  call s:define_default_key_mappings()
endif

let g:loaded_surround = 1
