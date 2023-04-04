runtime! plugin/surround_obj.vim

call surround_obj#define_built_in_objects([
\   "'",
\   '"',
\   '(',
\   ')',
\   '{',
\   '}',
\   'b',
\   'f',
\   't'
\ ])

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
  call s:do_test('ysl"', 'A B C', '"A" B C')
  call s:do_test('fBysl"', 'A B C', 'A "B" C')
  call s:do_test('fCysl"', 'A B C', 'A B "C"')
  call s:do_test('ys$"', 'A B C', '"A B C"')

  call s:do_test("ysl'", 'A B C', "'A' B C")
  call s:do_test("fBysl'", 'A B C', "A 'B' C")
  call s:do_test("fCysl'", 'A B C', "A B 'C'")
  call s:do_test("ys$'", 'A B C', "'A B C'")

  call s:do_test('ysl(', 'A B C', '(A) B C')
  call s:do_test('fBysl(', 'A B C', 'A (B) C')
  call s:do_test('fCysl(', 'A B C', 'A B (C)')
  call s:do_test('ys$(', 'A B C', '(A B C)')

  call s:do_test('ysl)', 'A B C', '( A ) B C')
  call s:do_test('fBysl)', 'A B C', 'A ( B ) C')
  call s:do_test('fCysl)', 'A B C', 'A B ( C )')
  call s:do_test('ys$)', 'A B C', '( A B C )')

  call s:do_test("ysltdiv\<CR>", 'A B C', '<div>A</div> B C')
  call s:do_test("fBysltdiv\<CR>", 'A B C', 'A <div>B</div> C')
  call s:do_test("fCysltdiv\<CR>", 'A B C', 'A B <div>C</div>')
  call s:do_test("ys$tdiv\<CR>", 'A B C', '<div>A B C</div>')

  call s:do_test("yslff\<CR>", 'A B C', 'f(A) B C')
  call s:do_test("fByslff\<CR>", 'A B C', 'A f(B) C')
  call s:do_test("fCyslff\<CR>", 'A B C', 'A B f(C)')
  call s:do_test("ys$ff\<CR>", 'A B C', 'f(A B C)')

  call s:do_test("yslff\<CR>", 'A B C', 'function() { A } B C', function('s:setup_js_function_object'))
  call s:do_test("fByslff\<CR>", 'A B C', 'A function() { B } C', function('s:setup_js_function_object'))
  call s:do_test("fCyslff\<CR>", 'A B C', 'A B function() { C }', function('s:setup_js_function_object'))
  call s:do_test("ys$ff\<CR>", 'A B C', 'function() { A B C }', function('s:setup_js_function_object'))

  call s:do_test('ys$(.', 'A', '((A))')
  call s:do_test('ys$(..', 'A', '(((A)))')
  call s:do_test('ys$(...', 'A', '((((A))))')
endfunction

