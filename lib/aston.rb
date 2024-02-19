# frozen_string_literal: true

require 'aston/version'

# Aston class keeps, modifies, and produces JSON which is isomorphic to XML
class Aston
  class Error < StandardError; end

  # Wrapper for attributes
  class Attributes
    attr_reader :data

    def initialize(data = {})
      @data = data
    end

    def to_hash
      @data
    end

    def [](key)
      @data[key]
    end

    def []=(key, value)
      @data[key] = value
    end

    def ==(other)
      other.is_a?(Attributes) && @data == other.data
    end

    def size
      @data.size
    end

    def to_s
      @data.map { |k, v| "#{k}='#{v}'" }.join(' ')
    end

    def to_json(opts = nil)
      @data.to_json(opts)
    end
  end

  # Wrapper for content
  class Content
    attr_reader :data

    def initialize(data = [])
      @data = data
    end

    def <<(elem)
      @data << elem
    end

    def [](index)
      @data[index]
    rescue StandardError => e
      raise Error, e
    end

    def ==(other)
      other.is_a?(Content) && @data == other.data
    end

    def size
      @data.size
    end

    def to_s
      @data.map(&:to_s).join("\n")
    end

    def to_json(opts = nil)
      @data.to_json(opts)
    end
  end

  attr_reader :name, :attributes, :content

  def initialize(name, attributes: {}, content: [])
    @name = name
    @attributes = Attributes.new(attributes)
    @content = Content.new(content)
  end

  def [](key)
    @attributes[key]
  end

  def []=(key, value)
    @attributes[key] = value
  end

  def <<(value)
    tap { @content << value }
  end

  def ==(other)
    other.is_a?(Aston) && @name == other.name && @attributes == other.attributes && @content == other.content
  end

  def to_s
    comment = "<!-- Aston:#{__id__}:#{name} -->"
    opening = @attributes.data.empty? ? "<#{name}>" : ["<#{name}", *@attributes].join(' ') << '>'
    [comment, opening, *@content, "</#{name}>"].join("\n")
  end

  def to_hash(remove_empty: false)
    {
      name: @name,
      attributes: @attributes.to_hash,
      content: @content.data.map { |e| e.is_a?(Aston) ? e.to_hash(remove_empty: remove_empty) : e }
    }.tap do |hash|
      if remove_empty
        hash.delete(:attributes) if hash[:attributes] == {}
        hash.delete(:content) if hash[:content] == []
      end
    end
  end

  def to_json(opts = nil)
    to_hash.to_json(opts)
  end

  def self.parse_hash(hash)
    name = hash.fetch('name', hash.fetch(:name, ''))
    attributes = hash.fetch('attributes', hash.fetch(:attributes, {}))
    content = hash.fetch('content', hash.fetch(:content, [])).map do |elem|
      case elem
      when String then elem
      when Hash then Aston.parse_hash(elem)
      end
    end
    Aston.new(name, attributes: attributes, content: content)
  end

  def paths
    do_paths([], [])
  end

  def filter(name)
    @content.data.select { |a| a.is_a?(Aston) && a.name == name }
  end

  def update_in(path, create_intermediate: true, &block)
    clamber(path, create_intermediate).each(&block)
  rescue StandardError => e
    raise Error, e
  end

  def put_attribute(path, name, value, create_intermediate: true)
    tap { clamber(path, create_intermediate).each { |aston| aston[name] = value } }
  rescue StandardError => e
    raise Error, e
  end

  def put_content(path, content, create_intermediate: true)
    tap { clamber(path, create_intermediate).each { |aston| aston << content } }
  rescue StandardError => e
    raise Error, e
  end

  def get(path)
    fix_path(path).reduce([self]) do |memo, e|
      memo.flat_map { |aston| aston.filter(e) }
    end
  end

  protected

  def do_paths(path, acc)
    content = @content.data.select { |c| c.is_a?(Aston) }
    return [path + [name]] if content.empty?

    content.map do |e|
      e.do_paths(path + [name], acc)
    end.flatten(1)
  end

  private

  def clamber(path, create_intermediate)
    fix_path(path).reduce([self]) do |memo, e|
      memo.flat_map do |aston|
        aston.filter(e).tap do |currents|
          next unless currents == []

          value = [Aston.new(e).tap { |n| aston << n }] if create_intermediate
          break value
        end
      end
    end
  end

  def fix_path(path)
    # path = path.split('.') if path.is_a?(String)
    raise Error, 'Path must be an array' unless path.is_a?(Array)

    path
  end
end
