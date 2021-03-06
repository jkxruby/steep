require "test_helper"

class MethodParsingTest < Minitest::Test
  T = Steep::Types
  Interface = Steep::Interface

  def test_no_params1
    method = Steep::Parser.parse_method("() -> any")
    assert_equal [], method.params.required
    assert_equal [], method.params.optional
    assert_nil method.params.rest
    assert_equal({}, method.params.required_keywords)
    assert_equal({}, method.params.optional_keywords)
    assert_nil method.params.rest_keywords
    assert_nil method.block
    assert_equal T::Any.new, method.return_type
  end

  def test_no_params2
    method = Steep::Parser.parse_method("-> any")
    assert_equal [], method.params.required
    assert_equal [], method.params.optional
    assert_nil method.params.rest
    assert_equal({}, method.params.required_keywords)
    assert_equal({}, method.params.optional_keywords)
    assert_nil method.params.rest_keywords
    assert_nil method.block
    assert_equal T::Any.new, method.return_type
  end

  def test_required_params
    method = Steep::Parser.parse_method("(any, String) -> any")
    assert_equal [T::Any.new, T::Name.instance(name: :String)], method.params.required
    assert_equal [], method.params.optional
    assert_nil method.params.rest
    assert_equal({}, method.params.required_keywords)
    assert_equal({}, method.params.optional_keywords)
    assert_nil method.params.rest_keywords
    assert_nil method.block
    assert_equal T::Any.new, method.return_type
  end

  def test_optional_params1
    method = Steep::Parser.parse_method("(any, Integer, ?String) -> any")
    assert_equal [T::Any.new, T::Name.instance(name: :Integer)], method.params.required
    assert_equal [T::Name.instance(name: :String)], method.params.optional
    assert_nil method.params.rest
    assert_equal({}, method.params.required_keywords)
    assert_equal({}, method.params.optional_keywords)
    assert_nil method.params.rest_keywords
    assert_nil method.block
    assert_equal T::Any.new, method.return_type
  end

  def test_optional_params2
    method = Steep::Parser.parse_method("(?any, ?String) -> any")
    assert_equal [], method.params.required
    assert_equal [T::Any.new, T::Name.instance(name: :String)], method.params.optional
    assert_nil method.params.rest
    assert_equal({}, method.params.required_keywords)
    assert_equal({}, method.params.optional_keywords)
    assert_nil method.params.rest_keywords
    assert_nil method.block
    assert_equal T::Any.new, method.return_type
  end

  def test_rest_param
    method = Steep::Parser.parse_method("(any, ?String, *Integer) -> any")
    assert_equal [T::Any.new], method.params.required
    assert_equal [T::Name.instance(name: :String)], method.params.optional
    assert_equal T::Name.instance(name: :Integer), method.params.rest
    assert_equal({}, method.params.required_keywords)
    assert_equal({}, method.params.optional_keywords)
    assert_nil method.params.rest_keywords
    assert_nil method.block
    assert_equal T::Any.new, method.return_type
  end

  def test_keywords
    method = Steep::Parser.parse_method("(any, ?String, *Integer, name: String, ?email: Symbol) -> any")
    assert_equal [T::Any.new], method.params.required
    assert_equal [T::Name.instance(name: :String)], method.params.optional
    assert_equal T::Name.instance(name: :Integer), method.params.rest
    assert_equal({ name: T::Name.instance(name: :String) }, method.params.required_keywords)
    assert_equal({ email: T::Name.instance(name: :Symbol) }, method.params.optional_keywords)
    assert_nil method.params.rest_keywords
    assert_nil method.block
    assert_equal T::Any.new, method.return_type
  end

  def test_keywords2
    method = Steep::Parser.parse_method("(name: String, ?email: Symbol) -> any")
    assert_equal [], method.params.required
    assert_equal [], method.params.optional
    assert_nil method.params.rest
    assert_equal({ name: T::Name.instance(name: :String) }, method.params.required_keywords)
    assert_equal({ email: T::Name.instance(name: :Symbol) }, method.params.optional_keywords)
    assert_nil method.params.rest_keywords
    assert_nil method.block
    assert_equal T::Any.new, method.return_type
  end

  def test_rest_keywords
    method = Steep::Parser.parse_method("(any, ?String, *Integer, name: String, ?email: Symbol, **Integer) -> any")
    assert_equal [T::Any.new], method.params.required
    assert_equal [T::Name.instance(name: :String)], method.params.optional
    assert_equal T::Name.instance(name: :Integer), method.params.rest
    assert_equal({ name: T::Name.instance(name: :String) }, method.params.required_keywords)
    assert_equal({ email: T::Name.instance(name: :Symbol) }, method.params.optional_keywords)
    assert_equal T::Name.instance(name: :Integer), method.params.rest_keywords
    assert_nil method.block
    assert_equal T::Any.new, method.return_type
  end

  def test_block
    method = Steep::Parser.parse_method("(any, ?String, *Integer, name: String, ?email: Symbol, **Integer) { } -> any")
    assert_equal [T::Any.new], method.params.required
    assert_equal [T::Name.instance(name: :String)], method.params.optional
    assert_equal T::Name.instance(name: :Integer), method.params.rest
    assert_equal({ name: T::Name.instance(name: :String) }, method.params.required_keywords)
    assert_equal({ email: T::Name.instance(name: :Symbol)}, method.params.optional_keywords)
    assert_equal T::Name.instance(name: :Integer), method.params.rest_keywords
    assert_instance_of Interface::Block, method.block
    assert_equal [], method.block.params.required
    assert_equal [], method.block.params.optional
    assert_equal T::Any.new, method.block.params.rest
    assert_equal({}, method.block.params.required_keywords)
    assert_equal({}, method.block.params.optional_keywords)
    assert_nil method.block.params.rest_keywords
    assert_equal T::Any.new, method.block.return_type
    assert_equal T::Any.new, method.return_type
  end

  def test_block1
    method = Steep::Parser.parse_method("(any, ?String, *Integer, name: String, ?email: Symbol, **Integer) { -> String } -> any")
    assert_equal [T::Any.new], method.params.required
    assert_equal [T::Name.instance(name: :String)], method.params.optional
    assert_equal T::Name.instance(name: :Integer), method.params.rest
    assert_equal({ name: T::Name.instance(name: :String) }, method.params.required_keywords)
    assert_equal({ email: T::Name.instance(name: :Symbol) }, method.params.optional_keywords)
    assert_equal T::Name.instance(name: :Integer), method.params.rest_keywords
    assert_instance_of Interface::Block, method.block
    assert_equal [], method.block.params.required
    assert_equal [], method.block.params.optional
    assert_equal T::Any.new, method.block.params.rest
    assert_equal({}, method.block.params.required_keywords)
    assert_equal({}, method.block.params.optional_keywords)
    assert_nil method.block.params.rest_keywords
    assert_equal T::Name.instance(name: :String), method.block.return_type
    assert_equal T::Any.new, method.return_type
  end

  def test_block2
    method = Steep::Parser.parse_method("(any, ?String, *Integer, name: String, ?email: Symbol, **Integer) { (String, ?Integer, *Symbol) -> any } -> any")
    assert_equal [T::Any.new], method.params.required
    assert_equal [T::Name.instance(name: :String)], method.params.optional
    assert_equal T::Name.instance(name: :Integer), method.params.rest
    assert_equal({ name: T::Name.instance(name: :String) }, method.params.required_keywords)
    assert_equal({ email: T::Name.instance(name: :Symbol) }, method.params.optional_keywords)
    assert_equal T::Name.instance(name: :Integer), method.params.rest_keywords
    assert_instance_of Interface::Block, method.block
    assert_equal [T::Name.instance(name: :String)], method.block.params.required
    assert_equal [T::Name.instance(name: :Integer)], method.block.params.optional
    assert_equal T::Name.instance(name: :Symbol), method.block.params.rest
    assert_equal({}, method.block.params.required_keywords)
    assert_equal({}, method.block.params.optional_keywords)
    assert_nil method.block.params.rest_keywords
    assert_equal T::Any.new, method.block.return_type
    assert_equal T::Any.new, method.return_type
  end

  def test_parameterized
    method = Steep::Parser.parse_method("<'a> () -> String")
    assert_equal [:a], method.type_params
  end

  def test_var_type
    method = Steep::Parser.parse_method("'a -> 'b")

    assert_equal [T::Var.new(name: :a)], method.params.required
    assert_equal T::Var.new(name: :b), method.return_type
  end

  def test_application
    method = Steep::Parser.parse_method("-> Array<'a>")

    assert_equal T::Name.instance(name: :Array, params: [T::Var.new(name: :a)]), method.return_type
  end

  def test_self_and_class_and_module
    method = Steep::Parser.parse_method("(class, module) -> instance")

    assert_equal [T::Class.new, T::Class.new], method.params.required
    assert_equal T::Instance.new, method.return_type
  end

  def test_method_param
    method = Steep::Parser.parse_method("<'a> () -> 'a")

    assert_equal [], method.params.required
    assert_equal [:a], method.type_params
    assert_equal T::Var.new(name: :a), method.return_type
  end

  def test_union
    method = Steep::Parser.parse_method("('a | 'b, 'c)-> Array<'a | 'b>")

    assert_equal [T::Union.new(types:
                                 [
                                   T::Var.new(name: :a),
                                   T::Var.new(name: :b),
                                 ]),
                  T::Var.new(name: :c)],
                 method.params.required

    assert_equal T::Name.instance(name: :Array,
                                  params: [
                                    T::Union.new(types: [
                                      T::Var.new(name: :a),
                                      T::Var.new(name: :b)
                                    ])
                                  ]), method.return_type
  end
end
