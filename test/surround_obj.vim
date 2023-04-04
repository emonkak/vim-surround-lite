runtime! plugin/surround_obj.vim

call surround_obj#define_built_in_objects(["'", '"', '(', ')', '{', '}', 't'])

call surround_obj#define_object('b', {
\   'type': 'alias',
\   'key': '(',
\ })

call surround_obj#define_object('u', {
\   'type': 'inline',
\   'delimiter': '_',
\   'pattern': surround_obj#make_pattern('_'),
\ })

call surround_obj#define_object('U', {
\   'type': 'inline',
\   'delimiter': '__',
\   'pattern': '__',
\ })

function! s:test_surround_add() abort
  call s:do_test('yse"', 'foo bar baz', '"foo" bar baz')
  call s:do_test('wyse"', 'foo bar baz', 'foo "bar" baz')
  call s:do_test('ys$"', 'foo bar baz', '"foo bar baz"')

  call s:do_test('yse''', 'foo bar baz', '''foo'' bar baz')
  call s:do_test('wyse''', 'foo bar baz', 'foo ''bar'' baz')
  call s:do_test('ys$''', 'foo bar baz', '''foo bar baz''')

  call s:do_test('yse(', 'foo bar baz', '(foo) bar baz')
  call s:do_test('wyse(', 'foo bar baz', 'foo (bar) baz')
  call s:do_test('ys$(', 'foo bar baz', '(foo bar baz)')
  call s:do_test('ys$(wyse(', 'foo bar baz', '((foo) bar baz)')
  call s:do_test('wyse(', '  foo', '  (foo)')

  call s:do_test('yse)', 'foo bar baz', '( foo ) bar baz')
  call s:do_test('wyse)', 'foo bar baz', 'foo ( bar ) baz')
  call s:do_test('ys$)', 'foo bar baz', '( foo bar baz )')
  call s:do_test('ys$)wyse)', 'foo bar baz', '( ( foo ) bar baz )')
  call s:do_test('wyse)', '  foo', '  ( foo )')

  call s:do_test('yseb', 'foo bar baz', '(foo) bar baz')
  call s:do_test('wyseb', 'foo bar baz', 'foo (bar) baz')
  call s:do_test('ys$b', 'foo bar baz', '(foo bar baz)')
  call s:do_test('ys$(wyseb', 'foo bar baz', '((foo) bar baz)')
  call s:do_test('wyseb', '  foo', '  (foo)')

  call s:do_test("ysetdiv\<CR>", 'foo bar baz', '<div>foo</div> bar baz')
  call s:do_test("wysetdiv\<CR>", 'foo bar baz', 'foo <div>bar</div> baz')
  call s:do_test("ys$tdiv\<CR>", 'foo bar baz', '<div>foo bar baz</div>')
  call s:do_test("ys$tdiv\<CR>wysetp\<CR>", 'foo bar baz', '<div><p>foo</p> bar baz</div>')
  call s:do_test("wysetdiv\<CR>", '  foo', '  <div>foo</div>')

  call s:do_test('ys$f', 'foo', 'function() { foo }', function('s:setup_local_function_object'))
  call s:do_test('ys$f', 'foo', 'foo')

  call s:do_test('ys$(..', '', '((()))')
  call s:do_test('ys$(..', 'foo', '(((foo)))')
endfunction