function! s:test_surround_change() abort
  call s:do_test('cs"(', '""', '()')
  call s:do_test('cs"(', '"A"', '(A)')
  call s:do_test('cs"(', '"A "', '(A )')
  call s:do_test('cs"(', '" A"', '( A)')
  call s:do_test('cs"(', '" A "', '( A )')
  call s:do_test('cs"(', '" \"A\" "', '( \"A\" )')
  call s:do_test('cs"(', '" \A\ "', '( \A\ )')
  call s:do_test('f"cs"(', '  "A"  ', '  (A)  ')

  call s:do_test('$cs"(', '""', '()')
  call s:do_test('$cs"(', '"A"', '(A)')
  call s:do_test('$cs"(', '"A "', '(A )')
  call s:do_test('$cs"(', '" A"', '( A)')
  call s:do_test('$cs"(', '" A "', '( A )')
  call s:do_test('$cs"(', '" \"A\" "', '( \"A\" )')
  call s:do_test('$cs"(', '" \A\ "', '( \A\ )')
  call s:do_test('2f"cs"(', '  "A"  ', '  (A)  ')

  call s:do_test('fAcs"(', '"A"', '(A)')
  call s:do_test('fAcs"(', '"A "', '(A )')
  call s:do_test('fAcs"(', '" A"', '( A)')
  call s:do_test('fAcs"(', '" A "', '( A )')
  call s:do_test('fAcs"(', '" \"A\" "', '( \"A\" )')
  call s:do_test('fAcs"(', '" \A\ "', '( \A\ )')
  call s:do_test('f"cs"(', '" \"A\" "', '( \"A\" )')
  call s:do_test('2f"cs"(', '" \"A\" "', '( \"A\" )')
  call s:do_test('fAcs"(', '  "A"  ', '  (A)  ')

  call s:do_test('cs"(', '"A"B"C"', '(A)B"C"')
  call s:do_test('fAcs"(', '"A"B"C"', '(A)B"C"')
  call s:do_test('fBcs"(', '"A"B"C"', '"A(B)C"')
  call s:do_test('fCcs"(', '"A"B"C"', '"A"B(C)')
  call s:do_test('f"cs"(', '"A"B"C"', '(A)B"C"')
  call s:do_test('2f"cs"(', '"A"B"C"', '"A"B(C)')
  call s:do_test('3f"cs"(', '"A"B"C"', '"A"B(C)')

  call s:do_test('cs({', '()', '{}')
  call s:do_test('cs({', '(A)', '{A}')
  call s:do_test('cs({', '(A )', '{A }')
  call s:do_test('cs({', '( A)', '{ A}')
  call s:do_test('cs({', '( A )', '{ A }')
  call s:do_test('cs({', '(A())', '{A()}')
  call s:do_test('f(cs({', '(A())', '(A{})')
  call s:do_test('f(cs({', '  ()  ', '  {}  ')
  call s:do_test('f(cs({', '  (A)  ', '  {A}  ')

  call s:do_test('$cs({', '()', '{}')
  call s:do_test('$cs({', '(A )', '{A }')
  call s:do_test('$cs({', '( A)', '{ A}')
  call s:do_test('$cs({', '( A )', '{ A }')
  call s:do_test('$cs({', '(A())', '{A()}')
  call s:do_test('f)cs({', '(A())', '(A{})')
  call s:do_test('f)cs({', '  ()  ', '  {}  ')
  call s:do_test('f)cs({', '  (A)  ', '  {A}  ')

  call s:do_test('fAcs({', '(A)', '{A}')
  call s:do_test('fAcs({', '(A )', '{A }')
  call s:do_test('fAcs({', '( A)', '{ A}')
  call s:do_test('fAcs({', '( A )', '{ A }')
  call s:do_test('fAcs({', '(A())', '{A()}')
  call s:do_test('fAcs({', '  (A)  ', '  {A}  ')

  call s:do_test('cs({', '(A)B(C)', '{A}B(C)')
  call s:do_test('fAcs({', '(A)B(C)', '{A}B(C)')
  call s:do_test('fCcs({', '(A)B(C)', '(A)B{C}')
  call s:do_test('f)cs({', '(A)B(C)', '{A}B(C)')
  call s:do_test('f(cs({', '(A)B(C)', '(A)B{C}')
  call s:do_test('$cs({', '(A)B(C)', '(A)B{C}')

  call s:do_test('cs({', '( \(A )', '{ \(A }')
  call s:do_test('cs({', '( A\) )', '{ A\) }')
  call s:do_test('cs({', '( \(A\) )', '{ \(A\) }')

  call s:do_test('cs({', "(\nA)", "{\nA}")
  call s:do_test('cs({', "(A\n)", "{A\n}")
  call s:do_test('cs({', "((\nA))", "{(\nA)}")
  call s:do_test('cs({', "((A\n))", "{(A\n)}")

  call s:do_test('cs)b', '( A )', '(A)')
  call s:do_test('cs)b', '(  A  )', '(A)')
  call s:do_test('cs)b', '( A)', '(A)')
  call s:do_test('cs)b', '(A )', '(A)')
  call s:do_test('cs)b', '(A)', '(A)')

  call s:do_test('csb)', '( A )', '(  A  )')
  call s:do_test('csb)', '(  A  )', '(   A   )')
  call s:do_test('csb)', '( A)', '(  A )')
  call s:do_test('csb)', '(A )', '( A  )')
  call s:do_test('csb)', '(A)', '( A )')

  call s:do_test('cs)}', '( A )', '{ A }')
  call s:do_test('cs)}', '(  A  )', '{ A }')
  call s:do_test('cs)}', '( A)', '{ A }')
  call s:do_test('cs)}', '(A )', '{ A }')
  call s:do_test('cs)}', '(A)', '{ A }')

  call s:do_test("csttp\<CR>", '<div></div>', '<p></p>')
  call s:do_test("csttp\<CR>", '<div>A</div>', '<p>A</p>')
  call s:do_test("csttp\<CR>", '<div>A </div>', '<p>A </p>')
  call s:do_test("csttp\<CR>", '<div> A</div>', '<p> A</p>')
  call s:do_test("csttp\<CR>", '<div> A </div>', '<p> A </p>')
  call s:do_test("csttp\<CR>", '<div>A<b>B</b></div>', '<p>A<b>B</b></p>')
  call s:do_test("f<cstti\<CR>", '<div>A<b>B</b></div>', '<div>A<i>B</i></div>')
  call s:do_test("f<csttp\<CR>", '  <div></div>  ', '  <p></p>  ')
  call s:do_test("f<csttp\<CR>", '  <div>A</div>  ', '  <p>A</p>  ')

  call s:do_test("f>csttp\<CR>", '<div></div>', '<p></p>')
  call s:do_test("f>csttp\<CR>", '<div>A</div>', '<p>A</p>')
  call s:do_test("f>csttp\<CR>", '<div>A </div>', '<p>A </p>')
  call s:do_test("f>csttp\<CR>", '<div> A</div>', '<p> A</p>')
  call s:do_test("f>csttp\<CR>", '<div> A </div>', '<p> A </p>')
  call s:do_test("f>csttp\<CR>", '<div>A<b>B</b></div>', '<p>A<b>B</b></p>')
  call s:do_test("2f>cstti\<CR>", '<div>A<b>B</b></div>', '<div>A<i>B</i></div>')
  call s:do_test("f>csttp\<CR>", '  <div></div>  ', '  <p></p>  ')
  call s:do_test("f>csttp\<CR>", '  <div>A</div>  ', '  <p>A</p>  ')

  call s:do_test("f<csttp\<CR>", '<div></div>', '<p></p>')
  call s:do_test("f<csttp\<CR>", '<div>A</div>', '<p>A</p>')
  call s:do_test("f<csttp\<CR>", '<div>A </div>', '<p>A </p>')
  call s:do_test("f<csttp\<CR>", '<div> A</div>', '<p> A</p>')
  call s:do_test("f<csttp\<CR>", '<div> A </div>', '<p> A </p>')
  call s:do_test("3f<csttp\<CR>", '<div>A<b>B</b></div>', '<p>A<b>B</b></p>')
  call s:do_test("f<cstti\<CR>", '<div>A<b>B</b></div>', '<div>A<i>B</i></div>')
  call s:do_test("f<csttp\<CR>", '  <div></div>  ', '  <p></p>  ')
  call s:do_test("f<csttp\<CR>", '  <div>A</div>  ', '  <p>A</p>  ')

  call s:do_test("$csttp\<CR>", '<div></div>', '<p></p>')
  call s:do_test("$csttp\<CR>", '<div>A</div>', '<p>A</p>')
  call s:do_test("$csttp\<CR>", '<div>A </div>', '<p>A </p>')
  call s:do_test("$csttp\<CR>", '<div> A</div>', '<p> A</p>')
  call s:do_test("$csttp\<CR>", '<div> A </div>', '<p> A </p>')
  call s:do_test("$csttp\<CR>", '<div>A<b>B</b></div>', '<p>A<b>B</b></p>')
  call s:do_test("2f>cstti\<CR>", '<div>A<b>B</b></div>', '<div>A<i>B</i></div>')
  call s:do_test("2f>csttp\<CR>", '  <div></div>  ', '  <p></p>  ')
  call s:do_test("2f>csttp\<CR>", '  <div>A</div>  ', '  <p>A</p>  ')

  call s:do_test("cs(ff\<CR>", '(A)', 'f(A)')
  call s:do_test('csf(', 'f(A)', '(A)')

  call s:do_test('cs(f', '(A)', 'function() { A }', function('s:setup_js_function_object'))
  call s:do_test('csf(', 'function() { A }', '(A)', function('s:setup_js_function_object'))

  call s:do_test('fAcs({.', '((((A))))', '(({{A}}))')
  call s:do_test('fAcs({..', '((((A))))', '({{{A}}})')
  call s:do_test('fAcs({...', '((((A))))', '{{{{A}}}}')
