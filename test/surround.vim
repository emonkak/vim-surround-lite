runtime! plugin/surround.vim

function! s:test_surround_add() abort
  call s:do_test('yseb', 'foo bar baz', ['(foo) bar baz'])
  call s:do_test('wyseb', 'foo bar baz', ['foo (bar) baz'])
  call s:do_test('ys$b', 'foo bar baz', ['(foo bar baz)'])
  call s:do_test('ys$bwyseb', 'foo bar baz', ['((foo) bar baz)'])
  call s:do_test('wyseb', '  foo', ['  (foo)'])

  call s:do_test('yse"', 'foo bar baz', ['"foo" bar baz'])
  call s:do_test('wyse"', 'foo bar baz', ['foo "bar" baz'])
  call s:do_test('ys$"', 'foo bar baz', ['"foo bar baz"'])

  call s:do_test('yse''', 'foo bar baz', ['''foo'' bar baz'])
  call s:do_test('wyse''', 'foo bar baz', ['foo ''bar'' baz'])
  call s:do_test('ys$''', 'foo bar baz', ['''foo bar baz'''])
endfunction

function! s:test_surround_change() abort
  call s:do_test('csbB', '()', ['{}'])
  call s:do_test('csbB', '(foo)', ['{foo}'])
  call s:do_test('csbB', '(foo )', ['{foo }'])
  call s:do_test('csbB', '( foo)', ['{ foo}'])
  call s:do_test('csbB', '( foo )', ['{ foo }'])
  call s:do_test('csbB', '(foo())', ['{foo()}'])
  call s:do_test('f(csbB', '(foo())', ['(foo{})'])
  call s:do_test('f(csbB', '  ()  ', ['  {}  '])
  call s:do_test('f(csbB', '  (foo)  ', ['  {foo}  '])

  call s:do_test('$csbB', '()', ['{}'])
  call s:do_test('$csbB', '(foo )', ['{foo }'])
  call s:do_test('$csbB', '( foo)', ['{ foo}'])
  call s:do_test('$csbB', '( foo )', ['{ foo }'])
  call s:do_test('$csbB', '(foo())', ['{foo()}'])
  call s:do_test('f)csbB', '(foo())', ['(foo{})'])
  call s:do_test('f)csbB', '  ()  ', ['  {}  '])
  call s:do_test('f)csbB', '  (foo)  ', ['  {foo}  '])

  call s:do_test('ffcsbB', '(foo)', ['{foo}'])
  call s:do_test('ffcsbB', '(foo )', ['{foo }'])
  call s:do_test('ffcsbB', '( foo)', ['{ foo}'])
  call s:do_test('ffcsbB', '( foo )', ['{ foo }'])
  call s:do_test('ffcsbB', '(foo())', ['{foo()}'])
  call s:do_test('ffcsbB', '  (foo)  ', ['  {foo}  '])

  call s:do_test('csbB', '(foo)bar(baz)', ['{foo}bar(baz)'])
  call s:do_test('ffcsbB', '(foo)bar(baz)', ['{foo}bar(baz)'])
  call s:do_test('f)csbB', '(foo)bar(baz)', ['{foo}bar(baz)'])
  call s:do_test('f(csbB', '(foo)bar(baz)', ['(foo)bar{baz}'])
  call s:do_test('2fbcsbB', '(foo)bar(baz)', ['(foo)bar{baz}'])
  call s:do_test('$csbB', '(foo)bar(baz)', ['(foo)bar{baz}'])

  call s:do_test('cs"b', '""', ['()'])
  call s:do_test('cs"b', '"foo"', ['(foo)'])
  call s:do_test('cs"b', '"foo "', ['(foo )'])
  call s:do_test('cs"b', '" foo"', ['( foo)'])
  call s:do_test('cs"b', '" foo "', ['( foo )'])
  call s:do_test('cs"b', '" \"foo\" "', ['( \"foo\" )'])
  call s:do_test('cs"b', '" \\foo\\ "', ['( \\foo\\ )'])
  call s:do_test('f"cs"b', '  "foo"  ', ['  (foo)  '])

  call s:do_test('$cs"b', '""', ['()'])
  call s:do_test('$cs"b', '"foo"', ['(foo)'])
  call s:do_test('$cs"b', '"foo "', ['(foo )'])
  call s:do_test('$cs"b', '" foo"', ['( foo)'])
  call s:do_test('$cs"b', '" foo "', ['( foo )'])
  call s:do_test('$cs"b', '" \"foo\" "', ['( \"foo\" )'])
  call s:do_test('$cs"b', '" \\foo\\ "', ['( \\foo\\ )'])
  call s:do_test('2f"cs"b', '  "foo"  ', ['  (foo)  '])

  call s:do_test('ffcs"b', '"foo"', ['(foo)'])
  call s:do_test('ffcs"b', '"foo "', ['(foo )'])
  call s:do_test('ffcs"b', '" foo"', ['( foo)'])
  call s:do_test('ffcs"b', '" foo "', ['( foo )'])
  call s:do_test('ffcs"b', '" \"foo\" "', ['( \"foo\" )'])
  call s:do_test('ffcs"b', '" \\foo\\ "', ['( \\foo\\ )'])
  call s:do_test('f"cs"b', '" \"foo\" "', ['( \"foo\" )'])
  call s:do_test('2f"cs"b', '" \"foo\" "', ['( \"foo\" )'])
  call s:do_test('ffcs"b', '  "foo"  ', ['  (foo)  '])

  call s:do_test('cs"b', '"foo"bar"baz"', ['(foo)bar"baz"'])
  call s:do_test('ffcs"b', '"foo"bar"baz"', ['(foo)bar"baz"'])
  call s:do_test('f"cs"b', '"foo"bar"baz"', ['(foo)bar"baz"'])
  call s:do_test('2f"cs"b', '"foo"bar"baz"', ['"foo"bar(baz)'])
  call s:do_test('fbcs"b', '"foo"bar"baz"', ['"foo(bar)baz"'])
  call s:do_test('2fbcs"b', '"foo"bar"baz"', ['"foo"bar(baz)'])
  call s:do_test('$cs"b', '"foo"bar"baz"', ['"foo"bar(baz)'])
endfunction

function! s:test_surround_delete() abort
  call s:do_test('dsb', '()', [''])
  call s:do_test('dsb', '(foo)', ['foo'])
  call s:do_test('dsb', '(foo )', ['foo'])
  call s:do_test('dsb', '( foo)', ['foo'])
  call s:do_test('dsb', '( foo )', ['foo'])
  call s:do_test('dsb', '(foo())', ['foo()'])
  call s:do_test('f(dsb', '(foo())', ['(foo)'])
  call s:do_test('f(dsb', '  ()  ', ['    '])
  call s:do_test('f(dsb', '  (foo)  ', ['  foo  '])

  call s:do_test('$dsb', '()', [''])
  call s:do_test('$dsb', '(foo)', ['foo'])
  call s:do_test('$dsb', '(foo )', ['foo'])
  call s:do_test('$dsb', '( foo)', ['foo'])
  call s:do_test('$dsb', '( foo )', ['foo'])
  call s:do_test('$dsb', '(foo())', ['foo()'])
  call s:do_test('f)dsb', '(foo())', ['(foo)'])
  call s:do_test('f)dsb', '  ()  ', ['    '])
  call s:do_test('f)dsb', '  (foo)  ', ['  foo  '])

  call s:do_test('ffdsb', '(foo)', ['foo'])
  call s:do_test('ffdsb', '(foo )', ['foo'])
  call s:do_test('ffdsb', '( foo)', ['foo'])
  call s:do_test('ffdsb', '( foo )', ['foo'])
  call s:do_test('ffdsb', '(foo())', ['foo()'])
  call s:do_test('ffdsb', '  (foo)  ', ['  foo  '])

  call s:do_test('dsbB', '(foo)bar(baz)', ['foobar(baz)'])
  call s:do_test('ffdsbB', '(foo)bar(baz)', ['foobar(baz)'])
  call s:do_test('f)dsbB', '(foo)bar(baz)', ['foobar(baz)'])
  call s:do_test('f(dsbB', '(foo)bar(baz)', ['(foo)barbaz'])
  call s:do_test('2fbdsbB', '(foo)bar(baz)', ['(foo)barbaz'])
  call s:do_test('$dsbB', '(foo)bar(baz)', ['(foo)barbaz'])

  call s:do_test('ds"b', '""', [''])
  call s:do_test('ds"b', '"foo"', ['foo'])
  call s:do_test('ds"b', '"foo "', ['foo'])
  call s:do_test('ds"b', '" foo"', ['foo'])
  call s:do_test('ds"b', '" foo "', ['foo'])
  call s:do_test('ds"b', '" \"foo\" "', ['\"foo\"'])
  call s:do_test('ds"b', '" \\foo\\ "', ['\\foo\\'])
  call s:do_test('f"ds"b', '  "foo"  ', ['  foo  '])

  call s:do_test('$ds"b', '""', [''])
  call s:do_test('$ds"b', '"foo"', ['foo'])
  call s:do_test('$ds"b', '"foo "', ['foo'])
  call s:do_test('$ds"b', '" foo"', ['foo'])
  call s:do_test('$ds"b', '" foo "', ['foo'])
  call s:do_test('$ds"b', '" \"foo\" "', ['\"foo\"'])
  call s:do_test('$ds"b', '" \\foo\\ "', ['\\foo\\'])
  call s:do_test('2f"ds"b', '  "foo"  ', ['  foo  '])

  call s:do_test('ffds"b', '"foo"', ['foo'])
  call s:do_test('ffds"b', '"foo "', ['foo'])
  call s:do_test('ffds"b', '" foo"', ['foo'])
  call s:do_test('ffds"b', '" foo "', ['foo'])
  call s:do_test('ffds"b', '" \"foo\" "', ['\"foo\"'])
  call s:do_test('ffds"b', '" \\foo\\ "', ['\\foo\\'])
  call s:do_test('ffds"b', '  "foo"  ', ['  foo  '])

  call s:do_test('ds"b', '"foo"bar"baz"', ['foobar"baz"'])
  call s:do_test('ffds"b', '"foo"bar"baz"', ['foobar"baz"'])
  call s:do_test('f"ds"b', '"foo"bar"baz"', ['foobar"baz"'])
  call s:do_test('2f"ds"b', '"foo"bar"baz"', ['"foo"barbaz'])
  call s:do_test('fbds"b', '"foo"bar"baz"', ['"foobarbaz"'])
  call s:do_test('2fbds"b', '"foo"bar"baz"', ['"foo"barbaz'])
  call s:do_test('$ds"b', '"foo"bar"baz"', ['"foo"barbaz'])
endfunction

function! s:do_test(keys, body, expected) abort
  new
  set smarttab
  silent put =a:body
  1delete
  call cursor(1, 1)
  execute 'normal' a:keys
  call assert_equal(a:expected, getline(1, line('$')), '')
  set smarttab&
  close!
endfunction
