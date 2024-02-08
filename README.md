# Aston

The tiny library providing a tooling to deal with _ASTON_, which is like _JSON_, but isomorphic to _XML_. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aston'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install aston

## Usage

```ruby
Aston.new(:root).
    then { |a| a.put_attribute([:bar, :baz], 'attr', 'value') }.
    then { |a| a.put_content([:bar, :baz], 'Hello, world!') }
#⇒ #<Aston:0x0000646926a11370
#  @attributes=#<Aston::Attributes:0x0000646926a112f8 @data={}>,
#  @content=
#   #<Aston::Content:0x0000646926a112d0
#    @data=
#     [#<Aston:0x0000646926a110f0
#       @attributes=#<Aston::Attributes:0x0000646926a11078 @data={}>,
#       @content=
#        #<Aston::Content:0x0000646926a11050
#         @data=
#          [#<Aston:0x0000646926a10f38
#            @attributes=#<Aston::Attributes:0x0000646926a10ec0 @data={"attr"=>"value"}>,
#            @content=#<Aston::Content:0x0000646926a10e98 @data=["Hello, world!"]>,
#            @name=:baz>]>,
#       @name=:bar>]>,
#  @name=:root>
```

### `#to_s`

```ruby
puts Aston.new(:root).
        then { |a| a.put_attribute([:bar, :baz], 'attr', 'value') }.
        then { |a| a.put_content([:bar, :baz], "Hello, world!") }.
        to_s
```

```xml
<!-- Aston:1380:root -->
<root>
    <!-- Aston:1400:bar -->
    <bar>
        <!-- Aston:1420:baz -->
        <baz attr='value'>
            Hello, world!
        </baz>
    </bar>
</root>
```

### `#to_json`

```ruby
puts Aston.new(:root).
        then { |a| a.put_attribute([:bar, :baz], 'attr', 'value') }.
        then { |a| a.put_content([:bar, :baz], "Hello, world!") }.
        to_json
#⇒ {"name":"root","attributes":{},"content":[
#     {"name":"bar","attributes":{},"content":[
#        {"name":"baz","attributes":{"attr":"value"},"content":["Hello, world!"]}]}]}
```

### `Aston#parse_hash`

```ruby
json = Aston.new(:root).
         then { |a| a.put_attribute([:bar, :baz], 'attr', 'value') }.
         then { |a| a.put_content([:bar, :baz], "Hello, world!") }.
         to_json
Aston.parse_hash(JSON.parse(json))
#⇒ #<Aston:0x0000643279caa890
#  @attributes=#<Aston::Attributes:0x0000643279caa868 @data={}>,
#  @content=
#   #<Aston::Content:0x0000643279caa840
#    @data=
#     [#<Aston:0x0000643279caa930
#       @attributes=#<Aston::Attributes:0x0000643279caa908 @data={}>,
#       @content=
#        #<Aston::Content:0x0000643279caa8e0
#         @data=
#          [#<Aston:0x0000643279caa9d0
#            @attributes=#<Aston::Attributes:0x0000643279caa9a8 @data={"attr"=>"value"}>,
#            @content=#<Aston::Content:0x0000643279caa980 @data=["Hello, world!"]>,
#            @name="baz">]>,
#       @name="bar">]>,
#  @name="root">
```

### `#update_in`

```ruby
a = Aston.new :aston, attributes: { foo: :bar }
a.put_attribute %i[bar baz], :ok, 42
a.put_content %i[bar baz], 'Hello'
a.update_in %i[bar baz] do |content|
  content <<
    Aston.new(:seq, attributes: { name: :seq1 }) <<
    Aston.new(:seq, attributes: { name: :seq2 }) <<
    Aston.new(:seq, attributes: { name: :seq3 })
end

#⇒ [#<Aston:0x0000643279c616e0
#   @attributes=#<Aston::Attributes:0x0000643279c61668 @data={:ok=>42}>,
#   @content=
#    #<Aston::Content:0x0000643279c61640
#     @data=
#      ["Hello",
#       #<Aston:0x0000643279c60d58
#        @attributes=#<Aston::Attributes:0x0000643279c60d08 @data={:name=>:seq1}>,
#        @content=#<Aston::Content:0x0000643279c60ce0 @data=[]>,
#        @name=:seq>,
#       #<Aston:0x0000643279c60c68
#        @attributes=#<Aston::Attributes:0x0000643279c60c18 @data={:name=>:seq2}>,
#        @content=#<Aston::Content:0x0000643279c60bc8 @data=[]>,
#        @name=:seq>,
#       #<Aston:0x0000643279c60b50
#        @attributes=#<Aston::Attributes:0x0000643279c60b00 @data={:name=>:seq3}>,
#        @content=#<Aston::Content:0x0000643279c60ad8 @data=[]>,
#        @name=:seq>]>,
#   @name=:baz>]
```

`#update_in` returns an array of updated elements on the path given. Unlike `#update_in`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Aston project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/am-kantox/aston/blob/master/CODE_OF_CONDUCT.md).
