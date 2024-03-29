# frozen_string_literal: true

require 'json'

RSpec.describe Aston::VERSION do
  it 'has a version number' do
    expect(Aston::VERSION).not_to be nil
  end
end

RSpec.describe Aston do
  it '#put_attribute, #put_content' do
    a = Aston.new :aston, attributes: { foo: :bar }
    expect do
      a.put_content(%i[bar baz], 'Hello', create_intermediate: false)
    end.to raise_error(Aston::Error, "undefined method `filter' for nil:NilClass")
    a.put_attribute %i[bar baz], :ok, 42
    a.put_content %i[bar baz], 'Hello'
    expect(a.get(%i[bar baz]).first.content).to eq(Aston::Content.new(['Hello']))
    expect(a.get(%i[bar baz]).first.attributes).to eq(Aston::Attributes.new({ ok: 42 }))
  end

  it '#update_in' do
    a = Aston.new :aston, attributes: { foo: :bar }
    a.put_attribute %i[bar baz], :ok, 42
    a.put_content %i[bar baz], 'Hello'
    a.update_in %i[bar baz] do |content|
      content <<
        Aston.new(:seq, attributes: { name: :seq1 }) <<
        Aston.new(:seq, attributes: { name: :seq2 }) <<
        Aston.new(:seq, attributes: { name: :seq3 })
    end
    expect(a.get(%i[bar baz]).first.content[2]).to eq(Aston.new(:seq, attributes: { name: :seq2 }))
    expect(a.get(%i[bar baz]).first.attributes).to eq(Aston::Attributes.new({ ok: 42 }))
  end

  it '#paths' do
    a = Aston.new :aston, attributes: { foo: :bar }
    expect(a.paths).to match_array([%i[aston]])
    a.put_content %i[bar1 baz1], 'Hello'
    a.put_content %i[bar1 baz2], 'Hello'
    a.put_content %i[bar2 baz1], 'Hello'
    a.put_content [:bar3], 'Hello'

    expect(a.paths).to match_array([%i[aston bar1 baz1], %i[aston bar1 baz2], %i[aston bar2 baz1], %i[aston bar3]])
  end

  it '#to_json' do
    a = Aston.new :aston, attributes: { foo: :bar }
    expect(a.paths).to match_array([%i[aston]])
    a.put_content %i[bar1 baz1], 'Hello'
    a.put_content %i[bar1 baz2], 'Hello'
    a.put_content %i[bar2 baz1], 'Hello'
    a.put_content [:bar3], 'Hello'

    expect(JSON.parse(a.to_json)).to eq(
      { 'attributes' => { 'foo' => 'bar' },
        'content' => [
          { 'attributes' => {},
            'content' => [{ 'attributes' => {}, 'content' => ['Hello'], 'name' => 'baz1' },
                          { 'attributes' => {}, 'content' => ['Hello'], 'name' => 'baz2' }],
            'name' => 'bar1' },
          { 'attributes' => {},
            'content' => [{ 'attributes' => {}, 'content' => ['Hello'], 'name' => 'baz1' }],
            'name' => 'bar2' },
          { 'attributes' => {}, 'content' => ['Hello'], 'name' => 'bar3' }
        ],
        'name' => 'aston' }
    )
  end

  it '#<<' do
    a = Aston.new(:aston, attributes: { foo: :bar }) << Aston.new(:foo1) << Aston.new(:foo2)
    expect(a.to_hash(remove_empty: true)).to eq({
                                                  attributes: { foo: :bar },
                                                  content: [{ name: :foo1 }, { name: :foo2 }],
                                                  name: :aston
                                                })
  end
end
