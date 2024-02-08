# frozen_string_literal: true

require 'aston/version'

# Aston class keeps, modifies, and produces JSON which is isomorphic to XML
class Aston
  class Error < StandardError; end

  # Wrapper for attributes
  class Attributes
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def [](key)
      @data[key]
    end

    def []=(key, value)
      @data[key] = value
    end

    def to_s
      @data.map { |k, v| "#{k}='#{v}'" }.join(' ')
    end

    def ==(other)
      other.is_a?(Attributes) && @data == other.data
    end

    def size
      @data.size
    end
  end

  # Wrapper for content
  class Content
    attr_reader :data

    def initialize(data)
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
    @content << value
  end

  def ==(other)
    other.is_a?(Aston) && @name == other.name && @attributes == other.attributes && @content == other.content
  end

  def to_s
    comment = "<!-- Aston:#{__id__}:#{name} -->"
    opening = @attributes.data.empty? ? "<#{name}>" : ['<', name, *@attributes].join(' ') << '>'
    [comment, opening, *@content, "</#{name}>"].join("\n")
  end

  def paths
    do_paths([], [])
  end

  def find(name)
    @content.data.find { |a| a.is_a?(Aston) && a.name == name }
  end

  def update_in(path, create_intermediate: true, &_block)
    yield clamber(path, create_intermediate)
  rescue StandardError => e
    raise Error, e
  end

  def put_attribute(path, name, value, create_intermediate: true)
    tap { clamber(path, create_intermediate)[name] = value }
  rescue StandardError => e
    raise Error, e
  end

  def put_content(path, aston, create_intermediate: true)
    tap { clamber(path, create_intermediate) << aston }
  rescue StandardError => e
    raise Error, e
  end

  def get(path, default: nil)
    path = fix_path(path)
    path.reduce(self) do |memo, e|
      current = memo.find(e)

      case current
      when NilClass then break default
      when String then current
      when Aston then current
      end
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
    fix_path(path).reduce(self) do |memo, e|
      current = memo.find(e)

      case current
      when NilClass then create_intermediate ? Aston.new(e).tap { |aston| memo << aston } : break
      when Aston then current
      end
    end
  end

  def fix_path(path)
    path = path.split('.') if path.is_a?(String)
    raise Error, 'Path must be an array' unless path.is_a?(Array)

    path
  end
end
