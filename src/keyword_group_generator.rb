require 'json'


# Applies nGram sorting algorithm to sort a
# selection of random keywords into suggested adgroups
class KeywordGroupGenerator


  MAX_NGRAM_ORDER = 5
  MIN_NGRAM_LENGTH = 2
  MIN_GROUP_SIZE = 5


  # Initialize generator
    # Params:
    # +keywords+:: array of keyword to be sorted
  def initialize(keywords)
    @_keyword_ideas = keywords

    process!
  end


  # Process the keywords
  def process!

    @_ngrams = Array.new(@_keyword_ideas.size)

    generate_ngrams(tokenize_keywords)

    fill_empty_ngrams

    @_results = assign_keywords_to_ngrams
  end



  # Generate all nGram candidates from the tokenized keywords, starting from
  # the maximum order
    # Params:
    # +keyword_tokens+:: tokenized keywords
  def generate_ngrams(keyword_tokens)
    (MAX_NGRAM_ORDER).downto(0) do |i|
      candidates = generate_ngram_candidates(keyword_tokens, i)
      apply_ngram_candidates(candidates)
    end
  end


  # Create all ngram candadates for a given order
    # Params:
    # +keyword_tokens+::
    # +order+:: current nGram order (from 0 to MAX_NGRAM_ORDER)
  def generate_ngram_candidates(keyword_tokens, order)
    candidates = []
    keyword_tokens.each do |tokens|
      (0).upto(tokens.length - order) do |j|
        candidates << tokens.slice(j, j + order).join(" ")
      end
    end
    candidates
  end


  # Apply nGram candidates to initial keywords list
   # Params:
   # +cadidates+: ngram candidates to test against keywords
  def apply_ngram_candidates(candidates)

    unclaimed = @_keyword_ideas.size

    keywords = @_keyword_ideas.map{ |k| pad(k) }

    candidates.each do |candidate|
      break if unclaimed < MIN_GROUP_SIZE

      matching_indexes = []
      keywords.each_with_index do |keyword, i|
          next unless @_ngrams[i] == nil
          if keyword.include? pad(candidate)
            matching_indexes << i
          end
      end

      if matching_indexes.count >= MIN_GROUP_SIZE
        matching_indexes.each do |i|
          @_ngrams[i] = candidate
        end
      end

      unclaimed -= matching_indexes.count
    end

  end


  # Fill empty nGrams with a blank string for odd-one-out
  # keywords which haven't matched the groups
  def fill_empty_ngrams
    @_ngrams.map! { |ngram|
      ngram || ""
    }
  end



  # Group keywords into suggested groups where key is suggested
  # group and value is keywords in the group
  def assign_keywords_to_ngrams
    ngrams = {}
    @_ngrams.each_with_index do |ngram, i|
      (ngrams[ngram] ||= []) << @_keyword_ideas[i]
    end
    ngrams
  end



  # Split all keywords into tokens and remove 'bad' tokens
  def tokenize_keywords
    @_keyword_ideas.map do |keyword|
      remove_bad_tokens(split_into_tokens(keyword))
    end
  end



  # Split a keyword into a tokenn array
    # Params:
    # +keyword+:: keyword to tokenize
  def split_into_tokens(keyword)
    keyword.split(" ").map(&:strip)
  end



  # 'Cleans' tokenized keywords
  #  removed tokens which are null, duplicates, or longer than MAX_NGRAM_LENGTH
    # Params:
    # +keyword_tokens+:: Array of tokenized keywords to clean
  def remove_bad_tokens(keyword_tokens)
    cleaned = []
    previous = nil
    keyword_tokens.each do |token|
      unless token == nil || token == previous
        if token.length > MIN_NGRAM_LENGTH
          cleaned << token
        end
        previous = token
      end
    end
    cleaned
  end



  # Add padding to front and back of a string to avoid
  # matching part-words in comparisons
  def pad(str)
    " " + str + " "
  end


  # Returns results
  def results
    @_results
  end


  # Format results to print to console
  def print_results
    "" << @_results.map { |key, value|
      key + "\n" + value.join(', ')
    }.join("\n\n")
  end


end


# Command line expects JSON array of keywords
if $0 == __FILE__
  keyword_array = JSON.parse File.read(ARGV[0])
  generator = KeywordGroupGenerator.new(keyword_array)
  puts generator.print_results
end