function! s:test_surround_change() abort
  call s:do_test('cs"(', '""', '()')
  call s:do_test('cs"(', '"foo"', '(foo)')
  call s:do_test('cs"(', '"foo "', '(foo )')
  call s:do_test('cs"(', '" foo"', '( foo)')
  call s:do_test('cs"(', '" foo "', '( foo )')
  call s:do_test('cs"(', '" \"foo\" "', '( \"foo\" )')
  call s:do_test('cs"(', '" \foo\ "', '( \foo\ )')
  call s:do_test('f"cs"(', '  "foo"  ', '  (foo)  ')

  call s:do_test('$cs"(', '""', '()')
  call s:do_test('$cs"(', '"foo"', '(foo)')
  call s:do_test('$cs"(', '"foo "', '(foo )')
  call s:do_test('$cs"(', '" foo"', '( foo)')
  call s:do_test('$cs"(', '" foo "', '( foo )')
  call s:do_test('$cs"(', '" \"foo\" "', '( \"foo\" )')
  call s:do_test('$cs"(', '" \foo\ "', '( \foo\ )')
  call s:do_test('2f"cs"(', '  "foo"  ', '  (foo)  ')

  call s:do_test('ffcs"(', '"foo"', '(foo)')
  call s:do_test('ffcs"(', '"foo "', '(foo )')
  call s:do_test('ffcs"(', '" foo"', '( foo)')
  call s:do_test('ffcs"(', '" foo "', '( foo )')
  call s:do_test('ffcs"(', '" \"foo\" "', '( \"foo\" )')
  call s:do_test('ffcs"(', '" \foo\ "', '( \foo\ )')
  call s:do_test('f"cs"(', '" \"foo\" "', '( \"foo\" )')
  call s:do_test('2f"cs"(', '" \"foo\" "', '( \"foo\" )')
  call s:do_test('ffcs"(', '  "foo"  ', '  (foo)  ')

  call s:do_test('cs"(', '"foo"bar"baz"', '(foo)bar"baz"')
  call s:do_test('ffcs"(', '"foo"bar"baz"', '(foo)bar"baz"')
  call s:do_test('f"cs"(', '"foo"bar"baz"', '(foo)bar"baz"')
  call s:do_test('2f"cs"(', '"foo"bar"baz"', '"foo"bar(baz)')
  call s:do_test('fbcs"(', '"foo"bar"baz"', '"foo(bar)baz"')
  call s:do_test('2fbcs"(', '"foo"bar"baz"', '"foo"bar(baz)')
  call s:do_test('$cs"(', '"foo"bar"baz"', '"foo"bar(baz)')

  call s:do_test('cs({', '()', '{}')
  call s:do_test('cs({', '(foo)', '{foo}')
  call s:do_test('cs({', '(foo )', '{foo }')
  call s:do_test('cs({', '( foo)', '{ foo}')
  call s:do_test('cs({', '( foo )', '{ foo }')
  call s:do_test('cs({', '(foo())', '{foo()}')
  call s:do_test('f(cs({', '(foo())', '(foo{})')
  call s:do_test('f(cs({', '  ()  ', '  {}  ')
  call s:do_test('f(cs({', '  (foo)  ', '  {foo}  ')

  call s:do_test('$cs({', '()', '{}')
  call s:do_test('$cs({', '(foo )', '{foo }')
  call s:do_test('$cs({', '( foo)', '{ foo}')
  call s:do_test('$cs({', '( foo )', '{ foo }')
  call s:do_test('$cs({', '(foo())', '{foo()}')
  call s:do_test('f)cs({', '(foo())', '(foo{})')
  call s:do_test('f)cs({', '  ()  ', '  {}  ')
  call s:do_test('f)cs({', '  (foo)  ', '  {foo}  ')

  call s:do_test('ffcs({', '(foo)', '{foo}')
  call s:do_test('ffcs({', '(foo )', '{foo }')
  call s:do_test('ffcs({', '( foo)', '{ foo}')
  call s:do_test('ffcs({', '( foo )', '{ foo }')
  call s:do_test('ffcs({', '(foo())', '{foo()}')
  call s:do_test('ffcs({', '  (foo)  ', '  {foo}  ')

  call s:do_test('cs({', '(foo)bar(baz)', '{foo}bar(baz)')
  call s:do_test('ffcs({', '(foo)bar(baz)', '{foo}bar(baz)')
  call s:do_test('f)cs({', '(foo)bar(baz)', '{foo}bar(baz)')
  call s:do_test('f(cs({', '(foo)bar(baz)', '(foo)bar{baz}')
  call s:do_test('2fbcs({', '(foo)bar(baz)', '(foo)bar{baz}')
  call s:do_test('$cs({', '(foo)bar(baz)', '(foo)bar{baz}')

  call s:do_test('cs({', '( \(foo )', '{ \(foo }')
  call s:do_test('cs({', '( foo\) )', '{ foo\) }')
  call s:do_test('cs({', '( \(foo\) )', '{ \(foo\) }')

  call s:do_test('cs({', "(\na)", "{\na}")
  call s:do_test('cs({', "(a\n)", "{a\n}")
  call s:do_test('cs({', "((\na))", "{(\na)}")
  call s:do_test('cs({', "((a\n))", "{(a\n)}")

  call s:do_test('cs)b', '( foo )', '(foo)')
  call s:do_test('cs)b', '(  foo  )', '(foo)')
  call s:do_test('cs)b', '( foo)', '(foo)')
  call s:do_test('cs)b', '(foo )', '(foo)')
  call s:do_test('cs)b', '(foo)', '(foo)')

  call s:do_test('csb)', '( foo )', '(  foo  )')
  call s:do_test('csb)', '(  foo  )', '(   foo   )')
  call s:do_test('csb)', '( foo)', '(  foo )')
  call s:do_test('csb)', '(foo )', '( foo  )')
  call s:do_test('csb)', '(foo)', '( foo )')

  call s:do_test('cs)}', '( foo )', '{ foo }')
  call s:do_test('cs)}', '(  foo  )', '{ foo }')
  call s:do_test('cs)}', '( foo)', '{ foo }')
  call s:do_test('cs)}', '(foo )', '{ foo }')
  call s:do_test('cs)}', '(foo)', '{ foo }')

  call s:do_test("csttp\<CR>", '<div></div>', '<p></p>')
  call s:do_test("csttp\<CR>", '<div>foo</div>', '<p>foo</p>')
  call s:do_test("csttp\<CR>", '<div>foo </div>', '<p>foo </p>')
  call s:do_test("csttp\<CR>", '<div> foo</div>', '<p> foo</p>')
  call s:do_test("csttp\<CR>", '<div> foo </div>', '<p> foo </p>')
  call s:do_test("csttp\<CR>", '<div>foo<b>bar</b></div>', '<p>foo<b>bar</b></p>')
  call s:do_test("f<cstti\<CR>", '<div>foo<b>bar</b></div>', '<div>foo<i>bar</i></div>')
  call s:do_test("f<csttp\<CR>", '  <div></div>  ', '  <p></p>  ')
  call s:do_test("f<csttp\<CR>", '  <div>foo</div>  ', '  <p>foo</p>  ')

  call s:do_test("f>csttp\<CR>", '<div></div>', '<p></p>')
  call s:do_test("f>csttp\<CR>", '<div>foo</div>', '<p>foo</p>')
  call s:do_test("f>csttp\<CR>", '<div>foo </div>', '<p>foo </p>')
  call s:do_test("f>csttp\<CR>", '<div> foo</div>', '<p> foo</p>')
  call s:do_test("f>csttp\<CR>", '<div> foo </div>', '<p> foo </p>')
  call s:do_test("f>csttp\<CR>", '<div>foo<b>bar</b></div>', '<p>foo<b>bar</b></p>')
  call s:do_test("2f>cstti\<CR>", '<div>foo<b>bar</b></div>', '<div>foo<i>bar</i></div>')
  call s:do_test("f>csttp\<CR>", '  <div></div>  ', '  <p></p>  ')
  call s:do_test("f>csttp\<CR>", '  <div>foo</div>  ', '  <p>foo</p>  ')

  call s:do_test("f<csttp\<CR>", '<div></div>', '<p></p>')
  call s:do_test("f<csttp\<CR>", '<div>foo</div>', '<p>foo</p>')
  call s:do_test("f<csttp\<CR>", '<div>foo </div>', '<p>foo </p>')
  call s:do_test("f<csttp\<CR>", '<div> foo</div>', '<p> foo</p>')
  call s:do_test("f<csttp\<CR>", '<div> foo </div>', '<p> foo </p>')
  call s:do_test("3f<csttp\<CR>", '<div>foo<b>bar</b></div>', '<p>foo<b>bar</b></p>')
  call s:do_test("f<cstti\<CR>", '<div>foo<b>bar</b></div>', '<div>foo<i>bar</i></div>')
  call s:do_test("f<csttp\<CR>", '  <div></div>  ', '  <p></p>  ')
  call s:do_test("f<csttp\<CR>", '  <div>foo</div>  ', '  <p>foo</p>  ')

  call s:do_test("$csttp\<CR>", '<div></div>', '<p></p>')
  call s:do_test("$csttp\<CR>", '<div>foo</div>', '<p>foo</p>')
  call s:do_test("$csttp\<CR>", '<div>foo </div>', '<p>foo </p>')
  call s:do_test("$csttp\<CR>", '<div> foo</div>', '<p> foo</p>')
  call s:do_test("$csttp\<CR>", '<div> foo </div>', '<p> foo </p>')
  call s:do_test("$csttp\<CR>", '<div>foo<b>bar</b></div>', '<p>foo<b>bar</b></p>')
  call s:do_test("2f>cstti\<CR>", '<div>foo<b>bar</b></div>', '<div>foo<i>bar</i></div>')
  call s:do_test("2f>csttp\<CR>", '  <div></div>  ', '  <p></p>  ')
  call s:do_test("2f>csttp\<CR>", '  <div>foo</div>  ', '  <p>foo</p>  ')

  call s:do_test('cs(f', '(foo)', 'function() { foo }', function('s:setup_local_function_object'))
  call s:do_test('cs(f', '(foo)', '(foo)')
  call s:do_test('csf(', 'function() { foo }', '(foo)', function('s:setup_local_function_object'))
  call s:do_test('csf(', 'function() { foo }', 'function() { foo }')

  call s:do_test('f)cs({..', '((()))', '{{{}}}')
  call s:do_test('f)cs({..', '(((foo)))', '{{{foo}}}')
