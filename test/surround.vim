runtime! plugin/surround.vim

function! s:test_surround_add() abort
  call s:do_test('yseb', 'foo bar baz', ['(foo) bar baz'])
  call s:do_test('wyseb', 'foo bar baz', ['foo (bar) baz'])
  call s:do_test('ys$b', 'foo bar baz', ['(foo bar baz)'])
  call s:do_test('ys$bwyseb', 'foo bar baz', ['((foo) bar baz)'])

  call s:do_test('yse"', 'foo bar baz', ['"foo" bar baz'])
  call s:do_test('wyse"', 'foo bar baz', ['foo "bar" baz'])
  call s:do_test('ys$"', 'foo bar baz', ['"foo bar baz"'])

  call s:do_test('yse''', 'foo bar baz', ['''foo'' bar baz'])
  call s:do_test('wyse''', 'foo bar baz', ['foo ''bar'' baz'])
  call s:do_test('ys$''', 'foo bar baz', ['''foo bar baz'''])
endfunction

function! s:test_surround_change() abort
  call s:do_test('csbB', '(foo)', ['{foo}'])
  call s:do_test('csbB', '( foo )', ['{ foo }'])
  call s:do_test('csbB', '( foo)', ['{ foo}'])
  call s:do_test('csbB', '(foo )', ['{foo }'])
  call s:do_test('csbB', '(foo())', ['{foo()}'])
  call s:do_test('2wcsbB', 'foo(bar())', ['foo{bar()}'])
  call s:do_test('3wcsbB', 'foo(bar())', ['foo(bar{})'])
  call s:do_test('3wcsbBcsbB', 'foo(bar())', ['foo{bar{}}'])

  call s:do_test('cs/b', '/foo/', ['(foo)'])
  call s:do_test('cs/b', '/ foo /', ['( foo )'])
  call s:do_test('cs/b', '/ foo/', ['( foo)'])
  call s:do_test('cs/b', '/foo /', ['(foo )'])
  call s:do_test('cs/b', '/ \/foo\/ /', ['( \/foo\/ )'])
endfunction

function! s:test_surround_delete() abort
  call s:do_test('dsb', '(foo)', ['foo'])
  call s:do_test('dsb', '(foo )', ['foo'])
  call s:do_test('dsb', '( foo)', ['foo'])
  call s:do_test('dsb', '( foo )', ['foo'])

  call s:do_test('dsb', '(foo())', ['foo()'])
  call s:do_test('f(dsb', '(foo())', ['(foo)'])
  call s:do_test('dsb', '(foo(bar()))', ['foo(bar())'])
  call s:do_test('f(dsb', '(foo(bar()))', ['(foobar())'])
  call s:do_test('2f(dsb', '(foo(bar()))', ['(foo(bar))'])

  call s:do_test('dsb', '(foo)()(bar)', ['foo()(bar)'])
  call s:do_test('f(dsb', '(foo)()(bar)', ['(foo)(bar)'])
  call s:do_test('2f(dsb', '(foo)()(bar)', ['(foo)()bar'])

  call s:do_test('f(dsb', '(foo)(bar)(baz)', ['(foo)bar(baz)'])
  call s:do_test('2f(dsb', '(foo)(bar)(baz)', ['(foo)(bar)baz'])
  call s:do_test('2wdsb', 'foo(bar())', ['foobar()'])

  call s:do_test('ds/', '//', [''])
  call s:do_test('ds/', '/foo/', ['foo'])
  call s:do_test('ds/', '/ foo /', ['foo'])
  call s:do_test('ds/', '/ foo/', ['foo'])
  call s:do_test('ds/', '/foo /', ['foo'])
  call s:do_test('ds/', '/ \/foo\/ /', ['\/foo\/'])
endfunction

function! s:do_test(keys, body, expected) abort
  new
  silent put =a:body
  1delete
  1
  execute 'normal' a:keys
  call assert_equal(a:expected, getline(1, line('$')), '')
  close!
endfunction
