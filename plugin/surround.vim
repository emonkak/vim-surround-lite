if exists('g:loaded_surround')
  finish
endif

if !exists('g:surround_objects')
  let g:surround_objects = {
  \   'b': ['(', ')'],
  \   '(': ['(', ')'],
  \   ')': ['(', ')'],
  \   'B': ['{', '}'],
  \   '{': ['{', '}'],
  \   '}': ['{', '}'],
  \   'r': ['[', ']'],
  \   '[': ['[', ']'],
  \   ']': ['[', ']'],
  \   'a': ['<', '>'],
  \   '<': ['<', '>'],
  \   '>': ['<', '>'],
  \   '"': ['"', '"'],
  \   "'": ["'", "'"],
  \   '`': ['`', '`'],
  \   '/': ['/', '/'],
  \   '|': ['|', '|'],
  \ }
endif

let s:KEY_NOTATION_TABLE = {
\   '|': '<Bar>',
\   '\\': '<Bslash>',
\   '<': '<Lt>',
\   ' ': '<Space>',
\ }

function! s:define_text_objects(kind) abort
  for [key, value] in items(g:surround_objects)
    let [head, tail] = value
    let lhs = printf('<Plug>(surround-textobj-%s:%s)',
    \                a:kind,
    \                escape(key, '|'))
    if head ==# tail
      let rhs = printf(':<C-u>call surround#textobj_between_%s(%s)<CR>',
      \                a:kind,
      \                string(escape(head, '|')))
    else
      let rhs = printf(':<C-u>call surround#textobj_around_%s(%s, %s)<CR>',
      \                a:kind,
      \                string(escape(head, '|')),
      \                string(escape(tail, '|')))
    endif
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
    execute 'nmap'
    \       ('cs' . s:key_notattion_from_char(key))
    \       ('<Plug>(surround-operator-change)'. textobj)
    execute 'nmap'
    \       ('ds' . s:key_notattion_from_char(key))
    \       ('<Plug>(surround-operator-delete)' . textobj)
  endfor
endfunction

function! s:key_notattion_from_char(c) abort
  return get(s:KEY_NOTATION_TABLE, a:c, a:c)
endfunction

nnoremap <expr> <Plug>(surround-operator-add)
\               surround#do_operator_n('surround#operator_add')
vnoremap <expr> <Plug>(surround-operator-add)
\               surround#do_operator_v('surround#operator_add')
onoremap <Plug>(surround-operator-add)  g@

nnoremap <expr> <Plug>(surround-operator-change)
\               surround#do_operator_n('surround#operator_change')
vnoremap <expr> <Plug>(surround-operator-change)
\               surround#do_operator_v('surround#operator_change')
onoremap <Plug>(surround-operator-change)  g@

nnoremap <expr> <Plug>(surround-operator-delete)
\               surround#do_operator_n('surround#operator_delete')
vnoremap <expr> <Plug>(surround-operator-delete)
\               surround#do_operator_v('surround#operator_delete')
onoremap <Plug>(surround-operator-delete)  g@

call s:define_text_objects('a')
call s:define_text_objects('i')

if !get(g:, 'surround_no_default_key_mappings', 0)
  call s:define_default_key_mappings()
endif

let g:loaded_surround = 1
