class Expr
  def self.build(ast)
    head, *tail = ast
    case head
      when :+ then Addition.new(*all(tail))
      when :* then Multiplication.new(*all(tail))
      when :- then Negation.new(*all(tail))
      when :sin then Sine.new(*all(tail))
      when :cos then Cosine.new(*all(tail))
      when :number then Number.new(*tail)
      when :variable then Variable.new(*tail)
    end
  end
  
  def self.all(expressions)
    expressions.map { |expression| build expression }
  end
  
  def +(other)
    Addition.new self, other
  end
  
  def *(other)
    Multiplication.new self, other
  end
  
  def -@
    Negation.new self
  end
  
  def simplify
    self
  end
  
  def derive(var)
    derivative(var).simplify
  end
end

class Unary < Expr
  attr_reader :expr
  
  def initialize(expr)
    @expr = expr
  end
  
  def ==(other)
    self.class == other.class and self.expr == other.expr
  end
  
  def exact?
    expr.exact?
  end
end

class Binary < Expr
  attr_reader :left, :right
  
  def initialize(left, right)
    @left, @right  = left, right
  end
  
  def ==(other)
    self.class == other.class and
    self.left == other.left and
    self.right == other.right
  end
  
  def simplify
    self.class.new left.simplify, right.simplify
  end
  
  def exact?
    left.simplify.exact? and right.simplify.exact?
  end
end

class Number < Unary
  def evaluate(env = {})
    expr
  end
  
  def derivative(varible)
    Number.new(0)
  end
  
  def exact?
    true
  end
end

class Addition < Binary
  def evaluate(environment = {})
    left.evaluate(environment) + right.evaluate(environment)
  end
  
  def simplify
    if exact? then Number.new(left.simplify.evaluate + right.simplify.evaluate)
    elsif left == Number.new(0) then right.simplify
    elsif right == Number.new(0) then left.simplify
    else super
    end
  end
  
  def derivative(variable)
    left.derivative(variable) + right.derivative(variable)
  end
end

class Multiplication < Binary
  def evaluate(environment = {})
    left.evaluate(environment) * right.evaluate(environment)
  end
  
  def simplify
    if exact? then Number.new(left.simplify.evaluate * right.simplify.evaluate)
    elsif left == Number.new(0) then Number.new(0)
    elsif right == Number.new(0) then Number.new(0)
    elsif left == Number.new(1) then right.simplify
    elsif right == Number.new(1) then left.simplify
    else super
    end
  end
  
  def derivative(variable)
    left.derivative(variable) * right + left * right.derivative(variable)
  end
end

class Variable < Unary
  def evaluate(environment = {})
    environment.fetch expr
  end
  
  def simplify
    self
  end

  def derivative(variable)
    variable == @expr ? Number.new(1) : Number.new(0)
  end
  
  def exact?
    false
  end
end

class Negation < Unary
  def evaluate(environment = {})
    -expr.evaluate(environment)
  end
  
  def simplify
    if exact?
      Number.new(-expr.simplify.evaluate)
    else
      Negation.new(expr.simplify)
    end
  end
  
  def derivative(variable)
    Negation.new expr.derivative(variable)
  end
  
  def exact?
    expr.exact?
  end
end

class Sine < Unary
  def evaluate(environment = {})
    Math.sin expr.evaluate(environment)
  end
  
  def simplify
    if exact?
      Number.new Math.sin(expr.simplify.evaluate)
    else
      Sine.new expr.simplify
    end
  end
  
  def derivative(variable)
    expr.derivative(variable) * Cosine.new(expr)
  end
end

class Cosine < Unary
  def evaluate(environment = {})
    Math.cos expr.evaluate(environment)
  end
  
  def simplify
    if exact?
      Number.new Math.cos(expr.simplify.evaluate)
    else
     Cosine.new expr.simplify
    end
  end
  
  def derivative(variable)
    expr.derivative(variable) * -Sine.new(expr)
  end
end