endfunction

function! s:test_surround_delete() abort
  call s:do_test('ds"', '""', '')
  call s:do_test('ds"', '"foo"', 'foo')
  call s:do_test('ds"', '"foo "', 'foo ')
  call s:do_test('ds"', '" foo"', ' foo')
  call s:do_test('ds"', '" foo "', ' foo ')
  call s:do_test('ds"', '" \"foo\" "', ' \"foo\" ')
  call s:do_test('ds"', '" \foo\ "', ' \foo\ ')
  call s:do_test('f"ds"', '  "foo"  ', '  foo  ')

  call s:do_test('$ds"', '""', '')
  call s:do_test('$ds"', '"foo"', 'foo')
  call s:do_test('$ds"', '"foo "', 'foo ')
  call s:do_test('$ds"', '" foo"', ' foo')
  call s:do_test('$ds"', '" foo "', ' foo ')
  call s:do_test('$ds"', '" \"foo\" "', ' \"foo\" ')
  call s:do_test('$ds"', '" \foo\ "', ' \foo\ ')
  call s:do_test('2f"ds"', '  "foo"  ', '  foo  ')

  call s:do_test('ffds"', '"foo"', 'foo')
  call s:do_test('ffds"', '"foo "', 'foo ')
  call s:do_test('ffds"', '" foo"', ' foo')
  call s:do_test('ffds"', '" foo "', ' foo ')
  call s:do_test('ffds"', '" \"foo\" "', ' \"foo\" ')
  call s:do_test('ffds"', '" \foo\ "', ' \foo\ ')
  call s:do_test('ffds"', '  "foo"  ', '  foo  ')

  call s:do_test('ds"', '"foo"bar"baz"', 'foobar"baz"')
  call s:do_test('ffds"', '"foo"bar"baz"', 'foobar"baz"')
  call s:do_test('f"ds"', '"foo"bar"baz"', 'foobar"baz"')
  call s:do_test('2f"ds"', '"foo"bar"baz"', '"foo"barbaz')
  call s:do_test('fbds"', '"foo"bar"baz"', '"foobarbaz"')
  call s:do_test('2fbds"', '"foo"bar"baz"', '"foo"barbaz')
  call s:do_test('$ds"', '"foo"bar"baz"', '"foo"barbaz')

  call s:do_test('ds(', '()', '')
  call s:do_test('ds(', '(foo)', 'foo')
  call s:do_test('ds(', '(foo )', 'foo ')
  call s:do_test('ds(', '( foo)', ' foo')
  call s:do_test('ds(', '( foo )', ' foo ')
  call s:do_test('ds(', '(foo())', 'foo()')
  call s:do_test('f(ds(', '(foo())', '(foo)')
  call s:do_test('f(ds(', '  ()  ', '    ')
  call s:do_test('f(ds(', '  (foo)  ', '  foo  ')

  call s:do_test('ds)', '()', '')
  call s:do_test('ds)', '(foo)', 'foo')
  call s:do_test('ds)', '(foo )', 'foo')
  call s:do_test('ds)', '( foo)', 'foo')
  call s:do_test('ds)', '( foo )', 'foo')
  call s:do_test('ds)', '(foo())', 'foo()')
  call s:do_test('f(ds)', '(foo())', '(foo)')
  call s:do_test('f(ds)', '  ()  ', '    ')
  call s:do_test('f(ds)', '  (foo)  ', '  foo  ')

  call s:do_test('dsb', '()', '')
  call s:do_test('dsb', '(foo)', 'foo')
  call s:do_test('dsb', '(foo )', 'foo ')
  call s:do_test('dsb', '( foo)', ' foo')
  call s:do_test('dsb', '( foo )', ' foo ')
  call s:do_test('dsb', '(foo())', 'foo()')
  call s:do_test('f(dsb', '(foo())', '(foo)')
  call s:do_test('f(dsb', '  ()  ', '    ')
  call s:do_test('f(dsb', '  (foo)  ', '  foo  ')

  call s:do_test('ds(', '( \(foo )', ' \(foo ')
  call s:do_test('ds(', '( foo\) )', ' foo\) ')
  call s:do_test('ds(', '( \(foo\) )', ' \(foo\) ')

  call s:do_test('ds(', "(\na)", "\na")
  call s:do_test('ds(', "(a\n)", "a\n")
  call s:do_test('ds(', "((\na))", "(\na)")
  call s:do_test('ds(', "((a\n))", "(a\n)")

  call s:do_test('$ds(', '()', '')
  call s:do_test('$ds(', '(foo)', 'foo')
  call s:do_test('$ds(', '(foo )', 'foo ')
  call s:do_test('$ds(', '( foo)', ' foo')
  call s:do_test('$ds(', '( foo )', ' foo ')
  call s:do_test('$ds(', '(foo())', 'foo()')
  call s:do_test('f)ds(', '(foo())', '(foo)')
  call s:do_test('f)ds(', '  ()  ', '    ')
  call s:do_test('f)ds(', '  (foo)  ', '  foo  ')

  call s:do_test('ffds(', '(foo)', 'foo')
  call s:do_test('ffds(', '(foo )', 'foo ')
  call s:do_test('ffds(', '( foo)', ' foo')
  call s:do_test('ffds(', '( foo )', ' foo ')
  call s:do_test('ffds(', '(foo())', 'foo()')
  call s:do_test('ffds(', '  (foo)  ', '  foo  ')

  call s:do_test('ds(', '(foo)bar(baz)', 'foobar(baz)')
  call s:do_test('ffds(', '(foo)bar(baz)', 'foobar(baz)')
  call s:do_test('f)ds(', '(foo)bar(baz)', 'foobar(baz)')
  call s:do_test('f(ds(', '(foo)bar(baz)', '(foo)barbaz')
  call s:do_test('2fbds(', '(foo)bar(baz)', '(foo)barbaz')
  call s:do_test('$ds(', '(foo)bar(baz)', '(foo)barbaz')

  call s:do_test('dst', '<div></div>', '')
  call s:do_test('dst', '<div>foo</div>', 'foo')
  call s:do_test('dst', '<div>foo </div>', 'foo ')
  call s:do_test('dst', '<div> foo</div>', ' foo')
  call s:do_test('dst', '<div> foo </div>', ' foo ')
  call s:do_test('dst', '<div>foo<b>bar</b></div>', 'foo<b>bar</b>')
  call s:do_test('f<dst', '<div>foo<b>bar</b></div>', '<div>foobar</div>')
  call s:do_test('f<dst', '  <div></div>  ', '    ')
  call s:do_test('f<dst', '  <div>foo</div>  ', '  foo  ')

  call s:do_test('f>dst', '<div></div>', '')
  call s:do_test('f>dst', '<div>foo</div>', 'foo')
  call s:do_test('f>dst', '<div>foo </div>', 'foo ')
  call s:do_test('f>dst', '<div> foo</div>', ' foo')
  call s:do_test('f>dst', '<div> foo </div>', ' foo ')
  call s:do_test('f>dst', '<div>foo<b>bar</b></div>', 'foo<b>bar</b>')
  call s:do_test('2f>dst', '<div>foo<b>bar</b></div>', '<div>foobar</div>')
  call s:do_test('f>dst', '  <div></div>  ', '    ')
  call s:do_test('f>dst', '  <div>foo</div>  ', '  foo  ')

  call s:do_test('f<dst', '<div></div>', '')
  call s:do_test('f<dst', '<div>foo</div>', 'foo')
  call s:do_test('f<dst', '<div>foo </div>', 'foo ')
  call s:do_test('f<dst', '<div> foo</div>', ' foo')
  call s:do_test('f<dst', '<div> foo </div>', ' foo ')
  call s:do_test('3f<dst', '<div>foo<b>bar</b></div>', 'foo<b>bar</b>')
  call s:do_test('2f<dst', '<div>foo<b>bar</b></div>', '<div>foobar</div>')
  call s:do_test('2f<dst', '  <div></div>  ', '    ')
  call s:do_test('2f<dst', '  <div>foo</div>  ', '  foo  ')

  call s:do_test('$dst', '<div></div>', '')
  call s:do_test('$dst', '<div>foo</div>', 'foo')
  call s:do_test('$dst', '<div>foo </div>', 'foo ')
  call s:do_test('$dst', '<div> foo</div>', ' foo')
  call s:do_test('$dst', '<div> foo </div>', ' foo ')
  call s:do_test('$dst', '<div>foo<b>bar</b></div>', 'foo<b>bar</b>')
  call s:do_test('3f>dst', '<div>foo<b>bar</b></div>', '<div>foobar</div>')
  call s:do_test('2f>dst', '  <div></div>  ', '    ')

  call s:do_test("/foo\<CR>dst", '<div>foo</div>', 'foo')
  call s:do_test("/foo\<CR>dst", '<div>foo </div>', 'foo ')
  call s:do_test("/foo\<CR>dst", '<div> foo</div>', ' foo')
  call s:do_test("/foo\<CR>dst", '<div> foo </div>', ' foo ')
  call s:do_test("/foo\<CR>dst", '<div>foo<b>bar</b></div>', 'foo<b>bar</b>')
  call s:do_test("/bar\<CR>dst", '<div>foo<b>bar</b></div>', '<div>foobar</div>')
  call s:do_test("/foo\<CR>dst", '  <div>foo</div>  ', '  foo  ')

  call s:do_test('dsf', 'function() { foo }', 'foo', function('s:setup_local_function_object'))
  call s:do_test('dsf', 'function() { foo }', 'function() { foo }')

  call s:do_test('ds(..', '((()))', '')
  call s:do_test('ds(..', '(((foo)))', 'foo')
