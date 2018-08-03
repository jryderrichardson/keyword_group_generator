require 'spec_helper'
require_relative '../src/keyword_group_generator'

describe 'KeywordGroupGenerator' do
  let(:generator) { KeywordGroupGenerator.new(JSON.parse(File.read('./spec/keywords.json')))  }



  context "Process! will create grouped results" do
    it "isn't null" do
      expect(generator.results).not_to be_nil
    end

    it "is a hash" do
      expect(generator.results).to be_a(Hash)
    end

    it "has keyword arrays" do
      expect(generator.results[generator.results.keys.sample]).to be_a(Array)
    end

    it "contains relevant groups and keywors" do
      generator.results.each do |key, value|
        value.map{|v| expect(v).to include(key)  }
      end
    end

  end


  context "Generate ngram candidates" do
    let!(:candidates) { generator.generate_ngram_candidates([["one", "two", "three", "four", "five"]], 3) }

    it "should have the right number of candidates" do
      expect(candidates.size).to eq(3)
    end

    it "should contain the good cadidates" do
      expect(candidates).to include("one two three")
    end
  end


  context "Appys nGRams to keyword list" do

  end



end
