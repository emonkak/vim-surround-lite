if exists('g:loaded_surround_obj')
  finish
endif

nnoremap <expr> <Plug>(surround-obj-add)
\        surround_obj#core#setup_operator('surround_obj#core#operator_add')
vnoremap <expr> <Plug>(surround-obj-add)
\        surround_obj#core#setup_operator('surround_obj#core#operator_add')
onoremap <Plug>(surround-obj-add) g@

map <Plug>(surround-obj-change) <Nop>

map <Plug>(surround-obj-remove) <Nop>

let g:loaded_surround_obj = 1
