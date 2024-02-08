# frozen_string_literal: true

require 'prop_check'

G = PropCheck::Generators

def aston
  G.tree(G.printable_ascii_string) do |aston_gen|
    G.instance(Aston, aston_gen,
               attributes: G.hash_of(G.printable_ascii_string, G.one_of(G.printable_string, G.integer)),
               content: G.array(aston_gen))
  end
end

RSpec.describe Aston do
  it 'builds the content' do
    # testing that Enumerable#sort sorts in ascending order
    PropCheck.forall(aston) do |aston|
      next unless aston.is_a?(Aston)

      expect(aston.content).to be_a Aston::Content
      expect(aston.content.size).to be >= 0
      expect(aston.attributes).to be_a Aston::Attributes
      expect(aston.attributes.size).to be >= 0

      aston.paths.each do |path|
        path = path[1..]
        next if path.empty?

        expect(aston.get(path).content.data.any? { |e| e.is_a?(Aston) }).to be false
      rescue StandardError => e
        puts({ aston_paths: aston.paths, aston: aston, path: path, result: aston.get(path) }).inspect
        raise e
      end
    end
  end
end