endfunction

function! s:test_surround_textobj() abort
  call s:do_test("d\<Plug>(surround-obj-a:u)", '_A_', '')
  call s:do_test("$d\<Plug>(surround-obj-a:u)", '_A_', '')
  call s:do_test("d\<Plug>(surround-obj-a:u)", ' _A_ ', ' _A_ ')
  call s:do_test("$d\<Plug>(surround-obj-a:u)", ' _A_ ', ' _A_ ')
  call s:do_test("fAd\<Plug>(surround-obj-a:u)", ' _A_ ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:u)", '_A__B_', '_B_')
  call s:do_test("$d\<Plug>(surround-obj-a:u)", '_A__B_', '_A_')
  call s:do_test("fAd\<Plug>(surround-obj-a:u)", '_A__B_', '_B_')
  call s:do_test("fBd\<Plug>(surround-obj-a:u)", '_A__B_', '_A_')

  call s:do_test("d\<Plug>(surround-obj-i:u)", '_A_', '__')
  call s:do_test("$d\<Plug>(surround-obj-i:u)", '_A_', '__')
  call s:do_test("d\<Plug>(surround-obj-i:u)", ' _A_ ', ' _A_ ')
  call s:do_test("$d\<Plug>(surround-obj-i:u)", ' _A_ ', ' _A_ ')
  call s:do_test("fAd\<Plug>(surround-obj-i:u)", ' _A_ ', ' __ ')
  call s:do_test("d\<Plug>(surround-obj-i:u)", '_A__B_', '___B_')
  call s:do_test("$d\<Plug>(surround-obj-i:u)", '_A__B_', '_A___')
  call s:do_test("fAd\<Plug>(surround-obj-i:u)", '_A__B_', '___B_')
  call s:do_test("fBd\<Plug>(surround-obj-i:u)", '_A__B_', '_A___')

  call s:do_test("d\<Plug>(surround-obj-a:U)", '__A__', '')
  call s:do_test("$d\<Plug>(surround-obj-a:U)", '__A__', '')
  call s:do_test("d\<Plug>(surround-obj-a:U)", ' __A__ ', ' __A__ ')
  call s:do_test("$d\<Plug>(surround-obj-a:U)", ' __A__ ', ' __A__ ')
  call s:do_test("fAd\<Plug>(surround-obj-a:U)", ' __A__ ', '  ')

  call s:do_test("d\<Plug>(surround-obj-i:U)", '__A__', '____')
  call s:do_test("$d\<Plug>(surround-obj-i:U)", '__A__', '____')
  call s:do_test("d\<Plug>(surround-obj-i:U)", ' __A__ ', ' __A__ ')
  call s:do_test("$d\<Plug>(surround-obj-i:U)", ' __A__ ', ' __A__ ')
  call s:do_test("fAd\<Plug>(surround-obj-i:U)", ' __A__ ', ' ____ ')

  call s:do_test("d\<Plug>(surround-obj-a:t)", '<div>A</div>', '')
  call s:do_test("$d\<Plug>(surround-obj-a:t)", '<div>A</div>', '')
  call s:do_test("d\<Plug>(surround-obj-a:t)", ' <div>A</div> ', ' <div>A</div> ')
  call s:do_test("$d\<Plug>(surround-obj-a:t)", ' <div>A</div> ', ' <div>A</div> ')
  call s:do_test("fAd\<Plug>(surround-obj-a:t)", ' <div>A</div> ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:t)", '<div>A<div>B</div>C</div>', '')
  call s:do_test("$d\<Plug>(surround-obj-a:t)", '<div>A<div>B</div>C</div>', '')
  call s:do_test("fAd\<Plug>(surround-obj-a:t)", '<div>A<div>B</div>C</div>', '')
  call s:do_test("fBd\<Plug>(surround-obj-a:t)", '<div>A<div>B</div>C</div>', '<div>AC</div>')
  call s:do_test("fCd\<Plug>(surround-obj-a:t)", '<div>A<div>B</div>C</div>', '')

  call s:do_test("d\<Plug>(surround-obj-i:t)", '<div>A</div>', '<div></div>')
  call s:do_test("$d\<Plug>(surround-obj-i:t)", '<div>A</div>', '<div></div>')
  call s:do_test("d\<Plug>(surround-obj-i:t)", ' <div>A</div> ', ' <div>A</div> ')
  call s:do_test("$d\<Plug>(surround-obj-i:t)", ' <div>A</div> ', ' <div>A</div> ')
  call s:do_test("fAd\<Plug>(surround-obj-i:t)", ' <div>A</div> ', ' <div></div> ')
  call s:do_test("d\<Plug>(surround-obj-i:t)", '<div>A<div>B</div>C</div>', '<div></div>')
  call s:do_test("$d\<Plug>(surround-obj-i:t)", '<div>A<div>B</div>C</div>', '<div></div>')
  call s:do_test("fAd\<Plug>(surround-obj-i:t)", '<div>A<div>B</div>C</div>', '<div></div>')
  call s:do_test("fBd\<Plug>(surround-obj-i:t)", '<div>A<div>B</div>C</div>', '<div>A<div></div>C</div>')
  call s:do_test("fCd\<Plug>(surround-obj-i:t)", '<div>A<div>B</div>C</div>', '<div></div>')

  call s:do_test("d\<Plug>(surround-obj-i:f)", 'function() { foo }', 'function() {  }', function('s:setup_local_function_object'))
  call s:do_test("$d\<Plug>(surround-obj-i:f)", 'function() { foo }', 'function() {  }', function('s:setup_local_function_object'))
  call s:do_test("d\<Plug>(surround-obj-a:f)", 'function() { foo }', '', function('s:setup_local_function_object'))
  call s:do_test("$d\<Plug>(surround-obj-a:f)", 'function() { foo }', '', function('s:setup_local_function_object'))
endfunction

function! s:do_test(key_sequence, source, expected_result, ...) abort
  new
  try 
    map <buffer> ys  <Plug>(surround-obj-add)
    nmap <buffer> cs  <Plug>(surround-obj-change)
    nmap <buffer> ds  <Plug>(surround-obj-delete)
    if a:0 > 0
      call a:1()
    endif
    silent put =a:source
    normal! ggdd0
    0verbose call feedkeys(a:key_sequence, 'x')
    call assert_equal(a:expected_result, join(getline(1, line('$')), "\n"))
  finally
    close!
  endtry
endfunction

function! s:setup_local_function_object() abort
  call surround_obj#define_local_object('f', {
  \   'type': 'block',
  \   'delimiter': ['function() { ', ' }'],
  \   'pattern': ['\<function\s*(\s*)\s*{\s*', '\s*}'],
  \ })
endfunction
