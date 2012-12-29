class Expr
  attr_accessor :expresion

  def initialize(tree)
    if tree[0] == :+ or tree[0] == :*
      @expresion = Binary.new(tree)
    else
      @expresion = Unary.new(tree)
    end
  end

  def Expr.build(tree)
    Expr.new(tree)
  end

  def ==(expr)
    expresion.expresion.arguments == expr.expresion.expresion.arguments
  end

  def evaluate(environment = {})
    expresion.expresion.evaluate(environment)
  end

  def simplify()
    expresion.expresion.simplify()
  end

  def exact?
    if expresion.class == Binary
      Expr.new(expresion.expresion.arguments[1]).exact? and
      Expr.new(expresion.expresion.arguments[2]).exact?
    elsif expresion.class == Unary
      if expresion.expresion.class == Variable
  false
      else
	true
      end
    end
  end

  def derive(variable)
    Expr.new(expresion.expresion.derive(variable)).simplify()
  end
end

class Unary < Expr
  attr_accessor :expresion

  def initialize(tree)
    if tree[0] == :number
      @expresion = Number.new(tree)
    elsif tree[0] == :variable
      @expresion = Variable.new(tree)
    elsif tree[0] == :-
      @expresion = Negation.new(tree)
    elsif tree[0] == :sin
      @expresion = Sine.new(tree)
    elsif tree[0] == :cos
      @expresion = Cosine.new(tree)
    end
  end

  def evaluate(environment = {})
    if @expresion.class == Number
      expresion.value.evaluate(environment)
    elsif @expresion.class == Variable
      expresion.variable.evaluate(environment)
    elsif @expresion.class == Negation
      expresion.argument.evaluate(environment)
    elsif @expresion.class == Sine
      expresion.argument.evaluate(environment)
    elsif @expresion.class == Cosine
      expresion.argument.evaluate(environment)
    end
  end

  def simplify()
    if @expresion.class == Number
      expresion.value.simplify()
    elsif @expresion.class == Variable
      expresion.variable.simplify()
    elsif @expresion.class == Negation
      expresion.argument.simplify()
    elsif @expresion.class == Sine
      expresion.argument.simplify()
    elsif @expresion.class == Cosine
      expresion.argument.simplify()
    end
  end

  def derive(variable)
    if @expresion.class == Number
      expresion.value.derive(variable)
    elsif @expresion.class == Variable
      expresion.variable.derive(variable)
    elsif @expresion.class == Negation
      expresion.argument.derive(variable)
    elsif @expresion.class == Sine
      expresion.argument.derive(variable)
    elsif @expresion.class == Cosine
      expresion.argument.derive(variable)
    end
  end
end

class Binary < Expr
  attr_accessor :expresion

  def initialize(tree)
    if tree[0] == :+
      @expresion = Addition.new(tree)
    else
      @expresion = Multiplication.new(tree)
    end
  end

  def evaluate(environment = {})
    expresion.arguments.evaluate(environment)
  end

  def simplify()
    expresion.arguments.simplify()
  end

  def derive(variable)
    expresion.arguments.derive(variable)
  end
end

class Number < Unary
  attr_accessor :value

  def initialize (tree)
    @value = tree
  end

  def evaluate(environment = {})
    @value[1]
  end

  def simplify()
    @value
  end

  def derive(variable)
    @value = [:number, 0]
  end
end

class Addition < Binary
  attr_accessor :arguments

  def initialize(tree)
    @arguments = tree
  end

  def evaluate(environment = {})
    if Expr.new(@arguments).exact?
      @arguments[1][1] + @arguments[2][1]
    else
      Expr.new(@arguments[1]).evaluate(environment) + Expr.new(@arguments[2]).evaluate(environment)
    end
  end

  def simplify ()
    if Expr.new(@arguments).exact?
      @arguments = [:number, Expr.new(@arguments).evaluate()]
    elsif @arguments[1] == [:number, 0]
      @arguments = @arguments[2]
    elsif @arguments[2] == [:number, 0]
      @arguments = @arguments[1]
    else
      @arguments = [:+, Expr.new(@arguments[1]).simplify(), Expr.new(@arguments[2]).simplify()]
      Expr.new(@arguments).simplify()
    end
  end

  def derive(variable)
    if Expr.new(@arguments).exact?
      @arguments = [:number, 0]
    else
      @arguments[1] = Expr.new(@arguments[1]).derive(variable)
      @arguments[2] = Expr.new(@arguments[2]).derive(variable)
    end
  end
end

class Multiplication < Binary
  attr_accessor :arguments

  def initialize(tree)
    @arguments = tree
  end

  def evaluate(environment = {})
    if Expr.new(@arguments).exact?
      @arguments[1][1] * @arguments[2][1]
    else
      Expr.new(@arguments[1]).evaluate(environment) * Expr.new(@arguments[2]).evaluate(environment)
    end
  end

  def simplify ()
    if Expr.new(@arguments).exact?
      @arguments = [:number, Expr.new(@arguments).evaluate()]
    elsif @arguments[1] == [:number, 1]
      @arguments = @arguments[2]
    elsif @arguments[2] == [:number, 1]
      @arguments = @arguments[1]
    elsif @arguments[1] == [:number, 0] or @arguments[2] == [:number, 0]
      @arguments = [:number, 0]
    else
      @arguments = [:*, Expr.new(@arguments[1]).simplify(), Expr.new(@arguments[2]).simplify()]
      Expr.new(@arguments).simplify()
    end
  end

  def derive(variable)
    if Expr.new(@arguments).exact?
      @arguments = [:number, 0]
    else
      @arguments = [:+, [:*, Expr.new(@arguments[1]).derive(variable), @arguments[2]],
	                [:*, @arguments[1], Expr.new(@arguments[2]).derive(variable)]]
    end
  end
end

class Variable < Unary
  attr_accessor :variable

  def initialize(tree)
    @variable = tree
  end

  def evaluate(environment = {})
    environment[@variable[1]]
  end

  def simplify()
    @variable
  end

  def derive(variable)
    if @variable[1] == variable
      @variable = [:number, 1]
    else
      @variable = [:number, 0]
    end
  end
end

class Negation < Unary
  attr_accessor :value

  def initialize(tree)
    @value = tree
  end

  def evaluate(environment = {})
    - @value[1]
  end

  def simplify()
    @value
  end

  def derive(variable)
    @value = [:-, Expr.new(@value[1]).derive(variable)]
  end
end

class Sine < Unary
  attr_accessor :argument

  def initialize(tree)
    @argument = tree
  end

  def evaluate(environment = {})
    Math.sin(Expr.new(@argument[1]).evaluate(environment))
  end

  def simplify()
    if argument[1] == [:number, 0]
      @expresion = [:number, 0]
    end
  end

  def derive(variable)
    if Expr.new(@arguments).exact?
      @argument = [:number, 0]
    else
      @argument = [:*, Expr.new(@argument[1]).derive(variable), [:cos, @argument[1]]]
    end
  end
end

class Cosine < Unary
  attr_accessor :argument

  def initialize(tree)
    @argument = tree
  end

  def evaluate(environment = {})
    Math.cos(Expr.new(@argument[1]).evaluate(environment))
  end

  def simplify()
    @argument
  end

  def derive(variable)
    if Expr.new(@arguments).exact?
      @argument = [:number, 0]
    else
      @argument = [:*, Expr.new(@argument[1]).derive(variable), [:-, [:sin, @argument[1]]]]
    end
  end
end
