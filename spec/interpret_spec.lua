describe('interpret', function()
  local scan = require 'scan'
  local parse = require 'parse'
  local interpret = require 'interpret'

  local function ast_for(s)
    return parse(scan(s))
  end

  local function should_generate_error_for_ast(s, expected_error)
    local error_reporter = spy.new(load'')
    interpret(ast_for(s), error_reporter)
    assert.spy(error_reporter).was_called_with(expected_error)
  end

  it('should interpret literals', function()
    assert.are.equal(3, interpret(ast_for('3')))
    assert.are.equal(true, interpret(ast_for('true')))
    assert.are.equal('hello', interpret(ast_for('"hello"')))
  end)

  it('should intrepret groupings', function()
    assert.are.equal(3, interpret(ast_for('(3)')))
  end)

  it('should interpret unary arithmetic negation', function()
    assert.are.equal(-3, interpret(ast_for('-3')))

    should_generate_error_for_ast('-"hello"', {
      token = { lexeme = '-', line = 1, type = 'MINUS' },
      message = 'Operand must be a number.'
    })
  end)

  it('should intrepret unary logical negation', function()
    assert.are.equal(false, interpret(ast_for('!true')))

    should_generate_error_for_ast('!3', {
      token = { lexeme = '!', line = 1, type = 'BANG' },
      message = 'Operand must be a boolean.'
    })
  end)

  it('should interpret sums', function()
    assert.are.equal(7, interpret(ast_for('3 + 4')))

    should_generate_error_for_ast('3 + "hello"', {
      token = { lexeme = '+', line = 1, type = 'PLUS' },
      message = 'Operands must be two numbers or two strings.'
    })
  end)

  it('should intrepret differences', function()
    assert.are.equal(-1, interpret(ast_for('3 - 4')))

    should_generate_error_for_ast('3 - "4"', {
      token = { lexeme = '-', line = 1, type = 'MINUS' },
      message = 'Operands must be numbers.'
    })

    should_generate_error_for_ast('"3" - 4', {
      token = { lexeme = '-', line = 1, type = 'MINUS' },
      message = 'Operands must be numbers.'
    })
  end)

  it('should interpret products', function()
    assert.are.equal(12, interpret(ast_for('3 * 4')))

    should_generate_error_for_ast('3 * "4"', {
      token = { lexeme = '*', line = 1, type = 'STAR' },
      message = 'Operands must be numbers.'
    })

    should_generate_error_for_ast('"3" * 4', {
      token = { lexeme = '*', line = 1, type = 'STAR' },
      message = 'Operands must be numbers.'
    })
  end)

  it('should interpret quotients', function()
    assert.are.equal(3 / 4, interpret(ast_for('3 / 4')))

    should_generate_error_for_ast('3 / "4"', {
      token = { lexeme = '/', line = 1, type = 'SLASH' },
      message = 'Operands must be numbers.'
    })

    should_generate_error_for_ast('"3" / 4', {
      token = { lexeme = '/', line = 1, type = 'SLASH' },
      message = 'Operands must be numbers.'
    })
  end)

  it('should interpret string concatenation', function()
    assert.are.equal('hello, world', interpret(ast_for('"hello" + ", world"')))

    should_generate_error_for_ast('"hello" + 3', {
      token = { lexeme = '+', line = 1, type = 'PLUS' },
      message = 'Operands must be two numbers or two strings.'
    })
  end)

  it('should interpret greater than comparisons', function()
    assert.are.equal(true, interpret(ast_for('4 > 3')))
    assert.are.equal(false, interpret(ast_for('1 > 3')))
    assert.are.equal(false, interpret(ast_for('3 > 3')))

    should_generate_error_for_ast('3 > "4"', {
      token = { lexeme = '>', line = 1, type = 'GREATER' },
      message = 'Operands must be numbers.'
    })

    should_generate_error_for_ast('"3" > 4', {
      token = { lexeme = '>', line = 1, type = 'GREATER' },
      message = 'Operands must be numbers.'
    })
  end)

  it('should interpret greater than or equal comparisons', function()
    assert.are.equal(true, interpret(ast_for('4 >= 3')))
    assert.are.equal(false, interpret(ast_for('1 >= 3')))
    assert.are.equal(true, interpret(ast_for('3 >= 3')))

    should_generate_error_for_ast('3 >= "4"', {
      token = { lexeme = '>=', line = 1, type = 'GREATER_EQUAL' },
      message = 'Operands must be numbers.'
    })

    should_generate_error_for_ast('"3" >= 4', {
      token = { lexeme = '>=', line = 1, type = 'GREATER_EQUAL' },
      message = 'Operands must be numbers.'
    })
  end)

  it('should interpret less than comparisons', function()
    assert.are.equal(false, interpret(ast_for('4 < 3')))
    assert.are.equal(true, interpret(ast_for('1 < 3')))
    assert.are.equal(false, interpret(ast_for('3 < 3')))

    should_generate_error_for_ast('3 < "4"', {
      token = { lexeme = '<', line = 1, type = 'LESS' },
      message = 'Operands must be numbers.'
    })

    should_generate_error_for_ast('"3" < 4', {
      token = { lexeme = '<', line = 1, type = 'LESS' },
      message = 'Operands must be numbers.'
    })
  end)

  it('should interpret less than or equal comparisons', function()
    assert.are.equal(false, interpret(ast_for('4 <= 3')))
    assert.are.equal(true, interpret(ast_for('1 <= 3')))
    assert.are.equal(true, interpret(ast_for('3 <= 3')))

    should_generate_error_for_ast('3 <= "4"', {
      token = { lexeme = '<=', line = 1, type = 'LESS_EQUAL' },
      message = 'Operands must be numbers.'
    })

    should_generate_error_for_ast('"3" <= 4', {
      token = { lexeme = '<=', line = 1, type = 'LESS_EQUAL' },
      message = 'Operands must be numbers.'
    })
  end)

  it('should interpret equality expressionss', function()
    assert.are.equal(false, interpret(ast_for('4 == 3')))
    assert.are.equal(true, interpret(ast_for('3 == 3')))
    assert.are.equal(false, interpret(ast_for('"3" == 3')))
    assert.are.equal(false, interpret(ast_for('3 == "3"')))
    assert.are.equal(false, interpret(ast_for('false == true')))
    assert.are.equal(true, interpret(ast_for('false == false')))
    assert.are.equal(true, interpret(ast_for('true == true')))
    assert.are.equal(false, interpret(ast_for('"hello" == "goodbye"')))
    assert.are.equal(true, interpret(ast_for('"hello" == "hello"')))
  end)

  it('should interpret inequality expressionss', function()
    assert.are.equal(true, interpret(ast_for('4 != 3')))
    assert.are.equal(false, interpret(ast_for('3 != 3')))
    assert.are.equal(true, interpret(ast_for('"3" != 3')))
    assert.are.equal(true, interpret(ast_for('3 != "3"')))
    assert.are.equal(true, interpret(ast_for('false != true')))
    assert.are.equal(false, interpret(ast_for('false != false')))
    assert.are.equal(false, interpret(ast_for('true != true')))
    assert.are.equal(true, interpret(ast_for('"hello" != "goodbye"')))
    assert.are.equal(false, interpret(ast_for('"hello" != "hello"')))
  end)
end)