endfunction

function! s:test_surround_delete() abort
  call s:do_test('ds"', '""', '')
  call s:do_test('ds"', '"A"', 'A')
  call s:do_test('ds"', '"A "', 'A ')
  call s:do_test('ds"', '" A"', ' A')
  call s:do_test('ds"', '" A "', ' A ')
  call s:do_test('ds"', '" \"A\" "', ' \"A\" ')
  call s:do_test('ds"', '" \A\ "', ' \A\ ')
  call s:do_test('f"ds"', '  "A"  ', '  A  ')

  call s:do_test('$ds"', '""', '')
  call s:do_test('$ds"', '"A"', 'A')
  call s:do_test('$ds"', '"A "', 'A ')
  call s:do_test('$ds"', '" A"', ' A')
  call s:do_test('$ds"', '" A "', ' A ')
  call s:do_test('$ds"', '" \"A\" "', ' \"A\" ')
  call s:do_test('$ds"', '" \A\ "', ' \A\ ')
  call s:do_test('2f"ds"', '  "A"  ', '  A  ')

  call s:do_test('fAds"', '"A"', 'A')
  call s:do_test('fAds"', '"A "', 'A ')
  call s:do_test('fAds"', '" A"', ' A')
  call s:do_test('fAds"', '" A "', ' A ')
  call s:do_test('fAds"', '" \"A\" "', ' \"A\" ')
  call s:do_test('fAds"', '" \A\ "', ' \A\ ')
  call s:do_test('fAds"', '  "A"  ', '  A  ')

  call s:do_test('ds"', '"A"B"C"', 'AB"C"')
  call s:do_test('f"ds"', '"A"B"C"', 'AB"C"')
  call s:do_test('2f"ds"', '"A"B"C"', '"A"BC')
  call s:do_test('$ds"', '"A"B"C"', '"A"BC')
  call s:do_test('fAds"', '"A"B"C"', 'AB"C"')
  call s:do_test('fBds"', '"A"B"C"', '"ABC"')
  call s:do_test('fCds"', '"A"B"C"', '"A"BC')

  call s:do_test('ds(', '()', '')
  call s:do_test('ds(', '(A)', 'A')
  call s:do_test('ds(', '(A )', 'A ')
  call s:do_test('ds(', '( A)', ' A')
  call s:do_test('ds(', '( A )', ' A ')
  call s:do_test('ds(', '(A())', 'A()')
  call s:do_test('f(ds(', '(A())', '(A)')
  call s:do_test('f(ds(', '  ()  ', '    ')
  call s:do_test('f(ds(', '  (A)  ', '  A  ')

  call s:do_test('ds)', '()', '')
  call s:do_test('ds)', '(A)', 'A')
  call s:do_test('ds)', '(A )', 'A')
  call s:do_test('ds)', '( A)', 'A')
  call s:do_test('ds)', '( A )', 'A')
  call s:do_test('ds)', '(A())', 'A()')
  call s:do_test('f(ds)', '(A())', '(A)')
  call s:do_test('f(ds)', '  ()  ', '    ')
  call s:do_test('f(ds)', '  (A)  ', '  A  ')

  call s:do_test('dsb', '()', '')
  call s:do_test('dsb', '(A)', 'A')
  call s:do_test('dsb', '(A )', 'A ')
  call s:do_test('dsb', '( A)', ' A')
  call s:do_test('dsb', '( A )', ' A ')
  call s:do_test('dsb', '(A())', 'A()')
  call s:do_test('f(dsb', '(A())', '(A)')
  call s:do_test('f(dsb', '  ()  ', '    ')
  call s:do_test('f(dsb', '  (A)  ', '  A  ')

  call s:do_test('ds(', '( \(A )', ' \(A ')
  call s:do_test('ds(', '( A\) )', ' A\) ')
  call s:do_test('ds(', '( \(A\) )', ' \(A\) ')

  call s:do_test('ds(', "(\nA)", "\nA")
  call s:do_test('ds(', "(A\n)", "A\n")
  call s:do_test('ds(', "((\nA))", "(\nA)")
  call s:do_test('ds(', "((A\n))", "(A\n)")

  call s:do_test('$ds(', '()', '')
  call s:do_test('$ds(', '(A)', 'A')
  call s:do_test('$ds(', '(A )', 'A ')
  call s:do_test('$ds(', '( A)', ' A')
  call s:do_test('$ds(', '( A )', ' A ')
  call s:do_test('$ds(', '(A())', 'A()')
  call s:do_test('f)ds(', '(A())', '(A)')
  call s:do_test('f)ds(', '  ()  ', '    ')
  call s:do_test('f)ds(', '  (A)  ', '  A  ')

  call s:do_test('fAds(', '(A)', 'A')
  call s:do_test('fAds(', '(A )', 'A ')
  call s:do_test('fAds(', '( A)', ' A')
  call s:do_test('fAds(', '( A )', ' A ')
  call s:do_test('fAds(', '(A())', 'A()')
  call s:do_test('fAds(', '  (A)  ', '  A  ')

  call s:do_test('ds(', '(A)B(C)', 'AB(C)')
  call s:do_test('f)ds(', '(A)B(C)', 'AB(C)')
  call s:do_test('f(ds(', '(A)B(C)', '(A)BC')
  call s:do_test('$ds(', '(A)B(C)', '(A)BC')
  call s:do_test('fAds(', '(A)B(C)', 'AB(C)')
  call s:do_test('fBds(', '(A)B(C)', '(A)B(C)')
  call s:do_test('fCds(', '(A)B(C)', '(A)BC')

  call s:do_test('dst', '<div></div>', '')
  call s:do_test('dst', '<div>A</div>', 'A')
  call s:do_test('dst', '<div>A </div>', 'A ')
  call s:do_test('dst', '<div> A</div>', ' A')
  call s:do_test('dst', '<div> A </div>', ' A ')
  call s:do_test('dst', '<div>A<b>B</b></div>', 'A<b>B</b>')
  call s:do_test('f<dst', '<div>A<b>B</b></div>', '<div>AB</div>')
  call s:do_test('f<dst', '  <div></div>  ', '    ')
  call s:do_test('f<dst', '  <div>A</div>  ', '  A  ')

  call s:do_test('f>dst', '<div></div>', '')
  call s:do_test('f>dst', '<div>A</div>', 'A')
  call s:do_test('f>dst', '<div>A </div>', 'A ')
  call s:do_test('f>dst', '<div> A</div>', ' A')
  call s:do_test('f>dst', '<div> A </div>', ' A ')
  call s:do_test('f>dst', '<div>A<b>B</b></div>', 'A<b>B</b>')
  call s:do_test('2f>dst', '<div>A<b>B</b></div>', '<div>AB</div>')
  call s:do_test('f>dst', '  <div></div>  ', '    ')
  call s:do_test('f>dst', '  <div>A</div>  ', '  A  ')

  call s:do_test('f<dst', '<div></div>', '')
  call s:do_test('f<dst', '<div>A</div>', 'A')
  call s:do_test('f<dst', '<div>A </div>', 'A ')
  call s:do_test('f<dst', '<div> A</div>', ' A')
  call s:do_test('f<dst', '<div> A </div>', ' A ')
  call s:do_test('3f<dst', '<div>A<b>B</b></div>', 'A<b>B</b>')
  call s:do_test('2f<dst', '<div>A<b>B</b></div>', '<div>AB</div>')
  call s:do_test('2f<dst', '  <div></div>  ', '    ')
  call s:do_test('2f<dst', '  <div>A</div>  ', '  A  ')

  call s:do_test('$dst', '<div></div>', '')
  call s:do_test('$dst', '<div>A</div>', 'A')
  call s:do_test('$dst', '<div>A </div>', 'A ')
  call s:do_test('$dst', '<div> A</div>', ' A')
  call s:do_test('$dst', '<div> A </div>', ' A ')
  call s:do_test('$dst', '<div>A<b>B</b></div>', 'A<b>B</b>')
  call s:do_test('3f>dst', '<div>A<b>B</b></div>', '<div>AB</div>')
  call s:do_test('2f>dst', '  <div></div>  ', '    ')

  call s:do_test("/A\<CR>dst", '<div>A</div>', 'A')
  call s:do_test("/A\<CR>dst", '<div>A </div>', 'A ')
  call s:do_test("/A\<CR>dst", '<div> A</div>', ' A')
  call s:do_test("/A\<CR>dst", '<div> A </div>', ' A ')
  call s:do_test("/A\<CR>dst", '<div>A<b>B</b></div>', 'A<b>B</b>')
  call s:do_test("/B\<CR>dst", '<div>A<b>B</b></div>', '<div>AB</div>')
  call s:do_test("/A\<CR>dst", '  <div>A</div>  ', '  A  ')

  call s:do_test('dsf', 'A(B)', 'B')
  call s:do_test('dsf', 'A(B )', 'B ')
  call s:do_test('dsf', 'A( B)', ' B')
  call s:do_test('dsf', 'A( B )', ' B ')
  call s:do_test('dsf', 'A(B())', 'B()')
  call s:do_test('dsf', '  A(B)  ', '  A(B)  ')

  call s:do_test('dsf', 'function() {foo}', 'foo', function('s:setup_js_function_object'))
  call s:do_test('dsf', 'function() {foo }', 'foo', function('s:setup_js_function_object'))
  call s:do_test('dsf', 'function() { foo}', 'foo', function('s:setup_js_function_object'))
  call s:do_test('dsf', 'function() { foo }', 'foo', function('s:setup_js_function_object'))
  call s:do_test('dsf', 'function() {  foo  }', 'foo', function('s:setup_js_function_object'))

  call s:do_test('ds(.', '((((foo))))', '((foo))')
  call s:do_test('ds(..', '((((foo))))', '(foo)')
  call s:do_test('ds(...', '((((foo))))', 'foo')
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

  call s:do_test("d\<Plug>(surround-obj-i:f)", 'foo(A)', 'foo()')
  call s:do_test("$d\<Plug>(surround-obj-i:f)", 'foo(A)', 'foo()')
  call s:do_test("d\<Plug>(surround-obj-a:f)", 'foo(A)', '')
  call s:do_test("$d\<Plug>(surround-obj-a:f)", 'foo(A)', '')

  call s:do_test("d\<Plug>(surround-obj-i:f)", 'function() { A }', 'function() {  }', function('s:setup_js_function_object'))
  call s:do_test("$d\<Plug>(surround-obj-i:f)", 'function() { A }', 'function() {  }', function('s:setup_js_function_object'))
  call s:do_test("d\<Plug>(surround-obj-a:f)", 'function() { A }', '', function('s:setup_js_function_object'))
  call s:do_test("$d\<Plug>(surround-obj-a:f)", 'function() { A }', '', function('s:setup_js_function_object'))
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

function! s:setup_js_function_object() abort
  call surround_obj#define_local_object('f', {
  \   'type': 'block',
  \   'delimiter': ['function() { ', ' }'],
  \   'pattern': ['\<function\s*(\s*)\s*{\s*', '\s*}'],
  \ })
endfunction
