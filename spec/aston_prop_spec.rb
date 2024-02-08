# frozen_string_literal: true

require 'prop_check'

G = PropCheck::Generators

def aston
  G.tree(G.printable_ascii_string) do |aston_gen|
    G.instance(Aston, G.printable_ascii_string,
               attributes: G.hash_of(G.printable_ascii_string, G.one_of(G.printable_string, G.integer)),
               content: G.array(aston_gen))
  end
end

RSpec.describe Aston do
  it 'builds the content' do
    PropCheck.forall(aston) do |aston|
      next unless aston.is_a?(Aston)

      expect(aston.content).to be_a Aston::Content
      expect(aston.content.size).to be >= 0
      expect(aston.attributes).to be_a Aston::Attributes
      expect(aston.attributes.size).to be >= 0

      aston.paths.each do |path|
        path = path[1..]
        next if path.empty? || path.include?('') # FIXME

        expect(aston.get(path).none? { |data| data.content.data.any? { |e| e.is_a?(Aston) } }).to be_truthy
      rescue StandardError => e
        # puts({ aston_paths: aston.paths, aston: aston, path: path, result: aston.get(path) }).inspect
        raise e
      end
    end
  end

  it 'builds JSON' do
    PropCheck.forall(aston) do |aston|
      next unless aston.is_a?(Aston)

      expect(aston).to eq(Aston.parse_hash(JSON.parse(aston.to_json)))
    end
  end
end
